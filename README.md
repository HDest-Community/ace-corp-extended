# AceCorp: Engineering Dept.

[![Nightly Build](https://github.com/HDest-Community/ace-corp-extended/actions/workflows/nightly.yml/badge.svg)](https://github.com/HDest-Community/ace-corp-extended/actions/workflows/nightly.yml)

_Requires [BulletLib - Recasted](https://github.com/HDest-Community/HDBulletLib-Recasted) and [AceCoreLib](https://github.com/HDest-Community/AceCoreLib), by the HDest Community._

This mod aims to maintain and improve Accensus' Arsenal, by updating them to the latest HDest main, as well as tweaking/fixing any bugs that come along the way.  All weapons can be found naturally, as well as dropping from Weapon Crates, and being sold by the [Merchant](https://github.com/HDest-Community/merchant). 

## Weapons
---

### Blackhawk
---
- CVars are:
	- `bh_invertscroll [true/false]`: Inverts bolt scrolling keys. Client-side CVar.
- Loadout codes:
	- `bhk`: Crossbow.
	- `bbr`: Regular bolt. Good armor penetration, unless it's ceramic armor, in which case better switch to something else.
	- `bbi`: Incendiary bolt. Explodes on impact with a hard surface and sets everything on fire. On impact with a solid target, deal lots of explosive damage and heavily ignite it.
	- `bbe`: Electric bolt. An EMP blast. Specialized payload that will permanently nullify all shields within range. Deals moderate amount of damage to unshielded targets.
	- `bbn`: Nuclear bolt. To whom it may concern.
- Configuration codes are:
	- `semiauto`: Automatically pull the string back after firing. Only works when cycling to the next bolt. Reloading on a relaxed string requires manual pulling for the first time.
	- `bolts:<codes>`: start with these specific bolts. Example: `bolts:rneir` will start you with Regular, Nuclear, Electric, Incendiary, Regular, in that order.
- The crossbow does not have sights. That is intentional. Turns out most crossbows don't have factory sights. This one is one of those. Sorry, the AceCorp budget got spent on nukes. One day I might add sights if the lack of any starts to bother me too much. For now that's off the table.

### Blackjack
---
- The loadout codes are `bjk`, `bm3`, and `bms` for weapon, 355 mag, and shell mag, respectively.
- CVars are:
	- `bj_invert [true/false]`: Inverts the primary/secondary fire modes and reload keys. Client-side CVar.

### Gungnir
---
- The loadout code is `gnr`.
- Configuration codes are:
	- `accel`: Accelerator - increases charge speed.
	- `cap`: Capacitor - gives an extra shot.
	- `proc`: Processor - makes battery consumption more efficient.

### Hammerhead
---
- The loadout code is `hhd`.
- There are 3 firing modes: 1 battery, 2 batteries, and full barrage. Lowest setting is for low-heat sustained fire. Highest setting is for maximizing damage at the expense of much faster heat build-up and battery drain rate.
- Batteries are cycled after each shot to deplete them evenly.
- If the heat bar turns orange, vent the gun or you will get set on fire.

### Jackdaw
---
- The loadout codes is `jdw`.
- Configuration codes are:
	- `rapid`: Locks the weapon to hyperburst RoF, except it's full-auto.
- The weapon feeds ammo directly from any HDBackpack item (Backpacks, Ammo Pouches, Dimensional Storage Devices, etc.)

### Majestic
---
- The loadout codes are `maj` and `mjm` for the weapon and mag respectively.
- Configuration codes are:
	- `accel`: Accelerator. Makes the gun charge a little faster.
#### Mechanics
- The weapon requires both a battery and a drum to fire a charged shot. Otherwise only a drum is required.
- Holding primary fire charges a shot. The higher the charge, the higher the projectile's velocity and explosion damage. Charging is not necessary and the gun can be quickfired in a pinch.

### RDL-N3 'Redline' Thermal Lance
---
- The loadout code is `rdl`.
- Configuration codes are:
	- `lockon`: Lock-on capabilities.
#### Mechanics
- Firing the weapon generates heat. Firing while overheated does 1.5 damage but takes 2 battery charges per shot. If you deplete the battery on an odd charge (basically 1) with an overheated shot, it will overload the battery and it will explode. It's harmless, but you will lose the battery.
- Holding fire turns on lock-on mode after a few milliseconds (if available). Hovering over an enemy within 50m will mark them. Letting go of the trigger will automatically fire in their direction. The number of enemies you can lock onto depends on the number of charges. There is an angle limit and you cannot do 360 noscopes with this.
- The autoaiming feature isn't too smart. Sometimes it will fail to fire at enemies that are behind a low wall. Use freefire against those.

### Scorpion
---
- The loadout code is `scr`.

### Soul Cube
---
- Loadout code is `slc`.
- Configuration codes are:
	- `frag`: Starting frag.
	- `level`: Starting level.
- Type `SC_ReturnToOwner` in the console to force the cube to return to you if you are within sight.
#### How it works
- Double-tap Use to pick up a floating cube.
- The cube passively collects frag only while it's in your inventory.
- It needs at least 5 frag to become active.
- Max frag capacity is 20 + 5 for each extra level.
- Max level is 4. Cube starts at level 0.
- Level is increased by gaining experience. Experience is gained by using the cube.
- Each level increases damage and rate of fire, and also the effectiveness of certain things.
- Frag collection frequency increases with level. Range does not.
- Attacks up to 3 enemies at once, dealing a flat amount of damage and ignoring shields/armor. Each attack costs 1 frag.
- Frag can be expended manually through the various modes the cube has.
- Some effects are amplified if the cube is overcharged.
#### While it is out, it has these passive effects:
- Helps put out fire faster.
- Helps with incap.
- Compels pained archviles to show up sooner.

### Viper
---
- The loadout codes are `vpr`, `vpm`, and `50r` for weapon, mag, and rounds, respectively.
- Configuration codes are:
	- `hframe`: Heavier frame. Gun weighs more but has less recoil.
	- `extended`: Extended barrel. Higher projectile velocity but heavier gun.

### Wyvern
---
- The loadout code is `wyv`.
- Configuration codes are:
	- `auto`: Autoloader. Makes reloading from side saddles a bit faster.

## Items
---

### Booster Jets
---
- Use Item: Turn on.
- Use + Use Item: If turned off, enable charging.
- Jump: If turned on, gain boost to current momentum.
- Sprint + Jump: Same as above but trade vertical velocity boost for horizontal.

#### Notes
- Cost scales with how encumbered you are.
- You can and probably will incap yourself with it so watch out.
- Booster jets are found naturally in the world. They are also sold by the [Merchant](https://gitlab.com/accensi/hd-addons/merchant) if you have that loaded.
- Loadout code is `bsj`.

### Deployable Barricade
---
- Use Item: Drops barricade and deploys it.
- Spam Use on the barricade to make it collapse back into a pickup.

#### Notes
- The loadout code for the barricade is `dab`.
- The barricade has 5000 health. Mind the damage. Can only be repaired with Arcanum.

### Dimensional Storage Device
---
- Loadout code is `dsd`.
- Configuration codes are:
	- `cap`: overrides the starting storage capacity.
- Some HDPickup items cannot be inserted into the backpack. That is intentional as there is no way to save some variables, which results in various exploits caused by packing and unpacking an item.
- Each player gets their own storage.
- Order of items is First-In-First-Out. New items are put at the end of the list.
- Each operation costs 2 battery charges. Device will be useless without batteries.
- The device itself does not hold any items. Meaning two different devices will point to the same storage.
- To expand your storage, hold Zoom and Firemode when picking up a DSD to consume the item and gain extra storage

### Field Assembly Kit
---
- FAKs can only be found in backpacks. 
- Loadout code is `fak`.
- There is a chance to gain an assembly core from downgrading weapons.
- Finding all secrets and killing 90% of all monsters in the level will reward you with an assembly core upon exiting the level.
- Cores can also drop from Archviles sometimes and much more often from bosses.

#### Vanilla Upgrades
Revolver:
- Speedloader: if the cylinder is empty, tapping reload fills it up in one go. Works with 9mm as well.

Hunter:
- Feeder: automatically loads the tube with shells from the side saddles.

Slayer:
- Autoloader: faster reloading.

ZM66:
- Heat Exhaust: prevent cooking off.
- Dejammer: Space age piece of shit. Prevents jamming.

Rocket Launcher:
- Rapid Fire: spammable rocket mode.
- Recoil Dampener: reduces recoil for rocket mode.
- No Safety: removes the minimum distance for rockets and grenades. Allows you to blast stuff at point blank range.

Blooper:
- No Safety: same as above.

Liberator:
- Brass Catcher: catches brass so you don't have to.

Thunderbuster:
- Chiller: allows continuous plasma mode fire.
- Stabilizer: makes plasma mode battery consumption slightly more effective.
- Amplifier: bust faster.

BFG:
- Accelerator: charge batteries faster (only when used on person) and shoot sooner.

Mag Manager:
- Speedloader: no time to explain, must load mags at turbo speed.

### Hacked Reloader
---
- Works exactly the same as the vanilla reloader. All it does is it chucks rounds faster and rounds have a higher chance of exploding. It still does 7 rounds per throw.

#### Notes
- Hacked reloaders can only be found in backpacks. They are also sold by the [Merchant](https://github.com/HDest-Community/Merchant) if you have that loaded.
- Loadout code is `7hr`.

### Ladder Launcher
---
- The loadout code is `llc`.

### Magazine Reloader
---
- Magazine reloaders can only be found in backpacks. They are also sold by the [Merchant](https://github.com/HDest-Community/Merchant) if you have that loaded.
- Loadout code is `mrl`.

### Personal Shield Generator
---
- The Personal Shield Generator can be found both in the wild and in backpacks.
- Loadout code is `psh`.
- Configuration codes are:
	- `points`: Start with this many upgrade points.
	- `elem`: Shield fully absorbs any elemental projectiles and generated heat, at the cost of dealing higher hard flux damage. This upgrade only works for heat in 360 degrees mode as fire is omnidirectional.
	- `medical`: Shield will help close wounds, regenerate health, and heal burns.
	- `shock`: Shield will damage latched babuins and eventually kill them.
	- `cloak`: Bravo six, going dark. Cloaks you if below 25% flux. Side effect is that it hides your sights. Disabling the shield also disables cloaking.
- Use + Use Item can be used to quickly toggle the shield on and off without having to bring up the interface.

#### Mechanics
- The generator needs at least one battery with 1 charge in it.
- Taking damage generates soft flux. A fraction of that is hard flux. The latter cannot be vented without disabling the shield. Soft flux cannot go under the hard flux amount.
- Taking *too much* damage will overload the shield, causing the following effects:
	- Battery charge will be partially depleted. This may result in battery loss if the initial charge was low to begin with.
	- Disable the generator and prevent reactivation until all flux is vented.
	- Set you on fire a little.
- The generator has two modes: full-coverage and frontal. The former makes you virtually impervious to attacks, but shields will take 100% damage, meaning faster flux build-up. Frontal shield makes you open to flanking, but damage to shields is greatly reduced.
- The generator is designed to work with three full batteries. The more charges the batteries are missing, the bigger the penalties to flux dissipation rate.
- Shields block all damage completely.
- Hold Firemode with your PSG selected when picking up another generator to consume the item and gain upgrade points. This is a passive bonus.

### Rearview Mirror
---
- Rearview mirrors can only be found in backpacks. They are also sold by the [Merchant](https://gitlab.com/accensi/hd-addons/merchant) if you have that loaded.
- Loadout code is `rvm`.
- Using the item toggles it on and off. Do this if you notice significant performance drops as it has to render the scene once for each mirror.
- Use + Use Item switches shoulder mount. Only works if you have one mirror for obvious reasons.
- Up to two mirrors can be utilized, one for each shoulder.

### Roomba
---
- Use Item: Drop roomba to collect brass or materials for the [Universal Reloader](https://github.com/HDest-Community/Universal-Reloader).
- Sprint + Use Item: Same as above but yeet it.
- To pick it up, double-tap Use on it.

#### Notes
- Roombas can only be found in backpacks. They are also sold by the [Merchant](https://github.com/HDest-Community/Merchant) if you have that loaded.
- The loadout code for the roomba is `rmb`.

### Secret Finder
---
- The item can spawn either in backpacks or be found randomly in the wild in place of computer area maps.
- Loadout code is `fdr`.
- The higher the range, the faster battery is drained.

### Super Stimpack
- Loadout code is `sst`.
- You can fumble for the stim while incapped if you mash the dedicated key. See the controls.
- Super stims reduce the incap timer, allowing you to get up sooner.
- Having blues doubles the effectiveness of the stim at the cost of some blues and the drugs being absorbed twice as fast.
- All healing effects scale with how much of the drug you have left in your system.
- When the effect runs out, you will suffer a short and mild comedown.

### Supply Beacon
---
- The beacons can only be found in backpacks.
- Loadout code is `spb`.
- CVars are:
	- `sb_skin` (0-1): Changes what the supply pod looks like.
- You need at least 1 of any type as a "sample" to use with the beacon.

### Teleporter
---
- Teleporters can only be found in backpacks. They are also sold by the [Merchant](https://github.com/HDest-Community/Merchant) if you have that loaded.
- The loadout code for the teleporter is `ptp`.
- You can fumble for the teleporter while incapped if you mash the dedicated key. See the controls.
- Fire will instantly teleport you 20m from where you're aiming. Watch out for the velocity boost!
- Alt-fire will open a rift 2m in front of you for a minute. Pressing alt-fire again will teleport you to that rift.
- Teleportation will cause minor burns.

## Credits
---

Original Mod Credits are displayed below.
- Cryomundus, for porting original mods to HDest Community Organization, updating mods as needed, rechambering Viper into .50 AM.
- Undead Zeratul, for aggregating weapons into this pack, updating as needed, adding spawning handler & menus, fixing Wyvern.

### Blackhawk
---
Code:
- Accensus

Sprites:
- Weapon Sprites: Mor'ladim
  - Original Model: [Joshua McCarthy](https://www.artstation.com/artwork/X2Dyn)
- Bolts: Mor'ladim
- Bolt Bundles: Pillowblaster

Sounds:
- Firing and String Pull Sounds: [Navaro](https://gamebanana.com/sounds/21075)

### Blackjack
---
Code:
- Accensus

Sprites:
- Weapon model for pickup sprite: Accensus
- Actual pickup sprite: Mor'ladim.
- First person sprites: Icarus, Sonik.o.fan

Sounds:
- Mag In/Mag Out/Bolt Pull: https://gamebanana.com/sounds/download/32256
- Firing Sound: https://gamebanana.com/sounds/download/4857

### Gungnir
---
Code:
- Accensus

Sprites:
- Pickup sprite: Mor'ladim
  - Original Model: [Tim Kaminski](https://www.artstation.com/artwork/l5BXo)

Sounds:
- [Ribbon](https://gamebanana.com/sounds/31093)
- Charging Sounds: Bullet-Eye
- Locking Sounds: Russian Overkill

Name Idea:
- Yholl

Scope fixes:
- TooFewSecrets(TooFewSecrets#4217)

### Hammerhead
---
Code:
- Accensus

Sprites:
- First Person Sprites: Icarus, frankensprited from various sources
- Pickup Sprite: Pillowblaster

### Jackdaw
---
Code:
- Accensus

Sprites:
- Weapon Sprite: Sonik.O
- Original Model: [Samuel & Joshua McCarthy](https://www.artstation.com/artwork/GRwO4)
- Pickup sprite: Mor'ladim

Sounds:
- Fire Sound: LakeDown

- Reloading Sounds: [MSKyuuni](https://gamebanana.com/sounds/21690)

### Majestic
---
Code:
- Accensus

Sounds:
- Firing Sound: Bullet-Eye's Assassin Vulcan weapon.
- Charging Sounds: Bullet-Eye's Triple Wyvern.
- Magmacow
  - [Hammer](https://gamebanana.com/sounds/54036)
  - [Battery Reload](https://gamebanana.com/sounds/35140)
- Navaro
  - [Everything Else](https://gamebanana.com/sounds/19952)

Sprites:
- Mor'ladim
  - Original Model: [Ibrahim Aysan](https://www.artstation.com/artwork/3orQlD)0

### Redline
---
Code:
- Accensus

Sprites:
- Pillowblaster
  - Original Model: [CaptainToggle](https://sketchfab.com/3d-models/nemesis-sniper-rifle-c68434f1190f48e1902be623971b4031)

Sounds:
- Fallout (Interplay/Bethesda)
  - Fire/Bolt Sounds: [Magmacow](https://gamebanana.com/sounds/33348)
  - Reloading Sounds: [Navaro](https://gamebanana.com/sounds/35140)

Feedback:
- Massive thanks to Eric and Daerik for their feedback on the bolt-action iterations.

### Scorpion
---
Code:
- Accensus

Sprites:
- Accensus

Sounds:
- Fire, Bolt Sounds: [KillerExe_01, NightmareMutant](https://gamebanana.com/sounds/18650)

### Viper
---
Code:
- Accensus

Sprites:
- Mor'ladim, iamcarrotmaster, DoomNukem, iamcarrotmaster
  - Taken from Project Brutality

Sounds:
- Firing sound by [RUS[PROTOTYPE]](https://gamebanana.com/sounds/18109), edited by a1337spy
- Rest of the sounds by various sources, compiled by [Magmacow](https://gamebanana.com/sounds/31009)

### Wyvern
---
Code:
- Accensus

Sprites:
- PillowBlaster, DoomNukem

Sounds:
- Firing Sound: Guncaster Team, most likely Marisa Kirisame
- Reload-related sounds are by magmacow.

### Booster Jets
---
Code:
- Accensus

### Dimensional Storage Device
---
Code:
- Accensus

Name idea:
- D2Icarus

Sprites:
- Teleport fog is from Doom (no shit) by id Software. Recolor by Accensus.
- Pickup sprite taken from Trailblazer. Probably done by PillowerBlaster or DoomNukem. Or both.

### Field Assembly Kit
---
Code:
- Accensus

Sprites:
- Mor'ladim for the assembly cores. Took them from Bullet-Eye.

Bugtesting:
- Icarus

### Ladder Launcher
---
Code:
- Accensus

Sprites:
- Combine_Kegan, based on work by HyperUltra64

### Magazine Reloader
---
Code:
- Accensus

Sprites:
- Reloader sprite by Mor'ladim.

Sounds:
- Bell ding is from Blood 2 (Monolith).

### Personal Shield Generator
---
Sprites:
- Conveniently taken from Russian Overkill.
- Extra shield graphics by PillowBlaster.

Sounds:
- UI sounds conveniently taken from Bullet-Eye.
- Shield break/restore (The Halo Vaccinator): https://gamebanana.com/sounds/40287
- Flux vent sound by Fractal Softworks (Starsector).

Idea:
- LSWraith
- Fractal Softworks for coming up with the flux idea in the first place. I took it from Starsector.

### Rearview Mirror
---
Sprites:
- Mor'ladim

### Roomba
---
Code:
- Accensus

Sprites:
- Hege Cactus for the roomba.

Sounds:
- Vacuum sound taken from Extreme Weapon Pack

### Super Stimpack
---
Code:
- Accensus

Sprites:
- Super stim: id Software
- Injector: ???

All edits by Accensus.

### Hacked Reloader
---
Code:
- Accensus

Sprites:
- Taken from HD, originally by BloodyAcid. Recolored by Accensus.

Base Idea:
- HexaDoken