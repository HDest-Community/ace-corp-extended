class SoulCubeHandler : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name ~== "SC_ReturnToOwner")
		{
			let plr = players[e.Player].mo;
			ThinkerIterator it = ThinkerIterator.Create("HDSoulCube", Thinker.STAT_DEFAULT);
			HDSoulCube SC;
			while ((SC = HDSoulCube(it.Next())))
			{
				if (SC.master == plr && SC.Destination && SC.CheckSight(SC.master))
				{
					SC.Destination.master = plr;
					return;
				}
			}
		}
	}
}

class HDSoulCube : HDWeapon
{
	enum SCFlags
	{
		SCF_AlreadyPickedUp = 1
	}

	enum SCProperty
	{
		SCProp_Flags,
		SCProp_UseOffset,
		SCProp_Frag,
		SCProp_CubeLevel,
		SCProp_CubeExperience,
		SCProp_TimeWithOwner,
		SCProp_LastOwnerNumber,
		SCProp_Mode
	}

	enum SCModes
	{
		SCMode_Attack,
		SCMode_Heal,
		SCMode_ConvertFrag,
		SCMode_SpiritualArmor,
		SCMode_ChargeBatteries
	}

	action void A_AddOffset(int ofs)
	{
		invoker.WeaponStatus[SCProp_UseOffset] += ofs;
	}
	
