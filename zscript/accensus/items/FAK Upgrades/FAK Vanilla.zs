class FAK_HDPistol_SelectFire : FAK_Upgrade
{
	override string GetItem() { return "HDPistol"; }
	override string GetDisplayName() { return "Select-Fire"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[PISS_FLAGS] |= PISF_SELECTFIRE; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[PISS_FLAGS] & PISF_SELECTFIRE > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[PISS_FLAGS] &= ~PISF_SELECTFIRE; GiveCore(wpn.owner, 0.5); }
}

class FAK_HDRevolver_Speedloader : FAK_Upgrade
{
	override string GetItem() { return "HDRevolver"; }
	override string GetDisplayName() { return "Speedloader"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 64; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 64 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~64; GiveCore(wpn.owner, 0.8); }
}

class FAK_SMG_SelectFire : FAK_Upgrade
{
	override string GetItem() { return "HDSMG"; }
	override string GetDisplayName() { return "Select-Fire"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SMGS_SWITCHTYPE] = 0; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[SMGS_SWITCHTYPE] == 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SMGS_SWITCHTYPE] = 1; GiveCore(wpn.owner, 0.05); }
}

class FAK_SMG_ReflexSight : FAK_Upgrade
{
	override string GetItem() { return "HDSMG"; }
	override string GetDisplayName() { return "Reflex Sight"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SMGS_FLAGS] |= SMGF_REFLEXSIGHT; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[SMGS_FLAGS] & SMGF_REFLEXSIGHT > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SMGS_FLAGS] &= ~SMGF_REFLEXSIGHT; }
}

class FAK_Hunter_FullAuto : FAK_Upgrade
{
	override string GetItem() { return "Hunter"; }
	override string GetDisplayName() { return "Full-Auto"; }
	override int GetCost() { return 2; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= HUNTF_CANFULLAUTO; wpn.WeaponStatus[0] &= ~HUNTF_EXPORT; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & HUNTF_CANFULLAUTO > 0; } // [Ace] Yes, you can upgrade an Export hunter and make it full-auto. But why would you do that? Are you mad? Do you work for Tchernobog?
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~HUNTF_CANFULLAUTO; GiveCore(wpn.owner, 1.0); }
}

class FAK_Hunter_MaxChoke : FAK_Upgrade
{
	override string GetItem() { return "Hunter"; }
	override string GetDisplayName() { return "Max Choke"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[HUNTS_CHOKE] = 7; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[HUNTS_CHOKE] == 7; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[HUNTS_CHOKE] = 0; GiveCore(wpn.owner, 0.6); }
}

class FAK_Hunter_Feeder : FAK_Upgrade
{
	override string GetItem() { return "Hunter"; }
	override string GetDisplayName() { return "Feeder"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 256; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 256 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~256; GiveCore(wpn.owner, 1.0); }
}

class FAK_Slayer_MaxChoke : FAK_Upgrade
{
	override string GetItem() { return "Slayer"; }
	override string GetDisplayName() { return "Max Choke"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SLAYS_CHOKE1] = 7; wpn.WeaponStatus[SLAYS_CHOKE2] = 7; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[SLAYS_CHOKE1] == 7 && wpn.WeaponStatus[SLAYS_CHOKE2] == 7; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[SLAYS_CHOKE1] = 0; wpn.WeaponStatus[SLAYS_CHOKE2] = 0; GiveCore(wpn.owner, 0.03); }
}

class FAK_Slayer_Autoloader : FAK_Upgrade
{
	override string GetItem() { return "Slayer"; }
	override string GetDisplayName() { return "Autoloader"; }
	override int GetCost() { return 2; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 256; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 256 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~256; GiveCore(wpn.owner, 1.0); }
}

class FAK_ZM66_SelectFire : FAK_Upgrade
{
	override string GetItem() { return "ZM66AssaultRifle"; }
	override string GetDisplayName() { return "Select-Fire"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] &= ~ZM66F_NOFIRESELECT; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[ZM66S_FLAGS] & ZM66F_NOFIRESELECT > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] |= ZM66F_NOFIRESELECT; GiveCore(wpn.owner, 0.03); }
}

