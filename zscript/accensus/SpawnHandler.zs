// Struct for itemspawn information.
class AceCorpsSpawnItem play {
	// ID by string for spawner
	string spawnName;
	
	// ID by string for spawnees
	Array<AceCorpsSpawnItemEntry> spawnReplaces;
	
	// Whether or not to persistently spawn.
	bool isPersistent;
	
	// Whether or not to replace the original item.
	bool replaceItem;

	string toString() {

		let replacements = "[";
		if (spawnReplaces.size()) {
			replacements = replacements..spawnReplaces[0].toString();

			foreach (spawnReplace : spawnReplaces) replacements = replacements..", "..spawnReplace.toString();
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

			foreach (weaponName : weaponNames) weapons = weapons..", "..weaponName;
		}
		weapons = weapons.."]";

		return String.format("{ ammoName=%s, weaponNames=%s }", ammoName, weapons);
	}
}



// One handler to rule them all.
class AceCorpsWepsHandler : EventHandler {

	// List of persistent classes to completely ignore.
	// This -should- mean this mod has no performance impact.
	static const string blacklist[] = {
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

			if (replacees.size() > 1) foreach (replacee : replacees) msg = msg..", "..replacee.toString();

			console.printf(msg.."]");
		}

		// Creates a new struct;
		AceCorpsSpawnItem spawnee = AceCorpsSpawnItem(new('AceCorpsSpawnItem'));

		// Populates the struct with relevant information,
		spawnee.spawnName = name;
		spawnee.isPersistent = persists;
		spawnee.replaceItem = rep;

		foreach (replacee : replacees) spawnee.spawnReplaces.push(replacee);

