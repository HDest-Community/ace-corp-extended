class FAK_HDPistol_Suppressor : FAK_Upgrade
{
	override string GetItem() { return "HDPistol"; }
	override string GetDisplayName() { return "Suppressor"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

		int mag = wpn.WeaponStatus[PISS_MAG];
		int chamber = wpn.WeaponStatus[PISS_CHAMBER];
		int selectFire = wpn.WeaponStatus[PISS_FLAGS] &= PISF_SELECTFIRE;
		wpn.destroy();

		Name cls = 'HushPuppyPistol';
		HDWeapon pistol;
		if (plr.FindInventory(cls)) {
			pistol = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			pistol.angle = plr.angle;
			pistol.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			pistol = HDWeapon(plr.GiveInventoryType(cls));
		}

		pistol.WeaponStatus[PISS_MAG] = mag;
		pistol.WeaponStatus[PISS_CHAMBER] = chamber;

		if (selectFire) GiveCore(plr, 0.5);
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'HushPuppyPistol';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'HushPuppyPistol';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a suppressor on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_HushPuppy_Suppressor : FAK_Upgrade
{
	override string GetItem() { return "HushpuppyPistol"; }
	override string GetDisplayName() { return "Suppressor"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

		int mag = wpn.WeaponStatus[PISS_MAG];
		int chamber = wpn.WeaponStatus[PISS_CHAMBER];
		wpn.destroy();

		Name cls = 'HDPistol';
		HDWeapon pistol;
		if (plr.FindInventory(cls)) {
			pistol = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			pistol.angle = plr.angle;
			pistol.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			pistol = HDWeapon(plr.GiveInventoryType(cls));
		}

		pistol.WeaponStatus[PISS_MAG] = mag;
		pistol.WeaponStatus[PISS_CHAMBER] = chamber;

		GiveCore(plr, 0.5);
	}
}

class FAK_Boss_SawnOff : FAK_Upgrade
{
	override string GetItem() { return "BossRifle"; }
	override string GetDisplayName() { return "Sawn-Off"; }
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

		Name cls = 'ObrozzPistol';
		HDWeapon obrozz;
		if (plr.FindInventory(cls))
		{
			obrozz = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			obrozz.angle = plr.angle;
			obrozz.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		}
		else
		{
			obrozz = HDWeapon(plr.GiveInventoryType(cls));
		}

		obrozz.WeaponStatus[0] = status;
		obrozz.WeaponStatus[1] = chamber;
		obrozz.WeaponStatus[2] = mag;
		obrozz.WeaponStatus[3] = zoom;
		obrozz.WeaponStatus[4] = dropAdjust;
		obrozz.WeaponStatus[5] = heat;
		obrozz.WeaponStatus[6] = grime;
		obrozz.WeaponStatus[7] = recasts;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return HUResult_Destructive; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'ObrozzPistol';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'ObrozzPistol';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a saw on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_ZM66_Hacked : FAK_Upgrade
{
	override string GetItem() { return "ZM66AssaultRifle"; }
	override string GetDisplayName() { return "Jailbreak"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int status = wpn.WeaponStatus[0];
		int mag = wpn.WeaponStatus[ZM66S_MAG];
		int fireMode = wpn.WeaponStatus[ZM66S_AUTO];
		int zoom = wpn.WeaponStatus[ZM66S_ZOOM];
		int heat = wpn.WeaponStatus[ZM66S_HEAT];
		int airburst = wpn.WeaponStatus[ZM66S_AIRBURST];
		int xhair = wpn.WeaponStatus[ZM66S_DOT];
		wpn.Destroy();

		Name cls = 'HackedZM66AssaultRifle';
		HDWeapon hzm;
		if (plr.FindInventory(cls)) {
			hzm = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			hzm.angle = plr.angle;
			hzm.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			hzm = HDWeapon(plr.GiveInventoryType(cls));
		}

		hzm.WeaponStatus[0] = status;
		hzm.WeaponStatus[ZM66S_MAG] = mag;
		hzm.WeaponStatus[ZM66S_AUTO] = fireMode;
		hzm.WeaponStatus[ZM66S_ZOOM] = zoom;
		hzm.WeaponStatus[ZM66S_HEAT] = heat;
		hzm.WeaponStatus[ZM66S_AIRBURST] = airburst;
		hzm.WeaponStatus[ZM66S_DOT] = xhair;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return HUResult_Destructive; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'HackedZM66AssaultRifle';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'HackedZM66AssaultRifle';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have time to be messing with that!";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_HackedZM66_SelectFire : FAK_ZM66_SelectFire
{
	override string GetItem() { return "HackedZM66AssaultRifle"; }
}

class FAK_HackedZM66_GL : FAK_ZM66_GL
{
	override string GetItem() { return "HackedZM66AssaultRifle"; }
}

// Holding off on these until I can figure out a nice solution to the class check in FAK_UpgradeThinker
/* class FAK_HackedZM66_HeatExhaust : FAK_ZM66_HeatExhaust
{
	override string GetItem() { return "HackedZM66AssaultRifle"; }
}

class FAK_HackedZM66_Dejammer : FAK_ZM66_Dejammer
{
	override string GetItem() { return "HackedZM66AssaultRifle"; }
} */