class FAK_ZM66_GL : FAK_Upgrade
{
	override string GetItem() { return "ZM66AssaultRifle"; }
	override string GetDisplayName() { return "Grenade Launcher"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] &= ~ZM66F_NOLAUNCHER; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[ZM66S_FLAGS] & ZM66F_NOLAUNCHER > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp)
	{
		wpn.WeaponStatus[ZM66S_FLAGS] |= ZM66F_NOLAUNCHER;
		GiveCore(wpn.owner, 0.1);
		if (wpn.WeaponStatus[LIBS_FLAGS] & ZM66F_GRENADELOADED)
		{
			wpn.WeaponStatus[LIBS_FLAGS] &= ~ZM66F_GRENADELOADED;
			wpn.owner.A_SpawnItemEx('HDRocketAmmo', cos(wpn.owner.pitch) * 10, 0, wpn.owner.height - 10 - 10 * sin(wpn.owner.pitch), wpn.owner.vel.x, wpn.owner.vel.y, wpn.owner.vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
			wpn.owner.A_StartSound("weapons/grenopen", CHAN_WEAPON);
		}
	}
}

class FAK_ZM66_HeatExhaust : FAK_Upgrade
{
	override string GetItem() { return "ZM66AssaultRifle"; }
	override string GetDisplayName() { return "Heat Exhaust"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] |= 2048; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[ZM66S_FLAGS] & 2048 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] &= ~2048; GiveCore(wpn.owner, 0.8); }
}

class FAK_ZM66_Dejammer : FAK_Upgrade
{
	override string GetItem() { return "ZM66AssaultRifle"; }
	override string GetDisplayName() { return "Dejammer"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] |= 4096; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[ZM66S_FLAGS] & 4096 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[ZM66S_FLAGS] &= ~4096; GiveCore(wpn.owner, 0.8); }
}

class FAK_Vulcanette_Repair : FAK_Upgrade
{
	override string GetItem() { return "Vulcanette"; }
	override string GetDisplayName() { return "Full Repair"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[VULCS_PERMADAMAGE] = 0; wpn.WeaponStatus[VULCS_BREAKCHANCE] = 0; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return HUResult_Repeatable; }
}

class FAK_RL_RapidFire : FAK_Upgrade
{
	override string GetItem() { return "HDRL"; }
	override string GetDisplayName() { return "Rapid Rockets"; }
	override int GetCost() { return 2; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] |= 8; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[RLS_STATUS] & 8 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] &= ~8; GiveCore(wpn.owner, 1.0); }
}

class FAK_RL_RecoilDampener : FAK_Upgrade
{
	override string GetItem() { return "HDRL"; }
	override string GetDisplayName() { return "Recoil Dampener"; }
	override int GetCost() { return 2; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] |= 16; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[RLS_STATUS] & 16 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] &= ~16; GiveCore(wpn.owner, 1.0); }
}

class FAK_RL_Magazine : FAK_Upgrade
{
	override string GetItem() { return "HDRL"; }
	override string GetDisplayName() { return "Magazine"; }
	override int GetCost() { return 1; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] &= ~RLF_NOMAG; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[RLS_STATUS] & RLF_NOMAG); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp)
	{
		if (wpn.WeaponStatus[RLS_MAG] > 0)
		{
			wpn.owner.A_GiveInventory('HDRocketAmmo', wpn.WeaponStatus[RLS_MAG]);
			wpn.WeaponStatus[RLS_MAG] = 0;
		}
		wpn.WeaponStatus[RLS_STATUS] |= RLF_NOMAG;
		GiveCore(wpn.owner, 0.85);
	}
}

class FAK_RL_NoSafety : FAK_Upgrade
{
	override string GetItem() { return "HDRL"; }
	override string GetDisplayName() { return "No Safety"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] |= 32; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[RLS_STATUS] & 32 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[RLS_STATUS] &= ~32; }
}

class FAK_Blooper_NoSafety : FAK_Upgrade
{
	override string GetItem() { return "Blooper"; }
	override string GetDisplayName() { return "No Safety"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[BLOPS_STATUS] |= 8; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[BLOPS_STATUS] & 8 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[BLOPS_STATUS] &= ~8; }
}

class FAK_Liberator_SelectFire : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Select-Fire"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~LIBF_NOAUTO; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[LIBS_FLAGS] & LIBF_NOAUTO > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] |= LIBF_NOAUTO; GiveCore(wpn.owner, 0.25); }
}

class FAK_Liberator_GL : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Grenade Launcher"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~LIBF_NOLAUNCHER; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return !(wpn.WeaponStatus[LIBS_FLAGS] & LIBF_NOLAUNCHER > 0); }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp)
	{
		wpn.WeaponStatus[LIBS_FLAGS] |= LIBF_NOLAUNCHER;
		GiveCore(wpn.owner, 0.4);
		if (wpn.WeaponStatus[LIBS_FLAGS] & LIBF_GRENADELOADED)
		{
			wpn.WeaponStatus[LIBS_FLAGS] &= ~LIBF_GRENADELOADED;
			wpn.owner.A_SpawnItemEx('HDRocketAmmo', cos(wpn.owner.pitch) * 10, 0, wpn.owner.height - 10 - 10 * sin(wpn.owner.pitch), wpn.owner.vel.x, wpn.owner.vel.y, wpn.owner.vel.z, 0, SXF_ABSOLUTEMOMENTUM | SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
			wpn.owner.A_StartSound("weapons/grenopen", CHAN_WEAPON);
		}
	}
}

