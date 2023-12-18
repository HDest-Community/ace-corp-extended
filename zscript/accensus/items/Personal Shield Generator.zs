class HDPersonalShieldGenerator : HDWeapon
{
	enum PSlags
	{
		PSF_Elemental = 1,
		PSF_Medical = 2,
		PSF_Shocking = 4,
		PSF_Cloaking = 8, // [Ace] Why yes, I like my technology overpowered, how can you tell?
		PSF_Overloaded = 16
	}

	enum PSProperties
	{
		PSProp_Flags,
		PSProp_UseOffset,
		PSProp_Battery1,
		PSProp_Battery2,
		PSProp_Battery3,
		PSProp_Flux,
		PSProp_HardFlux,
		PSProp_Degradation,
		PSProp_Mode,
		PSProp_UpgradePoints
	}

	action void A_AddOffset(int ofs)
	{
		invoker.WeaponStatus[PSProp_UseOffset] += ofs;
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner , bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override string, double GetPickupSprite()
	{
		string main = "PSH"..min(Tiers, (WeaponStatus[PSProp_UpgradePoints]));
		return main..(GetBatteriesLoaded(1) > 0 && Enabled ? "B" : "A").."0", 0.2;
	}
	override string GetHelpText()
	{
		return WEPHELP_RELOAD.."  Reload battery\n"
		..WEPHELP_UNLOAD.."  Unload battery\n"
		..WEPHELP_FIRE.." or "..WEPHELP_ALTFIRE.."  Change slider position\n"
		..WEPHELP_ZOOM.."  Toggle on/off\n"
		..WEPHELP_FIREMODE.."+"..WEPHELP_USE.."  Strip picked up generator";
	}
	override double WeaponBulk()
	{
		return 20 + 10 * min(Tiers, (WeaponStatus[PSProp_UpgradePoints])) + GetBatteriesLoaded() * ENC_BATTERY_LOADED;
	}
	override void LoadoutConfigure(string input)
	{
		InitializeWepStats(false);
		int points = GetLoadoutVar(input, "points", 2);
		if (points > 0)
		{
			WeaponStatus[PSProp_UpgradePoints] = clamp(points, 1, Tiers);
		}
		if (GetLoadoutVar(input, "elem", 1) > 0)
		{
			WeaponStatus[PSProp_Flags] |= PSF_Elemental;
		}
		if (GetLoadoutVar(input, "medical", 1) > 0)
		{
			WeaponStatus[PSProp_Flags] |= PSF_Medical;
		}
		if (GetLoadoutVar(input, "shock", 1) > 0)
		{
			WeaponStatus[PSProp_Flags] |= PSF_Shocking;
		}
		if (GetLoadoutVar(input, "cloak", 1) > 0)
		{
			WeaponStatus[PSProp_Flags] |= PSF_Cloaking;
		}
	}
	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[PSProp_Battery1] = 20;
		WeaponStatus[PSProp_Battery2] = 20;
		WeaponStatus[PSProp_Battery3] = 20;
	}

	override void ActualPickup(Actor other, bool silent)
	{
		if (other.player && other.player.ReadyWeapon is 'HDPersonalShieldGenerator' && other.player.cmd.buttons & BT_FIREMODE)
		{
			if (WeaponStatus[PSProp_Degradation] > 15)
			{
				other.A_Log("Shield generator is too damaged to be used for parts.", true);
				return;	
			}
			let gen = HDPersonalShieldGenerator(other.FindInventory('HDPersonalShieldGenerator'));
			other.A_StartSound("PSG/Upgrade");
			other.A_Log("Shield generator was stripped for parts.", true);

			int pointsRemaining = WeaponStatus[PSProp_UpgradePoints] + 1;

			int toUpgrade = min(pointsRemaining, Tiers - gen.WeaponStatus[PSProp_UpgradePoints]);
			gen.WeaponStatus[PSProp_UpgradePoints] += toUpgrade;

			pointsRemaining -= toUpgrade;
			if (pointsRemaining > 0)
			{
				gen.WeaponStatus[PSProp_Degradation] = max(0, gen.WeaponStatus[PSProp_Degradation] - pointsRemaining);
			}

			gen.WeaponStatus[PSProp_Flags] |= WeaponStatus[PSProp_Flags];
			for (int i = PSProp_Battery1; i <= PSProp_Battery3; ++i)
			{
				if (WeaponStatus[i] >= 0)
				{
					HDMagAmmo.GiveMag(other, 'HDBattery', WeaponStatus[i]);
				}
			}
			Destroy();
			return;
		}
		Super.ActualPickup(other, silent);
	}

	override bool Use(bool pickup)
	{
		if (!pickup && owner && owner.player.cmd.buttons & BT_USE)
		{
			A_ToggleShield();
			return false;
		}
		return Super.Use(pickup);
	}

	override void DetachFromOwner()
	{
		UnCloak();
		owner.A_StopSound(18);
		Super.DetachFromOwner();
	}

	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);
		other.A_GiveInventory('HDPersonalShield');
		A_StopSound(18);
	}

	// -----------------------------------------------------------------
	// UI
	// -----------------------------------------------------------------

	override int GetSbarNum(int flags)
	{
		if (owner && !owner.player)
		{
			HDStatusBar(StatusBar).SavedColour = Enabled ? Font.CR_DARKGREEN : (WeaponStatus[PSProp_Flags] & PSF_Overloaded ? Font.CR_RED : Font.CR_YELLOW);
			return int((WeaponStatus[PSProp_Flux] / double(GetFluxCapacity())) * 100);
		}
		return Super.GetSbarNum(flags);
	}

	override string PickupMessage()
	{
		string elemStr = WeaponStatus[PSProp_Flags] & PSF_Elemental ? "n elementally protective" : "";
		string clkStr = WeaponStatus[PSProp_Flags] & PSF_Cloaking ? "cloak-enabled " : "";
		string regenStr = WeaponStatus[PSProp_Flags] & PSF_Medical ? "medical " : "";
		string shkStr = WeaponStatus[PSProp_Flags] & PSF_Shocking ? " with a shocking field" : "";
		return String.Format("You picked up a%s %s%spersonal shield generator%s.", elemStr, clkStr, regenStr, shkStr);
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		vector2 bob = hpl.wepbob * 0.3;
		int Offset = WeaponStatus[PSProp_UseOffset];
		bob.y += Offset;
		
		sb.DrawImage(GetPickupSprite(), (0, 25) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER_BOTTOM, box: (40, -1), scale:(2, 2));
		for (int i = 0; i < 3; ++i)
		{
			// The batmobile won't start.
			// Check the battery.
			// What's a tery?
			// *slap*
			int tery = WeaponStatus[PSProp_Battery1 + i];
			if (tery > -1)
			{
				string icon; int fontCol;
				[icon, fontCol] = AceCore.GetBatteryColor(tery);
				sb.DrawImage(icon, (-24, -11 + 15 * i) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_RIGHT | sb.DI_ITEM_VCENTER, box: (-1, 15));
				sb.DrawString(sb.mAmountFont, sb.FormatNumber(WeaponStatus[PSProp_Battery1 + i], 1, 2), (-22, -8 + 15 * i) + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_RIGHT, fontCol);
			}
		}

		int fontHeight = sb.pSmallFont.mFont.GetHeight() / 2;
		vector2 pos = (23, -18 - fontHeight);

		// Arc angle.
		string str = String.Format("ARC "..ArcDegrees[WeaponStatus[PSProp_Mode]]);
		sb.DrawString(sb.pSmallFont, str, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_GOLD);
		pos.y += 10;

		// Capacity.
		int fluxCap = GetFluxCapacity();
		string colSoft = WeaponStatus[PSProp_Flags] & PSF_Overloaded ? "\c[DarkRed]" : "\c[DarkGreen]";
		string colHard = WeaponStatus[PSProp_Flags] & PSF_Overloaded ? "\c[Red]" : "\c[Green]";

		str = String.Format("CAP: %s%i\c-/%s%i\c-/\c[Cyan]%i\c- \c[DarkGray](+%i)\c-", colSoft, WeaponStatus[PSProp_Flux], colHard, WeaponStatus[PSProp_HardFlux], fluxCap, fluxCap - BaseFluxCap);
		sb.DrawString(sb.pSmallFont, str, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
		pos.y += 10;

		// Flux dissipation.
		double baseRate = GetFluxDissipationRate(true);
		double adjRate = GetFluxDissipationRate();
		string col = "\c[Green]";
		if (adjRate < baseRate * 0.20)
		{
			col = "\c[Black]";
		}
		else if (adjRate < baseRate * 0.40)
		{
			col = "\c[Red]";
		}
		else if (adjRate < baseRate * 0.60)
		{
			col = "\c[Orange]";
		}
		else if (adjRate < baseRate * 0.80)
		{
			col = "\c[Yellow]";
		}

		double relative = adjRate - baseRate;
		str = String.Format("DSR: %s%.2f \c[DarkGray](%s%.2f)\c-", col, adjRate, (relative >= 0 ? "+" : ""), relative);
		sb.DrawString(sb.pSmallFont, str, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
		pos.y += 10;

		string onOffStr = Enabled ? "\c[Green]ON\c-" : "\c[Red]OFF\c-";

		if (WeaponStatus[PSProp_Flags] & PSF_Elemental)
		{
			sb.DrawString(sb.pSmallFont, "ENV: "..onOffStr, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
			pos.y += 10;
		}
		if (WeaponStatus[PSProp_Flags] & PSF_Medical)
		{
			sb.DrawString(sb.pSmallFont, "MED: "..onOffStr, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
			pos.y += 10;
		}
		if (WeaponStatus[PSProp_Flags] & PSF_Shocking)
		{
			sb.DrawString(sb.pSmallFont, "SHK: "..onOffStr, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
			pos.y += 10;
		}
		if (WeaponStatus[PSProp_Flags] & PSF_Cloaking)
		{
			string onOff = CanCloak() ? "\c[Green]ON\c-" : "\c[Red]OFF\c-";
			sb.DrawString(sb.pSmallFont, "CLK: "..onOff, pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
			pos.y += 10;
		}

		// Status.
		sb.DrawString(sb.pSmallFont, Enabled ? "\c[Green]Enabled\c-" : "\c[Red]Disabled\c-", pos + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT);
	}

	// -----------------------------------------------------------------
	// TICKER
	// -----------------------------------------------------------------

	override void Tick()
	{
		if (IsFrozen())
		{
			return;
		}

		Super.Tick();

		if (!CoreHandler)
		{
			CoreHandler = AceCoreHandler(EventHandler.Find('AceCoreHandler'));
		}

		for (int i = 0; i < CoreHandler.Requests.Size(); ++i)
		{
			InterfaceRequest req = CoreHandler.Requests[i];
			if (req.Receiver == self)
			{
				switch (req.RequestName)
				{
					case 'OverloadPsg':
					{
						BuildUpFlux(GetFluxCapacity(), GetFluxCapacity());
						req.Remove(); i--;
						break;
					}
					case 'InflictEmpDamage':
					{
						if (Enabled)
						{
							BuildUpFlux(req.Arg.ToInt(), req.Arg.ToInt());
						}
						req.Remove(); i--;
						break;
					}
					case 'VentFlux':
					{
						VentFlux(GetFluxCapacity(), GetFluxCapacity());
						req.Remove(); i--;
						break;
					}
				}
			}
		}

		Icon = TexMan.CheckForTexture(GetPickupSprite(), TexMan.Type_Any);
		ReactionTime--;

		// [Ace] Owner is an NPC, assume they're intelligent enough to know how to operate it.
		if (owner && !owner.player)
		{
			if (!(WeaponStatus[PSProp_Flags] & PSF_Overloaded))
			{
				// [Ace] Do a fake overload to prevent the dumbass from clicking the button like a retard.
				// This also simulates manually turning off the shield to prevent overloading.
				if (WeaponStatus[PSProp_Flux] >= GetFluxCapacity() * 0.75)
				{
					A_ToggleShield();
					WeaponStatus[PSProp_Flags] |= PSF_Overloaded;
				}
				else if (!Enabled)
				{
					A_ToggleShield();
				}
			}
		}

		if (WeaponStatus[PSProp_Flags] & PSF_Overloaded)
		{
			if (WeaponStatus[PSProp_Flux] == 0)
			{
				WeaponStatus[PSProp_Flags] &= ~PSF_Overloaded;
			}
			else
			{
				Enabled = false;
			}
		}

		DissipationFrac += GetFluxDissipationRate();
		if (DissipationFrac >= 1.0)
		{
			int toVentSoft = int(DissipationFrac);
			int toVentHard = 0;
			if (!Enabled && WeaponStatus[PSProp_Flux] == WeaponStatus[PSProp_HardFlux])
			{
				toVentHard = toVentSoft;
			}

			DissipationFrac -= toVentSoft;
			VentFlux(toVentSoft, toVentHard);
		}

		if (!Enabled)
		{
			Actor ptr = owner ? owner : Actor(self);
			if (WeaponStatus[PSProp_Flux] > 0)
			{
				ptr.A_StartSound("PSG/VentFlux", 18, CHANF_LOOPING);
				for (int i = 0; i < 2; ++i)
				{
					Actor a; bool success;
					[success, a] = ptr.A_SpawnItemEx('FluxSmoke', ptr.radius, 0, frandom(0, ptr.height), frandom(4.0, 5.0), 0, 0, random(0, 359), SXF_NOCHECKPOSITION);
					if (success)
					{
						a.SetShade(GetShieldColor());
					}
				}
				if (GetAge() % 7 == 0)
				{
					HDActor.HDBlast(ptr, immolateradius: HDCONST_ONEMETRE * 1.5, immolateamount: 50);
				}
			}
			else
			{
				ptr.A_StopSound(18);
			}
			UnCloak();
			return;
		}
		
		int batteries = GetBatteriesLoaded(1);
		if (batteries < 1)
		{
			Enabled = false;
		}

		if (!owner)
		{
			return;
		}

		let plr = HDPlayerPawn(owner);

		if (WeaponStatus[PSProp_Flags] & PSF_Medical)
		{
			if (GetAge() % 25 == 0)
			{
				if (plr && plr.oldwoundcount > 0)
				{
					plr.oldwoundcount--;
					plr.burncount++;
					BuildUpFlux(15, 3);
				}
				if (owner.Health < (plr ? plr.MaxHealth() : owner.GetMaxHealth()))
				{
					if (HDMobBase(owner))
					{
						HDMobBase(owner).BodyDamage--;
					}
					owner.GiveBody(1);
					BuildUpFlux(15, 3);
				}
			}
			if (plr && GetAge() % 250 == 0 && plr.burncount > 0)
			{
				plr.burncount--;
				BuildUpFlux(40, 5);
			}
		}
		if (WeaponStatus[PSProp_Flags] & PSF_Shocking && GetAge() % 4 == 0)
		{
			BlockThingsIterator it = BlockThingsIterator.Create(owner, owner.default.radius * 1.5);
			while (it.Next())
			{
				if (it.thing.Health > 0)
				{
					if (it.thing is 'Babuin' && Babuin(it.thing).latchtarget == owner)
					{
						it.thing.DamageMobj(self, owner, random(1, 20), 'Electrical');
						BuildUpFlux(5);
					}
					if (it.thing is 'NinjaPirate' && NinjaPirate(it.thing).CurState.InStateSequence(FindState('Latch')))
					{
						it.thing.DamageMobj(self, owner, random(15, 30), 'Electrical');
						BuildUpFlux(10, 2);
					}
				}
			}
		}
		if (WeaponStatus[PSProp_Flags] & PSF_Cloaking && CanCloak())
		{
			IsCloaked = true;
			owner.A_SetRenderStyle(0.2, STYLE_Translucent);
			owner.bSHADOW = true;
			owner.bCANTSEEK = true;
		}
	}

	// -----------------------------------------------------------------
	// ACTIONS
	// -----------------------------------------------------------------

	private action void A_ToggleShield()
	{
		if (invoker.ReactionTime > 0)
		{
			return;
		}

		if (!(invoker.WeaponStatus[PSProp_Flags] & PSF_Overloaded))
		{
			invoker.Enabled = !invoker.Enabled;
			if (invoker.Enabled)
			{
				invoker.owner.A_SetInventory('HDPersonalShield', 1);
			}
		}
		invoker.owner.A_StopSound(18);
		invoker.owner.A_StartSound("PSG/Toggle", 9, pitch: invoker.Enabled ? 1.0 : 0.8);
		invoker.ReactionTime = 35;
	}

	private void UnCloak()
	{
		if (!owner || !IsCloaked)
		{
			return;
		}

		owner.bSHADOW = false;
		owner.bCANTSEEK = false;
		owner.A_SetRenderStyle(1, STYLE_Normal);

		for (Inventory next = owner.Inv; next != null; next = next.Inv)
		{
			if (next is 'PowerInvisibility')
			{
				next.DoEffect();
			}
		}

		IsCloaked = false;
	}

	void BuildUpFlux(int amt, int hardAmt = 0)
	{
		Actor ptr = owner ? owner : Actor(self);

		WeaponStatus[PSProp_Flux] += amt;
		WeaponStatus[PSProp_HardFlux] += hardAmt;

		WeaponStatus[PSProp_Flux] = max(WeaponStatus[PSProp_HardFlux], WeaponStatus[PSProp_Flux]);

		if (!(WeaponStatus[PSProp_Flags] & PSF_Overloaded) && WeaponStatus[PSProp_Flux] >= GetFluxCapacity())
		{
			WeaponStatus[PSProp_Flags] |= PSF_Overloaded;
			WeaponStatus[PSProp_Degradation]++;
			for (int i = PSProp_Battery1; i <= PSProp_Battery3; ++i)
			{
				WeaponStatus[i] -= random(6, 12);
				if (WeaponStatus[i] <= -1)
				{
					WeaponStatus[i] = -1;
					ptr.A_StartSound("weapons/plascrack", 11);
					ptr.A_StartSound("weapons/plascrack", 12);
					ptr.A_StartSound("world/tbfar", 14);
				}
			}
		}
	}

	void VentFlux(int amt, int hardAmt = 0)
	{
		WeaponStatus[PSProp_HardFlux] = max(0, WeaponStatus[PSProp_HardFlux] - hardAmt);
		WeaponStatus[PSProp_Flux] = max(WeaponStatus[PSProp_HardFlux], WeaponStatus[PSProp_Flux] - amt);
	}

	// -----------------------------------------------------------------
	// INFORMATION
	// -----------------------------------------------------------------

	clearscope int GetShieldColor()
	{
		switch (WeaponStatus[PSProp_UpgradePoints])
		{
			default: return 0xFFFFFF;
			case 0: return 0xFF1111;
			case 1: return 0xFF8811;
			case 2: return 0xFFFF11;
			case 3: return 0x66FF11;
			case 4: return 0x11FFFF;
			case 5: return 0x1144FF;
			case 6: return 0x8811FF;
			case 7: return 0xFF11FF;
		}
	}

	clearscope int GetBatteriesLoaded(int minCharge = 0)
	{
		int num = 0;
		for (int i = PSProp_Battery1; i <= PSProp_Battery3; ++i)
		{
			if (WeaponStatus[i] >= minCharge)
			{
				num++;
			}
		}
		return num;
	}

	clearscope int GetFluxCapacity() const
	{
		return BaseFluxCap + 1000 * WeaponStatus[PSProp_UpgradePoints];
	}

	clearscope double GetFluxDissipationRate(bool raw = false) const
	{
		double base = 1.0 + 0.25 * WeaponStatus[PSProp_UpgradePoints];
		if (raw)
		{
			return base;
		}

		double minBatteryFac = ((WeaponStatus[PSProp_Battery1] + WeaponStatus[PSProp_Battery2] + WeaponStatus[PSProp_Battery3]) / 3.0) / 20.0;
		double overloadFac = WeaponStatus[PSProp_Flags] & PSF_Overloaded ? 2.0 : 1;
		double enabledFac = Enabled ? 0.5 : 1.0;
		double cloakFac = CanCloak() ? 0.75 : 1.0;
		double degAmt = 0.15 * WeaponStatus[PSProp_Degradation];
		return max(0.05, base * minBatteryFac * overloadFac * enabledFac * cloakFac - degAmt);
	}

	clearscope bool CanCloak() const
	{
		return Enabled && WeaponStatus[PSProp_HardFlux] < GetFluxCapacity() * 0.25;
	}

	clearscope int GetShieldArc() const
	{
		return WeaponStatus[PSProp_Mode] == 1 ? 120 : 360;
	}

	const BaseFluxCap = 1000;
	const Tiers = 7; // [Ace] Actually Tiers + 1 because it's zero-based, so Tier 0 counts as Tier 1.
	static const string ArcDegrees[] = { "([]------):\c[Green] 360 deg\c-", "(------[]):\c[Red] 120 deg\c-" };
	bool Enabled;
	private double DissipationFrac;
	private bool IsCloaked;
	private AceCoreHandler CoreHandler;

	Default
	{
		+HDWEAPON.FITSINBACKPACK
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		-HDWEAPON.DROPTRANSLATION
		Inventory.Icon "PSH0A0";
		Inventory.PickupSound "weapons/pocket";
		Inventory.PickupMessage "You picked up a personal shield generator.";
		Tag "$TAG_PSH";
		HDWeapon.RefId "psh";
		Scale 0.35;
		HDWeapon.loadoutcodes "
			\cuelem - 0/1, Adds elemental resistance to the psg.
			\cumedical - 0/1, Makes the psg slowly heal you.
			\cushock - 0/1, Makes the psg shock enemies attached to you.
			\cucloak - 0/1, Makes the psg cloak you from enemies.
		";
	}

	States
	{
		RegisterSprites:
			PSH0 A 0; PSH1 A 0; PSH2 A 0; PSH3 A 0; PSH4 A 0; PSH5 A 0; PSH6 A 0; PSH7 A 0;

		Spawn:
			PSH0 A 1
			{
				if (!invoker.owner && invoker.Enabled)
				{
					invoker.Enabled = false;
				}

				string str = invoker.GetPickupSprite();
				sprite = GetSpriteIndex(str.Left(4));
				frame = int(invoker.GetBatteriesLoaded(1) > 0 && invoker.Enabled);
			}
			Loop;
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

				if (JustPressed(BT_ATTACK) && invoker.WeaponStatus[PSProp_Mode] > 0)
				{
					A_StartSound("PSG/Adjust", 10);
					invoker.WeaponStatus[PSProp_Mode]--;
				}
				else if (JustPressed(BT_ALTATTACK) && invoker.WeaponStatus[PSProp_Mode] < 1)
				{
					A_StartSound("PSG/Adjust", 10);
					invoker.WeaponStatus[PSProp_Mode]++;
				}

				int off = invoker.WeaponStatus[PSProp_UseOffset];
				if (off > 0)
				{
					invoker.WeaponStatus[PSProp_UseOffset] = off * 2 / 3;
				}

				A_WeaponReady((WRF_ALL | WRF_NOFIRE) & ~WRF_ALLOWUSER2);
			}
			Goto ReadyEnd;
		Unload:
			TNT1 A 20;
			TNT1 A 5
			{
				int count = invoker.GetBatteriesLoaded();
				if (count == 0)
				{
					return;
				}
				int last = invoker.WeaponStatus[PSProp_Battery1 + count - 1];
				if (PressingUnload() || PressingReload())
				{
					HDBattery.GiveMag(self, "HDBattery", last);
					A_StartSound("weapons/pocket", 9);
					A_SetTics(20);
				}
				else
				{
					HDBattery.SpawnMag(self, "HDBattery", last);
				}
				invoker.WeaponStatus[PSProp_Battery1 + count - 1] = -1;
			}
			Goto ReloadEnd;
		Reload:
			TNT1 A 14 A_StartSound("weapons/pocket", 9);
			TNT1 A 5
			{
				let bat = HDBattery(FindInventory('HDBattery'));
				int count = invoker.GetBatteriesLoaded();
				if (!bat || count == 3)
				{
					return;
				}
				invoker.WeaponStatus[PSProp_Battery1 + count] = bat.TakeMag(true);
				A_StartSound("weapons/vulcopen1", 8, CHANF_OVERLAP);
			}
			Goto ReloadEnd;
		Zoom:
			TNT1 A 1 A_ToggleShield();
			Goto Nope;
		ReloadEnd:
			TNT1 A 6;
			Goto Ready;
	}
}

class PsgRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let psg = HDPersonalShieldGenerator(Spawn('HDPersonalShieldGenerator', pos));
				HDF.TransferSpecials(self, psg);

				if (!random[psgrand](0, 5))
				{
					psg.WeaponStatus[psg.PSProp_Flags] |= (1 << random[psgrand](0, 3));
				}
				psg.InitializeWepStats(false);
			}
			Stop;
	}
}

class HDPersonalShield : HDDamageHandler
{
	override void AttachToOwner(Actor other)
	{
		Amount = 0;
		Super.AttachToOwner(other);
	}

	// -----------------------------------------------------------------
	// DAMAGE HANDLING
	// -----------------------------------------------------------------

	override int, Name, int, double, int, int, int HandleDamage(int damage, Name mod, int flags, Actor inflictor, Actor source, double towound, int toburn, int tostun, int tobreak)
	{
		bool env = SGen.WeaponStatus[SGen.PSProp_Flags] & SGen.PSF_Elemental;

		// [Ace] The only reason for this break of code styling consistency is because otherwise you'd need to prepare for the long and arduous journey to scroll horizontally.
		if (Amount == 0 || !owner || (flags & (DMG_NO_FACTOR | DMG_FORCED)) || !inflictor || inflictor == owner || inflictor is 'HDBulletActor'
			|| mod == 'bleedout' || (!env && (mod == 'hot' || mod == 'cold')) || mod == 'maxhpdrain' || mod == 'internal' || mod == 'holy' || mod == 'staples' || mod == 'Slime'
			|| AbsAngle(owner.angle, owner.AngleTo(inflictor)) > SGen.GetShieldArc() / 2.0
			|| source && source.bISMONSTER && owner.Distance2D(source) < (owner.radius * 2 + source.meleerange))
		{
			/*if (inflictor == owner) { Console.Printf("self damage"); }
			if (mod == 'bleedout' || (!env && (mod == 'hot' || mod == 'cold')) || mod == 'maxhpdrain' || mod == 'internal' || mod == 'holy' || mod == 'staples' || mod == 'Slime') { Console.Printf("damtype bypass"); }
			if ((mod == 'hot' || mod == 'cold')) { Console.Printf("env"); }
			if (!inflictor) { Console.Printf("no inflictor"); }
			if ((flags & (DMG_NO_FACTOR | DMG_FORCED))) { Console.Printf("forced"); }
			if (AbsAngle(owner.angle, owner.AngleTo(inflictor)) > SGen.GetShieldArc() / 2.0) { Console.Printf("over angle"); }
			if (source && source.bISMONSTER && owner.Distance3D(source) < (owner.radius + source.radius) * 1.5) { Console.Printf("too close"); }*/
			
			return damage, mod, flags, towound, toburn, tostun, tobreak;
		}

		double reductionFac = ShieldArc / 360.0;
		int blocked = max(1, int(damage * reductionFac));

		bool supereffective = (mod == 'BFGBallAttack' || mod == 'electrical' || mod == 'balefire' || mod == 'hot' || mod == 'cold');
		SGen.BuildUpFlux(blocked, int(blocked * (supereffective ? 0.75 : 0.25)));

		if (inflictor.bMISSILE)
		{
			SpawnImpactWeave(inflictor.pos + (0, 0, inflictor.height / 2.0));
		}

		return 0, 'None', flags, 0, 0, 0, 0;
	}

	override double, double OnBulletImpact(HDBulletActor bullet, double pen, double penshell, double hitangle, double deemedwidth, vector3 hitpos, vector3 vu, bool hitactoristall)
	{
		if (Amount == 0 || !owner || !bullet || AbsAngle(owner.angle, owner.AngleTo(bullet)) > SGen.GetShieldArc() / 2.0)
		{
			return pen, penshell;
		}

		double bulletpower = pen * bullet.mass * 0.1;
		if (bulletpower < 1)
		{
			bulletpower = int(frandom(0, 1) < bulletpower);
		}

		double reductionFac = ShieldArc / 360.0;
		int fluxAmt = max(1, int(bulletpower * reductionFac));

		SGen.BuildUpFlux(fluxAmt, int(fluxAmt * 0.25));
		SpawnImpactWeave(bullet.pos);

		bullet.bMISSILE = false;
		bullet.Destroy();
		return 0, 0;
	}

	// -----------------------------------------------------------------
	// TICKER
	// -----------------------------------------------------------------

	override void DoEffect()
	{
		Inventory.DoEffect();
		ShieldletCount = 0;

		if (!SGen || !SGen.owner)
		{
			SGen = HDPersonalShieldGenerator(owner.FindInventory('HDPersonalShieldGenerator'));
			if (!SGen)
			{
				ShieldDown(ShieldArc);
				Destroy();
				return;
			}
		}

		if (!SGen.Enabled)
		{
			if (Amount == 1)
			{
				ShieldDown(ShieldArc);
				Amount = 0;
			}
			ShieldArc = 0;
			return;
		}

		ShieldColor = SGen.GetShieldColor();

		int LastArc = ShieldArc;
		ShieldArc = SGen.GetShieldArc();
		if (LastArc != ShieldArc)
		{
			ShieldUp(ShieldArc);
		}
	}

	// -----------------------------------------------------------------
	// ACTIONS
	// -----------------------------------------------------------------

	private void ShieldDown(int arc)
	{
		if (Amount == 0)
		{
			return;
		}

		owner.A_StartSound("PSG/ShieldBreak", CHAN_BODY, CHANF_OVERLAP, 0.75);

		ShieldShieldlet sp = null;

		bool shift = false;
		for (double h = 0; h <= owner.height / 1.5; h += HeightIncrease)
		{
			for (double a = 0; a < arc; a += AngleIncrease)
			{
				if (random(0, 2))
				{
					continue;
				}

				vector3 spawnPos = (owner.Vec2Angle(owner.radius * 1.5, owner.angle + (a - arc / 2.0 + ShieldletSizeShift) + (shift ? AngleIncrease / 2.0 : 0)), owner.pos.z + owner.height / 2);
				if (h == 0)
				{
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos));
					sp.PeakAlpha = 1.0; sp.OutSpeed = frandom(0.03, 0.10); sp.bSTANDSTILL = true; sp.A_ChangeVelocity(min(0, frandom(-0.5, 1.0)), 0, 0, CVF_RELATIVE);
				}
				else
				{
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos + (0, 0, h)));
					sp.PeakAlpha = 1.0; sp.OutSpeed = frandom(0.03, 0.10); sp.bSTANDSTILL = true; sp.A_ChangeVelocity(min(0, frandom(-0.5, 1.0)), 0, 0, CVF_RELATIVE);
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos - (0, 0, h)));
					sp.PeakAlpha = 1.0; sp.OutSpeed = frandom(0.03, 0.10); sp.bSTANDSTILL = true; sp.A_ChangeVelocity(min(0, frandom(-0.5, 1.0)), 0, 0, CVF_RELATIVE);
				}
			}
			shift = !shift;
		}
	}

	void ShieldUp(int arc)
	{
		owner.A_StartSound("PSG/ShieldUp", CHAN_BODY, CHANF_OVERLAP, 0.75);

		ShieldShieldlet sp = null;

		double startAlpha = 0;
		bool shift = false;

		for (double h = 0; h < owner.height / 1.5; h += HeightIncrease)
		{
			for (double a = 0; a < arc; a += AngleIncrease)
			{
				vector3 spawnPos = (owner.Vec2Angle(owner.default.radius * 1.5, owner.angle + (a - arc / 2.0 + ShieldletSizeShift) + (shift ? AngleIncrease / 2.0 : 0)), owner.pos.z + owner.height / 2);
				if (h == 0)
				{
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos));
					sp.bREFLECTIVE = true; sp.Alpha = startAlpha; sp.PeakAlpha = 1.0; sp.InSpeed = 0.20; sp.OutSpeed = frandom(0.10, 0.20);
				}
				else
				{
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos + (0, 0, h)));
					sp.bREFLECTIVE = true; sp.Alpha = startAlpha; sp.PeakAlpha = 1.0; sp.InSpeed = 0.20; sp.OutSpeed = frandom(0.10, 0.20);
					sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', spawnPos - (0, 0, h)));
					sp.bREFLECTIVE = true; sp.Alpha = startAlpha; sp.PeakAlpha = 1.0; sp.InSpeed = 0.20; sp.OutSpeed = frandom(0.10, 0.20);
				}
			}
			startAlpha -= 0.1;
			shift = !shift;
		}
	}

	private void SpawnImpactWeave(vector3 spawnPos)
	{
		if (ShieldletCount > 40)
		{
			return;
		}

		vector3 diff = level.Vec3Diff(owner.pos, spawnPos);
		double centerAngle = VectorAngle(diff.x, diff.y);

		// [Ace] I tried to mathematically calculate how to do this, but after two hours I gave up. This isn't something that will change anytime soon, so it doesn't matter anyway.
		static const double spawnHeights[] =
		{
			HeightIncrease * 4,
			HeightIncrease * 3, HeightIncrease * 3,
			HeightIncrease * 2, HeightIncrease * 2, HeightIncrease * 2,
			HeightIncrease, HeightIncrease,
			0, 0, 0,
			-HeightIncrease, -HeightIncrease,
			-HeightIncrease * 2, -HeightIncrease * 2, -HeightIncrease * 2,
			-HeightIncrease * 3, -HeightIncrease * 3,
			-HeightIncrease * 4
		};

		static const double spawnAngles[] =
		{
			0,
			-AngleIncrease / 2, AngleIncrease / 2,
			-AngleIncrease, 0, AngleIncrease,
			-AngleIncrease / 2, AngleIncrease / 2,
			-AngleIncrease, 0, AngleIncrease,
			-AngleIncrease / 2, AngleIncrease / 2,
			-AngleIncrease, 0, AngleIncrease,
			-AngleIncrease / 2, AngleIncrease / 2,
			0
		};

		static const double spawnAlphas[] =
		{
			-1.0,
			-1.0, -1.0,
			-1.0, -0.5, -1.0,
			-0.5, -0.5,
			-1.0, 0, -1.0,
			-0.5, -0.5,
			-1.0, -0.5, -1.0,
			-1.0, -1.0,
			-1.0
		};

		vector2 randomShift = (frandom(5.0, 5.0), frandom(-4.0, 4.0));
		for (int i = 0; i < spawnHeights.Size(); ++i)
		{
			vector3 hexPos = (owner.Vec2Angle(owner.default.radius * 1.5, centerAngle + spawnAngles[i] + randomShift.x), spawnPos.z + spawnHeights[i] + randomShift.y);
			ShieldShieldlet sp = ShieldShieldlet(SpawnSegment('ShieldShieldlet', hexPos));
			sp.bREFLECTIVE = true; sp.Alpha = spawnAlphas[i]; sp.PeakAlpha = 0.75; sp.InSpeed = 0.5; sp.OutSpeed = 0.20;
		}
		ShieldletCount++;

		if (ShieldletCount < 3)
		{
			owner.A_StartSound("PSG/ShieldBlock", 15, CHANF_OVERLAP);
		}
	}

	private ShieldShieldlet SpawnSegment(class<ShieldShieldlet> type, vector3 spawnPos)
	{
		ShieldShieldlet a = ShieldShieldlet(Spawn(type, spawnPos));
		a.angle = a.AngleTo(owner);
		a.SetShade(ShieldColor);
		a.master = owner;
		return a;
	}

	override void DrawHUDStuff(HDStatusBar sb, HDPlayerPawn hpl, int hdflags, int gzflags)
	{
		if (hdflags & HDSB_AUTOMAP || !SGen)
		{
			return;
		}
		
		sb.DrawImage(SGen.GetPickupSprite(), (100, -3), gzflags | sb.DI_ITEM_LEFT_BOTTOM, box: (20, -1));

		sb.DrawString(sb.pNewSmallFont, SGen.WeaponStatus[SGen.PSProp_Mode] == 0 ? "\c[Green]360\c-" : "\c[Red]120\c-", (120, -18), gzflags | sb.DI_TEXT_ALIGN_LEFT, Font.CR_DARKBROWN, scale: (0.5, 0.5));

		string colSoft = SGen.Enabled ? "\c[DarkGreen]" : (SGen.WeaponStatus[SGen.PSProp_Flags] & SGen.PSF_Overloaded ? "\c[DarkRed]" : "\c[Yellow]");
		string colHard = SGen.Enabled ? "\c[Green]" : (SGen.WeaponStatus[SGen.PSProp_Flags] & SGen.PSF_Overloaded ? "\c[Red]" : "\c[Gold]");
		sb.DrawString(sb.pNewSmallFont,
			String.Format("%s%i\c-/%s%i\c-/\c[Cyan]%i\c-", colSoft, SGen.WeaponStatus[SGen.PSProp_Flux], colHard, SGen.WeaponStatus[SGen.PSProp_HardFlux], SGen.GetFluxCapacity()),
			(120, -10), gzflags | sb.DI_TEXT_ALIGN_LEFT, Font.CR_DARKBROWN, scale: (0.5, 0.5));

		for (int i = 0; i < 3; ++i)
		{
			int bat = SGen.WeaponStatus[SGen.PSProp_Battery1 + i];
			if (bat > -1)
			{
				sb.DrawImage(AceCore.GetBatteryColor(bat), (99, -23 + 8 * i), sb.DI_ITEM_RIGHT | sb.DI_ITEM_VCENTER | gzflags, box: (-1, 7));
			}
		}
	}

	// [Ace] These are calculated to work with the the current sprite scale, size, and distance. If any of these are incorrect, problems will happen.
	const HeightIncrease = 1.6;
	const AngleIncrease = 18;
	const ShieldletSizeShift = 35 * 0.10 - 1.5;
	private bool IsShieldUp;
	private int ShieldColor;
	private int ShieldArc;
	private int ShieldletCount;
	private HDPersonalShieldGenerator SGen;

	Default
	{
		Inventory.MaxAmount 1;
		+INVENTORY.KEEPDEPLETED
		-INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
		+NOINTERACTION
		HDDamageHandler.Priority 10002; // [Ace] Handle it before the shield from Arcanum.
	}
}

