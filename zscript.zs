version "4.10"

const HDLD_BLACKHAWK          = "bhk";
const HDLD_BLACKHAWKBOLT      = "bbr";
const HDLD_BLACKHAWKBOLT_E    = "bbe";
const HDLD_BLACKHAWKBOLT_I    = "bbi";
const HDLD_BLACKHAWKBOLT_N    = "bbn";
const HDLD_BLACKJACK          = "bjk";
const HDLD_BLACKJACKMAG_355   = "bm3";
const HDLD_BLACKJACKMAG_SHELL = "bms";
const HDLD_GUNGNIR            = "gnr";
const HDLD_HAMMERHEAD         = "hhd";
const HDLD_JACKDAW            = "jdw";
const HDLD_MAJESTIC           = "maj";
const HDLD_MAJESTICMAG        = "mjm";
const HDLD_REDLINE            = "rdl";
const HDLD_SCORPION           = "scr";
const HDLD_VIPER              = "vpr";
const HDLD_VIPERMAG           = "vpm";
const HDLD_WYVERN             = "wyv";

const HDLD_DSD                = "dsd";

// Core
#include "zscript/accensus/SpawnHandler.zs"

// Weapons
#include "zscript/accensus/weapons/Blackhawk/blackhawk.zs"

// Blackhawk Bolt Import Order matters [UZ]
#include "zscript/accensus/weapons/Blackhawk/bolts/regularBolts.zs"
#include "zscript/accensus/weapons/Blackhawk/bolts/incendiaryBolts.zs"
#include "zscript/accensus/weapons/Blackhawk/bolts/electricBolts.zs"
#include "zscript/accensus/weapons/Blackhawk/bolts/nuclearBolts.zs"

#include "zscript/accensus/weapons/Blackjack/blackjack.zs"

#include "zscript/accensus/weapons/Gungnir/gungnir.zs"

#include "zscript/accensus/weapons/Hammerhead/hammerhead.zs"

#include "zscript/accensus/weapons/Jackdaw/jackdaw.zs"

#include "zscript/accensus/weapons/Majestic/majestic.zs"

#include "zscript/accensus/weapons/Redline/redline.zs"

#include "zscript/accensus/weapons/Scorpion/scorpion.zs"

#include "zscript/accensus/weapons/Viper/viper.zs"

#include "zscript/accensus/weapons/Wyvern/wyvern.zs"

// Items
#include "zscript/accensus/items/Booster Jets.zs"
#include "zscript/accensus/items/Deployable Barricade.zs"
#include "zscript/accensus/items/Dimensional Storage Device.zs"
#include "zscript/accensus/items/Field Assembly Kit.zs"
#include "zscript/accensus/items/Ladder Launcher.zs"
#include "zscript/accensus/items/Magazine Reloader.zs"
#include "zscript/accensus/items/Personal Shield Generator.zs"
#include "zscript/accensus/items/Rearview Mirror.zs"
#include "zscript/accensus/items/Roomba.zs"
#include "zscript/accensus/items/Secret Finder.zs"
#include "zscript/accensus/items/Soul Cube.zs"
#include "zscript/accensus/items/Super Stimpack.zs"
#include "zscript/accensus/items/Supply Beacon.zs"
#include "zscript/accensus/items/Teleporter.zs"
#include "zscript/accensus/items/Weapon Crate.zs"
#include "zscript/accensus/items/Hacked Reloader.zs"
#include "zscript/accensus/items/Armor Patch Kit.zs"

// Field Assembly Kit shenanagins
#include "zscript/accensus/items/FAK Upgrades/FAK Thinkers.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Handler.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Vanilla.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK AceCorp.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK HexaDoken.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK HoagieTech.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Icarus.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Potetobloke.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Mohl.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Peppergrinder.zs"
#include "zscript/accensus/items/FAK Upgrades/FAK Radtech.zs"