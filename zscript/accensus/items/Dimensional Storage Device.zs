class DSDHandler : EventHandler
{
	DSDStorage Storages[MAXPLAYERS];

	override void WorldThingSpawned(WorldEvent e)
	{
		HDBattery bat = HDBattery(e.Thing);
		if (bat)
		{
			bat.ItemsThatUseThis.Push("DSDInterface");
		}
	}

	override void PlayerEntered(PlayerEvent e)
	{
		Storages[e.PlayerNumber] = DSDStorageThinker.Get(e.PlayerNumber);
	}

	// [Ace] I legitimately have no idea if this is even a good idea, but it seems to be the only way to manipulate the variables due to scoping.
	override void NetworkProcess(ConsoleEvent e)
	{
		let DSD = Storages[e.Player];

		if (e.Name ~== "DSD_BeginSearch")
		{
			DSD.InSearchMode = true;
			return;
		}

		if (e.Name ~== "DSD_ApplySearch")
		{
			DSD.ApplySearch();
			return;
		}

		if (e.Name ~== "DSD_DeleteLastChar")
		{
			DSD.SearchString.DeleteLastCharacter();
			return;
		}

		if (e.Name ~== "DSD_AppendChar")
		{
			DSD.SearchString = DSD.SearchString..String.Format("%c", e.Args[0]);
			return;
		}

		// [Ace] This is cheating.
		if (e.Name ~== "DSD_SetCapacity" && sv_cheats)
		{
			DSD.MaxBulk = max(1000, e.Args[0]);
			return;
		}
	}

	override bool InputProcess(InputEvent e)
	{
		let plr = players[consoleplayer].mo;
		if (plr && plr.player && plr.player.ReadyWeapon is 'DSDInterface' && e.Type == e.Type_KeyDown)
		{
			if (!Storages[consoleplayer].InSearchMode && e.KeyScan == e.Key_Enter)
			{
				EventHandler.SendNetworkEvent("DSD_BeginSearch");
				return true;
			}
			else if (e.Type == e.Type_KeyDown && Storages[consoleplayer].InSearchMode)
			{
				switch (e.KeyScan)
				{
					// Apply filter.
					case e.Key_Enter:
						EventHandler.SendNetworkEvent("DSD_ApplySearch");
						break;

					// Delete last character.
					case e.Key_Backspace:
						EventHandler.SendNetworkEvent("DSD_DeleteLastChar");
						break;

					default:
						if (Storages[consoleplayer].SearchString.Length() < 20 && e.KeyChar >= 32 && e.KeyChar <= 126) // [Ace] Only valid characters.
						{
							EventHandler.SendNetworkEvent("DSD_AppendChar", e.KeyChar);
						}
						break;
				}
				return true;
			}
		}

		return false;
	}
}

class DSDStorage : ItemStorage
{
	void ApplySearch()
	{
		if (SearchString == "")
		{
			InSearchMode = false;
			return;
		}

		Array<string> split;
		string search = SearchString.MakeLower();
		search.Split(split, " ");

		int mostMatches = 0, index = -1;
		for (int i = 0; i < Items.Size(); ++i)
		{
			string niceName = Items[i].NiceName.MakeLower();
			int curMatches = 0;
			for (int j = 0; j < split.Size(); ++j)
			{
				if (niceName.IndexOf(split[j]) != -1)
				{
					curMatches++;
				}
			}
			if (curMatches > mostMatches)
			{
				mostMatches = curMatches;
				index = i;
			}
		}
		if (index > -1)
		{
			SelItemIndex = index;
		}

		SearchString = "";
		InSearchMode = false;
	}

	override string GetFailMessage()
	{
		return "Your storage is full.";
	}

	override int GetOperationSpeed(class<Inventory> item, int operation)
	{
		let wpn = (class<HDWeapon>)(item);
		let pkp = (class<HDPickup>)(item);
		bool multipickup = pkp && GetDefaultByType(pkp).bMULTIPICKUP;
		switch (operation)
		{
			case SIIAct_Extract: return wpn ? 20 : multipickup ? 6 : 6;
			case SIIAct_Insert: return wpn ? 20 : multipickup ? 6 : 6;
		}
		return 20;
	}

