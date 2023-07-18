class HDMajestic : HDHandgun
{
	enum MajesticFlags
	{
		MJF_JustUnload = 1, 
		MJF_Accelerator = 2
	}

	enum MajesticProperties
	{
		MJProp_Flags,
		MJProp_LoadType,
		MJProp_Mag,
		MJProp_Battery,
		MJProp_SpentRounds
	}

	override void DetachFromOwner()
	{
		if (Charge > 0)
		{
			A_FireMajestic(true);
		}
		MustCancel = false;
		A_ResetCharges();
		Super.DetachFromOwner();
	}
	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool revMJCe, bool doselect) { return GetSpareWeaponRegular(newowner, revMJCe, doselect); }
	override double GunMass()
	{
		double baseMass = 8.0;
		int mag = WeaponStatus[MJProp_Mag];
		if (mag >= 0)
		{
			baseMass += HDMajesticMag.EncMagLoaded * 0.1 + WeaponStatus[MJProp_Mag] * ENC_50SW_LOADED * 0.04;
		}
		return baseMass;
	}
	override double WeaponBulk()
	{
		double baseBulk = 60;
		int mag = WeaponStatus[MJProp_Mag];
		if (mag >= 0)
		{
			BaseBulk += HDMajesticMag.EncMagLoaded + mag * ENC_50SW_LOADED;
		}
		return baseBulk;
	}
	override string, double GetPickupSprite() { return WeaponStatus[MJProp_Mag] >= 0 ? "MJCGZ0" : "MJCGY0", 0.4; }

	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[MJProp_Mag] = HDMajesticMag.MagCapacity;
		WeaponStatus[MJProp_Battery] = 20;
		WeaponStatus[MJProp_SpentRounds] = 0;
	}

	override void LoadoutConfigure(string input)
	{
		InitializeWepStats();
		if (GetLoadoutVar(input, "accel", 1) > 0)
		{
			WeaponStatus[MJProp_Flags] |= MJF_Accelerator;
		}
	}

	override void ForceBasicAmmo()
	{
		owner.A_TakeInventory("HD500SWLightAmmo");
		owner.A_TakeInventory("HDMajesticMag");
		owner.A_GiveInventory("HDMajesticMag");
	}

	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			double oldAngle = owner.angle;
			amt = clamp(amt, 1, 10);
			if (owner.CheckInventory("HD500SWLightAmmo", 1))
			{
				owner.A_DropInventory("HD500SWLightAmmo", amt * 10);
				owner.angle += 15;
			}
			else
			{
				owner.A_DropInventory("HDMajesticMag", amt);
				owner.angle += 15;
			}
			if (owner.CheckInventory("HDBattery", 1))
			{
				owner.A_DropInventory("HDBattery", 1);
			}
			owner.angle = oldAngle;
		}
	}

	private action void A_CheckMajesticFrame()
	{
		switch (invoker.WeaponStatus[MJProp_Mag])
		{
			default: player.GetPSprite(PSP_WEAPON).frame = 0; break;
			case -1: player.GetPSprite(PSP_WEAPON).frame = 3; break;
		}
	}

	override string GetHelpText()
	{
		return WEPHELP_FIRE.." (hold)  Shoot/Charge\n"
		..WEPHELP_ALTFIRE.."  Cancel charging\n"
		..WEPHELP_FIREMODE.."  Quick-Swap (if available)\n"
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_ALTRELOAD.."  Reload battery\n"
		.."("..WEPHELP_USE..")+"..WEPHELP_UNLOAD.."  Unload mag/battery\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD;
	}

	override string PickupMessage()
	{
		string accStr = WeaponStatus[MJProp_Flags] & MJF_Accelerator ? Stringtable.localize("$PICKUP_MAJESTIC_ACCELERATOR") : "";
	
		return Stringtable.localize("$PICKUP_MAJESTIC_PREFIX")..accStr..Stringtable.localize("$TAG_MAJESTIC")..Stringtable.localize("$PICKUP_MAJESTIC_SUFFIX");
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.hudlevel == 1)
		{
			int nextMag = sb.GetNextLoadMag(HDMagAmmo(hpl.FindInventory('HDMajesticMag')));
			if (nextMag > 0)
			{
				sb.DrawImage("MJMGA0", (-44, -10), sb. DI_SCREEN_CENTER_BOTTOM, scale: (0.75, 0.75));
			}
			else
			{
				sb.DrawImage("MJMGB0", (-44, -10), sb.DI_SCREEN_CENTER_BOTTOM, alpha: nextMag ? 0.6 : 1.0, scale: (0.75, 0.75));
			}
			sb.DrawNum(hpl.CountInv('HDMajesticMag'), -39, -8, sb.DI_SCREEN_CENTER_BOTTOM); 

			sb.DrawBattery(-60, -10, sb.DI_SCREEN_CENTER_BOTTOM, reloadorder: true);
			sb.DrawNum(hpl.CountInv('HDBattery'), -55, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}
		
		if (hdw.WeaponStatus[MJProp_Mag] >= 0)
		{
			for (int i = 0; i < HDMajesticMag.MagCapacity; ++i)
			{
				double DrawAngle = i * (360.0 / HDMajesticMag.MagCapacity) - 180;
				vector2 DrawPos = (sin(drawangle), cos(DrawAngle)) * 5;
				sb.Fill(hdw.WeaponStatus[MJProp_Mag] > i ? Color(255, 240, 230, 40) : Color(200, 30, 26, 24), DrawPos.x - 24, DrawPos.y - 21, 3, 3, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER);
			}
		}
		if (hdw.WeaponStatus[MJProp_Battery] >= 0)
		{
			for (int i = 0; i < 20; ++i)
			{
				double DrawAngle = i * (360.0 / 20.0) - 180;
				vector2 DrawPos = (sin(drawangle), cos(DrawAngle)) * 10;
				sb.Fill(hdw.WeaponStatus[MJProp_Battery] > i ? Color(255, 16, 230, 16) : Color(200, 30, 26, 24), DrawPos.x - 23.5, DrawPos.y - 20.5, 2, 2, sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER);
			}

			for (int i = 0; i < Charge / (MaxCharge / Tiers); ++i)
			{
				Color col;
				switch (i)
				{
					case 0: col = Color(255, 0, 255, 0); break;
					case 1: col = Color(255, 255, 255, 0); break;
					case 2: col = Color(255, 255, 0, 0); break;
				}
				sb.Fill(col, -24, -18 - (2 * i), 3, 1, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER);
			}
		}
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = Screen.GetClipRect();
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 13, sb.DI_SCREEN_CENTER);
		vector2 bob2 = bob * 2;
		bob2.y = clamp(bob2.y, -8, 8);
		sb.DrawImage("MJTCFRNT", bob2, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9, scale: (0.8, 0.6));
		sb.SetClipRect(cx, cy, cw, ch);
		sb.DrawImage("MJTCBACK", bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, scale: (0.6, 0.7));
	}

	private action void A_ResetCharges()
	{
		for (int i = 0; i < Tiers; ++i)
		{
			invoker.HasPlayedSound[i] = false;
		}
		invoker.Charge = 0;
	}

	private action void A_FireMajestic(bool fromDrop)
	{
		// [Ace] Otherwise it freezes the game.
		if (!fromDrop)
		{
			HDFlashAlpha(128);
		}
		A_Light1();
		A_StartSound("Majestic/Fire", CHAN_WEAPON);
		A_StartSound("Majestic/Fire", CHAN_WEAPON, CHANF_OVERLAP);

		int tier = invoker.Charge / (MaxCharge / Tiers);
		HDB_500SWElectrified b = HDB_500SWElectrified(HDBulletActor.FireBullet(self, "HDB_500SWElectrified", speedfactor: frandom(0.98, 1.02) + 0.35 * tier));
		b.Tier = tier;
		A_ResetCharges();
		A_AlertMonsters();
		A_ZoomRecoil(1.15);

		double mult = invoker.ActualAmount > 1 ? 0.7 : 1.0;
		A_MuzzleClimb(-frandom(0.25, 1.8) * mult, -frandom(4.0, 6.0) * mult);

		invoker.WeaponStatus[MJProp_SpentRounds]++;
		invoker.WeaponStatus[MJProp_Mag]--;
		if (tier > 0)
		{
			invoker.WeaponStatus[MJProp_Battery]--;
		}
	}

	action void A_CheckMajesticHand()
	{
		bool right = !invoker.wronghand;
		right = right && Wads.CheckNumForName("id", 0) != -1 || !right && Wads.CheckNumForName("id", 0) == -1;
		player.GetPSprite(PSP_WEAPON).sprite = GetSpriteIndex(right ? "MJCGA0" : "MJ2GA0");
	}

	const MaxCharge = 60;
	const Tiers = 3;
	private int Charge;
	private bool HasPlayedSound[Tiers];
	private bool MustCancel;

	Default
	{
		+HDWEAPON.FITSINBACKPACK
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 2;
		Weapon.SlotPriority 3;
		HDWeapon.BarrelSize 13, 0.35, 0.5;
		Scale 0.2;
		Tag "$TAG_MAJESTIC";
		HDWeapon.Refid HDLD_MAJESTIC;
	}

	States
	{
		Spawn:
			MJCG Z -1 NoDelay
			{
				frame = (invoker.WeaponStatus[MJProp_Mag] >= 0 ? 25 : 24);
			}
			Stop;
		Ready:
			MJCG # 1
			{
				A_CheckMajesticHand();
				A_WeaponReady(WRF_NOFIRE | (invoker.Charge == 0 ? WRF_ALL : 0));
				
				if (PressingFire() && invoker.WeaponStatus[MJProp_Mag] > 0 || invoker.Charge > 0 && player.GetPSprite(PSP_WEAPON).frame == 1)
				{
					if (PressingAltFire() || invoker.WeaponStatus[MJProp_Mag] <= 0 || invoker.MustCancel)
					{
						invoker.MustCancel = true;
						A_ResetCharges();
						if (player.GetPSprite(PSP_WEAPON).frame > 0)
						{
							A_MuzzleClimb(frandom(0.05, 0.1), frandom(0.4, 0.6), 0, -frandom(0.2, 0.4));
							A_StartSound("Majestic/Hammer", 5);
							player.GetPSprite(PSP_WEAPON).frame--;
							A_WeaponOffset(0, 34);
						}
						else
						{
							invoker.MustCancel = false;
							SetWeaponState("Nope");
						}
						return;
					}

					A_TakeInventory("IsMoving");
					if (player.GetPSprite(PSP_WEAPON).frame < 2)
					{
						A_MuzzleClimb(-frandom(0.05, 0.1), -frandom(0.4, 0.6), 0, frandom(0.2, 0.4));
						A_StartSound("Majestic/Hammer", 5);
						player.GetPSprite(PSP_WEAPON).frame++;
						A_WeaponOffset(0, 34);
					}
					
					let plr = HDPlayerPawn(self);
					if (invoker.Charge < (invoker.WeaponStatus[MJProp_Battery] > 0 ? MaxCharge : 1))
					{
						invoker.Charge = min(invoker.Charge + (invoker.WeaponStatus[MJProp_Flags] & MJF_Accelerator ? 2 : 1), MaxCharge);
						int tier = invoker.Charge / (MaxCharge / Tiers);

						if (tier > 0 && !invoker.HasPlayedSound[tier - 1])
						{
							invoker.HasPlayedSound[tier - 1] = true;
							A_StartSound("Majestic/Charge", 10, CHANF_OVERLAP, pitch: 1.0 + 0.1 * (tier - 1));
						}
					}
				}
				else if (invoker.Charge > 0)
				{
					SetWeaponState('Fire');
					return;
				}
				else
				{
					A_CheckMajesticFrame();
				}
			}
			Goto ReadyEnd;
		Select0:
			MJCG A 0 A_CheckMajesticHand();
			#### A 1 A_CheckMajesticFrame();
			Goto Select0Small;
		Deselect0:
			MJCG A 0 A_CheckMajesticHand();
			#### A 1
			{
				invoker.MustCancel = false;
				A_CheckMajesticFrame();
				A_ResetCharges();
			}
			Goto Deselect0Small;
		User3:
			#### # 0 A_MagManager("HDMajesticMag");
			Goto Ready;

		Fire:
			#### B 1;
			#### A 1
			{
				HDPlayerPawn(self).gunbraced = false;
			}
			#### E 1 Bright A_FireMajestic(false);
			#### F 1;
			#### G 1;
			#### A 2 A_CheckMajesticFrame();
			Goto Ready;

		Reload:
		AltReload:
			#### # 0
			{
				A_ResetCharges();
				invoker.WeaponStatus[MJProp_Flags] &= ~MJF_JustUnload;

				int type = invoker.WeaponStatus[MJProp_LoadType] = PressingAltReload() ? 1 : 0;
				int mag = invoker.WeaponStatus[type == 1 ? MJProp_Battery : MJProp_Mag];
				bool noMags = HDMagAmmo.NothingLoaded(self, type == 1 ? 'HDBattery' : 'HDMajesticMag');

				if (noMags || mag >= (type == 1 ? GetDefaultByType('HDBattery').MaxPerUnit : HDMajesticMag.MagCapacity))
				{
					SetWeaponState("Nope");
				}
			}
			Goto RemoveMag;

		Unload:
			#### # 0
			{
				A_ResetCharges();
				invoker.WeaponStatus[MJProp_Flags] |= MJF_JustUnload;
				int type = invoker.WeaponStatus[MJProp_LoadType] = PressingUse() ? 1 : 0;
				if (invoker.WeaponStatus[type == 1 ? MJProp_Battery : MJProp_Mag] >= 0)
				{
					SetWeaponState("RemoveMag");
				}
			}
			Goto Nope;
		RemoveMag:
			#### # 2 Offset(0, 34) A_SetCrosshair(21);
			#### # 2 Offset(1, 38);
			#### # 3 Offset(2, 42);
			#### # 6 Offset(3, 46) A_StartSound(invoker.WeaponStatus[MJProp_LoadType] == 1 ? "Majestic/BatteryOut" : "Majestic/MagOut", 8, CHANF_OVERLAP);
			#### # 0
			{
				int type = invoker.WeaponStatus[MJProp_LoadType];
				int mag = invoker.WeaponStatus[type == 0 ? MJProp_Mag : MJProp_Battery];
				invoker.WeaponStatus[type == 0 ? MJProp_Mag : MJProp_Battery] = -1;
				if (mag == -1)
				{
					SetWeaponState('MagOut');
					return;
				}

				if (type == 0)
				{
					if (invoker.WeaponStatus[MJProp_SpentRounds] > 0)
					{
						A_StartSound("Majestic/Eject", 9, CHANF_OVERLAP);
					}
					for (int i = 0; i < invoker.WeaponStatus[MJProp_SpentRounds]; ++i)
					{
						Actor a = A_EjectCasing('HDSpent500',frandom(-1,2),(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),(0,0,-2));
															
						a.roll = random(0, 359);
					}
					invoker.WeaponStatus[MJProp_SpentRounds] = 0;
				}

				class<HDMagAmmo> which = type == 1 ? 'HDBattery' : 'HDMajesticMag';
				if((!PressingUnload() && !PressingReload()) || A_JumpIfInventory(which, 0, 'null'))
				{
					HDMagAmmo.SpawnMag(self, which, mag);
					SetWeaponState('MagOut');
				}
				else
				{
					HDMagAmmo.GiveMag(self, which, mag);
					A_StartSound("weapons/pocket", 9);
					SetWeaponState('PocketMag');
				}
				A_CheckMajesticFrame();
			}
		PocketMag:
			#### #### 5 Offset(0, 46) A_MuzzleClimb(frandom(-0.2, 0.8), frandom(-0.2, 0.4));
			Goto MagOut;
		MagOut:
			#### # 0
			{
				if (invoker.WeaponStatus[MJProp_Flags] & MJF_JustUnload)
				{
					SetWeaponState('ReloadEnd');
				}
				else
				{
					SetWeaponState('LoadMag');
				}
			}
		LoadMag:
			#### # 4 Offset(0, 46) A_MuzzleClimb(frandom(-0.2, 0.8), frandom(-0.2, 0.4));
			#### # 5 A_StartSound("weapons/pocket", 9);
			#### # 5 Offset(0, 46) A_MuzzleClimb(frandom(-0.2, 0.8), frandom(-0.2, 0.4));
			#### # 3;
			#### A 0
			{
				int type = invoker.WeaponStatus[MJProp_LoadType];
				let mag = HDMagAmmo(FindInventory(type == 1 ? 'HDBattery' : 'HDMajesticMag'));
				if (mag)
				{
					invoker.WeaponStatus[type == 1 ? MJProp_Battery : MJProp_Mag] = mag.TakeMag(true);
					A_StartSound(type == 1 ? "Majestic/BatteryIn" : "Majestic/MagIn", 8);
				}
			}
			Goto ReloadEnd;
		ReloadEnd:
			#### # 2 Offset(3, 46);
			#### # 1 Offset(2, 42);
			#### # 1 Offset(2, 38);
			#### # 1 Offset(1, 34);
			Goto Nope;


		Firemode:
		SwapPistols:
			#### A 0 A_SwapHandguns();
			#### A 0 A_JumpIf(player.GetPSprite(PSP_WEAPON).sprite == GetSpriteIndex("MJCGA0"), "SwapPistols2");
		SwapPistols1:
			TNT1 A 0 A_Overlay(1026, "lowerleft");
			TNT1 A 0 A_Overlay(1025, "raiseright");
			TNT1 A 5;
			MJCG A 0;
			Goto Nope;
		SwapPistols2:
			TNT1 A 0 A_Overlay(1026, "lowerright");
			TNT1 A 0 A_Overlay(1025, "raiseleft");
			TNT1 A 5;
			MJ2G A 0;
			Goto Nope;
		LowerLeft:
			MJCG # 0 A_WeaponBusy(true);
			#### # 1 Offset(-6, 38);
			#### # 1 Offset(-12, 48);
			#### # 1 Offset(-20, 60);
			#### # 1 Offset(-34, 76);
			#### # 1 Offset(-50, 86);
			stop;
		LowerRight:
			MJ2G # 0 A_WeaponBusy(true);
			#### # 1 Offset(6, 38);
			#### # 1 Offset(12, 48);
			#### # 1 Offset(20, 60);
			#### # 1 Offset(34, 76);
			#### # 1 Offset(50, 86);
			Stop;
		RaiseLeft:
			MJCG # 0 A_WeaponBusy(false);
			#### # 1 Offset(-50, 86);
			#### # 1 Offset(-34, 76);
			#### # 1 Offset(-20, 60);
			#### # 1 Offset(-12, 48);
			#### # 1 Offset(-6, 38);
			Stop;
		RaiseRight:
			MJ2G # 0 A_WeaponBusy(false);
			#### # 1 Offset(50, 86);
			#### # 1 Offset(34, 76);
			#### # 1 Offset(20, 60);
			#### # 1 Offset(12, 48);
			#### # 1 Offset(6, 38);
			Stop;
		WhyAreYouSmiling:
			#### A 0 A_WeaponBusy(true);
			#### # 1 Offset(0, 48);
			#### # 1 Offset(0, 60);
			#### # 1 Offset(0, 76);
			TNT1 A 7;
			TNT1 A 0
			{
				invoker.wronghand = !invoker.wronghand;
				A_CheckMajesticHand();
			}
			#### # 1 Offset(0, 76);
			#### # 1 Offset(0, 60);
			#### # 1 Offset(0, 48);
			Goto Nope;
	}
}

