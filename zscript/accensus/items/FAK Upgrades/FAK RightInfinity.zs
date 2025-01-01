class FAK_Reaper_UBGL : FAK_Upgrade
{
	override string GetItem() { return "RIReaper"; }
	override string GetDisplayName() { return "Underbarrel Grenade Launcher"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[11] = 1; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[11] == 1 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp)
    {
		wpn.WeaponStatus[11] = 0;
		GiveCore(wpn.owner, 0.1);
		if (wpn.WeaponStatus[0] & 4)
		{
			wpn.WeaponStatus[0] &= ~4;
			wpn.owner.A_SpawnItemEx('HDRocketAmmo', cos(wpn.owner.pitch) * 10, 0, wpn.owner.height - 10 - 10 * sin(wpn.owner.pitch), wpn.owner.vel.x, wpn.owner.vel.y, wpn.owner.vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
			wpn.owner.A_StartSound("weapons/grenopen", CHAN_WEAPON);
		}
    }
}

class FAK_Reaper_UBZM : FAK_Upgrade
{
	override string GetItem() { return "RIReaper"; }
	override string GetDisplayName() { return "Underbarrel Carbine"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[11] = 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[11] == 2 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp)
    {
		wpn.WeaponStatus[11] = 0;
		GiveCore(wpn.owner, 0.1);
		if (wpn.WeaponStatus[0] & 4)
		{
			wpn.WeaponStatus[0] &= ~4;
			wpn.owner.A_SpawnItemEx('FourMilAmmo', cos(wpn.owner.pitch) * 10, 0, wpn.owner.height - 10 - 10 * sin(wpn.owner.pitch), wpn.owner.vel.x, wpn.owner.vel.y, wpn.owner.vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
		}

        HDMagAmmo.SpawnMag(wpn.owner, "HD4mMag", wpn.WeaponStatus[6] % 100);
		wpn.WeaponStatus[6] = -1;
    }
}

class FAK_Bronto_Buddy : FAK_Upgrade
{
	override string GetItem() { return "Brontornis"; }
	override string GetDisplayName() { return "Side Saddles"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int chamber = wpn.WeaponStatus[1];
		wpn.Destroy();

		Name cls = 'RIBrontoBuddy';
		HDWeapon buddy;
		if (plr.FindInventory(cls))
		{
			buddy = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			buddy.angle = plr.angle;
			buddy.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		}
		else
		{
			buddy = HDWeapon(plr.GiveInventoryType(cls));
		}
		buddy.WeaponStatus[1] = chamber;
		buddy.WeaponStatus[4] = 0;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'RIBrontoBuddy';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'RIBrontoBuddy';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have any side saddles on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_BrontoBuddy_Buddy : FAK_Upgrade
{
	override string GetItem() { return "RIBrontoBuddy"; }
	override string GetDisplayName() { return "Side Saddles"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

		int chamber = wpn.WeaponStatus[1];
		int saddles = wpn.WeaponStatus[4];
		wpn.destroy();

		Name cls = 'Brontornis';
		HDWeapon bronto;
		if (plr.FindInventory(cls)) {
			bronto = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			bronto.angle = plr.angle;
			bronto.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			bronto = HDWeapon(plr.GiveInventoryType(cls));
		}

		bronto.WeaponStatus[1] = chamber;

		for (int i = 0; i < saddles; i++)
		{
			plr.A_SpawnItemEx(
				'BrontornisRound',
				cos(plr.pitch) * 10, 0, plr.height - 10 - 10 * sin(plr.pitch),
				plr.vel.x, plr.vel.y, plr.vel.z,
				0,
				SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH
			);
		}

		GiveCore(plr, 0.5);
	}
}