	override string, double GetPickupSprite() { return "SLCBA3A7", 0.5; }
	override string GetHelpText()
	{
		LocalizeHelp();
		return 
		LWPHELP_FIRE..Stringtable.Localize("$CUBE_HELPTEXT_1")
		..LWPHELP_ALTFIRE..Stringtable.Localize("$CUBE_HELPTEXT_2")
		..LWPHELP_FIREMODE.. Stringtable.Localize("$CUBE_HELPTEXT_3");
	}
	override double WeaponBulk() { return 40; }

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl)
	{
		vector2 bob = hpl.wepbob * 0.3;
		bob.y += WeaponStatus[SCProp_UseOffset];
		int baseYOffset = -180;
		
		sb.DrawImage("SLCBA3A7", (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE, alpha: 1.0, scale:(2, 2));
		baseYOffset += 50;
		if (WeaponStatus[SCProp_Frag] >= MinFrag)
		{
			sb.DrawString(sb.pSmallFont, "Use us", (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GREEN);
		}
		else
		{
			sb.DrawString(sb.pSmallFont, "Not enough frag", (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GOLD);
		}
		baseYOffset += 10;

		// [Ace] Aggro.
		string aggroString = "\c[SC_AggroNone]Your soul is unharmed\c-";
		if (hpl.aggravateddamage > 0)
		{
			if (hpl.aggravateddamage <= 20)
			{
				aggroString = "\c[SC_AggroVLow]Your soul is weakening\c-";
			}
			else if (hpl.aggravateddamage <= 40)
			{
				aggroString = "\c[SC_AggroLow]Your soul needs healing\c-";
			}
			else if (hpl.aggravateddamage <= 60)
			{
				aggroString = "\c[SC_AggroMed]Your soul has been burnt\c-";
			}
			else if (hpl.aggravateddamage <= 80)
			{
				aggroString = "\c[SC_AggroHigh]Your soul is nearly torn apart\c-";
			}
			else if (hpl.aggravateddamage <= 100)
			{
				aggroString = "\c[SC_AggroExtr]Your soul has been utterly scorched\c-";
			}
			else
			{
				aggroString = "\c[SC_AggroUlt]You are already dead\c-";
			}
		}
		sb.DrawString(sb.pSmallFont, aggroString, (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
		baseYOffset += 10;

		// [Ace] Blues.
		string bluesString = "\c[White]We detect nothing supernatural in you\c-";
		int blues = hpl.CountInv('HealingMagic');
		if (blues > 0)
		{
			if (blues < HDHM_BOTTLE * HDHM_MOUTH)
			{
				bluesString = "\c[SC_BluesVLow]A faint supernatural presence can be felt\c-";
			}
			else if (blues < HDHM_BALL)
			{
				bluesString = "\c[SC_BluesLow]There is something supernatural in you\c-";
			}
			else if (blues < HDHM_BALL * 4)
			{
				bluesString = "\c[SC_BluesMed]You emanate a strange supernatural aura\c-";
			}
			else if (blues < HDHM_BALL * 8)
			{
				bluesString = "\c[SC_BluesHigh]Your body is infused with the supernatural\c-";
			}
			else if (blues < HDHM_BALL * 16)
			{
				bluesString = "\c[SC_BluesUlt]Holy burning hand of wrath\c-";
			}
			else if (blues < HDHM_BALL * 32)
			{
				bluesString = "\c[SC_BluesAlmostGod]Disciple of God\c-";
			}
			else if (blues < HDHM_BALL * 64)
			{
				bluesString = "\c[SC_BluesGod]Divine ascendancy\c-";
			}
			else
			{
				bluesString = "\c[SC_BluesGoddamn]God\c-";
			}
		}
		sb.DrawString(sb.pSmallFont, bluesString, (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
		baseYOffset += 10;

		// [Ace] Spiritual armor.
		// [Cryo] Will restore pending rework of Spiritual armor
		/*
		string protectionString = "\c[Red]You are not protected\c-";
		switch (sb.GetAmount("SpiritualArmour"))
		{
			case 1: protectionString = "\c[Orange]You are protected by a thin veil\c-"; break;
			case 2: protectionString = "\c[Yellow]The spirits guard your soul\c-"; break;
			case 3: protectionString = "\c[Green]Your soul has transcended beyond harm\c-"; break;
		}
		sb.DrawString(sb.pSmallFont, protectionString, (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
		baseYOffset += 20;

		sb.DrawString(sb.pSmallFont, ModeStrings[WeaponStatus[SCProp_Mode]], (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
		*/
		
		string protectionString = "\c[Red]ERROR: SHIELD ITEM NOT FOUND.\c-";
		switch (sb.GetAmount("ShieldCore"))
		{
			case 1: protectionString = "\c[Green]SHIELD ITEM READY FOR DEPLOYMENT.\c-"; break;
		}
		sb.DrawString(sb.pSmallFont, protectionString, (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
		baseYOffset += 20;

		sb.DrawString(sb.pSmallFont, ModeStrings[WeaponStatus[SCProp_Mode]], (0, baseYOffset) + bob, sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_CENTER);
	}

	override int GetSbarNum(int flags)
	{
		let HDHud = HDStatusBar(StatusBar);

		int Frag =  WeaponStatus[SCProp_Frag];
		HDHud.SavedColour = Frag >= MinFrag ? Font.CR_GREEN : Font.CR_RED;
		return Frag;
	}

	override int DisplayAmount()
	{
		let HDHud = HDStatusBar(StatusBar);
		int col = Font.FindFontColor("SC_Level_1");
		int lvl = A_GetCubeLevel();
		switch (lvl)
		{
			case 1: col = Font.FindFontColor("SC_Level_2"); break;
			case 2: col = Font.CR_YELLOW; break;
			case 3: col = Font.CR_ORANGE; break;
			case 4: col = Font.CR_RED; break;
			case 5: col = Font.CR_PURPLE; break;
		}
		HDHud.SavedColour = col;
		return lvl;
	}

	action clearscope int A_GetCubeLevel()
	{
		int lvl = invoker.WeaponStatus[SCProp_CubeLevel];
		if (invoker.PetTicker > 0)
		{
			lvl++;
		}
		return lvl;
	}

	action clearscope int A_GetParticleColor(int lvl)
	{
		switch (lvl)
		{
			case 0: return 0x44FF44;
			case 1: return 0x99FF11;
			case 2: return 0xFFFF11;
			case 3: return 0xFF9911;
			case 4: return 0xFF1111;
			case 5: return 0xA100E6;
		}
		return 0;
	}

	override void LoadoutConfigure(string input)
	{
		int StartLevel = GetLoadoutVar(input, "level", 1);
		if (StartLevel > 0)
		{
			WeaponStatus[SCProp_CubeLevel] = min(StartLevel, ExperienceReqs.Size());
		}

		int StartFrag = GetLoadoutVar(input, "frag", 3);
		if (StartFrag > 0)
		{
			WeaponStatus[SCProp_Frag] = StartFrag;
		}
	}

	override void InitializeWepStats(bool idfa)
	{
		PetTicker = PetCooldown;
	}

	override bool OnGrab(Actor other)
	{
		if (Active && PickupTimer <= 0)
		{
			PickupTimer = 10;
			return false;
		}

		if (Destination)
		{
			Destination.Destroy();
		}

		Active = false;
		bNOGRAVITY = false;

		if (hdsc_archermode)
		{
			if (!random(0, 5) && !(WeaponStatus[SCProp_Flags] & SCF_AlreadyPickedUp))
			{
				A_PlayArcherSound(other, "PickupSpecial");
			}
			else
			{
				A_PlayArcherSound(other, !random(0, 28) ? "PickupRare" : "PickupNormal");
			}
			WeaponStatus[SCProp_Flags] |= SCF_AlreadyPickedUp;
		}

		HasAnnounced[2] = false;

		return Super.OnGrab(other);
	}

	override void ActualPickup(Actor other, bool silent)
	{
		// [Ace] This pointer is for the existing cube in the player's inventory.
		let Cube = HDSoulCube(other.FindInventory("HDSoulCube"));
		if (Cube)
		{
			A_StartSound("SC/Activate", CHAN_WEAPON, volume: 0.3);
			if (hdsc_archermode)
			{
				A_PlayArcherSound(other, "ConsumeNormal");
			}
			Cube.WeaponStatus[SCProp_CubeLevel] = min(ExperienceReqs.Size(), Cube.WeaponStatus[SCProp_CubeLevel] + WeaponStatus[SCProp_CubeLevel]);
			Cube.A_GainExperience(WeaponStatus[SCProp_CubeExperience] + 200);
			Cube.WeaponStatus[SCProp_Frag] += WeaponStatus[SCProp_Frag] + 20;
			Destroy();
			return;
		}
		
		Super.ActualPickup(other, silent);
	}

	override void Tick()
	{
		Super.Tick();

		// ------------------------------------------------------------
		//
		// ------------------------------------------------------------

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
					case 'DrainChargeSoulCube':
					{
						int amt = req.Arg.ToInt();
						if (amt != 0)
						{
							WeaponStatus[SCProp_Frag] = max(0, WeaponStatus[SCProp_Frag] + amt);
						}
						req.Remove(); i--;
						break;
					}
					case 'SoulCubeUp':
					{
						A_GainExperience(ExperienceReqs[min(ExperienceReqs.Size() - 1, WeaponStatus[SCProp_CubeLevel])]);
						req.Remove(); i--;
						break;
					}
					case 'SoulCubePet':
					{
						A_PetCube();
						req.Remove(); i--;
						break;
					}
				}
			}
		}

		// ------------------------------------------------------------
		//
		// ------------------------------------------------------------

		if (GetAge() % 35 == 0 && PetCount > 0)
		{
			PetCount--;
		}

		PetTicker--;
		if (PetTicker > 0 && !random(0, 2))
		{
			A_ChangeVelocity(frandom(-0.05, 0.05), frandom(-0.05, 0.05), frandom(0.1, 0.25), CVF_RELATIVE);
		}
		else if (PetTicker <= PetCooldown)
		{
			for (int i = 0; i < MAXPLAYERS; ++i)
			{
				let plr = HDPlayerPawn(players[i].mo);
				if (!plr)
				{
					continue;
				}

				if (plr.player)
				{
					let wpn = HDWeaponGrabber(plr.player.ReadyWeapon);
					if (!wpn)
					{
						continue;
					}
					if (wpn.grabbed == self && !HasBeenPet)
					{
						HasBeenPet = true;
						A_ChangeVelocity(frandom(-0.15, 0.15), frandom(-0.15, 0.15), frandom(0.2, 0.6), CVF_RELATIVE);
						if (++PetCount == 6)
						{
							A_PetCube();
						}
					}
					else if (wpn.grabbed != self)
					{
						HasBeenPet = false;
					}
					break;
				}
			}
		}

		if (!master)
		{
			return;
		}

		if (JokerTicker > 0)
		{
			JokerTicker--;
		}
		else if (master.vel.z < -5 && HDPlayerPawn(master).incapacitated > 0 && HDPlayerPawn(master).incaptimer > 105)
		{
			JokerTicker = 35 * 60 * 20;
			if (hdsc_archermode)
			{
				A_PlayArcherSound(self, "JokerStairs");
			}
		}
	}

	override void DoEffect()
	{
		if (WeaponStatus[SCProp_LastOwnerNumber] != owner.PlayerNumber())
		{
			WeaponStatus[SCProp_LastOwnerNumber] = owner.PlayerNumber();
			WeaponStatus[SCProp_TimeWithOwner] = 0;
		}
		else
		{
			WeaponStatus[SCProp_TimeWithOwner]++;
		}

		if (HasAnnounced[0] && WeaponStatus[SCProp_Frag] < MinFrag)
		{
			HasAnnounced[0] = false;
		}

		int maxFrag = A_GetMaxFrag();
		if (WeaponStatus[SCProp_Frag] < maxFrag && level.time % int(105 - 17.5 * A_GetCubeLevel()) == 0 && !random(0, 1))
		{
			// [Ace] This is actually a square but it's invisible so who cares?
			let it = BlockThingsIterator.Create(owner, MaxRange);
			while (it.Next())
			{
				bool IsSuperShard = it.thing is 'BFGNecroShard';
				bool IsRegularShard = it.thing is 'BFGNecroShard';

				if (IsRegularShard || IsSuperShard && !random(0, 2))
				{
					owner.A_StartSound("SC/Ammo", 9, CHANF_LOCAL, volume: 0.45);
					WeaponStatus[SCProp_Frag] += IsSuperShard ? 3 : 1;
					A_GainExperience(IsSuperShard ? 3 : 1);
					it.thing.Destroy();

					if (!HasAnnounced[0] && WeaponStatus[SCProp_Frag] >= MinFrag)
					{
						if (hdsc_archermode)
						{
							A_PlayArcherSound(owner, "Ready", CHANF_LOCAL);
						}
						else
						{
							owner.A_StartSound("SC/Original/Ready", 10, CHANF_LOCAL, volume: 0.40);
						}
						HasAnnounced[0] = true;
					}
					if (!HasAnnounced[1] && WeaponStatus[SCProp_Frag] >= maxFrag && hdsc_archermode)
					{
						if (!random(0, 1))
						{
							A_PlayArcherSound(owner, !random(0, 12) ? "FullRare" : "FullNormal", CHANF_LOCAL);
						}
						HasAnnounced[1] = true;
					}
					break;
				}
			}
		}
		else if (hdsc_archermode && WeaponStatus[SCProp_Frag] >= maxFrag && ++MaxFragTicker >= (35 * 60 * 15))
		{
			A_PlayArcherSound(owner, "MaxedOut", CHANF_LOCAL);
			MaxFragTicker = 0;
		}

		let plr = HDPlayerPawn(owner);
		if (!Active && WeaponStatus[SCProp_Frag] >= MinFrag && plr && plr.incapacitated > 0)
		{
			A_DeployCube(false, true);
		}

		Super.DoEffect();
	}

	override string PickupMessage()
	{
		string BaseMessage = Stringtable.Localize("$PICKUP_SOULCUBE_BASE");
		if (hdsc_archermode)
		{
			BaseMessage = BaseMessage..Stringtable.Localize("$PICKUP_SOULCUBE_ARCHER");
		}
		if (!random(0, 32))
		{
			BaseMessage..Stringtable.Localize("$PICKUP_SOULCUBE_THANKYOUCUOB");
		}
		return BaseMessage;
	}

	private action void A_DeployCube(bool anchor, bool fromIncap)
	{
		let plr = invoker.owner;
		invoker.Destination = CubeDestination(Spawn("CubeDestination", pos));
		if (anchor)
		{
			FLineTraceData TraceData;
			LineTrace(angle, MaxRange, pitch, TRF_THRUBLOCK | TRF_THRUHITSCAN | TRF_NOSKY | TRF_SOLIDACTORS, height / 2 + 4, 0, 0, TraceData);
			
			if (TraceData.HitActor)
			{
				invoker.Destination.master = TraceData.HitActor;
			}
			else
			{
				invoker.Destination.SetOrigin(TraceData.HitLocation + (0, 0, 16), false);
			}
		}
		else
		{
			invoker.Destination.master = invoker.owner;
		}

		invoker.master = plr;
		if (!fromIncap)
		{
			plr.player.PendingWeapon = Weapon(plr.FindInventory('HDFist'));
		}
		plr.DropInventory(invoker);
		invoker.A_StartSound("SC/Activate", CHAN_WEAPON, volume: 0.3);
		if (!fromIncap && hdsc_archermode)
		{
			A_PlayArcherSound(invoker, !random(0, 20) ? "UseRare" : "UseNormal");
		}
		invoker.Active = true;
		invoker.bNOGRAVITY = true;
	}

	private action void A_GainExperience(int amount)
	{
		let plr = invoker.owner ? invoker.owner : invoker.master;
		int cubeLevel = invoker.WeaponStatus[SCProp_CubeLevel];
		if (cubeLevel >= invoker.ExperienceReqs.Size())
		{
			return;
		}

		invoker.WeaponStatus[SCProp_CubeExperience] += amount;
		if (invoker.WeaponStatus[SCProp_CubeExperience] >= invoker.ExperienceReqs[cubeLevel])
		{
			invoker.WeaponStatus[SCProp_CubeExperience] -= invoker.ExperienceReqs[cubeLevel];
			invoker.WeaponStatus[SCProp_CubeLevel]++;
			A_StartSound("SC/Activate", CHAN_WEAPON, volume: 0.3);
			if (hdsc_archermode)
			{
				A_PlayArcherSound(plr, "LevelUp", CHANF_LOCAL);
			}
			plr.A_Log("The cube's power grows.", true);
		}
	}

	private action void A_PetCube()
	{
		// [Ace] Because even instruments of total annihilation need emotional support.
		if (hdsc_archermode)
		{
			A_PlayArcherSound(invoker, !random(0, 5) ? (invoker.WeaponStatus[SCProp_TimeWithOwner] > 35 * 60 * 120 && !random(0, 3) ? "PetUltraRare" : "PetRare") : "PetNormal");
		}
		invoker.PetTicker = 35 * 60 * 5;
		invoker.PetCount = 0;
		invoker.A_StartSound("SC/Activate", CHAN_WEAPON, volume: 0.3);
		for (int i = 0; i < 64; ++i)
		{
			invoker.A_SpawnParticle(A_GetParticleColor(A_GetCubeLevel()), SPF_RELATIVE, random(35, 70), random(2, 4), random(0, 359), frandom(0, radius), 0, frandom(0, height), 0, 0, frandom(0.5, 3), 0, 0, frandom(-0.05, 0));
		}
	}

	private action clearscope int A_GetMaxFrag()
	{
		int extra = AceCore.CheckForItem(invoker.owner, "HDArcanumTome") ? 10 : 5;
		return 20 + extra * A_GetCubeLevel();
	}

	static void A_PlayArcherSound(Actor a, string snd, int flags = 0, double vol = 1.0, double atten = 0.5)
	{
		a.A_StopSound(10);
		a.A_StartSound("SC/Archer/"..snd, 10, flags, volume: vol, attenuation: atten);
	}

	static const string modeStrings[] = { "\c[Fire]Attack\c-", "\c[Red]Heal\c-", "\c[Blue]Convert frag\c-", "\c[Green]Spiritual armor\c-", "\c[DarkGreen]Charge batteries\c-" };
	static const int ExperienceReqs[] = { 400, 1250, 2500, 5000 };
	const MinFrag = 5;
	const MaxRange = 512;
	const PetCooldown = -(35 * 60 * 15);
	private bool Active;
	private bool HasAnnounced[3];
	private int PickupTimer;
	private int ShootTicker;
	private int MaxFragTicker;
	CubeDestination Destination;
	private int PetCount;
	private bool HasBeenPet;
	private int PetTicker;
	private int JokerTicker;
	private bool IgnoreMinFrag;
	private AceCoreHandler CoreHandler;

	Default
	{
		Speed 5;
		Height 15;
		+SLIDESONWALLS
		+INVENTORY.INVBAR
		+HDWEAPON.DONTFISTONDROP
		+HDWEAPON.DROPTRANSLATION
		Inventory.PickupSound "weapons/pocket";
		Scale 0.5;
		HDWeapon.RefId "slc";
		Tag "$TAG_SOULCUBE";
		HDWeapon.loadoutcodes "
			\culevel - 0/1, Sets what level the Soul Cube starts at.
			\cufrag - 0/1, Sets how much frag the Soul Cube starts with.
		";
	}

	States
	{
		Spawn:
			SLCB A 1
			{
				invoker.PickupTimer--;
				if (invoker.Active)
				{
					invoker.Angle += 10;
					int cubeLevel = A_GetCubeLevel();

					// [Ace] Move towards owner.
					double oldAngle = invoker.Angle;
					if (invoker.Destination)
					{
						if (invoker.Distance2D(invoker.Destination) > 40 || abs(invoker.pos.z - invoker.Destination.pos.z) > 20)
						{
							double pToDest = AceCore.PitchTo(invoker, invoker.Destination);

							A_Face(invoker.Destination, 180, 45);
							A_ChangeVelocity(1.0 * cos(pToDest), 0, 1.0 * sin(pToDest), CVF_RELATIVE);
							vel.x = clamp(vel.x, -6, 6);
							vel.y = clamp(vel.y, -6, 6);
							vel.z = clamp(vel.z, -6, 6);
						}
						else
						{
							A_ScaleVelocity(0.9);
						}
					}
					else
					{
						A_ScaleVelocity(0.9);
					}

					Color partCol = A_GetParticleColor(cubeLevel);

					// [Ace] Draw range circle.
					for (double i = 0; i < 360; i += 0.75)
					{
						A_SpawnParticle(partCol, SPF_RELPOS | SPF_FULLBRIGHT, 1, 40, i, MaxRange, 0, -(pos.z - floorz), startalphaf: 0.25);
					}

					// [Ace] Drop down when out of charges.
					if (invoker.WeaponStatus[SCProp_Frag] < 1)
					{
						invoker.bNOGRAVITY = false;
						invoker.Active = false;
						if (invoker.Destination)
						{
							invoker.Destination.Destroy();
						}

						if (hdsc_archermode)
						{
							A_PlayArcherSound(invoker, !random(0, 6) ? "PowerDownRare" : "PowerDownNormal");
						}
					}

					// [Ace] Target locator.
					Array<Actor> tList;
					Array<HDMobBase> fList;
					Array<HDPlayerPawn> pList;
					int hitThingCount = 0;
					let it = BlockThingsIterator.Create(invoker, MaxRange);
					while (it.Next())
					{
						Actor a = it.thing;
						if (Distance3D(a) > MaxRange || a.Health <= 0 || !CheckSight(a, SF_SEEPASTSHOOTABLELINES | SF_IGNOREVISIBILITY))
						{
							continue;
						}

						let necro = necromancer(a);
						if (necro && necro.tics > 105 && necro.InStateSequence(necro.CurState, necro.FindState('painedandgone')))
						{
							if (hdsc_archermode)
							{
								if (!invoker.HasAnnounced[2])
								{
									invoker.HasAnnounced[2] = true;
									A_PlayArcherSound(invoker, !random(0, 16) ? "ArchHuntRare" : "ArchHuntNormal");
								}
							}
							necro.tics -= 10;
						}

						if (hitThingCount < 3 && (a is 'BoneDrone' || a.bISMONSTER) && a.bSHOOTABLE && !a.bFRIENDLY && (!HDMobBase(a) || HDMobBase(a).bodydamage < a.SpawnHealth() * 1.2))
						{
							for (int i = 0; i < 2; ++i)
							{
								a.A_SpawnParticle(partCol, 0, 25, random(2, 5), 0, frandom(-a.Radius, a.Radius), frandom(-a.Radius, a.Radius), frandom(0, a.Height), 0, 0, random(3, 6));
							}

							tList.Push(a);
							hitThingCount++;
							continue;
						}

						if (a is 'HDPlayerPawn')
						{
							pList.Push(HDPlayerPawn(it.thing));
							continue;
						}

						Name FollowerCls = 'HDFollower';
						if (a is FollowerCls)
						{
							fList.Push(HDMobBase(it.thing));
							continue;
						}
					}

					// [Ace] Fire, incap, and regeneration.
					for (int i = 0; i < pList.Size(); ++i)
					{
						let plr = pList[i];
						plr.A_GiveInventory("HDFireDouse", 20);
						if (plr.incaptimer > 0)
						{
							plr.incaptimer = max(plr.incaptimer - (cubeLevel + 1), 0);
						}
					}

					for (int i = 0; i < fList.Size(); ++i)
					{
						let flw = fList[i];
						if (cubeLevel >= 1)
						{
							if (flw.stunned > 0)
							{
								flw.stunned = max(flw.stunned - (cubeLevel + 1), 0);
							}
							if (flw.Health < flw.SpawnHealth() && level.time % int(175 - 23.34 * cubeLevel) == 0)
							{
								flw.bodydamage = max(0, flw.bodydamage - 3);
								flw.GiveBody(3);
							}
						}
					}

					// [Ace] Attack stuff.
					if (hitThingCount > 0)
					{
						if (++invoker.ShootTicker >= 35 - 5 * cubeLevel)
						{
							int maxFrag = invoker.A_GetMaxFrag();
							bool overcharged = invoker.WeaponStatus[SCProp_Frag] > maxFrag;

							invoker.ShootTicker = 0;
							invoker.WeaponStatus[SCProp_Frag]--;
							if (invoker.WeaponStatus[SCProp_Frag] < maxFrag)
							{
								invoker.MaxFragTicker = 0;
								invoker.HasAnnounced[1] = false;
							}

							for (int i = 0; i < hitThingCount; ++i)
							{
								if (tList[i])
								{
									tList[i].DamageMobj(invoker, invoker.master, 150 + 25 * cubeLevel + 15 * int(overcharged), 'Holy', DMG_THRUSTLESS);
									A_GainExperience(1); // [Ace] Per enemy hit.
									if (!tList[i])
									{
										continue;
									}
									for (int j = 0; j < 80; ++j)
									{
										tList[i].A_SpawnParticle(partCol, SPF_RELATIVE, random(35, 70), random(4, 8), random(0, 359), frandom(0, tList[i].Radius), 0, frandom(0, tList[i].height), frandom(0, 1), 0, frandom(0, 3));
									}
								}
							}
						}
					}
					else
					{
						invoker.ShootTicker = 0;
					}
				}
			}
			Loop;
		Select:
			TNT1 A 0
			{
				invoker.WeaponStatus[SCProp_Mode] = SCMode_Attack;
				A_AddOffset(100);
			}
			Goto Super::Select;
		Ready:
			TNT1 A 1
			{
				if (PressingUser3())
				{
					A_MagManager("PickupManager");
					return;
				}

				int off = invoker.WeaponStatus[SCProp_UseOffset];
				if (off > 0)
				{
					invoker.WeaponStatus[SCProp_UseOffset] = off * 2 / 3;
				}

				if (PressingFire() || PressingAltfire())
				{
					SetWeaponState("Lower");
					return;
				}

				invoker.IgnoreMinFrag = false;

				A_WeaponReady(WRF_ALLOWUSER2 | WRF_ALLOWUSER3 | WRF_NOFIRE);
			}
			Goto ReadyEnd;
		Firemode:
			TNT1 A 1
			{
				invoker.WeaponStatus[SCProp_Mode]++;

				// [Ace] Skip some stuff if cube's level is not high enough.
				if (invoker.WeaponStatus[SCProp_CubeLevel] == 0 && invoker.WeaponStatus[SCProp_Mode] == SCMode_SpiritualArmor)
				{
					invoker.WeaponStatus[SCProp_Mode]++;
				}
				if (invoker.WeaponStatus[SCProp_CubeLevel] == 0 && invoker.WeaponStatus[SCProp_Mode] == SCMode_ChargeBatteries)
				{
					invoker.WeaponStatus[SCProp_Mode]++;
				}

				invoker.WeaponStatus[SCProp_Mode] %= invoker.ModeStrings.Size();
			}
			Goto Nope;
		Lower:
			TNT1 AA 1 A_AddOffset(6);
			TNT1 AAAA 1 A_AddOffset(18);
			TNT1 AAAAA 1 A_AddOffset(36);
			TNT1 A 0 A_JumpIf(!PressingFire() && !PressingAltfire(), "Ready");
			TNT1 A 1
			{
				if (invoker.WeaponStatus[SCProp_Frag] == 0 || !invoker.IgnoreMinFrag && invoker.WeaponStatus[SCProp_Frag] < MinFrag)
				{
					SetWeaponState("Nope");
					return;
				}

				if (PressingFire() || PressingAltfire())
				{
					int cubeLevel = A_GetCubeLevel() + 1;
					bool hasTome = AceCore.CheckForItem(self, "HDArcanumTome");
					bool overcharged = invoker.WeaponStatus[SCProp_Frag] > A_GetMaxFrag();
					if (overcharged)
					{
						cubeLevel++;
					}
					if (hasTome)
					{
						cubeLevel++;
					}

					switch (invoker.WeaponStatus[SCProp_Mode])
					{
						case SCMode_Attack:
						{
							A_DeployCube(PressingAltfire(), false);
							break;
						}
						case SCMode_Heal:
						{
							if (Health >= GetMaxHealth())
							{
								break;
							}

							for (int i = 0; i < 16; ++i)
							{
								A_SpawnParticle(0xFF1111, SPF_RELATIVE, random(35, 70), random(2, 4), random(0, 359), frandom(0, radius * 1.5), 0, frandom(0, height), 0, 0, frandom(0.5, 3), 0, 0, frandom(-0.05, 0));
							}
							A_StartSound("SC/Action", CHAN_WEAPON);
							GiveBody(5 * cubeLevel);
							A_GainExperience(2);
							invoker.WeaponStatus[SCProp_Frag]--;
							A_SetTics(15);
							invoker.IgnoreMinFrag = true;
							break;
						}
						case SCMode_ConvertFrag:
						{
							for (int i = 0; i < 16; ++i)
							{
								A_SpawnParticle(0x2222FF, SPF_RELATIVE, random(35, 70), random(2, 4), random(0, 359), frandom(0, radius * 1.5), 0, frandom(0, height), 0, 0, frandom(0.5, 3), 0, 0, frandom(-0.05, 0));
							}
							A_StartSound("SC/Action", CHAN_WEAPON);
							A_GiveInventory('HealingMagic', (HDHM_MOUTH / 3) * cubeLevel);
							A_GainExperience(2);
							invoker.WeaponStatus[SCProp_Frag]--;
							A_SetTics(10);
							invoker.IgnoreMinFrag = true;
							break;
						}
						case SCMode_SpiritualArmor:
						{
							// [Ace] Can't use it at L0 because the condition would always be false then. Intentional.
							if (CountInv("ShieldCore") < min(1, invoker.WeaponStatus[SCProp_CubeLevel]) && invoker.WeaponStatus[SCProp_Frag] >= 20)
							{
								invoker.WeaponStatus[SCProp_Frag] -= 20;
								for (int i = 0; i < MAXPLAYERS; ++i)
								{
									let plr = players[i].mo;
									if (!plr || plr != self && (plr.Distance3D(self) > MaxRange || !CheckSight(plr, SF_SEEPASTSHOOTABLELINES | SF_IGNOREVISIBILITY)))
									{
										continue;
									}
									for (int i = 0; i < 120; ++i)
									{
										plr.A_SpawnParticle(0x44FF44, SPF_RELATIVE, random(35, 70), random(2, 4), random(0, 359), random(8, 42), 0, frandom(0, plr.height), 0, 0, frandom(0.5, 3), 0, 0, frandom(-0.05, 0));
									}
									plr.A_GiveInventory("ShieldCore", 1);
									A_GainExperience(20);
								}

								A_StartSound("SC/Activate", CHAN_WEAPON, volume: 0.3);
								if (hdsc_archermode)
								{
									A_PlayArcherSound(self, "Praise");
								}
								SetWeaponState("Nope");
							}
							break;
						}
						case SCMode_ChargeBatteries:
						{
							let bat = HDBattery(FindInventory("HDBattery"));
							if (bat)
							{
								int index = AceCore.GetHighestMag(bat, bat.MaxPerUnit);
								if (index > -1)
								{
									for (int i = 0; i < 16; ++i)
									{
										A_SpawnParticle(0x88FF22, SPF_RELATIVE, random(35, 70), random(2, 4), random(0, 359), frandom(0, radius * 1.5), 0, frandom(0, height), 0, 0, frandom(0.5, 3), 0, 0, frandom(-0.05, 0));
									}
									A_StartSound("SC/Action", CHAN_WEAPON);
									bat.Mags[index] = min(bat.Mags[index] + cubeLevel, bat.MaxPerUnit);
									A_GainExperience(2);
									invoker.WeaponStatus[SCProp_Frag]--;
									A_SetTics(15);
									invoker.IgnoreMinFrag = true;
								}
							}
							break;
						}
					}
				}
				else
				{
					SetWeaponState('Nope');
					return;
				}
			}
			Wait;
	}
}

class CubeDestination : Actor
{
	Default
	{
		+NOINTERACTION
	}

	States
	{
		Spawn:
			TNT1 A 1
			{
				if (master && master.Health > 0)
				{
					Warp(master, master.radius + 10, -(master.radius + 10), master.height + 4, flags: WARPF_NOCHECKPOSITION);
				}
			}
			Loop;
	}
}
