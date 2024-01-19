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
	string SearchString;
	bool InSearchMode;

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

	override int CheckConditions(
		Inventory item,
		class<Inventory> cls
	){
		if (item)
		{
			let wpn = HDWeapon(item);
			let mag = HDMagAmmo(item);
			let pkp = HDPickup(item);

			if(
				item.bNOINTERACTION
				||item.bUNDROPPABLE
				||item.bUNTOSSABLE
				||(
					//container that is in use
					item is 'HDBackpack'
					&&HDBackpack(item).Storage
					&&HDBackpack(item).Storage.TotalBulk>0
				)||(
					//pickup that does not fit in backpack
					pkp
					&&!pkp.bFITSINBACKPACK
				)
			)return IType_Invalid;

			//some exceptions only apply to weapons
			if(
				wpn
				// &&!wpn.bINVBAR
				&&!wpn.bCHEATNOTWEAPON
			)return IType_Weapon;

			if(mag)return IType_Mag;
			if(pkp)return IType_Pickup;
		}
		else if (cls)
		{
			let dls=GetDefaultByType((class<Inventory>)(cls));
			let wpn = cls is 'HDWeapon' ? GetDefaultByType((class<HDWeapon>)(cls)) : null;
			let mag = cls is 'HDMagAmmo' ? GetDefaultByType((class<HDMagAmmo>)(cls)) : null;
			let pkp = cls is 'HDPickup' ? GetDefaultByType((class<HDPickup>)(cls)) : null;

			if(
				dls.bNOINTERACTION
				||dls.bUNDROPPABLE
				||dls.bUNTOSSABLE
				||dls.GetTag()==dls.GetClassName()
				||(
					pkp
					&&!pkp.bFITSINBACKPACK
				)
			)return IType_Invalid;

			if(
				wpn
				&&!wpn.bCHEATNOTWEAPON
				// &&!wpn.bINVBAR
			)return IType_Weapon;

			if(mag)return IType_Mag;
			if(pkp)return IType_Pickup;
		}

		return IType_Invalid;
	}

	override int GetOperationSpeed(
		class<Inventory> item,
		int operation
	){
		let wpn = (class<HDWeapon>)(item);
		let pkp = (class<HDPickup>)(item);
		bool multipickup=pkp && GetDefaultByType(pkp).bMULTIPICKUP;
		switch (operation){
			case SIIAct_Extract:return wpn ? 20 : multipickup ? 6 : 6;
			case SIIAct_Insert:return wpn ? 20 : multipickup ? 6 : 6;
			default:break;
		}
		return 20;
	}

	override string GetFailMessage() const
	{
		return Stringtable.Localize("$DSD_TOOFULL");
	}

	override Inventory RemoveItem(StorageItem item, Actor remover, Actor receiver, int amt, int index, int flags)
	{
		if (!item || item.Amounts.Size() == 0 || amt < 1)
		{
			return null;
		}

		let wpn = (class<HDWeapon>)(item.ItemClass);
		let mag = (class<HDMagAmmo>)(item.ItemClass);
		let pkp = (class<HDPickup>)(item.ItemClass);

		Inventory Spawned = null;
		vector3 SpawnPos = (0, 0, 0);
		if (remover)
		{
			for (int i = 64; i >= 0; i -= 8)
			{
				SpawnPos = remover.Vec3Angle(i - 8, remover.angle, remover.height / 2 + 6);
				if (level.IsPointInLevel(SpawnPos)) break;
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
					Spawned = Inventory(Actor.Spawn(wpn, SpawnPos));
					HDWeapon newwpn = HDWeapon(Spawned);
					newwpn.bdontdefaultconfigure=true;
					for (int i = 0; i < HDWEP_STATUSSLOTS; ++i)
					{
						newwpn.WeaponStatus[i] = item.WeaponStatus[HDWEP_STATUSSLOTS * index + i];
					}
					if (receiver)
					{
						newwpn.ActualPickup(receiver, flags & BF_SILENT);
					}
					if (newwpn.bDROPTRANSLATION)
					{
						newwpn.Translation = remover.Translation;
					}
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
		else if (mag)
		{
			index = min(index, item.Amounts.Size() - 1);
			amt = min(amt, item.Amounts.Size());
			if (remover && !(flags & BF_FROMCONSOLIDATE))
			{
				Actor.Spawn("DSDSpawnEffect", SpawnPos);
			}
			for (int i = 0; i < amt; ++i)
			{
				if (remover)
				{
					Spawned = Inventory(Actor.Spawn(mag, SpawnPos));
					HDMagAmmo newmag = HDMagAmmo(Spawned);
					newmag.Mags[0]=item.Amounts[0];
					if (receiver)
					{
						newmag.ActualPickup(receiver, true);
					}
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
				Spawned = Inventory(Actor.Spawn(pkp, SpawnPos));
				HDPickup newpkp = HDPickup(Spawned);
				newpkp.Amount = amt;
				if (receiver)
				{
					newpkp.ActualPickup(receiver, true);
				}
			}
			item.Bulks[0] -= amt * GetDefaultByType(pkp).Bulk;
			item.Amounts[0] -= amt;
			if (item.Amounts[0] == 0)
			{
				item.Amounts.Delete(0);
			}
		}
		if(Spawned){
			Spawned.angle = remover.angle;
			Spawned.A_ChangeVelocity(1.5*cos(remover.pitch),0,1.-1.5*sin(remover.pitch),CVF_RELATIVE);
			Spawned.vel += remover.vel;
		}

		RemoveNullOrEmpty(remover);
		CalculateBulk();
		return Spawned;
	}
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

	override void UpdateCapacity(){
		// no-op
	}

	override bool IsBeingWorn() { return false; }
	override string, double GetPickupSprite() { return "DSDDA0", 1.0; }
	override double WeaponBulk() { return 60; }
	override string GetHelpText(){
		LocalizeHelp();
		return LWPHELP_FIRE.."/"..LWPHELP_ALTFIRE..StringTable.Localize("$BPWH_PNI")
		..LWPHELP_FIREMODE.."+"..LWPHELP_UPDOWN..StringTable.Localize("$DSDWH_FMODPUD")
		..LWPHELP_RELOAD..StringTable.Localize("$BPWH_RELOAD")
		..LWPHELP_UNLOAD..StringTable.Localize("$BPWH_UNLOAD")
		..WEPHELP_BTCOL.."Enter"..WEPHELP_RGCOL..StringTable.Localize("$DSDWH_ENTER")
		..LWPHELP_ALTRELOAD.."(+"..LWPHELP_USE..")"..StringTable.Localize("$DSDWH_USEALTRELOAD")
		..LWPHELP_USE.."(hold) + "..LWPHELP_RELOAD..StringTable.Localize("$DSDWH_USERELOAD")
		..LWPHELP_USE.."(hold) + "..LWPHELP_UNLOAD..StringTable.Localize("$DSDWH_USEUNLOAD");
	}

	//configure from loadout
	override void LoadoutConfigure(string input){
		ConfigString = input;
		StartingCapacity = GetLoadoutVar(input, "cap", 5);
	}

	override void DropOneAmmo(int amt)
	{
		// no-op
	}

	override bool CanGrabInsert(Inventory item, class<Inventory> item, Actor grabber) {return false;}

	override void Consolidate(){Storage.Consolidate(owner);}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl){
		int BaseOffset = -80;

		if (WeaponStatus[DSDProp_Battery] > -1)
		{
			sb.DrawImage(AceCore.GetBatteryColor(WeaponStatus[DSDProp_Battery]), (0, BaseOffset - 5), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER_BOTTOM, box: (-1, 20), scale: (2.0, 2.0));
		}

		sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_TOP"), (0, BaseOffset), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
		sb.DrawString(sb.pSmallFont, Stringtable.Localize("$BACKPACK_TOTALBULK")..int(Storage.TotalBulk).."/"..int(Storage.MaxBulk).."\c-", (0, BaseOffset + 10), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
		if (WeaponStatus[DSDProp_Battery] <= 0)
		{
			if (level.time % 50 < 25)
			{
				sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_INOPERABLE"), (0, BaseOffset + 20), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_RED);
			}
		}
		else
		{
			sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_OPERATIONSLEFT")..(WeaponStatus[DSDProp_Battery]), (0, BaseOffset + 20), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GREEN);
		}

		BaseOffset += 40;

		int ItemCount = Storage.Items.Size();

		if(!ItemCount){
			sb.DrawString(sb.pSmallFont, Stringtable.Localize("$BACKPACK_NOITEMS"), (0, BaseOffset), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_DARKGRAY);
			return;
		}
		
		StorageItem SelItem = Storage.GetSelectedItem();
		if(!SelItem)return;

		for(int i = 0; i < (ItemCount > 1 ? 5 : 1); ++i){
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
			sb.DrawImage(CurItem.Icons[0], (Offset.x, BaseOffset + 10 + Offset.y), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, CenterItem && !CurItem.HaveNone() ? 1.0 : 0.6, CenterItem ? (50, 30) : (30, 20), getdefaultbytype(CurItem.ItemClass).scale*(CenterItem?4.0:3.0));
		}
		
		sb.DrawString(sb.pSmallFont, SelItem.NiceName, (0, BaseOffset + 30), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_FIRE);

		int AmountInBackpack = SelItem.ItemClass is 'HDMagAmmo' ? SelItem.Amounts.Size() : (SelItem.Amounts.Size() > 0 ? SelItem.Amounts[0] : 0);
		sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_INBAG")..sb.FormatNumber(AmountInBackpack, 1, 6), (0, BaseOffset + 40), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountInBackpack > 0 ? Font.CR_BROWN : Font.CR_DARKBROWN);

		int AmountOnPerson = GetAmountOnPerson(hpl.FindInventory(SelItem.ItemClass));
		sb.DrawString(sb.pSmallFont, StringTable.Localize("$BACKPACK_ONPERSON")..sb.FormatNumber(AmountOnPerson, 1, 6), (0, BaseOffset + 48), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, AmountOnPerson > 0 ?  Font.CR_WHITE : Font.CR_DARKGRAY);

		if ((SelItem.ItemClass is 'HDPickup') && !(SelItem.ItemClass is 'HDArmour'))
		{
			sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_INSERTREMOVE")..sb.FormatNumber(OperationAmount, 1, 3), (0, BaseOffset + 56), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_SAPPHIRE);
		}

		if (DSDStorage(Storage).InSearchMode)
		{
			sb.DrawString(sb.pSmallFont, StringTable.Localize("$DSD_SEARCHING")..DSDStorage(Storage).SearchString.."_", (-60, BaseOffset + 64), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_WHITE);
		}

		if (SelItem.ItemClass is 'HDArmour')
		{
			for (int i = 0; i < SelItem.Amounts.Size(); ++i)
			{
				vector2 Off = (-126 + 35 * (i % 8), BaseOffset + 90 + 35 * (i / 8));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (30, 20), (4.0, 4.0));
				sb.DrawString(sb.mAmountFont, sb.FormatNumber(SelItem.Amounts[i] > 1000 ? SelItem.Amounts[i] - 1000 : SelItem.Amounts[i], 1, 4), Off + (0, 12), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_YELLOW);
			}
		}
		else if (SelItem.ItemClass is 'HDMagAmmo' && GetDefaultByType((class<HDMagAmmo>)(SelItem.ItemClass)).MaxPerUnit)
		{
			for (int i = 0; i < SelItem.Amounts.Size(); ++i)
			{
				vector2 Off = (-160 + 42 * (i / 10) - 2 * i, BaseOffset + 90 + 12 * (i % 10));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, OperationAmount > i ? 1.0 : 0.5, (10, 20), (4.0, 4.0));
				int magAmt = SelItem.Amounts[i];
				if (magAmt == 51 && SelItem.ItemClass is 'HD4mMag') magAmt = 50;

				// Account for Magazines that leverage the "recast" mechanic by only considering the "total rounds" portion of the magAmt.
				name libMagName = 'HD7mMag';
				class<HDMagAmmo> libMag = (class<HDMagAmmo>)(libMagName);
				name cawsMagName = 'HD_CAWSMag';
				class<HDMagAmmo> cawsMag = (class<HDMagAmmo>)(cawsMagName);
				if (SelItem.ItemClass is libMag || SelItem.ItemClass is cawsMag) magAmt %= 100;

				Off = (-160 + 42 * (i / 10) - 2 * i, BaseOffset + 90 + 12 * (i % 10));
				sb.DrawString(sb.mAmountFont, sb.FormatNumber(magAmt, 1, 4), Off + (5, 3), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT, Font.CR_YELLOW, OperationAmount > i ? 1.0 : 0.5);
			}
		}
		else if (SelItem.ItemClass is 'HDWeapon' && SelItem.Amounts.Size() > 0 && SelItem.Amounts[0] > 1)
		{
			// [Ace] Don't display the first weapon. It's already in the preview.
			for (int i = 1; i < SelItem.Amounts[0]; ++i)
			{
				vector2 Off = (-120 + 60 * ((i - 1) % 5), BaseOffset + 90 + 30 * ((i - 1) / 5));
				sb.DrawImage(SelItem.Icons[i], Off, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, 1.0, (50, 20), (4.0, 4.0));
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

	protected action void A_DSDReady()
	{
		if (pressinguse())invoker.A_SetHelpText();

		if (PressingFiremode())
		{
			if (JustPressed(BT_ATTACK)) invoker.OperationAmount++;
			else if (JustPressed(BT_ALTATTACK)) invoker.OperationAmount--;

			int InputAmount = GetMouseY(true);
			if (InputAmount != 0) invoker.OperationAmount += int(ceil(InputAmount / 64.0));

			invoker.OperationAmount = clamp(invoker.OperationAmount, 1, 200);
		}
		else
		{
			invoker.RepeatTics--;
			A_WeaponReady(WRF_ALLOWUSER3);
			if (JustPressed(BT_ALTRELOAD)) A_Sort(PressingUse());
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
					}
					else if (invoker.WeaponStatus[DSDProp_Battery] >= 1)
					{
						A_UpdateStorage();
						StorageItem SelItem = invoker.Storage.GetSelectedItem();
						if (SelItem)
						{
							int inserted = invoker.Storage.TryInsertItem(SelItem.InvRef, self, invoker.OperationAmount);
							invoker.RepeatTics = invoker.Storage.GetOperationSpeed(SelItem.ItemClass, SIIAct_Insert);
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
					}
					else if (invoker.WeaponStatus[DSDProp_Battery] >= 1)
					{
						A_UpdateStorage();
						StorageItem SelItem = invoker.Storage.GetSelectedItem();
						if (SelItem)
						{
							Inventory removed = invoker.Storage.RemoveItem(SelItem, self, null, invoker.OperationAmount);
							invoker.RepeatTics = invoker.Storage.GetOperationSpeed(SelItem.ItemClass, SIIAct_Extract);
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

	override void InitializeWepStats(bool idfa){
		WeaponStatus[DSDProp_Battery] = -1;
	}

	private action void A_Sort(bool ascending)
	{
		A_UpdateStorage();
		StorageItem SelItem = invoker.Storage.GetSelectedItem();
		int size = SelItem.Amounts.Size();
		if (size > 1) // [Ace] It's a mag.
		{
			for (int i = 0; i < size - 1; ++i)
			{
				for (int j = i + 1; j < size; ++j)
				{
					if (!ascending && SelItem.Amounts[i] > SelItem.Amounts[j] || ascending && SelItem.Amounts[i] < SelItem.Amounts[j])
					{
						let swpAmt = SelItem.Amounts[i]; SelItem.Amounts[i] = SelItem.Amounts[j]; SelItem.Amounts[j] = swpAmt; 
						let swpBulk = SelItem.Bulks[i]; SelItem.Bulks[i] = SelItem.Bulks[j]; SelItem.Bulks[j] = swpBulk; 
						let swpIcon = SelItem.Icons[i]; SelItem.Icons[i] = SelItem.Icons[j]; SelItem.Icons[j] = swpIcon; 
					}
				}
			}
		}
	}

	private int OperationAmount;
	private string ConfigString;
	private int StartingCapacity;

	Default{
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		-HDWEAPON.DROPTRANSLATION
		-HDWEAPON.FITSINBACKPACK
		+HDWEAPON.ALWAYSSHOWSTATUS
		+HDWEAPON.IGNORELOADOUTAMOUNT
		Weapon.SelectionOrder 1010;
		Inventory.Icon "DSDDA0";
		Inventory.PickupMessage "$PICKUP_DSD";
		Inventory.PickupSound "weapons/pocket";
		Tag "$TAG_DSD";
		HDWeapon.RefId HDLD_DSD;
		Scale 0.5;
		HDWeapon.loadoutcodes "
			\cucap - 0-???, Overrides the capacity of the Dimensional Storage Device.
			\cuNOTE: THIS IS CONSIDERED A CHEAT.
		";
		HDWeapon.wornlayer 0;
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
			TNT1 A 1 A_DSDReady();
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
