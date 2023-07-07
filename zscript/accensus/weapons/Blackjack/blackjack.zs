class HDBlackjack : HDWeapon
{
	enum BlackjackFlags
	{
		BJF_JustUnload = 1
	}

	enum BlackjackProperties
	{
		BJProp_Flags,
		BJProp_ChamberPrimary,
		BJProp_MagPrimary,
		BJProp_ChamberSecondary,
		BJProp_MagSecondary,
		BJProp_LoadType
	}

	override void PostBeginPlay()
	{
		weaponspecial = 1337; // [Ace] UaS sling compatibility.

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (InvertFire && !owner)
		{
			InvertFire = null;
		}
		if (!InvertFire && owner)
		{
			InvertFire = CVar.GetCVar('bj_invert', owner.player);
		}
		Super.Tick();
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass()
	{
		double mass355 = WeaponStatus[BJProp_MagPrimary] > -1 ? 0.02 * WeaponStatus[BJProp_MagPrimary] : 0;
		double massShell = WeaponStatus[BJProp_MagSecondary] > -1 ? 0.03 * WeaponStatus[BJProp_MagSecondary] : 0;
		return 9.5 + mass355 + massShell;
	}
	override double WeaponBulk()
	{
		double BaseBulk = 115;
		int prim = WeaponStatus[BJProp_MagPrimary];
		int sec = WeaponStatus[BJProp_MagSecondary];
		if (prim >= 0)
		{
			BaseBulk += HDBlackjackMag355.EncMagLoaded + prim * ENC_355_LOADED;
		}
		if (sec >= 0)
		{
			BaseBulk += HDBlackjackMagShells.EncMagLoaded + sec * ENC_SHELLLOADED;
		}
		return BaseBulk;
	}
	override string, double GetPickupSprite()
	{
		string PrimMagFrame = WeaponStatus[BJProp_MagPrimary] == -1 ? "E" : "F";
		string SecMagFrame = WeaponStatus[BJProp_MagSecondary] == -1 ? "E" : "F";
		return "BJ"..PrimMagFrame..SecMagFrame.."A0", 1.0;
	}
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[BJProp_ChamberPrimary] = 2;
		WeaponStatus[BJProp_MagPrimary] = HDBlackjackMag355.MagCapacity;
		WeaponStatus[BJProp_ChamberSecondary] = 2;
		WeaponStatus[BJProp_MagSecondary] = HDBlackjackMagShells.MagCapacity;
	}

	override string GetHelpText()
	{
		string prim = InvertFire && InvertFire.GetBool() ? "shotgun" : "rifle";
		string sec = InvertFire && InvertFire.GetBool() ? "rifle" : "shotgun";

		return String.Format(WEPHELP_FIRE.. "  Shoot "..prim.."\n"
		..WEPHELP_ALTFIRE.. "  Shoot "..sec.."\n"
		..WEPHELP_RELOAD.."  Reload "..prim.." mag\n"
		..WEPHELP_ALTRELOAD.."  Reload "..sec.." mag\n"
		..WEPHELP_UNLOAD.. "  Unload "..prim.." mag\n"
		..WEPHELP_USE.."+"..WEPHELP_UNLOAD.. "  Unload "..sec.." mag\n"
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload "..prim.." chamber\n"
		..WEPHELP_USE.."+"..WEPHELP_ALTRELOAD.."  Reload "..sec.." chamber\n"
		.."("..WEPHELP_USE..")+"..WEPHELP_MAGMANAGER);
	}

	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKJACK_PREFIX")..Stringtable.localize("$TAG_BLACKJACK")..Stringtable.localize("$PICKUP_BLACKJACK_SUFFIX");
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			int NextPrimaryMag = sb.GetNextLoadMag(HDMagAmmo(hpl.FindInventory("HDBlackjackMag355")));
			if (NextPrimaryMag >= HDBlackjackMag355.MagCapacity)
			{
				sb.DrawImage("BJM3A0", (-46, -3),sb. DI_SCREEN_CENTER_BOTTOM, scale: (2.0, 2.0));
			}
			else if (NextPrimaryMag <= 0)
			{
				sb.DrawImage("BJM3B0", (-46, -3), sb.DI_SCREEN_CENTER_BOTTOM, alpha: NextPrimaryMag ? 0.6 : 1.0, scale: (2.0, 2.0));
			}
			else
			{
				sb.DrawBar("BJM3NORM", "BJM3GREY", NextPrimaryMag, HDBlackjackMag355.MagCapacity, (-46, -3), -1, sb.SHADER_VERT, sb.DI_SCREEN_CENTER_BOTTOM);
			}
			sb.DrawNum(hpl.CountInv("HDBlackjackMag355"), -43, -8, sb.DI_SCREEN_CENTER_BOTTOM);

			int NextSecondaryMag = sb.GetNextLoadMag(HDMagAmmo(hpl.FindInventory("HDBlackjackMagShells")));
			if (NextSecondaryMag >= HDBlackjackMagShells.MagCapacity)
			{
				sb.DrawImage("BJMSA0", (-60, -3),sb. DI_SCREEN_CENTER_BOTTOM, scale: (2.0, 2.0));
			}
			else if (NextSecondaryMag <= 0)
			{
				sb.DrawImage("BJMSB0", (-60, -3), sb.DI_SCREEN_CENTER_BOTTOM, alpha: NextSecondaryMag ? 0.6 : 1.0, scale: (2.0, 2.0));
			}
			else
			{
				sb.DrawBar("BJMSNORM", "BJMSGREY", NextSecondaryMag, HDBlackjackMagShells.MagCapacity, (-60, -3), -1, sb.SHADER_VERT, sb.DI_SCREEN_CENTER_BOTTOM);
			}
			sb.DrawNum(hpl.CountInv("HDBlackjackMagShells"), -57, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if (hdw.WeaponStatus[BJProp_MagPrimary] > 0)
		{
			sb.DrawWepNum(hdw.WeaponStatus[BJProp_MagPrimary], HDBlackjackMag355.MagCapacity, posy: -12);
		}
		if (hdw.WeaponStatus[BJProp_ChamberPrimary] == 2)
		{
			sb.DrawRect(-19, -16, 3, 1);
		}

		if (hdw.WeaponStatus[BJProp_MagSecondary] > 0)
		{
			sb.DrawWepNum(hdw.WeaponStatus[BJProp_MagSecondary], HDBlackjackMagShells.MagCapacity, posy: -4);
		}
		if (hdw.WeaponStatus[BJProp_ChamberSecondary] == 2)
		{
			sb.DrawRect(-24, -10, 5, 3);
			sb.DrawRect(-18, -10, 2, 3);
		}
		else if (hdw.WeaponStatus[BJProp_ChamberSecondary] == 1)
		{
			sb.DrawRect(-18, -10, 2, 3);
		}
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = Screen.GetClipRect();
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 12, sb.DI_SCREEN_CENTER);
		vector2 bob2 = bob * 2;
		bob2.y = clamp(bob2.y, -8, 8);
		sb.DrawImage("BJCKFRNT", bob2, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9, scale: (0.8, 0.6));
		sb.SetClipRect(cx, cy, cw, ch);
		sb.DrawImage("BJCKBACK", bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, scale: (1.0, 0.8));
	}

	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			double OldAngle = owner.angle;

			amt = clamp(amt, 1, 10);
			if (owner.CheckInventory("HDRevolverAmmo", 1))
			{
				owner.A_DropInventory("HDRevolverAmmo", amt * 15);
				owner.angle += 15;
			}
			else
			{
				owner.A_DropInventory("HDBlackjackMag355", amt);
				owner.angle += 15;
			}

			if (owner.CheckInventory("HDShellAmmo", 1))
			{
				owner.A_DropInventory("HDShellAmmo", amt * 15);
			}
			else
			{
				owner.A_DropInventory("HDBlackjackMagShells", amt);
			}

			owner.angle = OldAngle;
		}
	}

	private action void A_FirePrimary()
	{
		if (invoker.WeaponStatus[BJProp_ChamberPrimary] < 2)
		{
			invoker.WeaponStatus[BJProp_LoadType] = 1;
			SetWeaponState("ChamberManual");
			return;
		}
		else
		{
			SetWeaponState("RealFire");
			return;
		}
	}

	private action void A_FireSecondary()
	{
		if (invoker.WeaponStatus[BJProp_ChamberSecondary] < 2)
		{
			invoker.WeaponStatus[BJProp_LoadType] = 2;
			SetWeaponState("ChamberManual");
			return;
		}
		else
		{
			SetWeaponState("RealAltFire");
			return;
		}
	}

	private transient CVar InvertFire;

	Default
	{
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority 0.4;
		HDWeapon.BarrelSize 20, 2, 3;
		Scale 0.5;
		Tag "$TAG_BLACKJACK";
		HDWeapon.Refid HDLD_BLACKJACK;
	}

	States
	{
		RegisterSprites:
			BJFF A 0; BJFE A 0; BJEF A 0; BJEE A 0;

		Spawn:
			BJFF A 0 NoDelay
			{
				string PrimMagFrame = invoker.WeaponStatus[BJProp_MagPrimary] == -1 ? "E" : "F";
				string SecMagFrame = invoker.WeaponStatus[BJProp_MagSecondary] == -1 ? "E" : "F";
				sprite = GetSpriteIndex("BJ"..PrimMagFrame..SecMagFrame);
			}
		RealSpawn:
			#### A -1;
			Stop;
		Ready:
			BJKG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER3 | WRF_ALLOWUSER1 | WRF_ALLOWUSER4);
			Goto ReadyEnd;
		Select0:
			BJKG A 0;
			Goto Select0Big;
		Deselect0:
			BJKG A 0;
			Goto Deselect0Big;
		User3:
			BJKG A 0
			{
				bool invert = invoker.InvertFire.GetBool();
				bool sec = !invert && PressingUse() || invert && !PressingUse();
				A_MagManager(sec  ? "HDBlackjackMagShells" : "HDBlackjackMag355");
			}
			Goto Ready;

		Fire:
			BJKG A 1
			{
				if (invoker.InvertFire.GetBool())
				{
					A_FireSecondary();
				}
				else
				{
					A_FirePrimary();
				}
			}
			Goto Nope;
		RealFire:
			BJKF A 1 Bright
			{
				HDBulletActor.FireBullet(self, 'HDB_355', spread: 1.25, speedfactor: 1.15);
				A_AlertMonsters();
				invoker.WeaponStatus[BJProp_ChamberPrimary] = 1;
				A_StartSound("Blackjack/Fire", CHAN_WEAPON);
				A_ZoomRecoil(0.995);
				A_MuzzleClimb(-frandom(0.3, 0.35), -frandom(0.40, 0.5), -frandom(0.3, 0.35), -frandom(0.40, 0.5));
				A_Light1();
			}
			BJKG A 2 Offset(0, 36)
			{
				if (invoker.WeaponStatus[BJProp_ChamberPrimary] == 1)
				{
					A_EjectCasing("HDSpent355",frandom(-1,2),(6,-frandom(79, 81),frandom(6.0, 6.5)),(0,0,-2));
					//A_EjectCasing('HDSpent355', 6, -random(79, 81), frandom(6.0, 6.5));
					invoker.WeaponStatus[BJProp_ChamberPrimary] = 0;
				}

				if (invoker.WeaponStatus[BJProp_MagPrimary] <= 0)
				{
					SetWeaponState('Nope');
				}
				else
				{
					A_Light0();
					invoker.WeaponStatus[BJProp_ChamberPrimary] = 2;
					invoker.WeaponStatus[BJProp_MagPrimary]--;
				}
			}
			Goto Ready;

		AltFire:
			BJKG A 1
			{
				if (invoker.InvertFire.GetBool())
				{
					A_FirePrimary();
				}
				else
				{
					A_FireSecondary();
				}
			}
			Goto Nope;
		RealAltFire:
			BJKF B 1 Bright
			{
				Hunter.Fire(self, 3);
				A_AlertMonsters();
				invoker.WeaponStatus[BJProp_ChamberSecondary] = 1;
				A_StartSound("Blackjack/AltFire", CHAN_WEAPON);
				A_ZoomRecoil(0.995);
				A_MuzzleClimb(-frandom(1, 1.2), -frandom(1.5, 2.0), -frandom(1, 1.2), -frandom(1.5, 2.0));
				A_Light1();
			}
			BJKG A 1 Offset(0, 39)
			{
				if (invoker.WeaponStatus[BJProp_ChamberSecondary] == 1)
				{
					A_EjectCasing("HDSpentShell",frandom(-1,2),(11,-frandom(79, 81),frandom(6.0, 6.5)),(0,0,-2));
					//A_EjectCasing('HDSpentShell', 11, -random(79, 81), frandom(6.0, 6.5));
					invoker.WeaponStatus[BJProp_ChamberSecondary] = 0;
				}

				if (invoker.WeaponStatus[BJProp_MagSecondary] <= 0)
				{
					SetWeaponState('Nope');
				}
				else
				{
					A_Light0();
					invoker.WeaponStatus[BJProp_ChamberSecondary] = 2;
					invoker.WeaponStatus[BJProp_MagSecondary]--;
				}
			}
		AltHold:
			BJKG A 1;
			BJKG A 0 A_Refire();
			Goto Ready;

		Unload:
			BJKG A 0
			{
				bool invert = invoker.InvertFire.GetBool();
				bool sec = PressingUse() && !invert || !PressingUse() && invert;

				invoker.WeaponStatus[BJProp_Flags] |= BJF_JustUnload;
				invoker.WeaponStatus[BJProp_LoadType] = sec ? 2 : 1;
				if (!sec && invoker.WeaponStatus[BJProp_MagPrimary] >= 0 || sec && invoker.WeaponStatus[BJProp_MagSecondary] >= 0)
				{
					SetWeaponState('UnMag');
				}
				else if (!sec && invoker.WeaponStatus[BJProp_ChamberPrimary] > 0 || sec && invoker.WeaponStatus[BJProp_ChamberSecondary] > 0)
				{
					SetWeaponState('UnloadChamber');
				}
			}
			Goto Nope;
		UnloadChamber:
			BJKG A 1 A_JumpIf(invoker.WeaponStatus[BJProp_LoadType] == 1 && invoker.WeaponStatus[BJProp_ChamberPrimary] == 0 || invoker.WeaponStatus[BJProp_LoadType] == 2 && invoker.WeaponStatus[BJProp_ChamberSecondary] == 0, 'Nope');
			BJKG A 4 Offset(2, 34)
			{
				A_StartSound("Blackjack/BoltPull", 8);
			}
			BJKG A 6 Offset(1, 36)
			{
				if (invoker.WeaponStatus[BJProp_LoadType] == 1)
				{
					class<Actor> Which = invoker.WeaponStatus[BJProp_ChamberPrimary] > 1 ? 'HDRevolverAmmo' : 'HDSpent355';
					A_SpawnItemEx(Which, cos(pitch) * 10, 0, height - 8 - sin(pitch) * 10, vel.x, vel.y, vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
					invoker.WeaponStatus[BJProp_ChamberPrimary] = 0;
				}
				else if (invoker.WeaponStatus[BJProp_LoadType] == 2)
				{
					class<Actor> Which = invoker.WeaponStatus[BJProp_ChamberSecondary] > 1 ? 'HDShellAmmo' : 'HDSpentShell';
					A_SpawnItemEx(Which, cos(pitch) * 8, 0, height - 7 - sin(pitch) * 8, vel.x + cos(pitch) * cos(angle - random(86, 90)) * 5, vel.y + cos(pitch) * sin(angle - random(86, 90)) * 5, vel.z + sin(pitch) * random(4, 6), 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
					invoker.WeaponStatus[BJProp_ChamberSecondary] = 0;
				}
			}
			BJKG A 2 Offset(0, 34);
			Goto ReadyEnd;

		Reload:
		AltReload:
			BJKG A 0
			{
				bool invert = invoker.InvertFire.GetBool();

				invoker.WeaponStatus[BJProp_Flags] &= ~BJF_JustUnload;
				bool sec = !invert && PressingAltReload() || invert && !PressingAltReload();
				bool NoMags = HDMagAmmo.NothingLoaded(self, sec ? 'HDBlackjackMagShells' : 'HDBlackjackMag355');
				int magPrim = invoker.WeaponStatus[BJProp_MagPrimary];
				int magSec = invoker.WeaponStatus[BJProp_MagSecondary];
				int chPrim = invoker.WeaponStatus[BJProp_ChamberPrimary];
				int chSec = invoker.WeaponStatus[BJProp_ChamberSecondary];

				if (!sec && magPrim >= HDBlackjackMag355.MagCapacity || sec && magSec >= HDBlackjackMagShells.MagCapacity)
				{
					SetWeaponState('Nope');
				}
				else if (PressingUse() || NoMags)
				{
					if (!sec && chPrim < 1 && CheckInventory("HDRevolverAmmo", 1) || sec && chSec < 1 && CheckInventory("HDShellAmmo", 1))
					{
						SetWeaponState('LoadChamber');
					}
					else
					{
						SetWeaponState('Nope');
					}
				}
				invoker.WeaponStatus[BJProp_LoadType] = sec ? 2 : 1;
			}
			Goto UnMag;
		LoadChamber:
			BJKG A 1 Offset(0, 34) A_StartSound("weapons/pocket", 9);
			BJKG A 1 Offset(2, 36);
			BJKG A 1 Offset(2, 44);
			BJKG A 1 Offset(5, 54);
			BJKG A 2 Offset(7, 60);
			BJKG A 6 Offset(8, 70);
			BJKG A 5 Offset(8, 77)
			{
				if (invoker.WeaponStatus[BJProp_LoadType] == 1 && CheckInventory("HDRevolverAmmo", 1))
				{
					A_TakeInventory('HDRevolverAmmo', 1, TIF_NOTAKEINFINITE);
					invoker.WeaponStatus[BJProp_ChamberPrimary] = 2;
					A_StartSound("Blackjack/ChamberQuick", 8);
				}
				else if (invoker.WeaponStatus[BJProp_LoadType] == 2 && CheckInventory("HDShellAmmo", 1))
				{
					A_TakeInventory('HDShellAmmo', 1, TIF_NOTAKEINFINITE);
					invoker.WeaponStatus[BJProp_ChamberSecondary] = 2;
					A_StartSound("Blackjack/ChamberQuick", 8);
				}
			}
			BJKG A 3 Offset(9, 74);
			BJKG A 2 Offset(5, 70);
			BJKG A 1 Offset(5, 64);
			BJKG A 1 Offset(5, 52);
			BJKG A 1 Offset(5, 42);
			BJKG A 1 Offset(2, 36);
			BJKG A 2 Offset(0, 34);
			Goto Nope;

		UnMag:
			BJKG A 1 Offset(0, 34);
			BJKG A 1 Offset(5, 38);
			BJKG A 1 Offset(10, 42);
			BJKG A 3 Offset(20, 46) A_MuzzleClimb(0.3, 0.4);
			BJKG A 2 Offset(26, 52) A_MuzzleClimb(0.3, 0.4);
			BJKG A 2 Offset(26, 54)
			{
				A_StartSound("Blackjack/MagOut", 8);
				A_MuzzleClimb(0.3, 0.4);
			}
			BJKG A 0
			{
				int type = invoker.WeaponStatus[BJProp_LoadType];
				int magAmt = invoker.WeaponStatus[type == 1 ? BJProp_MagPrimary : BJProp_MagSecondary];
				if (magAmt == -1)
				{
					SetWeaponState('MagOut');
					return;
				}

				invoker.WeaponStatus[type == 1 ? BJProp_MagPrimary : BJProp_MagSecondary] = -1;
				class<HDMagAmmo> magCls = type == 1 ? 'HDBlackjackMag355' : 'HDBlackjackMagShells';

				if ((!PressingUnload() && !PressingReload() && !PressingAltReload()) || A_JumpIfInventory(magCls, 0, "Null"))
				{
					HDMagAmmo.SpawnMag(self, magCls, magAmt);
					SetWeaponState('MagOut');
				}
				else
				{
					HDMagAmmo.GiveMag(self, magCls, magAmt);
					SetWeaponState('PocketMag');
				}
			}
		PocketMag:
			BJKG AAAAAA 5 Offset(26, 54) A_MuzzleClimb(frandom(0.2, -0.8),frandom(-0.2, 0.4));
		MagOut:
			BJKG A 0
			{
				if (invoker.WeaponStatus[BJProp_Flags] & BJF_JustUnload)
				{
					SetWeaponState('ReloadEnd');
				}
			}
		LoadMag:
			BJKG A 0 A_StartSound("weapons/pocket", 9);
			BJKG A 6 offset(34, 54) A_MuzzleClimb(frandom(0.2, -0.8), frandom(-0.2, 0.4));
			BJKG A 7 offset(34, 52) A_MuzzleClimb(frandom(0.2, -0.8), frandom(-0.2, 0.4));
			BJKG A 10 offset(32, 50);
			BJKG A 3 offset(32, 49)
			{
				class<Inventory> whichCls = invoker.WeaponStatus[BJProp_LoadType] == 1 ? 'HDBlackjackMag355' : 'HDBlackjackMagShells';
				int whichIndex = invoker.WeaponStatus[BJProp_LoadType] == 1 ? BJProp_MagPrimary : BJProp_MagSecondary;
				let mag = HDMagAmmo(FindInventory(whichCls));
				if (mag)
				{
					invoker.WeaponStatus[whichIndex] = Mag.TakeMag(true);
					A_StartSound("Blackjack/MagIn", 8, CHANF_OVERLAP);
				}
			}
			Goto ReloadEnd;

		ReloadEnd:
			BJKG A 2 Offset(30, 52);
			BJKG A 2 Offset(20, 46);
			BJKG A 2 Offset(10, 42);
			BJKG A 2 Offset(5, 38);
			BJKG A 1 Offset(0, 34);
			Goto ChamberManual;

		ChamberManual:
			BJKG A 0 A_JumpIf(invoker.WeaponStatus[BJProp_LoadType] == 1 && (invoker.WeaponStatus[BJProp_MagPrimary] <= 0 || invoker.WeaponStatus[BJProp_ChamberPrimary] == 2) || invoker.WeaponStatus[BJProp_LoadType] == 2 && (invoker.WeaponStatus[BJProp_MagSecondary] <= 0 || invoker.WeaponStatus[BJProp_ChamberSecondary] == 2), "Nope");
			BJKG A 2 Offset(2, 34);
			BJKG A 4 Offset(3, 38);
			BJKG A 5 Offset(4, 44)
			{
				A_StartSound("Blackjack/BoltPull", 8, CHANF_OVERLAP);
				int type = invoker.WeaponStatus[BJProp_LoadType];
				int magIndex = type == 1 ? BJProp_MagPrimary : BJProp_MagSecondary;
				int chamberIndex = type == 1 ? BJProp_ChamberPrimary : BJProp_ChamberSecondary;
				class<Actor> casingCls = type == 1 ? 'HDSpent355' : 'HDSpentShell';

				if (invoker.WeaponStatus[chamberIndex] == 1)
				{
					A_EjectCasing(casingCls,frandom(-1,2),(6,-frandom(79, 81),frandom(6.0, 6.5)),(0,0,-2));
					//A_EjectCasing(casingCls, 6, -random(79, 81), frandom(6.0, 6.5));
				}
				
				invoker.WeaponStatus[magIndex]--;
				invoker.WeaponStatus[chamberIndex] = 2;
				A_WeaponBusy();
			}
			BJKG A 2 Offset(3, 38);
			BJKG A 2 Offset(2, 34);
			BJKG A 2 Offset(0, 32);
			Goto Nope;
	}
}

class BlackjackRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				A_SpawnItemEx("HDBlackjackMag355", -3,flags: SXF_NOCHECKPOSITION);
				A_SpawnItemEx("HDBlackjackMagShells", 6,flags: SXF_NOCHECKPOSITION);
				let wpn = HDBlackjack(Spawn("HDBlackjack", pos, ALLOW_REPLACE));
				if (!wpn)
				{
					return;
				}

				HDF.TransferSpecials(self, wpn);
				wpn.InitializeWepStats(false);
			}
			Stop;
	}
}


class HDBlackjackMag355 : HDMagAmmo
{
	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKJACKMAG_355_PREFIX")..Stringtable.localize("$TAG_BLACKJACKMAG_355")..Stringtable.localize("$PICKUP_BLACKJACKMAG_355_SUFFIX");
	}

	override string, string, name, double GetMagSprite(int thismagamt)
	{
		return (thismagamt > 0) ? "BJM3A0" : "BJM3B0", "PRNDA0", "HDRevolverAmmo", 1.0;
	}

	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("HDBlackjack");
	}

	const MagCapacity = 25;
	const EncMagEmpty = 9;
	const EncMagLoaded = EncMagEmpty * 0.9;

	Default
	{
		HDMagAmmo.MaxPerUnit MagCapacity;
		HDMagAmmo.InsertTime 7;
		HDMagAmmo.ExtractTime 5;
		HDMagAmmo.RoundType "HDRevolverAmmo";
		HDMagAmmo.RoundBulk ENC_355_LOADED;
		HDMagAmmo.MagBulk EncMagEmpty;
		Tag "$TAG_BLACKJACKMAG_355";
		HDPickup.RefId HDLD_BLACKJACKMAG_355;
		XScale 0.5;
		YScale 0.7;
	}

	States
	{
		Spawn:
			BJM3 A -1;
			Stop;
		SpawnEmpty:
			BJM3 B -1
			{
				bROLLSPRITE = true;
				bROLLCENTER = true;
				roll = randompick(0, 0, 0, 0, 2, 2, 2, 2, 1, 3) * 90;
			}
			Stop;
	}
}

