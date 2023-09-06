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

        foreach (spawnReplace : spawnReplaces) replacements = replacements..", "..spawnReplace.toString();

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

        foreach (weaponName : weaponNames) weapons = weapons..", "..weaponName;

        weapons = weapons.."]";

        return String.format("{ ammoName=%s, weaponNames=%s }", ammoName, weapons);
    }
}



// One handler to rule them all.
class AceCorpsWepsHandler : EventHandler {

    // List of persistent classes to completely ignore.
    // This -should- mean this mod has no performance impact.
    static const string blacklist[] = {
        'HDSmoke',
        'BloodTrail',
        'CheckPuff',
        'WallChunk',
        'HDBulletPuff',
        'HDFireballTail',
        'ReverseImpBallTail',
        'HDSmokeChunk',
        'ShieldSpark',
        'HDFlameRed',
        'HDMasterBlood',
        'PlantBit',
        'HDBulletActor',
        'HDLadderSection'
    };

    // List of CVARs for Backpack Spawns
    array<Class <Inventory> > backpackBlacklist;

    // Cache of Ammo Box Loot Table
    private HDAmBoxList ammoBoxList;

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

            let msg = "Adding "..(persists ? "Persistent" : "Non-Persistent").." Replacement Entry for "..name..": [";

            foreach (replacee : replacees) msg = msg..", "..replacee.toString();

