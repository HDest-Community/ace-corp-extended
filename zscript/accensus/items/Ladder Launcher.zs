class LadderLauncher : HDWeapon
{
	enum LadderWeaponFlags
	{
		LWFLAG_LOADED = 1,
		LWFLAG_JUSTUNLOAD
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) {return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass() { return WeaponStatus[0] & LWFLAG_LOADED ? 6 : 4; }
	override double WeaponBulk() { return 90 + (WeaponStatus[0] & LWFLAG_LOADED ? ENC_LADDER / 3 : 0); }
	override string, double GetPickupSprite() { return "LLCHZ0", 1.0; }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[0] |= LWFLAG_LOADED;
	}
	override void LoadoutConfigure(string input)
	{
		InitializeWepStats(false);
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.hudlevel == 1)
		{
			sb.DrawImage("LADDD0", (-52, -4), sb.DI_SCREEN_CENTER_BOTTOM, scale: (0.6, 0.6));
			sb.DrawNum(hpl.CountInv("PortableLadder"), -45, -8, sb.DI_SCREEN_CENTER_BOTTOM);
		}

		if (hdw.WeaponStatus[0] & LWFLAG_LOADED)
		{
			sb.DrawRect(-21, -13, 5, 3);
		}
	}
	override string GetHelpText()
	{
		return WEPHELP_FIRESHOOT
		..WEPHELP_RELOADRELOAD
		..WEPHELP_UNLOADUNLOAD;
	}
	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		sb.DrawGrenadeLadder(0, bob);
	}

	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			owner.A_DropInventory("PortableLadder", 1);
		}
	}

	action void A_FireLadder()
	{
		A_StartSound("weapons/grenadeshot", CHAN_WEAPON, CHANF_OVERLAP);
		let ggg = spawn("LadderProjectile", pos + GunPos((0, 0, -4)), ALLOW_REPLACE);
		ggg.angle=angle;
		ggg.pitch=pitch - 2;
		ggg.target=self;
		ggg.master=self;
		ggg.translation = invoker.owner.translation;
	}

	Default
	{
		-HDWEAPON.FITSINBACKPACK
		+WEAPON.NOAUTOFIRE
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 9;
		Weapon.SlotPriority 0;
		Scale 0.6;
		Inventory.PickupMessage "$PICKUP_LADDERLAUNCHER";
		HDWeapon.BarrelSize 24, 3.1,  3;
		Tag "$TAG_LADDERLAUNCHER";
		HDWeapon.Refid "llc";
	}

	States
	{
		Spawn:
			LLCH Z -1;
			Stop;
		Select0:
			LLCH A 0;
			Goto Select0Small;
		Deselect0:
			LLCH A 0;
			Goto Deselect0Small;
		Ready:
			LLCH A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER3 | WRF_ALLOWUSER4);
			Goto ReadyEnd;
		Fire:
			LLCH B 0 A_JumpIf(invoker.WeaponStatus[0] & LWFLAG_LOADED, "ReallyShoot");
			Goto Nope;
		ReallyShoot:
			LLCH A 1
			{
				A_ZoomRecoil(0.9);
				A_FireLadder();
				invoker.WeaponStatus[0] &= ~LWFLAG_LOADED;
			}
			LLCH A 1 offset(0, 37);
			LLCH B 0 A_MuzzleClimb(-frandom(2.0, 2.7), -frandom(3.4, 5.2));
			Goto Nope;
		LoadCommon:
			LLCH B 1 offset(2, 36) A_StartSound("weapons/rockopen", 8);
			LLCH C 1 offset(4, 42) A_MuzzleClimb(-frandom(1.2, 2.4),  frandom(1.2, 2.4));
			LLCH C 1 offset(10, 50);
			LLCH C 2 offset(12, 60) A_MuzzleClimb(-frandom(1.2, 2.4), frandom(1.2,  2.4));
			LLCH C 3 offset(13, 72) A_StartSound("weapons/rockopen2", 8, CHANF_OVERLAP);
			LLCH D 3 offset(14, 74);
			LLCH D 3 offset(11, 76) A_StartSound("weapons/pocket",  9);
			LLCH D 7 offset(10, 72);
			LLCH D 0
			{
				if (health < 40)
				{
					A_SetTics(7);
				}
				else if(health < 60)
				{
					A_SetTics(3);
				}
			}
			LLCH D 4 offset(12, 74) A_StartSound("weapons/rockreload", 8);
			LLCH D 2 offset(10, 72)
			{
				if (invoker.WeaponStatus[0] & LWFLAG_JUSTUNLOAD)
				{
					if(!(invoker.WeaponStatus[0] & LWFLAG_LOADED))
					{
						SetWeaponState("ReadyEnd");
					}
					else
					{
						invoker.WeaponStatus[0] &= ~LWFLAG_LOADED;
						if((!PressingUnload() && !PressingReload()) || A_JumpIfInventory("PortableLadder", 0, "null"))
						{
							A_SpawnItemEx("PortableLadder", 10, 0, height - 16, vel.x, vel.y, vel.z + 2, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION);
						}
						else
						{
							A_GiveInventory("PortableLadder", 1);
							A_StartSound("weapons/pocket",9);
							A_SetTics(4);
						}
					}
				}
				else
				{
					if (invoker.WeaponStatus[0] & LWFLAG_LOADED || !CheckInventory("PortableLadder", 1))
					{
						SetWeaponState("ReloadEnd");
					}
					else
					{
						A_TakeInventory("PortableLadder", 1, TIF_NOTAKEINFINITE);
						invoker.WeaponStatus[0] |= LWFLAG_LOADED;
						A_SetTics(5);
					}
				}
			}
		ReloadEnd:
			LLCH D 1 offset(12, 80);
			LLCH D 1 offset(11, 88);
			LLCH D 1 offset(10, 90) A_StartSound("weapons/rockopen2",  8);
			LLCH D 1 offset(10, 94);
			TNT1 A 4;
			LLCH D 0 A_StartSound("weapons/rockopen", 8,  CHANF_OVERLAP);
			LLCH C 1 offset(8, 78);
			LLCH C 1 offset(8, 66);
			LLCH C 1 offset(8, 52);
			LLCH B 1 offset(4, 40);
			LLCH B 1 offset(2, 34);
			Goto Ready;
		Reload:
			LLCH B 0 A_JumpIf(invoker.WeaponStatus[0] & LWFLAG_LOADED || !CheckInventory("PortableLadder", 1), "Nope");
			LLCH B 0
			{
				invoker.WeaponStatus[0] &= ~LWFLAG_JUSTUNLOAD;
			}
			Goto LoadCommon;
		Unload:
			LLCH B 0
			{
				if (!(invoker.WeaponStatus[0] & LWFLAG_LOADED))
				{
					setweaponstate("Nope");
				}
				else
				{
					invoker.WeaponStatus[0] |= LWFLAG_JUSTUNLOAD;
				}
			}
			Goto LoadCommon;
		}
}

