class HDRearviewMirror : HDPickup
{
	override void DetachFromOwner()
	{
		for (int i = 0; i < Cameras.Size(); ++i)
		{
			if (Cameras[i])
			{
				Cameras[i].Destroy();
			}
		}
		SwitchShoulderTicker = 0;

		Super.DetachFromOwner();
	}

	override bool Use(bool pickup)
	{
		if (!pickup)
		{
			if (owner.player.cmd.buttons & BT_USE)
			{
				if (Amount == 1 && SwitchShoulderTicker == 0)
				{
					Cameras[0].LeftShoulder = !Cameras[0].LeftShoulder;
					SwitchShoulderTicker = 40;
					return false;
				}
			}
			else
			{
				Disabled = !Disabled;
			}
		}
		return Super.Use(pickup);
	}

	override void DoEffect()
	{
		if (SwitchShoulderTicker > 0)
		{
			SwitchShoulderTicker--;
		}

		switch (Amount)
		{
			case 1:
			{
				TryCreateCamera(0, false);
				if (Cameras[1])
				{
					Cameras[1].Destroy();
				}
				break;
			}
			default:
			{
				TryCreateCamera(0, false);
				TryCreateCamera(1, !Cameras[0].LeftShoulder);
				break;
			}
		}

		Super.DoEffect();
	}

	override void DrawHUDStuff(HDStatusBar sb, HDPlayerPawn hpl, int hdflags, int gzflags)
	{
		if (hdflags & HDSB_AUTOMAP || SwitchShoulderTicker > 0 || Disabled)
		{
			return;
		}
		
		for (int i = 0; i < Cameras.Size(); ++i)
		{
			if (Cameras[i])
			{
				// [Ace] This can get expensive because it has to render the scene multiple times.
				vector2 scale = sb.GetHudScale();
				double scaleFac = max(scale.x, scale.y) / 3.0;
				TexMan.SetCameraToTexture(Cameras[i], "HDMRRCM"..i, 100);

				bool flip = i == 1 || Cameras[i].LeftShoulder;
				int flags = flip ? sb.DI_ITEM_RIGHT_TOP : sb.DI_ITEM_LEFT_TOP;
				double shift = flip ? -9 : 9;
				vector2 baseOffset = ((Cameras[i].LeftShoulder ? -30 : 30), 8) / scaleFac;
				sb.DrawImage("HDMRRCM"..i, (baseOffset.x + shift / scaleFac, baseOffset.y + 9 / scaleFac) + hpl.wepbob, sb.DI_SCREEN_CENTER_TOP | flags, scale: (0.3, 0.3) / scaleFac);
				sb.DrawImage("RVMRROR", baseOffset + hpl.wepbob, sb.DI_SCREEN_CENTER_TOP | flags, scale: (1.5, 1.5) / scaleFac);
			}
		}
	}

	private void TryCreateCamera(int which, bool left)
	{
		if (!Cameras[which])
		{
			Cameras[which] = HDRearviewCamera(Spawn("HDRearviewCamera", pos));
			Cameras[which].master = owner;
			Cameras[which].LeftShoulder = left;
			Cameras[which].Tick();
		}
	}

	private HDRearviewCamera Cameras[2];
	private int SwitchShoulderTicker;
	private bool Disabled;

	Default
	{
		+INVENTORY.INVBAR
		+HDPICKUP.FITSINBACKPACK
		-HDPICKUP.DROPTRANSLATION
		HDPickup.Bulk 10;
		Inventory.PickupMessage "$PICKUP_REARVIEWMIRROR";
		Inventory.PickupSound "weapons/pocket";
		Inventory.Icon "RVMGZ0";
		Scale 0.28;
		Tag "$TAG_REARVIEWMIRROR";
		HDPickup.RefId "rvm";
	}

	States
	{
		Spawn:
			RVMG Z -1;
			Stop;
	}
}

class HDRearviewCamera : Actor
{
	override void Tick()
	{
		Super.Tick();

		if (!master || master.Health <= 0)
		{
			Destroy();
			return;
		}

		Warp(master, master.radius + 8, LeftShoulder ? -master.radius - 2 : master.radius + 2, master.height, flags: WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE);
		double angleToMirror = DeltaAngle(master.Angle, master.AngleTo(self));
		angle = (master.angle - 180) - angleToMirror;

		// for (int i = 0; i < 10; ++i)
		// {
		// 	A_SpawnParticle(0xFFFFFFFF, SPF_RELATIVE | SPF_FULLBRIGHT, 1, 2, 0, i, 0, 0);
		// }
	}

	bool LeftShoulder;

	Default
	{
		+SEEINVISIBLE // [Ace] So it doesn't spaz out if the player is invisible, although the mirror won't even show up to begin with.
		+NOINTERACTION
	}

	States
	{
		Spawn:
			TNT1 A -1;
			Stop;
	}
}
