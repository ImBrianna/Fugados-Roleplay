/*
+-----------------------------------------------------------------------+
¦                        JunkBuster Anti-Cheat                          ¦
¦                                  by                                   ¦
¦                           Double-O-Seven                              ¦
¦                                                                       ¦
¦ This Anti-Cheat script is made by me, Double-O-Seven. The famous      ¦
¦ Anti-Cheat system "PunkBuster" inspired me the script a new           ¦
¦ Anti-Cheat script for SA:MP. It contains many functions against       ¦
¦ normal cheats and cheats from specific cheat tools. It's against      ¦
¦ (command) spam, too.                    								¦
¦ If JunkBuster kicks/bans too much innocent players, disable the codes ¦
¦ which kick/ban too many innocent players. You can easily configurate  ¦
¦ JunkBuster in the file "JunkBuster.cfg" in the folder "JunkBuster"    ¦
¦ in the folder "scriptfiles". Use "/jbcfg" ingame if you are           ¦
¦ (rcon)admin to update the configuration.                              ¦
¦ "ForbiddenWeapons.cfg" to forbidden weapons.                          ¦
¦                                                                       ¦
¦ The main script of JunkBuster is no longer an include!     			¦
¦ It's a filterscript now! Use JunkBuster.inc for all your        		¦
¦ other scripts or something may not work as it should.                	¦
¦                                                                       ¦
¦ This script has been made by Double-O-Seven!                          ¦
¦                                                                       ¦
¦ You are NOT allowed to:  												¦
¦ - Remove this text                                                    ¦
¦ - Rename JunkBuster! Never!                                 			¦
¦ - Re-release this script                                              ¦
¦ - Say it's your own script                                            ¦
¦ - Remove the "JunkBuster:" tag from client messages!           		¦
¦                                                                       ¦
¦ But you are allowed to add more functions and use it on your server.  ¦
¦                                                                       ¦
¦ Thanks to ~Cueball~ for his zone script, ZeeX for ZCMD				¦
¦ and Y_Less for sscanf function. I also thank dUDALUS for allowing 	¦
¦ me to cheat on his server.                                            ¦
¦                                                                       ¦
¦ (If I write SS anywhere, it means "Server Side", not "Schutzstaffel". ¦
¦ If I write CS anywhere, it means "Client Side", not "Counter Strike".)¦
+-----------------------------------------------------------------------+
*/

//==============================================================================

/*

Changelog Update 11:
	- Temp Ban functions fixed
	- Synchronization code rewritten
	- SplitIp functino fixed
	- When Anti-Moneyhack is enabled, JB will automatically disable stunt bonuses
	- Anti-joypad code rewritten (it actually works now)
	- When a player enters a vehicle, vehicle components which shouldn't be on the vehicle will get removed
	- Fixed a bug anti-tuning-hack: Players could get kicked when vehicle got destroyed
	- Added faster airbrake detection. You can choose between the old detection and the new one. The new one is enabled by default. Server restart is required to change detection mode.
	- It's now fully compatible with LuxAdmin (use #include <JunkBuster_Slim> in LuxAdmin)

Changelog Update 10:
	- Double-O-Bits instead of y_bit
	- Anti-joypad
	- Advanced speedhack detection with individual speed limit for each vehicle
	- Anti-armed vehicles
	- Improved anti-moneyhack
	- Command /jbreports for all admins: Command lists the newest JB reports
	- Memory usage optimized
	- SetJBVar, GetJBVar functions
	- Warnings for drive-byers
	- Unified prefix syntax (CALLBACK:, PRIVATE:, PUBLIC:)
	- Optimized code for IP-bans, blacklist, whitelist and tempbans
	- If an admin accidently types the rcon-password into the global chat, JunkBuster blocks it
	- Blacklist functions etc are now available for other scripts
	- Dialog for hack codes (If you don't understand you will after reading the dialog)
	- Colored variable list dialog (green = on, red = off)
	- AdvertisementCheck recoded
	- Detection of vehicle-repair hack
	- Detection of tuning hack
	- Detect if a players cheats or gets a weapon for free in Ammu-Nation
	- Made hooking easier in JunkBuster.inc. Not important for you, just for me.
	- Syncing of health/armour shops improved. Health now gets only sync in restaurants and armours only in Ammu-Nation instead of both locations.
	- Weapons also only get synced in Ammu-Nation instead of all shops. Also, only buyable weapons get synced clientside.
	- GodModeCheck rewritten. Should now work better.
	- Anti-AFK? Or was this already in update 9..?
	- Airbrake now spelled correctly. Also allowed me to give the variable AIRBRAKE a new function as lower speed limit for airbrake without causing trouble on already existing servers which would have speed limit of 1... w/e
	- New detection of vehicle spawning (the old method did absolutely nothing in SA-MP 0.3)
	- One of the the GlobalUpdate functions removed.
	- JunkBuster can now take action when a player has too many warnings in total
	- Hooked SetPlayerPosFindZ
	- Things I forgot?
	
*/

/*
A new ban system using SQLite. It's much slower than the old ban system and you can't use JB's rangeban system, which
has the advantage of having a whitelist the make exceptions for some players.
Uncomment the following line to use a database for banning players.
(Tempbans, static IP bans (only with an associated name) and blacklist supported. Whitelist is kinda also supported...)
At the moment I can't see any advantage in using the database except for the unlimitted amount of people you can ban with it.
The file system is limitted by MAX_JB_BANS. Database isn't. Oh, before I forget, the database does also not work correctly
with some names with special symbols.
>> It's just experimental. (However, you could make it work properly if you have to knowledge.)
*/

#if !defined I_AM_NO_RETARD

#endif

//#define USE_DATABASE

#define FILTERSCRIPT

#include <a_samp>

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
#endif
// Change this for more efficiency.
#define MAX_PLAYERS             (200)

#define PACK_CONTENT            (true)

#include <Double-O-Files_2>
#include <Double-O-Bits>
#include <foreach>
#include <zcmd>

#if defined USE_DATABASE
	#include <JBDB>
#endif

//==============================================================================

// Just for me.
//#define DEV

#if defined DEV
	#define BanEx(%0,%1) \
	    Kick (%0)
#endif

//==============================================================================

#define CONFIG_FILE 			"JunkBuster/JunkBuster.cfg"
#define JB_CHROME_FILE          "JunkBuster/JunkBusterChrome.log"
#define BAD_WORDS_FILE 			"JunkBuster/BadWords.cfg"
#define FORBIDDEN_WEAPONS_FILE 	"JunkBuster/ForbiddenWeapons.cfg"
#define JB_LOG_FILE 			"JunkBuster/JunkBuster.log"
#define BLACKLIST_FILE 			"JunkBuster/Blacklist.txt"
#define WHITELIST_FILE 			"JunkBuster/Whitelist.txt"
#define IP_BAN_FILE 			"JunkBuster/IpBans.txt"
#define TEMP_BAN_FILE 			"JunkBuster/TempBans.txt"
#define BAD_RCON_LOGIN_FILE 	"JunkBuster/BadRconLogin.txt"

#define JB_VERSION              "11"

#define MAX_JB_VARIABLES 		(60)
#define MAX_BAD_WORDS 			(100)
#define MAX_FORBIDDEN_WEAPONS 	(20)
#define MAX_PING_CHECKS 		(3)
#define MAX_WEAPONS 			(47)
#define MAX_WEAPON_SLOTS		(13)
#define MAX_CHECKS 				(3)
#define MAX_JB_BANS 			(250)
#define MAX_FPS_INDEX 			(3)
#define MAX_CLASSES			 	(300)
#define MAX_REPORTS             (40)
#define MAX_COMPONENT_SLOTS     (14)
#define GMC_TIMEOUT     		(5000)
#define MAX_SYNC_TYPES          (5)

#define WEAPON_HACK 			(0)
#define MONEY_HACK 				(1)
#define JETPACK 				(2)
#define HEALTH_HACK 			(3)
#define ARMOUR_HACK 			(4)
#define DRIVE_BY 				(5)
#define SPAM 					(6)
#define COMMAND_SPAM 			(7)
#define BAD_WORDS 				(8)
#define CAR_JACK_HACK 			(9)
#define TELEPORT_HACK 			(10)
#define MAX_PING 				(11)
#define SPECTATE_HACK 			(12)
#define BLACKLIST 				(13)
#define IP_BANS 				(14)
#define TEMP_BANS 				(15)
#define SPAWNKILL 				(16)
#define CAPS_LOCK 				(17)
#define SPEED_3D 				(18)
#define MAX_SPEED 				(19)
#define ADMIN_IMMUNITY 			(20)
#define ADVERTISEMENT 			(21)
#define FREEZE_UPDATE 			(22)
#define SPAWN_TIME 				(23)
#define CHECKPOINT_TELEPORT 	(24)
#define AIRBRAKE 				(25)
#define TANK_MODE 				(26)
#define WARN_PLAYERS 			(27)
#define SINGLEPLAYER_CHEATS 	(28)
#define MIN_FPS 				(29)
#define DISABLE_BAD_WEAPONS 	(30)
#define CBUG 					(31)
#define ANTI_BUG_KILL		  	(32)
#define NO_RELOAD			  	(33)
#define NO_RELOAD_SAWNOFF	  	(34)
#define ACTIVE_GMC			 	(35)
#define GMC_BAN				 	(36)
#define SS_HEALTH			  	(37)
#define CHECK_VM_POS			(38)
#define QUICK_TURN			 	(39)
#define VEHICLE_TELEPORT        (40)
#define WALLRIDE                (41)
#define DISPLAY_TEXTDRAW        (42)
#define AFK                     (43)
#define PICKUP_TELEPORT         (44)
#define FLY_HACK                (45)
#define JB_CHROME               (46)
#define CHECK_WALK_ANIMS        (47)
#define REPORT_MONEY_HACK      	(48)
#define SPEEDHACK_ADVANCED      (49)
#define JOYPAD                  (50)
#define ARMED_VEHICLES          (51)
#define VEHICLE_REPAIR          (52)
#define TUNING_HACK             (53)
#define PAY_FOR_GUNS            (54)
#define SPAWN_VEHICLES          (55)
#define MAX_TOTAL_WARNINGS      (56)
#define TOO_MANY_WARNS_ACTION   (57)
#define AIRBRAKE_DETECTION      (58)
#define SPEEDHACK_DETECTION     (59)

#define JB_RED 					(0xFF0000FF)
#define JB_GREEN 				(0x00FF00FF)
#define JB_GREEN_BLUE 			(0x00D799FF)

#define DIALOG_HACKCODES        (28351)
#define DIALOG_REPORTS 			(28352)
#define DIALOG_CMDS 			(28353)
#define DIALOG_CFG 				(28354)
#define DIALOG_VARLIST 			(28355)
#define DIALOG_SETVAR 			(28356)

#define SYNC_TYPE_POS           (0)
#define SYNC_TYPE_HEALTH        (1)
#define SYNC_TYPE_ARMOUR        (2)
#define SYNC_TYPE_WEAPONS       (3)
#define SYNC_TYPE_VEHICLE       (4)

#define PICKUP_TYPE_NONE		(0)
#define PICKUP_TYPE_WEAPON	 	(1)
#define PICKUP_TYPE_HEALTH	 	(2)
#define PICKUP_TYPE_ARMOUR	 	(3)

new stock
	FALSE = false,
	TRUE = true;

#define JB_SendFormattedMessage(%0,%1,%2,%3) 	do{new _string[128]; format(_string,sizeof(_string),%2,%3); SendClientMessage(%0,%1,_string);} while(FALSE)
#define JB_SendFormattedMessageToAll(%0,%1,%2) 	do{new _string[128]; format(_string,sizeof(_string),%1,%2); SendClientMessageToAll(%0,_string);} while(FALSE)
#define JB_LogEx(%0,%1) 						do{new _string[256]; format(_string,sizeof(_string),%0,%1); JB_Log(_string);} while(FALSE)
#define JB_Speed(%0,%1,%2,%3,%4) 				floatround(floatsqroot((%4)?(%0*%0+%1*%1+%2*%2):(%0*%0+%1*%1))*%3*1.6)

#define PUBLIC:%0(%1) 	forward %0(%1); \
						public %0(%1)
						
#define PRIVATE:%0(%1)  static stock %0(%1)

#define CALLBACK       	PUBLIC

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

//Y_Less:
#if !defined abs
	#define abs(%1) \
		(((%1) < 0) ? (-(%1)) : ((%1)))
#endif

