class HDRedline : HDCellWeapon
{
	enum RedlineFlags
	{
		RDF_LockOn = 1,
		RDF_Overheated = 2,
		RDF_JustUnload = 4
	}

	enum RedlineProperties
	{
		RDProp_Flags,
		RDProp_Battery,
		RDProp_LoadType,
		RDProp_Heat
	}

	override void PostBeginPlay()
	{
		weaponspecial = 1337; // [Ace] UaS sling compatibility.

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (WeaponStatus[RDProp_Heat] > 0)
		{
			DrainHeat(RDProp_Heat, 10, 0.5, 1.5, 0.6);
		}
		if (WeaponStatus[RDProp_Heat] < A_GetMaxHeat())
		{
			WeaponStatus[RDProp_Flags] &= ~RDF_Overheated;
		}

		if (!owner)
		{
			A_ClearLockon();
		}
		else
		{
			for (int i = 0; i < LockedTargets.Size();)
			{
				if (!IsValidTarget(self, LockedTargets[i]))
				{
					LockedTargets.Delete(i);
					continue;
				}
				++i;
			}
		}

		Super.Tick();
	}

	override void PreTravelled()
	{
		A_ClearLockon();
		Super.PreTravelled();
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner , bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass() { return WeaponStatus[RDProp_Battery] >= 0 ? 11.5 : 11; }
	override double WeaponBulk() { return 122 + (WeaponStatus[RDProp_Battery] >= 0 ? ENC_BATTERY_LOADED : 0); }
	override string, double GetPickupSprite() { return WeaponStatus[RDProp_Battery] >= 0 ? "RDLGZ0" : "RDLGY0", 0.5; }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[RDProp_Battery] = GetDefaultByType('HDBattery').MaxPerUnit;
	}
	override void LoadoutConfigure(string input)
	{
		if (GetLoadoutVar(input, "lockon", 1) > 0)
		{
			WeaponStatus[RDProp_Flags] |= RDF_LockOn;
		}

		InitializeWepStats(false);
	}

	override string GetHelpText()
	{
		string lockStr = WeaponStatus[RDProp_Flags] & RDF_LockOn ? " (hold to lock-on)" : "";
		return String.Format(WEPHELP_FIRE.."  Shoot%s\n"
		..(WeaponStatus[RDProp_Flags] & RDF_LockOn ? WEPHELP_ALTFIRE.."  Cancel lockon\n" : "")
		..WEPHELP_RELOADRELOAD
		..WEPHELP_UNLOADUNLOAD, lockStr);
	}

	override string PickupMessage()
	{
		string lockStr = WeaponStatus[RDProp_Flags] & RDF_LockOn ? Stringtable.localize("$PICKUP_REDLINE_LOCKON") : "";

		return Stringtable.localize("$PICKUP_REDLINE_PREFIX")..lockStr..Stringtable.localize("$TAG_REDLINE")..Stringtable.localize("$PICKUP_REDLINE_SUFFIX");
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			sb.DrawBattery(-60, -4, sb.DI_SCREEN_CENTER_BOTTOM, reloadorder: true);
			sb.DrawNum(hpl.CountInv("HDBattery"), -52, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if (hdw.WeaponStatus[RDProp_Flags] & RDF_Overheated)
		{
			sb.DrawString(sb.pNewSmallFont, "OVERHEAT", (-20, -22), sb.DI_TEXT_ALIGN_RIGHT | sb.DI_SCREEN_CENTER_BOTTOM, Font.CR_RED, scale: (0.5, 0.5));
		}

		if (WeaponStatus[RDProp_Battery] > 0)
		{
			for (int i = 0; i < WeaponStatus[RDProp_Battery]; ++i)
			{
				sb.DrawRect(-16 - 3 * (i % 10), -8 - 3 * (i / 10), -2, -2);
			}
		}
		else if (WeaponStatus[RDProp_Battery] == 0)
		{
			sb.DrawString(sb.mAmountFont, "00000", (-16, -13), sb.DI_TEXT_ALIGN_RIGHT | sb.DI_SCREEN_CENTER_BOTTOM, Font.CR_DARKGRAY);
		}

		sb.DrawWepNum(WeaponStatus[RDProp_Heat], A_GetMaxHeat(), posy: -4, alwaysprecise: true);
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 16, sb.DI_SCREEN_CENTER);
		vector2 bob2 = bob * 2;
		bob2.y = clamp(bob2.y, -8, 8);
		sb.DrawImage("REDFRONT", bob2, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9);
		sb.ClearClipRect();
		sb.DrawImage("REDBACK", bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP);

		if (scopeview)
		{
			//fixed courtesy of TooFewSecrets from Discord
		
			int scaledyoffset=76;
			int scaledwidth=91;
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(-45.5 + bob.x, 30.5 + bob.y, scaledwidth, scaledwidth, sb.DI_SCREEN_CENTER);
			
			texman.setcameratotexture(hpc, "HDXCAM_ZM66", 5);
			let cam  = texman.CheckForTexture("HDXCAM_ZM66",TexMan.Type_Any);
			sb.DrawCircle(cam,(0,ScaledYOffset)+bob*3,.11,usePixelRatio:true);

			sb.DrawImage("HDXCAM_ZM66", (0, scaledyoffset) + bob, sb.DI_SCREEN_CENTER |  sb.DI_ITEM_CENTER, scale: (.5, .5));
			sb.DrawImage("SCOPHOLE", (0, scaledyoffset) + bob * 5, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, scale: (1.5, 1.5));
			Screen.SetClipRect(cx, cy, cw, ch);
			sb.DrawImage("RDLNSCOP", (0, scaledyoffset) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, scale: (1.25, 1.25));
			
		}
	}

