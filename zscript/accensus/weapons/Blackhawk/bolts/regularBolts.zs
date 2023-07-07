class HDBlackhawkBoltRegular : HDBlackhawkBolt
{
	Default
	{
		Tag "$TAG_BLACKHAWKBOLT";
		Inventory.Icon "BHBIA0";
		HDPickup.Bulk 2.0;
		HDPickup.RefId HDLD_BLACKHAWKBOLT;
	}

	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKHAWKBOLT_PREFIX")..Stringtable.localize("$TAG_BLACKHAWKBOLT")..Stringtable.localize("$PICKUP_BLACKHAWKBOLT_SUFFIX");
	}

	States
	{
		Spawn:
			BHBL A 0;
			Goto Super::Spawn;
	}
}

class HDBlackhawkProjectileRegular : HDBlackhawkProjectile
{
	override void OnBoltHit(Line hitLine, Actor hitActor)
	{
		A_SprayDecal("BoltScorchRegular", 16);

		if (hitLine)
		{
			Actor.Spawn("BulletPuffSmall", pos);
		}
		
		if (!hitActor)
		{
			return;
		}

		// [Ace] Don't pierce ceramic armor. Not always at least.
		let arm = HDArmourWorn(hitActor.FindInventory('HDArmourWorn'));

		bool ignoreArmor = false;
		let mob = HDMobBase(hitActor);
		if (mob && !mob.bHasHelmet && pos.z - mob.pos.z >= mob.height * 0.8)
		{
			ignoreArmor = true;
		}

		if (ignoreArmor || !arm || !arm.Mega || arm.Mega && random(0, HDCONST_BATTLEARMOUR) <= arm.Durability << 1)
		{
			int dmg = random(50, 100);
			double ang = AbsAngle(angle, AngleTo(hitActor));
			if (ang < 20)
			{
				dmg += random(60, 120);
			}
			else if (ang < 40)
			{
				dmg += random(30, 60);
			}
			hitActor.DamageMobj(self, target, dmg, 'Piercing');
		}
	}

	Default
	{
		Mass 40;
		Speed HDCONST_MPSTODUPT * 180;
		Obituary "$OB_BLACKHAWKBOLT";
		+AMBUSH
		+NOEXTREMEDEATH
	}

	States
	{
		Spawn:
			BHBP A 0;
			Goto Super::Spawn;
	}
}