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

#include "zscript/accensus/SpawnHandler.zs"

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