	override int CheckConditions(Inventory item, class<Inventory> cls)
	{
		if (item)
		{
			let wpn = HDWeapon(item);
			let arm = HDArmour(item);
			let mag = HDMagAmmo(item);
			let pkp = HDPickup(item);

			if (item is 'HDBackpack')
			{
				return IType_Invalid;
			}
			if (wpn && !wpn.bNOINTERACTION && !wpn.bUNDROPPABLE && !wpn.bUNTOSSABLE && !wpn.bCHEATNOTWEAPON)
			{
				return IType_Weapon;
			}
			/*
			if (arm)
			{
				return IType_Armour;
			}
			*/
			if (mag)
			{
				return IType_Mag;
			}
			if (pkp && !pkp.bNOINTERACTION && !pkp.bUNDROPPABLE && !pkp.bUNTOSSABLE && pkp.bFITSINBACKPACK)
			{
				return IType_Pickup;
			}
		}
		else if (cls)
		{
			let wpn = cls is 'HDWeapon' ? GetDefaultByType((class<HDWeapon>)(cls)) : null;
			//let arm = cls is 'HDArmour' ? GetDefaultByType((class<HDArmour>)(cls)) : null;
			let mag = cls is 'HDMagAmmo' ? GetDefaultByType((class<HDMagAmmo>)(cls)) : null;
			let pkp = cls is 'HDPickup' ? GetDefaultByType((class<HDPickup>)(cls)) : null;

			if (wpn && !wpn.bNOINTERACTION && !wpn.bUNDROPPABLE && !wpn.bUNTOSSABLE && !wpn.bCHEATNOTWEAPON && wpn.GetTag() != wpn.GetClassName())
			{
				return IType_Weapon;
			}
			/*
			if (arm && arm.GetTag() != arm.GetClassName())
			{
				return IType_Armour;
			}
			*/
			if (mag && mag.GetTag() != mag.GetClassName())
			{
				return IType_Mag;
			}
			if (pkp && !pkp.bNOINTERACTION && !pkp.bUNDROPPABLE && !pkp.bUNTOSSABLE && pkp.bFITSINBACKPACK && pkp.GetTag() != pkp.GetClassName())
			{
				return IType_Pickup;
			}
		}

		return IType_Invalid;
	}

