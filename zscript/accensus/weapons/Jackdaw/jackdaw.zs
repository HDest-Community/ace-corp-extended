class HDJackdaw : HDWeapon
{
	enum JackdawFlags
	{
		JDF_JustUnload = 1,
		JDF_RapidFire = 2
	}

	enum JackdawProperties
	{
		JDProp_Flags,
		JDProp_Chamber,
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override double GunMass() { return 6.5; }
	override double WeaponBulk() { return 105; }
	override string, double GetPickupSprite() { return "JDWGZ0", 0.52; }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[JDProp_Chamber] = 2;
	}
	override void LoadoutConfigure(string input)
	{
		if (GetLoadoutVar(input, "rapid", 1) > 0)
		{
			WeaponStatus[JDProp_Flags] |= JDF_RapidFire;
		}

		InitializeWepStats(false);
	}

	override string GetHelpText()
	{
		return WEPHELP_FIRESHOOT;
	}

	override string PickupMessage()
	{
		string RapidStr = WeaponStatus[JDProp_Flags] & JDF_RapidFire ? Stringtable.localize("$PICKUP_JACKDAW_RAPIDFIRE") : "";

		return Stringtable.localize("$PICKUP_JACKDAW_PREFIX")..RapidStr..Stringtable.localize("$TAG_JACKDAW")..Stringtable.localize("$PICKUP_JACKDAW_SUFFIX");
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (hdw.WeaponStatus[JDProp_Chamber] == 2)
		{
			sb.DrawRect(-22, -8, 6, 3);
			sb.DrawRect(-23, -7, 1, 1);
		}
	}

	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot)
	{
		int cx, cy, cw, ch;
		[cx, cy, cw, ch] = Screen.GetClipRect();
		sb.SetClipRect(-16 + bob.x, -4 + bob.y, 32, 16, sb.DI_SCREEN_CENTER);
		vector2 bob2 = bob * 2;
		bob2.y = clamp(bob2.y, -8, 8);
		sb.DrawImage("JDWFRONT", bob2, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, alpha: 0.9);
		sb.SetClipRect(cx, cy, cw, ch);
		sb.DrawImage("JDWBACK", (0, -7) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP);
	}

	private action void A_TryLoadChamber()
	{
		if (invoker.Storage && invoker.Storage.owner == invoker.owner && invoker.Storage.Storage)
		{
			if (invoker.WeaponStatus[JDProp_Chamber] == 0)
			{
				if (invoker.AmmoReserve && invoker.AmmoReserve.Amounts.Size() > 0 && invoker.AmmoReserve.Amounts[0] > 0)
				{
					invoker.Storage.Storage.RemoveItem(invoker.AmmoReserve, null, null, 1);
					invoker.WeaponStatus[JDProp_Chamber] = 2;
				}
				else
				{
					invoker.AmmoReserve = null;
					if (A_FindStorage())
					{
						A_TryLoadChamber();
					}
				}
			}
			return;
		}
		if (A_FindStorage())
		{
			A_TryLoadChamber();
		}
	}

	private action bool A_FindStorage()
	{
		for (Inventory Next = Inv; Next; Next = Next.Inv)
		{
			let bp = HDBackpack(Next);
			if (bp && bp.Storage)
			{
				let nma = bp.Storage.Find('HDPistolAmmo');
				if (nma && nma.Amounts.Size() > 0 && nma.Amounts[0] > 0)
				{
					invoker.AmmoReserve = nma;
					invoker.Storage = bp;
					return true;
				}
			}
		}
		return false;
	}

	private HDBackpack Storage;
	private StorageItem AmmoReserve;

	Default
	{
		+HDWEAPON.FITSINBACKPACK
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 4;
		Weapon.SlotPriority 1.5;
		HDWeapon.BarrelSize 25, 2, 4;
		Scale 0.28;
		Tag "$TAG_JACKDAW";
		HDWeapon.Refid HDLD_JACKDAW;
		HDWeapon.loadoutcodes "
			\curapid - 0/1, Locks the weapon to hyperburst RoF, though keeps it in full-auto.
		";
	}

	States
	{
		Spawn:
			JDWG Z -1;
			Stop;
		Ready:
			JDWG A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER3);
			Goto ReadyEnd;
		Select0:
			JDWG A 0;
			Goto Select0Big;
		Deselect0:
			JDWG A 0;
			Goto Deselect0Big;

		AltFire:
			Goto ChamberManual;

		Fire:
			JDWG A 1
			{
				if (invoker.WeaponStatus[JDProp_Chamber] < 2)
				{
					SetWeaponState("ChamberManual");
					return;
				}
			}
			JDWF A 2
			{
				if (invoker.WeaponStatus[JDProp_Flags] & JDF_RapidFire)
				{
					A_SetTics(1);
				}

				let Proj = HDBulletActor.FireBullet(self, "HDB_9", spread: 2.0, speedfactor: 1.15);
				if (frandom(24, ceilingz - floorz) < Proj.speed * 0.1)
				{
					A_AlertMonsters(250);
				}
				invoker.WeaponStatus[JDProp_Chamber] = 1;
				A_StartSound("Jackdaw/Fire", CHAN_WEAPON, volume: 0.7);
				A_ZoomRecoil(0.995);
				A_MuzzleClimb(-frandom(0.1, 0.12), -frandom(0.15, 0.18), -frandom(0.1, 0.12),-frandom(0.15, 0.18));
			}
			JDWG A 0
			{
				if (invoker.WeaponStatus[JDProp_Chamber] == 1)
				{
					//A_EjectCasing("HDSpent9mm", 10, -frandom(79, 81), frandom(7, 7.5));
					A_EjectCasing("HDSpent9mm",frandom(-1,2),(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),(0,0,-2));
					invoker.WeaponStatus[JDProp_Chamber] = 0;
				}
				A_TryLoadChamber();
			}
			Goto Ready;

		ChamberManual:
			JDWG A 0 A_JumpIf(invoker.WeaponStatus[JDProp_Chamber] == 2, "Nope");
			JDWG A 2 Offset(2, 34);
			JDWG A 4 Offset(3, 38) A_StartSound("Jackdaw/BoltPull", 8, CHANF_OVERLAP);
			JDWG A 5 Offset(4, 44)
			{
				if (invoker.WeaponStatus[JDProp_Chamber] == 1)
				{
					//A_EjectCasing("HDSpent9mm", 10, -frandom(79, 81), frandom(7, 7.5));
					A_EjectCasing("HDSpent9mm",frandom(-1,2),(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),(0,0,-2));
					invoker.WeaponStatus[JDProp_Chamber] = 0;
				}

				A_WeaponBusy();
				A_TryLoadChamber();
			}
			JDWG A 2 Offset(3, 38);
			JDWG A 2 Offset(2, 34);
			JDWG A 2 Offset(0, 32);
			Goto Nope;
	}
}

class JackdawRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = HDJackdaw(Spawn("HDJackdaw", pos, ALLOW_REPLACE));
				if (!wpn) return;

				HDF.TransferSpecials(self, wpn);
				if (!random(0, 3)) wpn.WeaponStatus[wpn.JDProp_Flags] |= wpn.JDF_RapidFire;
				wpn.InitializeWepStats(false);
			}
			Stop;
	}
}
