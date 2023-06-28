class HDGungnir : HDCellWeapon
{
	enum GungnirFlags
	{
		GNF_Accelerator = 1,
		GNF_Capacitor = 2,
		GNF_Processor = 4,
		GNF_AntiFrag = 8
	}

	enum GungnirProperties
	{
		GNProp_Flags,
		GNProp_Battery,
		GNProp_Charge,
		GNProp_Timer,
		GNProp_LoadType
	}

	override void Tick()
	{
		if (!owner)
		{
			if (Charge > 0)
			{
				A_DestroyBattery();
				A_ResetWeapon();
			}
		}
		Super.Tick();
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass() { return WeaponStatus[GNProp_Battery] >= 0 ? 13 : 12; }
	override double WeaponBulk() { return 170 + (WeaponStatus[GNProp_Battery] >= 0 ? ENC_BATTERY_LOADED : 0); }
	override string, double GetPickupSprite() { return "GNGRZ0", 0.7; }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[GNProp_Battery] = 20;
		WeaponStatus[GNProp_Charge] = GetMaxCharge();
		WeaponStatus[GNProp_Timer] = 0;
	}
	override void LoadoutConfigure(string input)
	{
		if (GetLoadoutVar(input, "accel", 1) > 0)
		{
			WeaponStatus[GNProp_Flags] |= GNF_Accelerator;
		}
		if (GetLoadoutVar(input, "cap", 1) > 0)
		{
			WeaponStatus[GNProp_Flags] |= GNF_Capacitor;
		}
		if (GetLoadoutVar(input, "proc", 1) > 0)
		{
			WeaponStatus[GNProp_Flags] |= GNF_Processor;
		}

		InitializeWepStats(false);
	}

	override string GetHelpText()
	{
		return WEPHELP_FIRE.."  Shoot\n"
		..WEPHELP_ALTFIRE.."  Charge/Lock\n"
		..WEPHELP_RELOAD.."  Abort charge/Reload battery\n"
		..WEPHELP_UNLOADUNLOAD;
	}

	override string PickupMessage()
	{
		string AccStr = WeaponStatus[GNProp_Flags] & GNF_Accelerator ? "accelerated " : "";
		string CapStr = WeaponStatus[GNProp_Flags] & GNF_Capacitor ? "high-capacity " : "";
		string ProcStr = WeaponStatus[GNProp_Flags] & GNF_Processor ? " with high-efficiency processor" : "";
		return String.Format("You got the %s%s'Gungnir' frag beam rifle%s.", AccStr, CapStr, ProcStr);
	}

	protected clearscope int GetMaxCharge()
	{
		return WeaponStatus[GNProp_Flags] & GNF_Capacitor ? 3 : 2;
	}

	protected clearscope int GetBatteryCost()
	{
		return WeaponStatus[GNProp_Flags] & GNF_Processor ? 2 : 4;
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			sb.DrawBattery(-54, -4, sb.DI_SCREEN_CENTER_BOTTOM, reloadorder: true);
			sb.DrawNum(hpl.CountInv("HDBattery"), -46, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}

		for (int i = 0; i < hdw.WeaponStatus[GNProp_Charge]; ++i)
		{
			sb.DrawRect(-16 - 8 * i, -15, -7, 4);
		}

		sb.DrawRect(-16, -18, -23 * (Charge / double(A_GetChargePerTier() * Tiers)), 2);
		sb.DrawRect(-16, -10, -23 * (Charge / double(A_GetChargePerTier() * Tiers)), 2);

		if (Locked)
		{
			sb.DrawRect(-16, -19, -6, -5);
			sb.DrawRect(-16, -25, -2, -2);
			sb.DrawRect(-20, -25, -2, -2);
			sb.DrawRect(-18, -27, -2, -2);
		}

		int batCharge = hdw.WeaponStatus[GNProp_Battery];
		if (batCharge > 0)
		{
			for (int i = 0; i < batCharge / GetBatteryCost(); ++i)
			{
				if (hdw.WeaponStatus[GNProp_Flags] & GNF_Processor)
				{
					sb.DrawRect(-16 - 5 * (i / 2), (i % 2 == 0) ? -4 : -7, -4, 2);
				}
				else
				{
					sb.DrawRect(-16 - 5 * i, -7, -4, 4);
				}
			}
		}
		else if (batCharge == 0)
		{
			sb.DrawString(sb.mAmountFont, "00000", (-16, -7), sb.DI_TEXT_ALIGN_RIGHT | sb.DI_TRANSLATABLE | sb.DI_SCREEN_CENTER_BOTTOM, Font.CR_DARKGRAY);
		}
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = Screen.GetClipRect();
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 16, sb.DI_SCREEN_CENTER);
		vector2 bobb = bob * 2;
		bobb.y = clamp(bobb.y, -8, 8);
		sb.DrawImage("GNGRFRNT", bobb, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9);
		sb.SetClipRect(cx, cy, cw, ch);
		sb.DrawImage("GNGRBACK", (0, 3) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER);

		if (scopeview)
		{
			int ScaledYOffset = 60;
			int ScaledWidth = 89;
			vector2 ScaleHalf = (0.25, 0.25);
			int cx, cy, cw, ch;
			[cx, cy, cw, ch] = Screen.GetClipRect();
			sb.SetClipRect(-44.5 + bob.x, 16 + bob.y, ScaledWidth, ScaledWidth, sb.DI_SCREEN_CENTER);

			texman.setcameratotexture(hpc, "HDXCAM_BOSS", 5);
			let cam  = texman.CheckForTexture("HDXCAM_BOSS",TexMan.Type_Any);
			sb.DrawCircle(cam,(0,scaledyoffset)+bob*3,.11,usePixelRatio:true);

			sb.DrawImage("HDXCAM_BOSS", (0, ScaledYOffset) + bob, sb.DI_SCREEN_CENTER |  sb.DI_ITEM_CENTER, scale: ScaleHalf);
			sb.DrawImage("SCOPHOLE", (0, ScaledYOffset) + bob * 5, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, scale: (1.5, 1.5));
			Screen.SetClipRect(cx, cy, cw, ch);
			sb.DrawImage("GNRSCOPE", (0, ScaledYOffset) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, scale: (1.24, 1.24));
		}
	}

	private clearscope action int A_GetChargePerTier()
	{
		return invoker.WeaponStatus[GNProp_Flags] & GNF_Accelerator ? 5 : 10;
	}

	private action int A_GetDelayPerTier()
	{
		return invoker.WeaponStatus[GNProp_Flags] & GNF_Accelerator ? 20 : 30;
	}

	private action void A_ResetWeapon()
	{
		for (int i = 0; i < Tiers; ++i)
		{
			invoker.HasReachedTier[i] = false;
		}
		invoker.Charge = 0;
		invoker.ChargeDelayTicker = 0;
		A_ClearOverlays(-4, -4);
		if (invoker.DynLight)
		{
			invoker.DynLight.Destroy();
		}
		invoker.Locked = false;
	}

	private action void A_DestroyBattery()
	{
		A_StartSound("weapons/plascrack", 11);
		A_StartSound("weapons/plascrack", 12);
		A_StartSound("weapons/plascrack", 13);
		A_StartSound("world/tbfar", 14);
		A_StartSound("world/explode", 15);

		invoker.WeaponStatus[GNProp_Battery] = -1;
		invoker.WeaponStatus[GNProp_Charge] = 0;

		Actor ltt = Spawn("LingeringThunder", pos, ALLOW_REPLACE);
		ltt.target = invoker.owner;
		ltt.stamina = 35 + invoker.Charge;
	}

	private action void A_FireGungnir()
	{
		int tier = invoker.Charge / A_GetChargePerTier();

		A_Light0();
		A_StartSound("Gungnir/DeathRayFire", CHAN_WEAPON, pitch: 1.00 - 0.2 * (tier - 1));
		int minDamage, maxDamage;
		switch (tier)
		{
			case 1: minDamage = 800; maxDamage = 1000; break;
			case 2: minDamage = 2500; maxDamage = 3000; break;
			case 3: minDamage = 10000; maxDamage = 12000; break;
		}

		string puff = "GungnirRayImpactT"..tier;
		if (invoker.WeaponStatus[GNProp_Flags] & GNF_AntiFrag && tier == 3)
		{
			puff = puff.."OP";
		}
		A_RailAttack(random(minDamage, maxDamage), 0, false, "", "", RGF_NORANDOMPUFFZ | RGF_SILENT | RGF_NOPIERCING, 0, puff, 0, 0, HDCONST_ONEMETRE * 300, 0, 10.0, 0, "GungnirRaySegment", player.crouchfactor < 1.0 ? 0.9 : 1.8);

		A_Recoil((2.25 ** tier) * (HDPlayerPawn(self).gunbraced ? 0.3 : 1.0));
		A_AlertMonsters();
		A_SetBlend(0xDFFF66, 0.33 * tier, 30);
		A_ZoomRecoil(1.00 + 2 ** tier);
		A_ResetWeapon();

		double cMult = 1.0 + tier / 3.0;
		A_MuzzleClimb(0, 0, -0.2 * cMult, -0.8 * cMult, -frandom(0.5, 0.9) * cMult, -frandom(3.2, 4.0) * cMult, -frandom(0.5, 0.9) * cMult, -frandom(3.2, 4.0) * cMult);
		invoker.WeaponStatus[GNProp_Charge] -= tier;
	}

	const Tiers = 3;
	private int Charge; // [Ace] GNProp_Charge is for the "loaded" shots. This here is for charging up a more powerful beam.
	private bool HasReachedTier[Tiers];
	private int ChargeDelayTicker;
	private PointLight DynLight;
	private bool Locked;

	Default
	{
		-HDWEAPON.FITSINBACKPACK
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 7;
		Weapon.SlotPriority 1.5;
		HDWeapon.BarrelSize 35, 1.6, 3;
		Scale 0.5;
		Tag "Gungnir";
		HDWeapon.Refid "gnr";
	}

	States
	{
		Spawn:
			GNGR Z -1;
			Stop;
		Ready:
			GNGR A 1
			{
				A_WeaponReady(invoker.Charge > 0 ? WRF_NOFIRE : WRF_NOPRIMARY | WRF_ALL);
				int reqCharge = A_GetChargePerTier();
				int tier = invoker.Charge / reqCharge;
				if (PressingFire() && invoker.WeaponStatus[GNProp_Charge] > 0)
				{
					if (!invoker.DynLight)
					{
						invoker.DynLight = PointLight(Spawn("PointLight", pos + (0, 0, height / 2 + 2)));
					}
					else
					{
						invoker.DynLight.Args[0] = 0xDF;
						invoker.DynLight.Args[1] = 0xFF;
						invoker.DynLight.Args[2] = 0x66;
						invoker.DynLight.Args[3] = int(128 * (invoker.Charge / double(reqCharge * Tiers)));
						invoker.DynLight.SetOrigin(pos + (0, 0, height / 2 + 2), true);
					}

					A_MuzzleClimb(frandom(-0.10, 0.10) * (1.7 ** tier), frandom(-0.10, 0.10) * (1.7 ** tier));

					A_Overlay(-4, 'BlastCharge0', true);
					A_OverlayFlags(-4, PSPF_RENDERSTYLE, true);
					A_OverlayPivot(-4);
					A_OverlayRenderStyle(-4, STYLE_Add);
					if (tier == 0)
					{
						A_OverlayScale(-4, invoker.Charge / double(reqCharge));
					}
					else
					{
						A_OverlayScale(-4, 1.0 + (((invoker.Charge % reqCharge) / double(reqCharge))) * 0.55);
					}

					if (level.time % 4 == 0)
					{
						A_StartSound("weapons/bfgcharge", 8, pitch: 0.8);
					}

					let plr = HDPlayerPawn(self);
					if (invoker.Charge < Tiers * reqCharge && tier < invoker.WeaponStatus[GNProp_Charge])
					{
						if (!invoker.Locked || invoker.Charge % reqCharge != 0)
						{
							if (level.time % 4 == 0)
							{
								BFG9k.Spark(self, 1, height - 10);
							}
						
							if (tier == 0 || tier > 0 && ++invoker.ChargeDelayTicker >= A_GetDelayPerTier())
							{
								invoker.Charge++;
								tier = invoker.Charge / reqCharge;
							}
						}
					}

					if (JustPressed(BT_ALTATTACK))
					{
						invoker.Locked = !invoker.Locked;
						A_StartSound("Gungnir/"..(invoker.Locked ? "Lock" : "Unlock"), 9);
					}
					
					if (tier > 0 && !invoker.HasReachedTier[tier - 1])
					{
						invoker.HasReachedTier[tier - 1] = true;
						A_StartSound("Gungnir/Charge", 10, pitch: 1.0 + 0.15 * (tier - 1));
						A_WeaponOffset(0, 35);
						invoker.ChargeDelayTicker = 0;
					}
				}
				else if (tier > 0)
				{
					SetWeaponState('Shoot');
				}
				else
				{
					A_ResetWeapon();
				}
			}
			Goto ReadyEnd;
		BlastCharge0:
			GNC1 ABCDEFGHIJKLMNOPQRST 1 Bright A_JumpIf(invoker.Charge / A_GetChargePerTier() == 1, 'BlastCharge1');
			Loop;
		BlastCharge1:
			GNC1 ABCDEFGHIJKLMNOPQRST 1 Bright A_JumpIf(invoker.Charge / A_GetChargePerTier() == 2, 'BlastCharge2');
			Loop;
		BlastCharge2:
			GNC2 ABCDEFGHIJKLMNOPQRST 1 Bright A_JumpIf(invoker.Charge / A_GetChargePerTier() == 3, 'BlastCharge3');
			Loop;
		BlastCharge3:
			GNC3 ABCDEFGHIJKLMNOPQRST 1 Bright;
			Loop;

		Select0:
			GNGR A 0;
			Goto Select0Big;
		Deselect0:
			GNGR A 0
			{
				invoker.WeaponStatus[GNProp_Timer] = 0;
				if (invoker.Charge > 0)
				{
					A_ResetWeapon();
				}
			}
			Goto Deselect0Big;
		User3:
			#### A 0 A_MagManager("HDBattery");
			Goto Ready;
		AltFire:
			#### A 0
			{
				if (invoker.WeaponStatus[GNProp_Charge] < invoker.GetMaxCharge() && invoker.WeaponStatus[GNProp_Battery] >= invoker.GetBatteryCost())
				{ 
					return ResolveState("Charge");
				}

				return ResolveState("Nope");
			}
			Stop;
		Shoot:
			#### F 2 Bright Offset(0, 44) A_FireGungnir();
			#### B 2 Offset(0, 38);
			#### B 1 Offset(0, 32);
			Goto Nope;
		Charge:
			#### B 1;
		ActualCharge:
			#### C 6
			{
				if (PressingReload() || invoker.WeaponStatus[GNProp_Battery] < invoker.GetBatteryCost() || invoker.WeaponStatus[GNProp_Charge] == invoker.GetMaxCharge())
				{
					invoker.WeaponStatus[GNProp_Timer] = 0;
					SetWeaponState("Reload4");
					return;
				}

				if (++invoker.WeaponStatus[GNProp_Timer] > (invoker.WeaponStatus[GNProp_Flags] & GNF_Accelerator ? 4 : 12) - (AceCore.CheckForItem(self, "HDRedline") ? 2 : 0))
				{
					invoker.WeaponStatus[GNProp_Timer] = 0;
					invoker.WeaponStatus[GNProp_Battery] -= invoker.GetBatteryCost();
					invoker.WeaponStatus[GNProp_Charge] = invoker.GetMaxCharge();
				}

				A_WeaponBusy(false);
				A_StartSound("weapons/bfgcharge", 8);
				BFG9k.Spark(self, 1, height - 10);
				A_WeaponReady(WRF_NOFIRE);
			}
			Loop;
		Reload:
			#### A 0
			{
				if (invoker.WeaponStatus[GNProp_Battery] >= 20 || !CheckInventory("HDBattery", 1))
				{
					SetWeaponState("Nope");
					return;
				}
				invoker.WeaponStatus[GNProp_LoadType] = 1;
			}
			Goto Reload1;
		Unload:
			#### A 0
			{
				if (invoker.WeaponStatus[GNProp_Battery] == -1)
				{
					SetWeaponState("Nope");
					return;
				}
				invoker.WeaponStatus[GNProp_LoadType] = 0;
			}
			Goto Reload1;
		Reload1:
			#### A 4;
			#### B 2 Offset(0, 36) A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
			#### C 2 Offset(0, 38) A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
			#### C 4 Offset(0, 40)
			{
				A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
				A_StartSound("weapons/bfgclick2", 8);
			}
			#### C 2 Offset(0, 42)
			{
				A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
				A_StartSound("weapons/bfgopen", 8);
				if (invoker.WeaponStatus[GNProp_Battery] >= 0)
				{
					if (PressingReload() || PressingUnload())
					{
						HDMagAmmo.GiveMag(self, "HDBattery", invoker.WeaponStatus[GNProp_Battery]);
						A_SetTics(10);
					}
					else
					{
						HDMagAmmo.SpawnMag(self, "HDBattery", invoker.WeaponStatus[GNProp_Battery]);
						A_SetTics(4);
					}
				}
				invoker.WeaponStatus[GNProp_Battery] = -1;
			}
			Goto BatteryOut;
		BatteryOut:
			#### C 4 Offset(0, 42)
			{
				if (invoker.WeaponStatus[GNProp_LoadType] == 0)
				{
					SetWeaponState("Reload3");
				}
				else
				{
					A_StartSound("weapons/pocket", 9);
				}
			}
			#### C 12;
			#### C 12 Offset(0, 42) A_StartSound("weapons/bfgbattout", 8);
			#### C 10 Offset(0, 36) A_StartSound("weapons/bfgbattpop", 8);
			#### C 0
			{
				let Battery = HDMagAmmo(FindInventory("HDBattery"));
				if (Battery && Battery.Amount > 0)
				{
					invoker.WeaponStatus[GNProp_Battery] = Battery.TakeMag(true);
				}
				else
				{
					SetWeaponState("Reload3");
					return;
				}
			}
		Reload3:
			#### C 6 Offset(0, 38) A_StartSound("weapons/bfgopen", 8);
			#### C 8 Offset(0, 37) A_StartSound("weapons/bfgclick2", 8);
			#### C 2 Offset(0, 38);
			#### B 2 Offset(0, 36);
			#### A 2 Offset(0, 34);
			#### A 12;
			Goto Ready;
		Reload4:
			#### CBA 2;
			Goto Nope;
	}
}

class GungnirRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 nodelay
			{
				let wpn = HDGungnir(Spawn("HDGungnir", pos, ALLOW_REPLACE));
				if (!wpn)
				{
					return;
				}

				HDF.TransferSpecials(self, wpn);
				if (!random(0, 3))
				{
					wpn.WeaponStatus[wpn.GNProp_Flags] |= wpn.GNF_Accelerator;
				}
				if (!random(0, 3))
				{
					wpn.WeaponStatus[wpn.GNProp_Flags] |= wpn.GNF_Capacitor;
				}
				if (!random(0, 3))
				{
					wpn.WeaponStatus[wpn.GNProp_Flags] |= wpn.GNF_Processor;
				}
				wpn.InitializeWepStats(false);
			}
			Stop;
	}
}

class GungnirRayImpact : Actor abstract
{
	protected abstract void OnBlast(bool miss);
	protected void SpawnBlastEffects(int tier, bool miss)
	{
		// Horizontal ring.
		for (int i = -180; i < 180; i += 4)
		{
			A_SpawnParticle(0xAAFF42, SPF_FULLBRIGHT | SPF_RELATIVE, 10 + 2 * tier, 32 + 8 * tier, i, 0, 0, 0, 12, sizestep: 4.0);
		}
		
		// Ball.
		for (int i = -180; i < 180; i += 10)
		{
			for (int j = -90 + 10; j < 90 - 9; j += 10)
			{
				A_SpawnParticle(0xDFFF66, SPF_FULLBRIGHT | SPF_RELATIVE, 15 + tier, 24 + 4 * tier, i, 0, 0, 0, 4 * cos(j) * level.pixelstretch, 0, 4 * sin(j), sizestep: 2.0);
			}
		}

		if (miss)
		{
			// Spears.
			for (int i = 0; i < 10 * (tier + 1); ++i)
			{
				pitch = frandom(-85.0, 85.0);
				double smokeVel = frandom(10 + 5 * tier, 20 + 10 * tier);
				A_SpawnItemEx("GungnirRayImpactSpear", 0, 0, 0, smokeVel * cos(pitch), 0, smokeVel * sin(pitch), random(0, 359), SXF_NOCHECKPOSITION);
			}
		}
	}