#if !defined isnull
	#define isnull(%1) \
		((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define JB:: \
	JB_
	
#define JBGMC:: \
	JBGMC_
	
#pragma dynamic 8092

//==============================================================================

#if !defined GetPlayerDistanceFromPoint

	// Download here: http://forum.sa-mp.com/showthread.php?t=271586
#endif

native gpci (playerid, serial [], len);

//==============================================================================

enum JB::pInfo
{
	JB::pName[MAX_PLAYER_NAME],
	JB::pIp [16],
	JB::pMoney,
	Float: JB::pHealth,
	Float: JB::pArmour,
	JB::pLastMessage [128],
	JB::pMessageRepeated,
	JB::pMessages,
	JB::pCommands,
	JB::pMuted,
	JB::pPing [MAX_PING_CHECKS],
	JB::pPingCheckProgress,
	JB::pVehicleEntered,
	JB::pSpawnKillProtected,
	JB::pAirbraking,
	Float: JB::pOldAirbrakePos [3],
	JB::pLastAirbrakeSpeed,
	JB::pLastAirbrakeCheck,
	JB::pWallriding,
	JB::pLastCheck,
	JB::pLastDrunkLevel,
	JB::pFPS [MAX_FPS_INDEX],
	JB::pFPSIndex,
	JB::pFired,
	Float: JB::pSetPos [3],
	Float: JB::pCurrentPos [3],
	Float: JB::pOnFootPos [3],
	Float: JB::pAFKPos [3],
	Float: JB::pLastKeyPressed,
	BitArray: JB::pWeaponForbidden <MAX_WEAPONS>,
	JB::pAmmoUsed [MAX_WEAPONS],
	JB::pOldAmmo [MAX_WEAPONS],
	JB::pLastWeaponUsed [MAX_WEAPONS],
	JB::pOldWeapon,
	JB::pSawnOffAmmo,
	JB::pLastSawnOffShot,
	JB::pLastUpdate,
	JB::pVendingMachineUsed,
	JB::pKillingSpree,
	JB::pLastGMC,
	Float: JB::pVelocity [3],
	JB::pOldSpeed,
	Float: JB::pOldAngle,
	JB::pCurrentState,
	JB::pLastVehicle,
	JB::pFreezeTime,
	Float: JB::pVehicleHealth,
	JB::pLastMoneyChange,
	JB::pLastLostMoney,
	JB::pLastBoughtWeapon [2],
	JB::pBuyingGuns
};

enum JB::sInfo
{
	JB::sSyncTime,
	JB::sLastSyncUpdate
};

static
	JB::PlayerInfo [MAX_PLAYERS][JB::pInfo],
	JB::PlayerWeaponAmmo [MAX_PLAYERS][MAX_WEAPONS],
	JB::PlayerWeapons [MAX_PLAYERS][MAX_WEAPON_SLOTS char],
	JB::SyncInfo [MAX_PLAYERS][MAX_SYNC_TYPES][JB::sInfo],
	BitArray: JB::Freezed <MAX_PLAYERS>,
	BitArray: JB::KickBan <MAX_PLAYERS>,
	BitArray: JB::FullyConnected <MAX_PLAYERS>,
	BitArray: JB::AntiBugKilled <MAX_PLAYERS>,
	BitArray: JB::Spectating <MAX_PLAYERS>,
	BitArray: JB::BuyingInAmmuNation <MAX_PLAYERS>,
	BitArray: JB::GunBought <MAX_PLAYERS>,
	JB::PlayerClassWeapons [MAX_CLASSES][3][2],
	JB::SpawnWeapons [MAX_PLAYERS][3][2],
	bool: JB::PlayerPedAnims = false,
	JB::Homepage [32],
	Text: JB::KickBanTitle = Text: INVALID_TEXT_DRAW,
	Text: JB::KickBanInfo = Text: INVALID_TEXT_DRAW,
	Text: JB::KickBanHelp = Text: INVALID_TEXT_DRAW,
	JB::PickupType [MAX_PICKUPS char] = {PICKUP_TYPE_NONE, ...},
	JB::PickupVar [MAX_PICKUPS][2],
	Float: JB::PickupPos [MAX_PICKUPS][3],
	BitArray: JB::StaticPickup <MAX_PICKUPS>, // Simulate a static pickup...
	JB::PickupList [MAX_PICKUPS],
	JB::PickupCount,
	JB::Reports [MAX_REPORTS][128 char],
	JB::ReportIndex,
	JB::ReportCount,
	JB::Warnings [MAX_PLAYERS][MAX_JB_VARIABLES char],
	JB::Variables [MAX_JB_VARIABLES],
	BadWords [MAX_BAD_WORDS][32],
	BadWordsCount,
	ForbiddenWeapons [MAX_FORBIDDEN_WEAPONS char],
	ForbiddenWeaponsCount,
	JB::VehicleComponents [MAX_VEHICLES][MAX_COMPONENT_SLOTS char], // Save memory by just adding 999 to the byte value when accessing.
	Float: JBGMC::OldPos [MAX_PLAYERS][3],
	Float: JBGMC::OldHealth [MAX_PLAYERS],
	Float: JBGMC::NewHealth [MAX_PLAYERS],
	Float: JBGMC::OldArmour [MAX_PLAYERS],
	JBGMC::VehicleID [MAX_PLAYERS],
	JBGMC::Seat [MAX_PLAYERS char],
	JBGMC::Progress [MAX_PLAYERS char],
	JBGMC::TimeoutTime [MAX_PLAYERS],
	Float: JB::VehiclePos [MAX_VEHICLES][3],
	JB::AirbrakeDetection;
	
#if !defined USE_DATABASE

	enum tbInfo
	{
		tbName [MAX_PLAYER_NAME],
		tbIp [16],
		tbTime
	}

	static
		TempBanInfo [MAX_JB_BANS][tbInfo],
		TempBanCount,
		Blacklist [MAX_JB_BANS][MAX_PLAYER_NAME char],
		BlacklistCount,
		Whitelist [MAX_JB_BANS][MAX_PLAYER_NAME char],
		WhitelistCount,
		IpBans [MAX_JB_BANS],
		IpBanCount;

#endif

static const JB::DefaultVariables [MAX_JB_VARIABLES] =
{
	true, //WeaponHack
	true, //MoneyHack
	true, //Jetpack
	true, //HealthHack
	true, //ArmourHack
	3, //DriveBy
	true, //Spam
	true, //CommandSpam
	true, //BadWords
	true, //CarJackHack
	true, //TeleportHack
	500, //MaxPing
	true, //SpectateHack
	true, //Blacklist
	true, //IpBans
	true, //TempBans
	3, //SpawnKill
	true, //CapsLock
	false, //3DSpeed
	230, //MaxSpeed
	true, //AdminImmunity
	false, //Advertisement
	false, //FreezeUpdate
	10, //SpawnTime
	true, //CheckpointTeleport
	150, //Airbrake
	true, //TankMode
	false, //WarnPlayers
	true, //SingleplayerCheats
	13, //MinFPS
	true, //DisableBadWeapons
	16, //CBug
	true, //AntiBugKill
	20, //NoReload
	4, //NoReloadForSawnOff
	2, //ActiveGMC
	false, //GMCBan
	true, //ServerSideHealth
	false, //CheckVMPos
	true,//QuickTurn
	true, //VehicleTeleport
	170, //Wallride
	true, //DisplayTextDraw
	5, //AFK
	true, // PickupTeleport
	40, // FlyHack
	true, // JunkBusterChrome
	true, // CheckWalkAnims
	true, // ReportMoneyHack
	20, // SpeedhackAdvanced
	0, // Joypad
	0, // ArmedVehicles
	2, // VehicleRepair
	true, // TuningHack
	0, // PayForGuns
	2, // SpawnVehicles
	15, // MaxTotalWarnings
	1, // TooManyWarningsAction
	1, // AirbrakeDetection
	0 // SpeedhackDetection
};

static const JB::VariableNames [MAX_JB_VARIABLES][] =
{
	"WeaponHack",
	"MoneyHack",
	"Jetpack",
	"HealthHack",
	"ArmourHack",
	"DriveBy",
	"Spam",
	"CommandSpam",
	"BadWords",
	"CarJackHack",
	"TeleportHack",
	"MaxPing",
	"SpectateHack",
	"Blacklist",
	"IpBans",
	"TempBans",
	"SpawnKill",
	"CapsLock",
	"3DSpeed",
	"MaxSpeed",
	"AdminImmunity",
	"Advertisement",
	"FreezeUpdate",
	"SpawnTime",
	"CheckpointTeleport",
	"Airbrake",
	"TankMode",
	"WarnPlayers",
	"SingleplayerCheats",
	"MinFPS",
	"DisableBadWeapons",
	"CBug",
	"AntiBugKill",
	"NoReload",
	"NoReloadForSawnOff",
	"ActiveGMC",
	"GMCBan",
	"ServerSideHealth",
	"CheckVMPos",
	"QuickTurn",
	"VehicleTeleport",
	"Wallride",
	"DisplayTextDraw",
	"AFK",
	"PickupTeleport",
	"FlyHack",
	"JunkBusterChrome",
	"CheckWalkAnims",
	"ReportMoneyHack",
	"SpeedhackAdvanced",
	"Joypad",
	"ArmedVehicles",
	"VehicleRepair",
	"TuningHack",
	"PayForGuns",
	"SpawnVehicles",
	"MaxTotalWarnings",
	"TooManyWarningsAction",
	"AirbrakeDetection",
	"SpeedhackDetection"
};

static const JB::VarDescription [MAX_JB_VARIABLES][] =
{
	!"If enabled JunkBuster will ban for forbidden weapons.\nSet to 0 to disable, set to 1 to enable.", //WeaponHack
	!"Enable to manage to players money serverside. Cheating money will be impossible.\nBut gambling for money or stunt bonus, too.\nSet to 0 to disable, set to 1 to enable.", //MoneyHack
	!"If enabled JunkBuster will ban for jetpacks.", //Jetpack
	!"If enabled JunkBuster will ban players who's health value is higher than 100.\nDO NOT CONFUSE THIS FUNCTION WITH SERVER-SIDE HEALTH FUNCTION!\nSet to 0 to disable, set to 1 to enable.", //HealthHack
	!"If enabled JunkBuster will ban players who's armour value is higher than 100.\nDO NOT CONFUSE THIS FUNCTION WITH SERVER-SIDE ARMOUR FUNCTION!\nSet to 0 to disable, set to 1 to enable.", //ArmourHack
	!"Enable to prevent drive-by.\nSet to 0 to disable, set to 1 to and drive-byers will loose health,\nset to 2 and drive-byers will die when the kill someone,\nset to 3 and weapons will be disabled for drivers,\nset to 4 and weapons in cars will also get disabled for passengers.", //DriveBy
	!"Will mute, kick or ban for chat spam.\nSet to 0 to disable, set to 1 to enable.", //Spam
	!"Will kick or ban for command spam.\nSet to 0 to disable, set to 1 to enable.", //CommandSpam
	!"Enable to block bad words like 'motherfucker'.\nSet to 0 to disable, set to 1 to enable.", //BadWords
	!"Enable to prevent carjacks performed with hacks.\nSet to 0 to disable, set to 1 to enable.", //CarJackHack
	!"Enable to prevent teleport with cheat tools.\nSet to 0 to disable, set to 1 to enable.", //TeleportHack
	!"Set max ping. JunkBuster will calculate average ping for players and kick them if their ping is higher.\n Set to 0 to disable.\nIf you want to enable it, it's recommended to set higher than 300.", //MaxPing
	!"Enable to ban for illegal spectating with cheat tools.\nSet to 0 to disable, set to 1 to enable.", //SpectateHack
	!"Enable the blacklist. Players with blacklisted names will get banned when connecting.\nSet to 0 to disable, set to 1 to enable.", //Blacklist
	!"Alternative to the native IP ban system.\nYou can make exceptions for some players by adding them to the whitelist.\nIf their IP is banned they still can play if they are on whitelist.\nYou can rangeban players without banning every player with the banned IP.\nSet to 0 to disable, set to 1 to enable.", //IpBans
	!"Enable temporary bans.\nSet to 0 to disable, set to 1 to enable.", //TempBans
	!"Prevent players from spawnkilling other players.\nSet to 0 to disable.\nHigher then 0 will define how many spawnkill warnings a player will get before he will get kicked.", //SpawnKill
	!"Block capslock.\nSet to 0 to disable, set to 1 to enable.", //CapsLock
	!"Calculate speed with 3 dimensions (x, y, z) or only in 2 (x, y) if disabled.\nIt's recommended to disable this function.", //3DSpeed
	!"Set the max speed in KM/H. It's used for anti speedhack.\nThere is also another function called 'SpeedhackAdvanced'. Check it out.\nSet to 0 to disable anti speedhack.\nIt's recommended to set higher than 200.", //MaxSpeed
	!"If enabled admins are immune to everything. If disabled, admins can get muted for spam etc.\nSet to 0 to disable, set to 1 to enable.\nIt's recommended to enable.", //AdminImmunity
	!"Block advertisement.\nSet to 0 to disable, set to 1 to enable.", //Advertisement
	!"JunkBuster will constantly update the players freeze status.\nCheaters can unfreeze themselves but JunkBuster will freeze them again if enabled.", //FreezeUpdate
	!"Defines how long in seconds a player will be spawnkill protected after spawning.\nSet a value of your choice.", //SpawnTime
	!"Enable anti-racecheckpointteleport. Pretty useful for racing servers.\nCan cause problems when setting checkpoint at the players position.\nSet to 0 to disable, set to 1 to enable.", //CheckpointTeleport
	!"Enable to prevent airbrake.\nSet to 0 to disable, set to minimum speed (m/s) of airbrake to enable. (150 recommended)", //Airbrake
	!"Ban players for using tank mode on vehicles.\nSet to 0 to disable, set to 1 to enable.", //TankMode
	!"Warn players when connecting.\nThey will recieve a message that they should not cheat.\nSet to 0 to disable, set to 1 to enable.", //WarnPlayers
	!"Enable to kick players who are trying to use singleplayer cheats.\nSet to 0 to disable, set to 1 to enable.", //SingleplayerCheats
	!"Kick players with a lower FPS than required!\nSet to 0 to disable the FPS check, set higher to set the minimum FPS.", //MinFPS
	!"Enable to disable cameras and goggles.\nBe careful. Players may abuse this function to escape from fights when their health is low.\nSet to 1 to disable, set to 0 to enable.", //DisableBadWeapons
	!"Enable to prevent the usage of the C-Bug.\nSet to 1 to enable, set to 0 to enable.", //CBug
	!"Enable this to kill a player to prevent some bugs caused by lag.\nSet to 1 to enable, set to 0 to enable.", //AntiBugKill
	!"Set to 0 to disable, set to 1 to only enable warnings for admins,\nset higher than 1 to enable auto-kick.", //NoReload
	!"Set to 0 to disable, set high to set the the time, after which player gets banned for not reloading with sawn-off shotgun.", //NoReloadForSawnOff
	!"Set higher then 0 to let JunkBuster kick/ban players with godmode.\nSet to 0 to get warnings only.", //ActiveGMC
	!"Set to 1 to let JunkBuster ban players with godmode,\nset to 0 to let JunkBuster just kick players with godmode.\n(This function has NO effect when ActiveGMC is disabled!)", //GMCBan
	!"Set to 1 to enable server-side health and armour,\nset to 0 the disable it.", //ServerSideHealth
	!"If enabled, JunkBuster checks if player is near any vending machine. Not recommended to enable.\nThis will be checked via animation index anyways.\nSet to 1 to enable, set to 0 to enable.", //CheckVMPos
	!"Set to 1 to block the quick turn hack.\nSet to 0 to ignore it.",//QuickTurn
	!"Prevent cheaters from teleporting from one vehicle into another.", //VehicleTeleport
	!"Set to 0 to disable anti-wallride. You should set it to a value between\n150 and 200 to enable it and work correctly.", //Wallride
	!"Set to 1 to enable. A textdraw with important informations will appear when a player\ngets kicked/banned. Set to 0 to disable.", //DisplayTextDraw
	!"Set to time in minutes after which a player who is AFK should get kicked. Set to 0 to disable.", //AFK
	!"Set to 1 to prevent teleport to pickups. Set to 0 to disable.", // PickupTeleport
	!"Recommended to leave by default value when enabled. Set to 0 to disable.", // FlyHack
	!"Enable JunkBuster Chrome to collect as much user data as possible\nwhen a player gets kicked. This may help you with ban appeals of users.\nSet to 1 to enable, set to 0 to disable.", // JunkBusterChrome
	!"This will check if the player has the correct walking animations. If not, he will immediately get banned.\nHowever, this will only work if you do not use the function UsePlayerPedAnims'.\nHaving this enabled could be very useful for RP(G) servers.\nSet to 1 to enable, set to 0 to disable.", // CheckWalkAnims
	!"If enabled, JunkBuster will report possible money cheaters instead of resetting their money.\nSet to 1 to enable reports, set to 2 to also enable auto-kick, set to 0 to disable.", // ReportMoneyHack
	!"If enabled, JunkBuster will check how much faster the player drives than his vehicle actually can.\nSpeed limit depends on here on  the specific vehicle.\nRecommended to set to 20 to enable, set to 0 to dislable.", //SpeedhackAdvanced
	!"Set to number of warnings after which a player should get kicked for using a joypad/gamepad.\nIt's recommended to set to 2. The first time it will be a warning, the second time a kick.\nSet to 0 to disable.", // Joypad
	!"Set to number of warnings after which a player should get kicked for killing with armed vehicles.\nSet to 0 to disable.", // ArmedVehicles
	!"Set to number of warnings after which a player should get kicked for repairing vehicles with cheats.\nSet to 0 to disable.", // VehicleRepair
	!"Set to 1 to enable, set to 0 to disable.", // TuningHack
	!"If enabled JunkBuster will check if players pay for their guns.\nSet to number of warnings after which a player\nshould get kicked for not paying for guns.\nSet to 0 to disable.", // PayForGuns
	!"If enabled JunkBuster will detect if a player has spawned a vehicle.\nSet to number of warnings after which a player should get kicked, set to 0 to disable.", // SpawnVehicles
	!"If a player gets too many warnings in total, he will kicked/banned (See variable 'TooManyWarningsAction'.", // MaxTotalWarnings
	!"Define what JunkBuster should do when a player has too many warnings:\nMode 1: Kick\nMode 2: Ban\nMode 3: Temporary ban for 1 day\nElse: No action\nSet to mode you would like to have.\nThis function has no effect when variable 'MaxTotalWarnings' is 0.", // TooManyWarningsAction
	!"There's a fast and a slow airbrake detection. Choose which one you'd like to use.\nBe careful: The detection mode cannot be changed while server is running.\nIt's chosen when server starts.\nSet to 0 for slow mode, set to 1 for fast mode.\n", // AirbrakeDetection
	!"There's a very fast and a slower speedhack detection. Choose which one you'd like to use.\nSet to 0 for slower detection mode, set to 1 for faster detection mode.\nBe careful: The fast detection mode uses OnPlayerUpdate (!)\nwhile the slower uses JunkBuster's main timer (1 second interval)." //SpeedhackDetection
};

static const AmmuNationInfo [MAX_WEAPONS][2] =
{
	{0, 0}, //Fist 0
	{0, 0}, //Brass Knuckles 1
	{0, 0}, //Golf Club 2
	{0, 0}, //Nite Stick 3
	{0, 0}, //Knife 4
	{0, 0}, //Baseball Bat 5
	{0, 0}, //Shovel 6
	{0, 0}, //Pool Cue 7
	{0, 0}, //Katana 8
	{0, 0}, //Chainsaw 9
	{0, 0}, //Dildo 10
	{0, 0}, //Vibrator 11
	{0, 0}, //Vibrator 12
	{0, 0}, //Dildo 13
	{0, 0}, //Flowers 14
	{0, 0}, //Cane 15
	{0, 0}, //Grenade 16
	{0, 0}, //Tear Gas 17
	{0, 0}, //Molotov Cocktail 18
	{0, 0}, //19
	{0, 0}, //20
	{0, 0}, //21
	{200, 30}, //9mm 22
	{600, 30}, //Silenced 9mm 23
	{1200, 10}, //Deagle 24
	{600, 15}, //Shotgun 25
	{800, 12}, //Sawnoff 26
	{1000, 10}, //SPAS 12 27
	{500, 60}, //Micro UZI 28
	{2000, 90}, //MP5 29
	{3500, 120}, //AK47 30
	{4500, 90}, //M4 31
	{300, 60}, //Tec9 32
	{0, 0}, //Country Rifle 33
	{0, 0}, //Sniper Rifle 34
	{0, 0}, //Rocket Laucnher 35
	{0, 0}, //Heatseeker 36
	{0, 0}, //Flamethrower 37
	{0, 0}, //Minigun 38
	{0, 0}, //Satchel Charge 39
	{0, 0}, //Detonator40
	{0, 0}, //Spray Can 41
	{0, 0}, //Fire Extinguisher 42
	{0, 0}, //Camera43
	{0, 0}, //Nightvision Goggles 44
	{0, 0}, //Thermal Goggles 45
	{0, 0}//Parachute 46
};

static const DefaultPickupAmmo [MAX_WEAPONS] = //Change these values if they are not appropriate.
{
	1, //Fist 0
	1, //Brass Knuckles 1
	1, //Golf Club 2
	1, //Nite Stick 3
	1, //Knife 4
	1, //Baseball Bat 5
	1, //Shovel 6
	1, //Pool Cue 7
	1, //Katana 8
	1, //Chainsaw 9
	1, //Dildo 10
	1, //Vibrator 11
	1, //Vibrator 12
	1, //Dildo 13
	1, //Flowers 14
	1, //Cane 15
	8, //Grenade 16
	8, //Tear Gas 17
	8, //Molotov Cocktail 18
	0, //19
	0, //20
	0, //21
	30, //9mm 22
	10, //Silenced 9mm 23
	10, //Deagle 24
	15, //Shotgun 25
	10, //Sawnoff 26
	10, //SPAS 12 27
	60, //Micro UZI 28
	60, //MP5 29
	80, //AK47 30
	80, //M4 31
	60, //Tec9 32
	20, //Country Rifle 33
	10, //Sniper Rifle 34
	4, //Rocket Laucnher 35
	3, //Heatseeker 36
	100, //Flamethrower 37
	100, //Minigun 38
	5, //Satchel Charge 39
	1, //Detonator40
	500, //Spray Can 41
	200, //Fire Extinguisher 42
	32, //Camera 43
	1, //Nightvision Goggles 44
	1, //Thermal Goggles 45
	1//Parachute 46
};

static const AmmoAmount [MAX_WEAPONS] =
{
	4999, //Fist 0
	4999, //Brass Knuckles 1
	4999, //Golf Club 2
	4999, //Nite Stick 3
	4999, //Knife 4
	4999, //Baseball Bat 5
	4999, //Shovel 6
	4999, //Pool Cue 7
	4999, //Katana 8
	4999, //Chainsaw 9
	4999, //Dildo 10
	4999, //Vibrator 11
	4999, //Vibrator 12
	4999, //Dildo 13
	4999, //Flowers 14
	4999, //Cane 15
	4999, //Grenade 16
	4999, //Tear Gas 17
	4999, //Molotov Cocktail 18
	0, //19
	0, //20
	0, //21
	34, //9mm 22
	17, //Silenced 9mm 23
	7, //Deagle 24
	4999, //Shotgun 25
	4, //Sawnoff 26
	7, //SPAS 12 27
	100, //Micro UZI 28
	30, //MP5 29
	30, //AK47 30
	30, //M4 31
	100, //Tec9 32
	4999, //Country Rifle 33
	4999, //Sniper Rifle 34
	4999, //Rocket Laucnher 35
	4999, //Heatseeker 36
	100, //Flamethrower 37
	500, //Minigun 38
	4999, //Satchel Charge 39
	4999, //Detonator40
	1000, //Spray Can 41
	500, //Fire Extinguisher 42
	4999, //Camera43
	4999, //Nightvision Goggles 44
	4999, //Thermal Goggles 45
	4999 //Parachute 46
};

static const JB::Planes [] =
{
	417, 425, 447, 460, 469, 476, 487, 488, 497, 511, 512, 513, 519, 520, 548, 553, 563, 577, 592, 593
};

static const Float: AmmuNations [][3] =
{
    {296.5541, -38.5138, 1001.5156}, // Ammu-Nation
	{295.7008, -80.8109, 1001.5156}, // Ammu-Nation
	{290.1963, -109.7721, 1001.5156}, // Ammu-Nation
	{312.2592, -166.1385, 999.6010} // Ammu-Nation
};

static const Float: Restaurants [][3] =
{
	{368.7890, -6.8570, 1001.8516}, // Cluckin' Bell
	{375.5660, -68.2220, 1001.5151}, // Burger Shot
	{374.0000, -119.6410, 1001.4922} // Well Stacked Pizza
};

static const Float: JB::PayNSpray [][3] =
{
	{719.8571,-455.8376,16.0450},
	{-1420.4935,2584.8137,55.5545},
	{-99.8769,1116.7948,19.4567},
	{2065.9587,-1831.2217,13.2568},
	{-2425.9490,1021.5446,50.1055},
	{1975.1755,2162.3755,10.7835},
	{487.7060,-1739.6212,10.8601},
	{1025.0927,-1023.5479,31.8119},
	{2393.4456,1491.5537,10.5616},
	{-1904.5793,283.9675,40.7533}
};

static const Float: JB::VendingMachines [][3] = //Thanks to Rac3r for the coordinates!
{
	{-14.703, 1175.359, 18.953},
	{-253.742, 2597.953, 62.242},
	{201.015, -107.617, 0.898},
	{1277.835, 372.515, 18.953},
	{-862.828, 1536.609, 21.984},
	{2325.976, -1645.132, 14.210},
	{2352.179, -1357.156, 23.773},
	{1928.734, -1772.445, 12.945},
	{1789.210, -1369.265, 15.164},
	{2060.117, -1897.640, 12.929},
	{1729.789, -1943.046, 12.945},
	{1154.726, -1460.890, 15.156},
	{-1350.117, 492.289, 10.585},
	{-2118.968, -423.648, 34.726},
	{-2118.617, -422.414, 34.726},
	{-2097.273, -398.335, 34.726},
	{-2092.085, -490.054, 34.726},
	{-2063.273, -490.054, 34.726},
	{-2005.648, -490.054, 34.726},
	{-2034.460, -490.054, 34.726},
	{-2068.562, -398.335, 34.726},
	{-2039.851, -398.335, 34.726},
	{-2011.140, -398.335, 34.726},
	{-1980.789, 142.664, 27.070},
	{2503.140, 1243.695, 10.218},
	{2319.992, 2532.851, 10.218},
	{1520.148, 1055.265, 10.000},
	{2085.773, 2071.359, 10.453},
	{-2420.179, 985.945, 44.296}, //1302
	{-2420.218, 984.578, 44.296}, //1209
	{-36.148, -57.875, 1003.632}, //1776
	{-17.546, -91.710, 1003.632}, //1776
	{-16.531, -140.296, 1003.632}, //1776
	{-33.875, -186.765, 1003.632} //1776
};

static const JB::ArmedVehicles [] =
{
	425, // Hunter
	430, // Predator
	432, // Rhino
	447, // Sea Sparrow
	464, // RC Baron
	476, // Rustler
	520 // Hydra
};

enum JB::vInfo
{
	JB::vName [32 char],
	JB::vMaxSpeed
}

static const JB::VehicleInfo [][JB::vInfo] =
{
	{!"Landstalker", 140},
	{!"Bravura", 131},
	{!"Buffalo", 166},
	{!"Linerunner", 98},
	{!"Pereniel", 118},
	{!"Sentinel", 146},
	{!"Dumper", 98},
	{!"Firetruck", 132},
	{!"Trashmaster", 89},
	{!"Stretch", 140},
	{!"Manana", 115},
	{!"Infernus", 197},
	{!"Voodoo", 150},
	{!"Pony", 98},
	{!"Mule", 94},
	{!"Cheetah", 171},
	{!"Ambulance", 137},
	{!"Leviathan", 399},
	{!"Moonbeam", 103},
	{!"Esperanto", 133},
	{!"Taxi", 129},
	{!"Washington", 137},
	{!"Bobcat", 124},
	{!"Mr Whoopee", 88},
	{!"BF Injection", 120},
	{!"Hunter", 399},
	{!"Premier", 154},
	{!"Enforcer", 147},
	{!"Securicar", 139},
	{!"Banshee", 179},
	{!"Predator", 399},
	{!"Bus", 116},
	{!"Rhino", 84},
	{!"Barracks", 98},
	{!"Hotknife", 148},
	{!"Trailer", 0},
	{!"Previon", 133},
	{!"Coach", 140},
	{!"Cabbie", 127},
	{!"Stallion", 150},
	{!"Rumpo", 121},
	{!"RC Bandit", 67},
	{!"Romero", 124},
	{!"Packer", 112},
	{!"Monster Truck A", 98},
	{!"Admiral", 146},
	{!"Squalo", 399},
	{!"Seasparrow", 399},
	{!"Pizzaboy", 162},
	{!"Tram", 399},
	{!"Trailer", 399},
	{!"Turismo", 172},
	{!"Speeder", 399},
	{!"Reefer", 399},
	{!"Tropic", 399},
	{!"Flatbed", 140},
	{!"Yankee", 94},
	{!"Caddy", 84},
	{!"Solair", 140},
	{!"Berkley's RC Van", 121},
	{!"Skimmer", 399},
	{!"PCJ-600", 180},
	{!"Faggio", 155},
	{!"Freeway", 180},
	{!"RC Baron", 399},
	{!"RC Raider", 399},
	{!"Glendale", 131},
	{!"Oceanic", 125},
	{!"Sanchez", 164},
	{!"Sparrow", 399},
	{!"Patriot", 139},
	{!"Quad", 98},
	{!"Coastguard", 399},
	{!"Dinghy", 399},
	{!"Hermes", 133},
	{!"Sabre", 154},
	{!"Rustler", 399},
	{!"ZR-350", 166},
	{!"Walton", 105},
	{!"Regina", 124},
	{!"Comet", 164},
	{!"BMX", 86},
	{!"Burrito", 139},
	{!"Camper", 109},
	{!"Marquis", 399},
	{!"Baggage", 88},
	{!"Dozer", 56},
	{!"Maverick", 399},
	{!"News Chopper", 399},
	{!"Rancher", 124},
	{!"FBI Rancher", 139},
	{!"Virgo", 132},
	{!"Greenwood", 125},
	{!"Jetmax", 399},
	{!"Hotring", 191},
	{!"Sandking", 157},
	{!"Blista Compact", 145},
	{!"Police Maverick", 399},
	{!"Boxville", 96},
	{!"Benson", 109},
	{!"Mesa", 125},
	{!"RC Goblin", 399},
	{!"Hotring Racer", 191},
	{!"Hotring Racer", 191},
	{!"Bloodring Banger", 154},
	{!"Rancher", 124},
	{!"Super GT", 159},
	{!"Elegant", 148},
	{!"Journey", 96},
	{!"Bike", 93},
	{!"Mountain Bike", 117},
	{!"Beagle", 399},
	{!"Cropdust", 399},
	{!"Stunt", 399},
	{!"Tanker", 107},
	{!"RoadTrain", 126},
	{!"Nebula", 140},
	{!"Majestic", 140},
	{!"Buccaneer", 146},
	{!"Shamal", 399},
	{!"Hydra", 399},
	{!"FCR-900", 190},
	{!"NRG-500", 200},
	{!"HPV1000", 172},
	{!"Cement Truck", 116},
	{!"Tow Truck", 143},
	{!"Fortune", 140},
	{!"Cadrona", 133},
	{!"FBI Truck", 157},
	{!"Willard", 133},
	{!"Forklift", 54},
	{!"Tractor", 62},
	{!"Combine", 98},
	{!"Feltzer", 148},
	{!"Remington", 150},
	{!"Slamvan", 140},
	{!"Blade", 154},
	{!"Freight", 399},
	{!"Streak", 399},
	{!"Vortex", 89},
	{!"Vincent", 136},
	{!"Bullet", 180},
	{!"Clover", 146},
	{!"Sadler", 134},
	{!"Firetruck", 132},
	{!"Hustler", 131},
	{!"Intruder", 133},
	{!"Primo", 127},
	{!"Cargobob", 399},
	{!"Tampa", 136},
	{!"Sunrise", 128},
	{!"Merit", 140},
	{!"Utility", 108},
	{!"Nevada", 399},
	{!"Yosemite", 128},
	{!"Windsor", 141},
	{!"Monster Truck B", 98},
	{!"Monster Truck C", 98},
	{!"Uranus", 139},
	{!"Jester", 158},
	{!"Sultan", 150},
	{!"Stratum", 137},
	{!"Elegy", 158},
	{!"Raindance", 399},
	{!"RC Tiger", 79},
	{!"Flash", 146},
	{!"Tahoma", 142},
	{!"Savanna", 154},
	{!"Bandito", 130},
	{!"Freight", 399},
	{!"Trailer", 399},
	{!"Kart", 83},
	{!"Mower", 54},
	{!"Duneride", 98},
	{!"Sweeper", 53},
	{!"Broadway", 140},
	{!"Tornado", 140},
	{!"AT-400", 399},
	{!"DFT-30", 116},
	{!"Huntley", 140},
	{!"Stafford", 136},
	{!"BF-400", 170},
	{!"Newsvan", 121},
	{!"Tug", 76},
	{!"Trailer", 399},
	{!"Emperor", 136},
	{!"Wayfarer", 175},
	{!"Euros", 147},
	{!"Hotdog", 96},
	{!"Club", 145},
	{!"Trailer", 399},
	{!"Trailer", 399},
	{!"Andromada", 399},
	{!"Dodo", 399},
	{!"RC Cam", 54},
	{!"Launch", 399},
	{!"Police Car (LSPD)", 156},
	{!"Police Car (SFPD)", 156},
	{!"Police Car (LVPD)", 156},
	{!"Police Ranger", 140},
	{!"Picador", 134},
	{!"S.W.A.T. Van", 98},
	{!"Alpha", 150},
	{!"Phoenix", 152},
	{!"Glendale", 131},
	{!"Sadler", 134},
	{!"Luggage Trailer", 399},
	{!"Luggage Trailer", 399},
	{!"Stair Trailer", 399},
	{!"Boxville", 96},
	{!"Farm Plow", 399},
	{!"Utility Trailer", 399}
};

/*
These coordinates are taken from m0d_n00bheit.
Yes, I'm always testing the newest versions. You can't create a useful
anti-cheat which detects many cheats, if you don't check out the cheat tools.
Fuck those suckers. If someone teleports there, he MUST be a cheater
and JunkBuster will ban him.
*/

static const Float: CheatPositions [][3] =
{
	{-1935.77, 228.79, 34.16}, //Transfender near Wang Cars in Doherty
	{-2707.48, 218.65, 4.93}, //Wheel Archangels in Ocean Flats
	{2645.61, -2029.15, 14.28}, //LowRider Tuning Garage in Willowfield
	{1041.26, -1036.77, 32.48}, //Transfender in Temple
	{2387.55, 1035.70, 11.56}, //Transfender in come-a-lot
	{1836.93, -1856.28, 14.13}, //Eight Ball Autos near El Corona
	{2006.11, 2292.87, 11.57}, //Welding Wedding Bomb-workshop in Emerald Isle
	{-1787.25, 1202.00, 25.84}, //Michelles Pay 'n' Spray in Downtown
	{720.10, -470.93, 17.07}, //Pay 'n' Spray in Dillimore
	{-1420.21, 2599.45, 56.43}, //Pay 'n' Spray in El Quebrados
	{-100.16, 1100.79, 20.34}, //Pay 'n' Spray in Fort Carson
	{2078.44, -1831.44, 14.13}, //Pay 'n' Spray in Idlewood
	{-2426.89, 1036.61, 51.14}, //Pay 'n' Spray in Juniper Hollow
	{1957.96, 2161.96, 11.56}, //Pay 'n' Spray in Redsands East
	{488.29, -1724.85, 12.01}, //Pay 'n' Spray in Santa Maria Beach
	{1025.08, -1037.28, 32.28}, //Pay 'n' Spray in Temple
	{2393.70, 1472.80, 11.42}, //Pay 'n' Spray near Royal Casino
	{-1904.97, 268.51, 41.04}, //Pay 'n' Spray near Wang Cars in Doherty
	{403.58, 2486.33, 17.23}, //Player Garage: Verdant Meadows
	{1578.24, 1245.20, 11.57}, //Player Garage: Las Venturas Airport
	{-2105.79, 905.11, 77.07}, //Player Garage: Calton Heights
	{423.69, 2545.99, 17.07}, //Player Garage: Derdant Meadows
	{785.79, -513.12, 17.44}, //Player Garage: Dillimore
	{-2027.34, 141.02, 29.57}, //Player Garage: Doherty
	{1698.10, -2095.88, 14.29}, //Player Garage: El Corona
	{-361.10, 1185.23, 20.49}, //Player Garage: Fort Carson
	{-2463.27, -124.86, 26.41}, //Player Garage: Hashbury
	{2505.64, -1683.72, 14.25}, //Player Garage: Johnson House
	{1350.76, -615.56, 109.88}, //Player Garage: Mulholland
	{2231.64, 156.93, 27.63}, //Player Garage: Palomino Creek
	{-2695.51, 810.70, 50.57}, //Player Garage: Paradiso
	{1293.61, 2529.54, 11.42}, //Player Garage: Prickle Pine
	{1401.34, 1903.08, 11.99}, //Player Garage: Redland West
	{2436.50, 698.43, 11.60}, //Player Garage: Rockshore West
	{322.65, -1780.30, 5.55}, //Player Garage: Santa Maria Beach
	{917.46, 2012.14, 11.65}, //Player Garage: Whitewood Estates
	{1641.14, -1526.87, 14.30}, //Commerce Region Loading Bay
	{-1617.58, 688.69, -4.50}, //San Fierro Police Garage
	{837.05, -1101.93, 23.98}, //Los Santos Cemetery
	{2338.32, -1180.61, 1027.98}, //Interior: Burning Desire House
	{-975.5766, 1061.1312, 1345.6719}, //Interior: RC Zero's Battlefield
	{-750.80, 491.00, 1371.70}, //Interior: Liberty City
	{-1400.2138, 106.8926, 1032.2779}, //Interior: Unknown Stadium
	{-2015.6638, 147.2069, 29.3127}, //Interior: Secret San Fierro Chunk
	{2220.26, -1148.01, 1025.80}, //Interior: Jefferson Motel
	{-2660.6185, 1426.8320, 907.3626}, //Interior: Jizzy's Pleasure Dome
	{-1394.20, 987.62, 1023.96}, //Stadium: Bloodbowl
	{-1410.72, 1591.16, 1052.53}, //Stadium: Kickstart
	{-1417.8720, -276.4260, 1051.1910}, //Stadium: 8-Track Stadium
	{-25.8844, -185.8689, 1003.5499}, //24/7 Store: Big-L-Shaped
	{6.0911, -29.2718, 1003.5499}, //24/7 Store: Big-Oblong
	{-30.9469, -89.6095, 1003.5499}, //24/7 Store: Med-Square
	{-25.1329, -139.0669, 1003.5499}, //24/7 Store: Med-Square
	{-27.3123, -29.2775, 1003.5499}, //24/7 Store: Sml-Long
	{-26.6915, -55.7148, 1003.5499}, //24/7 Store: Sml-Square
	{-1827.1473, 7.2074, 1061.1435}, //Airport: Ticket Sales
	{-1855.5687, 41.2631, 1061.1435}, //Airport: Baggage Claim
	{2.3848, 33.1033, 1199.8499}, //Airplane: Shamal Cabin
	{315.8561, 1024.4964, 1949.7973}, //Airplane: Andromada Cargo hold
	{2536.08, -1632.98, 13.79}, // Grove Street
	{1992.93, 1047.31, 10.82}, //Four Dragons Casino
	{2033.00, -1416.02, 16.99}, // LS Hospital
	{-2653.11, 634.78, 14.45}, // SF Hospital
	{1580.22, 1768.93, 10.82}, //LV Hospital
	{-1550.73, 99.29, 17.33}, //SF Export
	//Positions given to me by SureShot :O
 	{-2057.8000, 229.9000, 35.6204}, // San Fierro
 	{-2366.0000, -1667.4000, 484.1011}, // Mount Chiliad
 	{2503.7000, -1705.8000, 13.5480}, // Grove Street
 	{1997.9000, 1056.3000, 10.8203}, // Las Venturas
 	{-2872.7000, 2712.6001, 275.2690}, // BaySide
 	{904.1000, 608.0000, -32.3281}, // Unterwasser
 	{-236.9000, 2663.8000, 73.6513} // The big Cock
};

static const SingleplayerCheats [][] =
{
	"BAGUVIX", //Unbegrenzt viel Gesundheit
	"HESOYAM", //Gesundheit, Schutzweste, $250.000
	"WANRLTW", //Unbegrenzt viel Munition, kein Nachladen
	"NCSGDAG", //Bei allen Waffen im Level Hitman
	"OUIQDMW", //Waehrend des Fahrens volle Zielfaehigkeiten
	"LXGIWYL", //Waffen-Set 1 (Schurken-Werkzeuge)
	"KJKSZPJ", //Waffen-Set 2 (Professionelle Werkzeuge)
	"UZUMYMW", //Waffen-Set 3 (Nutter-Werkzeuge)
	"ROCKETMAN", //Jetpack
	"AIYPWZQP", //Fallschirm
	"OSRBLHH", //Wanted-Level um zwei Sterne erhoehen
	"ASNAEB", //Wanted-Level loeschen
	"LJSPQK", //Wanted-Level auf sechs Sterne
	"AEZAKMI", //Niemals auf der Fahndungsliste
	"MUNASEF", //Adrenalin-Modus
	"KANGAROO", //Mega-Sprung
	"IAVENJQ", //Mega-Punch
	"AEDUWNV", //Niemals hungrig werden
	"CVWKXAM", //Unbegrenzt viel Sauerstoff
	//"BTCDBCB", //Dick
	//"KVGYZQK", //Duenn
	//"JYSDSOD", //Maximale Muskeln
	//"OGXSDAG", //Maximaler Respekt
	//"EHIBXQS", //Maximaler Sexappeal
	//"MROEMZH", //Gang-Mitglieder sind ueberall
	//"BIFBUZZ", //Gangs kontrollieren die Stra¦e
	"AIWPRTON", //Rhino
	"CQZIJMB", //Bloodring Banger
	"JQNTDMH", //Rancher
	"PDNEJOH", //Rennwagen
	"VPJTQWV", //Rennwagen 2
	"AQTBCODX", //Romero
	"KRIJEBR", //Stretch
	"UBHYZHQ", //Trashmaster
	"RZHSUEW", //Caddy
	"JUMPJET", //Hydra
	"KGGGDKP", //Vortex Hovercraft
	"OHDUDE", //Hunter
	"AKJJYGLC", //Quad
	"AMOMHRER", //Tanker Truck
	"EEGCYXT", //Dozer
	"URKQSRK", //Stunt Plane
	"AGBDLCID", //Monster
	"CPKTNWT", //Alle Autos sprengen
	"XICWMD", //Unsichtbares Auto
	"PGGOMOY", //Perfektes Handling
	//"ZEIIVG", //Alle Ampeln gruen
	//"YLTEICZ", //Aggressive Fahrer
	//"LLQPFBN", //Pink Verkehr
	//"IOWDLAC", //Schwarzer Verkehr
	"AFSNMSMW", //Boote fliegen
	//"BGKGTJH", //Verkehr mit billigen Autos
	//"GUSNHDE", //Verkehr mit schnellen Autos
	"RIPAZHA", //Autos fliegen
	"JHJOECW", //Gro¦er Hasensprung
	"JCNRUAD", //Smash 'n' Boom
	"COXEFGU", //Alle Autos sind mit Nitro betankt
	"BSXSGGC", //Autos rutschen bei Beruehrung weg
	//"THGLOJ", //Wenig Verkehr
	//"FVTMNBZ", //Verkehr nur mit landwirtschaftlichen Fahrzeugen
	"VKYPQCF", //Taxis sind mit Nitro betankt
	"VQIMAHA", //Alle Autos auf maximalen Statistiken
	//"AJLOJYQY", //Fu¦gaenger greifen sich gegenseitig an, Golf Club verfuegbar
	//"BAGOWPG", //Kopfgeld ist auf dich ausgesetzt
	//"FOOOXFT", //Jeder ist bewaffnet
	"SZCMAWO", //Selbstmord
	//"BLUESUEDESHOES", // ueberall erscheint Elvis
	//"BGLUAWML", //Fu¦gaenger greifen dich an, Raketenwerfer verfuegbar
	//"CIKGCGX", //Beach Party
	//"AFPHULTL", //Ninja Theme
	//"BEKKNQV", //Slut Magnet : P
	//"IOJUFZN", //Riot-Modus
	//"PRIEBJ", //Funhouse Theme
	//"SJMAHPE", //Rekrutiere jeden (9mm)
	//"BMTPWHR", //Landwitschaftsfahrzeuge und-fu¦gaenger, Trucker-Outfit
	//"ZSOXFSQ", //Rekrutiere jeden (Raketen)
	//"AFZLLQLL", //Sonnig
	//"ICIKPYH", //Sehr sonnig
	//"ALNSFMZO", //Bewoelkt
	//"AUIFRVQS", //Regnerisch
	//"CFVFGMJ", //Nebelig
	//"MGHXYRM", //Donner
	//"CWJXUOC", //Sandsturm
	"YSOHNUL", //Uhr laeuft schneller
	"PPGWJHT", //Gameplay laeuft schneller
	"LIYOAAY", //Gameplay laeuft langsamer
	"XJVSNAJ", //Immer Mitternacht
	//"OFVIAC", //Roetlicher Himmel 21: 00 Uhr
	"BOOOOORING", //Zeitlupen-Modus
	"Onspeed", //Zeitraffer-Modus
	"ASPIRINE", //Health-Cheat
	"LEAVEMEALONE", //Fahndungslevel-Cheat (loeschen)
	"NUTTERTOOLS", //Waffen-Cheats (schwer)
	"PROFESSIONALTOOLS", //Waffen-Cheats (mittel)
	"Thugstool", //Waffen-Cheat (leicht)
	"YOUWONTTAKEMEALIVE", //Fahndungslevel-Cheat (erhoehen)
	"ICANTTAKEITANYMORE" //Selbstmord
};

enum JB::SAZONE_MAIN
{ //Betamaster
	JB::SAZONE_NAME [28 char],
	Float: JB::SAZONE_AREA [6]
};

static const JB::SAZones [][JB::SAZONE_MAIN] =
{ // Majority of names and area coordinates adopted from Mabako's 'Zones Script' v0.2
	//	NAME							AREA (Xmin, Ymin, Zmin, Xmax, Ymax, Zmax)
	{!"The Big Ear", 				{-410.00, 1403.30, -3.00, -137.90, 1681.20, 200.00}},
	{!"Aldea Malvada",				{-1372.10, 2498.50, 0.00, -1277.50, 2615.30, 200.00}},
	{!"Angel Pine",				 	{-2324.90, -2584.20, -6.10, -1964.20, -2212.10, 200.00}},
	{!"Arco del Oeste",			 	{-901.10, 2221.80, 0.00, -592.00, 2571.90, 200.00}},
	{!"Avispa Country Club",		{-2646.40, -355.40, 0.00, -2270.00, -222.50, 200.00}},
	{!"Avispa Country Club",		{-2831.80, -430.20, -6.10, -2646.40, -222.50, 200.00}},
	{!"Avispa Country Club",		{-2361.50, -417.10, 0.00, -2270.00, -355.40, 200.00}},
	{!"Avispa Country Club",		{-2667.80, -302.10, -28.80, -2646.40, -262.30, 71.10}},
	{!"Avispa Country Club",		{-2470.00, -355.40, 0.00, -2270.00, -318.40, 46.10}},
	{!"Avispa Country Club",		{-2550.00, -355.40, 0.00, -2470.00, -318.40, 39.70}},
	{!"Back o Beyond",				{-1166.90, -2641.10, 0.00, -321.70, -1856.00, 200.00}},
	{!"Battery Point",				{-2741.00, 1268.40, -4.50, -2533.00, 1490.40, 200.00}},
	{!"Bayside",					{-2741.00, 2175.10, 0.00, -2353.10, 2722.70, 200.00}},
	{!"Bayside Marina",				{-2353.10, 2275.70, 0.00, -2153.10, 2475.70, 200.00}},
	{!"Beacon Hill",				{-399.60, -1075.50, -1.40, -319.00, -977.50, 198.50}},
	{!"Blackfield",					{964.30, 1203.20, -89.00, 1197.30, 1403.20, 110.90}},
	{!"Blackfield",					{964.30, 1403.20, -89.00, 1197.30, 1726.20, 110.90}},
	{!"Blackfield Chapel",			{1375.60, 596.30, -89.00, 1558.00, 823.20, 110.90}},
	{!"Blackfield Chapel",			{1325.60, 596.30, -89.00, 1375.60, 795.00, 110.90}},
	{!"Blackfield Intersection",	{1197.30, 1044.60, -89.00, 1277.00, 1163.30, 110.90}},
	{!"Blackfield Intersection",	{1166.50, 795.00, -89.00, 1375.60, 1044.60, 110.90}},
	{!"Blackfield Intersection",	{1277.00, 1044.60, -89.00, 1315.30, 1087.60, 110.90}},
	{!"Blackfield Intersection",	{1375.60, 823.20, -89.00, 1457.30, 919.40, 110.90}},
	{!"Blueberry",					{104.50, -220.10, 2.30, 349.60, 152.20, 200.00}},
	{!"Blueberry",					{19.60, -404.10, 3.80, 349.60, -220.10, 200.00}},
	{!"Blueberry Acres",			{-319.60, -220.10, 0.00, 104.50, 293.30, 200.00}},
	{!"Caligula's Palace",			{2087.30, 1543.20, -89.00, 2437.30, 1703.20, 110.90}},
	{!"Caligula's Palace",			{2137.40, 1703.20, -89.00, 2437.30, 1783.20, 110.90}},
	{!"Calton Heights",				{-2274.10, 744.10, -6.10, -1982.30, 1358.90, 200.00}},
	{!"Chinatown",					{-2274.10, 578.30, -7.60, -2078.60, 744.10, 200.00}},
	{!"City Hall",					{-2867.80, 277.40, -9.10, -2593.40, 458.40, 200.00}},
	{!"Come-A-Lot",					{2087.30, 943.20, -89.00, 2623.10, 1203.20, 110.90}},
	{!"Commerce",					{1323.90, -1842.20, -89.00, 1701.90, -1722.20, 110.90}},
	{!"Commerce",					{1323.90, -1722.20, -89.00, 1440.90, -1577.50, 110.90}},
	{!"Commerce",					{1370.80, -1577.50, -89.00, 1463.90, -1384.90, 110.90}},
	{!"Commerce",					{1463.90, -1577.50, -89.00, 1667.90, -1430.80, 110.90}},
	{!"Commerce",					{1583.50, -1722.20, -89.00, 1758.90, -1577.50, 110.90}},
	{!"Commerce",					{1667.90, -1577.50, -89.00, 1812.60, -1430.80, 110.90}},
	{!"Conference Center",			{1046.10, -1804.20, -89.00, 1323.90, -1722.20, 110.90}},
	{!"Conference Center",			{1073.20, -1842.20, -89.00, 1323.90, -1804.20, 110.90}},
	{!"Cranberry Station",			{-2007.80, 56.30, 0.00, -1922.00, 224.70, 100.00}},
	{!"Creek",						{2749.90, 1937.20, -89.00, 2921.60, 2669.70, 110.90}},
	{!"Dillimore",					{580.70, -674.80, -9.50, 861.00, -404.70, 200.00}},
	{!"Doherty",					{-2270.00, -324.10, -0.00, -1794.90, -222.50, 200.00}},
	{!"Doherty",					{-2173.00, -222.50, -0.00, -1794.90, 265.20, 200.00}},
	{!"Downtown",					{-1982.30, 744.10, -6.10, -1871.70, 1274.20, 200.00}},
	{!"Downtown",					{-1871.70, 1176.40, -4.50, -1620.30, 1274.20, 200.00}},
	{!"Downtown",					{-1700.00, 744.20, -6.10, -1580.00, 1176.50, 200.00}},
	{!"Downtown",					{-1580.00, 744.20, -6.10, -1499.80, 1025.90, 200.00}},
	{!"Downtown",					{-2078.60, 578.30, -7.60, -1499.80, 744.20, 200.00}},
	{!"Downtown",					{-1993.20, 265.20, -9.10, -1794.90, 578.30, 200.00}},
	{!"Downtown Los Santos",		{1463.90, -1430.80, -89.00, 1724.70, -1290.80, 110.90}},
	{!"Downtown Los Santos",		{1724.70, -1430.80, -89.00, 1812.60, -1250.90, 110.90}},
	{!"Downtown Los Santos",		{1463.90, -1290.80, -89.00, 1724.70, -1150.80, 110.90}},
	{!"Downtown Los Santos",		{1370.80, -1384.90, -89.00, 1463.90, -1170.80, 110.90}},
	{!"Downtown Los Santos",		{1724.70, -1250.90, -89.00, 1812.60, -1150.80, 110.90}},
	{!"Downtown Los Santos",		{1370.80, -1170.80, -89.00, 1463.90, -1130.80, 110.90}},
	{!"Downtown Los Santos",		{1378.30, -1130.80, -89.00, 1463.90, -1026.30, 110.90}},
	{!"Downtown Los Santos",		{1391.00, -1026.30, -89.00, 1463.90, -926.90, 110.90}},
	{!"Downtown Los Santos",		{1507.50, -1385.20, 110.90, 1582.50, -1325.30, 335.90}},
	{!"East Beach",					{2632.80, -1852.80, -89.00, 2959.30, -1668.10, 110.90}},
	{!"East Beach",					{2632.80, -1668.10, -89.00, 2747.70, -1393.40, 110.90}},
	{!"East Beach",					{2747.70, -1668.10, -89.00, 2959.30, -1498.60, 110.90}},
	{!"East Beach",					{2747.70, -1498.60, -89.00, 2959.30, -1120.00, 110.90}},
	{!"East Los Santos",			{2421.00, -1628.50, -89.00, 2632.80, -1454.30, 110.90}},
	{!"East Los Santos",			{2222.50, -1628.50, -89.00, 2421.00, -1494.00, 110.90}},
	{!"East Los Santos",			{2266.20, -1494.00, -89.00, 2381.60, -1372.00, 110.90}},
	{!"East Los Santos",			{2381.60, -1494.00, -89.00, 2421.00, -1454.30, 110.90}},
	{!"East Los Santos",			{2281.40, -1372.00, -89.00, 2381.60, -1135.00, 110.90}},
	{!"East Los Santos",			{2381.60, -1454.30, -89.00, 2462.10, -1135.00, 110.90}},
	{!"East Los Santos",			{2462.10, -1454.30, -89.00, 2581.70, -1135.00, 110.90}},
	{!"Easter Basin",				{-1794.90, 249.90, -9.10, -1242.90, 578.30, 200.00}},
	{!"Easter Basin",				{-1794.90, -50.00, -0.00, -1499.80, 249.90, 200.00}},
	{!"Easter Bay Airport",			{-1499.80, -50.00, -0.00, -1242.90, 249.90, 200.00}},
	{!"Easter Bay Airport",			{-1794.90, -730.10, -3.00, -1213.90, -50.00, 200.00}},
	{!"Easter Bay Airport",			{-1213.90, -730.10, 0.00, -1132.80, -50.00, 200.00}},
	{!"Easter Bay Airport",			{-1242.90, -50.00, 0.00, -1213.90, 578.30, 200.00}},
	{!"Easter Bay Airport",			{-1213.90, -50.00, -4.50, -947.90, 578.30, 200.00}},
	{!"Easter Bay Airport",			{-1315.40, -405.30, 15.40, -1264.40, -209.50, 25.40}},
	{!"Easter Bay Airport",			{-1354.30, -287.30, 15.40, -1315.40, -209.50, 25.40}},
	{!"Easter Bay Airport",			{-1490.30, -209.50, 15.40, -1264.40, -148.30, 25.40}},
	{!"Easter Bay Chemicals",		{-1132.80, -768.00, 0.00, -956.40, -578.10, 200.00}},
	{!"Easter Bay Chemicals",		{-1132.80, -787.30, 0.00, -956.40, -768.00, 200.00}},
	{!"El Castillo del Diablo",		{-464.50, 2217.60, 0.00, -208.50, 2580.30, 200.00}},
	{!"El Castillo del Diablo",		{-208.50, 2123.00, -7.60, 114.00, 2337.10, 200.00}},
	{!"El Castillo del Diablo",		{-208.50, 2337.10, 0.00, 8.40, 2487.10, 200.00}},
	{!"El Corona",					{1812.60, -2179.20, -89.00, 1970.60, -1852.80, 110.90}},
	{!"El Corona",					{1692.60, -2179.20, -89.00, 1812.60, -1842.20, 110.90}},
	{!"El Quebrados",				{-1645.20, 2498.50, 0.00, -1372.10, 2777.80, 200.00}},
	{!"Esplanade East",				{-1620.30, 1176.50, -4.50, -1580.00, 1274.20, 200.00}},
	{!"Esplanade East",				{-1580.00, 1025.90, -6.10, -1499.80, 1274.20, 200.00}},
	{!"Esplanade East",				{-1499.80, 578.30, -79.60, -1339.80, 1274.20, 20.30}},
	{!"Esplanade North",			{-2533.00, 1358.90, -4.50, -1996.60, 1501.20, 200.00}},
	{!"Esplanade North",			{-1996.60, 1358.90, -4.50, -1524.20, 1592.50, 200.00}},
	{!"Esplanade North",			{-1982.30, 1274.20, -4.50, -1524.20, 1358.90, 200.00}},
	{!"Fallen Tree",				{-792.20, -698.50, -5.30, -452.40, -380.00, 200.00}},
	{!"Fallow Bridge",				{434.30, 366.50, 0.00, 603.00, 555.60, 200.00}},
	{!"Fern Ridge",					{508.10, -139.20, 0.00, 1306.60, 119.50, 200.00}},
	{!"Financial",					{-1871.70, 744.10, -6.10, -1701.30, 1176.40, 300.00}},
	{!"Fisher's Lagoon",			{1916.90, -233.30, -100.00, 2131.70, 13.80, 200.00}},
	{!"Flint Intersection",			{-187.70, -1596.70, -89.00, 17.00, -1276.60, 110.90}},
	{!"Flint Range",				{-594.10, -1648.50, 0.00, -187.70, -1276.60, 200.00}},
	{!"Fort Carson",				{-376.20, 826.30, -3.00, 123.70, 1220.40, 200.00}},
	{!"Foster Valley",				{-2270.00, -430.20, -0.00, -2178.60, -324.10, 200.00}},
	{!"Foster Valley",				{-2178.60, -599.80, -0.00, -1794.90, -324.10, 200.00}},
	{!"Foster Valley",				{-2178.60, -1115.50, 0.00, -1794.90, -599.80, 200.00}},
	{!"Foster Valley",				{-2178.60, -1250.90, 0.00, -1794.90, -1115.50, 200.00}},
	{!"Frederick Bridge",			{2759.20, 296.50, 0.00, 2774.20, 594.70, 200.00}},
	{!"Gant Bridge",				{-2741.40, 1659.60, -6.10, -2616.40, 2175.10, 200.00}},
	{!"Gant Bridge",				{-2741.00, 1490.40, -6.10, -2616.40, 1659.60, 200.00}},
	{!"Ganton",						{2222.50, -1852.80, -89.00, 2632.80, -1722.30, 110.90}},
	{!"Ganton",						{2222.50, -1722.30, -89.00, 2632.80, -1628.50, 110.90}},
	{!"Garcia",						{-2411.20, -222.50, -0.00, -2173.00, 265.20, 200.00}},
	{!"Garcia",						{-2395.10, -222.50, -5.30, -2354.00, -204.70, 200.00}},
	{!"Garver Bridge",				{-1339.80, 828.10, -89.00, -1213.90, 1057.00, 110.90}},
	{!"Garver Bridge",				{-1213.90, 950.00, -89.00, -1087.90, 1178.90, 110.90}},
	{!"Garver Bridge",				{-1499.80, 696.40, -179.60, -1339.80, 925.30, 20.30}},
	{!"Glen Park",					{1812.60, -1449.60, -89.00, 1996.90, -1350.70, 110.90}},
	{!"Glen Park",					{1812.60, -1100.80, -89.00, 1994.30, -973.30, 110.90}},
	{!"Glen Park",					{1812.60, -1350.70, -89.00, 2056.80, -1100.80, 110.90}},
	{!"Green Palms",				{176.50, 1305.40, -3.00, 338.60, 1520.70, 200.00}},
	{!"Greenglass College",			{964.30, 1044.60, -89.00, 1197.30, 1203.20, 110.90}},
	{!"Greenglass College",			{964.30, 930.80, -89.00, 1166.50, 1044.60, 110.90}},
	{!"Hampton Barns",				{603.00, 264.30, 0.00, 761.90, 366.50, 200.00}},
	{!"Hankypanky Point",			{2576.90, 62.10, 0.00, 2759.20, 385.50, 200.00}},
	{!"Harry Gold Parkway",			{1777.30, 863.20, -89.00, 1817.30, 2342.80, 110.90}},
	{!"Hashbury",					{-2593.40, -222.50, -0.00, -2411.20, 54.70, 200.00}},
	{!"Hilltop Farm",				{967.30, -450.30, -3.00, 1176.70, -217.90, 200.00}},
	{!"Hunter Quarry",				{337.20, 710.80, -115.20, 860.50, 1031.70, 203.70}},
	{!"Idlewood",					{1812.60, -1852.80, -89.00, 1971.60, -1742.30, 110.90}},
	{!"Idlewood",					{1812.60, -1742.30, -89.00, 1951.60, -1602.30, 110.90}},
	{!"Idlewood",					{1951.60, -1742.30, -89.00, 2124.60, -1602.30, 110.90}},
	{!"Idlewood",					{1812.60, -1602.30, -89.00, 2124.60, -1449.60, 110.90}},
	{!"Idlewood",					{2124.60, -1742.30, -89.00, 2222.50, -1494.00, 110.90}},
	{!"Idlewood",					{1971.60, -1852.80, -89.00, 2222.50, -1742.30, 110.90}},
	{!"Jefferson",					{1996.90, -1449.60, -89.00, 2056.80, -1350.70, 110.90}},
	{!"Jefferson",					{2124.60, -1494.00, -89.00, 2266.20, -1449.60, 110.90}},
	{!"Jefferson",					{2056.80, -1372.00, -89.00, 2281.40, -1210.70, 110.90}},
	{!"Jefferson",					{2056.80, -1210.70, -89.00, 2185.30, -1126.30, 110.90}},
	{!"Jefferson",					{2185.30, -1210.70, -89.00, 2281.40, -1154.50, 110.90}},
	{!"Jefferson",					{2056.80, -1449.60, -89.00, 2266.20, -1372.00, 110.90}},
	{!"Julius Thruway East",		{2623.10, 943.20, -89.00, 2749.90, 1055.90, 110.90}},
	{!"Julius Thruway East",		{2685.10, 1055.90, -89.00, 2749.90, 2626.50, 110.90}},
	{!"Julius Thruway East",		{2536.40, 2442.50, -89.00, 2685.10, 2542.50, 110.90}},
	{!"Julius Thruway East",		{2625.10, 2202.70, -89.00, 2685.10, 2442.50, 110.90}},
	{!"Julius Thruway North",		{2498.20, 2542.50, -89.00, 2685.10, 2626.50, 110.90}},
	{!"Julius Thruway North",		{2237.40, 2542.50, -89.00, 2498.20, 2663.10, 110.90}},
	{!"Julius Thruway North",		{2121.40, 2508.20, -89.00, 2237.40, 2663.10, 110.90}},
	{!"Julius Thruway North",		{1938.80, 2508.20, -89.00, 2121.40, 2624.20, 110.90}},
	{!"Julius Thruway North",		{1534.50, 2433.20, -89.00, 1848.40, 2583.20, 110.90}},
	{!"Julius Thruway North",		{1848.40, 2478.40, -89.00, 1938.80, 2553.40, 110.90}},
	{!"Julius Thruway North",		{1704.50, 2342.80, -89.00, 1848.40, 2433.20, 110.90}},
	{!"Julius Thruway North",		{1377.30, 2433.20, -89.00, 1534.50, 2507.20, 110.90}},
	{!"Julius Thruway South",		{1457.30, 823.20, -89.00, 2377.30, 863.20, 110.90}},
	{!"Julius Thruway South",		{2377.30, 788.80, -89.00, 2537.30, 897.90, 110.90}},
	{!"Julius Thruway West",		{1197.30, 1163.30, -89.00, 1236.60, 2243.20, 110.90}},
	{!"Julius Thruway West",		{1236.60, 2142.80, -89.00, 1297.40, 2243.20, 110.90}},
	{!"Juniper Hill",				{-2533.00, 578.30, -7.60, -2274.10, 968.30, 200.00}},
	{!"Juniper Hollow",				{-2533.00, 968.30, -6.10, -2274.10, 1358.90, 200.00}},
	{!"K.A.C.C. Military Fuels",	{2498.20, 2626.50, -89.00, 2749.90, 2861.50, 110.90}},
	{!"Kincaid Bridge",				{-1339.80, 599.20, -89.00, -1213.90, 828.10, 110.90}},
	{!"Kincaid Bridge",				{-1213.90, 721.10, -89.00, -1087.90, 950.00, 110.90}},
	{!"Kincaid Bridge",				{-1087.90, 855.30, -89.00, -961.90, 986.20, 110.90}},
	{!"King's",						{-2329.30, 458.40, -7.60, -1993.20, 578.30, 200.00}},
	{!"King's",						{-2411.20, 265.20, -9.10, -1993.20, 373.50, 200.00}},
	{!"King's",						{-2253.50, 373.50, -9.10, -1993.20, 458.40, 200.00}},
	{!"LVA Freight Depot",			{1457.30, 863.20, -89.00, 1777.40, 1143.20, 110.90}},
	{!"LVA Freight Depot",			{1375.60, 919.40, -89.00, 1457.30, 1203.20, 110.90}},
	{!"LVA Freight Depot",			{1277.00, 1087.60, -89.00, 1375.60, 1203.20, 110.90}},
	{!"LVA Freight Depot",			{1315.30, 1044.60, -89.00, 1375.60, 1087.60, 110.90}},
	{!"LVA Freight Depot",			{1236.60, 1163.40, -89.00, 1277.00, 1203.20, 110.90}},
	{!"Las Barrancas",				{-926.10, 1398.70, -3.00, -719.20, 1634.60, 200.00}},
	{!"Las Brujas",					{-365.10, 2123.00, -3.00, -208.50, 2217.60, 200.00}},
	{!"Las Colinas",				{1994.30, -1100.80, -89.00, 2056.80, -920.80, 110.90}},
	{!"Las Colinas",				{2056.80, -1126.30, -89.00, 2126.80, -920.80, 110.90}},
	{!"Las Colinas",				{2185.30, -1154.50, -89.00, 2281.40, -934.40, 110.90}},
	{!"Las Colinas",				{2126.80, -1126.30, -89.00, 2185.30, -934.40, 110.90}},
	{!"Las Colinas",				{2747.70, -1120.00, -89.00, 2959.30, -945.00, 110.90}},
	{!"Las Colinas",				{2632.70, -1135.00, -89.00, 2747.70, -945.00, 110.90}},
	{!"Las Colinas",				{2281.40, -1135.00, -89.00, 2632.70, -945.00, 110.90}},
	{!"Las Payasadas",				{-354.30, 2580.30, 2.00, -133.60, 2816.80, 200.00}},
	{!"Las Venturas Airport",		{1236.60, 1203.20, -89.00, 1457.30, 1883.10, 110.90}},
	{!"Las Venturas Airport",		{1457.30, 1203.20, -89.00, 1777.30, 1883.10, 110.90}},
	{!"Las Venturas Airport",		{1457.30, 1143.20, -89.00, 1777.40, 1203.20, 110.90}},
	{!"Las Venturas Airport",		{1515.80, 1586.40, -12.50, 1729.90, 1714.50, 87.50}},
	{!"Last Dime Motel",			{1823.00, 596.30, -89.00, 1997.20, 823.20, 110.90}},
	{!"Leafy Hollow",				{-1166.90, -1856.00, 0.00, -815.60, -1602.00, 200.00}},
	{!"Liberty City",				{-1000.00, 400.00, 1300.00, -700.00, 600.00, 1400.00}},
	{!"Lil' Probe Inn",				{-90.20, 1286.80, -3.00, 153.80, 1554.10, 200.00}},
	{!"Linden Side",				{2749.90, 943.20, -89.00, 2923.30, 1198.90, 110.90}},
	{!"Linden Station",				{2749.90, 1198.90, -89.00, 2923.30, 1548.90, 110.90}},
	{!"Linden Station",				{2811.20, 1229.50, -39.50, 2861.20, 1407.50, 60.40}},
	{!"Little Mexico",				{1701.90, -1842.20, -89.00, 1812.60, -1722.20, 110.90}},
	{!"Little Mexico",				{1758.90, -1722.20, -89.00, 1812.60, -1577.50, 110.90}},
	{!"Los Flores",					{2581.70, -1454.30, -89.00, 2632.80, -1393.40, 110.90}},
	{!"Los Flores",					{2581.70, -1393.40, -89.00, 2747.70, -1135.00, 110.90}},
	{!"Los Santos International",	{1249.60, -2394.30, -89.00, 1852.00, -2179.20, 110.90}},
	{!"Los Santos International",	{1852.00, -2394.30, -89.00, 2089.00, -2179.20, 110.90}},
	{!"Los Santos International",	{1382.70, -2730.80, -89.00, 2201.80, -2394.30, 110.90}},
	{!"Los Santos International",	{1974.60, -2394.30, -39.00, 2089.00, -2256.50, 60.90}},
	{!"Los Santos International",	{1400.90, -2669.20, -39.00, 2189.80, -2597.20, 60.90}},
	{!"Los Santos International",	{2051.60, -2597.20, -39.00, 2152.40, -2394.30, 60.90}},
	{!"Marina",						{647.70, -1804.20, -89.00, 851.40, -1577.50, 110.90}},
	{!"Marina",						{647.70, -1577.50, -89.00, 807.90, -1416.20, 110.90}},
	{!"Marina",						{807.90, -1577.50, -89.00, 926.90, -1416.20, 110.90}},
	{!"Market",			 			{787.40, -1416.20, -89.00, 1072.60, -1310.20, 110.90}},
	{!"Market",						{952.60, -1310.20, -89.00, 1072.60, -1130.80, 110.90}},
	{!"Market",						{1072.60, -1416.20, -89.00, 1370.80, -1130.80, 110.90}},
	{!"Market",						{926.90, -1577.50, -89.00, 1370.80, -1416.20, 110.90}},
	{!"Market Station",				{787.40, -1410.90, -34.10, 866.00, -1310.20, 65.80}},
	{!"Martin Bridge",				{-222.10, 293.30, 0.00, -122.10, 476.40, 200.00}},
	{!"Missionary Hill",			{-2994.40, -811.20, 0.00, -2178.60, -430.20, 200.00}},
	{!"Montgomery",					{1119.50, 119.50, -3.00, 1451.40, 493.30, 200.00}},
	{!"Montgomery",					{1451.40, 347.40, -6.10, 1582.40, 420.80, 200.00}},
	{!"Montgomery Intersection",	{1546.60, 208.10, 0.00, 1745.80, 347.40, 200.00}},
	{!"Montgomery Intersection",	{1582.40, 347.40, 0.00, 1664.60, 401.70, 200.00}},
	{!"Mulholland",					{1414.00, -768.00, -89.00, 1667.60, -452.40, 110.90}},
	{!"Mulholland",					{1281.10, -452.40, -89.00, 1641.10, -290.90, 110.90}},
	{!"Mulholland",					{1269.10, -768.00, -89.00, 1414.00, -452.40, 110.90}},
	{!"Mulholland",					{1357.00, -926.90, -89.00, 1463.90, -768.00, 110.90}},
	{!"Mulholland",					{1318.10, -910.10, -89.00, 1357.00, -768.00, 110.90}},
	{!"Mulholland",					{1169.10, -910.10, -89.00, 1318.10, -768.00, 110.90}},
	{!"Mulholland",					{768.60, -954.60, -89.00, 952.60, -860.60, 110.90}},
	{!"Mulholland",					{687.80, -860.60, -89.00, 911.80, -768.00, 110.90}},
	{!"Mulholland",					{737.50, -768.00, -89.00, 1142.20, -674.80, 110.90}},
	{!"Mulholland",					{1096.40, -910.10, -89.00, 1169.10, -768.00, 110.90}},
	{!"Mulholland",					{952.60, -937.10, -89.00, 1096.40, -860.60, 110.90}},
	{!"Mulholland",					{911.80, -860.60, -89.00, 1096.40, -768.00, 110.90}},
	{!"Mulholland",					{861.00, -674.80, -89.00, 1156.50, -600.80, 110.90}},
	{!"Mulholland Intersection",	{1463.90, -1150.80, -89.00, 1812.60, -768.00, 110.90}},
	{!"North Rock",					{2285.30, -768.00, 0.00, 2770.50, -269.70, 200.00}},
	{!"Ocean Docks",				{2373.70, -2697.00, -89.00, 2809.20, -2330.40, 110.90}},
	{!"Ocean Docks",				{2201.80, -2418.30, -89.00, 2324.00, -2095.00, 110.90}},
	{!"Ocean Docks",				{2324.00, -2302.30, -89.00, 2703.50, -2145.10, 110.90}},
	{!"Ocean Docks",				{2089.00, -2394.30, -89.00, 2201.80, -2235.80, 110.90}},
	{!"Ocean Docks",				{2201.80, -2730.80, -89.00, 2324.00, -2418.30, 110.90}},
	{!"Ocean Docks",				{2703.50, -2302.30, -89.00, 2959.30, -2126.90, 110.90}},
	{!"Ocean Docks",				{2324.00, -2145.10, -89.00, 2703.50, -2059.20, 110.90}},
	{!"Ocean Flats",				{-2994.40, 277.40, -9.10, -2867.80, 458.40, 200.00}},
	{!"Ocean Flats",				{-2994.40, -222.50, -0.00, -2593.40, 277.40, 200.00}},
	{!"Ocean Flats",				{-2994.40, -430.20, -0.00, -2831.80, -222.50, 200.00}},
	{!"Octane Springs",				{338.60, 1228.50, 0.00, 664.30, 1655.00, 200.00}},
	{!"Old Venturas Strip",			{2162.30, 2012.10, -89.00, 2685.10, 2202.70, 110.90}},
	{!"Palisades",					{-2994.40, 458.40, -6.10, -2741.00, 1339.60, 200.00}},
	{!"Palomino Creek",				{2160.20, -149.00, 0.00, 2576.90, 228.30, 200.00}},
	{!"Paradiso",					{-2741.00, 793.40, -6.10, -2533.00, 1268.40, 200.00}},
	{!"Pershing Square",			{1440.90, -1722.20, -89.00, 1583.50, -1577.50, 110.90}},
	{!"Pilgrim",					{2437.30, 1383.20, -89.00, 2624.40, 1783.20, 110.90}},
	{!"Pilgrim",					{2624.40, 1383.20, -89.00, 2685.10, 1783.20, 110.90}},
	{!"Pilson Intersection",		{1098.30, 2243.20, -89.00, 1377.30, 2507.20, 110.90}},
	{!"Pirates in Men's Pants",		{1817.30, 1469.20, -89.00, 2027.40, 1703.20, 110.90}},
	{!"Playa del Seville",			{2703.50, -2126.90, -89.00, 2959.30, -1852.80, 110.90}},
	{!"Prickle Pine",				{1534.50, 2583.20, -89.00, 1848.40, 2863.20, 110.90}},
	{!"Prickle Pine",		 		{1117.40, 2507.20, -89.00, 1534.50, 2723.20, 110.90}},
	{!"Prickle Pine",		 		{1848.40, 2553.40, -89.00, 1938.80, 2863.20, 110.90}},
	{!"Prickle Pine",				{1938.80, 2624.20, -89.00, 2121.40, 2861.50, 110.90}},
	{!"Queens",						{-2533.00, 458.40, 0.00, -2329.30, 578.30, 200.00}},
	{!"Queens",						{-2593.40, 54.70, 0.00, -2411.20, 458.40, 200.00}},
	{!"Queens",						{-2411.20, 373.50, 0.00, -2253.50, 458.40, 200.00}},
	{!"Randolph Industrial Estate", {1558.00, 596.30, -89.00, 1823.00, 823.20, 110.90}},
	{!"Redsands East",				{1817.30, 2011.80, -89.00, 2106.70, 2202.70, 110.90}},
	{!"Redsands East",				{1817.30, 2202.70, -89.00, 2011.90, 2342.80, 110.90}},
	{!"Redsands East",				{1848.40, 2342.80, -89.00, 2011.90, 2478.40, 110.90}},
	{!"Redsands West",				{1236.60, 1883.10, -89.00, 1777.30, 2142.80, 110.90}},
	{!"Redsands West",				{1297.40, 2142.80, -89.00, 1777.30, 2243.20, 110.90}},
	{!"Redsands West",				{1377.30, 2243.20, -89.00, 1704.50, 2433.20, 110.90}},
	{!"Redsands West",				{1704.50, 2243.20, -89.00, 1777.30, 2342.80, 110.90}},
	{!"Regular Tom",				{-405.70, 1712.80, -3.00, -276.70, 1892.70, 200.00}},
	{!"Richman",					{647.50, -1118.20, -89.00, 787.40, -954.60, 110.90}},
	{!"Richman",					{647.50, -954.60, -89.00, 768.60, -860.60, 110.90}},
	{!"Richman",					{225.10, -1369.60, -89.00, 334.50, -1292.00, 110.90}},
	{!"Richman",					{225.10, -1292.00, -89.00, 466.20, -1235.00, 110.90}},
	{!"Richman",					{72.60, -1404.90, -89.00, 225.10, -1235.00, 110.90}},
	{!"Richman",					{72.60, -1235.00, -89.00, 321.30, -1008.10, 110.90}},
	{!"Richman",					{321.30, -1235.00, -89.00, 647.50, -1044.00, 110.90}},
	{!"Richman",					{321.30, -1044.00, -89.00, 647.50, -860.60, 110.90}},
	{!"Richman",					{321.30, -860.60, -89.00, 687.80, -768.00, 110.90}},
	{!"Richman",					{321.30, -768.00, -89.00, 700.70, -674.80, 110.90}},
	{!"Robada Intersection",		{-1119.00, 1178.90, -89.00, -862.00, 1351.40, 110.90}},
	{!"Roca Escalante",				{2237.40, 2202.70, -89.00, 2536.40, 2542.50, 110.90}},
	{!"Roca Escalante",				{2536.40, 2202.70, -89.00, 2625.10, 2442.50, 110.90}},
	{!"Rockshore East",				{2537.30, 676.50, -89.00, 2902.30, 943.20, 110.90}},
	{!"Rockshore West",				{1997.20, 596.30, -89.00, 2377.30, 823.20, 110.90}},
	{!"Rockshore West",				{2377.30, 596.30, -89.00, 2537.30, 788.80, 110.90}},
	{!"Rodeo",						{72.60, -1684.60, -89.00, 225.10, -1544.10, 110.90}},
	{!"Rodeo",						{72.60, -1544.10, -89.00, 225.10, -1404.90, 110.90}},
	{!"Rodeo",						{225.10, -1684.60, -89.00, 312.80, -1501.90, 110.90}},
	{!"Rodeo",						{225.10, -1501.90, -89.00, 334.50, -1369.60, 110.90}},
	{!"Rodeo",						{334.50, -1501.90, -89.00, 422.60, -1406.00, 110.90}},
	{!"Rodeo",						{312.80, -1684.60, -89.00, 422.60, -1501.90, 110.90}},
	{!"Rodeo",						{422.60, -1684.60, -89.00, 558.00, -1570.20, 110.90}},
	{!"Rodeo",						{558.00, -1684.60, -89.00, 647.50, -1384.90, 110.90}},
	{!"Rodeo",						{466.20, -1570.20, -89.00, 558.00, -1385.00, 110.90}},
	{!"Rodeo",						{422.60, -1570.20, -89.00, 466.20, -1406.00, 110.90}},
	{!"Rodeo",						{466.20, -1385.00, -89.00, 647.50, -1235.00, 110.90}},
	{!"Rodeo",						{334.50, -1406.00, -89.00, 466.20, -1292.00, 110.90}},
	{!"Royal Casino",				{2087.30, 1383.20, -89.00, 2437.30, 1543.20, 110.90}},
	{!"San Andreas Sound",			{2450.30, 385.50, -100.00, 2759.20, 562.30, 200.00}},
	{!"Santa Flora",				{-2741.00, 458.40, -7.60, -2533.00, 793.40, 200.00}},
	{!"Santa Maria Beach",			{342.60, -2173.20, -89.00, 647.70, -1684.60, 110.90}},
	{!"Santa Maria Beach",			{72.60, -2173.20, -89.00, 342.60, -1684.60, 110.90}},
	{!"Shady Cabin",				{-1632.80, -2263.40, -3.00, -1601.30, -2231.70, 200.00}},
	{!"Shady Creeks",				{-1820.60, -2643.60, -8.00, -1226.70, -1771.60, 200.00}},
	{!"Shady Creeks",				{-2030.10, -2174.80, -6.10, -1820.60, -1771.60, 200.00}},
	{!"Sobell Rail Yards",			{2749.90, 1548.90, -89.00, 2923.30, 1937.20, 110.90}},
	{!"Spinybed",					{2121.40, 2663.10, -89.00, 2498.20, 2861.50, 110.90}},
	{!"Starfish Casino",			{2437.30, 1783.20, -89.00, 2685.10, 2012.10, 110.90}},
	{!"Starfish Casino",			{2437.30, 1858.10, -39.00, 2495.00, 1970.80, 60.90}},
	{!"Starfish Casino",			{2162.30, 1883.20, -89.00, 2437.30, 2012.10, 110.90}},
	{!"Temple",						{1252.30, -1130.80, -89.00, 1378.30, -1026.30, 110.90}},
	{!"Temple",						{1252.30, -1026.30, -89.00, 1391.00, -926.90, 110.90}},
	{!"Temple",						{1252.30, -926.90, -89.00, 1357.00, -910.10, 110.90}},
	{!"Temple",						{952.60, -1130.80, -89.00, 1096.40, -937.10, 110.90}},
	{!"Temple",						{1096.40, -1130.80, -89.00, 1252.30, -1026.30, 110.90}},
	{!"Temple",						{1096.40, -1026.30, -89.00, 1252.30, -910.10, 110.90}},
	{!"The Camel's Toe",			{2087.30, 1203.20, -89.00, 2640.40, 1383.20, 110.90}},
	{!"The Clown's Pocket",			{2162.30, 1783.20, -89.00, 2437.30, 1883.20, 110.90}},
	{!"The Emerald Isle",			{2011.90, 2202.70, -89.00, 2237.40, 2508.20, 110.90}},
	{!"The Farm",					{-1209.60, -1317.10, 114.90, -908.10, -787.30, 251.90}},
	{!"The Four Dragons Casino",	{1817.30, 863.20, -89.00, 2027.30, 1083.20, 110.90}},
	{!"The High Roller",			{1817.30, 1283.20, -89.00, 2027.30, 1469.20, 110.90}},
	{!"The Mako Span",				{1664.60, 401.70, 0.00, 1785.10, 567.20, 200.00}},
	{!"The Panopticon",				{-947.90, -304.30, -1.10, -319.60, 327.00, 200.00}},
	{!"The Pink Swan",				{1817.30, 1083.20, -89.00, 2027.30, 1283.20, 110.90}},
	{!"The Sherman Dam",			{-968.70, 1929.40, -3.00, -481.10, 2155.20, 200.00}},
	{!"The Strip",					{2027.40, 863.20, -89.00, 2087.30, 1703.20, 110.90}},
	{!"The Strip",					{2106.70, 1863.20, -89.00, 2162.30, 2202.70, 110.90}},
	{!"The Strip",					{2027.40, 1783.20, -89.00, 2162.30, 1863.20, 110.90}},
	{!"The Strip",					{2027.40, 1703.20, -89.00, 2137.40, 1783.20, 110.90}},
	{!"The Visage",					{1817.30, 1863.20, -89.00, 2106.70, 2011.80, 110.90}},
	{!"The Visage",					{1817.30, 1703.20, -89.00, 2027.40, 1863.20, 110.90}},
	{!"Unity Station",				{1692.60, -1971.80, -20.40, 1812.60, -1932.80, 79.50}},
	{!"Valle Ocultado",				{-936.60, 2611.40, 2.00, -715.90, 2847.90, 200.00}},
	{!"Verdant Bluffs",				{930.20, -2488.40, -89.00, 1249.60, -2006.70, 110.90}},
	{!"Verdant Bluffs",				{1073.20, -2006.70, -89.00, 1249.60, -1842.20, 110.90}},
	{!"Verdant Bluffs",				{1249.60, -2179.20, -89.00, 1692.60, -1842.20, 110.90}},
	{!"Verdant Meadows",			{37.00, 2337.10, -3.00, 435.90, 2677.90, 200.00}},
	{!"Verona Beach",				{647.70, -2173.20, -89.00, 930.20, -1804.20, 110.90}},
	{!"Verona Beach",				{930.20, -2006.70, -89.00, 1073.20, -1804.20, 110.90}},
	{!"Verona Beach",				{851.40, -1804.20, -89.00, 1046.10, -1577.50, 110.90}},
	{!"Verona Beach",				{1161.50, -1722.20, -89.00, 1323.90, -1577.50, 110.90}},
	{!"Verona Beach",				{1046.10, -1722.20, -89.00, 1161.50, -1577.50, 110.90}},
	{!"Vinewood",					{787.40, -1310.20, -89.00, 952.60, -1130.80, 110.90}},
	{!"Vinewood",					{787.40, -1130.80, -89.00, 952.60, -954.60, 110.90}},
	{!"Vinewood",					{647.50, -1227.20, -89.00, 787.40, -1118.20, 110.90}},
	{!"Vinewood",					{647.70, -1416.20, -89.00, 787.40, -1227.20, 110.90}},
	{!"Whitewood Estates",			{883.30, 1726.20, -89.00, 1098.30, 2507.20, 110.90}},
	{!"Whitewood Estates",			{1098.30, 1726.20, -89.00, 1197.30, 2243.20, 110.90}},
	{!"Willowfield",				{1970.60, -2179.20, -89.00, 2089.00, -1852.80, 110.90}},
	{!"Willowfield",				{2089.00, -2235.80, -89.00, 2201.80, -1989.90, 110.90}},
	{!"Willowfield",				{2089.00, -1989.90, -89.00, 2324.00, -1852.80, 110.90}},
	{!"Willowfield",				{2201.80, -2095.00, -89.00, 2324.00, -1989.90, 110.90}},
	{!"Willowfield",				{2541.70, -1941.40, -89.00, 2703.50, -1852.80, 110.90}},
	{!"Willowfield",				{2324.00, -2059.20, -89.00, 2541.70, -1852.80, 110.90}},
	{!"Willowfield",				{2541.70, -2059.20, -89.00, 2703.50, -1941.40, 110.90}},
	{!"Yellow Bell Station",		{1377.40, 2600.40, -21.90, 1492.40, 2687.30, 78.00}},
	// Main Zones
	{!"Los Santos",					{44.60, -2892.90, -242.90, 2997.00, -768.00, 900.00}},
	{!"Las Venturas",				{869.40, 596.30, -242.90, 2997.00, 2993.80, 900.00}},
	{!"Bone County",				{-480.50, 596.30, -242.90, 869.40, 2993.80, 900.00}},
	{!"Tierra Robada",				{-2997.40, 1659.60, -242.90, -480.50, 2993.80, 900.00}},
	{!"Tierra Robada",				{-1213.90, 596.30, -242.90, -480.50, 1659.60, 900.00}},
	{!"San Fierro",					{-2997.40, -1115.50, -242.90, -1213.90, 1659.60, 900.00}},
	{!"Red County",					{-1213.90, -768.00, -242.90, 2997.00, 596.30, 900.00}},
	{!"Flint County",				{-1213.90, -2892.90, -242.90, 44.60, -768.00, 900.00}},
	{!"Whetstone",					{-2997.40, -2892.90, -242.90, -1213.90, -1115.50, 900.00}}
};

static const JB::AdminCommands [][] =
{
	"/jbcfg",
	"/jbreports",
	"/jbvarlist",
	"/jbsetvar",
	"/blackadd",
	"/blackdel",
	"/whiteadd",
	"/whitedel",
	"/tban",
	"/tunban",
	"/banIP",
	"/unbanIP",
	"/myfps",
	"/jbsethomepage",
	"/jbchrome",
	"/jbhackcodes"
};

//==============================================================================

PUBLIC: JB::AddPlayerClass (modelid, Float: spawn_x, Float: spawn_y, Float: spawn_z, Float: z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)
{
	new classid = AddPlayerClass (modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
	
	if (classid < MAX_CLASSES)
	{
		JB::PlayerClassWeapons [classid][0][0] = weapon1;
		JB::PlayerClassWeapons [classid][0][1] = weapon1_ammo;
		JB::PlayerClassWeapons [classid][1][0] = weapon2;
		JB::PlayerClassWeapons [classid][1][1] = weapon2_ammo;
		JB::PlayerClassWeapons [classid][2][0] = weapon3;
		JB::PlayerClassWeapons [classid][2][1] = weapon3_ammo;
	}
	else
		JB::Log ("Error: Please increase MAX_CLASSES!");
	return classid++;
}

PUBLIC: JB::AddPlayerClassEx (teamid, modelid, Float: spawn_x, Float: spawn_y, Float: spawn_z, Float: z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)
{
	new classid = AddPlayerClassEx (teamid, modelid, spawn_x, spawn_y, spawn_z, z_angle, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
		
	if (classid < MAX_CLASSES)
	{
		JB::PlayerClassWeapons [classid][0][0] = weapon1;
		JB::PlayerClassWeapons [classid][0][1] = weapon1_ammo;
		JB::PlayerClassWeapons [classid][1][0] = weapon2;
		JB::PlayerClassWeapons [classid][1][1] = weapon2_ammo;
		JB::PlayerClassWeapons [classid][2][0] = weapon3;
		JB::PlayerClassWeapons [classid][2][1] = weapon3_ammo;
	}
	else
		JB::Log ("Error: Please increase MAX_CLASSES!");
	return classid;
}

PUBLIC: JB::SetSpawnInfo (playerid, team, skin, Float: x, Float: y, Float: z, rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo)
{
	if (!IsPlayerConnected (playerid))
		return 0;

	JB::SpawnWeapons [playerid][0][0] = weapon1;
	JB::SpawnWeapons [playerid][0][1] = weapon1_ammo;
	JB::SpawnWeapons [playerid][1][0] = weapon2;
	JB::SpawnWeapons [playerid][1][1] = weapon2_ammo;
	JB::SpawnWeapons [playerid][2][0] = weapon3;
	JB::SpawnWeapons [playerid][2][1] = weapon3_ammo;
	return SetSpawnInfo (playerid, team, skin, x, y, z, rotation, weapon1, weapon1_ammo, weapon2, weapon2_ammo, weapon3, weapon3_ammo);
}

PUBLIC: AddWeaponPickup (Float: x, Float: y, Float: z, weaponid, ammo, worldid)
{
	new pickupid = CreatePickup (GetWeaponModel (weaponid), 19, x, y, z, worldid);

	if (pickupid != -1)
	{
		JB::PickupType {pickupid} = PICKUP_TYPE_WEAPON;
		JB::PickupVar [pickupid][0] = weaponid;
		JB::PickupVar [pickupid][1] = ammo;
		DOB::SetBit (JB::StaticPickup, pickupid, false);
		if (JB::PickupCount < MAX_PICKUPS)
			JB::PickupList [JB::PickupCount++] = pickupid;
		JB::PickupPos [pickupid][0] = x;
		JB::PickupPos [pickupid][1] = y;
		JB::PickupPos [pickupid][2] = z;
	}
	return pickupid;
}

PUBLIC: JB::AddStaticPickup (model, type, Float: x, Float: y, Float: z, virtualworld)
{
	new pickupid;

	if (type == 2 || type == 3 || type == 15 || type == 22)//Pickupable types with effect?
	{
		switch (model)
		{
			case 1240: //Health
			{
				pickupid = CreatePickup (model, type, x, y, z, virtualworld); //AddStaticPickup doesn't return pickupid...
				if (pickupid != -1)
				{
					JB::PickupType {pickupid} = PICKUP_TYPE_HEALTH;
					DOB::SetBit (JB::StaticPickup, pickupid, true);
					if (JB::PickupCount < MAX_PICKUPS)
						JB::PickupList [JB::PickupCount++] = pickupid;
					JB::PickupPos [pickupid][0] = x;
					JB::PickupPos [pickupid][1] = y;
					JB::PickupPos [pickupid][2] = z;
					return 1;
				}
				return 0;
			}

			case 1242: //Armour
			{
				pickupid = CreatePickup (model, type, x, y, z, virtualworld); //AddStaticPickup doesn't return pickupid...
				if (pickupid != -1)
				{
					JB::PickupType {pickupid} = PICKUP_TYPE_ARMOUR;
					DOB::SetBit (JB::StaticPickup, pickupid, true);
					if (JB::PickupCount < MAX_PICKUPS)
						JB::PickupList [JB::PickupCount++] = pickupid;
					JB::PickupPos [pickupid][0] = x;
					JB::PickupPos [pickupid][1] = y;
					JB::PickupPos [pickupid][2] = z;
					return 1;
				}
				return 0;
			}

			default:
			{
				for (new i = 0; i < MAX_WEAPONS; ++i)
				{
					if (GetWeaponModel (i) == model)//Is this pickup a weapon?
					{
					    pickupid = AddWeaponPickup (x, y, z, i, DefaultPickupAmmo [i], virtualworld);
					    if (pickupid != -1)
						{
						    DOB::SetBit (JB::StaticPickup, pickupid, true);
						    if (JB::PickupCount < MAX_PICKUPS)
								JB::PickupList [JB::PickupCount++] = pickupid;
						    JB::PickupPos [pickupid][0] = x;
							JB::PickupPos [pickupid][1] = y;
							JB::PickupPos [pickupid][2] = z;
						    return 1;
						}
						return 0;
					}
				}
			}
		}
	}
	
	pickupid = CreatePickup (model, type, x, y, z, virtualworld);
	if (pickupid != -1)
	{
	    DOB::SetBit (JB::StaticPickup, pickupid, true);
	    if (JB::PickupCount < MAX_PICKUPS)
			JB::PickupList [JB::PickupCount++] = pickupid;
	    JB::PickupPos [pickupid][0] = x;
		JB::PickupPos [pickupid][1] = y;
		JB::PickupPos [pickupid][2] = z;
	    return 1;
	}
	return 0;
}

PUBLIC: JB::CreatePickup (model, type, Float: x, Float: y, Float: z, virtualworld)
{
	new pickupid;

	if (type == 2 || type == 3 || type == 15 || type == 22)//Pickupable types with effect?
	{
		switch (model)
		{
			case 1240: //Health
			{
				pickupid = CreatePickup (model, type, x, y, z, virtualworld);
				if (pickupid != -1)
				{
					JB::PickupType {pickupid} = PICKUP_TYPE_HEALTH;
					DOB::SetBit (JB::StaticPickup, pickupid, false);
					if (JB::PickupCount < MAX_PICKUPS)
						JB::PickupList [JB::PickupCount++] = pickupid;
					JB::PickupPos [pickupid][0] = x;
					JB::PickupPos [pickupid][1] = y;
					JB::PickupPos [pickupid][2] = z;
				}
				return pickupid;
			}

			case 1242: //Armour
			{
				pickupid = CreatePickup (model, type, x, y, z, virtualworld);
				if (pickupid != -1)
				{
					JB::PickupType {pickupid} = PICKUP_TYPE_ARMOUR;
					DOB::SetBit (JB::StaticPickup, pickupid, false);
					if (JB::PickupCount < MAX_PICKUPS)
						JB::PickupList [JB::PickupCount++] = pickupid;
					JB::PickupPos [pickupid][0] = x;
					JB::PickupPos [pickupid][1] = y;
					JB::PickupPos [pickupid][2] = z;
				}
				return pickupid;
			}

			default:
			{
				for (new i = 0; i < MAX_WEAPONS; ++i)
				{
					if (GetWeaponModel (i) == model)//Is this pickup a weapon?
					{
						pickupid = AddWeaponPickup (x, y, z, i, DefaultPickupAmmo [i], virtualworld); //If yes, overwrite it to guarantee server-side weapons.
					    if (pickupid != -1)
						{
						    DOB::SetBit (JB::StaticPickup, pickupid, false);
						    if (JB::PickupCount < MAX_PICKUPS)
								JB::PickupList [JB::PickupCount++] = pickupid;
						    JB::PickupPos [pickupid][0] = x;
							JB::PickupPos [pickupid][1] = y;
							JB::PickupPos [pickupid][2] = z;
						}
						return pickupid;
					}
				}
			}
		}
	}
	
	pickupid = CreatePickup (model, type, x, y, z, virtualworld);
	if (pickupid != -1)
	{
	    DOB::SetBit (JB::StaticPickup, pickupid, false);
	    if (JB::PickupCount < MAX_PICKUPS)
			JB::PickupList [JB::PickupCount++] = pickupid;
	    JB::PickupPos [pickupid][0] = x;
		JB::PickupPos [pickupid][1] = y;
		JB::PickupPos [pickupid][2] = z;
	}
	return pickupid;
}

PUBLIC: JB::DestroyPickup (pickupid)
{
	if (pickupid >= 0 && pickupid < MAX_PICKUPS && !DOB::GetBit (JB::StaticPickup, pickupid) && DestroyPickup (pickupid))
	{
        DOB::SetBit (JB::StaticPickup, pickupid, false);
        for (new i = 0; i < JB::PickupCount; ++i)
        {
            if (JB::PickupList [i] == pickupid)
            {
                JB::PickupList [i] = JB::PickupList [--JB::PickupCount];
                break;
            }
        }
		JB::PickupType {pickupid} = PICKUP_TYPE_NONE;
		return 1;
	}
	return 0;
}

PUBLIC: JB::SetVehicleVelocity (vehicleid, Float: x, Float: y, Float: z)
{
	if (vehicleid != INVALID_VEHICLE_ID)
	{
		new tspeed = JB::Speed(x, y, z, 110.0, JB::Variables [SPEED_3D]);
			
		if (JB::Variables [MAX_SPEED] && tspeed >= JB::Variables [MAX_SPEED])
		{
			JB::LogEx ("Could not set velocity for vehicle %d because max speed is %d KM/H. (%d KM/H blocked)", vehicleid, JB::Variables [MAX_SPEED], tspeed);
			return 0;
		}
		return SetVehicleVelocity (vehicleid, x, y, z);
	}
	return 0;
}

PUBLIC: JB::SetPlayerSpecialAction (playerid, actionid)
{
	if (IsPlayerConnected (playerid))
	{
		if (actionid == SPECIAL_ACTION_USEJETPACK && JB::Variables [JETPACK] && !JB::IsPlayerAdmin (playerid))
		{
			JB::LogEx ("Could not give '%s' a jetpack because it's forbidden.", JB::PlayerInfo [playerid][JB::pName]);
			return 0;
		}

		return SetPlayerSpecialAction (playerid, actionid);
	}
	return 0;
}

PUBLIC: JB::PutPlayerInVehicle (playerid, vehicleid, seatid)
{
	if (IsPlayerConnected (playerid) && vehicleid != INVALID_VEHICLE_ID)
	{
		if (PutPlayerInVehicle (playerid, vehicleid, seatid))
		{
		    SetSyncTime (playerid, SYNC_TYPE_POS);
			JB::PlayerInfo [playerid][JB::pLastVehicle] = vehicleid;
			JB::PlayerInfo [playerid][JB::pVehicleEntered] = vehicleid;
 			return 1;
		}
	}
	return 0;
}

PUBLIC: JB::GivePlayerMoney (playerid, money)
{
	if (IsPlayerConnected (playerid))
	{
		GivePlayerMoney (playerid, money);
		JB::PlayerInfo [playerid][JB::pMoney] += money;
		return 1;
	}
	return 0;
}

PUBLIC: JB::ResetPlayerMoney (playerid)
{
	if (IsPlayerConnected (playerid))
	{
		ResetPlayerMoney (playerid);
		JB::PlayerInfo [playerid][JB::pMoney] = 0;
		return 1;
	}
	return 0;
}

PUBLIC: JB::GetPlayerMoney (playerid)
{
	if (IsPlayerConnected (playerid))
	{
	    if (JB::Variables [MONEY_HACK])
	        return min (GetPlayerMoney (playerid), JB::PlayerInfo [playerid][JB::pMoney]);
		else
			return GetPlayerMoney (playerid);
	}
	return 0;
}

PUBLIC: JB::SetPlayerMoney (playerid, money)
{
	if (IsPlayerConnected (playerid))
	{
		ResetPlayerMoney (playerid);
		GivePlayerMoney (playerid, money);
		JB::PlayerInfo [playerid][JB::pMoney] = money;
		return 1;
	}
	return 0;
}

PRIVATE: SyncMoney_SS (playerid)
{
	if (IsPlayerConnected (playerid))
	{
		ResetPlayerMoney (playerid);
		GivePlayerMoney (playerid, JB::PlayerInfo [playerid][JB::pMoney]);
		return 1;
	}
	return 0;
}

PRIVATE: SyncMoney_CS (playerid)
{
	if (IsPlayerConnected (playerid))
	{
		JB::PlayerInfo [playerid][JB::pMoney] = GetPlayerMoney (playerid);
		return 1;
	}
	return 0;
}

PUBLIC: JB::SetPlayerPos (playerid, Float: x, Float: y, Float: z)
{
	if (IsPlayerConnected (playerid))
	{
		if (SetPlayerPos (playerid, x, y, z))
		{
			JB::PlayerInfo [playerid][JB::pCurrentPos][0] = x;
			JB::PlayerInfo [playerid][JB::pCurrentPos][1] = y;
			JB::PlayerInfo [playerid][JB::pCurrentPos][2] = z;
			JB::PlayerInfo [playerid][JB::pSetPos][0] = x;
			JB::PlayerInfo [playerid][JB::pSetPos][1] = y;
			JB::PlayerInfo [playerid][JB::pSetPos][2] = z;
   			SetSyncTime (playerid, SYNC_TYPE_POS);
			return 1;
		}
	}
	return 0;
}

PUBLIC: JB::SetPlayerPosFindZ (playerid, Float: x, Float: y, Float: z)
{
	if (IsPlayerConnected (playerid))
	{
		if (SetPlayerPosFindZ (playerid, x, y, z))
		{
			JB::PlayerInfo [playerid][JB::pCurrentPos][0] = x;
			JB::PlayerInfo [playerid][JB::pCurrentPos][1] = y;
			JB::PlayerInfo [playerid][JB::pCurrentPos][2] = z;
			JB::PlayerInfo [playerid][JB::pSetPos][0] = x;
			JB::PlayerInfo [playerid][JB::pSetPos][1] = y;
			JB::PlayerInfo [playerid][JB::pSetPos][2] = z;
			SetSyncTime (playerid, SYNC_TYPE_POS);
			return 1;
		}
	}
	return 0;
}

PUBLIC: JB::SetVehiclePos (vehicleid, Float: x, Float: y, Float: z)
{
	if (vehicleid != INVALID_VEHICLE_ID)
	{
	    JB::VehiclePos [vehicleid][0] = x;
	    JB::VehiclePos [vehicleid][1] = y;
	    JB::VehiclePos [vehicleid][2] = z;
		if (SetVehiclePos (vehicleid, x, y, z))
		{
			foreach(Player, i)
			{
				if (GetPlayerVehicleID (i) == vehicleid)
				{
					JB::PlayerInfo [i][JB::pCurrentPos][0] = x;
					JB::PlayerInfo [i][JB::pCurrentPos][1] = y;
					JB::PlayerInfo [i][JB::pCurrentPos][2] = z;
					JB::PlayerInfo [i][JB::pSetPos][0] = x;
					JB::PlayerInfo [i][JB::pSetPos][1] = y;
					JB::PlayerInfo [i][JB::pSetPos][2] = z;
					SetSyncTime (i, SYNC_TYPE_POS);
				}
			}
			return 1;
		}
	}
	return 0;
}

PUBLIC: JB::GivePlayerWeapon (playerid, weaponid, ammo)
{
	if (!IsPlayerConnected (playerid))
		return 0;

	if (!IsWeaponForbiddenForPlayer (playerid, weaponid) || JB::IsPlayerAdmin (playerid))
	{
	    JB::PlayerInfo [playerid][JB::pLastBoughtWeapon] = 0;
 		WeaponUpdate (playerid, weaponid, ammo);
		return GivePlayerWeapon (playerid, weaponid, ammo);
	}
	
	new weapon [32];
		
	GetWeaponName (weaponid, weapon, sizeof (weapon));
	JB::LogEx ("Could not give '%s' weapon %s (%d) because it is forbidden!", JB::PlayerInfo [playerid][JB::pName], weapon, weaponid);
	return 0;
}

PUBLIC: JB::ResetPlayerWeapons (playerid)
{
	new i;
		
	for (i = 0; i < MAX_WEAPON_SLOTS; ++i)
	{
		JB::PlayerWeaponAmmo [playerid][i] = 0;
		JB::PlayerWeapons [playerid]{i} = 0;
	}
	for (; i < 47; ++i)
		JB::PlayerWeaponAmmo [playerid][i] = 0;
		
    SetSyncTime (playerid, SYNC_TYPE_WEAPONS);
	return ResetPlayerWeapons (playerid);
}

PRIVATE: SyncWeapons_CS (playerid, bool: buyableonly = false)//ClientSide
{
	if (IsPlayerConnected (playerid))
	{
		new
			i,
			weapons,
			ammo;
			
		for (i = 0; i < 47; ++i)
			JB::PlayerWeaponAmmo [playerid][i] = 0;

		for (i = 0; i < MAX_WEAPON_SLOTS; ++i)
		{
			GetPlayerWeaponData (playerid, i, weapons, ammo);
			if (weapons == 0 || !buyableonly ||  AmmuNationInfo [weapons][0] > 0)
			{
				JB::PlayerWeapons [playerid]{i} = weapons;
				JB::PlayerWeaponAmmo [playerid][JB::PlayerWeapons [playerid]{i}] = ammo;
			}
		}
		return 1;
	}
	return 0;
}

PRIVATE: SyncWeapons_SS (playerid)//ServerSide
{
	if (IsPlayerConnected (playerid))
	{
		SetSyncTime (playerid, SYNC_TYPE_WEAPONS);
		ResetPlayerWeapons (playerid);
		for (new i = 0; i < MAX_WEAPON_SLOTS; ++i)
			GivePlayerWeapon (playerid, JB::PlayerWeapons [playerid]{i}, JB::PlayerWeaponAmmo [playerid][JB::PlayerWeapons [playerid]{i}]);
		return 1;
	}
	return 0;
}

PRIVATE: WeaponUpdate (playerid, weaponid, ammo)
{
	if (!IsPlayerConnected (playerid) || weaponid < 0 || weaponid >= MAX_WEAPONS)
		return 0;

	SetSyncTime (playerid, SYNC_TYPE_WEAPONS);
	JB::PlayerWeapons [playerid]{GetWeaponSlot (weaponid)} = weaponid;
	JB::PlayerWeaponAmmo [playerid][weaponid] += ammo;
	if (JB::PlayerWeaponAmmo [playerid][weaponid] > 65535)
		JB::PlayerWeaponAmmo [playerid][weaponid] = 65535;

	switch (weaponid)
	{
		case 22, 23:
		{
			JB::PlayerWeaponAmmo [playerid][22] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][23] = JB::PlayerWeaponAmmo [playerid][weaponid];
		}

		case 25 .. 27:
		{
			JB::PlayerWeaponAmmo [playerid][25] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][26] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][27] = JB::PlayerWeaponAmmo [playerid][weaponid];
		}

		case 28, 29, 32:
		{
			JB::PlayerWeaponAmmo [playerid][28] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][29] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][32] = JB::PlayerWeaponAmmo [playerid][weaponid];
		}

		case 30, 31:
		{
			JB::PlayerWeaponAmmo [playerid][30] = JB::PlayerWeaponAmmo [playerid][weaponid];
			JB::PlayerWeaponAmmo [playerid][31] = JB::PlayerWeaponAmmo [playerid][weaponid];
		}
	}
	return 1;
}