// [Ace] This needs to be a separate actor because if put on the bullet itself ArcZap acts weird and gets spawned *on the player*, which makes sense given that the bullet hasn't travelled the distance yet.
class MajesticExplosion : HDActor
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				A_StartSound("weapons/plascrack", 11);
				A_StartSound("weapons/plascrack", 12);
				A_StartSound("weapons/plascrack", 13);
				A_StartSound("world/tbfar", 14);
				A_StartSound("world/explode", 15, volume: 0.5);
				
				A_HDBlast(
					blastradius: 25 * stamina, 
					blastdamage: int(random(40, 90) * stamina), 
					blastdamagetype: "slashing");

				A_SprayDecal("MajesticScorch", 14);
				DistantQuaker.Quake(self, stamina, 35, 512, 8, 128, 256, 256);

				for (int i = 0; i < 1; ++i)
				{
					A_SpawnItemEx("WallChunker", frandom(-10, 10), frandom(-10, 10), frandom(-10, 10), flags: SXF_NOCHECKPOSITION | SXF_TRANSFERPOINTERS);
				}

				DoorDestroyer.DestroyDoor(self, frandom(1, frandom(8, 16) * stamina), frandom(1, frandom(4, 16) * stamina));

				Spawn("HDExplosion", pos + (frandom(-4, 4), frandom(-4, 4), frandom(-4, 4)), ALLOW_REPLACE);
				for (int i = 0; i < 4; ++i)
				{
					ArcZap(self, maxdamage: 128 * stamina);
				}
			}
			Stop;
	}
}

