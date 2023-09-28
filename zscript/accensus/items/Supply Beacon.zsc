class SupplyOrder play
{
	HDPickup InvRef;
	class<HDPickup> Type;

	static SupplyOrder Create(HDPickup ref)
	{
		let order = new('SupplyOrder');
		order.InvRef = ref;
		order.Type = ref.GetClass();
		return order;
	}

	static bool IsValidType(HDPickup item)
	{
		if (!item)
		{
			return false;
		}

		// [Ace] Explicitly valid items.
		bool isValidAnyway = false;
		switch (item.GetClassName())
		{
			case 'DespicytoFilter':
			case 'FourMilAmmo':
				isValidAnyway = true;
				break;
		}

		return isValidAnyway || item is 'HDAmmo' && !item.bCHEATNOGIVE && (item is 'PortableStimpack' || !item.bINVBAR);
	}

	clearscope int, int GetDropAmount(int itemCount)
	{
		double divFac = max(1, itemCount * 0.75);
		int minAmt = int(500 / divFac);
		int maxAmt = int(800 / divFac);

		double finalDiv = 1;
		if (!(Type is 'HDRoundAmmo'))
		{
			finalDiv += 40;
			if (Type is 'HDMagAmmo' && GetDefaultByType((class<HDMagAmmo>)(Type)).MagBulk > 0)
			{
				finalDiv += 15;
			}
			if (Type is 'PortableStimpack')
			{
				finalDiv += 15;
			}
		}

		if (Type is 'FourMilAmmo')
		{
			finalDiv = 0.5;
		}

		return int(minAmt / finalDiv), int(maxAmt / finalDiv);
	}
}

class HDSupplyBeacon : HDWeapon
{
	enum SBProperty
	{
		SBProp_Flags,
		SBProp_UseOffset
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		return Active && other.bSOLID && !other.player || Super.CanCollideWith(other, passive);
	}

	override void DoEffect()
	{
		for (int i = 0; i < SlotCount; ++i)
		{
			if (Slots[i] && (!Slots[i].InvRef || !Slots[i].InvRef.owner))
			{
				Slots[i].Destroy();
			}
		}
		Super.DoEffect();
	}

	private action void A_AddOffset(int ofs)
	{
		invoker.WeaponStatus[SBProp_UseOffset] += ofs;
	}

	private action void A_FetchAvailableItems()
	{
		invoker.AvailableItems.Clear();
		for (Inventory next = Inv; next != null; next = next.Inv)
		{
			if (SupplyOrder.IsValidType(HDPickup(next)))
			{
				invoker.AvailableItems.Push(SupplyOrder.Create(HDPickup(next)));
			}
		}
		invoker.SelIndex = clamp(invoker.SelIndex, 0, invoker.AvailableItems.Size() - 1);
	}

	private action void A_CheckCycle(int cycleDir)
	{
		A_FetchAvailableItems();
		int size = invoker.AvailableItems.Size();
		if (size == 0)
		{
			return;
		}
		switch (cycleDir)
		{
			case 1:
				++invoker.SelIndex %= size;
				break;
			case -1:
				invoker.SelIndex = invoker.SelIndex == 0 ? invoker.AvailableItems.Size() - 1 : invoker.SelIndex - 1;
				break;
		}
	}

	private action bool A_CheckIfLoaded(class<HDPickup> cls)
	{
		for (int i = 0; i < SlotCount; ++i)
		{
			if (invoker.Slots[i] && invoker.Slots[i].Type == cls)
			{
				return true;
			}
		}
		return false;
	}

	clearscope action int A_GetLoadedItemCount()
	{
		int count = 0;
		for (int i = 0; i < SlotCount; ++i)
		{
			if (invoker.Slots[i])
			{
				count++;
			}
		}
		return count;
	}

	override void ActualPickup(Actor other, bool silent)
	{
		Active = false;
		FullHeight = 0;
		ArrivalTicker = 0;
		Super.ActualPickup(other, silent);
	}
	override bool AddSpareWeapon(Actor newowner) {return AddSpareWeaponRegular(newowner);}
	override HDWeapon GetSpareWeapon(Actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }
	override string, double GetPickupSprite() { return "SPBCZ0", 1.0; }
	override string GetHelpText()
	{
		return WEPHELP_FIREMODE.."+"..WEPHELP_FIRE.."(hold)  Deploy\n"
		..WEPHELP_FIRE.."/"..WEPHELP_ALTFIRE.."  Cycle ammo\n"
		..WEPHELP_RELOAD.."  Load ammo\n"
		..WEPHELP_UNLOAD.."  Unload ammo";
	}
	override double WeaponBulk() { return 40; }
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		vector2 bob = hpl.wepbob * 0.3;
		int offset = WeaponStatus[SBProp_UseOffset];
		bob.y += offset;

