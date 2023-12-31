class HDDeployableBarricade : HDPickup
{
	override int DisplayAmount()
	{
		let HDHud = HDStatusBar(StatusBar);
		double perc = Health / double(default.Health);
		if (perc > 0.75)
		{
			HDHud.SavedColour = Font.CR_GREEN;
		}
		else if (perc > 0.50)
		{
			HDHud.SavedColour = Font.CR_YELLOW;
		}
		else if (perc > 0.25)
		{
			HDHud.SavedColour = Font.CR_ORANGE;
		}
		else if (perc > 0.08)
		{
			HDHud.SavedColour = Font.CR_RED;
		}
		else
		{
			HDHud.SavedColour = Font.CR_BLACK;
		}
		return Health;
	}

	Default
	{
		Health 5000;
		+HDPICKUP.CHEATNOGIVE
		+HDPICKUP.NOTINPOCKETS
		+INVENTORY.INVBAR
		-HDPICKUP.FITSINBACKPACK
		HDPickup.Bulk 250;
		HDPickup.RefID "dab";
		Inventory.MaxAmount 1;
		Inventory.Icon "DABRB0";
		Inventory.PickupMessage "$PICKUP_DEPLOYABLEBARRICADEs";
		Tag "$TAG_DEPLOYABLEBARRICADE";
		XScale 1.4;
		YScale 1.16;
	}

	States
	{
		Spawn:
			DABR A -1;
			Stop;
		Use:
			TNT1 A 0
			{
				bool success; Actor a;

				double sinp = sin(pitch);
				double cosp = cos(pitch);

				double XVel = 1 + (CheckInventory("PowerStrength", 0) ? 3 : 1) * cosp;
				double ZVel = 1 + (CheckInventory("PowerStrength", 0) ? 2 : 1) * -sinp;

				[success, a] = A_SpawnItemEx("HDDeployedBarricade", radius + 4, 0, height / 2 + 8, XVel, 0, ZVel, flags: SXF_NOCHECKPOSITION | SXF_SETMASTER | SXF_TRANSFERTRANSLATION);
				let depBarricade = HDDeployedBarricade(a);
				depBarricade.Health = invoker.Health;
				depBarricade.angle += 180;
				depBarricade.vel += vel;
			}
			Stop;
	}
}

class HDDeployedBarricade : HDActor
{
	override void Tick()
	{
		if (IsFrozen())
		{
			return;
		}

		Super.Tick();
		if (GetAge() % 10 == 0 && TimesUsed > 0)
		{
			TimesUsed--;
		}

		if (Deployed)
		{
			double healthFac = Health / double(GetDefaultByType('HDDeployableBarricade').Health);
			StretchFac = StretchFac < healthFac ? min(healthFac, StretchFac + 0.1) : max(healthFac, StretchFac - 0.1);
		}
		else if (InStateSequence(CurState, FindState('UnDeploy')) && StretchFac > 0)
		{
			StretchFac = max(0, StretchFac - 0.1);
		}

		Color beamCol = 0xFFFF1111;
		if (StretchFac > 0.75)
		{
			beamCol = 0xFF22FF22;
		}
		else if (StretchFac > 0.50)
		{
			beamCol = 0xFFFFFF22;
		}
		else if (StretchFac > 0.25)
		{
			beamCol = 0xFFFFAA22;
		}

		for (double i = 0; i < 64 * StretchFac; i += 0.5)
		{
			double lengthFac = 1.0 - min(1.0, (i ** 1.05) / (64 * StretchFac));
			A_SpawnParticle(beamCol, SPF_FULLBRIGHT | SPF_RELATIVE, 1, 5 * lengthFac + 10 * min(1.0, StretchFac * 1.5) * sin((i / (32.0 * StretchFac)) * 85), 0, 8 + i, 0, 34, startalphaf: 0.30 * min(1.0, StretchFac * 2) * lengthFac);
		}

		// AceCore.DrawCollisionBox(self, 0xFF0000, 1, 1);
	}