class FAK_Liberator_NoBullpup : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Long Rifle"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] |= 512; wpn.bFITSINBACKPACK = false; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~512; wpn.bFITSINBACKPACK = true; GiveCore(wpn.owner, 0.8); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[LIBS_FLAGS] & 512 > 0; }
}

class FAK_Liberator_BrassCatcher : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Brass Catcher"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] |= 16384; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~16384; GiveCore(wpn.owner, 0.8); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[LIBS_FLAGS] & 16384 > 0; }
}

class FAK_Liberator_FrontReticle : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Front Reticle"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] |= LIBF_FRONTRETICLE; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~LIBF_FRONTRETICLE; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[LIBS_FLAGS] & LIBF_FRONTRETICLE > 0; }
}

class FAK_Liberator_AltReticle : FAK_Upgrade
{
	override string GetItem() { return "LiberatorRifle"; }
	override string GetDisplayName() { return "Alt Reticle"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] |= LIBF_ALTRETICLE; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[LIBS_FLAGS] &= ~LIBF_ALTRETICLE; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[LIBS_FLAGS] & LIBF_ALTRETICLE > 0; }
}

class FAK_Thunderbuster_Chiller : FAK_Upgrade
{
	override string GetItem() { return "Thunderbuster"; }
	override string GetDisplayName() { return "Chiller"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 128; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~128; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 128 > 0; }
}

class FAK_Thunderbuster_Stabilizer : FAK_Upgrade
{
	override string GetItem() { return "Thunderbuster"; }
	override string GetDisplayName() { return "Stabilizer"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 256; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~256; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 256 > 0; }
}

class FAK_Thunderbuster_Amplifier : FAK_Upgrade
{
	override string GetItem() { return "Thunderbuster"; }
	override string GetDisplayName() { return "Amplifier"; }
	override int GetCost() { return 3; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] |= 512; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[TBS_FLAGS] &= ~512; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[TBS_FLAGS] & 512 > 0; }
}

class FAK_BFG_Accelerator : FAK_Upgrade
{
	override string GetItem() { return "BFG9K"; }
	override string GetDisplayName() { return "Accelerator"; }
	override int GetCost() { return 5; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[BFGS_STATUS] |= 128; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[BFGS_STATUS] &= ~128; GiveCore(wpn.owner, 1.0); }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[BFGS_STATUS] & 128 > 0; }
}

class FAK_Boss_FrontReticle : FAK_Upgrade
{
	override string GetItem() { return "BossRifle"; }
	override string GetDisplayName() { return "Front Reticle"; }
	override int GetCost() { return 0; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= BOSSF_FRONTRETICLE; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~BOSSF_FRONTRETICLE; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & BOSSF_FRONTRETICLE > 0; }
}

class FAK_Boss_CustomChamber : FAK_Upgrade
{
	override string GetItem() { return "BossRifle"; }
	override string GetDisplayName() { return "Custom Chamber"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= BOSSF_CUSTOMCHAMBER; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & BOSSF_CUSTOMCHAMBER > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~BOSSF_CUSTOMCHAMBER; GiveCore(wpn.owner, 0.7); }
}

class FAK_Armor_Repair : FAK_Upgrade
{
	override string GetItem() { return "HDArmour"; }
	override string GetDisplayName() { return "Full Repair"; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp)
	{
		let arm = HDArmour(pkp);
		arm.Mags[arm.Mags.Size() - 1] = arm.mega ? 1070 : 144;
	}
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return HUResult_Repeatable; }
}

class FAK_MagManager_Speedloader : FAK_Upgrade
{
	override string GetItem() { return "MagManager"; }
	override string GetDisplayName() { return "Speedloader"; }
	override int GetCost() { return 6; }
	override void DoUpgrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] |= 16; }
	override int HasUpgrade(HDWeapon wpn, HDPickup pkp) { return wpn.WeaponStatus[0] & 16 > 0; }
	override void DoDowngrade(HDWeapon wpn, HDPickup pkp) { wpn.WeaponStatus[0] &= ~16; GiveCore(wpn.owner, 1.0); }
}