class HDB_500SWElectrified : HDB_500SW
{
	private void Kaboom(vector3 hitpos)
	{
		if (Exploded || Tier == 0)
		{
			return;
		}

		Actor exp = Spawn("MajesticExplosion", hitpos, ALLOW_REPLACE);
		exp.stamina = Tier;
		exp.target = target;
		exp.angle = angle;
		exp.pitch = pitch;
		Exploded = true;
	}

	override void OnHitActor(actor hitactor, vector3 hitpos, vector3 vu, int flags)
	{
		if (hitactor.bSHOOTABLE)
		{
			Kaboom(hitpos);
		}
		Super.OnHitActor(hitactor, hitpos, vu, flags);
	}

	override void HitGeometry(line hitline, sector hitsector, int hitside, int hitpart, vector3 vu, double lastdist)
	{
		Kaboom(pos - (0, 0, 8));
		Super.HitGeometry(hitline, hitsector, hitside, hitpart, vu, lastdist);
	}

	private bool Exploded;
	int Tier;
}

class MajesticRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = HDMajestic(Spawn("HDMajestic", pos, ALLOW_REPLACE));
				if (!wpn) return;

				HDF.TransferSpecials(self, wpn);
				if (!random(0, 4)) wpn.WeaponStatus[wpn.MJProp_Flags] |= wpn.MJF_Accelerator;
				wpn.InitializeWepStats(false);

				A_SpawnItemEx("HDMajesticMag", -1, flags: SXF_NOCHECKPOSITION);
			}
			Stop;
	}
}

