class HDBlackhawkBoltElectric : HDBlackhawkBolt
{
	Default
	{
		Tag "Electric bolt";
		Inventory.PickupMessage "Picked up an electric bolt.";
		Inventory.Icon "BHBIC0";
		HDPickup.Bulk 3.5;
		HDPickup.RefId "bbe";
	}

	States
	{
		Spawn:
			BHBL C 0;
			Goto Super::Spawn;
	}
}

class HDBlackhawkProjectileElectric : HDBlackhawkProjectile
{
	override void OnBoltHit(Line hitLine, Actor hitActor)
	{
		Spawn("HDExplosion", pos + (frandom(-4, 4), frandom(-4, 4), frandom(-4, 4)), ALLOW_REPLACE);
		Spawn("HDSmoke", pos + (frandom(-4, 4), frandom(-4, 4), frandom(-4, 4)), ALLOW_REPLACE);

		for (int i = 0; i < 10; ++i)
		{
			ArcZap(self, rad: EffectRange * 0.15);
		}

		A_HDBlast(256, random(1, 256), 128, "electrical");

		Actor flash = Spawn("BeamSpotFlash", pos, ALLOW_REPLACE);

		Actor thunder = Spawn("LingeringThunder", pos, ALLOW_REPLACE);
		thunder.target = target;
		thunder.stamina = 64;

		A_SprayDecal("BoltScorch", 14);
		DistantNoise.Make(self, "world/tbfar");
		DistantNoise.Make(self, "world/tbfar2", 2.0);
		DistantQuaker.Quake(self, 3, 35, 768);

		int zapsLeft = 8;
		BlockThingsIterator it = BlockThingsIterator.Create(self, EffectRange);
		while (it.Next() && zapsLeft > 0)
		{
			double distFac = it.thing.Distance3D(self) / EffectRange;
			if (distFac > 1.0 || !it.thing.bISMONSTER && !it.thing.player)
			{
				continue;
			}

			for (int i = 0; i < 2; ++i)
			{
				HDActor.ZapArc(self, it.thing, dev: 0.6);
			}

			zapsLeft--;
			it.thing.DamageMobj(self, target, random(1, int(32 + 256 * (1.0 - distFac))), 'Electrical');
			if (!it.thing) // [Ace] In case it gets destroyed by the DamageMobj call.
			{
				continue;
			}

			for (Inventory next = it.thing.Inv; next != null; next = next.Inv)
			{
				if (next.GetClassName() == 'HDPersonalShieldGenerator')
				{
					AceCoreHandler.CreateRequest('InflictEmpDamage', self, next, "500");
				}
				else if (next is 'HDMagicShield')
				{
					HDMagicShield.Deplete(it.thing, 20000, HDMagicShield(next), true);
				}
			}
		}
	}

	const EffectRange = HDCONST_ONEMETRE * 10;

	Default
	{
		Mass 60;
		Speed HDCONST_MPSTODUPT * 150;
		Obituary "%k helped %o make a shocking discovery - electricity can kill.";
		+BRIGHT
	}

	States
	{
		Spawn:
			BHBP C 0;
			Goto Super::Spawn;
	}
}