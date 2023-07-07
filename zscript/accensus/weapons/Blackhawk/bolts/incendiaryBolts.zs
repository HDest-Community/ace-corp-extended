class HDBlackhawkBoltIncendiary : HDBlackhawkBolt
{
	Default
	{
		Tag "$TAG_BLACKHAWKBOLT_I";
		Inventory.Icon "BHBIB0";
		HDPickup.Bulk 5.0;
		HDPickup.RefId HDLD_BLACKHAWKBOLT_I;
	}

	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKHAWKBOLT_I_PREFIX")..Stringtable.localize("$TAG_BLACKHAWKBOLT_I")..Stringtable.localize("$PICKUP_BLACKHAWKBOLT_I_SUFFIX");
	}

	States
	{
		Spawn:
			BHBL B 0;
			Goto Super::Spawn;
	}
}

// [Ace] This also acts as an incendiary bolt. It's less kinetic and more chemical.
class HDBlackhawkProjectileIncendiary : HDBlackhawkProjectile
{
	override void OnBoltHit(Line hitLine, Actor hitActor)
	{
		if (hitActor)
		{
			int dmg = random(50, 100);
			double ang = AbsAngle(angle, AngleTo(hitActor));
			if (ang < 20)
			{
				dmg += random(40, 60);
			}
			else if (ang < 40)
			{
				dmg += random(20, 30);
			}
			hitActor.DamageMobj(self, target, dmg, 'Piercing');
		}
		else
		{
			DoorDestroyer.DestroyDoor(self, maxdepth: 4);
		}

		if (!inthesky)
		{
			// [Ace] Absolutely fuck singular targets.
			if (hitActor)
			{
				A_HDBlast(fragradius: HDCONST_ONEMETRE * 2, fragtype: "HDB_frag", immolateradius: random(24, 64), immolateamount: 3000);
			}
			else
			{
				A_HDBlast(fragradius: HDCONST_ONEMETRE * 10, immolateradius: random(256, 384), immolateamount: random(1000, 2000), immolatechance: 90);
			}
			A_SprayDecal("BoltScorch", 16);
			Actor xpl = Spawn("Gyrosploder", pos - (0, 0, 1), ALLOW_REPLACE);
			xpl.target = target;
			xpl.master = master;
			xpl.stamina = 3;
		}
		else
		{
			DistantNoise.Make(self, "world/rocketfar");
		}
	}

	Default
	{
		Mass 100;
		Speed HDCONST_MPSTODUPT * 150;
		Obituary "$OB_BLACKHAWKBOLT_I";
		+BRIGHT
	}

	States
	{
		Spawn:
			BHBP B 0;
			Goto Super::Spawn;
	}
}