class ShieldShieldlet : Actor
{
	override void Tick()
	{
		// [Ace] I'm pulling a Matt and using unused flags instead of defining my own. Can it backfire? Maybe in a century. Can it backfire realistically? Probably not.
		if (master && !bSTANDSTILL)
		{
			vel = master.vel;
		}
		Super.Tick();
	}

	double InSpeed, OutSpeed, PeakAlpha;

	Default
	{
		+NOINTERACTION
		+NOBLOCKMAP
		Renderstyle "AddShaded";
		+BRIGHT
		+WALLSPRITE
		Alpha 1.0;
		Scale 0.10;
	}

	States
	{
		Spawn:
			SLDS S 1 NoDelay
			{
				if (bREFLECTIVE)
				{
					alpha += InSpeed;
					if (alpha >= PeakAlpha)
					{
						bREFLECTIVE = false;
					}
				}
				else
				{
					A_FadeOut(OutSpeed);
				}
			}
			Loop;
	}
}

class FluxSmoke : ACESmokeBase
{
	Default
	{
		Renderstyle "Shaded";
		ACESmokeBase.GrowSpeed 0.008, 0.0085;
		ACESmokeBase.FadeSpeed 0.01, 0.015;
		ACESmokeBase.StopSpeed 0.88, 0.88;
		Scale 0.05;
	}
}
