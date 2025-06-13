class HDBlackhawk : HDWeapon
{
	enum BlackhawkFlags
	{
		BHF_SemiAuto = 1,
		BHF_StringPulled = 16 // [Ace] 16 just in case I add more stuff at some point.
	}

	enum BlackhawkProperties
	{
		BHProp_Flags,

		// [Ace] Honestly I really hate that I have to do this, but any workarounds to fit around HDest's current fuck of a variable storage aren't going to be any better.
		BHProp_MagazineFirst = 1,
		BHProp_MagazineLast = 12,

		BHProp_NextBoltIndex // [Ace] This is for the reloading.
	}

	override void BeginPlay()
	{
		BoltClasses.Clear();
		for (int i = 0; i < AllActorClasses.Size(); ++i)
		{
			if (AllActorClasses[i] is 'HDBlackhawkBolt' && !AllActorClasses[i].IsAbstract())
			{
				BoltClasses.Push((class<HDBlackhawkBolt>)(AllActorClasses[i]));
			}
		}

		weaponspecial = 1337; // [Ace] UaS sling compatibility.
		Super.BeginPlay();
	}

	private action void A_CycleBolts(int dir)
	{
		Array<bool> boltsPresent;
		int foundBolts = 0;

		for (int i = 0; i < invoker.BoltClasses.Size(); ++i)
		{
			let bolt = invoker.owner.FindInventory(invoker.BoltClasses[i]);
			if (bolt)
			{
				boltsPresent.Push(true);
				foundBolts++;
			}
			else
			{
				boltsPresent.Push(false);
			}
		}

		if (foundBolts == 0)
		{
			return;
		}

		int curIndex = invoker.WeaponStatus[BHProp_NextBoltIndex];
		int size = boltsPresent.Size();
		int startIndex = curIndex;
		do
		{
			curIndex += dir;
			if (curIndex == -1)
			{
				curIndex = size - 1;
			}
			else if (curIndex == size)
			{
				curIndex = 0;
			}

			if (boltsPresent[curIndex])
			{
				invoker.WeaponStatus[BHProp_NextBoltIndex] = curIndex;
				break;
			}

		} while (curIndex != startIndex);
	}

	private action bool A_AddBolt(int type)
	{
		let boltRef = invoker.owner.FindInventory(invoker.BoltClasses[type]);
		if (!boltRef)
		{
			return false;
		}

		for (int i = BHProp_MagazineLast; i >= BHProp_MagazineFirst; --i)
		{
			invoker.WeaponStatus[i] = invoker.WeaponStatus[i - 1];
		}

		invoker.owner.A_TakeInventory(boltRef.GetClass(), 1);
		invoker.WeaponStatus[BHProp_MagazineFirst] = type;
		return true;
	}

	// [Ace] Bolts are fired in first-in-last-out order.
	private action int A_RemoveBolt(bool toInventory)
	{
		// [Ace] This should never return -1 because A_RemoveBolt should never be called on an empty magazine. It will result in an array index out of bounds exception.
		int removedType = invoker.WeaponStatus[BHProp_MagazineFirst];
		invoker.WeaponStatus[BHProp_MagazineFirst] = -1;
		if (toInventory)
		{
			if (!invoker.owner.A_JumpIfInventory(invoker.BoltClasses[removedType], 0, "Null"))
			{
				invoker.owner.A_GiveInventory(invoker.BoltClasses[removedType], 1);
			}
			else
			{
				Actor a = invoker.owner.Spawn(invoker.BoltClasses[removedType], invoker.owner.pos + (0, 0, invoker.owner.height / 2 + 8));
				a.angle = invoker.owner.angle;
				a.vel += invoker.owner.vel;
				a.A_ChangeVelocity(3, 0, 0, CVF_RELATIVE);
			}
		}

		for (int i = BHProp_MagazineFirst; i < BHProp_MagazineLast; ++i)
		{
			invoker.WeaponStatus[i] = invoker.WeaponStatus[i + 1];
			invoker.WeaponStatus[i + 1] = -1;
		}
		return removedType;
	}

	override bool AddSpareWeapon(actor newowner) { return AddSpareWeaponRegular(newowner); }
	override HDWeapon GetSpareWeapon(actor newowner , bool reverse, bool doselect) { return GetSpareWeaponRegular(newowner, reverse, doselect); }

	override double GunMass()
	{
		double boltMass = 0;
		for (int i = BHProp_MagazineFirst; i <= BHProp_MagazineLast; ++i)
		{
			if (WeaponStatus[i] > -1)
			{
				boltMass += HDBlackhawkBolt.Bulks[WeaponStatus[i]] * 0.02;
			}
		}
		return 7.5 + boltMass;
	}
	override double WeaponBulk()
	{
		double boltBulk = 0;
		for (int i = BHProp_MagazineFirst; i <= BHProp_MagazineLast; ++i)
		{
			if (WeaponStatus[i] > -1)
			{
				boltBulk += HDBlackhawkBolt.Bulks[WeaponStatus[i]] * 0.3;
			}
		}
		return 100 + boltBulk;
	}

	override string, double GetPickupSprite() { return "BHKGZ0", 0.4; }
	override void InitializeWepStats(bool idfa)
	{
		for (int i = BHProp_MagazineFirst; i <= BHProp_MagazineLast; ++i)
		{
			WeaponStatus[i] = 0;
		}
		WeaponStatus[BHProp_Flags] |= BHF_StringPulled;
	}
	override void LoadoutConfigure(string input)
	{
		if (GetLoadoutVar(input, "semiauto", 1) > 0)
		{
			WeaponStatus[BHProp_Flags] |= BHF_SemiAuto;
		}

		int boltKeyIndex = input.IndexOf("bolts:");
		if (boltKeyIndex > -1)
		{
			// [Ace] Empty the crossbow first because we're overriding it.
			for (int i = BHProp_MagazineFirst; i <= BHProp_MagazineLast; ++i)
			{
				WeaponStatus[i] = -1;
			}
			WeaponStatus[BHProp_Flags] &= ~BHF_StringPulled;

			// [Ace] I guess I could String.Split for this, but it's whatever.
			string boltInput = input.Mid(boltKeyIndex + 6, BHProp_MagazineLast);
			bool exit = false;
			for (int i = 0; i < BHProp_MagazineLast && i < boltInput.Length() && !exit; ++i)
			{
				Name code = boltInput.Mid(i, 1);
				switch (code)
				{
					case 'r': WeaponStatus[BHProp_MagazineFirst + i] = 0; break;
					case 'i': WeaponStatus[BHProp_MagazineFirst + i] = 1; break;
					case 'e': WeaponStatus[BHProp_MagazineFirst + i] = 2; break;
					case 'n': WeaponStatus[BHProp_MagazineFirst + i] = 3; break;
					default: exit = true; break;
				}
			}
		}
	}
	override void DropOneAmmo(int amt)
	{
		if (owner)
		{
			double oldAngle = owner.angle;
			owner.angle -= 30;
			for (int i = 0; i < BoltClasses.Size(); ++i)
			{
				owner.A_DropInventory(BoltClasses[i], 1);
				owner.angle += 20;
			}
			owner.angle = oldAngle;
		}
	}

	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_FIRE..Stringtable.Localize("$BHWK_HELPTEXT_1")
		..LWPHELP_ALTFIRE..Stringtable.Localize("$BHWK_HELPTEXT_2")
		..LWPHELP_RELOAD..Stringtable.Localize("$BHWK_HELPTEXT_3")
		.."  + "..LWPHELP_ALTRELOAD..Stringtable.Localize("$BHWK_HELPTEXT_4")
		.."  + "..LWPHELP_UNLOAD..Stringtable.Localize("$BHWK_HELPTEXT_5")
		.."  + "..LWPHELP_FIRE.."/"..LWPHELP_ALTFIRE..Stringtable.Localize("$BHWK_HELPTEXT_6");
	}

	override string PickupMessage()
	{
		string autoStr = WeaponStatus[BHProp_Flags] & BHF_SemiAuto ? "semi-auto " : "";

		return Stringtable.localize("$PICKUP_BLACKHAWK_PREFIX")..autoStr..Stringtable.localize("$TAG_BLACKHAWK")..Stringtable.localize("$PICKUP_BLACKHAWK_SUFFIX");
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		if (sb.HudLevel == 1)
		{
			for (int i = 0; i < BoltClasses.Size(); ++i)
			{
				let bolt = hpl.FindInventory(BoltClasses[i]);
				double drawAlpha = bolt ? 1.0 : 0.5;

				int frameLetter = 65 + i;
				sb.DrawImage(String.Format("BHBL%c0", frameLetter), (-37, -8 - 10 * i), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_VCENTER | sb.DI_ITEM_RIGHT, scale: (0.8, 0.8));
				int amt = bolt ? bolt.Amount : 0;

				if (i == WeaponStatus[BHProp_NextBoltIndex])
				{
					sb.DrawImage(String.Format("BHHH%c0", frameLetter), (-36, -8 - 10 * i), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_VCENTER | sb.DI_ITEM_RIGHT, scale: (0.8, 0.8));
				}

				sb.DrawNum(amt, -35, -8 - 10 * i, sb.DI_SCREEN_CENTER_BOTTOM);
			}
		}

		double yShift = 0;
		for (int i = BHProp_MagazineFirst; i <= BHProp_MagazineLast; ++i)
		{
			if (WeaponStatus[i] == -1)
			{
				continue;
			}
			sb.Fill(HDBlackhawkBolt.HudColors[WeaponStatus[i]], -15, -5 - yShift, -15, 1, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_RIGHT_BOTTOM);
			yShift += 2;
		}
	}

	// [Ace] It's a high-tech crossbow, but it doesn't have sights. Intentional. Development was severely underbudgeted and AceCorp didn't have the resources to add various extras.
	// Really I'm just lazy and out of ideas. One day I might add iron sights, but not for now. You don't really need to aim much anyway. 3/4 of the bolts are AoE.
	override void DrawSightPicture(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl, bool sightbob, vector2 bob, double fov, bool scopeview, actor hpc, string whichdot) { }

	Array<class<HDBlackhawkBolt> > BoltClasses;

	Default
	{
		-HDWEAPON.FITSINBACKPACK
		+WEAPON.NOAUTOFIRE
		Weapon.SelectionOrder 300;
		Weapon.SlotNumber 6;
		Weapon.SlotPriority 0.5;
		HDWeapon.BarrelSize 10, 10, 2;
		Scale 0.25;
		Tag "$TAG_BLACKHAWK";
		HDWeapon.Refid HDLD_BLACKHAWK;
		HDWeapon.loadoutcodes "
			\cusemiauto - 0/1, Automatically pulls the string back after firing.
			\cuNote: Only works when cycling to the next bolt.
			\cubolts - <codes>, start with these specific bolts loaded. 
			\cuExample: bolts:rneir for Regular, Nuclear, Electric, Incendiary, Regular in that order.
		";
	}

	States
	{
		Spawn:
			BHKG Z -1;
			Stop;
		Ready:
			BHKG # 1
			{
				bool stringPulled = invoker.WeaponStatus[BHProp_Flags] & BHF_StringPulled;
				if (stringPulled)
				{
					player.GetPSprite(PSP_WEAPON).frame = 2;
				}

				invoker.bWIMPY_WEAPON = false;

				int wrflags = stringPulled || invoker.WeaponStatus[BHProp_MagazineFirst] == -1 ? WRF_NOSECONDARY : WRF_NOPRIMARY;
				A_WeaponReady(WRF_ALLOWUSER3 | WRF_ALLOWRELOAD | wrflags);
			}
			Goto ReadyEnd;
		Select0:
			BHKG A 0
			{
				if (invoker.WeaponStatus[BHProp_Flags] & BHF_StringPulled)
				{
					player.GetPSprite(PSP_WEAPON).frame += 2;
				}
			}
			Goto Select0Big;
		Deselect0:
			BHKG A 0
			{
				if (invoker.WeaponStatus[BHProp_Flags] & BHF_StringPulled)
				{
					player.GetPSprite(PSP_WEAPON).frame += 2;
				}
			}
			Goto Deselect0Big;
		Fire:
			BHKG # 0
			{
				// [Ace] Don't decloak if using blur, although the screen will definitely flicker and annoy you so idk why you'd even want to use this with stealth.
				invoker.bWIMPY_WEAPON = true;
				if (invoker.WeaponStatus[BHProp_MagazineFirst] == -1 || !(invoker.WeaponStatus[BHProp_Flags] & BHF_StringPulled))
				{
					SetWeaponState("Nope");
					return;
				}
			}
			BHKG B 1
			{
				A_StartSound("Blackhawk/Fire", CHAN_WEAPON);
			}
			BHKG A 1 Offset(0, 34)
			{
				class<HDBlackhawkProjectile> boltcls = "HDBlackhawkProjectile"..HDBlackhawkBolt.Tags[A_RemoveBolt(false)];
				if (!boltcls)
				{
					return;
				}
				Actor bolt = Spawn(boltcls, pos + GunPos());
				bolt.angle = angle;
				bolt.pitch = pitch;
				bolt.target = self;
				bolt.master = self;

				invoker.WeaponStatus[BHProp_Flags] &= ~BHF_StringPulled;
				if (invoker.WeaponStatus[BHProp_Flags] & BHF_SemiAuto && invoker.WeaponStatus[BHProp_MagazineFirst] > -1)
				{
					SetWeaponState('AutoPull');
				}
			}
			BHKG A 1 Offset(0, 35);
			Goto Ready;
		AutoPull:
			BHKG A 2;
			BHKG B 3 A_StartSound("Blackhawk/StringPull", 6);
			BHKG C 2 { invoker.WeaponStatus[BHProp_Flags] |= BHF_StringPulled; }
			Goto Ready;
		AltFire:
			BHKG A 2 Offset(2, 36) A_WeaponBusy(true);
			BHKG A 2 Offset(3, 39);
			BHKG B 3 Offset(5, 42) A_StartSound("Blackhawk/StringPull", 6);
			BHKG C 3 { invoker.WeaponStatus[BHProp_Flags] |= BHF_StringPulled; }
			BHKG C 2 Offset(2, 37);
			BHKG C 2 Offset(0, 32) A_WeaponBusy(false);
			Goto Ready;
		Reload:
			BHKG # 2 Offset(2, 36);
			BHKG # 2 Offset(3, 39);
			BHKG # 2 Offset(4, 41);
			BHKG # 2 Offset(5, 42);
			BHKG # 2 Offset(5, 42);
		ReloadLoop:
			BHKG # 1
			{
				int dir = 0;
				bool invert = CVar.GetCVar('bh_invertscroll', player).GetBool();
				if (JustPressed(BT_ATTACK))
				{
					dir = invert ? 1 : -1;
				}
				else if (JustPressed(BT_ALTATTACK))
				{
					dir = invert ? -1 : 1;
				}
				if (dir != 0)
				{
					A_CycleBolts(dir);
				}

				if (JustPressed(BT_ALTRELOAD) && invoker.WeaponStatus[BHProp_MagazineLast] == -1 && FindInventory(invoker.BoltClasses[invoker.WeaponStatus[BHProp_NextBoltIndex]]))
				{
					SetWeaponState('InsertBolt');
					return;
				}

				if (JustPressed(BT_UNLOAD) && invoker.WeaponStatus[BHProp_MagazineFirst] > -1)
				{
					SetWeaponState('RemoveBolt');
					return;
				}

				if (!PressingReload())
				{
					SetWeaponState('ReloadEnd');
					return;
				}
			}
			Loop;

		InsertBolt:
			BHKG # 2 Offset(6, 44);
			BHKG # 2 Offset(7, 46)
			{
				A_AddBolt(invoker.WeaponStatus[BHProp_NextBoltIndex]);
				A_StartSound("Blackhawk/LoadBolt", 8);
			}
			BHKG # 4 Offset(5, 42);
			Goto ReloadLoop;
		RemoveBolt:
			BHKG # 0 A_JumpIf(invoker.WeaponStatus[BHProp_MagazineFirst + 1] > -1 || !(invoker.WeaponStatus[BHProp_Flags] & BHF_StringPulled), 5);
			BHKG # 0 { invoker.WeaponStatus[BHProp_Flags] &= ~BHF_StringPulled; }
			BHKG CBA 2;
			BHKG # 2 Offset(6, 44);
			BHKG # 2 Offset(7, 46)
			{
				A_RemoveBolt(true);
				A_StartSound("Blackhawk/LoadBolt", 8);
			}
			BHKG # 4 Offset(5, 42);
			Goto ReloadLoop;
		ReloadEnd:
			BHKG # 2 Offset(2, 37);
			BHKG # 2 Offset(1, 34);
			BHKG # 2 Offset(0, 33);
			BHKG # 2 Offset(0, 32);
			Goto Ready;
	}
}

