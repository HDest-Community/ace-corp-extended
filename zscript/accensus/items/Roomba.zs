class HDRoomba : HDPickup
{
	Default
	{
		+HDPICKUP.CHEATNOGIVE
		+HDPICKUP.NOTINPOCKETS
		+INVENTORY.INVBAR
		HDPickup.Bulk 30;
		HDPickup.RefID "rmb";
		Inventory.MaxAmount 3;
		Inventory.Icon "RMBAA1";
		Inventory.PickupMessage "$PICKUP_ROOMBA";
		Tag "$TAG_ROOMBA";
	}

	States
	{
		Spawn:
			RMBA A -1;
			Stop;
		Use:
			TNT1 A 0
			{
				bool success; Actor a;

				double sinp = sin(pitch);
				double cosp = cos(pitch);

				double XVel = 3 + ((player.cmd.buttons & BT_SPEED ? 15 : 2) * (CheckInventory("PowerStrength", 0) ? 3 : 1)) * cosp;
				double YVel = -(vel.x * sin(angle) + vel.y * cos(angle));
				double ZVel = 3 + (10 * -sinp) * (CheckInventory("PowerStrength", 0) ? 2 : 1);

				[success, a] = A_SpawnItemEx("HDRoombaHover", 0, 0, height / 2 + 8, XVel, YVel, ZVel, flags: SXF_SETMASTER | SXF_TRANSFERTRANSLATION);
				let Roomba = HDRoombaHover(a);
				Roomba.vel += vel;
				Roomba.SetShade(player.GetColor());
				Roomba.Destination = RoombaDestination(Spawn("RoombaDestination", pos));
				Roomba.Destination.master = self;
			}
			Stop;
	}
}

class HDRoombaHover : HDUPK
{	
	private void TurnOff()
	{
		if (!TurnedOff)
		{
			VolDecrease = 0;
			bNOGRAVITY = false;
			TurnedOff = true;
			A_StopAllSounds();
			A_StartSound("HDRoomba/VacuumStop", 7, 0, 0.75);
			SetStateLabel("Spawn");
		}
	}

	private void VacuumItems()
	{
		int itemsCollected = 0;
		let it = BlockThingsIterator.Create(self, 192);

		while (it.Next())
		{
			if (Distance3D(it.thing) > 192 || !CheckSight(it.thing)) continue;

			if (it.thing is 'HDUPK')
			{
				let hdp = HDUPK(it.thing);

				name vacuumableUPKs[] = {
					// Vanilla 7mm Brass
					'HDSpent7mm',

					// HDBulletLib Brasses
					'SpentSavage300',
					'HDSpent3006',
					'HDSpent10mm',
					'HDSpent762Tokarev',

					// Bryans' Brasses
					'BRoundSpent',

					// Merchant's Mercenary Bucks
					'BaseCurrencyPickup',
					'MercenaryBucks'
				};

				foreach (vacuumable : vacuumableUPKs)
				{
					if (hdp && hdp is vacuumable && CountInv(hdp.PickupType) < GetDefaultByType(hdp.PickupType).maxAmount)
					{
						hdp.pickTarget = self;
						hdp.A_HDUPKGive();
						itemsCollected++;
					}
				}
			}
			else if (it.thing is 'HDPickup')
			{
				let hdp = HDPickup(it.thing);

				name vacuumablePickups[] = {
					// Vanilla 7mm Brass
					'SevenMilBrass',

					// HDBulletLib Brasses
					'Savage300Brass',
					'ThirtyAughtSixBrass',
					'TenMilBrass',
					'TokarevBrass',

					// Bryans' Brasses
					'BRoundShell',

					// URL Crafting Materials
					'HDRel_CraftingMaterial',

					// Merchant's Mercenary Bucks
					'MercenaryBucks'
				};

				foreach (vacuumable : vacuumablePickups)
				{
					if (hdp && hdp is vacuumable && CountInv(hdp.GetClass()) < hdp.maxAmount)
					{
						hdp.ActualPickup(self);
						itemsCollected++;
					}
				}
			}

			// Once we've collected at least three, quit.
			if (itemsCollected >= 3) break;
		}
	}

	override bool OnGrab(Actor grabber)
	{
		if (!TurnedOff && PickupTimer <= 0)
		{
			PickupTimer = 10;
			return false;
		}

		if (Destination)
		{
			Destination.Destroy();
		}

		TurnOff();

		A_Face(grabber, 0, 0);

		for (Inventory next = Inv; next != null;)
		{
			Inventory cur = next;
			next = next.Inv;
			if (cur.Amount > 0)
			{
				int maxGiveAmount = cur.maxAmount - grabber.CountInv(cur.GetClass());
				int giveAmount = min(cur.Amount, maxGiveAmount);

				HDF.Give(grabber, cur.GetClass(), GiveAmount);
				A_TakeInventory(cur.GetClass(), GiveAmount);

				if (cur && cur.Amount > 0)
				{
					// [Ace] Drop excess if player can't pick up more.
					A_DropInventory(cur.GetClass(), cur.Amount);
				}
			}
		}

		return Super.OnGrab(grabber);
	}

	private int PickupTimer;
	private bool TurnedOff;
	private double VolDecrease;
	RoombaDestination Destination;

	Default
	{
		Radius 8;
		Height 12;
		HDUPK.PickupType "HDRoomba";
		HDUPK.PickupMessage "Picked up a hovering roomba.";
		HDUPK.MaxUnitAmount 3;
		+SLIDESONWALLS
	}

	States
	{
		Spawn:
			RMBA A 1 A_JumpIf(!TurnedOff, "TurningOn");
			Loop;
		TurningOn:
			RMBA A 5
			{
				A_StartSound("HDRoomba/VacuumStart", CHAN_VOICE, CHANF_NOSTOP, 0.75);
				if (vel.length() < 1)
				{
					bNOGRAVITY = true;
					SetStateLabel("On");
				}
			}
			Loop;
		On:
			RMBA AAAABBBB 1
			{
				if (VolDecrease < 0.60)
				{
					VolDecrease += 0.005;
				}

				invoker.PickupTimer--;
				if (level.time % 5 == 0)
				{
					for (int i = 0; i < 360; i += 10)
					{
						A_SpawnParticle(fillcolor, SPF_RELATIVE | SPF_FULLBRIGHT, 15, 2, i, radius - 4, 0, 0, 0.2, 0, -frandom(0.45, 0.5));
					}
				}
				if (invoker.Destination && (invoker.Distance2D(invoker.Destination) > 40 || abs(invoker.pos.z - invoker.Destination.pos.z) > 20))
				{
					double pToDest = AceCore.PitchTo(invoker, invoker.Destination);

					A_Face(invoker.Destination, 180, 45);
					A_ChangeVelocity(0.5 * cos(pToDest), 0, 0.5 * sin(pToDest), CVF_RELATIVE);
					vel.x = clamp(vel.x, -2.5, 2.5);
					vel.y = clamp(vel.y, -2.5, 2.5);
					vel.z = clamp(vel.z, -2.5, 2.5);
				}
				else
				{
					A_ScaleVelocity(0.9);
				}

				A_SoundVolume(CHAN_VOICE, 0.75 - VolDecrease);
				A_StartSound("HDRoomba/VacuumLoop", CHAN_VOICE, CHANF_LOOPING, 0.75);
				VacuumItems();
			}
			Loop;
	}
}

class RoombaDestination : Actor
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
					Warp(master, master.radius + 10, master.radius + 10, master.height + 4, flags: WARPF_NOCHECKPOSITION);
				}
				else
				{
					Destroy();
				}
			}
			Loop;
	}
}
