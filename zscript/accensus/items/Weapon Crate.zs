class HDWeaponCrate : HDUPK
{
	static const class<HDWeapon> Blacklist[] =
	{
		"BossRifle",
		"Brontornis",
		"Lumberjack",
		"HDPistol",
		"HDRL",
		"Blooper",
		"HDSMG",
		"ZM66AssaultRifle",
		"BFG9K",
		"Hunter",
		"Slayer",
		"Thunderbuster",
		"LiberatorRifle",
		"HDRevolver",
		"Vulcanette"
	};

	private bool IsBlacklisted(class<HDWeapon> wpn)
	{
		for (int i = 0; i < Blacklist.Size(); ++i)
		{
			if (Blacklist[i] == wpn)
			{
				return true;
			}
		}

		return false;
	}

	override void Tick()
	{
		UseTimer--;

		roll *= 0.6;

		Super.Tick();
	}

	override bool OnGrab(Actor other)
	{
		if (Distance3D(picktarget) <= 50) {
			if (UseTimer <= 0) {
				UseTimer = 10;
				vel.z = 2;
				A_SetRoll(frandompick(-5, 5), SPF_INTERPOLATE);
			} else {
				SetStateLabel("DropGoods");
			}
		}

		return false;
	}

	override void A_HDUPKGive() { }

	int UseTimer;

	Default
	{
		+ROLLSPRITE
		+ROLLCENTER
		+SHOOTABLE
		+NOBLOOD
		+NOPAIN
		Scale 0.375;
		Height 8;
		Radius 12;
		Health 100;
		Mass 120;
	}

	States
	{
		Spawn:
			WPCR T -1;
			Stop;
		DropGoods:
			TNT1 A 1
			{
				Array<class<HDWeapon> > WeaponsToDrop;
				for (int i = 0; i < AllActorClasses.Size(); ++i)
				{
					let CurrWeapon =  HDWeapon(GetDefaultByType(AllActorClasses[i]));
					if (CurrWeapon && !CurrWeapon.bWIMPY_WEAPON && !CurrWeapon.bCHEATNOTWEAPON && !CurrWeapon.bDONTNULL && !IsBlacklisted(CurrWeapon.GetClass()) && CurrWeapon.WeaponBulk() > 0 && !CurrWeapon.bINVBAR && CurrWeapon.Refid != "")
					{
						WeaponsToDrop.Push(CurrWeapon.GetClass());
					}
				}

				if (WeaponsToDrop.Size() > 0)
				{
					class<HDWeapon> PickedWeapon = WeaponsToDrop[random(0, WeaponsToDrop.Size() - 1)];
					A_SpawnItemEx(PickedWeapon, 0, 0, 0, frandom(0.5, 1.0), 0, frandom(3.0, 6.0), random(0, 359), SXF_NOCHECKPOSITION);
				}
			}
			Stop;
		Death:
			TNT1 A 1
			{
				Spawn("HDExplosion", pos, ALLOW_REPLACE);
				A_Explode(64, 64);
			}
			Stop;
	}
}
