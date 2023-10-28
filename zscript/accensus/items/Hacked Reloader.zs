class HackedReloader : AutoReloader
{
	override string,double GetPickupSprite()
	{
		return "HRLDA0", 1.0;
	}
	override void DrawHUDStuff(HDStatusBar sb, HDWeapon hdw, HDPlayerPawn hpl) // [Ace] I won't bother fixing the spacing on this right now.
	{
		vector2 bob=hpl.wepbob*0.3;
		int brass=hpl.countinv("SevenMilBrass");
		int fourm=hpl.countinv("FourMilAmmo");
		double lph=(brass&&fourm>=4)?1.:0.6;
		sb.drawimage("HRLDA0",(0,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER,
			alpha:lph,scale:(2,2)
		);
		sb.drawimage("RBRSA3A7",(-30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_RIGHT,
			alpha:lph,scale:(2.5,2.5)
		);
		sb.drawimage("RCLSA3A7",(30,-64)+bob,
			sb.DI_SCREEN_CENTER_BOTTOM|sb.DI_ITEM_CENTER|sb.DI_ITEM_LEFT,
			alpha:lph,scale:(1.9,4.7)
		);
		sb.drawstring(
			sb.psmallfont,""..brass,(-30,-54)+bob,
			sb.DI_TEXT_ALIGN_RIGHT|sb.DI_SCREEN_CENTER_BOTTOM,
			fourm?Font.CR_GOLD:Font.CR_DARKGRAY,alpha:lph
		);
		sb.drawstring(
			sb.psmallfont,""..fourm,(30,-54)+bob,
			sb.DI_TEXT_ALIGN_LEFT|sb.DI_SCREEN_CENTER_BOTTOM,
			fourm?Font.CR_LIGHTBLUE:Font.CR_DARKGRAY,alpha:lph
		);
	}
	override double WeaponBulk()
	{
		return 30 * amount;
	}
	void A_MakeRound()
	{
		if (brass < 1 || powders < 4)
		{
			makinground = false;
			SetStateLabel("spawn");
			return;
		}
		brass--;
		powders -= 4;

		A_StartSound("roundmaker/pop", 10);

		if(!random(0, 31))
		{
			A_SpawnItemEx("HDExplosion");
			A_Explode(32, 32);
		}
		else
		{
			A_SpawnItemEx("SevenMilAmmoRecast", 0, 0, 0, 1, 0, 3, 0, SXF_NOCHECKPOSITION);
		}
	}

	Default
	{
		Tag "$TAG_HACKEDRELOADER";
		HDWeapon.RefId "7hr";
	}

	States
	{
		Spawn:
			HRLD A -1 NoDelay A_JumpIf(invoker.makinground && invoker.brass > 0 && invoker.powders >= 3, "Chug");
			Stop;
		Chug:
			---- AAAAAAAAAA 3
			{
				invoker.A_Chug();
			}
			---- A 10
			{
				invoker.A_MakeRound();
			}
			---- A 0 A_Jump(256, "Spawn");
			Stop;
	}
}