class HDBlackjackMagShells : HDMagAmmo
{
	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_BLACKJACKMAG_SHELL_PREFIX")..Stringtable.localize("$TAG_BLACKJACKMAG_SHELL")..Stringtable.localize("$PICKUP_BLACKJACKMAG_SHELL_SUFFIX");
	}

	override string, string, name, double GetMagSprite(int thismagamt)
	{
		return (thismagamt > 0) ? "BJMSA0" : "BJMSB0", "SHL1A0", "HDShellAmmo", 1.0;
	}

	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("HDBlackjack");
	}

	const MagCapacity = 5;
	const EncMagEmpty = 9;
	const EncMagLoaded = EncMagEmpty * 0.9;

	Default
	{
		HDMagAmmo.MaxPerUnit MagCapacity;
		HDMagAmmo.InsertTime 10;
		HDMagAmmo.ExtractTime 8;
		HDMagAmmo.RoundType "HDShellAmmo";
		HDMagAmmo.RoundBulk ENC_SHELLLOADED;
		HDMagAmmo.MagBulk EncMagEmpty;
		Tag "$TAG_BLACKJACKMAG_SHELL";
		HDPickup.RefId HDLD_BLACKJACKMAG_SHELL;
		Scale 0.5;
	}

	States
	{
		Spawn:
			BJMS A -1;
			Stop;
		SpawnEmpty:
			BJMS B -1
			{
				bROLLSPRITE = true;
				bROLLCENTER = true;
				roll = randompick(0, 0, 0, 0, 2, 2, 2, 2, 1, 3) * 90;
			}
			Stop;
	}
}