	private action void A_CheckOverheat()
	{
		if (invoker.WeaponStatus[RDProp_Heat] > A_GetMaxHeat())
		{
			invoker.WeaponStatus[RDProp_Flags] |= RDF_Overheated;
			invoker.owner.A_StartSound("Redline/Overload", 10);
		}
	}

	private clearscope action int A_GetMaxHeat(bool raw = false)
	{
		double mult = 1.0;
		if (!raw)
		{
			if (AceCore.CheckForItem(invoker.owner, 'HDGungnir'))
			{
				mult += 0.5;
			}
		}
		return int(100 * mult);
	}

	private action void A_ClearLockon()
	{
		invoker.LockonTrigger = 0;
		invoker.LockedTargets.Clear();
	}

	static bool IsValidTarget(HDWeapon wpn, Actor trg)
	{
		if (!wpn || !wpn.owner)
		{
			return false;
		}

		let plr = HDPlayerPawn(wpn.owner);
		if (!trg || !trg.bISMONSTER || !trg.bSHOOTABLE || trg.bINVULNERABLE || trg.bFRIENDLY || trg.bBOSS || trg.Health <= 0 || trg.bCORPSE || !plr || plr.Distance3D(trg) > HDCONST_ONEMETRE * 50 || plr.player.ReadyWeapon != wpn || !plr.CheckSight(trg, SF_SEEPASTSHOOTABLELINES | SF_IGNOREVISIBILITY))
		{
			return false;
		}

		return !trg.InStateSequence(trg.CurState, trg.FindState('falldown')) && AbsAngle(plr.angle, plr.AngleTo(trg)) < 60 && AceCore.PitchTo(plr, trg, 2) < 50;
	}

	private bool HasFired;
	private int LockonTrigger;
	Array<Actor> LockedTargets;

	Default
	{
		-HDWEAPON.FITSINBACKPACK
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority 1.5;
		HDWeapon.BarrelSize 35, 1.5, 3;
		Scale 0.34;
		Tag "$TAG_REDLINE";
		HDWeapon.Refid HDLD_REDLINE;
		HDWeapon.loadoutcodes "
			\culockon - 0/1, Gives the redline lock-on capabilities.
		";
	}