		sb.DrawImage(GetPickupSprite(), bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, box: (60, 60), scale: (2.0, 2.0));

		int size = AvailableItems.Size();
		if (size > 0 && SelIndex < size && AvailableItems[SelIndex])
		{
			//sb.DrawImage(ItemStorage.GetIcon(AvailableItems[SelIndex].InvRef, invIconFirst: true), (0, 95) + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_BOTTOM, box: (30, 30), scale: (5.0, 5.0));
			sb.DrawString(sb.pSmallFont, AvailableItems[SelIndex].InvRef.GetTag(), (0, 100) + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_WHITE);
		}
		else if (offset < 5)
		{
			sb.DrawString(sb.pSmallFont, "No ammo selected.", (0, 80) + bob, sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GOLD);
		}

		int totalLoaded = A_GetLoadedItemCount();
		for (int i = 0; i < Slots.Size(); ++i)
		{
			if (!Slots[i])
			{
				continue;
			}

			vector2 imagePos = (-35 * cos(90 * i), 35 * sin(90 * i));

			//sb.DrawImage(ItemStorage.GetIcon(Slots[i].InvRef, invIconFirst: true), imagePos + bob, sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, box: (15, 15), scale: (5.0, 5.0));

			int minAmt, maxAmt;
			[minAmt, maxAmt] = Slots[i].GetDropAmount(totalLoaded);

			int textFlags = 0;
			vector2 textPos = (-50 * cos(90 * i), 50 * sin(90 * i));
			textPos.y -= sb.pSmallFont.mFont.GetHeight() / 2;
			switch (i)
			{
				case 0: textFlags = sb.DI_TEXT_ALIGN_RIGHT; break;
				case 2: textFlags = sb.DI_TEXT_ALIGN_LEFT; break;
				case 1:
				case 3: textFlags = sb.DI_TEXT_ALIGN_CENTER; break;
			}
			sb.DrawString(sb.pSmallFont, minAmt.."-"..maxAmt, textPos + bob, sb.DI_SCREEN_CENTER | textFlags, Font.CR_WHITE);
		}
	}

	const SlotCount = 4;

	private Array<SupplyOrder> AvailableItems;
	SupplyOrder Slots[SlotCount];
	private int SelIndex;

	private PointLight DynLight;
	private double FullHeight;
	bool Active;
	private int ArrivalTicker;
	private Actor PrevOwner;
	private int ActivationDelay;

	Default
	{
		+HDWEAPON.DROPTRANSLATION
		+HDWEAPON.FITSINBACKPACK
		+INVENTORY.INVBAR
		+WEAPON.WIMPY_WEAPON
		+CANPASS
		HDWeapon.RefID "spb";
		Inventory.MaxAmount 5;
		Inventory.Icon "SPBCZ0";
		Inventory.PickupMessage "$PICKUP_SUPPLYBEACON";
		Inventory.PickupSound "weapons/pocket";
		Tag "$TAG_SUPPLYBEACON";
	}

	States
	{
		Spawn:
			SPBC A 1
			{
				if (invoker.Active && invoker.vel.length() < 1 && ++invoker.ActivationDelay >= 10)
				{
					if (AceCore.IsSkyAbove(invoker))
					{
						SetStateLabel('WindUp');
						return;
					}
					else
					{
						if (invoker.PrevOwner)
						{
							invoker.PrevOwner.A_Log("Insufficient space for drop pod to land. Please relocate beacon.", true);
						}
						invoker.Active = false;
					}
				}
			}
			Loop;
		WindUp:
			SPBC BCDEFG 4;
			SPBC CDEFG 4;
			SPBC CDEFG 3;
			SPBC CDEFG 2;
			SPBC C 0
			{
				invoker.DynLight = PointLight(Spawn("HDSupplyBeaconLight"));
				invoker.DynLight.master = self;
				invoker.DynLight.Args[0] = fillcolor.r;
				invoker.DynLight.Args[1] = fillcolor.g;
				invoker.DynLight.Args[2] = fillcolor.b;
			}
		Speen:
			SPBC CCDDEEFFGG 1
			{
				if (!AceCore.IsSkyAbove(invoker))
				{
					if (invoker.PrevOwner)
					{
						invoker.PrevOwner.A_Log("Insufficient space for drop pod to land. Please relocate beacon.", true);
					}
					invoker.Active = false;
					SetStateLabel('Spawn');
					return;
				}

				if (bINVISIBLE)
				{
					return;
				}
				
				if (invoker.FullHeight < 128)
				{
					invoker.FullHeight += 16;
					if (invoker.DynLight)
					{
						invoker.DynLight.Args[3] = int(invoker.FullHeight * 1.2);
					}
				}
				A_StartSound("SupplyBeacon/Idle", 7, CHANF_NOSTOP | CHANF_LOOP, 0.20);
				for (double i = 0; i < invoker.FullHeight; i += invoker.FullHeight / 128.0)
				{
					A_SpawnParticle(fillcolor, SPF_FULLBRIGHT, 1, 16 + i ** 1.14, 0, 0, 0, 3 + i * 3, startalphaf: 0.30 * (1.0 - i / invoker.FullHeight));
				}
				if (++invoker.ArrivalTicker == 350)
				{
					invoker.bNOINTERACTION = true;
					invoker.A_SpawnItemEx('HDSupplyDropPod', 0, 0, ceilingz - floorz, 0, 0, -80, 180, flags: SXF_SETMASTER | SXF_NOCHECKPOSITION);
				}
				for (int i = 0; i < 360; ++i)
				{
					double fac = 1.0 - invoker.ArrivalTicker / 350.0;
					A_SpawnParticle(fillcolor, SPF_RELATIVE, 1, 4 + 28 * fac, i, 8 + 248 * fac, startalphaf: 0.3);
				}
			}
			Loop;
		Select:
			TNT1 A 0
			{
				A_FetchAvailableItems();
				A_AddOffset(100);
			}
			Goto Super::Select;
		Ready:
			TNT1 A 1
			{
				int off = invoker.WeaponStatus[SBProp_UseOffset];
				if (off > 0)
				{
					invoker.WeaponStatus[SBProp_UseOffset] = off * 2 / 3;
				}

				if (PressingFiremode() && (PressingFire() || PressingAltfire()))
				{
					SetWeaponState("Lower");
					return;
				}

				A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER3 | WRF_ALLOWUSER4);
			}
			Goto ReadyEnd;
		Lower:
			TNT1 AA 1 A_AddOffset(6);
			TNT1 AAAA 1 A_AddOffset(18);
			TNT1 AAAAA 1 A_AddOffset(36);
			TNT1 A 0 A_JumpIf(!PressingFire() && !PressingAltfire(), "Ready");
			TNT1 A 1
			{
				int loadedAmmoCount = A_GetLoadedItemCount();
				if (loadedAmmoCount == 0)
				{
					SetWeaponState('Nope');
					return;
				}
				invoker.Active = true;
				invoker.SetShade(player.GetColor());
				invoker.PrevOwner = invoker.owner;
				invoker.ActivationDelay = 0;
				DropInventory(invoker);
			}
			Wait;
		Fire:
			TNT1 A 1 A_CheckCycle(1);
			Goto Nope;
		AltFire:
			TNT1 A 1 A_CheckCycle(-1);
			Goto Nope;
		Unload:
			TNT1 A 1
			{
				for (int i = SlotCount - 1; i >= 0; --i)
				{
					if (invoker.Slots[i])
					{
						A_StartSound("weapons/pocket", 9);
						A_SetTics(12);
						invoker.Slots[i] = null;
						break;
					}
				}
			}
			Goto Ready;
		Reload:
			TNT1 A 1
			{
				int size = invoker.AvailableItems.Size();
				if (size > 0 && invoker.SelIndex < size && !A_CheckIfLoaded(invoker.AvailableItems[invoker.SelIndex].Type))
				{
					for (int i = 0; i < SlotCount; ++i)
					{
						if (!invoker.Slots[i])
						{
							A_StartSound("weapons/pocket", 9);
							A_SetTics(12);
							invoker.Slots[i] = invoker.AvailableItems[invoker.SelIndex];
							break;
						}
					}
				}
			}
			Goto Ready;
	}
}