class BlackhawkRandom : IdleDummy
{
	States
	{
		Spawn:
			TNT1 A 0 NoDelay
			{
				let wpn = HDBlackhawk(Spawn('HDBlackhawk', pos));
				HDF.TransferSpecials(self, wpn);

				if (!random(0, 4))
				{
					wpn.WeaponStatus[wpn.BHProp_Flags] |= wpn.BHF_SemiAuto;
				}
				wpn.InitializeWepStats(false);

				A_SpawnItemEx('HDBlackhawkBoltBundle', 10, angle: -45, flags: SXF_NOCHECKPOSITION);
				A_SpawnItemEx('HDBlackhawkBoltBundle', 10, angle: 0, flags: SXF_NOCHECKPOSITION);
				A_SpawnItemEx('HDBlackhawkBoltBundle', 10, angle: 45, flags: SXF_NOCHECKPOSITION);
			}
			Stop;
	}
}

class HDBlackhawkProjectile : SlowProjectile abstract
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		A_ChangeVelocity(speed * cos(pitch), 0, speed * sin(-pitch), CVF_RELATIVE);
	}
	override void GunSmoke() { } // [Ace] Smoking is bad for you.
	override void ExplodeSlowMissile(Line hitLine, Actor hitActor)
	{
		if (max(abs(pos.x), abs(pos.y)) >= 32768)
		{
			Destroy();
			return;
		}

		Actor a = Spawn("IdleDummy", pos, ALLOW_REPLACE);
		a.stamina = 15;
		a.A_StartSound("misc/bullethit", CHAN_AUTO);
		OnBoltHit(hitLine, hitActor);
		if (!bAMBUSH)
		{
			A_AlertMonsters(HDCONST_ONEMETRE * 3);
		}
		ExplodeMissile(hitLine, hitActor);
	}

	abstract void OnBoltHit(Line hitLine, Actor hitActor);

	Default
	{
		Scale 0.3;
	}

	States
	{
		Spawn:
			BHBP # -1;
			Stop;
	}
}

