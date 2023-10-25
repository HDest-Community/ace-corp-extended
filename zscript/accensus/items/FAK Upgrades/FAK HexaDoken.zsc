class FAK_Bossmerg_ExtendedMag : FAK_Upgrade
{
	override string GetItem() { return "Bossmerg"; }
	override string GetDisplayName() { return "Extended Magazine"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 32; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 32 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~32; GiveCore(wpn.owner, 0.2); }
}

class FAK_SpeedHunter_FullAuto : FAK_Hunter_FullAuto
{
	override string GetItem() { return "HunterSpeed"; }
}

class FAK_SpeedHunter_MaxChoke : FAK_Hunter_MaxChoke
{
	override string GetItem() { return "HunterSpeed"; }
}

class FAK_SpeedHunter_Feeder : FAK_Hunter_Feeder
{
	override string GetItem() { return "HunterSpeed"; }
}

class FAK_SpeedHunter_SideSaddles : FAK_Upgrade
{
	override string GetItem() { return "HunterSpeed"; }
	override string GetDisplayName() { return "Side Saddles"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~128; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[0] & 128 > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~128; GiveCore(wpn.owner, 0.2); }
}

class FAK_Boss_NoScopeBoss : FAK_Upgrade
{
	override string GetItem() { return "BossRifle"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) 
	{
		Actor plr = wpn.owner;

		int status = wpn.WeaponStatus[0];
		int chamber = wpn.WeaponStatus[BOSSS_CHAMBER];
		int mag = wpn.WeaponStatus[BOSSS_MAG];
		int zoom = wpn.WeaponStatus[BOSSS_ZOOM];
		int dropAdjust = wpn.WeaponStatus[BOSSS_DROPADJUST];
		int heat = wpn.WeaponStatus[BOSSS_HEAT];
		int grime = wpn.WeaponStatus[BOSSS_GRIME];
		int recasts = wpn.WeaponStatus[BOSSS_RECASTS];
		wpn.Destroy();

		Name cls = 'NoScopeBoss';
		HDWeapon nsBoss;
		if (plr.FindInventory(cls)) {
			nsBoss = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			nsBoss.angle = plr.angle;
			nsBoss.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			nsBoss = HDWeapon(plr.GiveInventoryType(cls));
		}

		nsBoss.WeaponStatus[0] = status;
		nsBoss.WeaponStatus[1] = chamber;
		nsBoss.WeaponStatus[2] = mag;
		nsBoss.WeaponStatus[3] = zoom;
		nsBoss.WeaponStatus[4] = dropAdjust;
		nsBoss.WeaponStatus[5] = heat;
		nsBoss.WeaponStatus[6] = grime;
		nsBoss.WeaponStatus[7] = recasts;

		GiveCore(plr, 0.2);
	}
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'BossRifle';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'NoScopeBoss';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "The scope is permanently attached.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_NSB_Boss : FAK_Upgrade
{
	override string GetItem() { return "NoScopeBoss"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int status = wpn.WeaponStatus[0];
		int chamber = wpn.WeaponStatus[BOSSS_CHAMBER];
		int mag = wpn.WeaponStatus[BOSSS_MAG];
		int zoom = wpn.WeaponStatus[BOSSS_ZOOM];
		int dropAdjust = wpn.WeaponStatus[BOSSS_DROPADJUST];
		int heat = wpn.WeaponStatus[BOSSS_HEAT];
		int grime = wpn.WeaponStatus[BOSSS_GRIME];
		int recasts = wpn.WeaponStatus[BOSSS_RECASTS];
		
		wpn.Destroy();

		Name cls = 'BossRifle';
		HDWeapon boss;
		if (plr.FindInventory(cls)) {
			boss = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			boss.angle = plr.angle;
			boss.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			boss = HDWeapon(plr.GiveInventoryType(cls));
		}

		boss.WeaponStatus[0] = status;
		boss.WeaponStatus[1] = chamber;
		boss.WeaponStatus[2] = mag;
		boss.WeaponStatus[3] = zoom;
		boss.WeaponStatus[4] = dropAdjust;
		boss.WeaponStatus[5] = heat;
		boss.WeaponStatus[6] = grime;
		boss.WeaponStatus[7] = recasts;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'BossRifle';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'BossRifle';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a scope on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_NSB_CustomChamber : FAK_Upgrade
{
	override string GetItem() { return "NoScopeBoss"; }
	override string GetDisplayName() { return "Custom Chamber"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= BOSSF_CUSTOMCHAMBER; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & BOSSF_CUSTOMCHAMBER > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~BOSSF_CUSTOMCHAMBER; GiveCore(wpn.owner, 0.7); }
}