	Default
	{
		+FORCEDECAL
		+PUFFGETSOWNER
		+ALWAYSPUFF
		+PUFFONACTORS
		+NOINTERACTION
		+BLOODLESSIMPACT
		+FORCERADIUSDMG
		+NOBLOOD
		+HITTRACER
		Decal "GungnirScorch";
		DamageType "Electrical";
	}

	States
	{
		Spawn:
			TNT1 A 16 NoDelay OnBlast(false);
			Stop;
		Crash:
			TNT1 A 16 OnBlast(true);
			Stop;
	}
}

class GungnirRayImpactT1 : GungnirRayImpact
{
	override void OnBlast(bool miss)
	{
		DoorDestroyer.DestroyDoor(self, 128, 32, dedicated: true); 
		A_Explode(random(200, 300), int(HDCONST_ONEMETRE * 3), XF_HURTSOURCE, false, damageType: 'Electrical');
		A_StartSound("Gungnir/RayHit", 8, attenuation: 0.5);
		DistantQuaker.Quake(self, 2, 50, HDCONST_ONEMETRE * 30, 10, 256, 512, 128);
		SpawnBlastEffects(0, miss);
	}
}

class GungnirRayImpactT2 : GungnirRayImpact
{
	override void OnBlast(bool miss)
	{
		DoorDestroyer.DestroyDoor(self, 256, 64, dedicated: true); 
		A_Explode(random(750, 1000), int(HDCONST_ONEMETRE * 4), XF_HURTSOURCE, false, damageType: 'Electrical');
		A_StartSound("Gungnir/RayHit", 8, attenuation: 0.2, pitch: 0.8);
		DistantQuaker.Quake(self, 4, 50, HDCONST_ONEMETRE * 70, 10, 256, 512, 128);
		SpawnBlastEffects(1, miss);
	}
}

