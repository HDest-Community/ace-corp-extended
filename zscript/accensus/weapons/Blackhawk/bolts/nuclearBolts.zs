class HDBlackhawkBoltNuclear : HDBlackhawkBolt
{
	Default
	{
		Tag "$TAG_BLACKHAWKBOLT_N";
		Inventory.Icon "BHBID0";
		HDPickup.Bulk 12.0;
		HDPickup.RefId HDLD_BLACKHAWKBOLT_N;
		+HDPICKUP.NORANDOMBACKPACKSPAWN
	}

	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKHAWKBOLT_N_PREFIX")..Stringtable.localize("$TAG_BLACKHAWKBOLT_N")..Stringtable.localize("$PICKUP_BLACKHAWKBOLT_N_SUFFIX");
	}

	States
	{
		Spawn:
			BHBL D 0;
			Goto Super::Spawn;
	}
}

class HDBlackhawkProjectileNuclear : HDBlackhawkProjectile
{
	override void OnBoltHit(Line ln, Actor a)
	{
		double scale = 0.5;

		A_HDBlast(pushradius: HDCONST_ONEMETRE * 60 * scale, pushamount: 10000 * scale, fullpushradius: HDCONST_ONEMETRE * 20 * scale);

		DoorDestroyer.DestroyDoor(self, 512, 128, dedicated: true); 

		// [Ace] Anything inside this radius is instantly turned into dust.
		int coreDist = int(HDCONST_ONEMETRE * 10 * scale);
		A_Explode(int(30000 * scale), coreDist, XF_HURTSOURCE, true, coreDist, 0, 0, null, 'Thermal');

		// [Ace] Middle blast. Relatively powerful.
		int blastDist = int(HDCONST_ONEMETRE * 25 * scale);
		A_Explode(int(3000 * scale), blastDist, XF_HURTSOURCE, true, 0, 0, 0, null, 'Thermal');

		// [Ace] Falloff. Low damage but high distance.
		int falloffDist = int(HDCONST_ONEMETRE * 50 * scale);
		A_Explode(int(200 * scale), falloffDist, XF_HURTSOURCE, true, 0, 0, 0, null, 'Thermal');

		target.A_SetBlend("FF4400", 0.8, 70);
		DistantNoise.Make(self, "Blackhawk/NukeExplosion");
		DistantQuaker.Quake(self, 8, 105, HDCONST_ONEMETRE * 200 * scale);

		// [Ace] Can't into maths? Hardcode it!
		// But seriously, I spent like an hour at least fucking with Desmos to try to figure out some sine bullshit for this. I got nothing. Doesn't really matter anyway.
		static const int partCols[] =
		{
			0xFF9200, 0xFF9000, 0xFF8800, 0xFF8600, 0xFF8400, 0xFF8200, 0xFF8000,
			0xFF7800, 0xFF7600, 0xFF7400, 0xFF7200, 0xFF7000, 0xFF6800, 0xFF6600, 0xFF6400, 0xFF6200, 0xFF5800, 0xFF5500, 0xFF5400, 0xFF5300, 0xFF5200,
			0xFF5200, 0xFF5300, 0xFF5400, 0xFF5500, 0xFF5500, 0xFF5500, 0xFF5500, 0xFF5500
		};
		static const double widths[] =
		{
			208, 192, 176, 160, 144, 128, 112,
			96, 86, 77, 69, 63, 58, 54, 51, 49, 47, 54, 58, 63, 69,
			96, 128, 160, 180, 160, 128, 96, 64
		};
		static const double heights[]=
		{
			0, 2, 4, 8, 11, 15, 23,
			33, 43, 53, 63, 73, 83, 93, 103, 113, 123, 133, 143, 153, 163,
			173, 183, 193, 203, 213, 223, 233, 236
		};

		int arrSize = partCols.Size();
		for (int i = 0; i < arrSize; ++i)
		{
			double partSize = 80;
			if (i >= arrSize - 6)
			{
				partSize += 32 * scale;
			}

			if (i == arrSize - 3)
			{
				for (int ang = 0; ang < 360; ang += 1)
				{
					A_SpawnParticle(0xFF9800, SPF_RELATIVE | SPF_FULLBRIGHT, 150 - 70, 192 * scale, ang, widths[i] * 1.2 * scale, 0, heights[i] * scale, 16, accelx: -0.10 * scale, sizestep: 2.0 * scale);
				}
			}
			if (i == arrSize / 2)
			{
				for (int ang = 0; ang < 360; ang += 1)
				{
					A_SpawnParticle(0xFF9800, SPF_RELATIVE | SPF_FULLBRIGHT, 140 - 35, 64 * scale, ang, widths[i] * 0.8 * scale, 0, heights[i] * scale, 8, accelx: -0.05 * scale, sizestep: 0.5 * scale);
				}
			}

			for (int ang = 0; ang < 360; ang += 12)
			{
				A_SpawnParticle(partCols[i], SPF_RELATIVE | SPF_FULLBRIGHT, 110 - 2 * (arrSize - i), partSize * scale, ang, widths[i] * scale, 0, heights[i] * scale, -0.5 * scale, 0, 0.25 * scale, sizestep: 1.0 * scale);
			}
		}

		int spearCount = random(6, 15);
		double angleDiv = 360 / spearCount;
		for (int i = 0; i < spearCount; ++i)
		{
			double smokePitch = frandom(0, 45.0);
			double smokeVel = frandom(15, 25) * scale;
			double smokeHeight = heights[arrSize - 1];

			Actor a; bool success;
			[success, a] = A_SpawnItemEx("HDBlackhawkNukeSmokeSpear", 192 * scale, 0, frandom(smokeHeight * 0.2, smokeHeight * 0.7) * scale, smokeVel * cos(smokePitch), 0, smokeVel * sin(smokePitch), angleDiv * i + random(-15, 15), SXF_NOCHECKPOSITION);
			if (success)
			{
				a.scale *= scale;
			}
		}

		for (int i = 0; i < 200; ++i)
		{
			Actor a; bool success;
			[success, a] = A_SpawnItemEx("HDBlackhawkNukeGroundSmoke", frandom(64, 512) * scale, 0, 0, frandom(20, 50) * scale, 0, 0, random(0, 359), SXF_NOCHECKPOSITION);
			if (success)
			{
				a.scale *= scale;
			}
		}
	}

