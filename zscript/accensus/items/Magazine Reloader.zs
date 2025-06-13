class HDMagazineReloader : HDWeapon
{
	enum FAction
	{
		FAction_None,
		FAction_Reload,
		FAction_Unload
	}

	override string, double GetPickupSprite() { return "MRLDA0", 1.0; }
	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_RELOAD..Stringtable.Localize("$MRL_HELPTEXT_1")
		..LWPHELP_UNLOAD..Stringtable.Localize("$MRL_HELPTEXT_2");
	}
	override double GunMass() { return 0; }
	override double WeaponBulk() { return 35; }
	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner, bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }

	override void Tick()
	{
		Super.Tick();

		if (!owner && !IsFrozen() && FactoryAction != FAction_None && !IsBeingPickedUp)
		{
			if (ChargeUp < 360 && vel.length() <= 0.4)
			{
				ChargeUp += 10;
			}
			for (int i = 0; i < ChargeUp; ++i)
			{
				A_SpawnParticle(FactoryAction == FAction_Reload ? 0xFFFF33 : 0xFF7733, SPF_RELATIVE | SPF_FULLBRIGHT, 1, 10, -i, SearchRange, 0, floorz - pos.z, startalphaf: 0.10);
			}			
		}
	}

	override bool OnGrab(Actor other)
	{
		IsBeingPickedUp = true;

		return Super.OnGrab(other);
	}

	override void ActualPickup(actor other, bool silent)
	{
		Super.ActualPickup(other, silent);

		if (!other)
		{
			return;
		}

		if (LoadedMagType)
		{
			HDMagAmmo.GiveMag(other, LoadedMagType, LoadedMagRounds);
		}
		LoadedMagType = null;
		LoadedMagRounds = 0;

		while (LoadedRounds > 0)
		{
			if (other.A_JumpIfInventory(LoadedRoundsType, 0, "null"))
			{
				other.A_SpawnItemEx(LoadedRoundsType, 0, 0, other.height - 16, 2, 0, 1);
			}
			else
			{
				HDF.Give(other, LoadedRoundsType, 1);
			}
			LoadedRounds--;
		}
		LoadedRoundsType = null;

		FactoryAction = FAction_None;
		Active = false;
		IsBeingPickedUp = false;
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		vector2 bob = hpl.wepbob * 0.3;
		int BaseYOffset = -110;
		int Distance = 40;
		
		sb.DrawImage("MRLDA0", (0, BaseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER, alpha: 1.0, scale:(2, 2));
	}

	protected action void A_PopMag()
	{
		A_StartSound("roundmaker/pop", 10);
		Actor a; bool success;
		[success, a] = A_SpawnItemEx(invoker.LoadedMagType, 0, 0, 0, -1, -2, 3, 0, SXF_NOCHECKPOSITION);
		if (success)
		{
			let Mag = HDMagAmmo(a);
			Mag.Mags.Clear();
			Mag.Amount = 0;
			Mag.AddAMag(invoker.LoadedMagRounds);
			invoker.LoadedMagType = null;
			if (invoker.LoadedRounds > 0)
			{
				[success, a] = A_SpawnItemEx(invoker.LoadedRoundsType, 0, 0, 0, -0.5, 2, 3, 0, SXF_NOCHECKPOSITION);
				if (success)
				{
					Inventory(a).Amount = invoker.LoadedRounds;
				}
				invoker.LoadedRounds = 0;
				invoker.LoadedRoundsType = null;
			}
		}
		invoker.Active = false;
	}

	protected action bool A_IsBeingTethered(Actor other)
	{
		if (invoker.TractoredMag == other)
		{
			return true;
		}
		if (invoker.TractoredBox == other)
		{
			return true;
		}
		for (int i = 0; i < invoker.TractoredRounds.Size(); ++i)
		{
			if (invoker.TractoredRounds[i] && invoker.TractoredRounds[i] == other)
			{
				return true;
			}
		}
		return false;
	}

	const MinDist = 5.0;
	const SearchRange = HDCONST_ONEMETRE;
	private bool Active;
	private FAction FactoryAction;
	private class<HDMagAmmo> LoadedMagType;
	private int LoadedMagRounds;
	private class<Inventory> LoadedRoundsType;
	private int LoadedRounds;
	private int MaxToLoad;
	private int ChugTicker;
	private int ChargeUp;
	private bool IsBeingPickedUp;
	private HDMagAmmo TractoredMag;
	private HDAmmo TractoredRounds[5];
	private HDUPK TractoredBox;

	Default
	{
		MaxStepHeight 2;
		+WEAPON.WIMPY_WEAPON
		+INVENTORY.INVBAR
		+HDWEAPON.FITSINBACKPACK
		Inventory.PickupSound "misc/w_pkup";
		Inventory.PickupMessage "$PICKUP_MAGRELOADER";
		Scale 0.7;
		HDWeapon.RefId "mrl";
		Tag "$TAG_MAGAZINERELOADER";
	}

	States
	{
		Spawn:
			MRLD A -1 NoDelay A_JumpIf(invoker.FactoryAction > FAction_None, "LookForStuff");
			Stop;
		Select0:
			TNT1 A 0 A_Raise(999);
			Wait;
		Deselect0:
			TNT1 A 0 A_Lower(999);
			Wait;
		Ready:
			TNT1 A 1 A_WeaponReady(WRF_ALLOWRELOAD | WRF_ALLOWUSER3 | WRF_ALLOWUSER4);
			Goto ReadyEnd;
		Fire:
			TNT1 A 1;
			Goto Ready;
		Reload:
			TNT1 A 5
			{
				invoker.ChargeUp = 0;
				invoker.FactoryAction = FAction_Reload;
				DropInventory(invoker);
			}
			Goto Ready;
		Unload:
			TNT1 A 5
			{
				invoker.ChargeUp = 0;
				invoker.FactoryAction = FAction_Unload;
				DropInventory(invoker);
			}
			Goto Ready;
		LookForStuff:
			#### A 1
			{
				if (invoker.Active)
				{
					return ResolveState('Chug');
				}
				else if (invoker.LoadedMagType)
				{
					switch (invoker.FactoryAction)
					{
						case FAction_Reload:
						{
							BlockThingsIterator it = BlockThingsIterator.Create(invoker, SearchRange);
							while (it.Next())
							{
								let am = HDAmmo(it.thing);
								let upkp = HDUPK(it.thing);
								if (invoker.Distance3D(it.thing) > SearchRange || it.thing.vel.length() > 0.4 || am && am.GetClass() != invoker.LoadedRoundsType || upkp && upkp.pickuptype != invoker.LoadedRoundsType || !am && !upkp)
								{
									continue;
								}

								if (upkp && !invoker.TractoredBox)
								{
									invoker.TractoredBox = upkp;
								}
								else if (am && !A_IsBeingTethered(am))
								{
									for (int i = 0; i < invoker.TractoredRounds.Size(); ++i)
									{
										if (!invoker.TractoredRounds[i])
										{
											invoker.TractoredRounds[i] = am;
											break;
										}
									}
								}
							}

							// [Ace] Prioritize boxes.
							if (invoker.TractoredBox)
							{
								double dist = invoker.Distance3D(invoker.TractoredBox);
								if (dist <= SearchRange)
								{
									if (dist > MinDist)
									{
										AceCore.Tether(invoker, invoker.TractoredBox);
									}
									else
									{
										int req = invoker.MaxToLoad - invoker.LoadedMagRounds - invoker.LoadedRounds;
										int toTake = min(req, invoker.TractoredBox.Amount);
										invoker.TractoredBox.Amount -= toTake;
										invoker.LoadedRounds += toTake;
										if (invoker.TractoredBox.Amount == 0)
										{
											invoker.TractoredBox.Destroy();
										}
										if (invoker.LoadedRounds == invoker.MaxToLoad - invoker.LoadedMagRounds)
										{
											invoker.Active = true;
										}
									}
								}
								else
								{
									invoker.TractoredBox = null;
								}
							}
							else for (int i = 0; i < invoker.TractoredRounds.Size(); ++i)
							{
								if (!invoker.TractoredRounds[i])
								{
									continue;
								}

								double dist = invoker.Distance3D(invoker.TractoredRounds[i]);
								if (dist <= SearchRange)
								{
									if (dist > MinDist)
									{
										AceCore.Tether(invoker, invoker.TractoredRounds[i]);
									}
									else
									{
										int req = invoker.MaxToLoad - invoker.LoadedMagRounds - invoker.LoadedRounds;
										int toTake = min(req, invoker.TractoredRounds[i].Amount);
										invoker.TractoredRounds[i].Amount -= toTake;
										invoker.LoadedRounds += toTake;
										if (invoker.TractoredRounds[i].Amount == 0)
										{
											invoker.TractoredRounds[i].Destroy();
										}
										if (invoker.LoadedRounds == invoker.MaxToLoad - invoker.LoadedMagRounds)
										{
											invoker.Active = true;
											break;
										}
									}
								}
								else
								{
									invoker.TractoredRounds[i] = null;
								}
							}
							break; // [Ace] Deleting this will break stuff. So don't do it again.
						}
						case FAction_Unload:
						{
							invoker.Active = true;
							break;
						}
					}
				}
				else
				{
					if (!invoker.TractoredMag)
					{
						BlockThingsIterator it = BlockThingsIterator.Create(invoker, SearchRange);
						while (it.Next())
						{
							let mag = HDMagAmmo(it.thing);
							if (!mag || invoker.Distance3D(mag) > SearchRange || invoker.ChargeUp < 360 || mag.vel.length() > 0.4 || !mag.RoundType || invoker.FactoryAction == FAction_Reload && mag.Mags[0] == mag.MaxPerUnit || invoker.FactoryAction == FAction_Unload && mag.Mags[0] == 0)
							{
								continue;
							}

							invoker.TractoredMag = mag;
							break;
						}
					}
					else
					{
						double dist = invoker.Distance3D(invoker.TractoredMag);
						if (dist <= SearchRange)
						{
							if (dist > MinDist)
							{
								AceCore.Tether(invoker, invoker.TractoredMag);
							}
							else
							{
								invoker.LoadedMagType = invoker.TractoredMag.GetClass();
								invoker.LoadedMagRounds = invoker.TractoredMag.Mags[0];
								invoker.LoadedRoundsType = invoker.TractoredMag.RoundType;
								invoker.MaxToLoad = invoker.TractoredMag.MaxPerUnit;
								invoker.TractoredMag.Destroy();
							}
						}
						else
						{
							invoker.TractoredMag = null;
						}
					}
				}
				return ResolveState(null);
			}
			Loop;
		Chug:
			#### A 0
			{
				A_StartSound("roundmaker/chug1", 8);
				A_StartSound("roundmaker/chug2", 9);
				vel.z += frandompick(-0.4, 0.4);
				vel.xy += (frandom(-0.05, 0.05), frandom(-0.05, 0.05));

				if (invoker.ChugTicker++ == 1)
				{
					invoker.ChugTicker = 0;
					return ResolveState("InsertRound");
				}

				return ResolveState(null);
			}
			#### A 3 A_SetTics(invoker.FactoryAction == FAction_Unload ? 2 : 3);
			Loop;
		InsertRound:
			#### A 0
			{
				switch (invoker.FactoryAction)
				{
					case FAction_Reload:
						invoker.LoadedMagRounds++;
						invoker.LoadedRounds--;
						if (invoker.LoadedMagRounds == invoker.MaxToLoad)
						{
							if (!random(0, 12))
							{
								A_StartSound("MagReloader/BellDing", 9);
							}
							A_PopMag();
						}
						break;
					case FAction_Unload:
						invoker.LoadedMagRounds--;
						invoker.LoadedRounds++;
						if (invoker.LoadedMagRounds == 0)
						{
							A_PopMag();
						}
						break;
				}
			}
			#### A 0 A_Jump(256, "Spawn");
			Stop;
	}
}