	States
	{
		Spawn:
			RDLG Z -1 NoDelay
			{
				frame = (invoker.WeaponStatus[RDProp_Battery] >= 0 ? 25 : 24);
			}
			Stop;
		Ready:
			RDLG A 1
			{
				int battery = invoker.WeaponStatus[RDProp_Battery];
				if (PressingFire())
				{
					if (battery > 0 && !invoker.HasFired)
					{
						if (invoker.WeaponStatus[RDProp_Flags] & RDF_LockOn)
						{	
							if (PressingAltfire())
							{
								invoker.LockonTrigger = 0;
								A_ClearLockon();
								return;
							}
							invoker.LockonTrigger++;
							if (invoker.LockonTrigger > 6)
							{
								FLineTraceData data;
								LineTrace(angle, HDCONST_ONEMETRE * 60, pitch, TRF_NOSKY | TRF_THRUHITSCAN | TRF_THRUBLOCK, PlayerPawn(self).ViewHeight, data: data);

								if (IsValidTarget(invoker, data.HitActor))
								{
									int size = invoker.LockedTargets.Size();
									if (size < battery && invoker.LockedTargets.Find(data.HitActor) == size)
									{
										invoker.LockedTargets.Push(data.HitActor);
										RedlineLockon ind = RedlineLockon(Spawn('RedlineLockon', data.HitActor.pos));
										ind.master = invoker;
										ind.target = data.HitActor;

										double minSize = min(data.HitActor.Height, data.HitActor.Radius * 2);
										if (minSize > 30)
										{
											double extraScale = min(3.0, minSize / 30.0);
											ind.Scale += (extraScale, extraScale);
										}

										A_StartSound("Redline/LockOn", 7);
									}
								}
							}
						}
						else
						{
							invoker.HasFired = true;
							SetWeaponState('Fire');
							return;
						}
					}
					A_WeaponReady(WRF_ALL | WRF_NOFIRE);
				}
				else
				{
					if (battery > 0 && invoker.WeaponStatus[RDProp_Flags] & RDF_LockOn && invoker.LockonTrigger > 0)
					{
						invoker.LockonTrigger = 0;
						SetWeaponState('Fire');
						return;
					}
					else
					{
						invoker.HasFired = false;
					}
					A_WeaponReady(WRF_ALL | WRF_NOPRIMARY);
				}
			}
			Goto ReadyEnd;
		Select0:
			RDLG A 0;
			Goto Select0Big;
		Deselect0:
			RDLG A 0 A_ClearLockon();
			Goto Deselect0Big;
		User3:
			#### A 0 A_MagManager("HDBattery");
			Goto Ready;
		Fire:
			#### F 1 Bright
			{
				A_Light0();
				A_StartSound("Redline/Fire", CHAN_WEAPON);

				int size = invoker.LockedTargets.Size();
				if (size > 0)
				{
					Actor trgt = invoker.LockedTargets[size - 1];
					A_Face(trgt, 0, 0, flags: FAF_MIDDLE, z_ofs: trgt.height < 30 ? -(trgt.height / 2) : 0);
				}

				A_CheckOverheat();
				bool overheated = invoker.WeaponStatus[RDProp_Flags] & RDF_Overheated;

				int dmg = int(random(110, 140) * (overheated ? 1.5 : 1.0));
				A_RailAttack(dmg, 0, false, "", "", RGF_NOPIERCING | RGF_NORANDOMPUFFZ | RGF_SILENT, 0, "RedlineRayImpact"..(overheated ? "Overheated" : ""), 0, 0, HDCONST_ONEMETRE * 300, 0, 10.0, 0, "RedlineRaySegment"..(overheated ? "Overheated" : ""), player.crouchfactor < 1.0 ? 1.1 : 2);
				
				invoker.WeaponStatus[RDProp_Heat] += int((dmg / 4) * frandom(0.925, 1.05));
				invoker.WeaponStatus[RDProp_Battery] -= overheated ? 2 : 1;
				if (invoker.WeaponStatus[RDProp_Battery] < 0)
				{
					A_StartSound("weapons/plascrack", 11);
					A_StartSound("weapons/plascrack", 12);
					A_StartSound("weapons/plascrack", 13);
					A_StartSound("world/tbfar", 14);
					A_ClearLockon();
				}
				invoker.LockedTargets.Pop();

				A_AlertMonsters();

				if (size == 0)
				{
					A_MuzzleClimb(0, 0, -0.1, -0.5, -frandom(0.3, 0.6), -frandom(0.3, 0.6), -frandom(0.3, 0.6), -frandom(0.3, 0.6));
				}
			}
			#### C 1;
			#### B 1;
			#### A 4 A_JumpIf(invoker.LockedTargets.Size() > 0, 'Fire');
			Goto Ready;

		Reload:
			#### A 0
			{
				if (invoker.WeaponStatus[RDProp_Battery] >= GetDefaultByType('HDBattery').MaxPerUnit || !CheckInventory("HDBattery", 1) || HDMagAmmo.NothingLoaded(self, 'HDBattery'))
				{
					SetWeaponState("Nope");
					return;
				}
				invoker.WeaponStatus[RDProp_LoadType] = 1;
			}
			Goto RemoveBattery;
		Unload:
			#### A 0
			{
				if (invoker.WeaponStatus[RDProp_Battery] == -1)
				{
					SetWeaponState("Nope");
					return;
				}
				invoker.WeaponStatus[RDProp_LoadType] = 0;
			}
			Goto RemoveBattery;

		RemoveBattery:
			#### # 4 Offset(0, 34);
			#### # 8 Offset(0, 36)
			{
				A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
				if (invoker.WeaponStatus[RDProp_Battery] >= 0)
				{
					A_StartSound("Redline/Unlock", 8, CHANF_OVERLAP);
				}
			}
			#### # 2 Offset(0, 38) A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));
			#### # 2 Offset(0, 40)
			{
				A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2, 2.4));

