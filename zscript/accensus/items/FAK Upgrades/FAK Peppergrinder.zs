class FAK_Oddball_Pump : FAK_Upgrade
{
	override string GetItem() { return "HDOddball"; }
	override string GetDisplayName() { return "Pump"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 8; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~8; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 8 > 0; }
}

class FAK_BPX_ReflexSight : FAK_Upgrade
{
	override string GetItem() { return "HDBPX"; }
	override string GetDisplayName() { return "Reflex Sight"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 1; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[6] == 1 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 0; }
}

class FAK_BPX_Scope : FAK_Upgrade
{
	override string GetItem() { return "HDBPX"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[6] == 2 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 0; GiveCore(wpn.owner, 0.25); }
}

class FAK_HLAR_SelectFire : FAK_Upgrade
{
	override string GetItem() { return "HDHLAR"; }
	override string GetDisplayName() { return "Select-Fire"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[5] = 0; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[5] == 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[5] = 1; GiveCore(wpn.owner, 0.2); }
}

class FAK_HLAR_HairTrigger : FAK_Upgrade
{
	override string GetItem() { return "HDHLAR"; }
	override string GetDisplayName() { return "GL Hair-Trigger"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~4; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[0] & 4 > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 4; }
}

class FAK_ScopedRevolver_Revolver : FAK_Upgrade
{
	override string GetItem() { return "HDScopedRevolver"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

		int cyl1 = wpn.WeaponStatus[BUGS_CYL1];
		int cyl2 = wpn.WeaponStatus[BUGS_CYL2];
		int cyl3 = wpn.WeaponStatus[BUGS_CYL3];
		int cyl4 = wpn.WeaponStatus[BUGS_CYL4];
		int cyl5 = wpn.WeaponStatus[BUGS_CYL5];
		int cyl6 = wpn.WeaponStatus[BUGS_CYL6];
		wpn.Destroy();

		Name cls = 'HDRevolver';
		HDWeapon revolver;

		if (plr.FindInventory(cls)) {
			revolver = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			revolver.angle = plr.angle;
			revolver.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			revolver = HDWeapon(plr.GiveInventoryType(cls));
		}
		
		revolver.WeaponStatus[BUGS_CYL1] = cyl1;
		revolver.WeaponStatus[BUGS_CYL2] = cyl2;
		revolver.WeaponStatus[BUGS_CYL3] = cyl3;
		revolver.WeaponStatus[BUGS_CYL4] = cyl4;
		revolver.WeaponStatus[BUGS_CYL5] = cyl5;
		revolver.WeaponStatus[BUGS_CYL6] = cyl6;

		GiveCore(plr, 0.2); 
	}
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'HDRevolver';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'HDRevolver';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have an assembly core.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_Revolver_ScopedRevolver : FAK_Upgrade
{
	override string GetItem() { return "HDRevolver"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int cyl1 = wpn.WeaponStatus[BUGS_CYL1];
		int cyl2 = wpn.WeaponStatus[BUGS_CYL2];
		int cyl3 = wpn.WeaponStatus[BUGS_CYL3];
		int cyl4 = wpn.WeaponStatus[BUGS_CYL4];
		int cyl5 = wpn.WeaponStatus[BUGS_CYL5];
		int cyl6 = wpn.WeaponStatus[BUGS_CYL6];
		wpn.Destroy();

		Name cls = 'HDScopedRevolver';
		HDWeapon scopedRevolver;

		if (plr.FindInventory(cls)) {
			scopedRevolver = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			scopedRevolver.angle = plr.angle;
			scopedRevolver.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			scopedRevolver = HDWeapon(plr.GiveInventoryType(cls));
		}
		
		scopedrevolver.WeaponStatus[BUGS_CYL1] = cyl1;
		scopedrevolver.WeaponStatus[BUGS_CYL2] = cyl2;
		scopedrevolver.WeaponStatus[BUGS_CYL3] = cyl3;
		scopedrevolver.WeaponStatus[BUGS_CYL4] = cyl4;
		scopedrevolver.WeaponStatus[BUGS_CYL5] = cyl5;
		scopedrevolver.WeaponStatus[BUGS_CYL6] = cyl6;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'HDScopedRevolver';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'HDScopedRevolver';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a scope on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_Slayer_SawnOff : FAK_Upgrade
{
	override string GetItem() { return "Slayer"; }
	override string GetDisplayName() { return "Sawn-Off"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int leftChamber = wpn.WeaponStatus[SLAYS_CHAMBER1];
		int rightChamber = wpn.WeaponStatus[SLAYS_CHAMBER2];
		int saddles = wpn.WeaponStatus[SHOTS_SIDESADDLE];
		wpn.Destroy();

		if (saddles > 0)
		{
			plr.A_GiveInventory('HDShellAmmo', saddles);
		}

		Name cls = 'SawedSlayer';
		HDWeapon sawedOff;
		if (plr.FindInventory(cls))
		{
			sawedOff = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			sawedOff.angle = plr.angle;
			sawedOff.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		}
		else
		{
			sawedOff = HDWeapon(plr.GiveInventoryType(cls));
		}
		sawedOff.WeaponStatus[1] = leftChamber;
		sawedOff.WeaponStatus[2] = rightChamber;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return HUResult_Destructive; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'SawedSlayer';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'SawedSlayer';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a saw on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_ScopedSlayer_MaxChoke : FAK_Slayer_MaxChoke
{
	override string GetItem() { return "ScopedSlayer"; }
}

class FAK_ScopedSlayer_Slayer : FAK_Upgrade
{
	override string GetItem() { return "ScopedSlayer"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return true; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) {
		Actor plr = wpn.owner;

		int leftChamber = wpn.WeaponStatus[SLAYS_CHAMBER1];
		int rightChamber = wpn.WeaponStatus[SLAYS_CHAMBER2];
		int leftChoke = wpn.WeaponStatus[SLAYS_CHOKE1];
		int rightChoke = wpn.WeaponStatus[SLAYS_CHOKE2];
		int saddles = wpn.WeaponStatus[SHOTS_SIDESADDLE];
		wpn.Destroy();

		Name cls = 'Slayer';
		HDWeapon slayer;

		if (plr.FindInventory(cls)) {
			slayer = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			slayer.angle = plr.angle;
			slayer.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			slayer = HDWeapon(plr.GiveInventoryType(cls));
		}
		
		slayer.WeaponStatus[SLAYS_CHAMBER1] = leftChamber;
		slayer.WeaponStatus[SLAYS_CHAMBER2] = rightChamber;
		slayer.WeaponStatus[SLAYS_CHOKE1] = leftChoke;
		slayer.WeaponStatus[SLAYS_CHOKE2] = rightChoke;
		slayer.WeaponStatus[SHOTS_SIDESADDLE] = saddles;

		GiveCore(plr, 0.2); 
	}
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'Slayer';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'Slayer';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have an assembly core.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_Slayer_ScopedSlayer : FAK_Upgrade
{
	override string GetItem() { return "Slayer"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		Actor plr = wpn.owner;

		int leftChamber = wpn.WeaponStatus[SLAYS_CHAMBER1];
		int rightChamber = wpn.WeaponStatus[SLAYS_CHAMBER2];
		int leftChoke = wpn.WeaponStatus[SLAYS_CHOKE1];
		int rightChoke = wpn.WeaponStatus[SLAYS_CHOKE2];
		int saddles = wpn.WeaponStatus[SHOTS_SIDESADDLE];
		wpn.Destroy();

		Name cls = 'ScopedSlayer';
		HDWeapon scopedSlayer;

		if (plr.FindInventory(cls)) {
			scopedSlayer = HDWeapon(Actor.Spawn(cls, plr.pos + (0, 0, plr.height / 2)));
			scopedSlayer.angle = plr.angle;
			scopedSlayer.A_ChangeVelocity(1, 0, 1, CVF_RELATIVE);
		} else {
			scopedSlayer = HDWeapon(plr.GiveInventoryType(cls));
		}
		
		scopedSlayer.WeaponStatus[SLAYS_CHAMBER1] = leftChamber;
		scopedSlayer.WeaponStatus[SLAYS_CHAMBER2] = rightChamber;
		scopedSlayer.WeaponStatus[SLAYS_CHOKE1] = leftChoke;
		scopedSlayer.WeaponStatus[SLAYS_CHOKE2] = rightChoke;
		scopedSlayer.WeaponStatus[SHOTS_SIDESADDLE] = saddles;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return false; }
	override bool CheckPrerequisites(HDWeapon wpn, HDPickup pkp)
	{
		Name cls = 'ScopedSlayer';
		return (class<Actor>)(cls);
	}
	override string GetFailMessage(HDWeapon wpn, HDPickup pkp, int type)
	{
		Name cls = 'ScopedSlayer';
		if (type == FMType_Requirements && !((class<Actor>)(cls)))
		{
			return "You don't have a scope on hand.";
		}
		return Super.GetFailMessage(wpn, pkp, type);
	}
}

class FAK_Wiseau_DoubleAction : FAK_Upgrade
{
	override string GetItem() { return "HDWiseau"; }
	override string GetDisplayName() { return "Double-Action"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 4; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 4 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~4; GiveCore(wpn.owner, 0.3); }
}

class FAK_Wiseau_Capacitor : FAK_Upgrade
{
	override string GetItem() { return "HDWiseau"; }
	override string GetDisplayName() { return "Capacitor"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 2 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~2; GiveCore(wpn.owner, 0.4); }
}

class FAK_Lisa_Scope : FAK_Upgrade
{
	override string GetItem() { return "HDLisa"; }
	override string GetDisplayName() { return "Box Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 4; wpn.WeaponStatus[0] &= ~8; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 4 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~4; GiveCore(wpn.owner, 0.3); }
}

class FAK_Lisa_TechScope : FAK_Upgrade
{
	override string GetItem() { return "HDLisa"; }
	override string GetDisplayName() { return "Tech Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 8; wpn.WeaponStatus[0] &= ~4; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 8 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~8; GiveCore(wpn.owner, 0.3); }
}

class FAK_Lisa_DoubleAction : FAK_Upgrade
{
	override string GetItem() { return "HDLisa"; }
	override string GetDisplayName() { return "Double-Action"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 16; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 16 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~16; GiveCore(wpn.owner, 0.25); }
}

class FAK_IronsLiberator_SelectFire : FAK_Liberator_SelectFire
{
	override string GetItem() { return "IronsLiberatorRifle"; }
}

class FAK_IronsLiberator_GL : FAK_Liberator_GL
{
	override string GetItem() { return "IronsLiberatorRifle"; }
}

class FAK_IronsLiberator_NoBullpup : FAK_Liberator_NoBullpup
{
	override string GetItem() { return "IronsLiberatorRifle"; }
}

class FAK_IronsLiberator_FrontReticle : FAK_Liberator_FrontReticle
{
	override string GetItem() { return "IronsLiberatorRifle"; }
}

class FAK_IronsLiberator_AltReticle : FAK_Liberator_AltReticle
{
	override string GetItem() { return "IronsLiberatorRifle"; }
}

class FAK_BoxCannon_ExtendedMag : FAK_Upgrade
{
	override string GetItem() { return "HDBoxCannon"; }
	override string GetDisplayName() { return "Extended Magazine"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 1; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[7] == 1 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 0; GiveCore(wpn.owner, 0.3); }
}

class FAK_BoxCannon_DrumMag : FAK_Upgrade
{
	override string GetItem() { return "HDBoxCannon"; }
	override string GetDisplayName() { return "Drum Magazine"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[7] == 2 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 0; GiveCore(wpn.owner, 0.3); }
}

class FAK_BoxCannon_Broomhandle : FAK_Upgrade
{
	override string GetItem() { return "HDBoxCannon"; }
	override string GetDisplayName() { return "Broomhandle Stock"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 8; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 8 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~8; GiveCore(wpn.owner, 0.15); }
}

class FAK_BoxCannon_LongerBarrel : FAK_Upgrade
{
	override string GetItem() { return "HDBoxCannon"; }
	override string GetDisplayName() { return "Longer Barrel"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 1; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[6] == 1 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 0; GiveCore(wpn.owner, 0.25); }
}

class FAK_BoxCannon_Suppressor : FAK_Upgrade
{
	override string GetItem() { return "HDBoxCannon"; }
	override string GetDisplayName() { return "Suppressor"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[6] == 2 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[6] = 0; GiveCore(wpn.owner, 0.25); }
}

class FAK_Lotus_Scope : FAK_Upgrade
{
	override string GetItem() { return "HDLotus"; }
	override string GetDisplayName() { return "Scope"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 4; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 4 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~4; GiveCore(wpn.owner, 0.25); }
}

class FAK_Lotus_GasSeal : FAK_Upgrade
{
	override string GetItem() { return "HDLotus"; }
	override string GetDisplayName() { return "Improved Gas Seal"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 2 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~2; GiveCore(wpn.owner, 0.35); }
}

class FAK_Lotus_ExtendedBarrel : FAK_Upgrade
{
	override string GetItem() { return "HDLotus"; }
	override string GetDisplayName() { return "Extended Barrel"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 1; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[7] == 1 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 0; GiveCore(wpn.owner, 0.35); }
}

class FAK_Lotus_Suppressor : FAK_Upgrade
{
	override string GetItem() { return "HDLotus"; }
	override string GetDisplayName() { return "Suppressor"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 2; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[7] == 2 ? HUResult_Installed : HUResult_Unique; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[7] = 0; GiveCore(wpn.owner, 0.35); }
}