class HDMajesticMag : HDMagAmmo
{
	override string PickupMessage()
	{
		return Stringtable.localize("$PICKUP_MAJESTICMAG_PREFIX")..Stringtable.localize("$TAG_MAJESTICMAG")..Stringtable.localize("$PICKUP_MAJESTICMAG_SUFFIX");
	}

	override string, string, name, double GetMagSprite(int thismagamt)
	{
		return String.Format("MJMG%c0", 67 + thismagamt), "SWRNA0", "HD500SWLightAmmo", 0.5;
	}

	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("HDMajestic");
	}

	const MagCapacity = 6;
	const EncMag = 8;
	const EncMagEmpty = EncMag * 0.4;
	const EncMagLoaded = EncMag * 0.6;

	Default
	{
		HDMagAmmo.MaxPerUnit 6;
		HDMagAmmo.InsertTime 9;
		HDMagAmmo.ExtractTime 6;
		HDMagAmmo.RoundType "HD500SWLightAmmo";
		HDMagAmmo.RoundBulk ENC_50SW_LOADED;
		HDMagAmmo.MagBulk EncMagEmpty;
		Tag "$TAG_MAJESTIC";
		HDPickup.RefId HDLD_MAJESTICMAG;
		Scale 0.25;
	}

	States
	{
		Spawn:
			MJMG A -1;
			Stop;
		SpawnEmpty:
			MJMG B -1
			{
				bROLLSPRITE = true;
				bROLLCENTER = true;
				roll = randompick(0, 0, 0, 0, 2, 2, 2, 2, 1, 3) * 90;
			}
			Stop;
	}
}