class HDSupplyDropPod : Actor
{
	override void PostBeginPlay()
	{
		for (int i = 0; i < 360; ++i)
		{
			A_SpawnParticle(0xFFFFFF, SPF_RELATIVE, random(20, 35), random(8, 24), i, 128, 0, 0, frandom(32, 64), 0, frandom(-5.000, 0), -1.5, sizestep: frandom(6.0, 12.0));
			A_SpawnParticle(0xFFFFFF, SPF_RELATIVE, random(20, 35), random(8, 24), i, 128, 0, 0, frandom(32, 64), 0, frandom(-5.000, 0), -1.5, sizestep: frandom(6.0, 12.0));

			for (int j = 0; j < 2; ++j)
			{
				double distFromCenter = frandom(radius * 2, 384);
				double distFac = (1.0 - distFromCenter / 196.0);
				A_SpawnParticle(0xFFFFFF, SPF_RELATIVE, random(16, 24), random(8, 24), random(0, 359),
					distFromCenter, 0, 0,
					0, 0, max(0.01, distFac) * frandom(-48, -32),
					-0.02, 0, 2 * max(0.01, distFac),
					sizestep: frandom(0.25, 0.75));
			}

		}
		Super.PostBeginPlay();
	}

	Default
	{
		+SOLID
		+NODAMAGETHRUST
		Mass 1000;
		Radius 15;
		Height 40;
	}