	/*
	override int TryInsertItem(Inventory item, Actor inserter, int amt, int index, bool noInsert, int flags)
	{
		if (flags & bFITSINBACKPACK)
		//if (flags & BF_FROMMANAGER)
		{
			return 0;
		}
		
		return Super.TryInsertItem(item, inserter, amt, index, noInsert, flags);
	}
	*/
	override Inventory RemoveItem(StorageItem item, Actor remover, Actor receiver, int amt, int index, int flags)
	{
		if (!item || item.Amounts.Size() == 0 || amt < 1)
		//if (!item || item.Amounts.Size() == 0 || amt < 1 || flags & bFITSINBACKPACK)
		{
			return null;
		}

		let wpn = (class<HDWeapon>)(item.ItemClass);
		//let arm = (class<HDArmour>)(item.ItemClass);
		let mag = (class<HDMagAmmo>)(item.ItemClass);
		let pkp = (class<HDPickup>)(item.ItemClass);

		Inventory spawned = null;
		vector3 SpawnPos = (0, 0, 0);
		if (remover)
		{
			for (int i = 64; i >= 0; i -= 8)
			{
				SpawnPos = remover.Vec3Angle(i - 8, remover.angle, remover.height / 2 + 6);
				if (level.IsPointInLevel(SpawnPos))
				{
					break;
				}
			}
		}
		if (wpn)
		{
			index = min(index, item.Amounts.Size() - 1);
			amt = min(1, amt, item.Amounts[0]);
			if (remover && !(flags & BF_FROMCONSOLIDATE))
			{
				Actor.Spawn("DSDSpawnEffect", SpawnPos);
			}
			for (int i = 0; i < amt; ++i)
			{
				if (remover)
				{
					spawned = Inventory(Actor.Spawn(wpn, SpawnPos));
					HDWeapon newwpn = HDWeapon(spawned);
					for (int i = 0; i < HDWEP_STATUSSLOTS; ++i)
					{
						newwpn.WeaponStatus[i] = item.WeaponStatus[HDWEP_STATUSSLOTS * index + i];
					}
					if (newwpn.bDROPTRANSLATION)
					{
						newwpn.Translation = remover.Translation;
					}
					newwpn.A_ChangeVelocity(0, 0, frandom(0, 2), CVF_RELATIVE);
				}
				item.WeaponStatus.Delete(HDWEP_STATUSSLOTS * index, HDWEP_STATUSSLOTS);
				if (item.Icons.Size() > 1) // [Ace] Don't delete the last icon. It is used for the preview.
				{
					item.Icons.Delete(index);
				}
				item.Bulks.Delete(index);
				item.Amounts[0]--;
				if (item.Amounts[0] == 0)
				{
					item.Amounts.Delete(0);
				}
			}
		}
		else if (mag)// || arm)
		{
			index = min(index, item.Amounts.Size() - 1);
			amt = min(1, amt, item.Amounts[0]);
			//amt = min(arm ? 1 : amt, item.Amounts.Size());
			if (remover && !(flags & BF_FROMCONSOLIDATE))
			{
				Actor.Spawn("DSDSpawnEffect", SpawnPos);
			}
			for (int i = 0; i < amt; ++i)
			{
				if (remover)
				{
					spawned = Inventory(Actor.Spawn(mag, SpawnPos));
					//spawned = Inventory(Actor.Spawn(arm ? (class<HDMagAmmo>)(arm) : mag, SpawnPos));
					HDMagAmmo newmag = HDMagAmmo(spawned);
					newmag.Mags[0] = item.Amounts[index];
					newmag.angle = random(0, 359);
					newmag.A_ChangeVelocity(frandom(-0.1, 0.4), 0, frandom(0, 3), CVF_RELATIVE);
				}
				if (item.Icons.Size() > 1)
				{
					item.Icons.Delete(index);
				}
				item.Bulks.Delete(index);
				item.Amounts.Delete(index);
			}
		}
		else if (pkp)
		{
			amt = min(amt, item.Amounts[0]);
			if (remover)
			{
				if (!(flags & BF_FROMCONSOLIDATE))
				{
					Actor.Spawn("DSDSpawnEffect", SpawnPos);
				}
				spawned = Inventory(Actor.Spawn(pkp, SpawnPos));
				HDPickup newpkp = HDPickup(spawned);
				newpkp.Amount = amt;
				newpkp.angle = random(0, 359);
				newpkp.A_ChangeVelocity(frandom(-0.1, 0.4), 0, frandom(0, 3), CVF_RELATIVE);
			}
			item.Bulks[0] -= amt * GetDefaultByType(pkp).Bulk;
			item.Amounts[0] -= amt;
			if (item.Amounts[0] == 0)
			{
				item.Amounts.Delete(0);
			}
		}

		RemoveNullOrEmpty(remover);
		CalculateBulk();
		return spawned;
	}

	string SearchString;
	bool InSearchMode;
}

class DSDStorageThinker : Thinker
{
	static DSDStorage Get(int num)
	{
		ThinkerIterator it = ThinkerIterator.Create('DSDStorageThinker', STAT_STATIC);
		DSDStorageThinker thkr;
		while ((thkr = DSDStorageThinker(it.Next())))
		{
			if (thkr.TrackedPlayer == num)
			{
				return thkr.Storage;
			}
		}

		// [Ace] Create a new one if none exist.
		thkr = new('DSDStorageThinker');
		thkr.ChangeStatNum(STAT_STATIC);
		thkr.TrackedPlayer = num;
		thkr.Storage = new('DSDStorage');
		thkr.Storage.MaxBulk = 1000;
		return thkr.Storage;
	}

	DSDStorage Storage;
	int TrackedPlayer;
}

class DSDInterface : HDBackpack
{
	enum DSDProperties
	{
		DSDProp_Flags,
		DSDProp_ExtraPoints,
		DSDProp_Battery
	}