class GungnirRayImpactT3 : GungnirRayImpact
{
	override void OnBlast(bool miss)
	{
		DoorDestroyer.DestroyDoor(self, 384, 96, dedicated: true); 
		A_Explode(random(1500, 2000), int(HDCONST_ONEMETRE * 5), XF_HURTSOURCE, false, damageType: 'Electrical');
		A_StartSound("Gungnir/RayHit", 8, attenuation: ATTN_NONE, pitch: 0.6);
		DistantQuaker.Quake(self, 6, 50, HDCONST_ONEMETRE * 200, 10, 256, 512, 128);
		SpawnBlastEffects(2, miss);
	}
}
/*
class GungnirRayImpactT3OP : GungnirRayImpactT3
{
	override void OnBlast(bool miss)
	{
		let necro = Necromancer(tracer);
		if (necro && !necro.bFRIENDLY)
		{
			for (int i = 0; i < 4 * necro.hitsleft; ++i)
			{
				necro.A_SpawnItemEx("BFGNecroShard", 0, 0, 42, flags: SXF_SETMASTER | SXF_TRANSFERPOINTERS);
			}
			necro.hitsleft = 0;
			necro.A_ChangeNecroFlags(true);
			necro.DamageMobj(self, target, 2000, 'Extreme', DMG_FORCED);
			let forcer = new('CurseForcer');
			forcer.Necro = necro;
		}
		Super.OnBlast(miss);
	}
}

class CurseForcer : Thinker
{
	private int Ticker;
	Necromancer Necro;
	override void Tick()
	{
		Super.Tick();
		if (!Necro)
		{
			Destroy();
			return;
		}
		if (Ticker++ == 45)
		{
			Necro.SetStateLabel('ghost');
			Destroy();
			return;
		}
	}
}
*/
class GungnirRaySegment : Actor
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		for (int i = 0; i < 2; ++i)
		{
			A_SpawnParticle(0xDFFF66, SPF_RELATIVE | SPF_FULLBRIGHT, random(100, 200), frandom(1.5, 3.0), 0,random(-10, 10), 0, 0,
				frandom(-0.10, 0.10), frandom(-0.10, 0.10), frandom(-0.10, 0.10),
				frandom(-0.005, 0.005), frandom(-0.005, 0.005), frandom(-0.005, 0.005));
		}
		if (target)
		{
			double dist = Distance3D(target);
			alpha += 0.00075 * dist;
		}
	}

	private double FadeSpeed;

	Default
	{
		Renderstyle "Add";
		+NOINTERACTION
		+NOBLOCKMAP
		+BRIGHT
		Alpha 1.0;
	}

	States
	{
		Spawn:
			GNGY A 1 Bright A_FadeOut(0.05);
			Loop;
	}
}

class GungnirRayImpactSpear : Actor
{
	override void PostBeginPlay()
	{
		ReactionTime = int(ReactionTime * frandom(0.10, 1.0));

		Super.PostBeginPlay();
	}

	Default
	{
		+NOINTERACTION
		Gravity 0.4;
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

				vel *= 0.97;
				vel.z -= 1.0 * Gravity;

				A_SpawnItemEx("GungnirSmoke");
			}
			Loop;
	}
}

class GungnirSmoke : ACESmokeBase
{
	Default
	{
		Renderstyle "Shaded";
		StencilColor "D1FF47";
	}
}