PUBLIC: JB::SetPlayerHealth (playerid, Float: health)
{
	if (!IsPlayerConnected (playerid))
		return 0;

	new Float: tmp_health = health;
		
	if (tmp_health < 0.0)
		tmp_health = 0.0;
	else if (tmp_health > 100.0 && JB::Variables [HEALTH_HACK])
		tmp_health = 100.0;
		
	JB::PlayerInfo [playerid][JB::pHealth] = tmp_health;
	SetSyncTime (playerid, SYNC_TYPE_HEALTH);
	return SetPlayerHealth (playerid, tmp_health);
}

PUBLIC: JB::SetPlayerArmour (playerid, Float: armour)
{
	if (!IsPlayerConnected (playerid))
		return 0;

	new Float: tmp_armour = armour;
		
	if (tmp_armour < 0.0)
		tmp_armour = 0.0;
	else if (tmp_armour > 100.0 && JB::Variables [ARMOUR_HACK])
		tmp_armour = 100.0;
	JB::PlayerInfo [playerid][JB::pArmour] = tmp_armour;
	SetSyncTime (playerid, SYNC_TYPE_ARMOUR);
	return SetPlayerArmour (playerid, tmp_armour);
}

PUBLIC: JB::AddStaticVehicle (modelid, Float: spawn_x, Float: spawn_y, Float: spawn_z, Float: z_angle, color1, color2)
{
	new vehicleid = AddStaticVehicle (modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2);
    if (vehicleid != INVALID_VEHICLE_ID)
	{
	    JB::VehiclePos [vehicleid][0] = spawn_x;
	    JB::VehiclePos [vehicleid][1] = spawn_y;
	    JB::VehiclePos [vehicleid][2] = spawn_z;
	    for (new i = 0; i < MAX_COMPONENT_SLOTS; ++i)
	    	JB::VehicleComponents [vehicleid]{i} = 0;
	}
	return vehicleid;
}

