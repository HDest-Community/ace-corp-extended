class HDBoosterJets : HDPickup
{
	override void BeginPlay()
	{
		InternalBattery = MaxBattery;
		Super.BeginPlay();
	}

	protected void StopCharging()
	{
		IsCharging = false;
		RechargeTicks = 0;
		owner.A_StartSound("weapons/plasswitch", CHAN_WEAPON);
	}

	protected void Bang()
	{
		owner.A_StartSound("jetpack/bang", 10, pitch: 1 + frandom(-0.2, 0.2));
		
		let exp = Spawn("HDExplosion", (owner.pos.xy, owner.pos.z - 20), ALLOW_REPLACE);
		exp.vel.z -= 20;
		exp.vel.xy += AngleToVector(owner.angle + angle, 6);
		exp.deathsound = "jetpack/bang";
	}

	override void DoEffect()
	{
		ReactivationTics--;

		let plr = HDPlayerPawn(owner);
		if (Active)
		{
			if (level.time % 2 == 0)
			{
				plr.A_StartSound("jetpack/fwoosh", CHAN_AUTO, CHANF_DEFAULT, 0.12, pitch: 1.6 + 0.2 * (level.time & (1 | 2))); // [Ace] I have no idea how these bitwise ORs work or why they're there.
			}
			if (DrainTicks++ >= 35 * 8)
			{
				DrainTicks = 0;
				InternalBattery--;
			}

			if (InternalBattery <= 0 || plr.incapacitated > 0)
			{
				InternalBattery = max(0, InternalBattery);
				Active = false;
			}

			int buttons = plr.player.cmd.buttons;
			int oldbuttons = plr.player.oldbuttons;
			bool justPressedJump = buttons & BT_JUMP && !(oldbuttons & BT_JUMP);
			bool isPressingJump = buttons & BT_JUMP;
			bool isPressingSprint = buttons & BT_SPEED;

			if (plr && justPressedJump && ReactivationTics <= 0)
			{
				int Cost = int(max(2, 2 * plr.overloaded));
				if (InternalBattery >= Cost)
				{
					ReactivationTics = 20;
					Bang();

					plr.vel.z += (isPressingSprint ? 4 : 8);
					if (isPressingSprint)
					{
						plr.vel.xy *= 2.0;
					}
					plr.lastvel = plr.vel; // [Ace] So you don't incap from the thrust.
					plr.DamageMobj(plr, plr, 4, 'Internal');
					InternalBattery -= Cost;
				}
				else
				{
					plr.A_Log("You are overburdened.", true);
				}
			}
		}
		else if (IsCharging && InternalBattery < MaxBattery && RechargeTicks++ >= 35)
		{
			RechargeTicks = 0;
			
			let bat = HDBattery(owner.FindInventory("HDBattery"));
			int index = AceCore.GetLowestMag(bat, 1);
			if (index > -1)
			{
				bat.Mags[index]--;
				InternalBattery = min(MaxBattery, InternalBattery + ChargePerCharge);
			}
			else
			{
				StopCharging();
			}
		}
		else if (IsCharging && InternalBattery == MaxBattery)
		{
			StopCharging();
		}

		Super.DoEffect();
	}

	override int GetSbarNum(int flags)
	{
		let HDHud = HDStatusBar(StatusBar);
		HDHud.SavedColour = Active ? Font.CR_GREEN : (IsCharging ? Font.CR_SAPPHIRE : Font.CR_RED);
		return InternalBattery;
	}

	protected bool Active;
	protected bool IsCharging;
	protected int InternalBattery;
	protected int ReactivationTics;
	protected int DrainTicks;
	protected int RechargeTicks;

	const MaxBattery = 100;
	const ChargePerCharge = MaxBattery / 20;

	Default
	{
		+HDPICKUP.CHEATNOGIVE
		+HDPICKUP.NOTINPOCKETS
		-HDPICKUP.DROPTRANSLATION
		-HDPICKUP.FITSINBACKPACK
		+HDPICKUP.NEVERSHOWINPICKUPMANAGER
		+INVENTORY.INVBAR
		HDPickup.Bulk 100;
		HDPickup.RefID "bsj";
		Inventory.MaxAmount 1;
		Inventory.Icon "BSJTA0";
		Inventory.PickupMessage "$PICKUP_BOOSTERJETS";
		Scale 0.7;
		Tag "$TAG_BOOSTERJETS";
	}

	States
	{
		Spawn:
			BSJT A -1;
			Stop;
		Use:
			TNT1 A 0
			{
				if (!invoker.Active && player.cmd.buttons & BT_USE)
				{
					if (!invoker.IsCharging)
					{
						invoker.IsCharging = true;
						A_StartSound("weapons/plasswitch", CHAN_WEAPON);
					}
					else
					{
						invoker.StopCharging();
					}
				}
				else
				{
					invoker.IsCharging = false;
					invoker.Active = !invoker.Active;
					A_StartSound("jetpack/wear", CHAN_WEAPON);
				}
			}
			Fail;
	}
}
