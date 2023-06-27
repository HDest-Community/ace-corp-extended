# Ace Corps, Extended

_Requires [BulletLib - Recasted](https://github.com/HDest-Community/HDBulletLib-Recasted) and [AceCoreLib](https://github.com/HDest-Community/AceCoreLib), by the HDest Community._

This mod aims to maintain and improve Accensus' Arsenal, by updating them to the latest HDest main, as well as tweaking/fixing any bugs that come along the way.  All weapons can be found naturally, as well as dropping from [Weapon Crates](https://github.com/HDest-Community/weapon-crate) and being sold by the [Merchant](https://github.com/HDest-Community/merchant). 

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