class LadderProjectile : SlowProjectile
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		A_ChangeVelocity(speed * cos(pitch), 0, speed * sin(-pitch), CVF_RELATIVE);
	}

	Default
	{
		-NOEXTREMEDEATH
		-NOTELEPORT
		+BLOODLESSIMPACT
		Height 2;
		Radius 2;
		Scale 0.7;
		Speed 60;
		Mass 600;
		Accuracy 0;
		WoundHealth 0;
		Obituary "$OB_LADDERLAUNCHER";
		Stamina 5;
	}

	States
	{
		Spawn:
			LADD D -1;
			Stop;
		Death:
			TNT1 A 1
			{
				FLineTraceData data;
				LineTrace(angle, 16, pitch, TRF_THRUACTORS, height / 2, data: data);
				
				vector2 off = Vec2Angle(-16, 0);
				bool validHitSpot = false;
				if (data.HitLine)
				{
					if (data.Hit3DFloor)
					{
						validHitSpot = abs(data.Hit3DFloor.top.ZAtPoint(off) - pos.z) < 20;
					}
					else
					{
						Sector s = data.HitLine.frontsector == CurSector ? data.HitLine.backsector : data.HitLine.frontsector;
						if (s)
						{
							validHitSpot = abs(s.FloorPlane.ZAtPoint(off) - pos.z) < 20;
						}
					}
				}
				
				if (validHitSpot)
				{
					bool success; Actor a;
					[success, a] = A_SpawnItemEx("HDLadderTop", -16, 0, 0, angle: 180, flags: SXF_NOCHECKPOSITION | SXF_ORIGINATOR | SXF_SETMASTER);
					if (a)
					{
						a.TryMove(a.pos.xy, 1);
					}
				}
				else
				{
					A_SpawnItemEx("PortableLadder", -10, 0, height - 18, 0, 0, 2 + frandom(1.0, 2.0), 0, SXF_NOCHECKPOSITION);
				}
			}
			Goto Super::Death;
	}
}