	override bool Used(Actor user)
	{
		if (!Deployed || Distance3D(user) > 50)
		{
			return false;
		}
		else if (TimesUsed < 3)
		{
			TimesUsed++;
			return false;
		}
		
		A_StartSound("doors/dr1_clos", pitch: 1.1);
		SetStateLabel('UnDeploy');
		return true;
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (other == master)
		{
			return false;
		}

		return Super.CanCollideWith(other, passive);
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (Health > 0)
		{
			Health -= ApplyDamageFactor(mod, damage);
			if (Health <= 0)
			{
				SetStateLabel('Boom');
			}
		}
		return 0;
	}

	bool Deployed;
	int TimesUsed;
	Array<BarricadeBarricade> CenterSegments;
	Array<BarricadeBarricade> LeftSideSegments;
	Array<BarricadeBarricade> RightSideSegments;
	private int Offset;
	private double StretchFac;

	Default
	{
		Radius 30;
		Height 20;
		Mass 20000;
		Friction 0.95;
		Renderstyle "Normal";
		DamageFactor "Hot", 0.10;
		DamageFactor "Balefire", 0.05;
		DamageFactor "Burning", 0.10;
		DamageFactor "Electrical", 0.05;
		DamageFactor "Holy", 0;
		DamageFactor "Bashing", 0.25;
		Gravity 1.4;
		Friction 0.5;
		+SOLID
		+FRIENDLY
		+GHOST
	}

	States
	{
		Spawn:
			DPBR A 1
			{
				if (vel.length() < 0.4)
				{
					A_Stop();
					SetStateLabel('Deploy');
					A_StartSound("doors/dr1_open", pitch: 1.1);
					bSOLID = false;
					for (double i = -Radius; i <= Radius; i += 6)
					{
						Actor a; bool success;
						[success, a] = A_SpawnItemEx("BarricadeBarricade", 0, i, flags: SXF_SETMASTER);
						let br = BarricadeBarricade(a);
						br.A_SetSize(-1, Height);
						br.Core = true;
						br.Offset = i;
						br.A_GiveInventory('ImmunityToFire');
						CenterSegments.Push(br);
					}
					return;
				}
			}
			Loop;
		Deploy:
			DPBR A 3;
			DPBR ABCDE 2
			{
				for (int i = 0; i < CenterSegments.Size(); ++i)
				{
					CenterSegments[i].A_SetSize(-1, CenterSegments[i].Height + 4);
				}
				A_SetSize(-1, Height + 4);
			}
			DPBR E 3;
			DPBR FGHIJ 2
			{
				Actor a; bool success; BarricadeBarricade br;

					double off = (Radius + 6 + Offset);

					[success, a] = A_SpawnItemEx("BarricadeBarricade", 0, off, 0, flags: SXF_SETMASTER);
					br = BarricadeBarricade(a);
					br.A_SetSize(-1, Height);
					br.Offset = off;
					br.A_GiveInventory('ImmunityToFire');
					LeftSideSegments.Push(br);

					[success, a] = A_SpawnItemEx("BarricadeBarricade", 0, -off, 0, flags: SXF_SETMASTER);
					br = BarricadeBarricade(a);
					br.A_SetSize(-1, Height);
					br.Offset = -off;
					br.A_GiveInventory('ImmunityToFire');
					RightSideSegments.Push(br);

					Offset += 6;
			}
			DPBR J 3;
			DPBR KLMNO 2
			{
				for (int i = 0; i < LeftSideSegments.Size(); ++i)
				{
					LeftSideSegments[i].A_SetSize(-1, LeftSideSegments[i].Height + 3.5);
				}
				for (int i = 0; i < RightSideSegments.Size(); ++i)
				{
					RightSideSegments[i].A_SetSize(-1, RightSideSegments[i].Height + 3.5);
				}
			}
		Idle:
			DPBR # -1
			{
				Deployed = true;
			}
			Stop;

		UnDeploy:
			DPBR ONMLK 2
			{
				Deployed = false;
				for (int i = 0; i < LeftSideSegments.Size(); ++i)
				{
					LeftSideSegments[i].A_SetSize(-1, LeftSideSegments[i].Height - 3.5);
				}
				for (int i = 0; i < RightSideSegments.Size(); ++i)
				{
					RightSideSegments[i].A_SetSize(-1, RightSideSegments[i].Height - 3.5);
				}
			}
			DPBR K 2;
			DPBR JIHGF 2
			{
				for (int i = 0; i < 2; ++i)
				{
					int lsize = LeftSideSegments.Size();
					if (lsize > 0)
					{
						LeftSideSegments[lsize - 1].Destroy();
						LeftSideSegments.Pop();
					}
					int rsize = RightSideSegments.Size();
					if (rsize > 0)
					{
						RightSideSegments[rsize - 1].Destroy();
						RightSideSegments.Pop();
					}
				}
			}
			DPBR EDCBA 2
			{
				for (int i = 0; i < CenterSegments.Size(); ++i)
				{
					CenterSegments[i].A_SetSize(-1, CenterSegments[i].Height - 4);
				}
				A_SetSize(-1, Height - 4);
			}
			DPBR A 0
			{
				Actor a = Spawn('HDDeployableBarricade', pos);
				a.Health = Health;
			}
			Stop;
		Boom:
			TNT1 A 1
			{
				for (int i = 0; i < CenterSegments.Size(); ++i)
				{
					CenterSegments[i].Destroy();
				}
				for (int i = 0; i < LeftSideSegments.Size(); ++i)
				{
					LeftSideSegments[i].Destroy();
				}
				for (int i = 0; i < RightSideSegments.Size(); ++i)
				{
					RightSideSegments[i].Destroy();
				}

				A_StartSound("weapons/bigcrack", CHAN_AUTO);
				A_StartSound("world/explode", CHAN_VOICE);
				A_SpawnChunks("HDExplosion", 6, 0, 1);
				A_SpawnItemEx("HDExplosion");
				DistantQuaker.Quake(self, 2, 35, 256, 10);
				A_HDBlast(pushradius: 256, pushamount: 128, fullpushradius: 96, fragradius: 256, fragtype: "HDB_Frag");
			}
			Stop;
	}
}