	States
	{
		RegisterSprites:
			SPDP A 0; SPDB A 0;

		Spawn:
			#### A 1 NoDelay
			{
				switch (CVar.GetCVar('sb_skin', players[consoleplayer]).GetInt())
				{
					default: sprite = GetSpriteIndex("SPDP"); scale = (0.7, 0.7); break;
					case 1: sprite = GetSpriteIndex("SPDB"); break;
				}
			}
			#### A 0 A_JumpIf(pos.z ~== floorz, 'Hoard');
			#### A 0 A_ScaleVelocity(1.05);
			Loop;
		Hoard:
			#### A 25
			{
				master.bINVISIBLE = true;
				DistantQuaker.Quake(self, 7, 70, 1024, 8, 128, 256, 256);
				A_StartSound("SupplyPod/Slam", CHAN_VOICE, attenuation: 0.2);
				A_Explode(40000, int(HDCONST_ONEMETRE * 3), damagetype: 'Bashing');
				bool success; Actor a;
				for (int i = 0; i < 100; ++i)
				{
					[success, a] = A_SpawnItemEx('HDSmoke', radius, 0, 0, frandom(1.0, 20.0), 0, frandom(0, 4.0), random(0, 359));
					a.scale *= frandom(0.75, 2.5);
					[success, a] = A_SpawnItemEx('WallChunk', radius, 0, 0, frandom(1.0, 20.0), 0, frandom(2.0, 12.0), random(0, 359));
					a.scale *= frandom(1.0, 4.0);
				}
			}
			#### B 5 A_StartSound("SupplyPod/Open", pitch: 0.85);
			#### CD 5;
			#### E 5
			{
				let beacon = HDSupplyBeacon(master);
				int totalLoaded = beacon.A_GetLoadedItemCount();

				bool success; Actor a;
				for (int i = 0; i < beacon.SlotCount; ++i)
				{
					if (!beacon.Slots[i])
					{
						continue;
					}

					int minAmt, maxAmt;
					[minAmt, maxAmt] = beacon.Slots[i].GetDropAmount(totalLoaded);

					[success, a] = A_SpawnItemEx(beacon.Slots[i].Type, radius / 2, 0, height / 3, frandom(2.0, 2.25), frandom(0.15, 0.4), frandom(2.0, 4.0), -90 + 90 * i, SXF_NOCHECKPOSITION);
					Inventory(a).Amount = random(minAmt, maxAmt);
				}
				beacon.Destroy();
			}
			#### F -1;
			Stop;
	}
}

class HDSupplyBeaconLight : PointLight
{
	override void Tick()
	{
		if (!master || master.bINVISIBLE || Inventory(master).owner || !HDSupplyBeacon(master).Active)
		{
			Destroy();
			return;
		}

		Warp(master, flags: WARPF_NOCHECKPOSITION);

		Super.Tick();
	}
}