	override void AttachToOwner(Actor other)
	{
		Super.AttachToOwner(other);

		Storage = DSDStorageThinker.Get(owner.PlayerNumber());

		// [Ace] I gotta set these here and not in LoadoutConfigure because that one is called before the storage can be initialized.
		if (StartingCapacity > 0)
		{
			Storage.MaxBulk = StartingCapacity;
			StartingCapacity = 0;
		}

		if (ConfigString != "")
		{
			// [Ace] Remove the dot after 'dsd', if any.
			if (ConfigString.ByteAt(0) == 46)
			{
				ConfigString = ConfigString.Mid(1);
			}
			Super.LoadoutConfigure(ConfigString);
			ConfigString = "";
		}
	}

	override void Tick()
	{
		if (Storage && WeaponStatus[DSDProp_ExtraPoints] > 0)
		{
			Storage.MaxBulk += 500 * WeaponStatus[DSDProp_ExtraPoints];
			WeaponStatus[DSDProp_ExtraPoints] = 0;
		}
		Super.Tick();
	}

	override void UpdateCapacity() {}
	override void DropOneAmmo(int amt) {}
	override void Consolidate() {}
	override void LoadoutConfigure(string input)
	{
		ConfigString = input;
		StartingCapacity = GetLoadoutVar(input, "cap", 5);
	}
	override bool CanGrabInsert(Inventory item, class<Inventory> item, Actor grabber) { return false; }
	override bool IsBeingWorn() { return false; }
	override string, double GetPickupSprite(){ return "DSDDA0", 1.0; }
	override double WeaponBulk() { return 60; }

	override void InitializeWepStats(bool idfa)
	{
		WeaponStatus[DSDProp_Battery] = -1;
	}