PUBLIC: JB::AddVehicleComponent (vehicleid, componentid)
{
	new slot = GetVehicleComponentType (componentid);
	if (slot != -1)
	{
	    AddVehicleComponent (vehicleid, componentid);
	    JB::VehicleComponents [vehicleid]{slot} = componentid - 999;
	    return 1;
	}
	return 0;
}

PUBLIC: JB::RemoveVehicleComponent (vehicleid, componentid)
{
	new slot = GetVehicleComponentType (componentid);
	if (slot != -1 && GetVehicleComponentInSlot (vehicleid, slot) == componentid)
	{
	    RemoveVehicleComponent (vehicleid, componentid);
	    JB::VehicleComponents [vehicleid]{slot} = 0;
	    return 1;
	}
	return 0;
}

PUBLIC: JB::RepairVehicle (vehicleid)
{
    if (vehicleid == INVALID_VEHICLE_ID)
	    return 0;
	    
    foreach(Player, i)
	{
	    if (GetPlayerVehicleID (i) == vehicleid)
	    {
	        JB::PlayerInfo [i][JB::pVehicleHealth] = 1000.0;
	        SetSyncTime (i, SYNC_TYPE_VEHICLE);
		}
	}
	
	return RepairVehicle (vehicleid);
}

PUBLIC: JB::SetVehicleHealth (vehicleid, Float: health)
{
	if (vehicleid == INVALID_VEHICLE_ID)
	    return 0;
	    
	new Float: tmp_health = health;
		
	if (tmp_health < 0.0)
		tmp_health = 0.0;
	else if (tmp_health > 1000.0 && JB::Variables [TANK_MODE])
		tmp_health = 1000.0;

	foreach(Player, i)
	{
	    if (GetPlayerVehicleID (i) == vehicleid)
	    {
	        JB::PlayerInfo [i][JB::pVehicleHealth] = tmp_health;
	        SetSyncTime (i, SYNC_TYPE_VEHICLE);
		}
	}
	        
	return SetVehicleHealth (vehicleid, tmp_health);
}

PUBLIC: JB::TogglePlayerControllable (playerid, toggle)
{
	DOB::SetBit (JB::Freezed, playerid, toggle != 0);
	if (!toggle && IsPlayerInAnyVehicle (playerid))
		SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
	return TogglePlayerControllable (playerid, toggle);
}

PUBLIC: JB::TogglePlayerSpectating (playerid, toggle)
{
	DOB::SetBit (JB::Spectating, playerid, toggle != 0);
	return TogglePlayerSpectating (playerid, toggle);
}

PUBLIC: JB::SetPlayerSpawnKillProtected (playerid, set)
{
	if (IsPlayerConnected (playerid))
	{
		if (set)
			JB::PlayerInfo [playerid][JB::pSpawnKillProtected] = JB::Variables [SPAWN_TIME];
		else
			JB::PlayerInfo [playerid][JB::pSpawnKillProtected] = 0;
		return 1;
	}
	return 0;
}

PUBLIC: JB::SetPlayerRaceCheckpoint (playerid, type, Float: x, Float: y, Float: z, Float: nextx, Float: nexty, Float: nextz, Float: size)
{
	if (IsPlayerInRangeOfPoint (playerid, (size + 5.0), x, y, z))//Prevent that spawning a checkpoint near a player counts as checkpoint teleport.
		SetSyncTime (playerid, SYNC_TYPE_POS);
	return SetPlayerRaceCheckpoint (playerid, type, x, y, z, nextx, nexty, nextz, size);
}

//==============================================================================

PUBLIC: VerifyNoReload (playerid)
{
	if (JB::PlayerInfo [playerid][JB::pCurrentState] == PLAYER_STATE_ONFOOT && GetPlayerWeapon (playerid) == 26
		&& HasTimePassed (JB::PlayerInfo [playerid][JB::pLastSawnOffShot], 10000)
		&& !HasTimePassed (JB::PlayerInfo [playerid][JB::pLastUpdate], 1000))
	{
		JB::Kick (playerid, "Not reloading (Sawn-off Shotgun) [Code 1]");
		return 1;
	}
	return 0;
}

PUBLIC: JB::AntiBugKill (playerid)
{
	if (IsPlayerConnected (playerid) && !IsPlayerNPC (playerid) && IsPlayerInValidState (playerid) && !DOB::GetBit (JB::AntiBugKilled, playerid)) //!JB::PlayerInfo [playerid][JB::pAntiBugKilled])
	{
		new
			Float: x,
			Float: y,
			Float: z,
			Float: health,
			Float: armour,
			Float: angle,
			weapons [13][2],
			varname [32],
			hour,
			minute;
			
		DOB::SetBit (JB::AntiBugKilled, playerid, true);
		//JB::PlayerInfo [playerid][JB::pAntiBugKilled] = true;
		GetPlayerPos (playerid, x, y, z);
		GetPlayerFacingAngle (playerid, angle);
		GetPlayerHealth (playerid, health);
		GetPlayerArmour (playerid, armour);
		for (new i = 0; i < MAX_WEAPON_SLOTS; ++i)
		{
			GetPlayerWeaponData (playerid, i, weapons [i][0], weapons [i][1]);
			format (varname, sizeof (varname), "JB_ABK_Weapon%02d", i);
			SetPVarInt (playerid, varname, weapons [i][0]);
			format (varname, sizeof (varname), "JB_ABK_Ammo%02d", i);
			SetPVarInt (playerid, varname, weapons [i][1]);
		}

		SetPVarFloat (playerid, "JB_ABK_PosX", x);
	 	SetPVarFloat (playerid, "JB_ABK_PosY", y);
	 	SetPVarFloat (playerid, "JB_ABK_PosZ", z);
	 	SetPVarFloat (playerid, "JB_ABK_Angle", angle);
	 	SetPVarFloat (playerid, "JB_ABK_Health", health);
	 	SetPVarFloat (playerid, "JB_ABK_Armour", armour);
	 	SetPVarInt (playerid, "JB_ABK_World", GetPlayerVirtualWorld (playerid));
	 	SetPVarInt (playerid, "JB_ABK_Interior", GetPlayerInterior (playerid));
	 	SetPVarInt (playerid, "JB_ABK_VehicleID", GetPlayerVehicleID (playerid));
	 	SetPVarInt (playerid, "JB_ABK_Seat", GetPlayerVehicleSeat (playerid));
	 	GetPlayerTime (playerid, hour, minute);
	 	SetPVarInt (playerid, "JB_ABK_Hour", hour);
	 	SetPVarInt (playerid, "JB_ABK_Minute", minute);

		JB::ResetPlayerWeapons (playerid);
		JB::SetPlayerHealth (playerid, 0.0);
		JB::SetPlayerArmour (playerid, 0.0);
		return 1;
	}
	return 0;
}

PRIVATE: JB::MutePlayer (playerid, time, reason [])//Time is seconds.
{
	if (IsPlayerConnected (playerid) && time)
	{
		JB::PlayerInfo [playerid][JB::pMuted] = time;
		JB::LogEx ("%s ha sido silenciado por %d segundo(s) por hacer %s.", JB::PlayerInfo [playerid][JB::pName], time, reason);
		JB::SendFormattedMessageToAll (JB_RED, "[Anti-Cheat]{FFFFFF} Jugador silenciado '%s' (%d) por %d segundo(s). {FF0000}Razón: %s", JB::PlayerInfo [playerid][JB::pName], playerid, time, reason);
		return 1;
	}
	return 0;
}

PRIVATE: JB::Kick (playerid, reason [])
{
	if (IsPlayerConnected (playerid) && !IsPlayerNPC (playerid))
	{
		if (JB::Variables [DISPLAY_TEXTDRAW])
            DisplayKickBanText (playerid, reason, false);
		else
		{
			new string [128];
				
			format (string, sizeof (string), "~r~Notificacion de Kick: ~n~%s", reason);
			GameTextForPlayer (playerid, string, 60000, 4);
		}

		TogglePlayerControllable (playerid, false);
		SetCameraBehindPlayer (playerid);
		JB::SendFormattedMessageToAll (JB_RED, "[Anti-Cheat]{FFFFFF} El jugador '%s' ha sido expulsado. {FF0000}Razón: %s", JB::PlayerInfo [playerid][JB::pName], reason);
		JB::LogEx ("%s (%s) ha sido expulsado por %s.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], reason);
		CallRemoteFunction ("OnJunkBusterKick", "is", playerid, reason);
		Kick (playerid);
		return 1;
	}
	return 0;
}

PRIVATE: JB::Ban (playerid, reason [])
{
	if (IsPlayerConnected (playerid) && !IsPlayerNPC (playerid))
	{
	    if (JB::Variables [DISPLAY_TEXTDRAW])
            DisplayKickBanText (playerid, reason, true);
		else
		{
			new string [128];
				
			format (string, sizeof (string), "~r~Notificacion Ban: ~n~%s", reason);
			GameTextForPlayer (playerid, string, 60000, 4);
		}

		TogglePlayerControllable (playerid, false);
		SetCameraBehindPlayer (playerid);
		JB::SendFormattedMessageToAll (JB_RED, "[Anti-Cheat]{FFFFFF} EL jugador '%s' ha sido baneado. {FF0000}Razón: %s", JB::PlayerInfo [playerid][JB::pName], reason);
		JB::LogEx ("%s (%s) has been banned for %s.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], reason);
		CallRemoteFunction ("OnJunkBusterBan", "is", playerid, reason);
		BanEx (playerid, reason);
		return 1;
	}
	return 0;
}

PRIVATE: DisplayKickBanText (playerid, reason [], bool: ban)
{
	if (IsPlayerConnected (playerid))
	{
		new string [256];
			
		if (JB::KickBanTitle == Text: INVALID_TEXT_DRAW)
		{
	        JB::KickBanTitle = TextDrawCreate (320.000000, 100.000000, ban ? ("Anti-Cheat~n~Informacion Ban~n~~n~~n~~n~~n~~n~~n~~n~~n~") : ("Anti-Cheat~n~Informacion Kick~n~~n~~n~~n~~n~~n~~n~~n~~n~"));
			TextDrawAlignment (JB::KickBanTitle, 2);
			TextDrawBackgroundColor (JB::KickBanTitle, 255);
			TextDrawFont (JB::KickBanTitle, 2);
			TextDrawLetterSize (JB::KickBanTitle, 0.500000, 2.999999);
			TextDrawColor (JB::KickBanTitle, -16776961);
			TextDrawSetOutline (JB::KickBanTitle, 1);
			TextDrawSetProportional (JB::KickBanTitle, 1);
			TextDrawUseBox (JB::KickBanTitle, 1);
			TextDrawBoxColor (JB::KickBanTitle, 96);
			TextDrawTextSize (JB::KickBanTitle, 7.000000, 240.000000);
		}
		else
		    TextDrawSetString (JB::KickBanTitle, ban ? ("Anti-Cheat~n~Informacion Ban~n~~n~~n~~n~~n~~n~~n~~n~~n~") : ("Anti-Cheat~n~Informacion Kick~n~~n~~n~~n~~n~~n~~n~~n~~n~"));
		TextDrawShowForPlayer (playerid, JB::KickBanTitle);

		if (JB::KickBanInfo == Text: INVALID_TEXT_DRAW)
		{
		    JB::KickBanInfo = TextDrawCreate (202.000000, 155.000000, "_");
			TextDrawBackgroundColor (JB::KickBanInfo, 255);
			TextDrawFont (JB::KickBanInfo, 1);
			TextDrawLetterSize (JB::KickBanInfo, 0.419999, 1.899999);
			TextDrawColor (JB::KickBanInfo, -1);
			TextDrawSetOutline (JB::KickBanInfo, 0);
			TextDrawSetProportional (JB::KickBanInfo, 1);
			TextDrawSetShadow (JB::KickBanInfo, 1);
		}
		format (string, sizeof (string), "~p~Nombre:~n~~w~%s~n~~p~Fecha:~n~~w~%s~n~~p~Hora:~n~~w~%s~n~~p~IP:~n~~w~%s~n~~p~Razon:~n~~w~%s", JB::PlayerInfo [playerid][JB::pName], JB::GetDate (), JB::GetTime (),
			JB::PlayerInfo [playerid][JB::pIp], reason);
		TextDrawSetString (JB::KickBanInfo, string);
		TextDrawShowForPlayer (playerid, JB::KickBanInfo);

		if (JB::KickBanHelp == Text: INVALID_TEXT_DRAW)
		{
		    JB::KickBanHelp = TextDrawCreate (320.000000, 330.000000, "_");
			TextDrawAlignment (JB::KickBanHelp, 2);
			TextDrawBackgroundColor (JB::KickBanHelp, 255);
			TextDrawFont (JB::KickBanHelp, 1);
			TextDrawLetterSize (JB::KickBanHelp, 0.319999, 1.399999);
			TextDrawColor (JB::KickBanHelp, -1);
			TextDrawSetOutline (JB::KickBanHelp, 0);
			TextDrawSetProportional (JB::KickBanHelp, 1);
			TextDrawSetShadow (JB::KickBanHelp, 1);
			TextDrawUseBox (JB::KickBanHelp, 1);
			TextDrawBoxColor (JB::KickBanHelp, 0);
			TextDrawTextSize (JB::KickBanHelp, 2.000000, 243.000000);
		}
		format (string, sizeof (string), "~g~Si ha sido injustamente %s, Pulse ~b~F8~g~ para hacer una captura de pantalla, reporta en ~r~creativeroleplay.xyz~g~.", ban ? ("banned") : ("kicked"), JB::Homepage);
		TextDrawSetString (JB::KickBanHelp, string);
		TextDrawShowForPlayer (playerid, JB::KickBanHelp);
		return 1;
	}
	return 0;
}

PRIVATE: JB::Log (log [])
{
	printf ("[junkbuster] %s", log);
	new
		string [256],
		File: f = fopen (JB_LOG_FILE, io_append);

	format (string, sizeof (string), "%s | %s | %s\r\n", JB::GetDate (), JB::GetTime (), log);
	fwrite (f, string);
	return fclose (f);
}

PUBLIC: JunkBusterChrome (playerid, comment [])
{
	if (IsPlayerConnected (playerid))
	{
		JB::LogEx ("Executing JunkBuster Chrome for player '%s'.", JB::PlayerInfo [playerid][JB::pName]);
		new
			string [256],
			string2 [64],
			Float: fvar [9],
			ivar [5],
			File: f = fopen (JB_CHROME_FILE, io_append);

		format (string, sizeof (string), "[%s, %d]\r\nComment: %s\r\nDate: %s\r\nTime: %s\r\n", JB::PlayerInfo [playerid][JB::pName], playerid, comment, JB::GetDate (), JB::GetTime ());
		fwrite (f, string);
		format (string, sizeof (string), "IP: %s\r\nPing: %d\r\n", JB::PlayerInfo [playerid][JB::pIp], playerid, GetPlayerPing (playerid));
		fwrite (f, string);
		#if defined gpci
			gpci (playerid, string, sizeof (string));
			format (string, sizeof (string), "gpci: %s\r\n", string);
			fwrite (f, string);
		#endif
		GetPlayerPos (playerid, fvar [0], fvar [1], fvar [2]);
		GetPlayerFacingAngle (playerid, fvar [3]);
		format (string, sizeof (string), "Coordinates: %f %f %f %f %d %d\r\n", fvar [0], fvar [1], fvar [2], fvar [3], GetPlayerInterior (playerid), GetPlayerVirtualWorld (playerid));
		fwrite (f, string);
		GetPlayerHealth (playerid, fvar [0]);
		GetPlayerArmour (playerid, fvar [1]);
		string [0] = string2 [0] = '\0';
		ivar [0] = GetPlayerAnimationIndex (playerid);
		GetAnimationName (ivar [0], string, sizeof (string), string2, sizeof (string2));
		format (string, sizeof (string), "State: %d %f %f %d %s %s\r\n", JB::PlayerInfo [playerid][JB::pCurrentState], fvar [0], fvar [1], ivar [0], string, string2);
		fwrite (f, string);
		GetPlayerVelocity (playerid, fvar [0], fvar [1], fvar [2]);
		format (string, sizeof (string), "Speed: %d %d %f %f %f\r\nArmed weapon: %d %d\r\nColor: 0x%x\r\n", JB::GetPlayerSpeed (playerid, true), JB::GetPlayerSpeed (playerid, false), fvar [0], fvar [1], fvar [2],
			GetPlayerWeapon (playerid), GetPlayerAmmo (playerid), GetPlayerColor (playerid));
		fwrite (f, string);
		GetPlayerTime (playerid, ivar [0], ivar [1]);
		format (string, sizeof (string), "Money: %d %d\r\nScore: %d\r\nSkin: %d\r\nWanted level: %d\r\nDrunk level: %d\r\nPlayer time: %02d:%02d\r\n", GetPlayerMoney (playerid), JB::PlayerInfo [playerid][JB::pMoney], GetPlayerScore (playerid), GetPlayerSkin (playerid),
			GetPlayerWantedLevel (playerid), GetPlayerDrunkLevel (playerid), ivar [0], ivar [1]);
		fwrite (f, string);
		GetPlayerKeys (playerid, ivar [0], ivar [1], ivar [2]);
		GetPlayerCameraPos (playerid, fvar [0], fvar [1], fvar [2]);
		GetPlayerCameraFrontVector (playerid, fvar [3], fvar [4], fvar [5]);
		format (string, sizeof (string), "Keys: 0x%x 0x%x 0x%x\r\nCamera: %f %f %f %f %f %f\r\nSpecial action: %d\r\n", ivar [0], ivar [1], ivar [2], fvar [0], fvar [1], fvar [2], fvar [3], fvar [4], fvar [5], GetPlayerSpecialAction (playerid));
		fwrite (f, string);
		string = "Weapons:";
		for (new i = 0; i < MAX_WEAPON_SLOTS; ++i)
		{
		    GetPlayerWeaponData (playerid, i, ivar [0], ivar [1]);
		    format (string, sizeof (string), "%s %d %d", string, ivar [0], ivar [1]);
		}
		strcat (string, "\r\n");
		fwrite (f, string);
		ivar [0] = GetPlayerVehicleID (playerid);
		if (IsPlayerInAnyVehicle (playerid))
		{
			GetVehicleVelocity (ivar [0], fvar [0], fvar [1], fvar [2]);
			GetVehicleZAngle (ivar [0], fvar [3]);
			GetVehicleRotationQuat (ivar [0], fvar [4], fvar [5], fvar [6], fvar [7]);
			GetVehicleHealth (ivar [0], fvar [8]);
			GetVehicleDamageStatus (ivar [0], ivar [1], ivar [2], ivar [3], ivar [4]);
			format (string, sizeof (string), "Vehicle: %d %d %s %f %f %f %f %f %f %f %f %f 0b%b 0b%b 0b%b 0b%b %d\r\n", ivar [0], GetVehicleModel (ivar [0]), JB::GetVehicleName (ivar [0]),
				fvar [0], fvar [1], fvar [2], fvar [3], fvar [4], fvar [5], fvar [6], fvar [7],
			    fvar [8], ivar [1], ivar [2], ivar [3], ivar [4], GetVehicleVirtualWorld (ivar [0]));
			fwrite (f, string);
			string = "Vehicle components:";
			for (new i = 0; i < 14; ++i)
			{
			    ivar [1] = GetVehicleComponentInSlot (ivar [0], i);
			    format (string, sizeof (string), "%s %d %d", string, ivar [1], GetVehicleComponentType (ivar [1]));
			}
			strcat (string, "\r\n");
			fwrite (f, string);
		}
		else
		    fwrite (f, "Vehicle: None\r\nVehicle components: None\r\n");
		fwrite (f, "\r\n");
		return fclose (f);
	}
	return 0;
}

//==============================================================================

PRIVATE: IsCheatPosition (playerid)//Teleporting to these locations is always cheating!
{
	for (new i = 0; i < sizeof (CheatPositions); ++i)
		if (IsPlayerInRangeOfPoint (playerid, 5.0, CheatPositions [i][0], CheatPositions [i][1], CheatPositions [i][2]))
			return true;
	return false;
}

PRIVATE: IsPickupPosition (playerid)
{
	for (new i = 0; i < JB::PickupCount; ++i)
	    if (IsPlayerInRangeOfPoint (playerid, 7.0, JB::PickupPos [JB::PickupList [i]][0], JB::PickupPos [JB::PickupList [i]][1], JB::PickupPos [JB::PickupList [i]][2]))
	        return true;
	return false;
}

PRIVATE: IsArmedVehicle (vehicleid)
{
	new m = GetVehicleModel (vehicleid);
		
	for (new i = 0; i < sizeof (JB::ArmedVehicles); ++i)
	    if (m == JB::ArmedVehicles [i])
	        return true;
	return false;
}

PRIVATE: IsPlayerInPlane (playerid)
{
	new m = GetVehicleModel (GetPlayerVehicleID (playerid));
		
	for (new i = 0; i < sizeof (JB::Planes); ++i)
		if (m == JB::Planes [i])
			return true;
	return false;
}

PRIVATE: IsPlayerInPayNSpray (playerid)
{
    for (new i = 0; i < sizeof (JB::PayNSpray); ++i)
		if (IsPlayerInRangeOfPoint (playerid, 10.0, JB::PayNSpray [i][0], JB::PayNSpray [i][1], JB::PayNSpray [i][2]))
			return true;
	return false;
}

PRIVATE: IsPlayerBuyingInAmmuNation (playerid)
{
    if (GetPlayerInterior (playerid) > 0)
	{
		for (new i = 0; i < sizeof (AmmuNations); ++i)
			if (IsPlayerInRangeOfPoint (playerid, 2.5, AmmuNations [i][0], AmmuNations [i][1], AmmuNations [i][2]))
				return true;
	}
	return false;
}

PRIVATE: IsPlayerBuyingInRestaurant (playerid)
{
    if (GetPlayerInterior (playerid) > 0)
	{
		for (new i = 0; i < sizeof (Restaurants); ++i)
			if (IsPlayerInRangeOfPoint (playerid, 2.5, Restaurants [i][0], Restaurants [i][1], Restaurants [i][2]))
				return true;
	}
	return false;
}

PRIVATE: IsPlayerBuyingInShop (playerid)
	return (IsPlayerBuyingInAmmuNation (playerid) || IsPlayerBuyingInRestaurant (playerid));

PRIVATE: IsPlayerNearVendingMachine (playerid)
{
	for (new i = 0; i < sizeof (JB::VendingMachines); ++i)
		if (IsPlayerInRangeOfPoint (playerid, 2.5, JB::VendingMachines [i][0], JB::VendingMachines [i][1], JB::VendingMachines [i][2]))
			return true;
	return false;
}

PRIVATE: IsPlayerInValidState (playerid)
{
	if (JB::PlayerInfo [playerid][JB::pCurrentState] > 0 && JB::PlayerInfo [playerid][JB::pCurrentState] <= 6)
		return true;
	return false;
}

PRIVATE: SetSyncTime (playerid, synctype, base = 3)
{
	if (!IsPlayerConnected (playerid) || synctype < 0 || synctype >= MAX_SYNC_TYPES)
	    return 0;

    JB::SyncInfo [playerid][synctype][JB::sSyncTime] = base;
	JB::SyncInfo [playerid][synctype][JB::sLastSyncUpdate] = GetTickCount ();
	return 1;
}

PRIVATE: AdvertisementCheck (text [])
{
	if (!isnull (text))
	{
	    new
			idx,
			i,
			ipstring [128],
			string [128],
			len = strlen (text);

		for (i = 0; i < len; ++i)
			if (text [i] != ' ')
			    string [idx++] = text [i];

		if (!(len = strlen (string)))
		    return false;

		if (!strfind (string, "www.", false) || !strfind (string, "http://", false) || !strfind (string, ".com", false) || !strfind (string, ".net", false)
			|| !strfind (string, ".de", false) || !strfind (string, ".org", false))
			return true;

		// Check for an IP.
		for (i = 0, idx = 0; i < len; ++i)
		{
		    if (string [i] == ':')
			{
			    ipstring [idx] = '\0';
			    if (ipstring [0] && SplitIp (ipstring) != 0xFFFFFFFF) 
					return true; // Something of the form "number1.number2.number3.number4" has been found where 0 <= number1-4 <= 255. Can it be something else than an IP?
				idx = 0;
				ipstring [0] = '\0';
			}
		    else if ('0' <= string [i] <= '9' || string [i] == '.')
		        ipstring [idx++] = string [i];
		}
		
		ipstring [idx] = '\0';
	    if (ipstring [0] && SplitIp (ipstring) != 0xFFFFFFFF)
			return true; // Something of the form "number1.number2.number3.number4" has been found where 0 <= number1-4 <= 255. Can it be something else than an IP?
	}
	return false;
}

PRIVATE: BadWordsCheck (text [])
{
	/*
		Example: The bad word is "noob". In BadWords.cfg it must be written as "nob".
		This code will prevent this word in all forms:
		 - "no.ob"
		 - "no	 ob"
		 - "nooooooooooooooooooob"
		 - etc.
	*/
	new
		c,
		string [128];
		
	for (new i = 0; i < strlen (text); ++i)
	{
		if ((text [i] >= 'a' && text [i] <= 'z') || (text [i] >= 'A' && text [i] <= 'Z'))
		{
			if (!c || (c && string [c - 1] != text [i]))
			{
				string [c] = text [i];
				c++;
			}
		}
		if (c >= sizeof (string))
			break;
	}

	for (new i = 0; i < BadWordsCount; ++i)
		if (strfind (string, BadWords [i], true) != -1)
			return true;
	return false;
}

PRIVATE: CapsLockCheck (text [])
{
	new len = strlen (text);
		
	if (len > 3)
	{
		new c;
			
		for (new i = 0; i < len; ++i)
			if (text [i] >= 'A' && text [i] <= 'Z')
				c++; //c# doesn't work! This is bu**sh*t.

		if (c)
			if (c >= (len >>> 2) * 3)
				return true;
	}
	return false;
}

PRIVATE: SingleplayerCheatCheck (string []) //Only d*mn noobs would use this. A kick is a good choice.
{
	if (strlen (string) < 6)
		return false;

	for (new i = 0; i < sizeof (SingleplayerCheats); ++i)
		if (strfind (string, SingleplayerCheats [i], true) != -1)
			return true;
	return false;
}

PUBLIC: CheckText (playerid, text []) //return 1: something forbidden found, return 0: everything OK!
{
	if (isnull (text))
	    return 0;
	    
	if (JB::Variables [ADVERTISEMENT] && !JB::IsPlayerAdmin (playerid) && AdvertisementCheck (text))
	{
		JB::Kick (playerid, "Advertisement");
		return 1;
	}

	if (JB::Variables [CAPS_LOCK] && CapsLockCheck (text))
	{
		SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are not allowed to use Caps Lock! Press [Caps Lock] to disable it.");
		return 1;
	}

	if (JB::Variables [SINGLEPLAYER_CHEATS] && SingleplayerCheatCheck (text))
	{
		JB::Kick (playerid, "Attempting to use singleplayer cheats");
		return 1;
	}

	if (JB::Variables [BAD_WORDS] && BadWordsCheck (text))
	{
		SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Una de las palabras que escribiste, se encuetra bloqueada.");
		return 1;
	}
	return 0;
}

PUBLIC: IsForbiddenWeapon (weaponid)
{
	if (weaponid && JB::Variables [WEAPON_HACK])
	{
		for (new i = 0; i < ForbiddenWeaponsCount; ++i)
			if (ForbiddenWeapons {i} == weaponid)
				return true;
	}
	return false;
}

PUBLIC: IsWeaponForbiddenForPlayer (playerid, weaponid)
{
	if (weaponid < 0 || weaponid >= MAX_WEAPONS)
		return true;

	//Forbidden for player OR forbidden for all and player isn't allowed to use it, too.
	return (DOB::GetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid) /*JB::PlayerInfo [playerid][JB::pWeaponForbidden][weaponid]*/ || (IsForbiddenWeapon (weaponid) && DOB::GetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid))); //JB::PlayerInfo [playerid][JB::pWeaponForbidden][weaponid]));
}