// [Ace] No, this isn't a typo.
class BarricadeBarricade : HDActor
{
	override void Tick()
	{
		Super.Tick();

		let br = HDDeployedBarricade(master);
		if (!br)
		{
			Destroy();
			return;
		}

		// [Ace] Nuke the thing if it gets automatically moved by the engine.
		if (floorz - 8 > br.floorz)
		{
			if (Core && br.Deployed)
			{
				br.Deployed = false;
				br.SetStateLabel('UnDeploy');
				return;
			}

			int leftIndex = br.LeftSideSegments.Find(self);
			if (leftIndex != br.LeftSideSegments.Size())
			{
				br.LeftSideSegments.Delete(leftIndex);
				Destroy();
				return;
			}

			int rightIndex = br.RightSideSegments.Find(self);
			if (rightIndex != br.RightSideSegments.Size())
			{
				br.RightSideSegments.Delete(rightIndex);
				Destroy();
				return;
			}
		}

		Warp(master, 0, Offset, 0, flags: WARPF_NOCHECKPOSITION);
		// if (!IsFrozen())
		// {
		// 	AceCore.DrawCollisionBox(self, 0xFF0000, 1, 1);
		// }
	}

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		master.DamageMobj(inflictor, source, damage, mod, flags, angle);
		return 0;
	}

	override double BulletResistance(double hitangle)
	{
		return Super.BulletResistance(hitangle) * 35;
	}

	override bool Used(Actor user)
	{
		master.Used(user);
		return true;
	}

	bool Core;
	double Offset;

	Default
	{
		Radius 3.5;
		Height 10;
		Mass 10000;
		+SOLID
		+SHOOTABLE
		+NODAMAGE
		+NOBLOOD
		+FORCEYBILLBOARD
		+DONTTHRUST
		+WALLSPRITE
		+NOFRICTIONBOUNCE
		+NOLIFTDROP
		+FRIENDLY
		+GHOST
	}

	States
	{
		Spawn:
			TNT1 A -1;
			STop;
	}
}