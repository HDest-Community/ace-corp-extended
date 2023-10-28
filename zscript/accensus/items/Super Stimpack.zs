class PortableSuperStimpack : PortableStimpack {

	default {
		Inventory.PickupMessage "$PICKUP_SUPERSTIM";
		Inventory.Icon "SSTMA0";
		Tag "$TAG_SUPERSTIM";
		HDWeapon.RefId "sst";
		PortableStimpack.mainHelpText "$SUPERSTIM_HELPTEXT";
		PortableStimpack.spentInjectType "SpentSuperStim";
		PortableStimpack.injectType "InjectSuperStimDummy";
	}
	
	states(actor) {
		spawn2:
			SSTM A -1;
			Stop;
	}
}

class InjectSuperStimDummy : InjectStimDummy {
	states {
		spawn:
			TNT1 A 6 nodelay {
				tg = HDPlayerPawn(target);
				if (!tg || tg.bKILLED)
				{
					destroy();
					return;
				}

				int aggro = int(ceil(tg.CountInv('HDSuperStim') / 200.0));
				tg.aggravateddamage += aggro;
				if (HDZerk.IsZerk(tg)) tg.aggravateddamage += aggro * 2;
			}
			TNT1 A 1 {
				if (!tg || tg.bKILLED)
				{
					Destroy();
					return;
				}

				// [Ace] Standard dosage. Thanks, doc.
				tg.A_GiveInventory('HDStim', HDStim.HDSTIM_DOSE);
				tg.fatigue += 20;
				tg.bloodpressure += 30;
				tg.A_GiveInventory('HDSuperStim', 200);
				
				Accuracy--;
			} stop;
	}
}

class HDSuperStim : HDDrug {

	bool comedown;

	override void OnHeartbeat(HDPlayerPawn hdp) {

		if (!comedown) {
			if (amount > 280) {

				// [Ace] You might be able to save yourself if you have blues in your system.
				hdp.DamageMobj(hdp, hdp, 2, 'Internal', DMG_FORCED);
				hdp.fatigue += 2;
				hdp.bloodpressure += 2;
				amount--;
			} else {

				int blues = hdp.CountInv('HealingMagic');
				int amt = int(ceil(amount / 25.0));
				if (blues > 0 && !random(0, 4)) {
					hdp.A_TakeInventory('HealingMagic', 1);
					amt *= 2;
				}
				hdp.beatmax = min(hdp.beatmax, 14);
				hdp.bloodpressure = max(hdp.bloodpressure, 30);
				hdp.GiveBody(amt);
				hdp.incaptimer = max(0, hdp.incaptimer - int(ceil(amount / 10.0)));
			}

			amount = max(0, amount - 1);
			if (amount == 0) {
				amount += 30;
				hdp.A_SetBlend("20 0a 0f", 0.6, 20);
				hdp.A_StartSound(hdp.painsound, CHAN_VOICE, volume: 0.5);
				comedown = true;
			}
		} else if (amount > 0) {

			hdp.fatigue++;
			hdp.beatmax = min(hdp.beatmax, 3);
			hdp.bloodpressure = max(hdp.bloodpressure, 50);
			amount--;
		}
	}
}

class SpentSuperStim : SpentStim {
	default {
		Translation "none";
	}

	States {
		spawn:
			SSYR G 0;
		spawn2:
			---- G 1 {
				A_SetRoll(Roll + 60, SPF_INTERPOLATE);
			} wait;
		death:
			---- G -1 {
				roll = 0;
				if (!random(0, 1)) Scale.x *= -1;
			} stop;
	}
}