PUBLIC: AllowWeaponForPlayer (playerid, weaponid)
{
	if (weaponid < 0 || weaponid >= MAX_WEAPONS)
		return 0;

	if (IsPlayerConnected (playerid))
	{
	    DOB::SetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid, false);
		//JB::PlayerInfo [playerid][JB::pWeaponForbidden][weaponid] = false;
	 	return 1;
	}
	return 0;
}

PUBLIC: ForbidWeaponForPlayer (playerid, weaponid, antibugkill)
{
	if (weaponid < 0 || weaponid >= MAX_WEAPONS)
		return 0;

	if (IsPlayerConnected (playerid))
	{
		new tmpforbid = DOB::GetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid); //JB::PlayerInfo [playerid][JB::pWeaponForbidden][weaponid];
			
		DOB::SetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid, true);
		//JB::PlayerInfo [playerid][JB::pWeaponForbidden][weaponid] = true;
		if (!tmpforbid && JB::Variables [ANTI_BUG_KILL] && antibugkill)//Wasn't forbidden before and is now forbidden.
			JB::AntiBugKill (playerid); //forbidding a minigun when leaving for example a minigun deathmatch may result in a ban when this isn't used.
		return 1;
	}
	return 0;
}

PUBLIC: ResetForbiddenWeaponsForPlayer (playerid, antibugkill) // Forbid like in configuration
{
	if (IsPlayerConnected (playerid))
	{
	    new i;
	        
		for (i = 0; i < MAX_WEAPONS; ++i)
			AllowWeaponForPlayer (playerid, i);

		for (i = 0; i < ForbiddenWeaponsCount; ++i)
			ForbidWeaponForPlayer (playerid, ForbiddenWeapons {i}, antibugkill);
		return 1;
	}
	return 0;
}

PRIVATE: JunkBusterReport (playerid, report [], details [])
{
	if (IsPlayerConnected (playerid))
	{
		new string [128];
		format (string, sizeof (string), "[%s] %s (%d, %s) with %s, %s", JB::GetTime (), JB::PlayerInfo [playerid][JB::pName], playerid, JB::PlayerInfo [playerid][JB::pIp], report, details);
        strpack (JB::Reports [JB::ReportIndex], string);
		JB::ReportIndex = (JB::ReportIndex + 1) % MAX_REPORTS;
		JB::ReportCount++;
		if (JB::ReportCount > MAX_REPORTS)
		    JB::ReportCount = MAX_REPORTS;
		    
		format (string, sizeof (string), "[Anti-Cheat]{FFFFFF} %s(%d) tiene posible %s - %s.", JB::PlayerInfo [playerid][JB::pName], playerid, report, details);
		MensajeStaff(0xE00000FF, string, playerid);

		CallRemoteFunction ("OnJunkBusterReport", "iss", playerid, report, details);
		return JB::Log (string [20]);
	}
	return 0;
}

stock MensajeStaff(color, string[], playerid) {
    foreach(Player, i) {
        if(JB::IsPlayerAdmin (i) && i != playerid)
			SendClientMessage (i, color, string);
    }
    return 1;
}

PRIVATE: JB::IsPlayerAdmin (playerid)
	return (IsPlayerAdmin (playerid) || CallRemoteFunction ("IsPlayerAdminCall", "i", playerid));

/*
Put for example this into your gamemode (Godfather):

public IsPlayerAdminCall (playerid)
	return (PlayerInfo [playerid][pAdmin] >= 1);

You can link your admin system with JunkBuster,
if you create a IsPlayerAdminCall function which
fits to your script. (The example above may only work for GF!)
*/

//==============================================================================

PUBLIC: GlobalUpdate ()
{
	new
		playerlist [MAX_PLAYERS],
		players,
		reason [64],
		bool: nokeypressed,
		totalwarnings;
		
    foreach(Player, i)
    {
        if (JB::Variables [MAX_TOTAL_WARNINGS])
        {
            totalwarnings = JB::Warnings [i]{REPORT_MONEY_HACK};
			totalwarnings += JB::Warnings [i]{PAY_FOR_GUNS};
			totalwarnings += JB::Warnings [i]{TELEPORT_HACK};
			totalwarnings += JB::Warnings [i]{AIRBRAKE};
			totalwarnings += JB::Warnings [i]{MAX_SPEED};
			totalwarnings += JB::Warnings [i]{WALLRIDE};
			totalwarnings += JB::Warnings [i]{NO_RELOAD_SAWNOFF};
			totalwarnings += JB::Warnings [i]{SS_HEALTH};
			totalwarnings += JB::Warnings [i]{ACTIVE_GMC};
			totalwarnings += JB::Warnings [i]{SPAWN_VEHICLES};
			totalwarnings += JB::Warnings [i]{VEHICLE_REPAIR};
			totalwarnings += JB::Warnings [i]{NO_RELOAD};
			totalwarnings += JB::Warnings [i]{DRIVE_BY};
			totalwarnings += JB::Warnings [i]{ARMED_VEHICLES};
			totalwarnings += JB::Warnings [i]{SPAWNKILL};
			totalwarnings += JB::Warnings [i]{CAR_JACK_HACK};
			totalwarnings += JB::Warnings [i]{VEHICLE_TELEPORT};
			totalwarnings += JB::Warnings [i]{CBUG};
			totalwarnings += JB::Warnings [i]{JOYPAD};
			totalwarnings += JB::Warnings [i]{CHECKPOINT_TELEPORT};
				
			if (totalwarnings >= JB::Variables [MAX_TOTAL_WARNINGS])
			{
			    switch (JB::Variables [TOO_MANY_WARNS_ACTION])
			    {
			        case 1:
					{
					    JB::Kick (i, "Suspected as cheater/unfair player");
					    continue;
					}
					
					case 2:
					{
					    JB::Ban (i, "Suspected as cheater/unfair player");
					    continue;
					}
					
					case 3:
					{
					    TempBan (i, 1, "Suspected as cheater/unfair player");
					    continue;
					}
			    }
			}
        }
        
        if (DOB::GetBit (JB::FullyConnected, i))
        {
	        nokeypressed = (GetTickCount () - JB::PlayerInfo [i][JB::pLastKeyPressed]) >= (60000 * JB::Variables [AFK]);
	        if ((!JB::IsPlayerAdmin (i) || !JB::Variables [ADMIN_IMMUNITY]) && JB::Variables [AFK]
				&& (nokeypressed || IsPlayerInRangeOfPoint (i, 3.0, JB::PlayerInfo [i][JB::pAFKPos][0], JB::PlayerInfo [i][JB::pAFKPos][1], JB::PlayerInfo [i][JB::pAFKPos][2])))
	        {
	            JB::Warnings [i]{AFK}++;
	            if (JB::Warnings [i]{AFK} >= JB::Variables [AFK] || nokeypressed)
	            {
	                format (reason, sizeof (reason), "Idle for too long [Max %d min(s)]", JB::Variables [AFK]);
	                JB::Kick (i, reason);
	            }
	        }
			else
			{
			    JB::Warnings [i]{AFK} = 0;
				if (IsPlayerInValidState (i) && JB::Variables [ACTIVE_GMC] && !IsPlayerNPC (i) && JB::PlayerInfo [i][JB::pKillingSpree] >= 5 && !JB::IsPlayerAdmin (i) && HasTimePassed (JB::PlayerInfo [i][JB::pLastGMC], 60000 * 5))
					playerlist [players++] = i;
			}
		}
        GetPlayerPos (i, JB::PlayerInfo [i][JB::pAFKPos][0], JB::PlayerInfo [i][JB::pAFKPos][1], JB::PlayerInfo [i][JB::pAFKPos][2]);
	}
	
	if (players) // 0 when JB::Variables [ACTIVE_GMC] = 0
		JB::GodModeCheck (playerlist [random (players)]);
	return 1;
}

PUBLIC: SpamUpdate ()
{
	foreach(Player, i)
	{
		if (JB::PlayerInfo [i][JB::pMessages])
			JB::PlayerInfo [i][JB::pMessages]--;

		if (JB::PlayerInfo [i][JB::pCommands])
			JB::PlayerInfo [i][JB::pCommands]--;
	}
	return 1;
}

PUBLIC: AirbrakeCheck ()
{
	if (JB::Variables [AIRBRAKE])
	{
	    new t = GetTickCount (), reason [128], speed; // Speed in m/s
	    
	    foreach(Player, i)
	    {
	        if (!JB::SyncInfo [i][SYNC_TYPE_POS][JB::sSyncTime] && DOB::GetBit (JB::FullyConnected, i))
	        {
		        if (GetPlayerSurfingVehicleID (i) == INVALID_VEHICLE_ID && GetPlayerSurfingObjectID (i) == INVALID_OBJECT_ID && JB::GetPlayerSpeed (i, true) < 30 && (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_DRIVER || JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_ONFOOT))
		        {
					speed = floatround ((GetPlayerDistanceFromPoint (i, JB::PlayerInfo [i][JB::pOldAirbrakePos][0], JB::PlayerInfo [i][JB::pOldAirbrakePos][1], JB::PlayerInfo [i][JB::pOldAirbrakePos][2]) / float (t - JB::PlayerInfo [i][JB::pLastAirbrakeCheck])) * 1000.0);
                    GetPlayerPos (i, JB::PlayerInfo [i][JB::pOldAirbrakePos][0], JB::PlayerInfo [i][JB::pOldAirbrakePos][1], JB::PlayerInfo [i][JB::pOldAirbrakePos][2]);
					if (speed > JB::Variables [AIRBRAKE] && JB::PlayerInfo [i][JB::pLastAirbrakeSpeed] > JB::Variables [AIRBRAKE])
					{
					    JB::Warnings [i]{AIRBRAKE}++;
						if (JB::Warnings [i]{AIRBRAKE} < MAX_CHECKS)
						{
							format (reason, sizeof (reason), "height: %.2f, ~%d m/s, vehicle: %s", JB::PlayerInfo [i][JB::pOldAirbrakePos][2], speed, JB::GetVehicleName (GetPlayerVehicleID (i)));
                            JB::PlayerInfo [i][JB::pLastAirbrakeSpeed] = 0;
							JunkBusterReport (i, "airbrake", reason);
						}
						else
						{
						    if (JB::AirbrakeDetection == 1) JB::Kick (i, "Airbrake");
							else JB::Ban (i, "Airbrake");
							continue;
						}
					}
					JB::PlayerInfo [i][JB::pLastAirbrakeSpeed] = speed;
				}
				else
				{
				    GetPlayerPos (i, JB::PlayerInfo [i][JB::pOldAirbrakePos][0], JB::PlayerInfo [i][JB::pOldAirbrakePos][1], JB::PlayerInfo [i][JB::pOldAirbrakePos][2]);
				    JB::PlayerInfo [i][JB::pLastAirbrakeSpeed] = 0;
				}
			}
			else
			{
			    GetPlayerPos (i, JB::PlayerInfo [i][JB::pOldAirbrakePos][0], JB::PlayerInfo [i][JB::pOldAirbrakePos][1], JB::PlayerInfo [i][JB::pOldAirbrakePos][2]);
			    JB::PlayerInfo [i][JB::pLastAirbrakeSpeed] = 0;
			}

			JB::PlayerInfo [i][JB::pLastAirbrakeCheck] = t;
	    }
	    return 1;
	}
	return 0;
}

PUBLIC: QuickTurnCheck ()
{
	if (JB::Variables [QUICK_TURN])
	{
		new
			Float: x,
			Float: y,
			Float: z,
			speed,
			Float: angle,
			vehicleid,
			Float: ad;
			
		foreach(Player, i)
		{
			if (DOB::GetBit (JB::FullyConnected, i) && JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_DRIVER && !JB::IsPlayerAdmin (i))
			{
				vehicleid = GetPlayerVehicleID (i);
				GetVehicleVelocity (vehicleid, x, y, z);
				GetVehicleZAngle (vehicleid, angle);
				speed = JB::Speed(x, y, z, 100.0, TRUE);
				if (angle > 360.0)
					angle -= 360.0;
				else if (angle < 0.0)
					angle += 360.0;
				ad = abs(angle - JB::PlayerInfo [i][JB::pOldAngle]);

				if (speed > 15 && abs(JB::PlayerInfo [i][JB::pOldSpeed] - speed) < 25.0 && (170.0 < ad < 190.0))
					if ((x < 0.0) != (JB::PlayerInfo [i][JB::pVelocity][0] < 0.0) && (y < 0.0) != (JB::PlayerInfo [i][JB::pVelocity][1] < 0.0) && (z < 0.0) != (JB::PlayerInfo [i][JB::pVelocity][2] < 0.0))
						JB::Ban (i, "Quick turn"); //He must have used quick turn! I think there is no other way to satisfy the statements above...

				JB::PlayerInfo [i][JB::pVelocity][0] = x;
				JB::PlayerInfo [i][JB::pVelocity][1] = y;
				JB::PlayerInfo [i][JB::pVelocity][2] = z;
				JB::PlayerInfo [i][JB::pOldSpeed] = speed;
				JB::PlayerInfo [i][JB::pOldAngle] = angle;
			}
		}
		return 1;
	}
	return 0;
}

//==============================================================================
						/* MAIN FUNCTION OF ANTI-CHEAT */

PUBLIC: JunkBuster ()
{
	new
		Float: health,
		Float: armour,
		var,
		reason [64],
		ivar [4],
		Float: x,
		Float: y,
		Float: z,
		Float: rx,
		Float: ry,
		Float: rz,
		vehicleid,
		componentid,
		bool: surfing,
		bool: freezed,
		keys,
		updown,
		leftright;
		
	foreach(Player, i)
	{
		if (DOB::GetBit (JB::FullyConnected, i) && GetPlayerPos (i, x, y, z))
		{
		    vehicleid = GetPlayerVehicleID (i);
			if (vehicleid != INVALID_VEHICLE_ID)
				GetVehiclePos (vehicleid, JB::VehiclePos [vehicleid][0], JB::VehiclePos [vehicleid][1], JB::VehiclePos [vehicleid][2]);

			if (JB::PlayerInfo [i][JB::pMuted])
				JB::PlayerInfo [i][JB::pMuted]--;

			if (JB::PlayerInfo [i][JB::pSpawnKillProtected])
				JB::PlayerInfo [i][JB::pSpawnKillProtected]--;
			    
			if (JBGMC::Progress {i} != 0 && GetTickCount () > JBGMC::TimeoutTime [i])
				JBGMC::EndCheck (i, bool: IsPlayerInValidState (i));

			if (JB::Variables [MONEY_HACK])
			{
			    var = GetPlayerMoney (i);
				if (var > JB::PlayerInfo [i][JB::pMoney])
				{
				    if (JB::Variables [REPORT_MONEY_HACK] && !JB::IsPlayerAdmin (i))
				    {
                        if (!HasTimePassed (JB::PlayerInfo [i][JB::pLastUpdate], 2000))
                        {
                            JB::Warnings [i]{MONEY_HACK}++;
                            if (JB::Warnings [i]{MONEY_HACK} >= MAX_CHECKS)
                            {
                                JB::Warnings [i]{MONEY_HACK} = 0;
								JB::Warnings [i]{REPORT_MONEY_HACK}++;
								if (JB::Warnings [i]{REPORT_MONEY_HACK} >= MAX_CHECKS && JB::Variables [REPORT_MONEY_HACK] > 1)
								{
								    JB::Kick (i, "Moneyhack");
								    continue;
								}
								else
								{
	                                format (reason, sizeof (reason), "$%d expected but $%d found", JB::PlayerInfo [i][JB::pMoney], var);
									JunkBusterReport (i, "moneyhack", reason);
									// Resetting seems to be a good idea.
									ResetPlayerMoney (i);
									GivePlayerMoney (i, JB::PlayerInfo [i][JB::pMoney]);
								}
                            }
                        }
                        else
                            JB::Warnings [i]{MONEY_HACK} = 0;
				    }
				    else
				    {
					    ResetPlayerMoney (i);
						GivePlayerMoney (i, JB::PlayerInfo [i][JB::pMoney]);
					}
				}
                else
                    JB::Warnings [i]{MONEY_HACK} = 0;
			}

			if (JB::PlayerInfo [i][JB::pVendingMachineUsed])
			{
				GetPlayerHealth (i, JB::PlayerInfo [i][JB::pHealth]);
				JB::PlayerInfo [i][JB::pVendingMachineUsed]--;
			}

			if (JB::PlayerInfo [i][JB::pAirbraking] >= MAX_CHECKS)
				JB::PlayerInfo [i][JB::pAirbraking] = 0;

            if (JB::PlayerInfo [i][JB::pWallriding] >= MAX_CHECKS)
				JB::PlayerInfo [i][JB::pWallriding] = 0;

			if (!JBGMC::Progress {i})
			{
			    freezed = bool: DOB::GetBit (JB::Freezed, i);
				if (freezed && JB::Variables [FREEZE_UPDATE])//Prevent that cheaters unfreeze themselves.
				{
					TogglePlayerControllable (i, false);
					SetSyncTime (i, SYNC_TYPE_VEHICLE);
				}

	            if (JB::PlayerInfo [i][JB::pFreezeTime])
	            {
	                JB::PlayerInfo [i][JB::pFreezeTime]--;
	                if (!JB::PlayerInfo [i][JB::pFreezeTime] && !freezed)
	                    TogglePlayerControllable (i, true);
	            }
            }
            else if (JB::PlayerInfo [i][JB::pFreezeTime])
                JB::PlayerInfo [i][JB::pFreezeTime]--;

			if (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_ONFOOT)
			{
				if (IsPlayerBuyingInAmmuNation (i))
				{
				    DOB::SetBit (JB::BuyingInAmmuNation, i, true);
					SyncWeapons_CS (i, true);
					GetPlayerArmour (i, JB::PlayerInfo [i][JB::pArmour]);
					SetSyncTime (i, SYNC_TYPE_ARMOUR);
				}
				else if (IsPlayerBuyingInRestaurant (i))
				{
					GetPlayerHealth (i, JB::PlayerInfo [i][JB::pHealth]);
					SetSyncTime (i, SYNC_TYPE_HEALTH);
				}
				else if (GetPlayerAnimationIndex (i) == 1660 || (JB::Variables [CHECK_VM_POS] && IsPlayerNearVendingMachine (i)))
				{
				    DOB::SetBit (JB::BuyingInAmmuNation, i, false);
					JB::PlayerInfo [i][JB::pVendingMachineUsed] = 5;
					SetSyncTime (i, SYNC_TYPE_HEALTH);
				}
			}

			if (!JB::IsPlayerAdmin (i) && IsPlayerInValidState (i) && !DOB::GetBit (JB::AntiBugKilled, i)) //!JB::PlayerInfo [i][JB::pAntiBugKilled])
			{
			    if (JB::Variables [CHECK_WALK_ANIMS] && GetPlayerWeapon (i) != 46 && JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_ONFOOT && !JB::PlayerPedAnims && GetPlayerSkin (i) != 0 && GetPlayerAnimationIndex (i) == 1231)
			    {
			        JB::Ban (i, "Cheats detected");
			        continue;
			    }
			    
			    if (JB::Variables [JOYPAD] && !JB::PlayerInfo [i][JB::pFreezeTime])
				{
				    GetPlayerKeys (i, keys, updown, leftright);
				    if((updown != 128 && updown != 0 && updown != -128) || (leftright != 128 && leftright != 0 && leftright != -128))
				    {
				        if (++JB::Warnings [i]{JOYPAD} >= JB::Variables [JOYPAD])
				        	JB::Kick (i, "Using joypad");
						else
						{
						    JB::PlayerInfo [i][JB::pFreezeTime] = 5; // Freeze for 5 seconds.
						    SetSyncTime (i, SYNC_TYPE_VEHICLE);
							TogglePlayerControllable (i, false);
							SendClientMessage (i, JB_RED, "[Anti-Cheat]{FFFFFF} Please stop using a joypad/gamepad. Use your keyboard and mouse.");
						}
				    }
				}

			    if (DOB::GetBit (JB::GunBought, i) && DOB::GetBit (JB::BuyingInAmmuNation, i) && JB::PlayerInfo [i][JB::pLastBoughtWeapon] != 0)
			    {
			        if (++JB::PlayerInfo [i][JB::pBuyingGuns] >= 2)
			        {
				        if (GetTickCount () - JB::PlayerInfo [i][JB::pLastMoneyChange] > 5000)
				        {
				            if (++JB::Warnings [i]{PAY_FOR_GUNS} >= JB::Variables [PAY_FOR_GUNS])
				            {
				                reason [0] = '\0';
				                GetWeaponName (JB::PlayerInfo [i][JB::pLastBoughtWeapon], reason, sizeof (reason));
				                format (reason, sizeof (reason), "Ain't payin' for gun: %s", reason);
					            JB::Kick (i, reason);
					            continue;
				            }
				        }
				        else if (JB::PlayerInfo [i][JB::pLastLostMoney] < AmmuNationInfo [JB::PlayerInfo [i][JB::pLastBoughtWeapon]][0])
				        {
				            if (++JB::Warnings [i]{PAY_FOR_GUNS} >= JB::Variables [PAY_FOR_GUNS])
				            {
					            reason [0] = '\0';
				                GetWeaponName (JB::PlayerInfo [i][JB::pLastBoughtWeapon], reason, sizeof (reason));
				                format (reason, sizeof (reason), "Ain't payin' for gun: %s", reason);
					            JB::Kick (i, reason);
					            continue;
				            }
				        }
	                    DOB::SetBit (JB::GunBought, i, false);
	                    JB::PlayerInfo [i][JB::pBuyingGuns] = 0;
                    }
			    }
			    else
			        JB::PlayerInfo [i][JB::pBuyingGuns] = 0;

				if (JB::Variables [MIN_FPS])
				{
					var = JB::GetPlayerFPS (i);
					if (var < JB::Variables [MIN_FPS])
					{
						JB::Warnings [i]{MIN_FPS}++;
						if (JB::Warnings [i]{MIN_FPS} >= (MAX_CHECKS * 30))//Constantly low FPS = kick
						{
							format (reason, sizeof (reason), "Too low FPS (%d, min %d)", var, JB::Variables [MIN_FPS]);
							JB::Kick (i, reason);
							continue;
						}
						else if (JB::Warnings [i]{MIN_FPS} % (MAX_CHECKS * 10) == 0)
						{
							JB::SendFormattedMessage (i, JB_RED, "[Anti-Cheat]{FFFFFF} Please fix your framerate (FPS) or you will get kicked! (Min %d, your FPS: %d)", JB::Variables [MIN_FPS], var);
							SendClientMessage (i, JB_RED, "[Anti-Cheat]{FFFFFF} Pressing F7 once may help to fix it. (Removes the outlines of the letters in chat window.)");
						}
					}
				}

				if (!JB::SyncInfo [i][SYNC_TYPE_POS][JB::sSyncTime])
				{
				    surfing = (GetPlayerSurfingVehicleID (i) != INVALID_VEHICLE_ID || GetPlayerSurfingObjectID (i) != INVALID_OBJECT_ID);
					if ((z < 900.0) == (JB::PlayerInfo [i][JB::pCurrentPos][2] < 900.0))//Prevent kick when entering buildings.
					{
						if (JB::PlayerInfo [i][JB::pCurrentState] != PLAYER_STATE_PASSENGER && !surfing && !IsPlayerInRangeOfPoint (i, 350.0, JB::PlayerInfo [i][JB::pCurrentPos][0], JB::PlayerInfo [i][JB::pCurrentPos][1], JB::PlayerInfo [i][JB::pCurrentPos][2]))
						{
							if (!IsPlayerInRangeOfPoint (i, 5.0, JB::PlayerInfo [i][JB::pSetPos][0], JB::PlayerInfo [i][JB::pSetPos][1], JB::PlayerInfo [i][JB::pSetPos][2]))
							{
								JB::GetPlayer2DZone (i, reason, sizeof (reason));
								JB::Warnings [i]{TELEPORT_HACK}++;
								if (JB::Variables [TELEPORT_HACK])
								{
									if (IsCheatPosition (i))
									{
										format (reason, sizeof (reason), "Teleport cheats [Code 1]: %s", reason);
										JB::Ban (i, reason);
										continue;
									}
									else if (JB::Variables [PICKUP_TELEPORT] && IsPickupPosition (i)) // IsPickupPosition will only be executed when Anti-PickupTeleport is enaled.
									{
									    format (reason, sizeof (reason), "Teleport cheats [Code 3]: %s", reason);
										JB::Ban (i, reason);
										continue;
									}
									else if (JB::Warnings [i]{TELEPORT_HACK} >= MAX_CHECKS)
									{
										format (reason, sizeof (reason), "Teleport cheats [Code 2]: %s", reason);
										JB::Kick (i, reason);
										continue;
									}
									else
										JunkBusterReport (i, "teleport cheats", reason);
								}
								else
									JunkBusterReport (i, "teleport cheats", reason);
							}
						}
					}

					// This will only be executed when JB::AirbrakeDetection == 0 (slow mode)
					if (!JB::AirbrakeDetection && JB::Variables [AIRBRAKE] && !surfing && (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_ONFOOT || (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_DRIVER && JB::GetPlayerSpeed (i, true) < 30)))
					{
					    var = floatround (GetPlayerDistanceFromPoint (i, JB::PlayerInfo [i][JB::pCurrentPos][0], JB::PlayerInfo [i][JB::pCurrentPos][1], JB::PlayerInfo [i][JB::pCurrentPos][2]));
						if (var >= JB::Variables [AIRBRAKE])
						{
							JB::PlayerInfo [i][JB::pAirbraking]++;
							if (JB::PlayerInfo [i][JB::pAirbraking] >= (MAX_CHECKS - 1))
							{
								JB::Warnings [i]{AIRBRAKE}++;
								if (JB::Warnings [i]{AIRBRAKE} < MAX_CHECKS)
								{
									format (reason, sizeof (reason), "height: %.2f, ~%d m/s, vehicle: %s", z, var, JB::GetVehicleName (vehicleid));
									JunkBusterReport (i, "airbrake", reason);
								}
								else
								{
									JB::Ban (i, "Airbrake");
									continue;
								}
							}
						}
						else
							JB::PlayerInfo [i][JB::pAirbraking] = 0;
					}
				}
					
				var = GetPlayerAnimationIndex (i);
				if (JB::Variables [FLY_HACK] && ivar [3] > JB::Variables [FLY_HACK] && z > 12.0 && (var == 1543 || var == 1538 || var == 1539))
				{
				    JB::Ban (i, "Fly hack"); // Obvious noob is obvious.
				    continue;
				}

				if (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_DRIVER)
				{
				    if (JB::Variables [TANK_MODE])
					{
						GetVehicleHealth (vehicleid, health);
						if (health > 1000.0)
						{
							JB::Ban (i, "Tank mode");
							SetVehicleToRespawn (vehicleid);
							continue;
						}
					}

					if (IsPlayerInPayNSpray (i) || 1 <= GetPlayerInterior (i) <= 3)
					    SetSyncTime (i, SYNC_TYPE_VEHICLE);
					    
					if (JB::Variables [TUNING_HACK])
					{
					    for (new j = 0; j < MAX_COMPONENT_SLOTS; ++j)
					    {
					        componentid = GetVehicleComponentInSlot (vehicleid, j);
					        if (componentid != 0 && componentid != (JB::VehicleComponents [vehicleid]{j} + 999))
					        {
					            JB::Kick (i, "Tuning hack");
					            SetVehicleToRespawn (vehicleid);
					            continue;
					        }
					    }
					}
					    
					if (JB::Variables [MAX_SPEED])
					{
      					ivar [0] = JB::GetVehicleMaxSpeed (vehicleid);
						if (!IsPlayerInPlane (i))
						{
						    if (JB::Variables [SPEEDHACK_DETECTION] == 0)
						    {
						        var = JB::GetPlayerSpeed (i, JB::Variables [SPEED_3D]);
								if (!JB::PlayerInfo [i][JB::pFreezeTime])
								{
									if (var > JB::Variables [MAX_SPEED])
									{
										JB::Warnings [i]{MAX_SPEED}++;
										JB::PlayerInfo [i][JB::pFreezeTime] = 5; // Freeze for 5 seconds.
										SetSyncTime (i, SYNC_TYPE_VEHICLE);
										TogglePlayerControllable (i, false);
										if (JB::Warnings [i]{MAX_SPEED} < MAX_CHECKS)
										{
											format (reason, sizeof (reason), "%d KM/H with %s (Max %d)", var, JB::GetVehicleName (vehicleid), ivar [0]);
											JunkBusterReport (i, "speedhack [Code 1]", reason);
										}
										else
										{
											JB::Ban (i, "Speedhack [Code 1]");
											continue;
										}
									}
									else if (JB::Variables [SPEEDHACK_ADVANCED] && var > (ivar [0] + JB::Variables [SPEEDHACK_ADVANCED]))
									{
									    JB::Warnings [i]{MAX_SPEED}++;
										JB::PlayerInfo [i][JB::pFreezeTime] = 5; // Freeze for 5 seconds.
										SetSyncTime (i, SYNC_TYPE_VEHICLE);
										TogglePlayerControllable (i, false);
										if (JB::Warnings [i]{MAX_SPEED} < MAX_CHECKS)
										{
											format (reason, sizeof (reason), "%d KM/H with %s (Max %d)", var, JB::GetVehicleName (vehicleid), ivar [0]);
											JunkBusterReport (i, "speedhack [Code 2]", reason);
										}
										else
										{
											JB::Kick (i, "Speedhack [Code 2]");
											continue;
										}
									}
								}
							}

							if (JB::Variables [WALLRIDE])
							{
							    GetVehicleRotation (vehicleid, rx, ry, rz);
							    if (75.0 < abs (rz) < 105.0)
							    {
							        GetVehicleVelocity (vehicleid, rx, ry, rz);
							        if (JB::Variables [SPEEDHACK_DETECTION] != 0)
							            var = JB::GetPlayerSpeed (i, JB::Variables [SPEED_3D]);
							            
									if (floatround (rz * 160.0) < JB::Variables [WALLRIDE] && var > 10)
									{
									    JB::PlayerInfo [i][JB::pWallriding]++;
									    if (JB::PlayerInfo [i][JB::pWallriding] == MAX_CHECKS)
									    {
										    JB::Warnings [i]{WALLRIDE}++;
										    if (JB::Warnings [i]{WALLRIDE} >= MAX_CHECKS)
										    {
										        JB::Kick (i, "Wallride");
										        continue;
										    }
										    else
										    {
										        format (reason, sizeof (reason), "with %s", JB::GetVehicleName (vehicleid));
												JunkBusterReport (i, "wallride", reason);
										    }
									    }
									}
							    }
							    else
                                    JB::PlayerInfo [i][JB::pWallriding] = 0;
							}
						}
						else
							JB::PlayerInfo [i][JB::pWallriding] = 0;
					}
				}

				var = GetPlayerWeapon (i);
				if (IsWeaponForbiddenForPlayer (i, var))
				{
					GetWeaponName (var, reason, sizeof (reason));
					format (reason, sizeof (reason), "Using weapon cheats (%s)", reason);
					JB::Ban (i, reason);
					continue;
				}

				if (JB::Variables [WEAPON_HACK] && !JB::SyncInfo [i][SYNC_TYPE_WEAPONS][JB::sSyncTime])
				{
					if (var >= 16 && var <= 39)//Grenades and guns
					{
						if (JB::PlayerWeapons [i]{GetWeaponSlot (var)} != var && GetPlayerAmmo (i))
						{
							GetWeaponName (var, reason, sizeof (reason));
							format (reason, sizeof (reason), "Using weapon cheats (%s)", reason);
							JB::Kick (i, reason);
							continue;
						}
					}
				}

				if (JB::Variables [NO_RELOAD_SAWNOFF])
				{
					if (var == 26 && JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_ONFOOT)
					{
						var = GetPlayerAmmo (i);
						ivar [0] = (JB::PlayerInfo [i][JB::pSawnOffAmmo] - var);
						if (ivar [0] > 5 && ivar [0] < 11)//6 - 10 shots per second with sawn-off is cheating!
						{
							JB::Warnings [i]{NO_RELOAD_SAWNOFF}++;
							if (JB::Warnings [i]{NO_RELOAD_SAWNOFF} >= JB::Variables [NO_RELOAD_SAWNOFF])
							{
								JB::Ban (i, "Not reloading (Sawn-off Shotgun) [Code 2]");
								continue;
							}
						}
						else if (JB::Warnings [i]{NO_RELOAD_SAWNOFF})
							JB::Warnings [i]{NO_RELOAD_SAWNOFF}--;
						JB::PlayerInfo [i][JB::pSawnOffAmmo] = var;
					}
					else
						JB::Warnings [i]{NO_RELOAD_SAWNOFF} = 0;
				}

				if (JB::Variables [WEAPON_HACK])
				{
					ivar [0] = 0;
			 		ivar [1] = 0;
			 		for (new j = 0; j < MAX_WEAPON_SLOTS; ++j)
			 		{
			 			GetPlayerWeaponData (i, j, var, ivar [2]);
			 			if (ivar [2] == 69)
							ivar [0]++;
						else if (ivar [2] == 198)
							ivar [1]++;
			 		}

					if (ivar [0] >= MAX_CHECKS || ivar [1] >= MAX_CHECKS)
					{
						JB::ResetPlayerWeapons (i);
						JB::Kick (i, "Ammohack");
						continue;
					}
				}

				if (GetPlayerSpecialAction (i) == SPECIAL_ACTION_USEJETPACK && JB::Variables [JETPACK])
				{
					JB::Ban (i, "Using jetpack");
					continue;
				}

				GetPlayerHealth (i, health);
				if (JB::Variables [HEALTH_HACK])
				{
					GetPlayerHealth (i, health);
					if (health > 100.0)
					{
						JB::Ban (i, "Health hack [Code 1]");
						continue;
					}
				}

				GetPlayerArmour (i, armour);
				if (JB::Variables [ARMOUR_HACK])
				{
					if (armour > 100.0)
					{
						JB::Ban (i, "Armour hack [Code 1]");
						continue;
					}
				}

				if (JB::Variables [SS_HEALTH])
				{
					if (health > JB::PlayerInfo [i][JB::pHealth] && !JB::PlayerInfo [i][JB::pVendingMachineUsed] && !JB::SyncInfo [i][SYNC_TYPE_HEALTH][JB::sSyncTime])
					{
						JB::Warnings [i]{SS_HEALTH}++;
						if (JB::Warnings [i]{SS_HEALTH} >= MAX_CHECKS)
							JB::Kick (i, "Health hack [Code 2]");
						continue;
					}
					else if (armour > JB::PlayerInfo [i][JB::pArmour] && !JB::SyncInfo [i][SYNC_TYPE_ARMOUR][JB::sSyncTime])
					{
						JB::Warnings [i]{SS_HEALTH}++;
						if (JB::Warnings [i]{SS_HEALTH} >= MAX_CHECKS)
							JB::Kick (i, "Armour hack [Code 2]");
						continue;
					}
					else
						JB::Warnings [i]{SS_HEALTH} = 0;
				}

				JB::PlayerInfo [i][JB::pPing][JB::PlayerInfo [i][JB::pPingCheckProgress]] = GetPlayerPing (i);
				JB::PlayerInfo [i][JB::pPingCheckProgress]++;
				if (JB::PlayerInfo [i][JB::pPingCheckProgress] == MAX_PING_CHECKS)
				{
					if (JB::Variables [MAX_PING])
					{
						var = 0;
						for (new j = 0; j < MAX_PING_CHECKS; ++j)
							var += JB::PlayerInfo [i][JB::pPing][j];
						var /= MAX_PING_CHECKS;
						if (var > JB::Variables [MAX_PING])
						{
							format (reason, sizeof (reason), "Too high ping. [%d/%d]", var, JB::Variables [MAX_PING]);
							JB::Kick (i, reason);
							continue;
						}
					}
					JB::PlayerInfo [i][JB::pPingCheckProgress] = 0;
				}
			}

			JB::PlayerInfo [i][JB::pCurrentPos][0] = x;
			JB::PlayerInfo [i][JB::pCurrentPos][1] = y;
			JB::PlayerInfo [i][JB::pCurrentPos][2] = z;
			JB::PlayerInfo [i][JB::pLastCheck] = GetTickCount ();
		}
	}
	return 1;
}

