class FAK_Handler : EventHandler
{
	private bool GaveCore;

	override void PlayerEntered(PlayerEvent e)
	{
		FAK_UpgradeThinker thonker = new('FAK_UpgradeThinker');
		thonker.PlayerNumber = e.PlayerNumber;
	}

	override void WorldThingDied(WorldEvent e)
	{
		if (!e.Thing.bFRIENDLY && (e.Thing is 'Necromancer' && !random(0, 10) || e.Thing.bBOSS && !random(0, 6)))
		{
			e.Thing.A_SpawnItemEx('AssemblyCore', 0, 0, 0, frandom(0.5, 2.0), 0, frandom(1.0, 4.0), random(0, 359), SXF_NOCHECKPOSITION);
		}
	}

	override void WorldUnloaded(WorldEvent e)
	{
		if (
			fak_giveCores_mapEnd
			&& !GaveCore
			&& level.total_secrets > 0 && level.found_secrets == level.total_secrets
			&& level.total_monsters > 0 && level.killed_monsters >= level.total_monsters * 0.9
		) {
			for (int i = 0; i < MAXPLAYERS; ++i) {
				let plr = players[i].mo;

				if (!plr) continue;

				plr.A_GiveInventory('AssemblyCore', 1);
			}
			GaveCore = true;
		}
	}
}

class FAK_Upgrade abstract
{
	enum FailMessageType
	{
		FMType_Requirements,
		FMType_Installed,
		FMType_MaxedOut, // [Ace] Only really useful for repeatable upgrades.
		FMType_Uninstalled,
		FMType_NotAvailable
	}

	enum HasUpgradeResult
	{
		HUResult_NotInstalled,
		HUResult_Installed,
		HUResult_Repeatable,
		HUResult_MaxedOut,
		HUResult_Destructive,
		HUResult_Unique
	}
	
	//Array<string> Icons;
	abstract string GetItem();
	abstract string GetDisplayName();
	virtual int GetCost() const { return 1; }

	abstract play void DoUpgrade(HDWeapon wpn, HDPickup pkp);
	abstract int HasUpgrade(HDWeapon wpn, HDPickup pkp) const;

	virtual play void DoDowngrade(HDWeapon wpn, HDPickup pkp) { }
	virtual bool CanDowngrade() { return true; }
	play void GiveCore(Actor other, double chance) {
		if (fak_coreRefund_ratio > 0.0) {
			let gaveCore = false;
			let scaledChance = chance * fak_coreRefund_ratio;

			if (hd_debug) console.printf('Original Chance: '..chance..', Scaled Chance: '..scaledChance);

			while (scaledChance > 1.0) {
				other.A_GiveInventory('AssemblyCore', 1);
				scaledChance -= 1.0;
				gaveCore = true;
			}
	
			if (frandom(0.01, 1.00) <= scaledChance) {
				other.A_GiveInventory('AssemblyCore', 1);
				gaveCore = true;
			}

			if (gaveCore) {
				other.A_Log('You have obtained an assembly core from this downgrade.', true);
			}
		}
	}

	virtual bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp) const { return true; }
	virtual string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type) const
	{
		switch (type)
		{
			case FMType_Requirements: return "Requirements not met.";
			case FMType_Installed: return "Upgrade has already been installed.";
			case FMType_MaxedOut: return "Upgrade has been maxed out.";
			case FMType_Uninstalled: return "Upgrade has already been uninstalled.";
			case FMType_NotAvailable: return "Downgrade not available.";
		}
		return "Error message that the player should never see. Go complain to Ace.";
	}
}


class HDFieldAssemblyKit : HDWeapon
{
	
	Array<string> Icons;
	
	enum KitProperties
	{
		KProp_SelectedWeapon,
		KProp_SelectedUpgrade
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		for (int i = 0; i < AllClasses.Size(); ++i)
		{
			if (AllClasses[i] is 'FAK_Upgrade' && !AllClasses[i].IsAbstract())
			{
				FAK_Upgrade Upgrade = FAK_Upgrade(new(AllClasses[i]));
				class<Inventory> item = Upgrade.GetItem();
				if (item)
				{
					AllUpgrades.Push(Upgrade);
				}
			}
		}
	}