	override string GetHelpText()
	{
		return WEPHELP_FIRE.."/"..WEPHELP_ALTFIRE.."  Previous/Next item\n"
		..WEPHELP_FIREMODE.."+"..WEPHELP_UPDOWN.."  Adjust operation amount\n"
		..WEPHELP_RELOAD.."  Insert\n"
		..WEPHELP_UNLOAD.."  Remove\n"
		..WEPHELP_BTCOL.."Enter"..WEPHELP_RGCOL.."  Search mode/apply search\n"
		..WEPHELP_ALTRELOAD.."(+"..WEPHELP_USE..")  Sort descending/ascending\n"
		..WEPHELP_USE.."(hold) + "..WEPHELP_RELOAD.."  Load battery\n"
		..WEPHELP_USE.."(hold) + "..WEPHELP_UNLOAD.."  Remove battery";
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		int yOff = -80;

		if (WeaponStatus[DSDProp_Battery] > -1)
		{
			sb.DrawImage(AceCore.GetBatteryColor(WeaponStatus[DSDProp_Battery]), (0, yOff - 5), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER_BOTTOM, box: (-1, 20), scale: (2.0, 2.0));
		}

		sb.DrawString(sb.pSmallFont, "\c[DarkBrown][] [] [] \c[Cyan]Dimensional Storage Device \c[DarkBrown][] [] []", (0, yOff), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
		sb.DrawString(sb.pSmallFont, String.Format("Total Bulk: \cf%.2f/%i\c-", Storage.TotalBulk, Storage.MaxBulk), (0, yOff + 10), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
		if (WeaponStatus[DSDProp_Battery] <= 0)
		{
			if (level.time % 50 < 25)
			{
				sb.DrawString(sb.pSmallFont, "!!! INOPERABLE !!!", (0, yOff + 20), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_RED);
			}
		}
		else
		{
			sb.DrawString(sb.pSmallFont, "\c[Brown]Operations left: \c-"..(WeaponStatus[DSDProp_Battery]), (0, yOff + 20), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GREEN);
		}

		yOff += 40;

		int itemCount = Storage.Items.Size();
		if (itemCount == 0)
		{
			sb.DrawString(sb.pSmallFont, "No items found.", (0, yOff), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_DARKGRAY);
			return;
		}
		
		StorageItem selItem = Storage.GetSelectedItem();
		if (!selItem)
		{
			return;
		}

		for (int i = 0; i < (ItemCount > 1 ? 5 : 1); ++i)
		{
			int RealIndex = (Storage.SelItemIndex + (i - 2)) % ItemCount;
			if (RealIndex < 0)
			{
				RealIndex = ItemCount - abs(RealIndex);
			}

			vector2 Offset = ItemCount > 1 ? (-100, 8) : (0, 0);
			switch (i)
			{
				case 1: Offset = (-50, 4);  break;
				case 2: Offset = (0, 0); break;
				case 3: Offset = (50, 4); break;
				case 4: Offset = (100, 8); break;
			}

			StorageItem CurItem = Storage.Items[RealIndex];
			bool CenterItem = Offset ~== (0, 0);
			sb.DrawImage(CurItem.Icons[0], (Offset.x, yOff + 10 + Offset.y), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, CenterItem && !CurItem.HaveNone() ? 1.0 : 0.6, CenterItem ? (50, 30) : (30, 20), GetDefaultByType(CurItem.ItemClass).Scale * (CenterItem ? 4.0 : 3.0));
		}
		
		sb.DrawString(sb.pSmallFont, selItem.NiceName, (0, yOff + 30), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_FIRE);

		int AmountInBackpack = selItem.ItemClass is 'HDMagAmmo' ? selItem.Amounts.Size() : (selItem.Amounts.Size() > 0 ? selItem.Amounts[0] : 0);
		sb.DrawString(sb.pSmallFont, "In backpack:  "..sb.FormatNumber(AmountInBackpack, 1, 6), (0, yOff + 40), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountInBackpack > 0 ? Font.CR_BROWN : Font.CR_DARKBROWN);

		int AmountOnPerson = GetAmountOnPerson(hpl.FindInventory(selItem.ItemClass));
		sb.DrawString(sb.pSmallFont, "On person:  "..sb.FormatNumber(AmountOnPerson, 1, 6), (0, yOff + 48), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountOnPerson > 0 ?  Font.CR_WHITE : Font.CR_DARKGRAY);

		if (selItem.ItemClass is 'HDPickup' && !(selItem.ItemClass is 'HDArmour'))
		{
			sb.DrawString(sb.pSmallFont, "Insert/remove:  "..sb.FormatNumber(OperationAmount, 1, 3), (0, yOff + 56), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_SAPPHIRE);
		}

		if (DSDStorage(Storage).InSearchMode)
		{
			sb.DrawString(sb.pSmallFont, "Searching: "..DSDStorage(Storage).SearchString.."_", (-60, yOff + 64), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
		}

		if (selItem.ItemClass is 'HDArmour')
		{
			for (int i = 0; i < selItem.Amounts.Size(); ++i)
			{
				vector2 Off = (-126 + 35 * (i % 8), yOff + 90 + 35 * (i / 8));
				sb.DrawImage(selItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (30, 20), (4.0, 4.0));
				sb.DrawString(sb.mAmountFont, sb.FormatNumber(selItem.Amounts[i] > 1000 ? selItem.Amounts[i] - 1000 : selItem.Amounts[i], 1, 4), Off + (0, 12), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_YELLOW);
			}
		}
		else if (selItem.ItemClass is 'HDMagAmmo' && GetDefaultByType((class<HDMagAmmo>)(selItem.ItemClass)).MaxPerUnit)
		{
			int size = selItem.Amounts.Size();
			for (int i = 0; i < size; ++i)
			{
				vector2 off = (-160 + 42 * (i / 10) - 2 * i, yOff + 90 + 12 * (i % 10));
				sb.DrawImage(selItem.Icons[i], off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, OperationAmount > i ? 1.0 : 0.5, (10, 20), (4.0, 4.0));
			}
			for (int i = 0; i < size; ++i)
			{
				int magAmt = selItem.Amounts[i];
				if (magAmt == 51 && selItem.ItemClass is 'HD4mMag')
				{
					magAmt = 50;
				}
				vector2 off = (-160 + 42 * (i / 10) - 2 * i, yOff + 90 + 12 * (i % 10));
				sb.DrawString(sb.mAmountFont, sb.FormatNumber(magAmt, 1, 4), off + (5, 3), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_YELLOW, OperationAmount > i ? 1.0 : 0.5);
			}
		}
		else if (selItem.ItemClass is 'HDWeapon' && selItem.Amounts.Size() > 0 && selItem.Amounts[0] > 1)
		{
			// [Ace] Don't display the first weapon. It's already in the preview.
			for (int i = 1; i < selItem.Amounts[0]; ++i)
			{
				vector2 Off = (-120 + 60 * ((i - 1) % 5), yOff + 90 + 30 * ((i - 1) / 5));
				sb.DrawImage(selItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (50, 20), (4.0, 4.0));
			}
		}
	}

	override void ActualPickup(Actor other, bool silent)
	{
		if (other.player && other.player.cmd.buttons & BT_ZOOM && other.player.cmd.buttons & BT_FIREMODE)
		{
			other.A_StartSound("weapons/pocket");
			other.A_Log("Your storage has expanded.", true);
			Storage = DSDStorageThinker.Get(other.PlayerNumber());
			Storage.MaxBulk += 500;
			if (WeaponStatus[DSDProp_Battery] >= 0)
			{
				HDMagAmmo.GiveMag(other, 'HDBattery', WeaponStatus[DSDProp_Battery]);
			}
			Destroy();
			return;
		}
		Super.ActualPickup(other, silent);
	}

	private action void A_Sort(bool ascending)
	{
		A_UpdateStorage();
		StorageItem selItem = invoker.Storage.GetSelectedItem();
		int size = selItem.Amounts.Size();
		if (size > 1) // [Ace] It's a mag.
		{
			for (int i = 0; i < size - 1; ++i)
			{
				for (int j = i + 1; j < size; ++j)
				{
					if (!ascending && selItem.Amounts[i] > selItem.Amounts[j] || ascending && selItem.Amounts[i] < selItem.Amounts[j])
					{
						let swpAmt = selItem.Amounts[i]; selItem.Amounts[i] = selItem.Amounts[j]; selItem.Amounts[j] = swpAmt; 
						let swpBulk = selItem.Bulks[i]; selItem.Bulks[i] = selItem.Bulks[j]; selItem.Bulks[j] = swpBulk; 
						let swpIcon = selItem.Icons[i]; selItem.Icons[i] = selItem.Icons[j]; selItem.Icons[j] = swpIcon; 
					}
				}
			}
		}
	}

	private int OperationAmount;
	private string ConfigString;
	private int StartingCapacity;

	Default
	{
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		-HDWEAPON.DROPTRANSLATION
		-HDWEAPON.FITSINBACKPACK
		+HDWEAPON.ALWAYSSHOWSTATUS
		+HDWEAPON.IGNORELOADOUTAMOUNT
		HDWeapon.WornLayer 0;
		Weapon.SelectionOrder 1010;
		Inventory.Icon "DSDDA0";
		Inventory.PickupMessage "$PICKUP_DSD";
		Inventory.PickupSound "weapons/pocket";
		Tag "$TAG_DSD";
		HDWeapon.RefId "dsd";
		Scale 0.5;
		HDWeapon.loadoutcodes "
			\cucap - 0-???, Overrides the capacity of the Dimensional Storage Device.
			\cuNOTE: THIS IS CONSIDERED A CHEAT.
		";
	}
	
	States
	{
		Spawn:
			DSDD A -1 Light("DSDLight");
			Stop;
		Select0:
			TNT1 A 1
			{
				invoker.OperationAmount = 1;
				A_UpdateStorage(); // [Ace] Populates items.
				A_StartSound("weapons/pocket", CHAN_WEAPON);
			}
			TNT1 A 0 A_Raise(999);
			Wait;
		Deselect0:
			TNT1 A 0 A_Lower(999);
			Wait;
		Ready:
			TNT1 A 1
			{
				if (PressingFiremode())
				{
					if (JustPressed(BT_ATTACK))
					{
						invoker.OperationAmount++;
					}
					else if (JustPressed(BT_ALTATTACK))
					{
						invoker.OperationAmount--;
					}

					int InputAmount = GetMouseY(true);
					if (InputAmount != 0)
					{
						invoker.OperationAmount += int(ceil(InputAmount / 64.0));
					}

					invoker.OperationAmount = clamp(invoker.OperationAmount, 1, 200);
				}
				else
				{
					invoker.RepeatTics--;
					A_WeaponReady(WRF_ALLOWUSER3);
					if (JustPressed(BT_ALTRELOAD))
					{
						A_Sort(PressingUse());
					}
					if (JustPressed(BT_ATTACK))
					{
						A_UpdateStorage();
						invoker.Storage.PrevItem();
					}
					else if (JustPressed(BT_ALTATTACK))
					{
						A_UpdateStorage();
						invoker.Storage.NextItem();
					}

					if (invoker.RepeatTics <= 0)
					{
						if (PressingReload())
						{
							if (PressingUse())
							{
								if (invoker.WeaponStatus[DSDProp_Battery] == -1)
								{
									SetWeaponState('InsertBattery');
								}
								return;
							}
							if (invoker.WeaponStatus[DSDProp_Battery] >= 1)
							{
								A_UpdateStorage();
								StorageItem selItem = invoker.Storage.GetSelectedItem();
								if (selItem)
								{
									int inserted = invoker.Storage.TryInsertItem(selItem.InvRef, self, invoker.OperationAmount);
									invoker.RepeatTics = invoker.Storage.GetOperationSpeed(selItem.ItemClass, SIIAct_Insert);
									if (inserted > 0)
									{
										invoker.WeaponStatus[DSDProp_Battery] -= 1;
									}
								}
							}
						}
						else if (PressingUnload())
						{
							if (PressingUse())
							{
								if (invoker.WeaponStatus[DSDProp_Battery] > -1)
								{
									SetWeaponState('RemoveBattery');
								}
								return;
							}
							if (invoker.WeaponStatus[DSDProp_Battery] >= 1)
							{
								A_UpdateStorage();
								StorageItem selItem = invoker.Storage.GetSelectedItem();
								if (selItem)
								{
									Inventory removed = invoker.Storage.RemoveItem(selItem, self, null, invoker.OperationAmount);
									invoker.RepeatTics = invoker.Storage.GetOperationSpeed(selItem.ItemClass, SIIAct_Extract);
									if (removed)
									{
										invoker.WeaponStatus[DSDProp_Battery] -= 1;
									}
								}
							}
						}
					}
				}
			}
			Goto ReadyEnd;
		RemoveBattery:
			TNT1 A 20;
			TNT1 A 5
			{
				int charge = invoker.WeaponStatus[DSDProp_Battery];
				if (PressingUnload() || PressingReload())
				{
					HDBattery.GiveMag(self, "HDBattery", charge);
					A_StartSound("weapons/pocket", 9);
					A_SetTics(20);
				}
				else
				{
					HDBattery.SpawnMag(self, "HDBattery", charge);
				}
				invoker.WeaponStatus[DSDProp_Battery] = -1;
			}
			Goto Ready;
		InsertBattery:
			TNT1 A 14 A_StartSound("weapons/pocket", 9);
			TNT1 A 5
			{
				let bat = HDBattery(FindInventory('HDBattery'));
				if (!bat)
				{
					return;
				}
				invoker.WeaponStatus[DSDProp_Battery] = bat.TakeMag(true);
				A_StartSound("weapons/vulcopen1", 8, CHANF_OVERLAP);
			}
			Goto Ready;
		User3:
			TNT1 A 0 A_SelectWeapon("MagManager");
			Goto Ready;
	}
}

class DSDSpawnEffect : Actor
{
	Default
	{
		+NOINTERACTION
		Renderstyle "Add";
		Scale 0.5;
	}

	States
	{
		Spawn:
			DSDE A 0 NoDelay
			{
				A_StartSound("DSD/Unload", pitch: 0.7);
				for (int i = 0; i < 150; ++i)
				{
					A_SpawnParticle(0x88BBFF, SPF_RELATIVE | SPF_FULLBRIGHT, random(8, 12), frandom(2, 3), random(0, 359), 32, 0, 0, -2, 0, frandom(3.5, 4));
					A_SpawnParticle(0x88BBFF, SPF_RELATIVE | SPF_FULLBRIGHT, random(8, 12), frandom(2, 3), random(0, 359), 32, 0, 0, -2, 0, -frandom(3.5, 4));
				}
			}
			DSDE ABABCDEFGHIJ 3 Bright;
			Stop;
	}
}
