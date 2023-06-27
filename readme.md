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