//==============================================================================

PRIVATE: SplitIp (ipstring [])
{
	new
		j,
		bytes [4],
		word;

	for (new i = 0, len = strlen (ipstring); i < len; ++i)
	{
	    if (j > 3)
	        return 0xFFFFFFFF;

		if (ipstring [i] == ' ')
		    continue;

		if (ipstring [i] == '*')
		    bytes [j] = 0xFF;
		else if (ipstring [i] == '.')
		{
		    ++j;
		}
		else if ('0' <= ipstring [i] <= '9')
		{
		    bytes [j] = 10 * bytes [j] + ipstring [i] - '0';
		    if (bytes [j] > 0xFF || bytes [j] < 0)
		        return 0xFFFFFFFF;
		}
		else
		    return 0xFFFFFFFF;
	}
	
	if (j != 3)
	    return 0xFFFFFFFF;
	
	DOB::BytesToWord (bytes [0], bytes [1], bytes [2], bytes [3], word);
	return word;
}

#if !defined USE_DATABASE

	PUBLIC: IpBanCheck (playerid)
	{
		new ip = SplitIp (JB::PlayerInfo [playerid][JB::pIp]);
		for (new i = 0; i < IpBanCount; ++i)
			if (IsSameIpEx (IpBans [i], ip))
				return true;
		return false;
	}

	PRIVATE: IsSameIp (ip1, ip2)
	{
		return (ip1 == ip2);
	}

	PRIVATE: IsSameIpEx (ip1, ip2)// Check for range-ban
	{
	    new bytes [2][4];
	    DOB::WordToBytes (ip1, bytes [0][0], bytes [0][1], bytes [0][2], bytes [0][3]);
	    DOB::WordToBytes (ip2, bytes [1][0], bytes [1][1], bytes [1][2], bytes [1][3]);
	    for (new i = 0; i < 4; ++i)
	        if (bytes [0][i] != bytes [1][i] && bytes [0][i] != 0xFF && bytes [1][i] != 0xFF)
	            return false;
	    return true;
	}

	PUBLIC: BanIp (ipstring [])
	{
		new ip = SplitIp (ipstring);
		
		if (ip != 0xFFFFFFFF && IpBanCount < sizeof (IpBans))
		{
		    IpBans [IpBanCount++] = ip;
		    JB::LogEx ("IP %s has been banned.", ipstring);
			SaveIpBans ();
			foreach(Player, j)
				if (IsSameIpEx (ip, SplitIp (JB::PlayerInfo [j][JB::pIp])))
					JB::Kick (j, "IP has been banned");
			return 1;
		}
		JB::LogEx ("Could not ban IP %s!", ipstring);
		return 0;
	}

	PUBLIC: UnbanIp (ipstring [])
	{
		new ip = SplitIp (ipstring);
		
		for (new i = 0; i < IpBanCount; ++i)
		{
			if (IsSameIp (IpBans [i], ip))
			{
			    IpBans [i] = IpBans [--IpBanCount];
				JB::LogEx ("IP %s has been unbanned.", ipstring);
				SaveIpBans ();
				return 1;
			}
		}
		JB::LogEx ("Could not unban IP %s!", ipstring);
		return 0;
	}

	PRIVATE: SaveIpBans ()
	{
		new
			File: f = fopen (IP_BAN_FILE, io_write),
			string [32],
			bytes [4];
			
		for (new i = 0; i < IpBanCount; ++i)
		{
			string [0] = '\0';
			DOB::WordToBytes (IpBans [i], bytes [0], bytes [1], bytes [2], bytes [3]);
			for (new j = 0; j < 4; ++j)
			{
				if (bytes [j] == 0xFF)
					format (string, sizeof (string), "%s.*", string);
				else
					format (string, sizeof (string), "%s.%d", string, bytes [j]);
			}
			strcat (string, "\r\n");
			fwrite (f, string [1]);
		}
		return fclose (f);
	}

	PRIVATE: LoadIpBans ()
	{
		if (DOF2::FileExists (IP_BAN_FILE))
		{
			new
				File: f = fopen (IP_BAN_FILE, io_read),
				string [16];
				
			IpBanCount = 0;
			while (fread (f, string, sizeof (string)) && IpBanCount < sizeof (IpBans))
			{
				JB::StripNewLine (string);
				if (string [0])
				{
					IpBans [IpBanCount] = SplitIp (string);
					if (IpBans [IpBanCount] != 0xFFFFFFFF)
						++IpBanCount;
				}
			}
			fclose (f);
			JB::LogEx ("%d IP-bans have been loaded.", IpBanCount);
			return 1;
		}
		else
		{
		    IpBanCount = 0;
			DOF2::CreateFile (IP_BAN_FILE);
		}
		JB::Log ("Could not load IP-bans!");
		return 0;
	}

	//==============================================================================

	PRIVATE: LoadBlacklist ()
	{
		if (DOF2::FileExists (BLACKLIST_FILE))
		{
			new
				File: f = fopen (BLACKLIST_FILE, io_read),
				string [MAX_PLAYER_NAME];
				
			BlacklistCount = 0;
			while (fread (f, string, sizeof (string)) && BlacklistCount < sizeof (Blacklist))
			{
				JB::StripNewLine (string);
				if (string [0])
				    strpack (Blacklist [BlacklistCount++], string);
			}
			fclose (f);
			JB::LogEx ("%d blacklist entries have been loaded.", BlacklistCount);
			return 1;
		}
		else
		{
		    BlacklistCount = 0;
			DOF2::CreateFile (BLACKLIST_FILE);
		}
		JB::Log ("Could not load blacklist!");
		return 0;
	}

	PRIVATE: UpdateBlacklist ()
	{
		new
			string [MAX_PLAYER_NAME + 2],
			File: f = fopen (BLACKLIST_FILE, io_write);
			
		for (new i = 0; i < BlacklistCount; ++i)
		{
		    strunpack (string, Blacklist [i]);
		    strcat (string, "\r\n");
			fwrite (f, string);
		}
		JB::Log ("Blacklist has been updated.");
		return fclose (f);
	}

	PUBLIC: AddNameToBlacklist (name [])
	{
	    if (isnull (name))
	        return 0;

	    if (BlacklistCount < sizeof (Blacklist))
	    {
	        strpack (Blacklist [BlacklistCount++], name);
	        UpdateBlacklist ();
	        JB::LogEx ("Player '%s' has successfully been added to blacklist.", name);
			return 1;
		}
		JB::LogEx ("Could not add player '%s' to blacklist!", name);
		return 0;
	}

	PUBLIC: RemoveNameFromBlacklist (name [])
	{
	    if (isnull (name))
	        return 0;

		new string [MAX_PLAYER_NAME];
			
		for (new i = 0; i < BlacklistCount; ++i)
		{
		    strunpack (string, Blacklist [i]);
			if (!strcmp (string, name, false))
			{
				Blacklist [i] = Blacklist [--BlacklistCount];
				UpdateBlacklist ();
				JB::LogEx ("Player '%s' has successfully been removed from blacklist.", name);
				return 1;
			}
		}
		JB::LogEx ("Could not remove player '%s' from blacklist!", name);
		return 0;
	}

	PUBLIC: AddPlayerToBlacklist (playerid)
	{
		if (AddNameToBlacklist (JB::PlayerInfo [playerid][JB::pName]))
			return JB::Ban (playerid, "Blacklist");
		return 0;
	}

	PUBLIC: IsPlayerOnBlacklist (playerid)
	{
		new string [MAX_PLAYER_NAME];
			
		for (new i = 0; i < BlacklistCount; ++i)
		{
		    strunpack (string, Blacklist [i]);
			if (!strcmp (JB::PlayerInfo [playerid][JB::pName], string, false))
				return true;
		}
		return false;
	}

	//==============================================================================

	PRIVATE: LoadWhitelist ()
	{
		if (DOF2::FileExists (WHITELIST_FILE))
		{
			new
				File: f = fopen (WHITELIST_FILE, io_read),
				string [MAX_PLAYER_NAME];
				
			WhitelistCount = 0;
			while (fread (f, string, sizeof (string)) && WhitelistCount < sizeof (Whitelist))
			{
				JB::StripNewLine (string);
				if (string [0])
					strpack (Whitelist [WhitelistCount++], string);
			}
			fclose (f);
			JB::LogEx ("%d whitelist entries have been loaded.", WhitelistCount);
			return 1;
		}
		else
		{
		    WhitelistCount = 0;
			DOF2::CreateFile (WHITELIST_FILE);
		}
		JB::Log ("Could not load whitelist!");
		return 0;
	}

	PRIVATE: UpdateWhitelist ()
	{
		new
			string [MAX_PLAYER_NAME + 2],
			File: f = fopen (WHITELIST_FILE, io_write);
			
		for (new i = 0; i < WhitelistCount; ++i)
		{
		    strunpack (string, Whitelist [i]);
		    strcat (string, "\r\n");
			fwrite (f, string);
		}
		JB::Log ("Whitelist has been updated.");
		return fclose (f);
	}

	PUBLIC: AddNameToWhitelist (name [])
	{
	    if (isnull (name))
	        return 0;

	    if (WhitelistCount < sizeof (Whitelist))
	    {
	        strpack (Whitelist [WhitelistCount++], name);
	        UpdateWhitelist ();
	        JB::LogEx ("Player '%s' has successfully been added to whitelist.", name);
			return 1;
		}
		JB::LogEx ("Could not add player '%s' to whitelist!", name);
		return 0;
	}

	PUBLIC: RemoveNameFromWhitelist (name [])
	{
	    if (isnull (name))
	        return 0;

		new string [MAX_PLAYER_NAME];
		
		for (new i = 0; i < WhitelistCount; ++i)
		{
		    strunpack (string, Whitelist [i]);
			if (!strcmp (string, name, false))
			{
				Whitelist [i] = Whitelist [--WhitelistCount];
				UpdateWhitelist ();
				JB::LogEx ("Player '%s' has successfully been removed from whitelist.", name);
				return 1;
			}
		}
		JB::LogEx ("Could not remove player '%s' from whitelist!", name);
		return 0;
	}

	PUBLIC: AddPlayerToWhitelist (playerid)
	{
		return AddNameToWhitelist (JB::PlayerInfo [playerid][JB::pName]);
	}

	PUBLIC: IsPlayerOnWhitelist (playerid)
	{
		new string [MAX_PLAYER_NAME];
			
		for (new i = 0; i < WhitelistCount; ++i)
		{
		    strunpack (string, Whitelist [i]);
			if (!strcmp (JB::PlayerInfo [playerid][JB::pName], string, false))
				return true;
		}
		return false;
	}

	//==============================================================================

	PUBLIC: TempBanCheck (playerid)
	{
		new time = gettime ();

		for (new i = 0; i < TempBanCount; ++i)
		{
			if (!strcmp (TempBanInfo [i][tbName], JB::PlayerInfo [playerid][JB::pName], false))
			{
				if (TempBanInfo [i][tbTime] > time)
				{
					new
						days,
						hours,
						minutes,
						seconds;
						
					SecondsToDHMS (TempBanInfo [i][tbTime] - time, days, hours, minutes, seconds);
					TempBanInfo [i][tbIp] = JB::PlayerInfo [playerid][JB::pIp];
					JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are temporary for %d day(s), %d hour(s), %d minute(s) and %d second(s)!", days, hours, minutes, seconds);
					JB::LogEx ("%s (%s) has been banned for Ban evading.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
					BanEx (playerid, "Ban evading");
					return 1;
				}
				else
					TempBanInfo [i][tbTime] = 0;
			}
		}
		return 0;
	}

	PUBLIC: TempBan (playerid, days, reason [])
	{
		if (days > 0)
		{
		    if (TempBanCount < sizeof (TempBanInfo))
		    {
		        new string [128];
		        
				TempBanInfo [TempBanCount][tbTime] = gettime () + (days * 24 * 60 * 60);
				strcpy (TempBanInfo [TempBanCount][tbIp], JB::PlayerInfo [playerid][JB::pIp], 16);
				strcpy (TempBanInfo [TempBanCount][tbName], JB::PlayerInfo [playerid][JB::pName], MAX_PLAYER_NAME);
				++TempBanCount;
				format (string, sizeof (string), "%s [%d day(s)]", reason, days);
				JB::Ban (playerid, string);
				SaveTempBans ();
				return 1;
		    }
		}
		return 0;
	}

	PUBLIC: DeleteTempBan (name [])
	{
		for (new i = 0; i < TempBanCount; ++i)
		{
			if (!strcmp (TempBanInfo [i][tbName], name, false))
			{
				new string [32];

				--TempBanCount;
				format (string, sizeof (string), "unbanip %s", TempBanInfo [i][tbIp]);
				SendRconCommand (string);
				JB::LogEx ("Player '%s' (%s) has been unbanned.", name, TempBanInfo [i][tbIp]);
				TempBanInfo [i][tbTime] = TempBanInfo [TempBanCount][tbTime];
				strcpy (TempBanInfo [i][tbIp], TempBanInfo [TempBanCount][tbIp], 16);
				strcpy (TempBanInfo [i][tbName], TempBanInfo [TempBanCount][tbName], MAX_PLAYER_NAME);
				SaveTempBans ();
				return 1;
			}
		}
		return 0;
	}

	PRIVATE: LoadTempBans ()
	{
		if (DOF2::FileExists (TEMP_BAN_FILE))
		{
			new
				File: f = fopen (TEMP_BAN_FILE, io_read),
				string [128];
				
            TempBanCount = 0;
			while (fread (f, string, sizeof (string)) && TempBanCount < sizeof (TempBanInfo))
			{
				JB::StripNewLine (string);
				if (!isnull (string))
					if (!JB::sscanf (string, "iss", TempBanInfo [TempBanCount][tbTime], TempBanInfo [TempBanCount][tbIp], TempBanInfo [TempBanCount][tbName]))
						TempBanCount++;
			}
			fclose (f);
			JB::LogEx ("%d temporary bans have been loaded.", TempBanCount);
			return 1;
		}
		else
			DOF2::CreateFile (TEMP_BAN_FILE);
		JB::Log ("Could not load temporary bans!");
		return 0;
	}

	PRIVATE: SaveTempBans ()
	{
		new
			File: f = fopen (TEMP_BAN_FILE, io_write),
			string [128];
			
		for (new i = 0; i < TempBanCount; ++i)
		{
			if (TempBanInfo [i][tbTime])
			{
				format (string, sizeof (string), "%d %s %s\r\n", TempBanInfo [i][tbTime], TempBanInfo [i][tbIp], TempBanInfo [i][tbName]);
				fwrite (f, string);
			}
		}
		return fclose (f);
	}

	PUBLIC: TempBanUpdate ()
	{
		new
			string [32],
			time = gettime ();
			
		for (new i = 0; i < TempBanCount; ++i)
		{
			if (TempBanInfo [i][tbTime] < time)
			{
				format (string, sizeof (string), "unbanip %s", TempBanInfo [i][tbIp]);
				SendRconCommand (string);
				JB::LogEx ("Player '%s' (%s) has been unbanned.", TempBanInfo [i][tbName], TempBanInfo [i][tbIp]);
				--TempBanCount;
				TempBanInfo [i][tbTime] = TempBanInfo [TempBanCount][tbTime];
				strcpy (TempBanInfo [i][tbIp], TempBanInfo [TempBanCount][tbIp], 16);
				strcpy (TempBanInfo [i][tbName], TempBanInfo [TempBanCount][tbName], MAX_PLAYER_NAME);
				--i;
			}
		}
		SaveTempBans ();
		return 1;
	}

#endif

//==============================================================================

PRIVATE: LoadBadWords ()
{
	if (DOF2::FileExists (BAD_WORDS_FILE))
	{
		new
			File: f = fopen (BAD_WORDS_FILE, io_read),
			string [32];
			
		BadWordsCount = 0;
		while (fread (f, string, sizeof (string)) && BadWordsCount < MAX_BAD_WORDS)
		{
			JB::StripNewLine (string);
			if (string [0])
				BadWords [BadWordsCount++] = string;
		}
		fclose (f);
		JB::LogEx ("%d bad words have been loaded.", BadWordsCount);
		return 1;
	}
	else
		DOF2::CreateFile (BAD_WORDS_FILE);
	JB::Log ("Could not load bad words!");
	return 0;
}

PRIVATE: LoadForbiddenWeapons ()
{
	if (DOF2::FileExists (FORBIDDEN_WEAPONS_FILE))
	{
		new
			File: f = fopen (FORBIDDEN_WEAPONS_FILE, io_read),
			string [32];
			
		ForbiddenWeaponsCount = 0;
		while (fread (f, string, sizeof (string)) && ForbiddenWeaponsCount < MAX_FORBIDDEN_WEAPONS)
		{
			JB::StripNewLine (string);
			if (string [0])
				ForbiddenWeapons {ForbiddenWeaponsCount++} = strval (string);
		}
		fclose (f);
		JB::LogEx ("%d forbidden weapons have been loaded.", ForbiddenWeaponsCount);
		return 1;
	}
	else
		DOF2::CreateFile (FORBIDDEN_WEAPONS_FILE);
	JB::Log ("Could not load forbidden weapons!");
	return 0;
}

PRIVATE: ConfigJunkBuster ()
{
	if (!DOF2::FileExists (CONFIG_FILE))
		DOF2::CreateFile (CONFIG_FILE);
		
	if (!DOF2::FileExists (JB_CHROME_FILE))
	    DOF2::CreateFile (JB_CHROME_FILE);

	DOF2::SetString (CONFIG_FILE, "Version", #JB_VERSION, "Misc");
	if (!DOF2::IsSet (CONFIG_FILE, "Homepage", "Misc"))
	{
	    JB::Homepage = "creativeroleplay.xyz";
	    DOF2::SetString (CONFIG_FILE, "Homepage", JB::Homepage, "Misc");
	}
	else
	    strcpy (JB::Homepage, DOF2::GetString (CONFIG_FILE, "Homepage", "Misc"));

	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
	{
		if (DOF2::IsSet (CONFIG_FILE, JB::VariableNames [i]))
			JB::Variables [i] = DOF2::GetInt (CONFIG_FILE, JB::VariableNames [i]);
		else
			DOF2::SetInt (CONFIG_FILE, JB::VariableNames [i], JB::Variables [i]);
	}
	
	DOF2::SaveFile ();

	print (" ");
	printf("Configuración del JunkBuster: ");
	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
		if (JB::Variables [i] != 0) printf ("(%s = %d)", JB::VariableNames [i], JB::Variables [i]);
	print (" ");
	
	if (JB::Variables [MONEY_HACK])
	    EnableStuntBonusForAll (false);

	#if !defined USE_DATABASE
		LoadIpBans ();
		LoadTempBans ();
		LoadWhitelist ();
		LoadBlacklist ();
	#endif
	
	LoadBadWords ();
	LoadForbiddenWeapons ();
	JB::Log ("JunkBuster has been configurated.");
	return 1;
}

PUBLIC: SetJBVar (var [], value)
{
    if (!isnull (var) && value >= 0)
	{
		for (new i = 0; i < MAX_JB_VARIABLES; ++i)
		{
			if (!strcmp (var, JB::VariableNames [i], true))
			{
				JB::Variables [i] = value;
				return 1;
			}
		}
	}
	return 0;
}

PUBLIC: GetJBVar (var [])
{
    if (!isnull (var))
		for (new i = 0; i < MAX_JB_VARIABLES; ++i)
			if (!strcmp (var, JB::VariableNames [i], true))
				return JB::Variables [i];
	return -1;
}

PUBLIC: SaveJunkBusterVars ()
{
	if (!DOF2::FileExists (CONFIG_FILE))
		DOF2::CreateFile (CONFIG_FILE);

	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
		DOF2::SetInt (CONFIG_FILE, JB::VariableNames [i], JB::Variables [i]);
	DOF2::SaveFile ();

	JB::Log ("Current JunkBuster configuration: ");
	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
		JB::LogEx ("- %s = %d", JB::VariableNames [i], JB::Variables [i]);

	print (" ");
	JB::Log ("JunkBuster configuration has been saved to file.");
	return 1;
}

//==============================================================================

PRIVATE: JB::GetTime ()
{
	new
		time [16],
		hours,
		minutes,
		seconds;
		
	gettime (hours, minutes, seconds);
	format (time, sizeof (time), "%02d:%02d:%02d", hours, minutes, seconds);
	return time;
}

PRIVATE: JB::GetDate ()
{
	new
		date [32],
		day,
		month,
		year;
		
	getdate (year, month, day);
	format (date, sizeof (date), "%d. %s %d", day, JB::GetMonth (month), year);
	return date;
}

PRIVATE: JB::GetMonth (month)
{
	new string [16] = "Unknown month";
		
	switch (month)
	{
		case 1:
			string = "January";
			
		case 2:
			string = "February";
			
		case 3:
			string = "March";
			
		case 4:
			string = "April";
			
		case 5:
			string = "May";
			
		case 6:
			string = "June";
			
		case 7:
			string = "July";
			
		case 8:
			string = "August";
			
		case 9:
			string = "Septembre";
			
		case 10:
			string = "Octobre";
			
		case 11:
			string = "Novembre";
			
		case 12:
			string = "Decembre";
	}
	return string;
}

PRIVATE: GetWeaponSlot (weaponid)
{
	switch (weaponid)
	{
		case 0, 1:
			return 0;
			
		case 2 .. 9:
			return 1;

		case 10 .. 15:
			return 10;

		case 16 .. 19, 39:
			return 8;

		case 22 .. 24:
			return 2;

		case 25 .. 27:
			return 3;

		case 28, 29, 32:
			return 4;

		case 30, 31:
			return 5;

		case 33, 34:
			return 6;

		case 35 .. 38:
			return 7;

		case 40:
			return 12;

		case 41 .. 43:
			return 11;
	}
	return 0;
}

PRIVATE: GetWeaponModel (weaponid)
{
	switch (weaponid)
	{
		case 1:
			return 331;

		case 2 .. 8:
			return weaponid + 331;

		case 9:
			return 341;

		case 10 .. 15:
			return weaponid + 311;

		case 16 .. 18:
			return weaponid + 326;

		case 22 .. 29:
			return weaponid + 324;

		case 30, 31:
			return weaponid + 325;

		case 32:
			return 372;

		case 33 .. 45:
			return weaponid + 324;

		case 46:
			return 371;
	}
	return 0;
}

PRIVATE: HasTimePassed (time, delay)
{
	new t = GetTickCount () - time;
		
	return (t > delay || t < 0);
}

PRIVATE: IsPlayerInRangeOfPlayer (playerid, Float: range, playerid2)
{
	new
		Float: x,
		Float: y,
		Float: z;
		
	GetPlayerPos (playerid2, x, y, z);
	return IsPlayerInRangeOfPoint (playerid, range, x, y, z);
}

PRIVATE: IsPlayerInRangeOfVehicle (playerid, Float: range, vehicleid)
{
    new
		Float: x,
		Float: y,
		Float: z;

	GetVehiclePos (vehicleid, x, y, z);
	return IsPlayerInRangeOfPoint (playerid, range, x, y, z);
}

PRIVATE: SecondsToDHMS (value, &days, &hours, &minutes, &seconds)
{
	days = value / (24 * 60 * 60);
	hours = (value - (days * 24 * 60 * 60)) / (60 * 60);
	minutes = (value - (days * 24 * 60 * 60) - (hours * 60 * 60)) / 60;
	seconds = value - (days * 24 * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
}

PRIVATE: JB::IsNumeric (string [])
{
	for (new i = 0, j = strlen (string); i < j; ++i)
		if ((string [i] > '9' || string [i] < '0') || (string [i] == '-' && i != 0))
			return 0;
	return 1;
}

PRIVATE: JB::StripNewLine (string [])
{
	new len = strlen (string);
		
	if (string [0] == 0)
		return;
		
	if ((string [len - 1] == '\n') || (string [len - 1] == '\r'))
	{
		string [len - 1] = 0;
		if (string [0] == 0)
			return;
			
		if ((string [len - 2] == '\n') || (string [len - 2] == '\r'))
			string [len - 2] = 0;
	}
}

//==============================================================================

PUBLIC: JB::GetPlayerFPS (playerid)
{
	new fps;
		
	for (new i = 0; i < MAX_FPS_INDEX; ++i)
		fps += JB::PlayerInfo [playerid][JB::pFPS][i];
	return (fps / MAX_FPS_INDEX);
}

//==============================================================================

PUBLIC: JB::GetPlayerSpeed (playerid, get3d)
{
	new Float: x, Float: y, Float: z;
	if (IsPlayerInAnyVehicle (playerid))
		GetVehicleVelocity (GetPlayerVehicleID (playerid), x, y, z);
	else
		GetPlayerVelocity (playerid, x, y, z);

	return JB::Speed(x, y, z, 100.0, get3d);
}

PRIVATE: JB::GetVehicleName (vehicleid)
{
	new
		name [32] = "Unknown",
		modelid = GetVehicleModel (vehicleid) - 400;
		
	if (modelid >= 0 && modelid < sizeof (JB::VehicleInfo))
	    strunpack (name, JB::VehicleInfo [modelid][JB::vName]);
	return name;
}

PRIVATE: JB::GetVehicleMaxSpeed (vehicleid)
{
	new modelid = GetVehicleModel (vehicleid) - 400;
		
	if (modelid >= 0 && modelid < sizeof (JB::VehicleInfo))
	    return JB::VehicleInfo [modelid][JB::vMaxSpeed];
	return 9999;
}

PRIVATE: JB::GetSquaredDistance (Float: x1, Float: y1, Float: z1, Float: x2, Float: y2, Float: z2)
{
	x1 -= x2;
	y1 -= y2;
	z1 -= z2;
	x1 *= x1;
	y1 *= y1;
	z1 *= z1;
	return floatround (x1 + y1 + z1);
}

PRIVATE: GetXYZInFrontOfPlayer(playerid, &Float: x, &Float: y, &Float: z, Float: distance)
{
	new Float: a;

	GetPlayerPos (playerid, x, y, z);
	GetPlayerFacingAngle (playerid, a);

	x += (distance * floatsin (-a, degrees));
	y += (distance * floatcos (-a, degrees));
}

//==============================================================================

//By a dude called DANGER1979. Thanks.

PRIVATE: ConvertNonNormaQuatToEuler(Float: qw, Float: qx, Float: qy, Float: qz, &Float: heading, &Float: attitude, &Float: bank)
{
    new
		Float: sqw = qw * qw,
	    Float: sqx = qx * qx,
	    Float: sqy = qy * qy,
	    Float: sqz = qz * qz,
	    Float: unit = sqx + sqy + sqz + sqw,
	    Float: test = qx * qy + qz * qw;
	/*
	if (test > 0.499 * unit)
    {
        heading = 2 * atan2 (qx, qw);
        attitude = 3.141592653 / 2;
        bank = 0;
        return 1;
    }
    if (test < -0.499 * unit)
    {
        heading = -2 * atan2 (qx, qw);
        attitude = -3.141592653 / 2;
        bank = 0;
        return 1;
    }
    */
    heading = atan2 (2 * qy * qw - 2 * qx * qz, sqx - sqy - sqz + sqw);
    attitude = asin (2 * test / unit);
    bank = atan2(2 * qx * qw - 2 * qy * qz, -sqx + sqy - sqz + sqw);
    return 1;
}

PRIVATE: GetVehicleRotation (vehicleid, &Float: heading,  &Float: attitude,  &Float: bank)
{
    new
		Float: quat_w,
		Float: quat_x,
		Float: quat_y,
		Float: quat_z;
		
    GetVehicleRotationQuat (vehicleid, quat_w, quat_x, quat_y, quat_z);
    ConvertNonNormaQuatToEuler (quat_w, quat_x, quat_z, quat_y,  heading,  attitude,  bank);
    bank = -1 * bank;
    return 1;
}

//==============================================================================

//From Cueball's "Zones By ~Cueball~ - V 2.0"
PRIVATE: JB::GetPlayer2DZone (playerid, zone [], len = sizeof (zone)) //Credits to Cueball, Betamaster, Mabako, and Simon (for finetuning).
{
	new
		Float: x,
		Float: y,
		Float: z;
		
	GetPlayerPos (playerid, x, y, z);
 	for (new i = 0; i != sizeof (JB::SAZones); ++i)
 	{
		if (x >= JB::SAZones [i][JB::SAZONE_AREA][0] && x <= JB::SAZones [i][JB::SAZONE_AREA][3] && y >= JB::SAZones [i][JB::SAZONE_AREA][1] && y <= JB::SAZones [i][JB::SAZONE_AREA][4])
		{
		    strunpack (zone, JB::SAZones [i][JB::SAZONE_NAME], len);
			return i;
		}
	}
	return -1;
}

//==============================================================================

PRIVATE: ShowPlayerConfigDialog (playerid)
{
	ShowPlayerDialog (playerid, DIALOG_CFG, DIALOG_STYLE_LIST, "JunkBuster", "Set a variable\nLoad configuration from file\nSave configuration to file\nLoad default configuration\nSee JunkBuster reports\nSee JunkBuster commands for admins", "Choose", "Close");
}

PRIVATE: ShowPlayerHackCodeDialog (playerid)
{
	new string [1024];
	
	strcat (string, "{0CB7EB}Not reloading:{FFFFFF}\n\tCode 1: Player probably uses 2-shot with sawn-off shotgun.\n\tCode 2: Player is shooting really fast with sawn-off shotgun. Hack, not 2-shot.\n\n");
	strcat (string, "{0CB7EB}Teleporthack:{FFFFFF}\n\tCode 1: Player has teleport to a position know from cheat tools.\n\tCode 2: Teleport suspected, position not defined. Teleported to another player?\n\tCode 3: Teleport to a pickup.\n\n");
	strcat (string, "{0CB7EB}Speedhack:{FFFFFF}\n\tCode 1: Player's speed is higher than the global limit.\n\tCode 2: Player's speed is higher than the vehicle model's limit.\n\n");
	strcat (string, "{0CB7EB}Health-/armourhack:{FFFFFF}\n\tCode 1: Health/armour is higher than 100.\n\tCode 2: Player's health/armour is higher than JunkBuster actually expects.");
	ShowPlayerDialog (playerid, DIALOG_HACKCODES, DIALOG_STYLE_MSGBOX, "JunkBuster hack codes", string, "Close", "");
}

PRIVATE: ShowPlayerVarlistDialog (playerid)
{
	new string [MAX_JB_VARIABLES * 64];
		
	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
	{
	    if (JB::Variables [i] > 0)
	        format (string, sizeof (string), "%s{33AA33}", string);
		else
		    format (string, sizeof (string), "%s{AA3333}", string);
		format (string, sizeof (string), "%s%s = %d\n", string, JB::VariableNames [i], JB::Variables [i]);
	}

	ShowPlayerDialog (playerid, DIALOG_VARLIST, DIALOG_STYLE_LIST, "JunkBuster variables", string, "Choose", "Go back");
}

PRIVATE: ShowPlayerSetvarDialog (playerid, var)
{
	new
		string [64],
		description [512];
		
	format (string, sizeof (string), "JunkBuster variable: %s = %d", JB::VariableNames [var], JB::Variables [var]);
	strunpack (description, JB::VarDescription [var]);
	ShowPlayerDialog (playerid, DIALOG_SETVAR + var, DIALOG_STYLE_INPUT, string, description, "Set var", "Go back");
}

PRIVATE: ShowPlayerReportDialog (playerid)
{
	new
		string [(sizeof (JB::Reports []) * 4 + 8) * MAX_REPORTS],
		buf [sizeof (JB::Reports []) * 4 + 8];
		
	for (new i = 0; i < JB::ReportCount; ++i)
	{
		buf [0] = '\0';
	    strunpack (buf, JB::Reports [(JB::ReportIndex - 1 - i) % JB::ReportCount]);
	    if (buf [0])
	    {
			strcat (string, buf);
			strcat (string, "\n");
		}
	}
	if (string [0])
		ShowPlayerDialog (playerid, DIALOG_REPORTS, DIALOG_STYLE_LIST, "JunkBuster reports", string, "Close", "");
	else
	    ShowPlayerDialog (playerid, DIALOG_REPORTS, DIALOG_STYLE_MSGBOX, "JunkBuster reports", "There are no reports.", "Close", "");
}

//==============================================================================

PUBLIC: JB::GodModeCheck (playerid)
{
	if (IsPlayerConnected (playerid) && !IsPlayerNPC (playerid) && IsPlayerInValidState (playerid))
	{
		if (!HasTimePassed (JB::PlayerInfo [playerid][JB::pLastUpdate], 1000) &&  !DOB::GetBit (JB::Freezed, playerid))
		{
			new
				Float: x,
				Float: y,
				Float: z,
				Float: vx,
				Float: vy,
				Float: vz;

			GetPlayerCameraPos (playerid, x, y, z);
			GetPlayerCameraFrontVector (playerid, vx, vy, vz);
			SetPlayerCameraPos (playerid, x, y, z);
			SetPlayerCameraLookAt (playerid, x + vx, y + vy, z + vz);
			GetPlayerHealth (playerid, JBGMC::OldHealth [playerid]);
			GetPlayerArmour (playerid, JBGMC::OldArmour [playerid]);
			GetPlayerPos (playerid, JBGMC::OldPos [playerid][0], JBGMC::OldPos [playerid][1], JBGMC::OldPos [playerid][2]);
			if (IsPlayerInAnyVehicle (playerid))
			{
				JBGMC::VehicleID [playerid] = GetPlayerVehicleID (playerid);
				JBGMC::Seat {playerid} = GetPlayerVehicleSeat (playerid);
			}
			else
			    JBGMC::VehicleID [playerid] = INVALID_VEHICLE_ID;

			TogglePlayerControllable (playerid, false);
			JB::SetPlayerPos (playerid, JBGMC::OldPos [playerid][0], JBGMC::OldPos [playerid][1], JBGMC::OldPos [playerid][2] + 2000.0);

			JBGMC::Progress {playerid} = 1;
			JBGMC::TimeoutTime [playerid] = GetTickCount () + GMC_TIMEOUT;
			return 1;
		}
	}
	return 0;
}

PRIVATE: JBGMC::EndCheck (playerid, bool: reset = true)
{
    if (IsPlayerConnected (playerid) && JBGMC::Progress {playerid} != 0)
	{
	    if (reset)
	    {
		    SetCameraBehindPlayer (playerid);
		    JB::SetPlayerHealth (playerid, JBGMC::OldHealth [playerid]);
		    JB::SetPlayerArmour (playerid, JBGMC::OldArmour [playerid]);
		    JB::SetPlayerPos (playerid, JBGMC::OldPos [playerid][0], JBGMC::OldPos [playerid][1], JBGMC::OldPos [playerid][2]);
		    if (JBGMC::VehicleID [playerid] != INVALID_VEHICLE_ID)
		    	JB::PutPlayerInVehicle (playerid, JBGMC::VehicleID [playerid], JBGMC::Seat {playerid});
	    }
	    JBGMC::Progress {playerid} = 0;
	    return 1;
	}
	return 0;
}

PUBLIC: JBGMC::UpdateCheck (playerid)
{
	if (JBGMC::Progress {playerid} != 0 && IsPlayerInValidState (playerid))
	{
	    switch (JBGMC::Progress {playerid})
	    {
	        case 1:
	        {
	            if (!IsPlayerInRangeOfPoint (playerid, 10.0, JBGMC::OldPos [playerid][0], JBGMC::OldPos [playerid][1], JBGMC::OldPos [playerid][2] + 2000.0))
	                return ;

				TogglePlayerControllable (playerid, true);
				GetPlayerHealth (playerid, JBGMC::OldHealth [playerid]);
				GetPlayerArmour (playerid, JBGMC::OldArmour [playerid]);

				if (JBGMC::OldHealth [playerid] == 99.0)
				    JBGMC::NewHealth [playerid] = 100.0;
				else
				    JBGMC::NewHealth [playerid] = 99.0;
				JB::SetPlayerHealth (playerid, JBGMC::NewHealth [playerid]);
				JB::SetPlayerArmour (playerid, 0.0);

				JBGMC::Progress {playerid} = 2;
	            JBGMC::TimeoutTime [playerid] = GetTickCount () + GMC_TIMEOUT;
	        }

	        case 2:
	        {
	            new
	                Float: x,
	                Float: y,
	                Float: z,
	                Float: health,
					Float: armour;

				GetPlayerHealth (playerid, health);
				GetPlayerArmour (playerid, armour);
				if (health != JBGMC::NewHealth [playerid])
				{
				    JB::SetPlayerHealth (playerid, JBGMC::NewHealth [playerid]);
					JB::SetPlayerArmour (playerid, 0.0);
				    JB::SetPlayerPos (playerid, JBGMC::OldPos [playerid][0], JBGMC::OldPos [playerid][1], JBGMC::OldPos [playerid][2] + 2000.0);
				    return ;
				}

	            GetPlayerPos (playerid, x, y, z);
	            CreateExplosion (x, y, z, 8, 5.0);

	            JBGMC::Progress {playerid} = 3;
	            JBGMC::TimeoutTime [playerid] = GetTickCount () + GMC_TIMEOUT;
	        }

	        case 3 .. 7:
	        	JBGMC::Progress {playerid}++;

			case 8:
			{
			    new Float: health;

			    GetPlayerHealth (playerid, health);
			    JBGMC::EndCheck (playerid);
			    if (health == JBGMC::NewHealth [playerid])
			        SetTimerEx ("OnPlayerGodMode", 500, false, "i", playerid);
			}
 		}
	}
}

//==============================================================================

CALLBACK: OnUsePlayerPedAnims ()
{
	JB::PlayerPedAnims = true;
	return 1;
}

CALLBACK: OnSetPlayerName (playerid, name [])
{
	strcpy (JB::PlayerInfo [playerid][JB::pName], name, MAX_PLAYER_NAME);
	return 1;
}

CALLBACK: OnPlayerMoneyChange (playerid, oldmoney, newmoney)
{
	if (oldmoney > newmoney)
	{
	    JB::PlayerInfo [playerid][JB::pLastLostMoney] = oldmoney - newmoney;
	    JB::PlayerInfo [playerid][JB::pLastMoneyChange] = GetTickCount ();
	}
	return 1;
}

CALLBACK: OnPlayerBuyGun (playerid, weaponid, ammo)
{
	if (AmmuNationInfo [weaponid][0] > 0) // Can you buy this gun?
	{
	    JB::PlayerInfo [playerid][JB::pLastBoughtWeapon][0] = weaponid;
		JB::PlayerInfo [playerid][JB::pLastBoughtWeapon][1] = ammo;
	}
	return 1;
}

CALLBACK: OnPlayerGodMode (playerid)
{
	if (JB::Variables [ACTIVE_GMC] && !JB::IsPlayerAdmin (playerid))
	{
		JB::Warnings [playerid]{ACTIVE_GMC}++;
		if (JB::Warnings [playerid]{ACTIVE_GMC} >= JB::Variables [ACTIVE_GMC])
		{
			if (JB::Variables [GMC_BAN])
				JB::Ban (playerid, "Godmode");
			else
				JB::Kick (playerid, "Godmode");
			return 1;
		}
		else
			SetTimerEx ("JB_GodModeCheck", 5000 + random (10) * 1000, false, "i", playerid);
	}
	else
		JB::Warnings [playerid]{ACTIVE_GMC} = 0;
	JunkBusterReport (playerid, "godmode", "no details");
	return 1;
}

CALLBACK: OnPlayerReport (playerid, reporterid, report [])
{
	if (isnull (report))
	    return 0;
	    
	JB::LogEx ("%s (%s) ha reportado %s (%s). {FF0000}Razón: %s", JB::PlayerInfo [reporterid][JB::pName], JB::PlayerInfo [reporterid][JB::pIp], JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], report);
	if (JB::Variables [ACTIVE_GMC] && !JB::IsPlayerAdmin (playerid) && HasTimePassed (JB::PlayerInfo [playerid][JB::pLastGMC], 60000 * 5) && (strfind (report, "god", true) != -1 || strfind (report, "health", true) != -1))
	{
		JB::PlayerInfo [playerid][JB::pLastGMC] = GetTickCount ();
		SetTimerEx ("JB_GodModeCheck", 5000 + random (10) * 1000, false, "i", playerid);
	}
	return 1;
}

CALLBACK: OnVehicleDeath (vehicleid, killerid)
{
    GetVehiclePos (vehicleid, JB::VehiclePos [vehicleid][0], JB::VehiclePos [vehicleid][1], JB::VehiclePos [vehicleid][2]);
    /*
    // Seems to cause problems when driving into water.
	for (new i = 0; i < MAX_COMPONENT_SLOTS; ++i)
	    JB::VehicleComponents [vehicleid]{i} = 0;
	*/
	return 1;
}

CALLBACK: OnVehicleSpawn (vehicleid)
{
    GetVehiclePos (vehicleid, JB::VehiclePos [vehicleid][0], JB::VehiclePos [vehicleid][1], JB::VehiclePos [vehicleid][2]);
    for (new i = 0; i < MAX_COMPONENT_SLOTS; ++i)
    	JB::VehicleComponents [vehicleid]{i} = 0;
	return 1;
}

CALLBACK: OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat)
{
	if (JB::Variables [SPAWN_VEHICLES] && !passenger_seat && JB::PlayerInfo [playerid][JB::pCurrentState] == PLAYER_STATE_ONFOOT
		&& GetVehicleDistanceFromPoint (vehicleid, JB::VehiclePos [vehicleid][0], JB::VehiclePos [vehicleid][1], JB::VehiclePos [vehicleid][2]) > 50.0)
	{
	    new Float: x, Float: y, Float: z;
	    
 		GetXYZInFrontOfPlayer(playerid, x, y, z, 5.0);
 		if (GetVehicleDistanceFromPoint (vehicleid, x, y, z) < 5.0)
 		{
 		    if (++JB::Warnings [playerid]{SPAWN_VEHICLES} >= JB::Variables [SPAWN_VEHICLES])
 		    {
 		        new reason [64] = "Spawning vehicle: ";
 		        
 		        strcat (reason, JB::GetVehicleName (vehicleid));
 		        JB::Kick (playerid, reason);
 		        return 0;
 		    }
 		    else
 		        JunkBusterReport (playerid, "spawning vehicle", JB::GetVehicleName (vehicleid));
 		}
	}

	GetVehiclePos (vehicleid, JB::VehiclePos [vehicleid][0], JB::VehiclePos [vehicleid][1], JB::VehiclePos [vehicleid][2]);
	return 1;
}

CALLBACK: OnVehicleMod(playerid, vehicleid, componentid)
{
	if (1 <= GetPlayerInterior (playerid) <= 3)
		JB::VehicleComponents [vehicleid]{GetVehicleComponentType (componentid)} = componentid - 999;
	return 1;
}

CALLBACK: OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	JB::PlayerInfo [playerid][JB::pVehicleHealth] = 1000.0;
	SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
	return 1;
}

