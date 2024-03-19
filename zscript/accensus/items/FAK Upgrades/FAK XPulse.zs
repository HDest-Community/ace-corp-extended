class FAK_XPulseTB_Chiller : FAK_Upgrade
{
	override string GetItem() { return "CrossPulseThunderBuster"; }
	override string GetDisplayName() { return "Chiller"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 128; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~128; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 128 > 0; }
}

class FAK_XPulseTB_Stabilizer : FAK_Upgrade
{
	override string GetItem() { return "CrossPulseThunderBuster"; }
	override string GetDisplayName() { return "Stabilizer"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 256; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~256; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 256 > 0; }
}

class FAK_XPulseTB_Amplifier : FAK_Upgrade
{
	override string GetItem() { return "CrossPulseThunderBuster"; }
	override string GetDisplayName() { return "Amplifier"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 512; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~512; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 512 > 0; }
}

class FAK_XPulseTB_ThunderBuster : FAK_Upgrade
{
	override string GetItem() { return "CrossPulseThunderBuster"; }
	override string GetDisplayName() { return "Cross Pulse"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

        int flags = wpn.WeaponStatus[TBS_FLAGS];
		int battery = wpn.WeaponStatus[TBS_BATTERY];
		wpn.Destroy();

		Name cls = 'ThunderBuster';
		HDWeapon tb;

		if (plr.FindInventory(cls)) {
			tb = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			tb.angle = plr.angle;
			tb.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			tb = HDWeapon(plr.GiveInventoryType(cls));
		}
		
        tb.WeaponStatus[TBS_FLAGS] = flags;
		tb.WeaponStatus[TBS_BATTERY] = battery;

		GiveCore(plr, 1.0); 
	}
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'ThunderBuster';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'ThunderBuster';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have an assembly core.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_ThunderBuster_XPulseTB : FAK_Upgrade
{
	override string GetItem() { return "ThunderBuster"; }
	override string GetDisplayName() { return "Cross Pulse"; }
	override int GetCost() { return 5; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

        int flags = wpn.WeaponStatus[TBS_FLAGS];
		int battery = wpn.WeaponStatus[TBS_BATTERY];
		wpn.Destroy();

		Name cls = 'CrossPulseThunderBuster';
		HDWeapon xtb;

		if (plr.FindInventory(cls)) {
			xtb = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			xtb.angle = plr.angle;
			xtb.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			xtb = HDWeapon(plr.GiveInventoryType(cls));
		}
		
        xtb.WeaponStatus[TBS_FLAGS] = flags;
		xtb.WeaponStatus[TBS_BATTERY] = battery;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'CrossPulseThunderBuster';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'CrossPulseThunderBuster';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a Cross Pulse Modification Kit on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}