				int charge = invoker.WeaponStatus[RDProp_Battery]; // [Ace] Lose fractions if you take out a non-empty battery.
				invoker.WeaponStatus[RDProp_Battery] = -1;
				A_StartSound("Redline/CellOut", 8, CHANF_OVERLAP);
				if (A_JumpIfInventory('HDBattery', 0, "null") || !PressingReload() && !PressingUnload())
				{
					HDMagAmmo.SpawnMag(self, "HDBattery", charge);
					A_SetTics(4);
				}
				else
				{
					HDMagAmmo.GiveMag(self, "HDBattery", charge);
					A_SetTics(10);
				}
			}
			#### # 4 Offset(0, 42)
			{
				if (invoker.WeaponStatus[RDProp_LoadType] == 0)
				{
					SetWeaponState("ReloadEnd");
				}
				else
				{
					A_StartSound("weapons/pocket", 8, CHANF_OVERLAP);
				}
			}
			#### # 8 Offset(2, 44);
			#### # 8 Offset(2, 46);
			#### # 8 Offset(0, 42) A_StartSound("Redline/Eject", 8, CHANF_OVERLAP);
			#### # 3 Offset(0, 36)
			{
				let bat = HDMagAmmo(FindInventory("HDBattery"));
				if (bat && bat.Amount > 0)
				{
					invoker.WeaponStatus[RDProp_Battery] = bat.TakeMag(true);
					A_StartSound("Redline/CellIn", 8, CHANF_OVERLAP);
				}
			}
			#### # 0 A_StartSound("Redline/Charge", 8, CHANF_OVERLAP);
		ReloadEnd:
			#### # 4 Offset(0, 38);
			#### # 2 Offset(0, 38);
			#### # 2 Offset(0, 36);
			#### # 2 Offset(0, 34);
			Goto Ready;
	}
}

class RedlineRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = HDRedline(Spawn("HDRedline", pos, ALLOW_REPLACE));
				if (!wpn) return;

				HDF.TransferSpecials(self, wpn);
				if (!random(0, 3)) wpn.WeaponStatus[wpn.RDProp_Flags] |= wpn.RDF_LockOn;
				wpn.InitializeWepStats(false);

				A_SpawnItemEx("HDBattery", -3, flags: SXF_NOCHECKPOSITION);
			}
			Stop;
	}
}

class RedlineRayImpact : HDActor
{
	protected virtual void ImmolateTarget()
	{
		A_GiveInventory('Heat', random(150, 400), AAPTR_TRACER);
	}

	Default
	{
		+NODAMAGETHRUST
		+FORCEDECAL
		+PUFFGETSOWNER
		+ALWAYSPUFF
		+PUFFONACTORS
		+NOINTERACTION
		+BLOODLESSIMPACT
		+FORCERADIUSDMG
		+NOBLOOD
		+HITTRACER
		Decal "RedlineScorch";
		DamageType "Hot";
	}

	States
	{
		Spawn:
			TNT1 A 5 NoDelay
			{
				A_Explode(random(15, 30), 20, XF_HURTSOURCE, false);
				A_StartSound("Redline/Impact");
				ImmolateTarget();

				for (int i = 0; i < 30; ++i)
				{
					double pitch = frandom(-85.0, 85.0);
					A_SpawnParticle(0xFF1111, SPF_RELATIVE | SPF_FULLBRIGHT, random(10, 20), random(6, 9), random(0, 359), random(0, 4), 0, 0, random(1, 5) * cos(pitch), 0, random(1, 5) * sin(pitch), 0, 0, -0.5);
				}
			}
			Stop;
	}
}

class RedlineRayImpactOverheated : RedlineRayImpact
{
	override void ImmolateTarget()
	{
		A_GiveInventory('Heat', random(300, 550), AAPTR_TRACER);
	}
}

class RedlineRaySegment : Actor
{
	override void PostBeginPlay()
	{
		if (target)
		{
			double dist = Distance3D(target);
			alpha += 0.002 * dist;
		}

		Super.PostBeginPlay();
	}

	Default
	{
		Renderstyle "Add";
		+NOINTERACTION
		+NOBLOCKMAP
		+BRIGHT
		Alpha 2.0;
	}

	States
	{
		Spawn:
			RDLR A 1 Bright A_FadeOut(0.1);
			Loop;
	}
}

class RedlineRaySegmentOverheated : RedlineRaySegment
{
	Default
	{
		Alpha 3.0;
	}
}

class RedlineLockon : Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOINTERACTION
		+BRIGHT
		Renderstyle "Add";
	}

	States
	{
		Spawn:
			RDLK A 1
			{
				let wpn = HDRedline(master);
				if (!HDRedline.IsValidTarget(wpn, target) || wpn.LockedTargets.Find(target) == wpn.LockedTargets.Size())
				{
					Destroy();
					return;
				}
				Warp(target, target.radius, 0, target.height - target.height / 4, target.AngleTo(wpn.owner), flags: WARPF_ABSOLUTEANGLE | WARPF_NOCHECKPOSITION);
				alpha = frandom(0.8, 1.2);
			}
			Loop;
	}
}
