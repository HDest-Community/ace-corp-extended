class SecretLocation
{
	static SecretLocation Create(Actor a, Sector s)
	{
		SecretLocation loc = new('SecretLocation');
		if (a)
		{
			loc.Thing = a;
			loc.Pos = a.pos;
			return loc;
		}
		if (s)
		{
			loc.Sec = s;
			loc.Pos = (s.centerspot, s.floorplane.ZAtPoint(s.centerspot));
			return loc;
		}
		return null; // [Ace] How? Why!?
	}

	Actor Thing;
	Sector Sec;
	vector3 Pos;
}

class HDSecretFinder : HDWeapon
{
	enum SFNProperty
	{
		SFNProp_Flags,
		SFNProp_UseOffset,
		SFNProp_Battery,
		SFNProp_DrainTicker,
		SFNProp_Range
	}

	action void A_AddOffset(int ofs)
	{
		invoker.WeaponStatus[SFNProp_UseOffset] += ofs;
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner , bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override string, double GetPickupSprite() { return WeaponStatus[SFNProp_Battery] > 0 && Active ? "FNDRA0" : "FNDRE0", 0.3; }
	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_RELOAD..Stringtable.Localize("$SFNDR_HELPTEXT_1")
		..LWPHELP_UNLOAD..Stringtable.Localize("$SFNDR_HELPTEXT_2")
		..LWPHELP_ZOOM..Stringtable.Localize("$SFNDR_HELPTEXT_3")
		..LWPHELP_FIREMODE.."+"..LWPHELP_UPDOWN..Stringtable.Localize("$SFNDR_HELPTEXT_4");
	}
	override double WeaponBulk() { return 15 + (WeaponStatus[SFNProp_Battery] >= 0 ? ENC_BATTERY_LOADED : 0); }
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[SFNProp_Battery] = 20;
		WeaponStatus[SFNProp_Range] = 20;
	}

	override void PreTravelled()
	{
		HasScanned = false;
		Locations.Clear();
	}

	override void Tick()
	{
		Super.Tick();

		if (owner)
		{
			Icon = TexMan.CheckForTexture(GetPickupSprite(), TexMan.Type_Any);
		}
		
		if (!owner || WeaponStatus[SFNProp_Battery] <= 0)
		{
			Active = false;
			return;
		}

		if (Active && WeaponStatus[SFNProp_Battery] > 0)
		{
			if (++WeaponStatus[SFNProp_DrainTicker] > int(35 * 60 * (20.0 / WeaponStatus[SFNProp_Range])))
			{
				WeaponStatus[SFNProp_Battery]--;
				WeaponStatus[SFNProp_DrainTicker] = 0;
			}
		}

		if (Locations.Size() == 0 && !HasScanned)
		{
			HasScanned = true;
			ThinkerIterator it = ThinkerIterator.Create('Actor', STAT_DEFAULT);
			Actor a;
			while ((a = Actor(it.Next())))
			{
				if (a.bCOUNTSECRET)
				{
					Locations.Push(SecretLocation.Create(a, null));
				}
			}

			for (int i = 0; i < level.Sectors.Size(); ++i)
			{
				if (level.Sectors[i].IsSecret())
				{
					Locations.Push(SecretLocation.Create(null, level.Sectors[i]));
				}
			}
		}

		if (!Active)
		{
			return;
		}

		double closestDist = int.Max;
		for (int i = 0; i < Locations.Size(); ++i)
		{
			if (!Locations[i].Sec && !Locations[i].Thing || Locations[i].Sec && !Locations[i].Sec.IsSecret() && Locations[i].Sec.WasSecret())
			{
				Locations[i].Destroy();
				Locations.Delete(i--);
				continue;
			}

			double dist = level.Vec3Diff(owner.pos, Locations[i].Pos).length();
			if (dist < closestDist)
			{
				closestDist = dist;
			}
		}

		if (Locations.Size() > 0 && closestDist < HDCONST_ONEMETRE * WeaponStatus[SFNProp_Range])
		{
			int freq = int(max(5, 105 * (closestDist / (HDCONST_ONEMETRE * WeaponStatus[SFNProp_Range]))));
			if (++PingTicker >= freq)
			{
				owner.A_StartSound("SecretFinder/Ping", 25, volume: 0.4, attenuation: 1.5);
				PingTicker = 0;
			}
		}
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		vector2 bob = hpl.wepbob * 0.3;
		bob.y += WeaponStatus[SFNProp_UseOffset];
		
		sb.DrawImage(GetPickupSprite(), bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, box: (50, 50), scale: (2, 2));
		int bat = hdw.WeaponStatus[SFNProp_Battery];
		if (bat >= 0)
		{
			sb.DrawImage(AceCore.GetBatteryColor(bat), (0, 30) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_TOP, scale: (2.0, 2.0));
		}
		sb.DrawString(sb.pSmallFont, "\c[White]Range:\c- "..sb.FormatNumber(WeaponStatus[SFNProp_Range], 1, 2), (20, -3) + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_SAPPHIRE);
	}

	override int GetSbarNum(int flags)
	{
		let hud = HDStatusBar(StatusBar);
		hud.SavedColour = Active ? Font.CR_GREEN : Font.CR_RED;
		return int(Active);
	}

	private bool Active;
	private int PingTicker;
	private transient bool HasScanned;
	private transient Array<SecretLocation> Locations;

	Default
	{
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		-HDWEAPON.DROPTRANSLATION
		+HDWEAPON.FITSINBACKPACK
		HDWeapon.RefID "fdr";
		Inventory.Icon "FNDRA0";
		Inventory.PickupMessage "$PICKUP_SECRETFINDER";
		Inventory.PickupSound "weapons/pocket";
		Tag "$TAG_SECRETFINDER";
		Scale 0.20;
	}

	States
	{
		Spawn:
			FNDR E -1;
			Stop;
		Select:
			TNT1 A 0 A_AddOffset(100);
			Goto Super::Select;
		Ready:
			TNT1 A 1
			{
				if (PressingUser3())
				{
					A_MagManager("HDBattery");
					return;
				}

				int off = invoker.WeaponStatus[SFNProp_UseOffset];
				if (off > 0)
				{
					invoker.WeaponStatus[SFNProp_UseOffset] = off * 2 / 3;
				}

				if (JustPressed(BT_ZOOM) && invoker.WeaponStatus[SFNProp_Battery] > 0)
				{
					invoker.Active = !invoker.Active;
					A_StartSound("SecretFinder/"..(invoker.Active ? "Beep" : "Unbeep"), 15, CHANF_OVERLAP);
					invoker.PingTicker = 0;
				}

				if (PressingFiremode())
				{
					if (JustPressed(BT_ATTACK))
					{
						invoker.WeaponStatus[SFNProp_Range]++;
					}
					else if (JustPressed(BT_ALTATTACK))
					{
						invoker.WeaponStatus[SFNProp_Range]--;
					}
					int amt = GetMouseY(true);
					if (amt != 0)
					{
						invoker.WeaponStatus[SFNProp_Range] += int(ceil(amt / 64.0));
					}
					invoker.WeaponStatus[SFNProp_Range] = clamp(invoker.WeaponStatus[SFNProp_Range], 5, 60);
				}
				else
				{
					A_WeaponReady(WRF_ALL & ~WRF_ALLOWUSER2);
				}
			}
			Goto ReadyEnd;
		Unload:
			TNT1 A 20;
			TNT1 A 5
			{
				int bat = invoker.WeaponStatus[SFNProp_Battery];
				if (bat < 0)
				{
					return;
				}
				if (PressingUnload() || PressingReload())
				{
					HDBattery.GiveMag(self, "HDBattery", bat);
					A_StartSound("weapons/pocket", 9);
					A_SetTics(20);
				}
				else
				{
					HDBattery.SpawnMag(self, "HDBattery", bat);
				}
				invoker.WeaponStatus[SFNProp_Battery] = -1;
			}
			Goto ReloadEnd;
		Reload:
			TNT1 A 14 A_StartSound("weapons/pocket", 9);
			TNT1 A 5
			{
				if (invoker.WeaponStatus[SFNProp_Battery] >= 0)
				{
					return;
				}
				let bat = HDMagAmmo(FindInventory("HDBattery"));
				if (!bat)
				{
					return;
				}
				invoker.WeaponStatus[SFNProp_Battery] = bat.TakeMag(true);
				A_StartSound("weapons/vulcopen1", 8, CHANF_OVERLAP);
			}
			Goto ReloadEnd;
		ReloadEnd:
			TNT1 A 6;
			Goto ready;
	}
}