CALLBACK: OnVehicleRespray(playerid, vehicleid, color1, color2)
{
    JB::PlayerInfo [playerid][JB::pVehicleHealth] = 1000.0;
    SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
	return 1;
}

CALLBACK: OnPlayerRequestClass (playerid, classid)
{
	if (classid < MAX_CLASSES)
	{
		for (new i = 0; i < 3; ++i)
		{
			JB::SpawnWeapons [playerid][i][0] = JB::PlayerClassWeapons [classid][i][0];
			JB::SpawnWeapons [playerid][i][1] = JB::PlayerClassWeapons [classid][i][1];
		}
	}
	return 1;
}

CALLBACK: OnPlayerPickUpPickup (playerid, pickupid)
{
	switch (JB::PickupType {pickupid})
	{
		case PICKUP_TYPE_WEAPON:
			JB::GivePlayerWeapon (playerid, JB::PickupVar [pickupid][0], JB::PickupVar [pickupid][1]);

		case PICKUP_TYPE_HEALTH:
		{
			JB::PlayerInfo [playerid][JB::pHealth] = 100.0;
			SetSyncTime (playerid, SYNC_TYPE_HEALTH);
		}
		
		case PICKUP_TYPE_ARMOUR:
		{
			JB::PlayerInfo [playerid][JB::pArmour] = 100.0;
			SetSyncTime (playerid, SYNC_TYPE_ARMOUR);
		}
	}
	return 1;
}

CALLBACK: OnPlayerSpawn (playerid)
{
	new i;
		
	for (i = 0; i < MAX_WEAPON_SLOTS; ++i)
	{
		JB::PlayerWeaponAmmo [playerid][i] = 0;
		JB::PlayerWeapons [playerid]{i} = 0;
	}
	for ( ; i < 47; ++i)
		JB::PlayerWeaponAmmo [playerid][i] = 0;
		
	for (i = 0; i < 3; ++i)
		WeaponUpdate (playerid, JB::SpawnWeapons [playerid][i][0], JB::SpawnWeapons [playerid][i][1]);
		
	DOB::SetBit (JB::FullyConnected, playerid, true);
	DOB::SetBit (JB::Freezed, playerid, false);
    DOB::SetBit (JB::Spectating, playerid, false);
    
    for (i = 0; i < MAX_SYNC_TYPES; ++i)
        SetSyncTime (playerid, i);
    
	JB::PlayerInfo [playerid][JB::pHealth] = 100.0;
	GetPlayerArmour (playerid, JB::PlayerInfo [playerid][JB::pArmour]);
	JB::PlayerInfo [playerid][JB::pAFKPos][0] = JB::PlayerInfo [playerid][JB::pAFKPos][1] = JB::PlayerInfo [playerid][JB::pAFKPos][2] = 99999.9;
	
	if (DOB::GetBit (JB::AntiBugKilled, playerid))
	{
		new
			varname1 [32],
			varname2 [32],
			weaponid;
			
		for (i = 0; i < MAX_WEAPON_SLOTS; ++i)
		{
			format (varname1, sizeof (varname1), "JB_ABK_Weapon%02d", i);
			format (varname2, sizeof (varname2), "JB_ABK_Ammo%02d", i);
			weaponid = GetPVarInt (playerid, varname1);
			if (!DOB::GetBit (JB::PlayerInfo [playerid][JB::pWeaponForbidden], weaponid))
				JB::GivePlayerWeapon (playerid, weaponid, GetPVarInt (playerid, varname2));
			DeletePVar (playerid, varname1);
			DeletePVar (playerid, varname2);
		}

		SetPlayerPos (playerid, GetPVarFloat (playerid, "JB_ABK_PosX"), GetPVarFloat (playerid, "JB_ABK_PosY"), GetPVarFloat (playerid, "JB_ABK_PosZ"));
	 	SetPlayerFacingAngle (playerid, GetPVarFloat (playerid, "JB_ABK_Angle"));
	 	JB::SetPlayerHealth (playerid, GetPVarFloat (playerid, "JB_ABK_Health"));
	 	JB::SetPlayerArmour (playerid, GetPVarFloat (playerid, "JB_ABK_Armour"));
	 	SetPlayerVirtualWorld (playerid, GetPVarInt (playerid, "JB_ABK_World"));
	 	SetPlayerInterior (playerid, GetPVarInt (playerid, "JB_ABK_Interior"));
	 	SetPlayerTime (playerid, GetPVarInt (playerid, "JB_ABK_Hour"), GetPVarInt (playerid, "JB_ABK_Minute"));
	 	SetTimerEx ("JB_PutPlayerInVehicle", 500, false, "iii", playerid, GetPVarInt (playerid, "JB_ABK_VehicleID"), GetPVarInt (playerid, "JB_ABK_Seat"));

		DeletePVar (playerid, "JB_ABK_PosX");
	 	DeletePVar (playerid, "JB_ABK_PosY");
	 	DeletePVar (playerid, "JB_ABK_PosZ");
	 	DeletePVar (playerid, "JB_ABK_Angle");
	 	DeletePVar (playerid, "JB_ABK_Health");
	 	DeletePVar (playerid, "JB_ABK_Armour");
	 	DeletePVar (playerid, "JB_ABK_World");
	 	DeletePVar (playerid, "JB_ABK_Interior");
	 	DeletePVar (playerid, "JB_ABK_VehicleID");
	 	DeletePVar (playerid, "JB_ABK_Seat");
	 	DeletePVar (playerid, "JB_ABK_Hour");
	 	DeletePVar (playerid, "JB_ABK_Minute");

		DOB::SetBit (JB::AntiBugKilled, playerid, false);
		return 1;
	}

	for (i = 0; i < MAX_WEAPONS; ++i)
	{
		JB::PlayerInfo [playerid][JB::pOldAmmo][i] = 0;
		JB::PlayerInfo [playerid][JB::pLastWeaponUsed][i] = GetTickCount () - 5000;
		JB::PlayerInfo [playerid][JB::pOldWeapon] = 0;
	}
	return 1;
}

CALLBACK: OnPlayerUpdate (playerid)
{
	JB::PlayerInfo [playerid][JB::pLastUpdate] = GetTickCount ();
	if (IsPlayerNPC (playerid))
		return 1;
		
    JBGMC::UpdateCheck (playerid);

	new
		Float: fvar,
		ivar,
		vehicleid,
		ammo,
		speed,
		maxspeed,
		reason [64];
		
	static
		oldmoney [MAX_PLAYERS],
		oldweapons [MAX_PLAYERS][MAX_WEAPON_SLOTS char],
		oldammo [MAX_PLAYERS][MAX_WEAPON_SLOTS];

	for (new i = 0; i < MAX_SYNC_TYPES; ++i)
	{
	    if (JB::SyncInfo [playerid][i][JB::sSyncTime])
	    {
	        if (JB::PlayerInfo [playerid][JB::pLastUpdate] - JB::SyncInfo [playerid][i][JB::sLastSyncUpdate] > 1000)
	        {
	            JB::SyncInfo [playerid][i][JB::sSyncTime]--;
	            JB::SyncInfo [playerid][i][JB::sLastSyncUpdate] = JB::PlayerInfo [playerid][JB::pLastUpdate];
	        }
	    }
	}

	GetPlayerHealth (playerid, fvar);
	if (fvar < JB::PlayerInfo [playerid][JB::pHealth] || JB::SyncInfo [playerid][SYNC_TYPE_HEALTH][JB::sSyncTime])
		JB::PlayerInfo [playerid][JB::pHealth] = fvar;

	GetPlayerArmour (playerid, fvar);
	if (fvar < JB::PlayerInfo [playerid][JB::pArmour] || JB::SyncInfo [playerid][SYNC_TYPE_ARMOUR][JB::sSyncTime])
		JB::PlayerInfo [playerid][JB::pArmour] = fvar;
	
	ivar = GetPlayerMoney (playerid);
	if (ivar != oldmoney [playerid])
	    OnPlayerMoneyChange (playerid, oldmoney [playerid], ivar);
	oldmoney [playerid] = ivar;

	ivar = GetPlayerDrunkLevel (playerid);

	if (ivar < 100)
		SetPlayerDrunkLevel (playerid, 2000);
	else
	{
		if (JB::PlayerInfo [playerid][JB::pLastDrunkLevel] != ivar)
		{
			new fps = JB::PlayerInfo [playerid][JB::pLastDrunkLevel] - ivar;

			if (fps > 0 && fps < 200)
				JB::PlayerInfo [playerid][JB::pFPS][JB::PlayerInfo [playerid][JB::pFPSIndex]] = fps;
			JB::PlayerInfo [playerid][JB::pLastDrunkLevel] = ivar;
		}
		JB::PlayerInfo [playerid][JB::pFPSIndex]++;
		if (JB::PlayerInfo [playerid][JB::pFPSIndex] >= MAX_FPS_INDEX)
			JB::PlayerInfo [playerid][JB::pFPSIndex] = 0;
	}

	ivar = GetPlayerState (playerid);
	vehicleid = GetPlayerVehicleID (playerid);

	if (ivar == JB::PlayerInfo [playerid][JB::pCurrentState] && ivar == PLAYER_STATE_DRIVER)
	{
	    GetVehicleHealth (vehicleid, fvar);
	    
	    if (JB::PlayerInfo [playerid][JB::pLastVehicle] != 0 && vehicleid != 0 && !JB::IsPlayerAdmin (playerid))
	    {
	        if (JB::PlayerInfo [playerid][JB::pLastVehicle] != vehicleid)
	        {
			    if (!JB::SyncInfo [playerid][SYNC_TYPE_POS][JB::sSyncTime])
			    {
					if (JB::Variables [VEHICLE_TELEPORT])
					{
				        JB::Ban (playerid, "Vehicle teleport");
				        //JB::Kick (playerid, "Vehicle teleport"); // Remove JB::Ban and uncomment this if you have troubles with this. Or just set VehicleTeleport variable to 0.
				        return 0;
			        }
			        else
			            JunkBusterReport (playerid, "vehicle teleport", JB::GetVehicleName (vehicleid));
			    }
		    }
		    else if (JB::Variables [VEHICLE_REPAIR] && !JB::SyncInfo [playerid][SYNC_TYPE_VEHICLE][JB::sSyncTime])
		    {
		        if (fvar > JB::PlayerInfo [playerid][JB::pVehicleHealth])
		        {
		            JB::Warnings [playerid]{VEHICLE_REPAIR}++;
		            if (JB::Warnings [playerid]{VEHICLE_REPAIR} >= JB::Variables [VEHICLE_REPAIR])
		            {
		                JB::Kick (playerid, "Repairing vehicle with cheats");
		                return 0;
		            }
		            else
		                JunkBusterReport (playerid, "repairing vehicle with cheats", JB::GetVehicleName (vehicleid));
		        }
		    }
	    }
	    
	    JB::PlayerInfo [playerid][JB::pVehicleHealth] = fvar;
	    JB::PlayerInfo [playerid][JB::pLastVehicle] = vehicleid;
	}
	else if (ivar != JB::PlayerInfo [playerid][JB::pCurrentState])
	{
	    for (new i = 0; i < MAX_WEAPON_SLOTS; ++i)
	    {
	        oldweapons [playerid]{i} = 0;
	        oldammo [playerid][i] = 0;
		}
	}
	JB::PlayerInfo [playerid][JB::pCurrentState] = ivar;

	if (ivar == PLAYER_STATE_ONFOOT)
		GetPlayerPos (playerid, JB::PlayerInfo [playerid][JB::pOnFootPos][0], JB::PlayerInfo [playerid][JB::pOnFootPos][1], JB::PlayerInfo [playerid][JB::pOnFootPos][2]);

	ivar = GetPlayerWeapon (playerid);

	if (!JB::IsPlayerAdmin (playerid))
	{
        ammo = GetPlayerAmmo (playerid);
		if (JB::Variables [PAY_FOR_GUNS])
		{
  			new
				weapons,
				slot = GetWeaponSlot (ivar);
            
			if (DOB::GetBit (JB::BuyingInAmmuNation, playerid) && ammo > oldammo [playerid][slot])
			{
				DOB::SetBit (JB::GunBought, playerid, true);
				OnPlayerBuyGun (playerid, ivar, ammo - oldammo [playerid][slot]);
			}

			for (new i = 2; i < MAX_WEAPON_SLOTS; ++i)
		    {
				GetPlayerWeaponData (playerid, i, weapons, oldammo [playerid][i]);
				oldweapons [playerid]{i} = weapons;
			}
		}

		if (JB::Variables [NO_RELOAD_SAWNOFF] && JB::PlayerInfo [playerid][JB::pOldWeapon] == 26 && ivar == 26)
		{
			if (ammo != JB::PlayerInfo [playerid][JB::pOldAmmo][26])
				JB::PlayerInfo [playerid][JB::pLastSawnOffShot] = JB::PlayerInfo [playerid][JB::pLastUpdate];
		}
		else
			JB::PlayerInfo [playerid][JB::pLastSawnOffShot] = JB::PlayerInfo [playerid][JB::pLastUpdate];

		if (JB::Variables [SPEEDHACK_DETECTION] != 0 && JB::PlayerInfo [playerid][JB::pCurrentState] == PLAYER_STATE_DRIVER && !JB::PlayerInfo [playerid][JB::pFreezeTime])
		{
	        speed = JB::GetPlayerSpeed (playerid, JB::Variables [SPEED_3D]);
	        maxspeed = JB::GetVehicleMaxSpeed (vehicleid);

			if (speed > JB::Variables [MAX_SPEED])
			{
				JB::Warnings [playerid]{MAX_SPEED}++;
				JB::PlayerInfo [playerid][JB::pFreezeTime] = 5; // Freeze for 5 seconds.
				SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
				TogglePlayerControllable (playerid, false);
				if (JB::Warnings [playerid]{MAX_SPEED} < MAX_CHECKS)
				{
					format (reason, sizeof (reason), "%d KM/H with %s (Max %d)", speed, JB::GetVehicleName (vehicleid), maxspeed);
					JunkBusterReport (playerid, "speedhack [Code 1]", reason);
				}
				else
				{
					JB::Ban (playerid, "Speedhack [Code 1]");
					return 0;
				}
			}
			else if (JB::Variables [SPEEDHACK_ADVANCED] && speed > (maxspeed + JB::Variables [SPEEDHACK_ADVANCED]))
			{
			    JB::Warnings [playerid]{MAX_SPEED}++;
				JB::PlayerInfo [playerid][JB::pFreezeTime] = 5; // Freeze for 5 seconds.
				SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
				TogglePlayerControllable (playerid, false);
				if (JB::Warnings [playerid]{MAX_SPEED} < MAX_CHECKS)
				{
					format (reason, sizeof (reason), "%d KM/H with %s (Max %d)", speed, JB::GetVehicleName (vehicleid), maxspeed);
					JunkBusterReport (playerid, "speedhack [Code 2]", reason);
				}
				else
				{
					JB::Kick (playerid, "Speedhack [Code 2]");
					return 0;
				}
			}
		}

		if (JB::Variables [NO_RELOAD])
		{
			if ((JB::PlayerInfo [playerid][JB::pLastUpdate] - JB::PlayerInfo [playerid][JB::pLastWeaponUsed][ivar]) > 4000)//Player may just have changed to another weapon without reloading and he doesn't want to abuse bugs.
				JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] = 0;

			if (JB::PlayerInfo [playerid][JB::pOldWeapon] == ivar)//same weapon.
			{
				if (GetPlayerWeaponState (playerid) == WEAPONSTATE_RELOADING || ammo < 0 || ammo > 9999 || JB::PlayerInfo [playerid][JB::pCurrentState] != PLAYER_STATE_ONFOOT)
					JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] = 0;
				else
				{
					new ammoused;

					if (!JB::PlayerInfo [playerid][JB::pOldAmmo][ivar])
						JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] = 0;
					else
					{
						ammoused = (JB::PlayerInfo [playerid][JB::pOldAmmo][ivar] - ammo);
						if (ammoused < 0)
							ammoused = 0;

						JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] += ammoused;
						if (JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] < 0)
							JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] = 0;
					}

					if (JB::PlayerInfo [playerid][JB::pAmmoUsed][ivar] > (AmmoAmount [ivar] * 2) && ammoused > 0)//Player must have switch weapons fast or doesn't reload at all
					{
						JB::Warnings [playerid]{NO_RELOAD}++;
						if ((JB::Variables [NO_RELOAD] == 1 && (JB::Warnings [playerid]{NO_RELOAD} % 10) == 0))
						{
							GetWeaponName (ivar, reason, sizeof (reason));
							JunkBusterReport (playerid, "no reload", reason);
						}
						else if (JB::Warnings [playerid]{NO_RELOAD} >= JB::Variables [NO_RELOAD] && (ivar != 26 || !JB::Variables [NO_RELOAD_SAWNOFF]))
						{
							GetWeaponName (ivar, reason, sizeof (reason));
							format (reason, sizeof (reason), "Not reloading (%s)", reason);
							JB::Kick (playerid, reason);
							return 0;
						}
					}
				}
			}
			JB::PlayerInfo [playerid][JB::pOldAmmo][ivar] = ammo;
			JB::PlayerInfo [playerid][JB::pLastWeaponUsed][ivar] = JB::PlayerInfo [playerid][JB::pLastUpdate];
			JB::PlayerInfo [playerid][JB::pOldWeapon] = ivar;
		}
	}

	if (JB::Variables [DISABLE_BAD_WEAPONS])
	{
	    /*
		if (ivar >= 43 && ivar <= 45) // Camera & goggles are bugged... HOWEVER, this could get abused for maybe escaping in a fight?
			return 0;
		*/
		// New version of this by wups:
		if (ivar >= 43 && ivar <= 45)
		{
		    new
		        keys,
		        udlr;
		        
			GetPlayerKeys (playerid, keys, udlr, udlr);
			if (keys & KEY_FIRE)
			    return 0;
		}
	}
	return 1;
}

CALLBACK: OnPlayerDeath (playerid, killerid, reason)
{
	JBGMC::EndCheck (playerid, false);
	if (DOB::GetBit (JB::AntiBugKilled, playerid))
		return 0;

	JB::PlayerInfo [playerid][JB::pKillingSpree] = 0;
	if (killerid != INVALID_PLAYER_ID && !IsPlayerNPC (killerid) && (!JB::IsPlayerAdmin (killerid) || !JB::Variables [ADMIN_IMMUNITY]))
	{
		if (IsPlayerInRangeOfPlayer (killerid, 100.0, playerid))
		{
		    if (JB::PlayerInfo [killerid][JB::pCurrentState] == PLAYER_STATE_DRIVER)
		    {
				if (JB::Variables [DRIVE_BY] >= 2 && (reason == WEAPON_UZI || reason == WEAPON_MP5 || reason == WEAPON_TEC9 || reason == 50)) // 50 = helicopter blades.
				{
				    if (++JB::Warnings [killerid]{DRIVE_BY} >= MAX_CHECKS)
				        JB::Kick (killerid, "Excessive drive-by");
					else
					{
						JB::SetPlayerHealth (killerid, 0.0);
						SendClientMessage (killerid, JB_RED, "[Anti-Cheat]{FFFFFF} You have been killed for drive-by!");
					}
				}
				
			 	if (JB::Variables [ARMED_VEHICLES])
			 	{
			 	    new vehicleid = GetPlayerVehicleID (killerid);
					 	
					if (IsArmedVehicle (vehicleid))
					{
					    if (++JB::Warnings [killerid]{ARMED_VEHICLES} >= JB::Variables [ARMED_VEHICLES])
						{
						    new string [128];
								
						    format (string, sizeof (string), "Excessive killing with %s", JB::GetVehicleName (vehicleid));
						    JB::Kick (killerid, string);
						}
						else
							JB::SendFormattedMessage (killerid, JB_RED, "[Anti-Cheat]{FFFFFF} Killing with a %s is not allowed! Stop it! (Warning %d/%d)", JB::GetVehicleName (vehicleid), JB::Warnings [killerid]{ARMED_VEHICLES}, JB::Variables [ARMED_VEHICLES]);
					}
			 	}
			}

			if (JB::Variables [SPAWNKILL])
			{
				if (JB::PlayerInfo [playerid][JB::pSpawnKillProtected])
				{
					if (++JB::Warnings [killerid]{SPAWNKILL} >= JB::Variables [SPAWNKILL])
						JB::Kick (killerid, "Excessive spawnkilling");
					else
						JB::SendFormattedMessage (killerid, JB_RED, "[Anti-Cheat]{FFFFFF} Do not spawnkill! (Warning %d/%d)", JB::Warnings [killerid]{SPAWNKILL}, JB::Variables [SPAWNKILL]);
				}
		 	}
		}
		
		JB::PlayerInfo [killerid][JB::pKillingSpree]++;
		
		if (JB::Variables [NO_RELOAD_SAWNOFF] && reason == 26 && !JB::IsPlayerAdmin (killerid))//Getoetet mit Sawnoff
			if (GetPlayerWeapon (killerid) == 26 && GetPlayerAmmo (killerid) && IsPlayerInRangeOfPlayer (killerid, 30.0, playerid) && GetPlayerVirtualWorld (killerid) == GetPlayerVirtualWorld (playerid))
				SetTimerEx ("VerifyNoReload", GetPlayerPing (killerid) + 300, false, "i", killerid);
 	}
	return 1;
}

CALLBACK: OnPlayerInteriorChange (playerid, newinteriorid, oldinteriorid)
{
    DOB::SetBit (JB::GunBought, playerid, false);
	SetSyncTime (playerid, SYNC_TYPE_POS);
	return 1;
}