	Default
	{
		Mass 150;
		Speed HDCONST_MPSTODUPT * 100;
		Obituary "$OB_BLACKHAWKBOLT_N";
		+NODAMAGETHRUST
		+BRIGHT
	}

	States
	{
		Spawn:
			BHBP D 0;
			Goto Super::Spawn;
	}
}

class HDBlackhawkNukeSmokeSpear : Actor
{
	override void BeginPlay()
	{
		ReactionTime = int(ReactionTime * frandom(0.5, 1.0));
		Super.BeginPlay();
	}

	Default
	{
		+NOINTERACTION
		Gravity 0.05;
		ReactionTime 70;
	}

	States
	{
		Spawn:
			TNT1 A 1
			{
				if (!level.IsPointInLevel(pos) || --ReactionTime == 0)
				{
					Destroy();
					return;
				}

				vel *= 0.98;
				vel.z -= 1.0 * Gravity;

				Actor a = Spawn('HDBlackhawkNukeSpearSmoke', pos);
				a.scale *= scale.x;
			}
			Loop;
	}
}

class HDBlackhawkNukeSpearSmoke : ACESmokeBase
{
	Default
	{
		ACESmokeBase.FadeSpeed 0.00475, 0.005;
		Renderstyle "Shaded";
		StencilColor "FFAA11";
		Scale 0.1;
	}
}

class HDBlackhawkNukeGroundSmoke : ACESmokeBase
{
	override void BeginPlay()
	{
		Super.BeginPlay();
		frame = 11;
	}

	Default
	{
		ACESmokeBase.FadeSpeed 0.002, 0.003;
		Scale 0.7;
	}
}