// Struct for itemspawn information.
class AceCorpsSpawnItem play {
	// ID by string for spawner
	string spawnName;
	
	// ID by string for spawnees
	Array<AceCorpsSpawnItemEntry> spawnReplaces;
	
	// Whether or not to persistently spawn.
	bool isPersistent;
	
	bool replaceItem;

	string toString() {

		let replacements = "[";
		if (spawnReplaces.size()) {
			replacements = replacements..spawnReplaces[0].toString();

			for (let i = 1; i < spawnReplaces.size(); i++) {
				replacements = replacements..", "..spawnReplaces[i].toString();
			}
		}
		replacements = replacements.."]";


		return String.format("{ spawnName=%s, spawnReplaces=%s, isPersistent=%b, replaceItem=%b }", spawnName, replacements, isPersistent, replaceItem);
	}
}

class AceCorpsSpawnItemEntry play {
	string name;
	int    chance;

	string toString() {
		return String.format("{ name=%s, chance=%s }", name, chance >= 0 ? "1/"..(chance + 1) : "never");
	}
}

// Struct for passing useinformation to ammunition.
class AceCorpsSpawnAmmo play {
	// ID by string for the header ammo.
	string ammoName;
	
	// ID by string for weapons using that ammo.
	Array<string> weaponNames;
	
	string toString() {

		let weapons = "[";
		if (weaponNames.size()) {
			weapons = weapons..weaponNames[0];

			for (let i = 1; i < weaponNames.size(); i++) {
				weapons = weapons..", "..weaponNames[i];
			}
		}
		weapons = weapons.."]";

		return String.format("{ ammoName=%s, weaponNames=%s }", ammoName, weapons);
	}
}



// One handler to rule them all.
class AceCorpsWepsHandler : EventHandler {

	// List of persistent classes to completely ignore.
	// This -should- mean this mod has no performance impact.
	static const class<actor> blacklist[] = {
		"HDSmoke",
		"BloodTrail",
		"CheckPuff",
		"WallChunk",
		"HDBulletPuff",
		"HDFireballTail",
		"ReverseImpBallTail",
		"HDSmokeChunk",
		"ShieldSpark",
		"HDFlameRed",
		"HDMasterBlood",
		"PlantBit",
		"HDBulletActor",
		"HDLadderSection"
	};

	// List of weapon-ammo associations.
	// Used for ammo-use association on ammo spawn (happens very often).
	array<AceCorpsSpawnAmmo> ammoSpawnList;

	// List of item-spawn associations.
	// used for item-replacement on mapload.
	array<AceCorpsSpawnItem> itemSpawnList;

	bool cvarsAvailable;

	// appends an entry to itemSpawnList;
	void addItem(string name, Array<AceCorpsSpawnItemEntry> replacees, bool persists, bool rep=true) {

		if (hd_debug) {
			let msg = "Adding "..(persists ? "Persistent" : "Non-Persistent").." Replacement Entry for "..name..": ["..replacees[0].toString();

			if (replacees.size() > 1) {
				for (let i = 1; i < replacees.size(); i++) msg = msg..", "..replacees[i].toString();
			}

			console.printf(msg.."]");
		}

		// Creates a new struct;
		AceCorpsSpawnItem spawnee = AceCorpsSpawnItem(new('AceCorpsSpawnItem'));

		// Populates the struct with relevant information,
		spawnee.spawnName = name;
		spawnee.isPersistent = persists;
		spawnee.replaceItem = rep;

		for (int i = 0; i < replacees.size(); i++) {
			spawnee.spawnReplaces.push(replacees[i]);
		}

		// Pushes the finished struct to the array.
		itemSpawnList.push(spawnee);
	}

	AceCorpsSpawnItemEntry addItemEntry(string name, int chance) {
		// Creates a new struct;
		AceCorpsSpawnItemEntry spawnee = AceCorpsSpawnItemEntry(new('AceCorpsSpawnItemEntry'));
		spawnee.name = name.makelower();
		spawnee.chance = chance;
		return spawnee;
	}