	override void DoEffect()
	{
		Super.DoEffect();
		if (owner.player && owner.player.ReadyWeapon == self)
		{
			for (int i = AvailableItems.Size() - 1; i >= 0; --i)
			{
				if (!AvailableItems[i] || !AvailableItems[i].owner)
				{
					AvailableItems.Delete(i);
					A_UpdateUpgradesForItem(GetSelectedItem());
				}
			}

			// [Ace] If you pick something up, automatically update interface.
			if (AvailableItems.Size() == 0)
			{
				A_UpdateAvailableItems();
				A_UpdateUpgradesForItem(GetSelectedItem());
			}
		}
	}

	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_FIRE..Stringtable.Localize("$FAK_HELPTEXT_1")
		..LWPHELP_ALTFIRE..Stringtable.Localize("$FAK_HELPTEXT_2")
		..LWPHELP_ZOOM.."+"..LWPHELP_FIRE.."/"..LWPHELP_ALTFIRE..Stringtable.Localize("$FAK_HELPTEXT_3")
		..LWPHELP_FIREMODE.."+"..LWPHELP_FIRE.."/"..LWPHELP_ALTFIRE..Stringtable.Localize("$FAK_HELPTEXT_4");
	}
	override string, double GetPickupSprite() { return "FAKTA0", 0.5; }
	override double GunMass() { return 0; }
	override double WeaponBulk() { return 40; }
	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override int GetSbarNum(int flags)
	{
		return owner.CountInv('AssemblyCore');
	}

	override void ActualPickup(Actor other, bool silent)
	{
		let kit = other.FindInventory('HDFieldAssemblyKit');
		if (kit)
		{
			other.A_Log("Assembly kit was converted to an assembly core.", true);
			other.A_GiveInventory('AssemblyCore', 1);
			Destroy();
			return;
		}
		Super.ActualPickup(other, silent);
	}

	private void ResetConfirmation()
	{
		for (int i = 0; i < Confirmation.Size(); ++i)
		{
			Confirmation[i] = false;
		}
	}

	private action void A_UpdateAvailableItems()
	{
		invoker.AvailableItems.Clear();
		for (int i = 0; i < invoker.AllUpgrades.Size(); ++i)
		{
			Inventory item = invoker.owner.FindInventory(invoker.AllUpgrades[i].GetItem());
			if (item && invoker.AvailableItems.Find(item) == invoker.AvailableItems.Size())
			{
				invoker.AvailableItems.Push(item);
			}
		}
		invoker.WeaponStatus[KProp_SelectedWeapon] = clamp(invoker.WeaponStatus[KProp_SelectedWeapon], 0, invoker.AvailableItems.Size() - 1);
		invoker.ResetConfirmation();
	}

	private action void A_UpdateUpgradesForItem(Inventory item)
	{
		if (!item)
		{
			return;
		}

		invoker.CurrUpgrades.Clear();
		for (int i = 0; i < invoker.AllUpgrades.Size(); ++i)
		{
			if (invoker.AllUpgrades[i].GetItem() == item.GetClass())
			{
				invoker.CurrUpgrades.Push(invoker.AllUpgrades[i]);
			}
		}
	}

	private clearscope Inventory GetSelectedItem()
	{
		int size = AvailableItems.Size();
		int selIndex = min(WeaponStatus[KProp_SelectedWeapon], size - 1);
		return selIndex > -1 ? AvailableItems[selIndex] : null;
	}

	private clearscope FAK_Upgrade GetSelectedUpgrade()
	{
		int size = CurrUpgrades.Size();
		int selIndex = min(WeaponStatus[KProp_SelectedUpgrade], size - 1);
		return selIndex > -1 ? CurrUpgrades[selIndex] : null;
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		sb.DrawRect(-41, -17, 4, 5); // Stock.
		sb.DrawRect(-34, -16, 3, 5); // Handle.
		sb.DrawRect(-28, -16, 5, 5); // Magazine.
		sb.DrawRect(-37, -17, 19, 3); // Body.
		sb.DrawRect(-32, -20, 11, 3); // Scope.
		sb.DrawRect(-18, -17, 6, 1); // Barrel.

		vector2 bob = hpl.wepbob * 0.3;
		int BaseYOffset = -40;
		
		sb.DrawImage(GetPickupSprite(), (0, BaseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER_BOTTOM);

		vector2 pos = (0, BaseYOffset - 160);
		let selItem = GetSelectedItem();
		if (selItem)
		{
			//StorageItem CurItem = Storage.Items[RealIndex];
			//sb.DrawImage(ItemStorage.GetIcon(selItem), pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_BOTTOM, box: (70, 40), scale: (2.0, 2.0));
			//sb.DrawImage(SelItem.Icons[i], pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_BOTTOM, box: (70, 40), scale: (2.0, 2.0));
			//pos.y += 10;
			sb.DrawString(sb.pSmallFont, selItem.GetTag(), pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER, Font.CR_SAPPHIRE);
			pos.y += 10;

			int Size = CurrUpgrades.Size();
			for (int i = 0; i < Size; ++i)
			{
				bool selected = i == WeaponStatus[KProp_SelectedUpgrade];

				string hasUpStr = " \c[Red]Not installed\c-";
				switch (CurrUpgrades[i].HasUpgrade(HDWeapon(selItem), HDPickup(selItem)))
				{
					case FAK_Upgrade.HUResult_Installed: hasUpStr = " \c[Green]Installed\c-"; break;
					case FAK_Upgrade.HUResult_Repeatable: hasUpStr = " \c[Purple]Repeatable\c-"; break;
					case FAK_Upgrade.HUResult_MaxedOut: hasUpStr = " \c[FAK_Blue]Maxed Out\c-"; break;
					case FAK_Upgrade.HUResult_Destructive: hasUpStr = " \c[Fire]Destructive\c-"; break;
					case FAK_Upgrade.HUResult_Unique: hasUpStr = " \c[Sapphire]Unique\c-"; break;
				}

				int cost = CurrUpgrades[i].GetCost();
				string costStr = "\c[Gold]- "..CurrUpgrades[i].GetCost().." -\c- ";
				if (cost == 0)
				{
					costStr = "  ";
				}
				sb.DrawString(sb.pSmallFont, hasUpStr, pos + bob - (20, 0), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT);
				sb.DrawString(sb.pSmallFont, costStr, pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
				sb.DrawString(sb.pSmallFont, CurrUpgrades[i].GetDisplayName(), pos + bob + (18, 0), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, selected ? Font.CR_WHITE : Font.CR_DARKGRAY);
				pos.y += 10;
			}

			string str = "";
			if (Confirmation[0])
			{
				str = "Confirm upgrade?";
			}
			else if (Confirmation[1])
			{
				str = "Confirm downgrade?";
			}

			if (str != "")
			{
				pos.y += 10;
				sb.DrawString(sb.pSmallFont, str, pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GREEN);
			}
		}
		else
		{
			sb.DrawString(sb.pSmallFont, "No available items.", pos + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER, Font.CR_ORANGE, 1.0);
		}
	}

	private action void A_CheckWeaponCycle(int cycleDir)
	{
		A_UpdateAvailableItems();
		int size = invoker.AvailableItems.Size();
		if (size < 1)
		{
			return;
		}

		int selIndex = invoker.WeaponStatus[KProp_SelectedWeapon];
		switch (cycleDir)
		{
			case 1:
				++selIndex %= size;
				break;
			case -1:
				selIndex = selIndex == 0 ? size - 1 : selIndex - 1;
				break;
		}
		invoker.WeaponStatus[KProp_SelectedWeapon] = selIndex;
		invoker.WeaponStatus[KProp_SelectedUpgrade] = 0;
		A_UpdateUpgradesForItem(invoker.GetSelectedItem());
		invoker.ResetConfirmation();
	}

	private action void A_CheckUpgradeCycle(int cycleDir)
	{
		int size = invoker.CurrUpgrades.Size();
		if (size < 1)
		{
			return;
		}

		int selIndex = invoker.WeaponStatus[KProp_SelectedUpgrade];
		switch (cycleDir)
		{
			case 1:
				++selIndex %= size;
				break;
			case -1:
				selIndex = selIndex == 0 ? invoker.CurrUpgrades.Size() - 1 : selIndex - 1;
				break;
		}
		invoker.WeaponStatus[KProp_SelectedUpgrade] = selIndex;
		invoker.ResetConfirmation();
	}

	private action void A_PerformKitAction(int act)
	{
		let item = invoker.GetSelectedItem();
		if (!item)
		{
			return;
		}

		FAK_Upgrade upgrade = invoker.GetSelectedUpgrade();
		if (!upgrade)
		{
			return;
		}

		if (act == 0)
		{
			if (CountInv('AssemblyCore') < upgrade.GetCost())
			{
				A_WeaponMessage("Not enough assembly cores.");
				return;
			}

			switch (upgrade.HasUpgrade(HDWeapon(item), HDPickup(item)))
			{
				case FAK_Upgrade.HUResult_Installed: A_WeaponMessage(upgrade.GetFailMessage(HDWeapon(item), HDPickup(item), FAK_Upgrade.FMType_Installed)); return;
				case FAK_Upgrade.HUResult_MaxedOut: A_WeaponMessage(upgrade.GetFailMessage(HDWeapon(item), HDPickup(item), FAK_Upgrade.FMType_MaxedOut)); return;
			}

			if (!upgrade.CheckPrerequisites(HDWeapon(item), HDPickup(item)))
			{
				A_WeaponMessage(upgrade.GetFailMessage(HDWeapon(item), HDPickup(item), FAK_Upgrade.FMType_Requirements));
				return;
			}
		}
		else if (act == 1)
		{
			if (!upgrade.CanDowngrade())
			{
				A_WeaponMessage(upgrade.GetFailMessage(HDWeapon(item), HDPickup(item), FAK_Upgrade.FMType_NotAvailable));
				return;
			}

			// [Ace] This is here because some upgrades are not necessarily marked as explicitly undowngradeable.
			// An example is Peppergrinder's Lotus. It can have either a suppressor or an extended barrel, but it can also have neither.
			// On the other hand, Icarus's MBR can only have one barrel type, but it MUST have a barrel, so those are explicitly marked as undowngradeable, despite being unique.
			// Bottom line, if it's doesn't say "installed", it can't be downgraded, period. Same with repeatable upgrades, despite some of those being installation-like, e.g. PSG's upgrades.
			// CanDowngrade() has limited use, like with the MBR, so don't use it willy-nilly.

			int result = upgrade.HasUpgrade(HDWeapon(item), HDPickup(item));
			if (result != FAK_Upgrade.HUResult_Installed)
			{
				A_WeaponMessage(upgrade.GetFailMessage(HDWeapon(item), HDPickup(item), result == FAK_Upgrade.HUResult_NotInstalled ? FAK_Upgrade.FMType_Uninstalled : FAK_Upgrade.FMType_NotAvailable));
				return;
			}
		}

		if (invoker.Confirmation[act])
		{
			switch (act)
			{
				case 0:
				{
					upgrade.DoUpgrade(HDWeapon(item), HDPickup(item));
					int cost = upgrade.GetCost();
					if (cost > 0)
					{
						A_TakeInventory('AssemblyCore', cost);
					}
					break;
				}
				case 1:
				{
					upgrade.DoDowngrade(HDWeapon(item), HDPickup(item));
					break;
				}
			}
			A_StartSound("FAKit/Use", 10);
			invoker.ResetConfirmation();
			SetWeaponState('Nope');
		}
		else
		{
			invoker.Confirmation[act] = true;
			SetWeaponState('Nope');
		}
	}

	bool Confirmation[2];
	private Array<FAK_Upgrade> AllUpgrades;
	private Array<Inventory> AvailableItems;
	private Array<FAK_Upgrade> CurrUpgrades;

	Default
	{
		+WEAPON.WIMPY_WEAPON
		+INVENTORY.INVBAR
		+HDWEAPON.FITSINBACKPACK
		Inventory.PickupSound "weapons/pocket";
		Inventory.PickupMessage "$PICKUP_FAK";
		Scale 0.3;
		HDWeapon.RefId "FAK";
		Tag "$TAG_FAK";
	}

	States
	{
		Spawn:
			FAKT A -1;
			Stop;
		Select0:
			TNT1 A 0
			{
				invoker.ResetConfirmation();
				invoker.WeaponStatus[KProp_SelectedUpgrade] = 0;
				A_UpdateAvailableItems();
				A_UpdateUpgradesForItem(invoker.GetSelectedItem());
				A_Raise(999);
			}
			Wait;
		Deselect0:
			TNT1 A 0 A_Lower(999);
			Wait;
		Fire:
			TNT1 A 5
			{
				if (PressingZoom())
				{
					A_CheckWeaponCycle(1);
				}
				else if (PressingFiremode())
				{
					A_CheckUpgradeCycle(1);
				}
				else
				{
					A_PerformKitAction(0);
				}
			}
			Goto Ready;
		AltFire:
			TNT1 A 5
			{
				if (PressingZoom())
				{
					A_CheckWeaponCycle(-1);
				}
				else if (PressingFiremode())
				{
					A_CheckUpgradeCycle(-1);
				}
				else
				{
					A_PerformKitAction(1);
				}
			}
			Goto Ready;
		Ready:
			TNT1 A 1 A_WeaponReady(WRF_ALLOWUSER3);
			Goto ReadyEnd;
		User3:
			#### A 0 A_SelectWeapon("PickupManager");
			Goto Ready;
	}
}

class AssemblyCore : HDPickup
{
	Default
	{
		+HDPICKUP.FITSINBACKPACK
		-INVENTORY.INVBAR
		+HDPICKUP.CHEATNOGIVE
		Tag "$TAG_ASSEMBLYCORE";
		Inventory.Icon "ASCRA0";
		Inventory.PickupMessage "$PICKUP_ASSEMBLYCORE";
		Inventory.PickupSound "weapons/pocket";
		HDPickup.Bulk 15;
		Scale 0.6;
	}

	States
	{
		Spawn:
			ASCR ABCDEF 3;
			Loop;
	}
}