            console.printf(msg.."]");
        }

        // Creates a new struct;
        AceCorpsSpawnItem spawnee = AceCorpsSpawnItem(new('AceCorpsSpawnItem'));

        // Populates the struct with relevant information,
        spawnee.spawnName = name;
        spawnee.isPersistent = persists;
        spawnee.replaceItem = rep;
        spawnee.spawnReplaces.copy(replacees);

        // Pushes the finished struct to the array.
        itemSpawnList.push(spawnee);
    }

    AceCorpsSpawnItemEntry addItemEntry(string name, int chance) {

        // Creates a new struct;
        AceCorpsSpawnItemEntry spawnee = AceCorpsSpawnItemEntry(new('AceCorpsSpawnItemEntry'));
        spawnee.name = name;
        spawnee.chance = chance;
        return spawnee;
    }

    // appends an entry to ammoSpawnList;
    void addAmmo(string name, Array<string> weapons) {

        if (hd_debug) {
            let msg = "Adding Ammo Association Entry for "..name..": [";

            foreach (weapon : weapons) msg = msg..", "..weapon;

            console.printf(msg.."]");
        }

        // Creates a new struct;
        AceCorpsSpawnAmmo spawnee = AceCorpsSpawnAmmo(new('AceCorpsSpawnAmmo'));
        spawnee.ammoName = name;
        spawnee.weaponNames.copy(weapons);

        // Pushes the finished struct to the array.
        ammoSpawnList.push(spawnee);
    }


    // Populates the replacement and association arrays.
    void init() {
        
        cvarsAvailable = true;
        
        //-----------------
        // Backpack Spawns
        //-----------------

        if (!blackhawk_allowBackpacks)         backpackBlacklist.push((Class<Inventory>)('HDBlackhawk'));
        if (!blackjack_allowBackpacks)         backpackBlacklist.push((Class<Inventory>)('HDBlackjack'));
        if (!gungnir_allowBackpacks)           backpackBlacklist.push((Class<Inventory>)('HDGungnir'));
        if (!hammerhead_allowBackpacks)        backpackBlacklist.push((Class<Inventory>)('HDHammerhead'));
        if (!jackdaw_allowBackpacks)           backpackBlacklist.push((Class<Inventory>)('HDJackdaw'));
        if (!majestic_allowBackpacks)          backpackBlacklist.push((Class<Inventory>)('HDMajestic'));
        if (!redline_allowBackpacks)           backpackBlacklist.push((Class<Inventory>)('HDRedline'));
        if (!scorpion_allowBackpacks)          backpackBlacklist.push((Class<Inventory>)('HDScorpion'));
        if (!viper_allowBackpacks)             backpackBlacklist.push((Class<Inventory>)('HDViper'));
        if (!wyvern_allowBackpacks)            backpackBlacklist.push((Class<Inventory>)('HDWyvern'));
        
        if (!blackhawkBolts_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HDBlackhawkBoltRegular'));
        if (!blackhawkBolts_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HDBlackhawkBoltIncendiary'));
        if (!blackhawkBolts_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HDBlackhawkBoltElectric'));
        if (!blackhawkBolts_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HDBlackhawkBoltNuclear'));
        if (!blackjack355mag_allowBackpacks)   backpackBlacklist.push((Class<Inventory>)('HDBlackjackMag355'));
        if (!blackjackshellmag_allowBackpacks) backpackBlacklist.push((Class<Inventory>)('HDBlackjackMagShells'));
        if (!majesticmag_allowBackpacks)       backpackBlacklist.push((Class<Inventory>)('HDMajesticMag'));
        if (!vipermag_allowBackpacks)          backpackBlacklist.push((Class<Inventory>)('HDViperMag'));

        if (!ladderlauncher_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('LadderLauncher'));
        if (!psg_allowBackpacks)               backpackBlacklist.push((Class<Inventory>)('HDPersonalShieldGenerator'));
        if (!secretfinder_allowBackpacks)      backpackBlacklist.push((Class<Inventory>)('HDSecretFinder'));
        if (!superstim_allowBackpacks)         backpackBlacklist.push((Class<Inventory>)('PortableSuperStimpack'));
        if (!fak_allowBackpacks)               backpackBlacklist.push((Class<Inventory>)('HDFieldAssemblyKit'));
        // I'm gonna have the FAK toggle disable assembly cores also, they should have no use outside of the Field Assembly Kit and Merchant and it was part of the original mod so I think it's fine. - [Ted]
        if (!fak_allowBackpacks)               backpackBlacklist.push((Class<Inventory>)('AssemblyCore'));
        if (!boosterJets_allowBackpacks)       backpackBlacklist.push((Class<Inventory>)('HDBoosterJets'));
        if (!dsd_allowBackpacks)               backpackBlacklist.push((Class<Inventory>)('DSDInterface'));
        if (!rearviewmirror_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HDRearviewMirror'));
        if (!roomba_allowBackpacks)            backpackBlacklist.push((Class<Inventory>)('HDRoomba'));
        if (!supplybeacon_allowBackpacks)      backpackBlacklist.push((Class<Inventory>)('HDSupplyBeacon'));
        if (!teleporter_allowBackpacks)        backpackBlacklist.push((Class<Inventory>)('HDTeleporter'));
        if (!soulcube_allowBackpacks)          backpackBlacklist.push((Class<Inventory>)('HDSoulCube'));
        if (!magreloader_allowBackpacks)       backpackBlacklist.push((Class<Inventory>)('HDMagazineReloader'));
        if (!hackedreloader_allowBackpacks)    backpackBlacklist.push((Class<Inventory>)('HackedReloader'));

        //------------
        // Ammunition
        //------------

        // 9mm
        Array<string> wep_9mm;
        wep_9mm.push('HDJackdaw');
        addAmmo('HDPistolAmmo', wep_9mm);

        // .355
        Array<string> wep_355;
        wep_355.push('HDBlackjack');
        addAmmo('HDRevolverAmmo', wep_355);

        // 12 gauge Buckshot Ammo.
        Array<string> wep_12gaShell;
        wep_12gaShell.push('HDBlackjack');
        addAmmo('HDShellAmmo', wep_12gaShell);

        // HDBattery. 
        Array<string> wep_battery;  
        wep_battery.push('HDGungnir');
        wep_battery.push('HDHammerhead');
        wep_battery.push('HDRedline');
        wep_battery.push('HDTeleporter');
        addAmmo('HDBattery', wep_battery);

        // 35mm
        Array<string> wep_35mm;
        wep_35mm.push('HDScorpion');
        addAmmo('BrontornisRound', wep_35mm);

        // .50 AM
        Array<string> wep_50am;
        wep_50am.push('HDViper');
        addAmmo('HD50AM_Ammo', wep_50am);

        // .500 S&W Light
        Array<string> wep_500swl;
        wep_500swl.push('HDMajestic');
        addAmmo('HD500SWLightAmmo', wep_500swl);

        // .50 OMG
        Array<string> wep_OMG;
        wep_OMG.push('HDWyvern');
        addAmmo('HD50OMGAmmo', wep_OMG);

        // Blackhawk Bolts
        Array<string> wep_bolts;
        wep_bolts.push('HDBlackhawk');
        addAmmo('HDBlackhawkBoltRegular', wep_bolts);
        addAmmo('HDBlackhawkBoltIncendiary', wep_bolts);
        addAmmo('HDBlackhawkBoltElectric', wep_bolts);
        addAmmo('HDBlackhawkBoltNuclear', wep_bolts);


        //------------
        // Weaponry
        //------------

        // Blackhawk
        Array<AceCorpsSpawnItemEntry> spawns_blackhawk;
        spawns_blackhawk.push(addItemEntry('HDRL', blackhawk_launcher_spawn_bias));
        addItem('BlackhawkRandom', spawns_blackhawk, blackhawk_persistent_spawning);

        // Blackjack
        Array<AceCorpsSpawnItemEntry> spawns_blackjack;
        spawns_blackjack.push(addItemEntry('HDAmBoxUnarmed', blackjack_clipbox_spawn_bias));
        spawns_blackjack.push(addItemEntry('HDAmBox', blackjack_clipbox_spawn_bias));
        addItem('BlackjackRandom', spawns_blackjack, blackjack_persistent_spawning);

        // Gungnir
        Array<AceCorpsSpawnItemEntry> spawns_gungnir;
        spawns_gungnir.push(addItemEntry('BFG9K', gungnir_bfg_spawn_bias));
        addItem('GungnirRandom', spawns_gungnir, gungnir_persistent_spawning);

        // Hammerhead
        Array<AceCorpsSpawnItemEntry> spawns_hammerhead;
        spawns_hammerhead.push(addItemEntry('Vulcanette', hammerhead_chaingun_spawn_bias));
        spawns_hammerhead.push(addItemEntry('Thunderbuster', hammerhead_thunderbuster_spawn_bias));
        addItem('HammerheadRandom', spawns_hammerhead, hammerhead_persistent_spawning);

        // Jackdaw
        Array<AceCorpsSpawnItemEntry> spawns_jackdaw;
        spawns_jackdaw.push(addItemEntry('Vulcanette', jackdaw_vulcanette_spawn_bias));
        addItem('JackdawRandom', spawns_jackdaw, jackdaw_persistent_spawning);

        // Majestic
        Array<AceCorpsSpawnItemEntry> spawns_majestic;
        spawns_majestic.push(addItemEntry('HDPistol', majestic_pistol_spawn_bias));
        spawns_majestic.push(addItemEntry('Hunter', majestic_hunter_spawn_bias));
        spawns_majestic.push(addItemEntry('Slayer', majestic_slayer_spawn_bias));
        addItem('MajesticRandom', spawns_majestic, majestic_persistent_spawning);

        // Redline
        Array<AceCorpsSpawnItemEntry> spawns_redline;
        spawns_redline.push(addItemEntry('Thunderbuster', redline_thunderbuster_spawn_bias));
        addItem('RedlineRandom', spawns_redline, redline_persistent_spawning);

        // Scorpion
        Array<AceCorpsSpawnItemEntry> spawns_scorpion;
        spawns_scorpion.push(addItemEntry('BrontornisSpawner', scorpion_bronto_spawn_bias));
        addItem('ScorpionSpawner', spawns_scorpion, scorpion_persistent_spawning);

        // Viper
        Array<AceCorpsSpawnItemEntry> spawns_viper;
        spawns_viper.push(addItemEntry('HDPistol', viper_pistol_spawn_bias));
        spawns_viper.push(addItemEntry('Hunter', viper_hunter_spawn_bias));
        addItem('ViperRandom', spawns_viper, viper_persistent_spawning);

        // Wyvern
        Array<AceCorpsSpawnItemEntry> spawns_wyvern;
        spawns_wyvern.push(addItemEntry('Hunter', wyvern_hunter_spawn_bias));
        spawns_wyvern.push(addItemEntry('Slayer', wyvern_slayer_spawn_bias));
        addItem('WyvernRandom', spawns_wyvern, wyvern_persistent_spawning);


        //------------
        // Ammunition
        //------------

        // Blackhawk Bolts
        Array<AceCorpsSpawnItemEntry> spawns_blackhawkBolts;
        spawns_blackhawkBolts.push(addItemEntry('HDRocketAmmo', blackhawkBolts_rocket_spawn_bias));
        addItem('HDBlackhawkBoltBundle', spawns_blackhawkBolts, blackhawkBolts_persistent_spawning);

        // Blackjack .355 Mag
        Array<AceCorpsSpawnItemEntry> spawns_blackjack_355mag;
        spawns_blackjack_355mag.push(addItemEntry('ClipMagPickup', blackjack355mag_clip_spawn_bias));
        addItem('HDBlackjackMag355', spawns_blackjack_355mag, blackjack355mag_persistent_spawning);

        // Blackjack 12ga Shell Mag
        Array<AceCorpsSpawnItemEntry> spawns_blackjack_shellmag;
        spawns_blackjack_shellmag.push(addItemEntry('HDShellAmmo', blackjackshellmag_shell_spawn_bias));
        addItem('HDBlackjackMagShells', spawns_blackjack_shellmag, blackjackshellmag_persistent_spawning);

        // Majestic Magazine
        Array<AceCorpsSpawnItemEntry> spawns_majesticmag;
        spawns_majesticmag.push(addItemEntry('HD9mMag15', majesticmag_clipmag_spawn_bias));
        addItem('HDMajesticMag', spawns_majesticmag, majesticmag_persistent_spawning);

        // Viper Magazine
        Array<AceCorpsSpawnItemEntry> spawns_vipermag;
        spawns_vipermag.push(addItemEntry('HD9mMag15', vipermag_clipmag_spawn_bias));
        addItem('HDViperMag', spawns_vipermag, vipermag_persistent_spawning);


        // --------------------
        // Item Spawns
        // --------------------

        // Deployable Barricade
        Array<AceCorpsSpawnItemEntry> spawns_deployablebarricade;
        spawns_deployablebarricade.push(addItemEntry('HDRL', deployablebarricade_rl_spawn_bias));
        addItem('HDDeployableBarricade', spawns_deployablebarricade, deployablebarricade_persistent_spawning);

        // Ladder Launcher
        Array<AceCorpsSpawnItemEntry> spawns_ladderlauncher;
        spawns_ladderlauncher.push(addItemEntry('RocketBigPickup', ladderlauncher_rocketbox_spawn_bias));
        spawns_ladderlauncher.push(addItemEntry('HDBattery', ladderlauncher_cellpack_spawn_bias));
        addItem('LadderLauncher', spawns_ladderlauncher, ladderlauncher_persistent_spawning);

        // Personal Shield Generator
        Array<AceCorpsSpawnItemEntry> spawns_psg;
        spawns_psg.push(addItemEntry('BattleArmour', psg_battlearmor_spawn_bias));
        addItem('PsgRandom', spawns_psg, psg_persistent_spawning);

        // Secret Finder
        Array<AceCorpsSpawnItemEntry> spawns_secretfinder;
        spawns_secretfinder.push(addItemEntry('HDMap', secretfinder_map_spawn_bias));
        addItem('HDSecretFinder', spawns_secretfinder, secretfinder_persistent_spawning);

        // Soul Cube
        Array<AceCorpsSpawnItemEntry> spawns_soulcube;
        spawns_soulcube.push(addItemEntry('Lumberjack', soulcube_chainsaw_spawn_bias));
        addItem('HDSoulCube', spawns_soulcube, soulcube_persistent_spawning);

        // Super Stimpack
        Array<AceCorpsSpawnItemEntry> spawns_superstim;
        spawns_superstim.push(addItemEntry('PortableMedicalItem', superstim_medical_spawn_bias));
        addItem('PortableSuperStimpack', spawns_superstim, superstim_persistent_spawning);

        // Weapon Crate
        Array<AceCorpsSpawnItemEntry> spawns_weaponcrate;
        spawns_weaponcrate.push(addItemEntry('HDRL', weaponcrate_rl_spawn_bias));
        addItem('HDWeaponCrate', spawns_weaponcrate, weaponcrate_persistent_spawning);

        // Dimensional Storage Device
        Array<AceCorpsSpawnItemEntry> spawns_dsd;
        spawns_dsd.push(addItemEntry('WildBackpack', dsd_backpack_spawn_bias));
        addItem('DSDInterface', spawns_dsd, dsd_persistent_spawning);
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

    override void worldLoaded(WorldEvent e) {

        // Populates the main arrays if they haven't been already. 
        if (!cvarsAvailable) init();

        foreach (bl : backpackBlacklist) {
            if (hd_debug) console.printf("Removing "..bl.getClassName().." from Backpack Spawn Pool");
                
            BPSpawnPool.removeItem(bl);
        }
    }

    override void worldThingSpawned(WorldEvent e) {

        // If thing spawned doesn't exist, quit
        if (!e.thing) return;

        // If thing spawned is blacklisted, quit
        foreach (bl : blacklist) if (e.thing is bl) return;

        string candidateName = e.thing.getClassName();

        // Pointers for specific classes.
        let ammo = HDAmmo(e.thing);

        // If the thing spawned is an ammunition, add any and all items that can use this.
        if (ammo) handleAmmoUses(ammo, candidateName);

        // Return if range before replacing things.
        if (level.MapName == 'RANGE') return;

        if (e.thing is 'HDAmBox') {
            handleAmmoBoxLootTable();
        } else {
            handleWeaponReplacements(e.thing, ammo, candidateName);
        }
    }

    private void handleAmmoBoxLootTable() {
        if (!ammoBoxList) {
            ammoBoxList = HDAmBoxList.Get();

            foreach (bl : backpackBlacklist) {
                let index = ammoBoxList.invClasses.find(bl.getClassName());

                if (index != ammoBoxList.invClasses.Size()) {
                    if (hd_debug) console.printf("Removing "..bl.getClassName().." from Ammo Box Loot Table");

                    ammoBoxList.invClasses.Delete(index);
                }
            }
        }
    }

    private void handleAmmoUses(HDAmmo ammo, string candidateName) {
        foreach (ammoSpawn : ammoSpawnList) if (candidateName ~== ammoSpawn.ammoName) {
            if (hd_debug) {
                console.printf("Adding the following to the list of items that use "..ammo.getClassName().."");
                foreach (weapon : ammoSpawn.weaponNames) console.printf("* "..weapon);
            }

            ammo.itemsThatUseThis.append(ammoSpawn.weaponNames);
        }
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
                    if (spawnReplace.name ~== candidateName) {
                        if (hd_debug) console.printf("Attempting to replace "..candidateName.." with "..itemSpawn.spawnName.."...");

                        if (tryCreateItem(thing, itemSpawn.spawnName, spawnReplace.chance, itemSpawn.replaceItem)) return;
                    }
                }
            }
        }
    }
}