		// Pushes the finished struct to the array.
		itemSpawnList.push(spawnee);
	}

	AceCorpsSpawnItemEntry addItemEntry(string name, int chance) {
		// Creates a new struct;
		AceCorpsSpawnItemEntry spawnee = AceCorpsSpawnItemEntry(new('AceCorpsSpawnItemEntry'));
		spawnee.name = name.makeLower();
		spawnee.chance = chance;
		return spawnee;
	}

	// appends an entry to ammoSpawnList;
	void addAmmo(string name, Array<string> weapons) {

		// Creates a new struct;
		AceCorpsSpawnAmmo spawnee = AceCorpsSpawnAmmo(new('AceCorpsSpawnAmmo'));
		spawnee.ammoName = name.makeLower();

		// Populates the struct with relevant information,
		foreach (weapon : weapons) spawnee.weaponNames.push(weapon.makeLower());

		// Pushes the finished struct to the array.
		ammoSpawnList.push(spawnee);
	}


	// Populates the replacement and association arrays.
	void init() {
		
		cvarsAvailable = true;

		//------------
		// Ammunition
		//------------

		// .355
		Array<string> wep_355;
		wep_355.push("HDBlackjack");
		addAmmo("HDRevolverAmmo", wep_355);

		// 12 gauge Buckshot Ammo.
		Array<string> wep_12gaShell;
		wep_12gaShell.push("HDBlackjack");
		addAmmo("HDShellAmmo", wep_12gaShell);

		// HDBattery. 
		Array<string> wep_battery;  
		wep_battery.push("HDGungnir");
		addAmmo('HDBattery', wep_battery);

		// Blackhawk Bolts
		Array<string> wep_bolts;
		wep_bolts.push("HDBlackhawk");
		addAmmo("HDBlackhawkBoltRegular", wep_bolts);
		addAmmo("HDBlackhawkBoltIncendiary", wep_bolts);
		addAmmo("HDBlackhawkBoltElectric", wep_bolts);
		addAmmo("HDBlackhawkBoltNuclear", wep_bolts);


		//------------
		// Weaponry
		//------------

		// Blackhawk
		Array<AceCorpsSpawnItemEntry> spawns_blackhawk;
		spawns_blackhawk.push(addItemEntry("HDRL", blackhawk_launcher_spawn_bias));
		addItem("BlackhawkRandom", spawns_blackhawk, blackhawk_persistent_spawning);

		// Blackjack
		Array<AceCorpsSpawnItemEntry> spawns_blackjack;
		spawns_blackjack.push(addItemEntry("HDAmBoxUnarmed", blackjack_clipbox_spawn_bias));
		spawns_blackjack.push(addItemEntry("HDAmBox", blackjack_clipbox_spawn_bias));
		addItem("BlackjackRandom", spawns_blackjack, blackjack_persistent_spawning);

		// Gungnir
		Array<AceCorpsSpawnItemEntry> spawns_gungnir;
		spawns_gungnir.push(addItemEntry("BFG9K", gungnir_bfg_spawn_bias));
		addItem("GungnirRandom", spawns_gungnir, gungnir_persistent_spawning);


		//------------
		// Ammunition
		//------------

		// Blackhawk Bolts
		Array<AceCorpsSpawnItemEntry> spawns_blackhawkBolts;
		spawns_blackhawkBolts.push(addItemEntry("HDRocketAmmo", blackhawkBolts_rocket_spawn_bias));
		addItem("HDBlackhawkBoltBundle", spawns_blackhawkBolts, blackhawkBolts_persistent_spawning);

		// Blackjack .355 Mag
		Array<AceCorpsSpawnItemEntry> spawns_blackjack_355mag;
		spawns_blackjack_355mag.push(addItemEntry("ClipMagPickup", blackjack355mag_clip_spawn_bias));
		addItem("HDBlackjackMag355", spawns_blackjack_355mag, blackjack355mag_persistent_spawning);

		// Blackjack 12ga Shell Mag
		Array<AceCorpsSpawnItemEntry> spawns_blackjack_shellmag;
		spawns_blackjack_shellmag.push(addItemEntry("HDShellAmmo", blackjackshellmag_shell_spawn_bias));
		addItem("HDBlackjackMagShells", spawns_blackjack_shellmag, blackjackshellmag_persistent_spawning);


		// --------------------
		// Item Spawns
		// --------------------
	}

	// Random stuff, stores it and forces negative values just to be 0.
	bool giveRandom(int chance) {
		if (chance > -1) {
			let result = random(0, chance);

			if (hd_debug) console.printf("Rolled a "..(result + 1).." out of "..(chance + 1));

			return result == 0;
		}

		return false;
	}

	// Tries to create the item via random spawning.
	bool tryCreateItem(Actor thing, string spawnName, int chance, bool rep) {
		if (giveRandom(chance)) {
            if (Actor.Spawn(spawnName, thing.pos) && rep) {
                if (hd_debug) console.printf(thing.getClassName().." -> "..spawnName);

                thing.destroy();

				return true;
			}
		}

		return false;
	}

	override void worldThingSpawned(WorldEvent e) {
		// Populates the main arrays if they haven't been already. 
		if (!cvarsAvailable) init();

		// If thing spawned doesn't exist, quit
		if (!e.thing) return;

		// If thing spawned is blacklisted, quit
		foreach (bl : blacklist) if (e.thing is bl) return;

		string candidateName = e.thing.getClassName();
		candidateName = candidateName.makeLower();

		// Pointers for specific classes.
		let ammo = HDAmmo(e.thing);

		// If the thing spawned is an ammunition, add any and all items that can use this.
		if (ammo) handleAmmoUses(ammo, candidateName);

		// Return if range before replacing things.
		if (level.MapName ~== "RANGE") return;

        handleWeaponReplacements(e.thing, ammo, candidateName);
	}

	private void handleAmmoUses(HDAmmo ammo, string candidateName) {
		foreach (ammoSpawn : ammoSpawnList) if (candidateName == ammoSpawn.ammoName) ammo.itemsThatUseThis.copy(ammoSpawn.weaponNames);
	}

    private void handleWeaponReplacements(Actor thing, HDAmmo ammo, string candidateName) {

		// Checks if the level has been loaded more than 1 tic.
		bool prespawn = !(level.maptime > 1);

		// Iterates through the list of item candidates for e.thing.
		foreach (itemSpawn : itemSpawnList) {

			// if an item is owned or is an ammo (doesn't retain owner ptr),
			// do not replace it.
            let item = Inventory(thing);
            if ((prespawn || itemSpawn.isPersistent) && (!(item && item.owner) && (!ammo || prespawn))) {
				foreach (spawnReplace : itemSpawn.spawnReplaces) {
					if (spawnReplace.name == candidateName) {
						if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..itemSpawn.spawnName.."...");

                        if (tryCreateItem(thing, itemSpawn.spawnName, spawnReplace.chance, itemSpawn.replaceItem)) return;
					}
				}
			}
		}
	}
}