class HDBlackhawkBolt : HDAmmo abstract
{
	override void GetItemsThatUseThis()
	{
		ItemsThatUseThis.Push("HDBlackhawk");
	}

	// [Ace] Regular, Incendiary, Electric, Nuclear.
	// Some of these are duplicated on the actual classes because indexing can't be resolved at compile time.
	static const double Bulks[] = { 2.0, 5.0, 3.5, 12.0 };
	static const int BundleAmounts[] = { 24, 3, 6, 1 };
	static const string Tags[] = { "Regular", "Incendiary", "Electric", "Nuclear" };
	static const int HudColors[] = { 0xFFBBBBBB, 0xFFFF9900, 0xFF0088FF, 0xFF22FF00 };

	meta string IndefiniteArticle;
	property IndefiniteArticle: IndefiniteArticle;

	Default
	{
		+HDPICKUP.MULTIPICKUP
		+HDPICKUP.FITSINBACKPACK
		+FORCEXYBILLBOARD 
		+CANNOTPUSH
		+INVENTORY.IGNORESKILL
		Scale 0.2;
	}

	States
	{
		Spawn:
			BHBL # -1;
			Stop;
	}
}

class HDBlackhawkBoltBundle : HDUPK
{
	override void BeginPlay()
	{
		Array<int> weights;
		weights.Push(12);
		weights.Push(8);
		weights.Push(5);
		weights.Push(1);

		ChosenType = AceCore.GetWeightedResult(weights);

		PickupType = "HDBlackhawkBolt"..HDBlackhawkBolt.Tags[ChosenType];

		Amount = MaxUnitAmount = HDBlackhawkBolt.BundleAmounts[ChosenType];
		frame = ChosenType;
		Super.BeginPlay();
	}

	override void Tick()
	{
		PickupMessage = String.Format("Picked up pack containing %i %s bolt%s.", Amount, HDBlackhawkBolt.Tags[ChosenType], Amount > 1 ? "s" : "");
		Super.Tick();
	}

	int ChosenType;

	Default
	{
		Scale 0.15;
	}

	States
	{
		Spawn:
			BHBB # -1;
			Stop;
	}
}