CALLBACK: OnFilterScriptInit ()
{
	printf("Cargando JunkBuster...");
	JB::Variables = JB::DefaultVariables;

	DOF2::RemoveFile (BAD_RCON_LOGIN_FILE);
	DOF2::CreateFile (BAD_RCON_LOGIN_FILE);

	#if defined USE_DATABASE
	    JBDB::Init ();
	#else
		SetTimer ("TempBanUpdate", 1013 * 60 * 15, true); // Every 15 minutes
	#endif

	ConfigJunkBuster ();

	if ((JB::AirbrakeDetection = JB::Variables [AIRBRAKE_DETECTION])) // start timer only when fast mode is activated.
	    SetTimer ("AirbrakeCheck", 337, true);
	
	SetTimer ("JunkBuster", 997, true);
	SetTimer ("QuickTurnCheck", 499, true);
	SetTimer ("SpamUpdate", 3511, true);
	SetTimer ("GlobalUpdate", 60 * 1009, true); //Every minute
	print (" ");
	printf("» JunkBuster (v"#JB_VERSION") su carga fue exitosa.");
	print (" ");
	return 0;
}

CALLBACK: OnFilterScriptExit ()
{
	#if defined USE_DATABASE
	    JBDB::Exit ();
	#else
		SaveIpBans ();
		SaveTempBans ();
	#endif
	if (JB::KickBanTitle != Text: INVALID_TEXT_DRAW)
		TextDrawDestroy (JB::KickBanTitle);
		
    if (JB::KickBanInfo != Text: INVALID_TEXT_DRAW)
		TextDrawDestroy (JB::KickBanInfo);
		
    if (JB::KickBanHelp != Text: INVALID_TEXT_DRAW)
		TextDrawDestroy (JB::KickBanHelp);
		
	DOF2::Exit ();
	return 0;
}

CALLBACK: OnGameModeExit ()
{
	JB::Log ("Resetting player classes.");
	for (new i = 0; i < MAX_CLASSES; ++i)
	{
		JB::PlayerClassWeapons [i][0][0] = 0;
		JB::PlayerClassWeapons [i][0][1] = 0;
		JB::PlayerClassWeapons [i][1][0] = 0;
		JB::PlayerClassWeapons [i][1][1] = 0;
		JB::PlayerClassWeapons [i][2][0] = 0;
		JB::PlayerClassWeapons [i][2][1] = 0;
	}
	JB::PlayerPedAnims = false;
	JB::PickupCount = 0;
	return 0;
}

CALLBACK: OnPlayerConnect (playerid)
{
	GetPlayerName (playerid, JB::PlayerInfo [playerid][JB::pName], MAX_PLAYER_NAME);
	GetPlayerIp (playerid, JB::PlayerInfo [playerid][JB::pIp], 16);

	DOB::SetBit (JB::Freezed, playerid, false);
	DOB::SetBit (JB::KickBan, playerid, false);
	DOB::SetBit (JB::FullyConnected, playerid, false);
	DOB::SetBit (JB::AntiBugKilled, playerid, false);
	DOB::SetBit (JB::BuyingInAmmuNation, playerid, false);
	DOB::SetBit (JB::GunBought, playerid, false);

	if (!IsPlayerNPC (playerid))
	{
	    #if defined USE_DATABASE
	    
	        if (JB::Variables [BLACKLIST])
	        {
		        new
					bool: banned,
					unbantime,
					bool: whitelisted,
					ip [16];
					
		        JBDB::GetUserData (JB::PlayerInfo [playerid][JB::pName], banned, unbantime, whitelisted, ip);
		        if (banned)
		        {
		            new t = gettime ();
						
		            if (unbantime == 0 || !JB::Variables [TEMP_BANS])
		            {
		                SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are banned from this server!");
						JB::LogEx ("%s (%s) has been banned for Ban evading.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
						JBDB::UpdateUserData (JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], true, unbantime, whitelisted);
			            DOB::SetBit (JB::KickBan, playerid, true);
		                Kick (playerid);
			            return 0;
					}
					else if (t < unbantime)
					{
					    new
							days,
							hours,
							minutes,
							seconds;
							
						SecondsToDHMS (unbantime - t, days, hours, minutes, seconds);
					    JB::SendFormattedMessageToAll (JB_RED, "[Anti-Cheat]{FFFFFF} You are temporary for %d day(s), %d hour(s), %d minute(s) and %d second(s)!", days, hours, minutes, seconds);
						JB::LogEx ("%s (%s) has been banned for Ban evading (Temporary banned).", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
						JBDB::UpdateUserData (JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], true, unbantime, whitelisted);
			            DOB::SetBit (JB::KickBan, playerid, true);
		                Kick (playerid);
			            return 0;
					}
					else
					    JBDB::UpdateUserData (JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], false, 0, whitelisted);
		        }
		        else if (JB::Variables [IP_BANS] && !whitelisted && JBDB::IsBanned (JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp])) // Also checks for IP bans.
		        {
		            SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are banned from this server!");
					JB::LogEx ("%s (%s) has been banned for Ban evading.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
					JBDB::UpdateUserData (JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp], true, unbantime, whitelisted);
		            DOB::SetBit (JB::KickBan, playerid, true);
	                Kick (playerid);
		            return 0;
		        }
	        }
	        
	    #else
	    
			if (TempBanCheck (playerid) && JB::Variables [TEMP_BANS])
   			{
			    DOB::SetBit (JB::KickBan, playerid, true);
				return 0;
   			}

			if (IpBanCheck (playerid) && !IsPlayerOnWhitelist (playerid) && JB::Variables [IP_BANS])
			{
			    DOB::SetBit (JB::KickBan, playerid, true);
				SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are banned from this server!");
				JB::LogEx ("%s (%s) has been kicked for Banned IP.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
				Kick (playerid);
				return 0;
			}

			if (IsPlayerOnBlacklist (playerid) && JB::Variables [BLACKLIST])
			{
			    DOB::SetBit (JB::KickBan, playerid, true);
				SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are banned from this server!");
				JB::LogEx ("%s (%s) has been banned for Ban evading.", JB::PlayerInfo [playerid][JB::pName], JB::PlayerInfo [playerid][JB::pIp]);
				BanEx (playerid, "Ban evading");
				return 0;
			}
			
		#endif
	}

	for (new i = 0; i < MAX_JB_VARIABLES; ++i)
		JB::Warnings [playerid]{i} = 0;

	for (new i = 0; i < MAX_SYNC_TYPES; ++i)
	    SetSyncTime (playerid, i);

	ResetForbiddenWeaponsForPlayer (playerid, false);
	JB::PlayerInfo [playerid][JB::pLastMessage][0] = 0;
	JB::PlayerInfo [playerid][JB::pMessageRepeated] = 0;
	JB::PlayerInfo [playerid][JB::pMessages] = 0;
	JB::PlayerInfo [playerid][JB::pCommands] = 0;
	JB::PlayerInfo [playerid][JB::pPingCheckProgress] = 0;
	JB::PlayerInfo [playerid][JB::pVehicleEntered] = INVALID_VEHICLE_ID;
	JB::PlayerInfo [playerid][JB::pMuted] = 0;
	JB::PlayerInfo [playerid][JB::pKillingSpree] = 0;
	JB::PlayerInfo [playerid][JB::pLastGMC] = GetTickCount () - 10 * 60 * 1000;
	JB::PlayerInfo [playerid][JB::pHealth] = 100.0;
	JB::PlayerInfo [playerid][JB::pArmour] = 0.0;
	JB::PlayerInfo [playerid][JB::pVendingMachineUsed] = 0;
	JB::PlayerInfo [playerid][JB::pCurrentState] = 0;
	JB::PlayerInfo [playerid][JB::pLastVehicle] = 0;
	JB::PlayerInfo [playerid][JB::pFreezeTime] = 0;
	JB::PlayerInfo [playerid][JB::pLastKeyPressed] = GetTickCount ();
	JB::PlayerInfo [playerid][JB::pLastMoneyChange] = GetTickCount ();
	JB::PlayerInfo [playerid][JB::pLastLostMoney] = 0;
	for (new i = 0; i < MAX_FPS_INDEX; ++i)
		JB::PlayerInfo [playerid][JB::pFPS][i] = JB::Variables [MIN_FPS] + 1;

	if (JB::Variables [WARN_PLAYERS])
	{
		SendClientMessage (playerid, JB_GREEN_BLUE, "> This server is running {FF0000}JunkBuster Anti-Cheat "#JB_VERSION"{00D799}!");
		SendClientMessage (playerid, JB_GREEN_BLUE, "> You may not cheat otherwise you'll get kicked/banned.");
	}
	return 0;
}

CALLBACK: OnPlayerDisconnect (playerid, reason)
{
	DOB::SetBit (JB::FullyConnected, playerid, false);
	DOB::SetBit (JB::Spectating, playerid, false);
	if (DOB::GetBit (JB::KickBan, playerid))
		return 0;

    JBGMC::EndCheck (playerid, false);
	if (reason == 2 && JB::Variables [JB_CHROME])
	    JunkBusterChrome (playerid, "No comment");

	if (DOB::GetBit (JB::AntiBugKilled, playerid))
	{
		new
			varname1 [32],
			varname2 [32];
			
		for (new i = 0; i < MAX_WEAPON_SLOTS; ++i)
		{
			format (varname1, sizeof (varname1), "JB_ABK_Weapon%02d", i);
			format (varname2, sizeof (varname2), "JB_ABK_Ammo%02d", i);
			DeletePVar (playerid, varname1);
			DeletePVar (playerid, varname2);
		}

		DeletePVar (playerid, "JB_ABK_PosX");
	 	DeletePVar (playerid, "JB_ABK_PosY");
	 	DeletePVar (playerid, "JB_ABK_PosZ");
	 	DeletePVar (playerid, "JB_ABK_Angle");
	 	DeletePVar (playerid, "JB_ABK_Health");
	 	DeletePVar (playerid, "JB_ABK_Armour");
	 	DeletePVar (playerid, "JB_ABK_World");
	 	DeletePVar (playerid, "JB_ABK_Interior");
	 	DeletePVar (playerid, "JB_ABK_VehicleID");
	 	DeletePVar (playerid, "JB_ABK_Seat");
	 	DeletePVar (playerid, "JB_ABK_Hour");
	 	DeletePVar (playerid, "JB_ABK_Minute");
	 	DOB::SetBit (JB::AntiBugKilled, playerid, false);
	 	//JB::PlayerInfo [playerid][JB::pAntiBugKilled] = false;
	}
	return 0;
}

CALLBACK: OnPlayerText (playerid, text [])
{
	if (IsPlayerNPC (playerid))
		return 1;
		
	if (isnull (text))
	    return 0;
	    
	new rcon_password [64];
		
	GetServerVarAsString ("rcon_password", rcon_password, sizeof (rcon_password));
	if (strfind (text, rcon_password, true) != -1)
	{
	    JB::LogEx ("Player '%s' has probably accidently typed the RCON-command into the chat. Message blocked. (\"%s\")", JB::PlayerInfo [playerid][JB::pName], text);
	    return 0;
	}

	if (JB::PlayerInfo [playerid][JB::pMuted] && JB::Variables [SPAM])
	{
		JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} You are not allowed to chat for %d second(s) because you have been muted!", JB::PlayerInfo [playerid][JB::pMuted]);
		return 0;
	}

	if (!JB::IsPlayerAdmin (playerid) || !JB::Variables [ADMIN_IMMUNITY])
	{
		if (!isnull (JB::PlayerInfo [playerid][JB::pLastMessage]))
		{
			if (!strcmp (text, JB::PlayerInfo [playerid][JB::pLastMessage], true, min (strlen (text), strlen (JB::PlayerInfo [playerid][JB::pLastMessage]))))
				JB::PlayerInfo [playerid][JB::pMessageRepeated]++;
			else
				JB::PlayerInfo [playerid][JB::pMessageRepeated] = 0;
		}
		else
			JB::PlayerInfo [playerid][JB::pMessageRepeated] = 0;

		strcpy (JB::PlayerInfo [playerid][JB::pLastMessage], text, 128);
		JB::PlayerInfo [playerid][JB::pMessages]++;
		if (!JB::PlayerInfo [playerid][JB::pMuted] && JB::Variables [SPAM])
		{
			if (JB::PlayerInfo [playerid][JB::pMessages] > 15 && !JB::IsPlayerAdmin (playerid))
			{
				JB::Ban (playerid, "Extreme spam");
				return 0;
			}
			else if (JB::PlayerInfo [playerid][JB::pMessages] > 10)
			{
				JB::Kick (playerid, "Massive spam");
				return 0;
			}
			else if (JB::PlayerInfo [playerid][JB::pMessages] > 4 || JB::PlayerInfo [playerid][JB::pMessageRepeated] >= MAX_CHECKS)
			{
				JB::PlayerInfo [playerid][JB::pMessageRepeated] = 0;
				JB::MutePlayer (playerid, 2 * 60, "Spam");
				return 0;
			}
		}

		if (CheckText (playerid, text))
			return 0;
	}
	return 1;
}

CALLBACK: OnPlayerCommandReceived (playerid, cmdtext [])
{
	JB::PlayerInfo [playerid][JB::pCommands]++;
	if (JB::Variables [COMMAND_SPAM] && (!JB::IsPlayerAdmin (playerid) || !JB::Variables [ADMIN_IMMUNITY]))
	{
		if (JB::PlayerInfo [playerid][JB::pCommands] > 15 && !JB::IsPlayerAdmin (playerid))
		{
			JB::Ban (playerid, "Extreme command spam");
			return 0;
		}
		else if (JB::PlayerInfo [playerid][JB::pCommands] > 5)
		{
			JB::Kick (playerid, "Command spam");
			return 0;
		}
	}
	return 1;
}

//==============================================================================

#if defined DEV

	COMMAND:oputest (playerid, params [])
	{
		new
		    t = GetTickCount (),
			s = strval (params);

		for (new i = 0; i < s; ++i)
			OnPlayerUpdate (playerid);

		t = GetTickCount () - t;
		JB::SendFormattedMessage (playerid, JB_RED, "OnPlayerUpdate time: %d ms", t);
		return 1;
	}

	COMMAND:jbtest (playerid, params [])
	{
		new
		    t = GetTickCount (),
			s = strval (params);

		for (new i = 0; i < s; ++i)
			JunkBuster ();

		t = GetTickCount () - t;
		JB::SendFormattedMessage (playerid, JB_RED, "JunkBuster time: %d ms", t);
		return 1;
	}

#endif

COMMAND:myfps (playerid, params [])
{
	#pragma unused params
	if (!JB::Variables [MIN_FPS])
		return SendClientMessage (playerid, JB_RED, "This function has been disabled!");
		
	JB::SendFormattedMessage (playerid, JB_GREEN_BLUE, "Your FPS: %d", JB::GetPlayerFPS (playerid));
	return 1;
}

// Debug Commands:

COMMAND:gmctest (playerid, params [])//GodModeCheck test
{
	#pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	JB::GodModeCheck (playerid);
	return 1;
}

COMMAND:gotosprunk (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	new machine = strval (params);
		
	if (machine < 0 || machine >= sizeof (JB::VendingMachines))
		return 1;
		
	JB::SetPlayerPos (playerid, JB::VendingMachines [machine][0], JB::VendingMachines [machine][1], JB::VendingMachines [machine][2] + 3.0);
	return 1;
}

COMMAND:abktest (playerid, params [])//AntiBugKill test
{
	#pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	JB::AntiBugKill (playerid);
	return 1;
}

// Debug Commands - END

COMMAND:jbcmds (playerid, params [])
{
	#pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	new string [(sizeof (JB::AdminCommands)) * 32];
		
	for (new i = 0; i < sizeof (JB::AdminCommands); ++i)
		format (string, sizeof (string), "%s%s\n", string, JB::AdminCommands [i]);

	ShowPlayerDialog (playerid, DIALOG_CMDS, DIALOG_STYLE_LIST, "JunkBuster Commands", string, "Perform", "Close");
	return 1;
}

COMMAND:jbchrome (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;
		
    new id;
		
	if (JB::sscanf (params, "u", id))
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /jbchrome <ID/name>");
		
	if (JunkBusterChrome (id, JB::PlayerInfo [playerid][JB::pName]))
		JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} JunkBuster Chrome has successfully collected data of player '%s'!", JB::PlayerInfo  [id][JB::pName]);
	else
	    JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} JunkBuster Chrome could not colect data of player '%s'!", params);
	return 1;
}

COMMAND:jbsethomepage (playerid, params [])
{
    if (!IsPlayerAdmin (playerid))
		return 0;

	if (isnull (params))
	    return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /jbsethomepage <homepage>");
	    
	strcpy (JB::Homepage, params);
    DOF2::SetString (CONFIG_FILE, "Homepage", JB::Homepage, "Misc");
    JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Homepage has been set to '%s'!", params);
	return 1;
}

COMMAND:jbreports (playerid, params [])
{
    #pragma unused params
	if (!JB::IsPlayerAdmin (playerid))
		return 0;
		
    ShowPlayerReportDialog (playerid);
	return 1;
}

COMMAND:jbhackcodes (playerid, params [])
{
    #pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	ShowPlayerHackCodeDialog (playerid);
	return 1;
}

COMMAND:jbcfg (playerid, params [])
{
	#pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	ShowPlayerConfigDialog (playerid);
	return 1;
}

COMMAND:blackadd (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	new id;
		
	if (JB::sscanf (params, "u", id))
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /blackadd <ID/name>");

	if (!IsPlayerConnected (id))
	{
	    #if defined USE_DATABASE
	        if (JBDB::UpdateUserData (params, "255.255.255.255", true, 0, false))
	    #else
			if (AddNameToBlacklist (params))
		#endif
				JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been added to blacklist!", params);
			else
				JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not add player '%s' to blacklist!", params);
	}
	else
	{
		if (id != playerid)
		{
		    #if defined USE_DATABASE
		        if (JBDB::UpdateUserData (JB::PlayerInfo [id][JB::pName], JB::PlayerInfo [id][JB::pIp], true, 0, false))
		        {
		            JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been added to blacklist!", JB::PlayerInfo [id][JB::pName]);
		            JB::Kick (id, "Blacklist");
		        }
		    #else
				if (AddPlayerToBlacklist (id))
					JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been added to blacklist!", JB::PlayerInfo [id][JB::pName]);
			#endif
				else
					JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not add player '%s' to blacklist!", JB::PlayerInfo [id][JB::pName]);
		}
	}
	return 1;
}

COMMAND:blackdel (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	if (!isnull (params))
	{
	    #if defined USE_DATABASE
	        if (JBDB::UpdateUserData (params, "255.255.255.255", false, 0, false))
		#else
			if (RemoveNameFromBlacklist (params))
		#endif
				JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been removed from blacklist!", params);
			else
				JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not remove player '%s' from blacklist!", params);
			return 1;
	}
	return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /blackdel <name>");
}

COMMAND:whiteadd (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	if (!isnull (params))
	{
	    #if defined USE_DATABASE
	        if (JBDB::UpdateUserData (params, "255.255.255.255", false, 0, true))
		#else
			if (AddNameToWhitelist (params))
		#endif
				JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been added to whitelist!", params);
			else
				JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not add player '%s' to whitelist!", params);
			return 1;
	}
	return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /whiteadd <name>");
}

COMMAND:whitedel (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	if (!isnull (params))
	{
	    #if defined USE_DATABASE
	        if (JBDB::SetWhitelisted (params, "255.255.255.255", false))
		#else
			if (RemoveNameFromWhitelist (params))
		#endif
				JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Player '%s' has successfully been removed from whitelist!", params);
			else
				JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not remove player '%s' from whitelist!", params);
			return 1;
	}
	return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /whitedel <name>");
}

COMMAND:jbvarlist (playerid, params [])
{
	#pragma unused params
	if (!IsPlayerAdmin (playerid))
		return 0;

	ShowPlayerVarlistDialog (playerid);
	return 1;
}

COMMAND:jbsetvar (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	new
		var [32],
		value;
		
	if (JB::sscanf (params, "si", var, value))
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /jbsetvar <variable name> <0/1(/max ping)> ");

	if (SetJBVar (var, value))
	{
	    JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} JunkBuster variable '%s' has successfully been set to %d.", var, value);
		JB::LogEx ("%s has set variable '%s' to %d.", JB::PlayerInfo [playerid][JB::pName], var, value);
	}
	return 1;
}

COMMAND:tban (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	new
		id,
		days,
		reason [128];
		
	if (JB::sscanf (params, "uiz", id, days, reason))
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /tban <ID/name> <days> <reason>");

	if (IsPlayerConnected (id) && id != playerid && days > 0 && !isnull (reason))
	{
	    #if defined USE_DATABASE
	        JBDB::UpdateUserData (JB::PlayerInfo [id][JB::pName], JB::PlayerInfo [id][JB::pIp], true, gettime () + days * 60 * 60 * 24, false);
	        format (reason, sizeof (reason), "%s [%d day(s) banned]", reason, days);
	        JB::Kick (id, reason);
	    #else
			TempBan (id, days, reason);
		#endif
			return 1;
	}
	return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /tban <ID/name> <days> <reason> ");
}

COMMAND:tunban (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	if (!isnull (params))
	{
	    #if defined USE_DATABASE
	        if (JBDB::UpdateUserData (params, "255.255.255.255", false, 0, false))
		#else
			if (DeleteTempBan (params))
		#endif
				JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Temporary ban of player '%s' has successfully been deleted.", params);
			else
				JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not delete temporary ban of player '%s'!", params);
			return 1;
	}
	return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /tunban <name>");
}

COMMAND:banip (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

	#if defined USE_DATABASE
	    // Actually I have no clue how to implement a range ban system with a database...
	    SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Sorry, this command is currently not available when using JunkBuster database.");
	    return 1;
	#else
		if (!isnull (params))
		{
			if (SplitIp (params) != 0xFFFFFFFF)
			{
				if (BanIp (params))
					JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} IP %s has successfully been banned!", params);
				else
					JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not ban IP %s!", params);
				return 1;
			}
		}
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /banIP <IP> ");
	#endif
}

COMMAND:unbanip (playerid, params [])
{
	if (!IsPlayerAdmin (playerid))
		return 0;

    #if defined USE_DATABASE
	    if (JBDB::UnbanIp (params))
			JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} IP %s has successfully been unbanned!", params);
		else
			JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not unban IP %s!", params);
		return 1;
	#else
		if (!isnull (params))
		{
			if (SplitIp (params) != 0xFFFFFFFF)
			{
				if (UnbanIp (params))
					JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} IP %s has successfully been unbanned!", params);
				else
					JB::SendFormattedMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Could not unban IP %s!", params);
				return 1;
			}
		}
		return SendClientMessage (playerid, JB_RED, "Usage:{D6D6D6} /unbanIP <IP> ");
	#endif
}

//==============================================================================

CALLBACK: OnPlayerEnterVehicle (playerid, vehicleid, ispassenger)
{
	JB::PlayerInfo [playerid][JB::pVehicleEntered] = vehicleid;
	return 1;
}

CALLBACK: OnPlayerStateChange (playerid, newstate, oldstate)
{
	if (JB::Variables [SPECTATE_HACK] && newstate == PLAYER_STATE_SPECTATING && !JB::IsPlayerAdmin (playerid) && !IsPlayerNPC (playerid) && DOB::GetBit (JB::FullyConnected, playerid) && !DOB::GetBit (JB::Spectating, playerid))
		JB::Ban (playerid, "Spectate hack");

	if (newstate <= 0 || newstate > 6)
	    for (new i = 0; i < MAX_SYNC_TYPES; ++i)
	        SetSyncTime (playerid, i);

	if (newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid = GetPlayerVehicleID (playerid),
			componentid;

		GetVehicleHealth (vehicleid, JB::PlayerInfo [playerid][JB::pVehicleHealth]);
		if (JB::PlayerInfo [playerid][JB::pVehicleHealth] > 1000.0) // Prevent innoncent players getting banned because of vehicle used by the cheaters
			SetVehicleHealth (vehicleid, 1000.0);
			
		if (JB::Variables [DRIVE_BY] >= 3)
		    SetPlayerArmedWeapon (playerid, 0);
		    
        for (new j = 0; j < MAX_COMPONENT_SLOTS; ++j)
	    {
	        componentid = GetVehicleComponentInSlot (vehicleid, j);
	        if (componentid != 0 && componentid != (JB::VehicleComponents [vehicleid]{j} + 999))
	            JB::RemoveVehicleComponent (vehicleid, componentid);
	    }
			
        JB::PlayerInfo [playerid][JB::pLastVehicle] = vehicleid;
		if (JB::PlayerInfo [playerid][JB::pVehicleEntered] != vehicleid && !JB::IsPlayerAdmin (playerid) && !IsPlayerNPC (playerid))
		{
			new driver = INVALID_PLAYER_ID;

			foreach(Player, i)
			{
				if (i != playerid)
				{
					if (JB::PlayerInfo [i][JB::pCurrentState] == PLAYER_STATE_DRIVER)
					{
						if (GetPlayerVehicleID (i) == vehicleid)
						{
							driver = i;
							break;
						}
					}
				}
			}

			if (driver != INVALID_PLAYER_ID)
			{
				JB::Warnings [playerid]{CAR_JACK_HACK}++;
				if (JB::Variables [CAR_JACK_HACK] && JB::Warnings [playerid]{CAR_JACK_HACK} >= MAX_CHECKS)
					JB::Kick (playerid, "Carjack hack");
				else
					JunkBusterReport (playerid, "carjack hack", JB::PlayerInfo [driver][JB::pName]);
			}
			else if (oldstate == PLAYER_STATE_ONFOOT)
			{
			    if (!IsPlayerInRangeOfPoint (playerid, 20.0, JB::PlayerInfo [playerid][JB::pOnFootPos][0], JB::PlayerInfo [playerid][JB::pOnFootPos][1], JB::PlayerInfo [playerid][JB::pOnFootPos][2]))
			    {
			        JB::Warnings [playerid]{VEHICLE_TELEPORT}++;
			        if (JB::Variables [VEHICLE_TELEPORT] && JB::Warnings [playerid]{VEHICLE_TELEPORT} >= MAX_CHECKS)
						JB::Kick (playerid, "Vehicle teleport");
			        else
			            JunkBusterReport (playerid, "vehicle teleport", JB::GetVehicleName (vehicleid));
			    }
			}
		}
	}
	else
	{
	    JB::PlayerInfo [playerid][JB::pVehicleHealth] = 1000.0;
	    if (newstate == PLAYER_STATE_PASSENGER && JB::Variables [DRIVE_BY] >= 4)
			SetPlayerArmedWeapon (playerid, 0);
		JB::PlayerInfo [playerid][JB::pLastVehicle] = 0;
	}

	switch (oldstate)
	{
	    case PLAYER_STATE_PASSENGER:
	        SetSyncTime (playerid, SYNC_TYPE_POS);

	    case PLAYER_STATE_ONFOOT:
			DOB::SetBit (JB::BuyingInAmmuNation, playerid, false);
	}

	JB::PlayerInfo [playerid][JB::pVehicleEntered] = INVALID_VEHICLE_ID;
	JB::PlayerInfo [playerid][JB::pAirbraking] = 0;
	JB::PlayerInfo [playerid][JB::pWallriding] = 0;
	JB::PlayerInfo [playerid][JB::pOldSpeed] = 0;
	JB::PlayerInfo [playerid][JB::pLastAirbrakeSpeed] = 0;
	GetPlayerPos (playerid, JB::PlayerInfo [playerid][JB::pOldAirbrakePos][0], JB::PlayerInfo [playerid][JB::pOldAirbrakePos][1], JB::PlayerInfo [playerid][JB::pOldAirbrakePos][2]);
	return 1;
}

CALLBACK: OnPlayerKeyStateChange (playerid, newkeys, oldkeys)
{
	if (IsPlayerNPC (playerid))
		return 1;
		
    JB::Warnings [playerid]{AFK} = 0;
	JB::PlayerInfo [playerid][JB::pLastKeyPressed] = GetTickCount ();
	
	if (!JB::IsPlayerAdmin (playerid) || !JB::Variables [ADMIN_IMMUNITY])
	{
		if (JB::Variables [CBUG] && JB::PlayerInfo [playerid][JB::pCurrentState] == PLAYER_STATE_ONFOOT)
		{
			switch (GetPlayerWeapon (playerid))
			{
				case 24, 25, 27, 29, 30, 31, 33, 34: // Deagle, Shotung, SPAS12, MP5, AK47, M4, Rifle, Sniper Rifle
				{
					if ((newkeys & KEY_FIRE) || (newkeys == KEY_FIRE))
						JB::PlayerInfo [playerid][JB::pFired] = GetTickCount ();
					else if (((oldkeys & KEY_FIRE) || (oldkeys == KEY_FIRE)) && ((newkeys & KEY_CROUCH) || (newkeys == KEY_CROUCH)) && (GetTickCount () - JB::PlayerInfo [playerid][JB::pFired]) < 750)
					{
						if (++JB::Warnings [playerid]{CBUG} & 1 == 0)
							SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Please stop performing the C-Bug or you will get kicked/banned.");
						else if (JB::Warnings [playerid]{CBUG} >= JB::Variables [CBUG])
							JB::Kick (playerid, "C-Bug");
					}
				}
			}
		}
	}
	
	if (1 <= JB::Variables [DRIVE_BY] <= 2 && PRESSED (KEY_FIRE) && (HOLDING (KEY_LOOK_RIGHT) || HOLDING (KEY_LOOK_LEFT)))
	{
		if (!IsPlayerInPlane (playerid) && GetVehicleModel (GetPlayerVehicleID (playerid)) != 432)//Ignore planes and rhinos.
		{
			new
				weaponid,
				ammo;
				
			GetPlayerWeaponData (playerid, 4, weaponid, ammo);
			if (weaponid != 0 && ammo != 0)//Check if player has got an SMG. Don't punish innoncent players.
			{
				//Take away half of his armour and health. Only stupid idiots would continue with drive-by.
				new Float: var;

				GetPlayerHealth (playerid, var);
				if (var > (5.0))//But don't let him die. That's not funny.
				{
					var = float (floatround (var) / 2);
					JB::SetPlayerHealth (playerid, var);
				}

				GetPlayerArmour (playerid, var);
				var = float (floatround (var) / 2);
				JB::SetPlayerArmour (playerid, var);
				SendClientMessage (playerid, JB_RED, "[Anti-Cheat]{FFFFFF} Please stop performing drive-by!");
				TogglePlayerControllable (playerid, false);
				JB::PlayerInfo [playerid][JB::pFreezeTime] = 3;
				SetSyncTime (playerid, SYNC_TYPE_VEHICLE);
			}
		}
	}
	return 1;
}

CALLBACK: OnDialogResponse (playerid, dialogid, response, listitem, inputtext [])
{
	new len = strlen (inputtext);
		
	for (new i = 0; i < len; ++i)
		if (inputtext [i] == '%')//A % can crash your server if you want to use the inputtext in a formatted string. Let's prevent this.
			inputtext [i] = '#';

	if (IsPlayerAdmin (playerid))
	{
		switch (dialogid)
		{
			case DIALOG_CMDS:
			{
				if (response)
					CallLocalFunction ("OnPlayerCommandText", "is", playerid, JB::AdminCommands [listitem]); //Sexy command list.
				return 1;
			}

			case DIALOG_CFG:
			{
				if (response)
				{
					switch (listitem)
					{
						case 0:
							ShowPlayerVarlistDialog (playerid);

						case 1:
						{
							ConfigJunkBuster ();
							SendClientMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Configuration has been loaded from file.");
							ShowPlayerConfigDialog (playerid);
						}

						case 2:
						{
							SaveJunkBusterVars ();
							SendClientMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Configuration has been saved to file.");
							ShowPlayerConfigDialog (playerid);
						}

						case 3:
						{
							JB::Variables = JB::DefaultVariables;
							SendClientMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} Default configuration has been loaded.");
	    					JB::Log ("JunkBuster variables have been reset to default values.");
							ShowPlayerConfigDialog (playerid);
						}
						
						case 4:
                            ShowPlayerReportDialog (playerid);
						
						case 5:
						{
						    new string [1024];
								
							for (new i = 0; i < sizeof (JB::AdminCommands); ++i)
								format (string, sizeof (string), "%s%s\n", string, JB::AdminCommands [i]);

							ShowPlayerDialog (playerid, DIALOG_CMDS, DIALOG_STYLE_LIST, "JunkBuster Commands", string, "Perform", "Close");
						}
					}
				}
				return 1;
			}

			case DIALOG_VARLIST:
			{
				if (response)
					ShowPlayerSetvarDialog (playerid, listitem);
				else
					ShowPlayerConfigDialog (playerid);
				return 1;
			}

			case DIALOG_SETVAR .. (DIALOG_SETVAR + MAX_JB_VARIABLES - 1):
			{
				if (response)
				{
					new
						var = dialogid - DIALOG_SETVAR,
						setvar = strval (inputtext);
						
					if (isnull (inputtext) || !JB::IsNumeric (inputtext) || setvar < 0)
						ShowPlayerSetvarDialog (playerid, var);
					else
					{
						JB::Variables [var] = setvar;
						JB::SendFormattedMessage (playerid, JB_GREEN, "[Anti-Cheat]{FFFFFF} JunkBuster variable '%s' has successfully been set to %d.", JB::VariableNames [var], JB::Variables [var]);
						JB::LogEx ("%s has set variable '%s' to %d.", JB::PlayerInfo [playerid][JB::pName], JB::VariableNames [var], JB::Variables [var]);
						ShowPlayerVarlistDialog (playerid);
					}
				}
				else
					ShowPlayerVarlistDialog (playerid);
				return 1;
			}
		}
	}

	return 0;
}

CALLBACK: OnRconLoginAttempt (ip [], password [], success)
{
	if (!success)
	{
		new attempts = DOF2::GetInt (BAD_RCON_LOGIN_FILE, ip) + 1;
			
		if (attempts >= MAX_CHECKS)
		{
			new cmd [32];
				
			format (cmd, sizeof (cmd), "banip %s", ip);
			SendRconCommand (cmd);
			JB::LogEx ("Banning IP %s for too many failed RCON-logins.", ip); //Ban the hacker.
		}
		JB::LogEx ("IP %s attempted to log in as RCON-admin with password '%s'.", ip, password);
		DOF2::SetInt (BAD_RCON_LOGIN_FILE, ip, attempts);
		DOF2::SaveFile ();
	}
	else
		JB::LogEx ("IP %s has logged in as RCON-admin", ip);
	return 1;
}

CALLBACK: OnRconCommand (cmd [])
{
	new
		rconcmd [64],
		var [64],
		value;
		
	JB::sscanf (cmd, "ssi", rconcmd, var, value);

	if (!strcmp (rconcmd, "jbsetvar", true))
	{
	    if (SetJBVar (var, value))
	        JB::LogEx ("RCON admin has set variable '%s' to %d.", var, value);
		return 1;
	}

	if (!strcmp (rconcmd, "jbvarlist", true))
	{
		print (" ");
		JB::Log ("Current JunkBuster configuration: ");
		for (new i = 0; i < MAX_JB_VARIABLES; ++i)
			JB::LogEx ("- %s = %d", JB::VariableNames [i], JB::Variables [i]);
		print (" ");
		return 1;
	}
	
	if (!strcmp (rconcmd, "jbload", true))
	{
	    ConfigJunkBuster ();
	    return 1;
	}
	
	if (!strcmp (rconcmd, "jbsave", true))
	{
	    SaveJunkBusterVars ();
	    return 1;
	}
	
	if (!strcmp (rconcmd, "jbdefault", true))
	{
	    JB::Variables = JB::DefaultVariables;
	    JB::Log ("JunkBuster variables have been reset to default values by an RCON admin.");
	    return 1;
	}
	
	if (!strcmp (rconcmd, "unbanme", true))
	{
	    SendRconCommand ("unbanip 127.0.0.1");
	    return 1;
	}
	
	if (!strcmp (rconcmd, "jbunbanip", true))
	{
	    UnbanIp (var);
	    return 1;
	}
	
	if (!strcmp (rconcmd, "jbbanip", true))
	{
	    BanIp (var);
	    return 1;
	}
	
	if (!strcmp (rconcmd, "blackadd", true))
	{
	    AddNameToBlacklist (var);
	    return 1;
	}
	
	if (!strcmp (rconcmd, "blackdel", true))
	{
	    RemoveNameFromWhitelist (var);
	    return 1;
	}
	
	if (!strcmp (rconcmd, "whiteadd", true))
	{
	    AddNameToWhitelist (var);
	    return 1;
	}

	if (!strcmp (rconcmd, "whitedel", true))
	{
	    RemoveNameFromWhitelist (var);
	    return 1;
	}
	return 0;
}

CALLBACK: OnPlayerEnterRaceCheckpoint (playerid)
{
	if (IsPlayerNPC (playerid))
		return 1;

	if (!JB::SyncInfo [playerid][SYNC_TYPE_POS][JB::sSyncTime] && !JB::IsPlayerAdmin (playerid))
	{
		if (JB::Variables [CHECKPOINT_TELEPORT])
		{
			if (!JB::GetPlayerSpeed (playerid, false))
			{
				JB::Warnings [playerid]{CHECKPOINT_TELEPORT}++;
				if (JB::Warnings [playerid]{CHECKPOINT_TELEPORT} >= MAX_CHECKS)
					JB::Ban (playerid, "Checkpoint teleport");
				else
				{
					new string [128];
						
					format (string, sizeof (string), "checkpoint teleport (Warning %d)", JB::Warnings [playerid]{CHECKPOINT_TELEPORT});
					JunkBusterReport (playerid, "teleport cheats", string);
				}
			}
		}
	}
	return 1;
}

//==============================================================================

PRIVATE: strcpy (dest [], src [], size = sizeof (dest))
{
	dest [0] = '\0';
	return strcat (dest, src, size);
}

PRIVATE: JB::sscanf (string [], format [], {Float, _}: ...)
{
	#if defined isnull
		if (isnull (string))
	#else
		if (string [0] == 0 || (string [0] == 1 && string [1] == 0))
	#endif
		{
			return format [0];
		}
	#pragma tabsize 4
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs (),
		delim = ' ';
	while (string [stringPos] && string [stringPos] <= ' ')
	{
		stringPos++;
	}
	while (paramPos < paramCount && string [stringPos])
	{
		switch (format [formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0,
					ch = string [stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string [++stringPos];
				}
				do
				{
					stringPos++;
					if ('0' <= ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string [stringPos]) > ' ' && ch != delim);
				setarg (paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0,
					ch = string [stringPos];
				do
				{
					stringPos++;
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				while ((ch = string [stringPos]) > ' ' && ch != delim);
				setarg (paramPos, 0, num);
			}
			case 'c':
			{
				setarg (paramPos, 0, string [stringPos++]);
			}
			case 'f':
			{

				new changestr [16], changepos = 0, strpos = stringPos;
				while (changepos < 16 && string [strpos] && string [strpos] != delim)
				{
					changestr [changepos++] = string [strpos++];
				}
				changestr [changepos] = '\0';
				setarg (paramPos, 0, _: floatstr (changestr));
			}
			case 'p':
			{
				delim = format [formatPos++];
				continue;
			}
			case '\'':
			{
				new
					end = formatPos - 1,
					ch;
				while ((ch = format [++end]) && ch != '\'') {}
				if (!ch)
				{
					return -1;
				}
				format [end] = '\0';
				if ((ch = strfind (string, format [formatPos], false, stringPos)) == -1)
				{
					if (format [end + 1])
					{
						return -1;
					}
					return 0;
				}
				format [end] = '\'';
				stringPos = ch + (end - formatPos);
				formatPos = end + 1;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool: num = true,
					ch;
				while ((ch = string [++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected (id))
				{
					setarg (paramPos, 0, id);
				}
				else
				{
	 				string [end] = '\0';
					num = false;
					id = end - stringPos;
					foreach(Player, playerid)
					{
						if (!strcmp (JB::PlayerInfo [playerid][JB::pName], string [stringPos], true, id))
						{
							setarg (paramPos, 0, playerid);
							num = true;
							break;
						}
					}
					if (!num)
					{
						setarg (paramPos, 0, INVALID_PLAYER_ID);
					}
					string [end] = ch;
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0,
					ch;
				if (format [formatPos])
				{
					while ((ch = string [stringPos++]) && ch != delim)
					{
						setarg (paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string [stringPos++]))
					{
						setarg (paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg (paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string [stringPos] && string [stringPos] != delim && string [stringPos] > ' ')
		{
			stringPos++;
		}
		while (string [stringPos] && (string [stringPos] == delim || string [stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	do
	{
		if ((delim = format [formatPos++]) > ' ')
		{
			if (delim == '\'')
			{
				while ((delim = format [formatPos++]) && delim != '\'') {}
			}
			else if (delim != 'z')
			{
				return delim;
			}
		}
	}
	while (delim > ' ');
	return 0;
}

#if !defined I_AM_NO_RETARD

#endif
