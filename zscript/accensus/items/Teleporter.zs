class TeleporterThinker : Thinker
{
	static TeleporterThinker Get()
	{
		ThinkerIterator it = ThinkerIterator.Create('TeleporterThinker', STAT_STATIC);
		TeleporterThinker t;
		while ((t = TeleporterThinker(it.Next())))
		{
			return t;
		}

		// [Ace] Create a new one if none exist.
		t = new('TeleporterThinker');
		t.ChangeStatNum(Thinker.STAT_STATIC);
		return t;
	}

	string LastLevel;
}

class HDTeleporter : HDWeaponGrabber
{
	enum TeleporterFlags
	{
		TF_JustUnload = 1
	}
	enum TeleporterProperties
	{
		TProp_Flags,
		TProp_Battery,
		TProp_Charge
	}
	enum RiftFlags
	{
		RF_INSTANT = 1,
		RF_FREE = 2,
		RF_DESTROY = 4
	}

	override void DoEffect()
	{
		if (!TeleThinker)
		{
			TeleThinker = TeleporterThinker.Get();
		}
		Cooldown--;
		if (TimesFumbled > 0 && Cooldown <= 0)
		{
			TimesFumbled--;
			Cooldown = 9;
		}

		Super.DoEffect();
	}

	override bool Use(bool pickup)
	{
		let plr = HDPlayerPawn(owner);
		if (!plr || plr.incapacitated <= 0)
		{
			return Super.Use(pickup);
		}

		plr.A_StartSound("weapons/pocket", 20);
		if (++TimesFumbled >= 7)
		{
			if (Rift && WeaponStatus[TProp_Charge] >= ActivationCost)
			{
				A_TeleportToRift(Rift, RF_DESTROY);
			}
			else if (!Rift && WeaponStatus[TProp_Charge] >= ActivationCost * 2)
			{
				A_OpenRift(HDCONST_ONEMETRE * (20 + 10 * (WeaponStatus[TProp_Charge] / 20)), RF_INSTANT);
				A_TeleportToRift(Rift);
			}
			TimesFumbled = 0;
		}

		return Super.Use(pickup);
	}

	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_FIRE..Stringtable.Localize("$TP_HELPTEXT_1")
		..LWPHELP_ALTFIRE..Stringtable.Localize("$TP_HELPTEXT_2")
		..LWPHELP_ZOOM.."+"..LWPHELP_FIRE..Stringtable.Localize("$TP_HELPTEXT_3")
		..LWPHELP_RELOADRELOAD
		..LWPHELP_UNLOADUNLOAD
		..LWPHELP_FIREMODE..Stringtable.Localize("$TP_HELPTEXT_4");
	}

	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			amt = clamp(amt, 1, 10);
			owner.A_DropInventory("HDBattery", 1);
		}
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) {return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass() { return 0; }
	override double WeaponBulk() { return 10; }
	override string, double GetPickupSprite() { return "TPRTZ0", 1.0; }
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			sb.DrawBattery(-54, -4, sb.DI_SCREEN_CENTER_BOTTOM, reloadorder: true);
			sb.DrawNum(hpl.CountInv("HDBattery"), -46, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if (Rift)
		{
			sb.DrawRect(-16, -15, -3, 3);
		}

		int charge = hdw.WeaponStatus[TProp_Charge];
		sb.DrawWepNum(charge, MaxCharge, posy: -9);
		sb.Fill(Color(255, 32, 192, 32), -16 + -8, -11, 2, 2, sb.DI_SCREEN_CENTER_BOTTOM);
		sb.Fill(Color(255, 192, 32, 32), -16 + -15, -11, -2, 2, sb.DI_SCREEN_CENTER_BOTTOM);

		int bat = hdw.WeaponStatus[TProp_Battery];
		if (bat > 0)
		{
			sb.DrawWepNum(bat, 20);
		}
		else if (bat == 0)
		{
			sb.DrawString(sb.mAmountFont, "00000", (-16, -7), sb.DI_TEXT_ALIGN_RIGHT | sb.DI_TRANSLATABLE | sb.DI_SCREEN_CENTER_BOTTOM, Font.CR_DARKGRAY);
		}
	}
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[TProp_Battery] = 20;
		WeaponStatus[TProp_Charge] = 20;
	}

	private action void A_TeleportToRift(HDTeleporterRift rf, int flags = 0, double velMult = 1.0)
	{
		A_WeaponOffset(1, 3, WOF_ADD); // [Ace] Should this even be here?
		if (!rf)
		{
			return;
		}

		let plr = HDPlayerPawn(invoker.owner);
		Actor OldTracer = plr.tracer; // [Ace] Just in case.
		
		double ThrustAngle = plr.AngleTo(rf);
		if (plr.Warp(rf, 0, 0, -(plr.height / 2), flags: WARPF_USECALLERANGLE | WARPF_NOCHECKPOSITION))
		{
			plr.A_ChangeVelocity(8 * cos(ThrustAngle) * velMult, 8 * sin(ThrustAngle) * velMult, 0);
			for (int i = 0; i < 360; ++i)
			{
				if (!random(0, 1))
				{
					plr.A_SpawnParticle(0x392249, SPF_RELATIVE, random(20, 50), random(4, 6), i, random(8, 16), 0, frandom(0, height), random(4, 16), 0, frandom(-3, 3), 0, 0, frandom(-0.05, 0));
				}
				plr.A_SpawnParticle(0x392249, SPF_RELATIVE, 15, 16, i, 0, 0, 0, 20, 0, 0, -0.8, sizestep: 0.6);
			}

			// [Ace] Take whatever you're holding with you. Provided you have enough space.
			if (invoker.Grabbed)
			{
				invoker.Grabbed.Warp(rf, plr.radius + invoker.Grabbed.Radius + 8, angle: plr.angle, flags: WARPF_ABSOLUTEANGLE);
				invoker.Grabbed.A_ChangeVelocity(3, 0, 0, CVF_RELATIVE);
				A_ClearGrabbing();
			}

			invoker.WeaponStatus[TProp_Charge] -= ActivationCost;
			plr.burncount += 5;
			if (flags & RF_DESTROY)
			{
				rf.Destroy();
			}
			plr.A_PlaySound("HDTeleporter/Teleport", 11);
			plr.tracer = OldTracer;
		}
		else
		{
			plr.A_Log("Destination is blocked. Force-closing rift.", true);
			rf.Destroy();
			plr.tracer = OldTracer;
		}
	}

	private action void A_OpenRift(double dist, int flags = 0)
	{
		let plr = HDPlayerPawn(invoker.owner);
		FLineTraceData data;

		bool hit = plr.LineTrace(plr.angle, dist, plr.pitch, TRF_NOSKY | TRF_THRUBLOCK | TRF_THRUHITSCAN, plr.height - 4, 0, 0, data);
		vector3 targetPos = data.HitLocation;

		if (hit)
		{
			switch (data.HitType)
			{
				case data.TRACE_HitActor:
				{
					double ang = data.HitActor.AngleTo(plr);
					ang = round(ang / 90.0) * 90.0; // [Ace] Snap to 90 degrees because hitboxes in Doom don't rotate.
					targetPos = data.HitActor.Vec3Angle(data.HitActor.radius + plr.radius * 2, ang);
					break;
				}
				case data.TRACE_HitWall:
				{
					vector3 oldPos = plr.pos;
					plr.SetXYZ(data.HitLocation);
					// [Ace] Move the player perpendicularly to the angle of the wall to prevent getting stuck.
					targetPos = plr.Vec3Angle(plr.radius * 2, VectorAngle(data.HitLine.delta.x, data.HitLine.delta.y) - 90);
					plr.SetXYZ(oldPos);
					break;
				}
			}
		}

		invoker.Rift = HDTeleporterRift(Spawn("HDTeleporterRift", targetPos));
		if (flags & RF_INSTANT)
		{
			invoker.Rift.Instant = true;
		}
		if (!(flags & RF_FREE))
		{
			invoker.WeaponStatus[TProp_Charge] -= ActivationCost;
		}
	}

	const ActivationCost = 2;
	const MaxCharge = 60;
	private int Cooldown;
	private int TimesFumbled;
	private HDTeleporterRift Rift;
	private int ChargeTicker;
	private bool GTFO;
	private int CrackTicker;
	TeleporterThinker TeleThinker;

	Default
	{
		Scale 0.5;
		+WEAPON.WIMPY_WEAPON
		+INVENTORY.INVBAR
		+HDWEAPON.FITSINBACKPACK
		HDWeapon.RefID "ptp";
		Inventory.Icon "TPRTZ0";
		Inventory.PickupMessage "$PICKUP_TELEPORTER";
		Tag "$TAG_TELEPORTER";
	}

	States
	{
		Spawn:
			TPRT Z -1;
			Stop;
		Select0:
			TPRT AAA 1 A_Raise(24);
			TPRT A 1
			{
				A_Raise(8);
				A_StartSound("HDTeleporter/Safety", 10, volume: 0.5);
			}
			TPRT BBCC 1 A_Raise(8);
			Wait;
		Deselect0:
			TPRT C 1 A_Lower(32);
			Wait;
		Ready:
			TPRT C 1
			{
				invoker.ChargeTicker = 0;
				A_WeaponReady(WRF_ALL);
			}
			Goto ReadyEnd;
		Firemode:
			TPRT C 0 A_ClearGrabbing();
		GrabHold:
			TPRT C 1 A_CheckGrabbing();
			TPRT C 0 A_JumpIf(PressingFire(), "Fire");
			TPRT C 0 A_JumpIf(PressingAltfire(), "AltFire");
			TPRT C 0 A_JumpIf(PressingFiremode(), "GrabHold");
			TPRT C 0 A_ClearGrabbing();
			Goto Nope;
		Fire:
			TPRT A 0 A_JumpIf(PressingZoom(), 'ChargeTeleporter');
			TPRT C 1
			{
				invoker.bWEAPONBUSY = true;
				A_StartSound("HDTeleporter/Button", 10, volume: 0.5);
				A_WeaponOffset(1, 12, WOF_ADD);
			}
			TPRT D 1 A_WeaponOffset(1, 6, WOF_ADD);
			TPRT E 8
			{
				if (invoker.WeaponStatus[TProp_Charge] >= ActivationCost * 2)
				{
					HDTeleporterRift OldRift = invoker.Rift;
					A_OpenRift(HDCONST_ONEMETRE * (20 + 10 * (invoker.WeaponStatus[TProp_Charge] / 20)), RF_INSTANT);
					A_TeleportToRift(invoker.Rift);
					invoker.Rift = OldRift;
				}
			}
			TPRT EDC 1 A_WeaponOffset(-1, -7, WOF_ADD);
			TPRT C 0 { invoker.bWEAPONBUSY = false; }
			Goto Nope;
		AltFire:
			TPRT C 1
			{
				invoker.bWEAPONBUSY = true;
				A_StartSound("HDTeleporter/Button", 10, volume: 0.5);
				A_WeaponOffset(1, 12, WOF_ADD);
			}
			TPRT D 1 A_WeaponOffset(1, 6, WOF_ADD);
			TPRT E 8
			{
				if (invoker.WeaponStatus[TProp_Charge] >= ActivationCost)
				{
					if (invoker.Rift)
					{
						A_TeleportToRift(invoker.Rift, RF_DESTROY);
					}
					else
					{
						A_OpenRift(HDCONST_ONEMETRE * 2);
					}
				}
			}
			TPRT EDC 1 A_WeaponOffset(-1, -7, WOF_ADD);
			TPRT C 0 { invoker.bWEAPONBUSY = false; }
			Goto Nope;
		ChargeTeleporter:
			TPRT C 1
			{
				invoker.bWEAPONBUSY = true;
				A_StartSound("HDTeleporter/Button", 10, volume: 0.5);
				A_WeaponOffset(1, 12, WOF_ADD);
			}
			TPRT D 1 A_WeaponOffset(1, 6, WOF_ADD);
		ChargeLoop:
			TPRT E 1
			{
				FLineTraceData data;
				LineTrace(angle, HDCONST_ONEMETRE * 300, pitch, TRF_NOSKY | TRF_THRUACTORS | TRF_THRUBLOCK | TRF_THRUHITSCAN, height - 6, data: data);

				bool inReloadingRoom = level.MapName ~== "LOTSAGUN";
				bool canSupercharge = invoker.WeaponStatus[TProp_Battery] >= 20 && (inReloadingRoom || CheckInventory('HDBlursphere', 1)) && CheckInventory('WornRadsuit', 1) && CheckInventory("SquadSummoner", 7) && (!inReloadingRoom && LevelInfo.MapExists("LOTSAGUN") && data.HitType == data.TRACE_HitNone || inReloadingRoom && invoker.TeleThinker.LastLevel != "");
				if (!PressingZoom() || !PressingFire() || invoker.WeaponStatus[TProp_Charge] == MaxCharge && !canSupercharge || invoker.WeaponStatus[TProp_Battery] <= 0)
				{
					SetWeaponState('LetGo');
					return;
				}

				if (++invoker.ChargeTicker > 105)
				{
					int toCharge = min(MaxCharge - invoker.WeaponStatus[TProp_Charge], invoker.WeaponStatus[TProp_Battery]);
					invoker.WeaponStatus[TProp_Battery] -= toCharge;
					
					if (invoker.WeaponStatus[TProp_Charge] < MaxCharge)
					{
						invoker.WeaponStatus[TProp_Charge] += toCharge;
					}
					else if (canSupercharge)
					{
						invoker.WeaponStatus[TProp_Battery] -= 20;
						invoker.WeaponStatus[TProp_Charge] -= MaxCharge;
						if (!inReloadingRoom)
						{
							A_TakeInventory("HDBlursphere", 1);
						}
						A_TakeInventory("SquadSummoner", 7);
						A_TakeInventory("WornRadsuit", 1);
						A_StartSound("weapons/plascrack", 11);
						A_StartSound("weapons/plascrack", 12);
						A_StartSound("world/tbfar", 14);
						A_StartSound("world/explode", 15);
						invoker.GTFO = true;
					}

					SetWeaponState('LetGo');
					return;
				}

				double fac = invoker.ChargeTicker / 10.0;
				double chfac = invoker.WeaponStatus[TProp_Charge] / double(MaxCharge);
				A_MuzzleClimb(frandom(-fac, fac) * 0.3 * chfac, frandom(-fac, fac) * 0.3 * chfac);

				if (++invoker.CrackTicker > 35 - 3 * fac)
				{
					invoker.CrackTicker = 0;
					A_StartSound(invoker.WeaponStatus[TProp_Charge] < MaxCharge ? "misc/arczap" : "weapons/plascrack", 10);
				}
			}
			Loop;
		LetGo:
			TPRT EDC 1 A_WeaponOffset(-1, -7, WOF_ADD);
			TPRT C 0
			{
				invoker.bWEAPONBUSY = false;
				if (invoker.GTFO)
				{
					invoker.GTFO = false;
					if (!(level.MapName ~== "LOTSAGUN"))
					{
						invoker.TeleThinker.LastLevel = level.MapName;
						level.ChangeLevel("LOTSAGUN", flags: CHANGELEVEL_NOINTERMISSION);
					}
					else
					{
						level.ChangeLevel(invoker.TeleThinker.LastLevel, flags: CHANGELEVEL_NOINTERMISSION);
						invoker.TeleThinker.LastLevel = "";
					}
				}
			}
			Goto Nope;

		Reload:
			TPRT C 0
			{
				invoker.WeaponStatus[TProp_Flags] &= ~TF_JustUnload;
				bool NoMags = HDMagAmmo.NothingLoaded(self, "HDBattery");
				if (invoker.WeaponStatus[TProp_Battery] >= 20 || NoMags)
				{
					SetWeaponState("Nope");
				}
			}
			Goto RemoveBattery;
		Unload:
			TPRT C 0
			{
				invoker.WeaponStatus[TProp_Flags] |= TF_JustUnload;
				if (invoker.WeaponStatus[TProp_Battery] == -1)
				{
					SetWeaponState("Nope");
				}
			}
			Goto RemoveBattery;
		RemoveBattery:
			TPRT C 1 Offset(0, 36) A_SetCrosshair(21);
			TPRT C 1 Offset(2, 42);
			TPRT C 2 Offset(4, 50);
			TPRT C 3 Offset(6, 56) A_StartSound("weapons/pismagclick", 8, CHANF_OVERLAP);
			TPRT C 0
			{
				int Bat = invoker.WeaponStatus[TProp_Battery];
				invoker.WeaponStatus[TProp_Battery] = -1;
				if (Bat == -1)
				{
					SetWeaponState("BatteryOut");
				}
				else if((!PressingUnload() && !PressingReload()) || A_JumpIfInventory("HDBattery", 0, "null"))
				{
					HDMagAmmo.SpawnMag(self, "HDBattery", Bat);
					SetWeaponState("BatteryOut");
				}
				else
				{
					HDMagAmmo.GiveMag(self, "HDBattery", Bat);
					A_StartSound("weapons/pocket", 9);
					SetWeaponState("PocketMag");
				}
			}
		PocketMag:
			TPRT CCC 5 Offset(0, 46) A_MuzzleClimb(frandom(-0.1, 0.2), frandom(-0.2, 0.4));
			Goto BatteryOut;
		BatteryOut:
			TPRT C 0
			{
				if (invoker.WeaponStatus[TProp_Flags] & TF_JustUnload)
				{
					SetWeaponState("ReloadEnd");
				}
			}
		LoadMag:
			TPRT C 4 Offset(0, 53) A_MuzzleClimb(frandom(-0.2, 0.4), frandom(-0.2, 0.4));
			TPRT C 0 A_StartSound("weapons/pocket", 9);
			TPRT C 5 Offset(0, 56) A_MuzzleClimb(frandom(-0.2, 0.4), frandom(-0.2, 0.4));
			TPRT C 3;
			TPRT C 0
			{
				let Bat = HDMagAmmo(FindInventory("HDBattery"));
				if (Bat)
				{
					invoker.WeaponStatus[TProp_Battery] = Bat.TakeMag(true);
					A_StartSound("weapons/pismagclick", 8);
				}
			}
			Goto ReloadEnd;
		ReloadEnd:
			TPRT C 2 Offset(6, 50);
			TPRT C 1 Offset(4, 42);
			TPRT C 1 Offset(2, 36);
			TPRT C 1 Offset(1, 32);
			Goto Nope;
		User3:
			TPRT A 0 A_MagManager("HDBattery");
			Goto Ready;
	}
}