	// appends an entry to ammoSpawnList;
	void addAmmo(string name, Array<string> weapons) {

		// Creates a new struct;
		AceCorpsSpawnAmmo spawnee = AceCorpsSpawnAmmo(new('AceCorpsSpawnAmmo'));
		spawnee.ammoName = name.makelower();

		// Populates the struct with relevant information,
		for (int i = 0; i < weapons.size(); i++) {
			spawnee.weaponNames.push(weapons[i].makelower());
		}

		// Pushes the finished struct to the array.
		ammoSpawnList.push(spawnee);
	}


	// Populates the replacement and association arrays.
	void init() {
		
		cvarsAvailable = true;

		//------------
		// Ammunition
		//------------



		//------------
		// Weaponry
		//------------



		//------------
		// Ammunition
		//------------

        

		// --------------------
		// Item Spawns
		// --------------------
	}

	// Random stuff, stores it and forces negative values just to be 0.
	bool giveRandom(int chance) {
		if (chance > -1) {
			let result = random(0, chance);

			if (hd_debug) console.printf("Rolled a "..result.." out of "..(chance + 1));

			return result == 0;
		}

		return false;
	}

	// Tries to create the item via random spawning.
	bool tryCreateItem(Actor thing, AceCorpsSpawnItem f, int g, bool rep) {
		if (giveRandom(f.spawnReplaces[g].chance)) {
            if (Actor.Spawn(f.spawnName, thing.pos) && rep) {
                if (hd_debug) console.printf(thing.GetClassName().." -> "..f.spawnName);

                thing.destroy();

				return true;
			}
		}

		return false;
	}

	override void worldthingspawned(worldevent e) {
		// Populates the main arrays if they haven't been already. 
		if (!cvarsAvailable) init();

		// If thing spawned doesn't exist, quit
		if (!e.Thing) return;

		// If thing spawned is blacklisted, quit
		for (let i = 0; i < blacklist.size(); i++) if (e.thing is blacklist[i]) return;

		string candidateName = e.Thing.GetClassName();
		candidateName = candidateName.makelower();

		// Pointers for specific classes.
		let ammo = HDAmmo(e.Thing);

		// If the thing spawned is an ammunition, add any and all items that can use this.
		if (ammo) handleAmmoUses(ammo, candidateName);

		// Return if range before replacing things.
		if (level.MapName ~== "RANGE") return;

        handleWeaponReplacements(e.Thing, ammo, candidateName);
	}

	private void handleAmmoUses(HDAmmo ammo, string candidateName) {
		// Goes through the entire ammospawn array.
		for (let i = 0; i < ammoSpawnList.size(); i++) {
			if (candidateName == ammoSpawnList[i].ammoName) {
				// Appends each entry in that ammo's subarray.
				for (let j = 0; j < ammoSpawnList[i].weaponNames.size(); j++) {
					// Actual pushing to itemsthatusethis().
					ammo.ItemsThatUseThis.Push(ammoSpawnList[i].weaponNames[j]);
				}
			}
		}
	}

    private void handleWeaponReplacements(Actor thing, HDAmmo ammo, string candidateName) {

		// Checks if the level has been loaded more than 1 tic.
		bool prespawn = !(level.maptime > 1);

		// Iterates through the list of item candidates for e.thing.
		for (let i = 0; i < itemSpawnList.size(); i++) {

			// if an item is owned or is an ammo (doesn't retain owner ptr),
			// do not replace it.
            let item = Inventory(thing);
            if ((prespawn || itemSpawnList[i].isPersistent) && (!(item && item.owner) && (!ammo || prespawn))) {
				for (let j = 0; j < itemSpawnList[i].spawnReplaces.size(); j++) {
					if (itemSpawnList[i].spawnReplaces[j].name == candidateName) {
						if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..itemSpawnList[i].spawnName.."...");

                        if (tryCreateItem(thing, itemSpawnList[i], j, itemSpawnList[i].replaceItem)) return;
					}
				}
			}
		}
	}
}