class HDTeleporterRift : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+FIXMAPTHINGPOS
		ReactionTime 35 * 60;
		Radius 16;
		Height 4;
	}

	bool Instant;

	States
	{
		Spawn:
			RFTG A 0 NoDelay
			{
				DistantNoise.Make(self, "world/tbfar");
				DistantNoise.Make(self, "world/tbfar2", 2.0);
				DistantQuaker.Quake(self, 5, 50, 2048, 8, 128, 256, 256);

				for (int i = 0; i < 3; ++i)
				{
					A_SpawnItemEx("WallChunker", frandom(-4 ,4), frandom(-4, 4), -4, flags:SXF_NOCHECKPOSITION | SXF_TRANSFERPOINTERS);
				}
				
				A_StartSound("weapons/plascrack", 11);
				A_StartSound("weapons/plascrack", 12);
				A_StartSound("world/tbfar", 14);
				A_StartSound("world/explode", 15);
				if (Instant)
				{
					Destroy();
				}
			}
		SpawnLoop:
			TNT1 A 1
			{
				for (int i = 0; i < 4; ++i)
				{
					int SpawnPitch = random(-80, 80);
					int SpawnAngle = random(0, 359);
					double sinp = sin(SpawnPitch);
					double cosp = cos(SpawnPitch);
					Color col = randompick(0x0f0b19, 0x171127, 0x201735);
					double AgeFactor = max(0.1, (ReactionTime / double(default.ReactionTime)));
					double SpawnDist = random(128, 192) * AgeFactor;
					int Speed = -4;
					double Acceleration = -0.05;
					A_SpawnParticle(col, SPF_RELATIVE, int(35 * AgeFactor), frandom(5.0, 8.0), SpawnAngle, SpawnDist * cosp, 0, (SpawnDist * sinp) / 1.2, Speed * cosp, 0, (Speed * sinp) / 1.2, Acceleration * cosp, 0, (Acceleration * sinp) / 1.2);
				}

				A_SpawnItemEx("HDRiftSmoke", flags: SXF_SETMASTER);

				if (--ReactionTime <= 0)
				{
					SetStateLabel("Death");
					return;
				}
			}
			Loop;
	}
}

class HDRiftSmoke : Actor
{
	override void PostBeginPlay()
	{
		A_SetRoll(random(0, 359));
		if (master)
		{
			A_SetScale(max(0.05, frandom(0.20, 0.40) * (master.ReactionTime / double(master.default.ReactionTime))));
		}
		else
		{
			A_SetScale(0.05);
		}

		Super.PostBeginPlay();
	}

	Default
	{
		+NOINTERACTION
		+ROLLSPRITE
		+FORCEXYBILLBOARD
		Renderstyle "Shaded";
	}

	States
	{
		Spawn:
			RFSM K 1
			{
				if (!random(0, 2))
				{
					SetShade(0x2c243d);
				}
				else if (!random(0, 2))
				{
					SetShade(0x181127);
				}
				else
				{
					SetShade(0x07060a);
				}
				A_FadeOut(0.12);
				A_SetScale(Scale.X - 0.02);
			}
	}
}