// Gamemode script
// Developers:
// - Olly
// - 

#include <a_samp>
#include <a_mysql>
#include <easyDialog>
#include <bcrypt>
#include <zcmd>
#include <betterdialogs>
#include <sscanf2>
#include <streamer>
#include <cuffs>
#include <multilines>

#define Labels // 3D Labels above the Fires 
#define Holding(%0) \
	((newkeys & (%0)) == (%0))
#define MAX_FIRES 100
forward OnFireKill(ID, killerid);
forward VehicleToPoint(Float:radi, vehicleid, Float:x, Float:y, Float:z);
forward HealthDown();
new
    FireObj[MAX_FIRES],
    Float:FirePos[MAX_FIRES][3],
	TotalFires = 0,
	FireHealth[MAX_FIRES],
	FireHealthMax[MAX_FIRES];

#if defined Labels
new Text3D:FireText[MAX_FIRES];
#endif

#define BCRYPT_COST 12
#define lenull(%1) \
((!( % 1[0])) || ((( % 1[0]) == '\1') && (!( % 1[1]))))
#define MAX_JOBS 100
#define MAX_FACTIONS 100


#define GREY 			0xCECECEFF
#define SPECIALORANGE   0xFFCC00FF // CRP Orange 0xFF8000FF
#define SERVERCOLOR 	0xA9C4E4FF //0x99CEFFFF 94ABC8
#define NICESKY 		0xC2A2DAFF // rp color
#define ADMINBLUE 		0x1D7CF2FF //0059E8
#define COLOR_AQUA 0xF0F8FFAA


#define     VEHICLE_NOT_RENTABLE    0
#define     VEHICLE_RENTABLE        1
#define     VEHICLE_PLAYER_OWNED    2
#define     VEHICLE_NOT_RENTED      0
#define     VEHICLE_RENTED      	1


main() {
    print("\n----------------------------------");
    print(" Gamemode started... please wait...");
    print("----------------------------------\n");
}

/* 1- NEWS -*/
new MySQL:db_handle;


new Menu:busdrivermenu, Menu:hardwaremenu, Menu:phonemenu, Menu:gpsmenu, Menu:AmmunationMenu, Menu:Pistols, Menu:SMGS, Menu:shotguns, Menu:Rifles, Menu:Armour;

new PostCheckpoint[MAX_PLAYERS], JobCheckpoint[MAX_PLAYERS], GarbageCheckpoint[MAX_PLAYERS];
new dumpCheckPoint[MAX_PLAYERS], routeId[MAX_PLAYERS], busCheckpoint[MAX_PLAYERS], drugDeal[MAX_PLAYERS];
new speedoTimer[MAX_PLAYERS], fuelTimer[MAX_PLAYERS], drugDealTimer[MAX_PLAYERS];

new policeCall[MAX_PLAYERS], towingCall[MAX_PLAYERS];
new policeMainDoor, policeMainCell, cell1, cell2, cell3, cell4, impoundGate;
new medicsMainDoor;

new dumpPickup, jobPickup[MAX_JOBS];
new busInfoPickup[100], busEntPickup[100], busExitPickup[100], busUsePickup[100];
new houseInfoPickup[100], houseEntPickup[100], houseExitPickup[100];
new facInfoPickup[100], facDutyPickup[100], facClothesPickup[100];
new facEntPickup[100], facExitPickup[100];

new fireCallTimer[MAX_FIRES];

new PlayerText:VEHSTUFF[MAX_PLAYERS][5];

new PLights[MAX_VEHICLES];
new TLI, TLI2;
 
forward TimerBlinkingLights(vehicleid);
forward TimerBlinkingLights2(vehicleid);
forward BlinkingLights(playerid);
forward ShutOffBlinkingLights(playerid);
forward encode_lights(light1, light2, light3, light4);


new PlayerText:dash1[MAX_PLAYERS];
new PlayerText:dash2[MAX_PLAYERS];
new PlayerText:dashPlate[MAX_PLAYERS];
new PlayerText:dashSpeed[MAX_PLAYERS];
new PlayerText:dashDist[MAX_PLAYERS];
new PlayerText:dashVid[MAX_PLAYERS];

new PlayerText:PlayerAddress[MAX_PLAYERS][4];
new PlayerText:businessBox[MAX_PLAYERS];
new PlayerText:addressName[MAX_PLAYERS];
new PlayerText:addressNameString[MAX_PLAYERS];
new PlayerText:addressBox[MAX_PLAYERS];
new PlayerText:addressString[MAX_PLAYERS];
new PlayerText:addressStatus[MAX_PLAYERS];
new PlayerText:addressType[MAX_PLAYERS];
new PlayerText:addressPrice[MAX_PLAYERS];


new Text:NotOnDuty;
new Text:accessDoor;
new Text:PublicTD[3];
new Text:sheriffsoffice[4];
new Text:hospital[3];
new Text:bank[3];
new Text:cardealer[3];
new Text:finishtutorial[3];
new Text:PMuted;
new Text:NoHelpmes;
new Text:NoReports;
new Text:CantCommand, Text:CantTakePost, Text:NoBinBags;

new RoutePay[] = {
    300,
    400,
    125
};

new Float:RandomPostLocations[][3] = {
    { 94.8995, 1183.6771, 18.0150 },
    {-177.2173, 1213.1268, 19.2113 },
    {-208.2337, 973.4498, 18.3233 },
    {-321.9125, 1055.7777, 19.1717 },
    {-362.2701, 1165.2568, 19.2094 },
    {-208.0344, 1112.1625, 19.2098 }
};

new Float:RandomGarbageLocations[][3] = {
    { 94.8995, 1183.6771, 18.0150 },
    {-177.2173, 1213.1268, 19.2113 },
    {-208.2337, 973.4498, 18.3233 },
    {-321.9125, 1055.7777, 19.1717 },
    {-362.2701, 1165.2568, 19.2094 },
    {-208.0344, 1112.1625, 19.2098 }
};

new Float:randomdrugdeals[][3] = {
    {-14.3074, 1226.7869, 18.4454},
    {23.2193, 1164.6573, 18.5577},
    {-51.8717, 1165.2013, 18.6198}
};

new Float:busObject[][4] = {
    {-281.6187, 1170.1730, 19.7832, 0.0000},
    {-351.6738, 1122.1995, 19.7832, 0.0000},
    {-281.9393, 1037.8536, 19.7832, 0.0000},
    {-199.3061, 960.7129, 17.6637, 0.0000},
    {-279.2794, 903.4935, 11.8586, 20.7833},
    {-554.8635, 1108.9758, 11.5790, 56.2904},
    {-755.9011, 738.8364, 18.2921, 325.8446},
    {-356.9895, 544.6367, 16.7502, 81.4697},
    {76.3922, 642.9280, 6.5915, 117.3704},
    {344.7141, 727.7280, 9.3864, 209.0105},
    {263.9272, 978.1386, 28.4293, 111.8186},
    {800.8280, 1125.6385, 28.6225, 124.5017},
    {841.8600, 1713.1047, 6.1961, 192.0606},
    {693.4581, 1866.5504, 5.8549, 262.6922},
    {482.0066, 1659.7740, 14.7270, 299.9181},
    {192.2281, 1170.1422, 14.9482, 325.8821},
    {38.0655, 1204.9498, 19.2712, 271.8622},

    //Fort carson LOOP
    {-201.8537, 1173.9659, 19.7763, 0.0000},
    {-133.9370, 1091.8904, 19.8795, 90.0000},
    {-40.9731, 1016.5122, 19.7397, 90.0000},
    {35.9185, 1122.9139, 19.7783, 180.0000},
    {-58.8452, 1182.4476, 19.6180, 180.0000},
    {-220.2953, 1246.4258, 23.3962, -90.0000},
    {-438.3150, 1474.7195, 34.2605, 180.0000},
    {-441.7047, 1769.8910, 72.3647, 296.4569},
    {-731.5360, 2061.5767, 60.5356, 96.8976},
    {-890.4467, 1803.8699, 60.6641, 293.3637},
    {-1100.1838, 1741.6031, 33.1263, 61.8473},
    {-856.4813, 1484.9619, 17.6349, 0.0000},
    {-655.8999, 1216.0162, 12.3312, 82.8859},
    {-381.8099, 976.9009, 10.8624, 29.2169},
    {-306.0473, 820.9340, 14.0127, 8.4419},
    {-201.5049, 881.0867, 10.3240, 149.9598},
    {-184.0526, 1117.7760, 19.7757, 180.0000},

    // express
    {-254.0678, 1204.7655, 19.8921, -90.0000 },
    {-281.8794, 1081.2390, 19.7088, 0.0000 },
    {-184.4253, 1063.7166, 19.8921, 180.0000 },
    {-152.1365, 1092.1180, 19.8921, 90.0000 },
    {-59.0811, 1123.8838, 19.8921, 180.0000 },
    { 54.0659, 1192.2245, 19.8921, 90.0000 },
    { 65.8657, 1249.7249, 17.7258, 245.6365 },
    {-123.0387, 1230.5771, 18.7788, 6.1884 }
};

new Float:ClassicStops[][3] = {
    {-278.0308, 1169.4193, 18.5795},
    {-348.2357, 1122.8986, 18.5794},
    {-278.2794, 1038.0569, 18.5845},
    {-195.4032, 961.7260, 16.5470},
    {-283.3341, 902.3236, 10.3310},
    {-557.5754, 1103.6727, 10.0092},
    {-752.3760, 736.4799, 17.1416},
    {-355.8842, 550.3585, 15.4051},
    {73.9916, 647.5514, 5.1911},
    {341.2138, 724.5412, 8.3957},
    {262.1244, 982.8416, 27.1757},
    {797.0475, 1129.6514, 27.4107},
    {836.0959, 1712.4144, 4.6246},
    {692.7012, 1862.0048, 4.5803},
    {483.8451, 1655.6417, 13.4645},
    {195.7803, 1168.1116, 13.8286},
    {38.7248, 1200.6976, 17.8346}
};

new Float:FortCarsonLoopStops[][3] = {
    {-198.2140, 1173.5037, 18.5812},
    {-134.1615, 1095.5880, 18.5823},
    {-41.3756, 1020.7316, 18.5823},
    {31.8862, 1122.4478, 18.5766},
    {-62.9441, 1182.1210, 18.5359},
    {-221.5766, 1242.3821, 22.2409},
    {-442.4277, 1474.3597, 33.1526},
    {-439.0397, 1763.8916, 71.0105},
    {-733.3111, 2069.2063, 59.1679},
    {-888.0124, 1798.8232, 59.2779},
    {-1098.0883, 1745.4121, 31.7598},
    {-851.1487, 1485.4338, 16.5763},
    {-655.8133, 1220.7173, 11.1303},
    {-376.9046, 979.2209, 9.3838},
    {-301.8374, 822.1568, 12.8859},
    {-204.9120, 884.6138, 9.2884},
    {-187.7946, 1118.6029, 18.5713}
};

new Float:ExpressStops[][3] = {
    {-254.1759, 1200.1873, 20.3816 },
    {-278.3591, 1082.1646, 19.3810 },
    {-187.9721, 1063.9950, 19.0946 },
    {-152.4380, 1095.5483, 19.0946 },
    {-63.0088, 1124.2401, 19.0946 },
    { 54.8343, 1195.8729, 19.0946 },
    { 63.3990, 1246.7830, 17.0584 },
    {-119.0424, 1229.4414, 17.9745 }
};

new maleSkins[] = {
    20,
    23,
    15,
    24,
    25,
    60,
    72,
    73,
    125,
    143,
    170
};

new femaleSkins[] = {
    40,
    11,
    69,
    192,
    150,
    76,
    226,
    233,
    198,
    197
};


new VehicleNames[][] = {
    "Landstalker",
    "Bravura",
    "Buffalo",
    "Linerunner",
    "Perrenial",
    "Sentinel",
    "Dumper",
    "Firetruck",
    "Trashmaster",
    "Stretch",
    "Manana",
    "Infernus",
    "Voodoo",
    "Pony",
    "Mule",
    "Cheetah",
    "Ambulance",
    "Leviathan",
    "Moonbeam",
    "Esperanto",
    "Taxi",
    "Washington",
    "Bobcat",
    "Whoopee",
    "BF Injection",
    "Hunter",
    "Premier",
    "Enforcer",
    "Securicar",
    "Banshee",
    "Predator",
    "Bus",
    "Rhino",
    "Barracks",
    "Hotknife",
    "Trailer",
    "Previon",
    "Coach",
    "Cabbie",
    "Stallion",
    "Rumpo",
    "RC Bandit",
    "Romero",
    "Packer",
    "Monster",
    "Admiral",
    "Squalo",
    "Seasparrow",
    "Pizzaboy",
    "Tram",
    "Trailer",
    "Turismo",
    "Speeder",
    "Reefer",
    "Tropic",
    "Flatbed",
    "Yankee",
    "Caddy",
    "Solair",
    "Berkley's RC Van",
    "Skimmer",
    "PCJ-600",
    "Faggio",
    "Freeway",
    "RC Baron",
    "RC Raider",
    "Glendale",
    "Oceanic",
    "Sanchez",
    "Sparrow",
    "Patriot",
    "Quad",
    "Coastguard",
    "Dinghy",
    "Hermes",
    "Sabre",
    "Rustler",
    "ZR-350",
    "Walton",
    "Regina",
    "Comet",
    "BMX",
    "Burrito",
    "Camper",
    "Marquis",
    "Baggage",
    "Dozer",
    "Maverick",
    "News Chopper",
    "Rancher",
    "FBI Rancher",
    "Virgo",
    "Greenwood",
    "Jetmax",
    "Hotring",
    "Sandking",
    "Blista Compact",
    "Police Maverick",
    "Boxville",
    "Benson",
    "Mesa",
    "RC Goblin",
    "Hotring Racer A",
    "Hotring Racer B",
    "Bloodring Banger",
    "Rancher",
    "Super GT",
    "Elegant",
    "Journey",
    "Bike",
    "Mountain Bike",
    "Beagle",
    "Cropduster",
    "Stunt",
    "Tanker",
    "Roadtrain",
    "Nebula",
    "Majestic",
    "Buccaneer",
    "Shamal",
    "Hydra",
    "FCR-900",
    "NRG-500",
    "HPV1000",
    "Cement Truck",
    "Tow Truck",
    "Fortune",
    "Cadrona",
    "FBI Truck",
    "Willard",
    "Forklift",
    "Tractor",
    "Combine",
    "Feltzer",
    "Remington",
    "Slamvan",
    "Blade",
    "Freight",
    "Streak",
    "Vortex",
    "Vincent",
    "Bullet",
    "Clover",
    "Sadler",
    "Firetruck",
    "Hustler",
    "Intruder",
    "Primo",
    "Cargobob",
    "Tampa",
    "Sunrise",
    "Merit",
    "Utility",
    "Nevada",
    "Yosemite",
    "Windsor",
    "Monster",
    "Monster",
    "Uranus",
    "Jester",
    "Sultan",
    "Stratium",
    "Elegy",
    "Raindance",
    "RC Tiger",
    "Flash",
    "Tahoma",
    "Savanna",
    "Bandito",
    "Freight Flat",
    "Streak Carriage",
    "Kart",
    "Mower",
    "Dune",
    "Sweeper",
    "Broadway",
    "Tornado",
    "AT-400",
    "DFT-30",
    "Huntley",
    "Stafford",
    "BF-400",
    "News Van",
    "Tug",
    "Trailer",
    "Emperor",
    "Wayfarer",
    "Euros",
    "Hotdog",
    "Club",
    "Freight Box",
    "Trailer",
    "Andromada",
    "Dodo",
    "RC Cam",
    "Launch",
    "Police Car",
    "Police Car",
    "Police Car",
    "Police Ranger",
    "Picador",
    "S.W.A.T",
    "Alpha",
    "Phoenix",
    "Glendale",
    "Sadler",
    "Luggage",
    "Luggage",
    "Stairs",
    "Boxville",
    "Tiller",
    "Utility Trailer"
};

new tries[MAX_PLAYERS], passwordForFinalReg[MAX_PLAYERS][BCRYPT_HASH_LENGTH], quizAttempts[MAX_PLAYERS];

enum ENUM_POLICECLOTHES {
    SKINID,
    SKINNAME[32]
};
new const POLICECLOTHES[][ENUM_POLICECLOTHES] = {
    {288, "Desert Sheriff"},
    {302, "LV Police Officer"},
    {310, "County Sheriff"},
    {283, "County Sheriff"},
    {311, "Desert Sherriff without Hat"},
    {306, "Female LS Police Officer"},
    {307, "Female LV Police Officer"},
    {284, "Motorcycle Cop"},
    {285, "Swat Gear"}
};

enum ENUM_MEDICCLOTHES {
    SKINID,
    SKINNAME[32]
};
new const MEDICCLOTHES[][ENUM_MEDICCLOTHES] = {
    {274, "Emergency Responder"},
    {275, "Emergency Responder"},
    {276, "Emergency Responder"},
    {70, "Doctor"},
    {71, "Emergency Responder"},
    {307, "Female LV Police Officer"}
};


enum ENUM_TOWCLOTHES {
    SKINID,
    SKINNAME[32]
};
new const TOWCLOTHES[][ENUM_TOWCLOTHES] = {
    {50, "Mechanic"},
    {153, "Chief"},
    {247, "Bike Mechanic"},
    {175, "Mechanic"}
};


enum ENUM_CARDEAL_DATA {
    VEHICLE_MODELID,
    VEHICLE_NAME[32],
    VEHICLE_PRICE,
    VEHICLE_ID2
};

new const BUS_DEALERSHIP[][ENUM_CARDEAL_DATA] = {
    {400, "Landstalker", 4500, 400},
    {404, "Perennial", 3950, 404},
    {412, "Voodoo", 3600, 412},
    {413, "Boxville", 4750, 413},
    {415, "Cheetah", 61295, 415},
    {418, "Moonbeam", 6250, 418},
    {421, "Washington", 7500, 421},
    {422, "Bobcat", 6000, 422},
    {429, "Banshee", 62599, 429},
    {444, "Monster", 72100, 444},
    {451, "Turismo", 82999, 451},
    {461, "PCJ-600", 16500, 461},
    {463, "Freeway", 15599, 463},
    {468, "Sanchez", 13599, 468},
    {470, "Patriot", 56950, 470},
    {475, "Sabre", 10195, 475},
    {477, "ZR-350", 59520, 477},
    {489, "Rancher", 25900, 489},
    {496, "Blista Compact", 18500, 496}
};

enum ENUM_PLAYER_DATA {
    ID[32],
        pName[MAX_PLAYER_NAME],
        pPassword[255],
        HashedPassword[BCRYPT_HASH_LENGTH],
        pEmail[128],
        pLevel,
        pExp,
        pRegion[32],
        Float:pHealth,
        Float:pArmour,
        pGender,
        pSkin,
        pAge,
        pBank,
        pCash,
        pPayTimer,
        pPhoneNumber,
        pPhoneModel,
        pGpsModel,

        pFactionId,
        pFactionRank,
        pFactionRankname[32],
        pFactionPay,
        pDuty,
        pDutyClothes,

        pFines, // fine cmd
        pMostRecentFine[32],

        pWantedLevel, // ca cmd
        pMostRecentWantedReason[32],

        pInPrisonType, // can be admin or normal jail cell.
        pPrisonTimer,

        pJobId,
        pJobPay,
        pWeedAmount,
        pCokeAmount,

        pCigAmount,
        pRopeAmount,
        pHasMask,
        pLottoNumbers,

        pDrivingLicense,
        pHeavyLicense,
        pPilotLicense,
        pGunLicense,

        pWeaponSlot1,
        pWeaponSlot1Ammo,
        pWeaponSlot2,
        pWeaponSlot2Ammo,
        pWeaponSlot3,
        pWeaponSlot3Ammo,

        pVehicleSlotsUsed,
        pVehicleSlots,

        pPreferredSpawn,

        pAlertCall,
        pAlertMsg[64],

        pAdminLevel,
        pModerator,
        pHelper,

        bool:LoggedIn,
        pMuted,
        CurrentState,
        PostState,
        GarbageState,
        busStopState,
        pDragged,
        DashCamStatus,
        OnCall,
        BeingCalled,
        CalledService,
        AwaitingReason,

        SentHAccept,
        AwaitingHAccept,
        SentRAccept,
        AwaitingRAccept,
        SentRPrice,

        SentAdv,
        AdvMsg[100],
        SelectedAd,

        RentingVehicle
}
new pInfo[MAX_PLAYERS][ENUM_PLAYER_DATA];

enum SERVER_STATS{
    lastFireType,
    lastFireAddress,
    firePutOut
}
new sInfo[2][SERVER_STATS]; //sInfo[0][lastFireType] -- only need to affect the first entry!!!, on gamemodeinit, start a fire!

new dragState[MAX_PLAYERS], dashtimer[MAX_PLAYERS], callTimer[MAX_PLAYERS];

enum ENUM_JOB_DATA {
    jID[11],
        jName[32],
        jPay,
        Float:jobIX,
        Float:jobIY,
        Float:jobIZ
}
new jInfo[MAX_JOBS][ENUM_JOB_DATA], loadedJob;

enum ENUM_VEH_DATA {
    vID[32],
        vModelId,
        vOwner[32],
        vFuel,
        vJobId,
        vFacId,
        vBusId,
        vFines,
        vMostRecentFine[32],
        vImpounded,
        vPlate[32],
        Float:vParkedX,
        Float:vParkedY,
        Float:vParkedZ,
        Float:vAngle,
        vColor1,
        vColor2,
        vRentingPlayer,
        vRented,
        vRentalState,
        vRentalPrice,

        SirenStatus,
        IsLive
}
new vInfo[500][ENUM_VEH_DATA], loadedVeh;

enum ENUM_HOUSE_DATA{
    hId[32],
    hAddress,
    hType,
    hOwner[32],
    hPrice,
    hLockedState,
    Float:hInfoX,
    Float:hInfoY,
    Float:hInfoZ,
    Float:hEntX,
    Float:hEntY,
    Float:hEntZ,
    Float:hExitX,
    Float:hExitY,
    Float:hExitZ,
    OnFire
};
new hInfo[500][ENUM_HOUSE_DATA], loadedHouse;

enum ENUM_BUS_DATA {
    bId[32],
    bName[50],
    bAddress,
    bPrice,
    bSalary,
    bOwner[32],
    bType,
    bIntId,
    Float:bInfoX,
    Float:bInfoY,
    Float:bInfoZ,
    Float:bEntX,
    Float:bEntY,
    Float:bEntZ,
    Float:bUseX,
    Float:bUseY,
    Float:bUseZ,
    Float:bExitX,
    Float:bExitY,
    Float:bExitZ,
    OnFire
};
new bInfo[500][ENUM_BUS_DATA], loadedBus;

enum ENUM_FAC_DATA {
    fID[32],
        fName[32],
        fAddress,
        fLeader[32],
        fType, // 1 = gang 2 = legal
        fPrice,
        fRank1Name[32],
        fRank2Name[32],
        fRank3Name[32],
        fRank4Name[32],
        fRank5Name[32],
        fRank6Name[32],
        fRank7Name[32],
        Float:fInfoX,
        Float:fInfoY,
        Float:fInfoZ,
        Float:fDutyX,
        Float:fDutyY,
        Float:fDutyZ,
        Float:fClothesX,
        Float:fClothesY,
        Float:fClothesZ,
        Float:fEntX,
        Float:fEntY,
        Float:fEntZ,
        Float:fExitX,
        Float:fExitY,
        Float:fExitZ,

        IsLive,
        OnFire
}
new fInfo[MAX_FACTIONS][ENUM_FAC_DATA], loadedFac;

enum ENUM_DRUG_PRICES{
    drugId[32],
    drugName[32],
    drugAmount,
    drugPrice
};
new drugInfo[15][ENUM_DRUG_PRICES], loadedDrug;
new myobject[MAX_VEHICLES], copCarSiren[MAX_VEHICLES], rancherSiren[MAX_VEHICLES];


public OnGameModeInit() {
    mysql_log(ALL);
    ManualVehicleEngineAndLights();
    DisableInteriorEnterExits();
    // Don't use these lines if it's a filterscript
    SetGameModeText("Roleplay | v1.5.2");
    
    sInfo[0][firePutOut] = 0;
    sInfo[0][lastFireAddress] = 0;
    sInfo[0][lastFireType] = 0;

    /* MySQL info */
    db_handle = mysql_connect_file("mysql.ini"); // Database info!

    if(db_handle == MYSQL_INVALID_HANDLE || mysql_errno(db_handle) != 0) {
        printf("** [MYSQL] Failed to connect! Exiting gamemode!");
        SendRconCommand("exit");
        return 1;
    }
    printf("** [MYSQL] Connected successfully! Proceeding to load the gamemode!");


    LoadJobData();
    LoadFacData();
    LoadHouseData();
    LoadBusData();
    CreateBusStopObjects();
    LoadVehicleData();
    LoadDrugPrices();
    SetTimer("startARandomFire", 25000, false);

    

    
    // FCPD
    policeMainDoor = CreateDynamicObject(1535, -2689.00903, 2646.06396, 4086.79517, 0.00000, 0.00000, 270.00000);
    policeMainCell = CreateDynamicObject(19302, -2666.55249, 2641.79932, 4081.68091,   0.00000, 0.00000, 90.00000);
    cell1 = 	CreateDynamicObject(19302, -2664.75830, 2643.68066, 4081.68091,   0.00000, 0.00000, 180.00000);
    cell2 = 	CreateDynamicObject(19302, -2658.35400, 2643.65918, 4081.68091,   0.00000, 0.00000, 180.00000);
    cell4 = 	CreateDynamicObject(19302, -2664.77002, 2640.15576, 4081.68091,   0.00000, 0.00000, 180.00000);
    cell3 = 	CreateDynamicObject(19302, -2658.35254, 2640.17212, 4081.68091,   0.00000, 0.00000, 180.00000);
    impoundGate = 	CreateDynamicObject(969, -180.26389, 1010.19574, 18.92880,   0.00000, 0.00000, 90.00000); // gate

// ems
    medicsMainDoor = CreateDynamicObject(1535, -2081.04126, 2902.94800, 5067.21533,   0.00000, 0.00000, 270.00000);

    // DUMP 
    dumpPickup = CreatePickup(1239, 1, 281.7589, 1411.7045, 10.5003, -1);

    /* POSTMAN
    CreateDynamicObject(17038, -94.66439, 1130.53223, 18.72370, 0.00000, 0.00000, 180.00000);
    CreateDynamicObject(6959, -92.12310, 1125.20642, 18.73150, 0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1345, -90.60535, 1130.87866, 19.46094, 356.85840, 0.00000, -1.57080);
    CreateDynamicObject(1345, -90.60535, 1130.87866, 19.46094, 356.85840, 0.00000, -1.57080);
    CreateDynamicObject(1232, -76.37077, 1137.26379, 21.30760, 0.00000, 0.00000, 0.00000);
    CreateDynamicObject(1286, -85.68120, 1137.99756, 19.24240, 0.00000, 0.00000, 181.43620);
    CreateDynamicObject(1289, -86.81896, 1137.96716, 19.24240, 0.00000, 0.00000, 180.00000);
    CreateDynamicObject(1287, -86.27790, 1138.02942, 19.24240, 0.00000, 0.00000, 181.43620);
    CreateDynamicObject(1285, -85.16120, 1137.99756, 19.24240, 0.00000, 0.00000, 181.43620);
    CreateDynamicObject(1286, -84.60120, 1137.99756, 19.24240, 0.00000, 0.00000, 181.43620);
    CreateDynamicObject(1508, -96.28460, 1117.77185, 20.30520, 0.00000, 0.00000, 90.00000);
    CreateDynamicObject(1334, -102.79440, 1116.40662, 19.81580, 0.00000, 0.00000, 40.00000);*/

    // BUS DRIVER

    CreateDynamicObject(17038, -252.32233, 1216.70703, 18.72150, 0.00000, 0.00000, 90.00000);


    AmmunationMenu = CreateMenu("Ammunation", 1, 30.000000, 160.000000, 160.000000, 0.000000);
    AddMenuItem(AmmunationMenu, 0, "Pistols");
    AddMenuItem(AmmunationMenu, 0, "SMGS");
    AddMenuItem(AmmunationMenu, 0, "Shotguns");
    AddMenuItem(AmmunationMenu, 0, "Rifles");
    AddMenuItem(AmmunationMenu, 0, "Armour");


    Pistols = CreateMenu("Ammunation", 2, 30.000000, 160.000000, 90.000000, 90.000000);
   
    SetMenuColumnHeader(Pistols, 0, "Name");
    SetMenuColumnHeader(Pistols, 1, "Price");
    AddMenuItem(Pistols, 0, "Glock-18");
    AddMenuItem(Pistols, 1, "$750");
    AddMenuItem(Pistols, 0, "Desert Eagle");
    AddMenuItem(Pistols, 1, "$1250");

    
    SMGS = CreateMenu("Ammunation", 2, 30.000000, 160.000000, 90.000000, 90.000000);
      
    SetMenuColumnHeader(SMGS, 0, "Name");
    SetMenuColumnHeader(SMGS, 1, "Price");
    AddMenuItem(SMGS, 0, "MP5");
    AddMenuItem(SMGS, 1, "$5000");
    
    shotguns = CreateMenu("Ammunation", 2, 30.000000, 160.000000, 90.000000, 90.000000);
        
    SetMenuColumnHeader(shotguns, 0, "Name");
    SetMenuColumnHeader(shotguns, 1, "Price");
    AddMenuItem(shotguns, 0, "Shotgun");
    AddMenuItem(shotguns, 1, "$3000");

    Rifles = CreateMenu("Ammunation", 2, 30.000000, 160.000000, 90.000000, 90.000000);
    
    SetMenuColumnHeader(Rifles, 0, "Name");
    SetMenuColumnHeader(Rifles, 1, "Price");
    AddMenuItem(Rifles, 0, "Rifle");
    AddMenuItem(Rifles, 1, "$4500");


    Armour = CreateMenu("Ammunation", 2, 30.000000, 160.000000, 90.000000, 90.000000);
        
    SetMenuColumnHeader(Armour, 0, "Name");
    SetMenuColumnHeader(Armour, 1, "Price");
    AddMenuItem(Armour, 0, "Heavy Armour");
    AddMenuItem(Armour, 1, "$1000");
    AddMenuItem(Armour, 0, "Light Armour");
    AddMenuItem(Armour, 1, "$350");

    hardwaremenu = CreateMenu("Hardware Store", 2, 200.0, 100.0, 100.0, 100.0);
    AddMenuItem(hardwaremenu, 0, "Phones");
    AddMenuItem(hardwaremenu, 0, "GPS");

    phonemenu = CreateMenu("Hardware Store", 2, 200.0, 100.0, 100.0, 100.0);    
    SetMenuColumnHeader(phonemenu, 0, "Name");
    SetMenuColumnHeader(phonemenu, 1, "Price");
    AddMenuItem(phonemenu, 0, "Nokia");
    AddMenuItem(phonemenu, 1, "$150");
    AddMenuItem(phonemenu, 0, "LG");
    AddMenuItem(phonemenu, 1, "$180");
    AddMenuItem(phonemenu, 0, "Sony");
    AddMenuItem(phonemenu, 1, "$200");
    AddMenuItem(phonemenu, 0, "Samsung");
    AddMenuItem(phonemenu, 1, "$250");
    AddMenuItem(phonemenu, 0, "iFruit X");
    AddMenuItem(phonemenu, 1, "$300");

    gpsmenu = CreateMenu("Hardware Store", 2, 200.0, 100.0, 100.0, 100.0);   
    SetMenuColumnHeader(gpsmenu, 0, "Name");
    SetMenuColumnHeader(gpsmenu, 1, "Price");  
    AddMenuItem(gpsmenu, 0, "TomTom");
    AddMenuItem(gpsmenu, 1, "$400");   
    AddMenuItem(gpsmenu, 0, "GoClever");
    AddMenuItem(gpsmenu, 1, "$280");  
    AddMenuItem(gpsmenu, 0, "NavRoad");
    AddMenuItem(gpsmenu, 1, "$310");   
    AddMenuItem(gpsmenu, 0, "GARMIN");
    AddMenuItem(gpsmenu, 1, "$410"); 


    busdrivermenu = CreateMenu("Bus Routes", 2, 200.0, 75.0, 150.0, 100.0);

    SetMenuColumnHeader(busdrivermenu, 0, "Route");
    SetMenuColumnHeader(busdrivermenu, 1, "Salary");
    AddMenuItem(busdrivermenu, 0, "Classic");
    AddMenuItem(busdrivermenu, 1, "$300");
    AddMenuItem(busdrivermenu, 0, "Fort Carson Loop");
    AddMenuItem(busdrivermenu, 1, "$400");
    AddMenuItem(busdrivermenu, 0, "Express");
    AddMenuItem(busdrivermenu, 1, "$150");

    // CONTINUE LOAD
    accessDoor = TextDrawCreate(29.000000, 139.000000, "Access Door: SPACE");
    TextDrawFont(accessDoor, 1);
    TextDrawLetterSize(accessDoor, 0.491666, 1.900000);
    TextDrawTextSize(accessDoor, 272.000000, 12.500000);
    TextDrawSetOutline(accessDoor, 1);
    TextDrawSetShadow(accessDoor, 0);
    TextDrawAlignment(accessDoor, 1);
    TextDrawColor(accessDoor, -1);
    TextDrawBackgroundColor(accessDoor, 255);
    TextDrawBoxColor(accessDoor, 50);
    TextDrawUseBox(accessDoor, 1);
    TextDrawSetProportional(accessDoor, 1);
    TextDrawSetSelectable(accessDoor, 0);

    PMuted = TextDrawCreate(230.000000, 366.000000, "You are muted!");
    TextDrawBackgroundColor(PMuted, 255);
    TextDrawFont(PMuted, 1);
    TextDrawLetterSize(PMuted, 0.559999, 1.800000);
    TextDrawColor(PMuted, -1);
    TextDrawSetOutline(PMuted, 0);
    TextDrawSetProportional(PMuted, 1);
    TextDrawSetShadow(PMuted, 1);

    NoHelpmes = TextDrawCreate(230.000000, 366.000000, "There are no new helpmes!");
    TextDrawBackgroundColor(NoHelpmes, 255);
    TextDrawFont(NoHelpmes, 1);
    TextDrawLetterSize(NoHelpmes, 0.559999, 1.800000);
    TextDrawColor(NoHelpmes, -1);
    TextDrawSetOutline(NoHelpmes, 0);
    TextDrawSetProportional(NoHelpmes, 1);
    TextDrawSetShadow(NoHelpmes, 1);

    NoReports = TextDrawCreate(230.000000, 366.000000, "There are no new reports!");
    TextDrawBackgroundColor(NoReports, 255);
    TextDrawFont(NoReports, 1);
    TextDrawLetterSize(NoReports, 0.559999, 1.800000);
    TextDrawColor(NoReports, -1);
    TextDrawSetOutline(NoReports, 0);
    TextDrawSetProportional(NoReports, 1);
    TextDrawSetShadow(NoReports, 1);

    NoBinBags = TextDrawCreate(230.000000, 366.000000, "You have not collected any garbage!");
    TextDrawBackgroundColor(NoBinBags, 255);
    TextDrawFont(NoBinBags, 1);
    TextDrawLetterSize(NoBinBags, 0.559999, 1.800000);
    TextDrawColor(NoBinBags, -1);
    TextDrawSetOutline(NoBinBags, 0);
    TextDrawSetProportional(NoBinBags, 1);
    TextDrawSetShadow(NoBinBags, 1);

    CantTakePost = TextDrawCreate(230.000000, 366.000000, "You have already collected post!");
    TextDrawBackgroundColor(CantTakePost, 255);
    TextDrawFont(CantTakePost, 1);
    TextDrawLetterSize(CantTakePost, 0.559999, 1.800000);
    TextDrawColor(CantTakePost, -1);
    TextDrawSetOutline(CantTakePost, 0);
    TextDrawSetProportional(CantTakePost, 1);
    TextDrawSetShadow(CantTakePost, 1);

    NotOnDuty = TextDrawCreate(230.000000, 366.000000, "You are not on duty!");
    TextDrawBackgroundColor(NotOnDuty, 255);
    TextDrawFont(NotOnDuty, 1);
    TextDrawLetterSize(NotOnDuty, 0.559999, 1.800000);
    TextDrawColor(NotOnDuty, -1);
    TextDrawSetOutline(NotOnDuty, 0);
    TextDrawSetProportional(NotOnDuty, 1);
    TextDrawSetShadow(NotOnDuty, 1);

    CantCommand = TextDrawCreate(230.000000, 366.000000, "You cannot use this command!");
    TextDrawBackgroundColor(CantCommand, 255);
    TextDrawFont(CantCommand, 1);
    TextDrawLetterSize(CantCommand, 0.559999, 1.800000);
    TextDrawColor(CantCommand, -1);
    TextDrawSetOutline(CantCommand, 0);
    TextDrawSetProportional(CantCommand, 1);
    TextDrawSetShadow(CantCommand, 1);

    PublicTD[0] = TextDrawCreate(323.000000, 276.000000, "CityHall");
    TextDrawFont(PublicTD[0], 3);
    TextDrawLetterSize(PublicTD[0], 0.600000, 2.000000);
    TextDrawTextSize(PublicTD[0], 764.000000, -313.000000);
    TextDrawSetOutline(PublicTD[0], 1);
    TextDrawSetShadow(PublicTD[0], 0);
    TextDrawAlignment(PublicTD[0], 2);
    TextDrawColor(PublicTD[0], -1);
    TextDrawBackgroundColor(PublicTD[0], 255);
    TextDrawBoxColor(PublicTD[0], 121);
    TextDrawUseBox(PublicTD[0], 1);
    TextDrawSetProportional(PublicTD[0], 1);
    TextDrawSetSelectable(PublicTD[0], 0);

    PublicTD[1] = TextDrawCreate(247.000000, 305.000000, "This is Fort Carson's city hall. Here you can manage your properties, find a job and collect your paychecks.");
    TextDrawFont(PublicTD[1], 1);
    TextDrawLetterSize(PublicTD[1], 0.158333, 0.749998);
    TextDrawTextSize(PublicTD[1], 400.000000, 17.000000);
    TextDrawSetOutline(PublicTD[1], 1);
    TextDrawSetShadow(PublicTD[1], 0);
    TextDrawAlignment(PublicTD[1], 1);
    TextDrawColor(PublicTD[1], -1);
    TextDrawBackgroundColor(PublicTD[1], 255);
    TextDrawBoxColor(PublicTD[1], 50);
    TextDrawUseBox(PublicTD[1], 0);
    TextDrawSetProportional(PublicTD[1], 1);
    TextDrawSetSelectable(PublicTD[1], 0);

    PublicTD[2] = TextDrawCreate(257.000000, 324.000000, "The City Hall also allows you to change your details, such as your name for a fee; and many offices for your business.");
    TextDrawFont(PublicTD[2], 1);
    TextDrawLetterSize(PublicTD[2], 0.158333, 0.749998);
    TextDrawTextSize(PublicTD[2], 400.000000, 17.000000);
    TextDrawSetOutline(PublicTD[2], 1);
    TextDrawSetShadow(PublicTD[2], 0);
    TextDrawAlignment(PublicTD[2], 1);
    TextDrawColor(PublicTD[2], -1);
    TextDrawBackgroundColor(PublicTD[2], 255);
    TextDrawBoxColor(PublicTD[2], 50);
    TextDrawUseBox(PublicTD[2], 0);
    TextDrawSetProportional(PublicTD[2], 1);
    TextDrawSetSelectable(PublicTD[2], 0);


    sheriffsoffice[0] = TextDrawCreate(323.000000, 276.000000, "SHERIFF'S-OFFICE");
    TextDrawFont(sheriffsoffice[0], 3);
    TextDrawLetterSize(sheriffsoffice[0], 0.600000, 2.000000);
    TextDrawTextSize(sheriffsoffice[0], 764.000000, -313.000000);
    TextDrawSetOutline(sheriffsoffice[0], 1);
    TextDrawSetShadow(sheriffsoffice[0], 0);
    TextDrawAlignment(sheriffsoffice[0], 2);
    TextDrawColor(sheriffsoffice[0], -1);
    TextDrawBackgroundColor(sheriffsoffice[0], 255);
    TextDrawBoxColor(sheriffsoffice[0], 121);
    TextDrawUseBox(sheriffsoffice[0], 1);
    TextDrawSetProportional(sheriffsoffice[0], 1);
    TextDrawSetSelectable(sheriffsoffice[0], 0);

    sheriffsoffice[1] = TextDrawCreate(247.000000, 305.000000, "This is the Sheriff's Office, here you will find Police Officers that will assist you with your queries & concerns.");
    TextDrawFont(sheriffsoffice[1], 1);
    TextDrawLetterSize(sheriffsoffice[1], 0.158333, 0.749997);
    TextDrawTextSize(sheriffsoffice[1], 400.000000, 17.000000);
    TextDrawSetOutline(sheriffsoffice[1], 1);
    TextDrawSetShadow(sheriffsoffice[1], 0);
    TextDrawAlignment(sheriffsoffice[1], 1);
    TextDrawColor(sheriffsoffice[1], -1);
    TextDrawBackgroundColor(sheriffsoffice[1], 255);
    TextDrawBoxColor(sheriffsoffice[1], 50);
    TextDrawUseBox(sheriffsoffice[1], 0);
    TextDrawSetProportional(sheriffsoffice[1], 1);
    TextDrawSetSelectable(sheriffsoffice[1], 0);

    sheriffsoffice[2] = TextDrawCreate(255.000000, 335.000000, "You will see officers roaming the streets of Fort Carson to protect and serve! To find out on how to join, visit the city hall.");
    TextDrawFont(sheriffsoffice[2], 1);
    TextDrawLetterSize(sheriffsoffice[2], 0.124999, 0.799996);
    TextDrawTextSize(sheriffsoffice[2], 400.000000, 17.000000);
    TextDrawSetOutline(sheriffsoffice[2], 1);
    TextDrawSetShadow(sheriffsoffice[2], 0);
    TextDrawAlignment(sheriffsoffice[2], 1);
    TextDrawColor(sheriffsoffice[2], -1);
    TextDrawBackgroundColor(sheriffsoffice[2], 255);
    TextDrawBoxColor(sheriffsoffice[2], 50);
    TextDrawUseBox(sheriffsoffice[2], 0);
    TextDrawSetProportional(sheriffsoffice[2], 1);
    TextDrawSetSelectable(sheriffsoffice[2], 0);

    sheriffsoffice[3] = TextDrawCreate(255.000000, 352.000000, "Make sure that you follow all of the laws or else you may meet these officers soon!");
    TextDrawFont(sheriffsoffice[3], 1);
    TextDrawLetterSize(sheriffsoffice[3], 0.116664, 0.799996);
    TextDrawTextSize(sheriffsoffice[3], 400.000000, 17.000000);
    TextDrawSetOutline(sheriffsoffice[3], 1);
    TextDrawSetShadow(sheriffsoffice[3], 0);
    TextDrawAlignment(sheriffsoffice[3], 1);
    TextDrawColor(sheriffsoffice[3], -1);
    TextDrawBackgroundColor(sheriffsoffice[3], 255);
    TextDrawBoxColor(sheriffsoffice[3], 50);
    TextDrawUseBox(sheriffsoffice[3], 0);
    TextDrawSetProportional(sheriffsoffice[3], 1);
    TextDrawSetSelectable(sheriffsoffice[3], 0);


    hospital[0] = TextDrawCreate(323.000000, 276.000000, "FORT-CARSON-MEDICAL-CENTER");
    TextDrawFont(hospital[0], 3);
    TextDrawLetterSize(hospital[0], 0.600000, 2.000000);
    TextDrawTextSize(hospital[0], 764.000000, -313.000000);
    TextDrawSetOutline(hospital[0], 1);
    TextDrawSetShadow(hospital[0], 0);
    TextDrawAlignment(hospital[0], 2);
    TextDrawColor(hospital[0], -1);
    TextDrawBackgroundColor(hospital[0], 255);
    TextDrawBoxColor(hospital[0], 121);
    TextDrawUseBox(hospital[0], 1);
    TextDrawSetProportional(hospital[0], 1);
    TextDrawSetSelectable(hospital[0], 0);

    hospital[1] = TextDrawCreate(247.000000, 305.000000, "This is Fort Carson's Medical Center, you can have a doctor look over your injuries for a very small fee.");
    TextDrawFont(hospital[1], 1);
    TextDrawLetterSize(hospital[1], 0.158333, 0.749997);
    TextDrawTextSize(hospital[1], 400.000000, 17.000000);
    TextDrawSetOutline(hospital[1], 1);
    TextDrawSetShadow(hospital[1], 0);
    TextDrawAlignment(hospital[1], 1);
    TextDrawColor(hospital[1], -1);
    TextDrawBackgroundColor(hospital[1], 255);
    TextDrawBoxColor(hospital[1], 50);
    TextDrawUseBox(hospital[1], 0);
    TextDrawSetProportional(hospital[1], 1);
    TextDrawSetSelectable(hospital[1], 0);

    hospital[2] = TextDrawCreate(255.000000, 335.000000, "The hospital is open 24/7; all you need to do is check in at the front desk to replenish and to get your life back on track.");
    TextDrawFont(hospital[2], 1);
    TextDrawLetterSize(hospital[2], 0.124999, 0.799996);
    TextDrawTextSize(hospital[2], 400.000000, 17.000000);
    TextDrawSetOutline(hospital[2], 1);
    TextDrawSetShadow(hospital[2], 0);
    TextDrawAlignment(hospital[2], 1);
    TextDrawColor(hospital[2], -1);
    TextDrawBackgroundColor(hospital[2], 255);
    TextDrawBoxColor(hospital[2], 50);
    TextDrawUseBox(hospital[2], 0);
    TextDrawSetProportional(hospital[2], 1);
    TextDrawSetSelectable(hospital[2], 0);


    bank[0] = TextDrawCreate(323.000000, 276.000000, "FORT-CARSON-BANK");
    TextDrawFont(bank[0], 3);
    TextDrawLetterSize(bank[0], 0.600000, 2.000000);
    TextDrawTextSize(bank[0], 764.000000, -313.000000);
    TextDrawSetOutline(bank[0], 1);
    TextDrawSetShadow(bank[0], 0);
    TextDrawAlignment(bank[0], 2);
    TextDrawColor(bank[0], -1);
    TextDrawBackgroundColor(bank[0], 255);
    TextDrawBoxColor(bank[0], 121);
    TextDrawUseBox(bank[0], 1);
    TextDrawSetProportional(bank[0], 1);
    TextDrawSetSelectable(bank[0], 0);

    bank[1] = TextDrawCreate(247.000000, 305.000000, "This is the Fort Carson Bank, this is where you can access your open bank accounts.");
    TextDrawFont(bank[1], 1);
    TextDrawLetterSize(bank[1], 0.158333, 0.749997);
    TextDrawTextSize(bank[1], 400.000000, 17.000000);
    TextDrawSetOutline(bank[1], 1);
    TextDrawSetShadow(bank[1], 0);
    TextDrawAlignment(bank[1], 1);
    TextDrawColor(bank[1], -1);
    TextDrawBackgroundColor(bank[1], 255);
    TextDrawBoxColor(bank[1], 50);
    TextDrawUseBox(bank[1], 0);
    TextDrawSetProportional(bank[1], 1);
    TextDrawSetSelectable(bank[1], 0);

    bank[2] = TextDrawCreate(255.000000, 335.000000, "Why not visit your nearest bank? You can manage your funds, apply for loans and more! Enquire within.");
    TextDrawFont(bank[2], 1);
    TextDrawLetterSize(bank[2], 0.124999, 0.799996);
    TextDrawTextSize(bank[2], 400.000000, 17.000000);
    TextDrawSetOutline(bank[2], 1);
    TextDrawSetShadow(bank[2], 0);
    TextDrawAlignment(bank[2], 1);
    TextDrawColor(bank[2], -1);
    TextDrawBackgroundColor(bank[2], 255);
    TextDrawBoxColor(bank[2], 50);
    TextDrawUseBox(bank[2], 0);
    TextDrawSetProportional(bank[2], 1);
    TextDrawSetSelectable(bank[2], 0);

    cardealer[0] = TextDrawCreate(323.000000, 276.000000, "FORT-CARSON-CAR-DEALERSHIP");
    TextDrawFont(cardealer[0], 3);
    TextDrawLetterSize(cardealer[0], 0.600000, 2.000000);
    TextDrawTextSize(cardealer[0], 764.000000, -313.000000);
    TextDrawSetOutline(cardealer[0], 1);
    TextDrawSetShadow(cardealer[0], 0);
    TextDrawAlignment(cardealer[0], 2);
    TextDrawColor(cardealer[0], -1);
    TextDrawBackgroundColor(cardealer[0], 255);
    TextDrawBoxColor(cardealer[0], 121);
    TextDrawUseBox(cardealer[0], 1);
    TextDrawSetProportional(cardealer[0], 1);
    TextDrawSetSelectable(cardealer[0], 0);

    cardealer[1] = TextDrawCreate(247.000000, 305.000000, "This is the Fort Carson Car Dealership, a fine business to spend your money!");
    TextDrawFont(cardealer[1], 1);
    TextDrawLetterSize(cardealer[1], 0.158333, 0.749997);
    TextDrawTextSize(cardealer[1], 400.000000, 17.000000);
    TextDrawSetOutline(cardealer[1], 1);
    TextDrawSetShadow(cardealer[1], 0);
    TextDrawAlignment(cardealer[1], 1);
    TextDrawColor(cardealer[1], -1);
    TextDrawBackgroundColor(cardealer[1], 255);
    TextDrawBoxColor(cardealer[1], 50);
    TextDrawUseBox(cardealer[1], 0);
    TextDrawSetProportional(cardealer[1], 1);
    TextDrawSetSelectable(cardealer[1], 0);

    cardealer[2] = TextDrawCreate(255.000000, 335.000000, "Here you can find any vehicle that you require, from supercars to sedans - with many colours to choose from!");
    TextDrawFont(cardealer[2], 1);
    TextDrawLetterSize(cardealer[2], 0.124999, 0.799996);
    TextDrawTextSize(cardealer[2], 400.000000, 17.000000);
    TextDrawSetOutline(cardealer[2], 1);
    TextDrawSetShadow(cardealer[2], 0);
    TextDrawAlignment(cardealer[2], 1);
    TextDrawColor(cardealer[2], -1);
    TextDrawBackgroundColor(cardealer[2], 255);
    TextDrawBoxColor(cardealer[2], 50);
    TextDrawUseBox(cardealer[2], 0);
    TextDrawSetProportional(cardealer[2], 1);
    TextDrawSetSelectable(cardealer[2], 0);

    finishtutorial[0] = TextDrawCreate(323.000000, 276.000000, "END-OF-TUTORIAL");
    TextDrawFont(finishtutorial[0], 3);
    TextDrawLetterSize(finishtutorial[0], 0.600000, 2.000000);
    TextDrawTextSize(finishtutorial[0], 764.000000, -313.000000);
    TextDrawSetOutline(finishtutorial[0], 1);
    TextDrawSetShadow(finishtutorial[0], 0);
    TextDrawAlignment(finishtutorial[0], 2);
    TextDrawColor(finishtutorial[0], -1);
    TextDrawBackgroundColor(finishtutorial[0], 255);
    TextDrawBoxColor(finishtutorial[0], 121);
    TextDrawUseBox(finishtutorial[0], 1);
    TextDrawSetProportional(finishtutorial[0], 1);
    TextDrawSetSelectable(finishtutorial[0], 0);

    finishtutorial[1] = TextDrawCreate(247.000000, 305.000000, "This concludes the tutorial, we have tried to show you where everything is to get started!");
    TextDrawFont(finishtutorial[1], 1);
    TextDrawLetterSize(finishtutorial[1], 0.158333, 0.749997);
    TextDrawTextSize(finishtutorial[1], 400.000000, 17.000000);
    TextDrawSetOutline(finishtutorial[1], 1);
    TextDrawSetShadow(finishtutorial[1], 0);
    TextDrawAlignment(finishtutorial[1], 1);
    TextDrawColor(finishtutorial[1], -1);
    TextDrawBackgroundColor(finishtutorial[1], 255);
    TextDrawBoxColor(finishtutorial[1], 50);
    TextDrawUseBox(finishtutorial[1], 0);
    TextDrawSetProportional(finishtutorial[1], 1);
    TextDrawSetSelectable(finishtutorial[1], 0);

    return 1;
}

// load server data

forward public CreateBusStopObjects();
public CreateBusStopObjects() {
    for (new i = 0; i < sizeof(busObject); i++) {
        CreateDynamicObject(1257, busObject[i][0], busObject[i][1], busObject[i][2], 0, 0, busObject[i][3]);
    }
    return 1;
}

forward public LoadNewVehData(id);
public LoadNewVehData(id){
    new DB_Query[900];
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `vehicles` WHERE `vID` = '%d'", id);
    mysql_tquery(db_handle, DB_Query, "newVeh");
}

forward public newVeh();
public newVeh(){
    
    if(cache_num_rows() == 0) print("Not a valid vehicle id!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "vID", vInfo[loadedVeh][vID]);
            cache_get_value_int(i, "vModelId", vInfo[loadedVeh][vModelId]);
            cache_get_value(i, "vOwner", vInfo[loadedVeh][vOwner], 32);
            cache_get_value_int(i, "vFuel", vInfo[loadedVeh][vFuel]);
            cache_get_value_int(i, "vJobId", vInfo[loadedVeh][vJobId]);
            cache_get_value_int(i, "vFacId", vInfo[loadedVeh][vFacId]);
            cache_get_value_int(i, "vBusId", vInfo[loadedVeh][vBusId]);
            cache_get_value_int(i, "vFines", vInfo[i][vFines]);
            cache_get_value(i, "vPlate", vInfo[i][vPlate], 32);
            cache_get_value(i, "vMostRecentFine", vInfo[i][vMostRecentFine], 32);
            cache_get_value_int(i, "vImpounded", vInfo[i][vImpounded]);
            cache_get_value_float(i, "vParkedX", vInfo[loadedVeh][vParkedX]);
            cache_get_value_float(i, "vParkedY", vInfo[loadedVeh][vParkedY]);
            cache_get_value_float(i, "vParkedZ", vInfo[loadedVeh][vParkedZ]);
            cache_get_value_float(i, "vAngle", vInfo[loadedVeh][vAngle]);
            cache_get_value_int(i, "vColor1", vInfo[loadedVeh][vColor1]);
            cache_get_value_int(i, "vColor2", vInfo[loadedVeh][vColor2]);
            cache_get_value_int(i, "vRentalState", vInfo[loadedVeh][vRentalState]);
            cache_get_value_int(i, "vRentalPrice", vInfo[loadedVeh][vRentalPrice]);
            new vehicleid = CreateVehicle(vInfo[loadedVeh][vModelId],
                vInfo[loadedVeh][vParkedX],
                vInfo[loadedVeh][vParkedY],
                vInfo[loadedVeh][vParkedZ],
                vInfo[loadedVeh][vAngle],
                vInfo[loadedVeh][vColor1],
                vInfo[loadedVeh][vColor2],
                -1
            );
            vInfo[loadedVeh][vRentingPlayer] = INVALID_PLAYER_ID;
            SetVehicleNumberPlate(vehicleid, vInfo[loadedVeh][vPlate]);
            loadedVeh++;
        }
        printf("** [MYSQL] Reloaded %d vehicles from the database!", cache_num_rows());
    }
}

forward public LoadVehicleData();
public LoadVehicleData() {
    new DB_Query[900];
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `vehicles`");
    mysql_tquery(db_handle, DB_Query, "VehsReceived");
}

forward VehsReceived();
public VehsReceived() {
    if(cache_num_rows() == 0) print("No vehicles have been created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "vID", vInfo[i][vID]);
            cache_get_value_int(i, "vModelId", vInfo[i][vModelId]);
            cache_get_value(i, "vOwner", vInfo[i][vOwner], 32);
            cache_get_value_int(i, "vFuel", vInfo[i][vFuel]);
            cache_get_value_int(i, "vJobId", vInfo[i][vJobId]);
            cache_get_value_int(i, "vFacId", vInfo[i][vFacId]);
            cache_get_value_int(i, "vBusId", vInfo[i][vBusId]);
            cache_get_value_int(i, "vFines", vInfo[i][vFines]);
            cache_get_value(i, "vPlate", vInfo[i][vPlate], 32);
            cache_get_value(i, "vMostRecentFine", vInfo[i][vMostRecentFine], 32);
            cache_get_value_int(i, "vImpounded", vInfo[i][vImpounded]);
            cache_get_value_float(i, "vParkedX", vInfo[i][vParkedX]);
            cache_get_value_float(i, "vParkedY", vInfo[i][vParkedY]);
            cache_get_value_float(i, "vParkedZ", vInfo[i][vParkedZ]);
            cache_get_value_float(i, "vAngle", vInfo[i][vAngle]);
            cache_get_value_int(i, "vColor1", vInfo[i][vColor1]);
            cache_get_value_int(i, "vColor2", vInfo[i][vColor2]);
            cache_get_value_int(i, "vRentalState", vInfo[i][vRentalState]);
            cache_get_value_int(i, "vRentalPrice", vInfo[i][vRentalPrice]);
            new vehicleid = CreateVehicle(vInfo[i][vModelId],
                vInfo[i][vParkedX],
                vInfo[i][vParkedY],
                vInfo[i][vParkedZ],
                vInfo[i][vAngle],
                vInfo[i][vColor1],
                vInfo[i][vColor2],
                -1
            );
            SetVehicleZAngle(i, vInfo[i][vAngle]);
            vInfo[loadedVeh][vRentingPlayer] = INVALID_PLAYER_ID;
            SetVehicleNumberPlate(vehicleid, vInfo[i][vPlate]);            
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
            if(vInfo[i][vRentalState] != VEHICLE_RENTABLE){            
                SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
            }
            loadedVeh++;
        }
        printf("** [MYSQL] Loaded %d vehicles from the database!", cache_num_rows());
    }
}

forward public LoadBusData();
public LoadBusData(){
    new DB_Query[900];
    
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `businesses`");
    mysql_tquery(db_handle, DB_Query, "BusReceived");
}

forward public BusReceived();
public BusReceived() {
    if(cache_num_rows() == 0) print("No businesses created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "bId", bInfo[i][bId]);
            cache_get_value(i, "bName", bInfo[i][bName], 32);
            cache_get_value_int(i, "bAddress", bInfo[i][bAddress]);
            cache_get_value_int(i, "bPrice", bInfo[i][bPrice]);
            cache_get_value_int(i, "bSalary", bInfo[i][bSalary]);
            cache_get_value(i, "bOwner", bInfo[i][bOwner], 32);
            cache_get_value_int(i, "bType", bInfo[i][bType]);
            cache_get_value_int(i, "bIntId", bInfo[i][bIntId]);
            cache_get_value_float(i, "bInfoX", bInfo[i][bInfoX]);
            cache_get_value_float(i, "bInfoY", bInfo[i][bInfoY]);
            cache_get_value_float(i, "bInfoZ", bInfo[i][bInfoZ]);
            cache_get_value_float(i, "bEntX", bInfo[i][bEntX]);
            cache_get_value_float(i, "bEntY", bInfo[i][bEntY]);
            cache_get_value_float(i, "bEntZ", bInfo[i][bEntZ]);
            cache_get_value_float(i, "bUseX", bInfo[i][bUseX]);
            cache_get_value_float(i, "bUseY", bInfo[i][bUseY]);
            cache_get_value_float(i, "bUseZ", bInfo[i][bUseZ]);
            cache_get_value_float(i, "bExitX", bInfo[i][bExitX]);
            cache_get_value_float(i, "bExitY", bInfo[i][bExitY]);
            cache_get_value_float(i, "bExitZ", bInfo[i][bExitZ]);

            if(!strcmp(bInfo[i][bOwner], "NULL", true)){
                busInfoPickup[i] = CreateDynamicPickup(1273, 1, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], -1);
            }

            if(strcmp(bInfo[i][bOwner], "NULL", true)){            
                busInfoPickup[i] = CreateDynamicPickup(1239, 1, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], -1);
            }
            busEntPickup[i] = CreateDynamicPickup(1559, 1, bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ], -1);
            busUsePickup[i] = CreateDynamicPickup(1239, 1, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ], -1);
            busExitPickup[i] = CreateDynamicPickup(1559, 1, bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ], -1);
            loadedBus++;
        }

        printf("** [MYSQL]:Loaded %d businesses from the database.", cache_num_rows());
    }
    return 1;
}

forward public LoadNewBusData(id);
public LoadNewBusData(id) {
    new DB_Query[900];
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `businesses` WHERE `bID` = '%d'", id);
    mysql_tquery(db_handle, DB_Query, "newBus");
}

forward public newBus();
public newBus() {
    if(cache_num_rows() == 0) print("Not a valid business id!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "bId", bInfo[i][bId]);
            cache_get_value(i, "bName", bInfo[i][bName], 32);
            cache_get_value_int(i, "bAddress", bInfo[i][bAddress]);
            cache_get_value_int(i, "bPrice", bInfo[i][bPrice]);
            cache_get_value_int(i, "bSalary", bInfo[i][bSalary]);
            cache_get_value(i, "bOwner", bInfo[i][bOwner], 32);
            cache_get_value_int(i, "bType", bInfo[i][bType]);
            cache_get_value_int(i, "bIntId", bInfo[i][bIntId]);
            cache_get_value_float(i, "bInfoX", bInfo[i][bInfoX]);
            cache_get_value_float(i, "bInfoY", bInfo[i][bInfoY]);
            cache_get_value_float(i, "bInfoZ", bInfo[i][bInfoZ]);
            cache_get_value_float(i, "bEntX", bInfo[i][bEntX]);
            cache_get_value_float(i, "bEntY", bInfo[i][bEntY]);
            cache_get_value_float(i, "bEntZ", bInfo[i][bEntZ]);
            cache_get_value_float(i, "bUseX", bInfo[i][bUseX]);
            cache_get_value_float(i, "bUseY", bInfo[i][bUseY]);
            cache_get_value_float(i, "bUseZ", bInfo[i][bUseZ]);
            cache_get_value_float(i, "bExitX", bInfo[i][bExitX]);
            cache_get_value_float(i, "bExitY", bInfo[i][bExitY]);
            cache_get_value_float(i, "bExitZ", bInfo[i][bExitZ]);
            busInfoPickup[i] = CreateDynamicPickup(1239, 1, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], -1); 
            loadedBus++;
        }

        printf("** [MYSQL]:Reloaded %d businesss from the database.", cache_num_rows());
    }
    return 1;
}
forward public LoadNewHouseData(id);
public LoadNewHouseData(id){
    new DB_Query[900];

    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `houses` WHERE `hId` = '%d'", id);
    mysql_tquery(db_handle, DB_Query, "newHouse");
}


forward public newHouse();
public newHouse() {
    if(cache_num_rows() == 0) print("Not a valid house!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "hId", hInfo[i][hId]);
            cache_get_value(i, "hOwner", hInfo[i][hOwner], 32);
            cache_get_value_int(i, "hAddress", hInfo[i][hAddress]);
            cache_get_value_int(i, "hPrice", hInfo[i][hPrice]);
            cache_get_value_int(i, "hType", hInfo[i][hType]);
            cache_get_value_float(i, "hInfoX", hInfo[i][hInfoX]);
            cache_get_value_float(i, "hInfoY", hInfo[i][hInfoY]);
            cache_get_value_float(i, "hInfoZ", hInfo[i][hInfoZ]);
            cache_get_value_float(i, "hEntX", hInfo[i][hEntX]);
            cache_get_value_float(i, "hEntY", hInfo[i][hEntY]);
            cache_get_value_float(i, "hEntZ", hInfo[i][hEntZ]);
            cache_get_value_float(i, "hExitX", hInfo[i][hExitX]);
            cache_get_value_float(i, "hExitY", hInfo[i][hExitY]);
            cache_get_value_float(i, "hExitZ", hInfo[i][hExitZ]);
            if(!strcmp(hInfo[i][hOwner], "NULL", true)){
                houseInfoPickup[i] = CreateDynamicPickup(1273, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
            }
            if(strcmp(hInfo[i][hOwner], "NULL", true)){            
                houseInfoPickup[i] = CreateDynamicPickup(1239, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
            }
            houseEntPickup[i] = CreateDynamicPickup(1559, 1, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ], -1);
            houseExitPickup[i] = CreateDynamicPickup(1559, 1, hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ], -1);
            loadedHouse++;
        }

        printf("** [MYSQL]:Loaded %d houses from the database.", cache_num_rows());
    }
    return 1;
}

forward public LoadHouseData();
public LoadHouseData(){
    new DB_Query[900];

    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `houses`");
    mysql_tquery(db_handle, DB_Query, "HousesReceived");
}


forward public HousesReceived();
public HousesReceived() {
    if(cache_num_rows() == 0) print("No houses created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "hId", hInfo[i][hId]);
            cache_get_value(i, "hOwner", hInfo[i][hOwner], 32);
            cache_get_value_int(i, "hAddress", hInfo[i][hAddress]);
            cache_get_value_int(i, "hPrice", hInfo[i][hPrice]);
            cache_get_value_int(i, "hType", hInfo[i][hType]);
            cache_get_value_float(i, "hInfoX", hInfo[i][hInfoX]);
            cache_get_value_float(i, "hInfoY", hInfo[i][hInfoY]);
            cache_get_value_float(i, "hInfoZ", hInfo[i][hInfoZ]);
            cache_get_value_float(i, "hEntX", hInfo[i][hEntX]);
            cache_get_value_float(i, "hEntY", hInfo[i][hEntY]);
            cache_get_value_float(i, "hEntZ", hInfo[i][hEntZ]);
            cache_get_value_float(i, "hExitX", hInfo[i][hExitX]);
            cache_get_value_float(i, "hExitY", hInfo[i][hExitY]);
            cache_get_value_float(i, "hExitZ", hInfo[i][hExitZ]);
            if(!strcmp(hInfo[i][hOwner], "NULL", true)){
                houseInfoPickup[i] = CreateDynamicPickup(1273, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
            }
            if(strcmp(hInfo[i][hOwner], "NULL", true)){            
                houseInfoPickup[i] = CreateDynamicPickup(1239, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
            }
            houseEntPickup[i] = CreateDynamicPickup(1559, 1, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ], -1);
            houseExitPickup[i] = CreateDynamicPickup(1559, 1, hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ], -1);
            loadedHouse++;
        }

        printf("** [MYSQL]:Loaded %d houses from the database.", cache_num_rows());
    }
    return 1;
}

forward public LoadFacData();
public LoadFacData() {
    new DB_Query[900];

    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `factions`");
    mysql_tquery(db_handle, DB_Query, "FacsReceived");
}

forward public LoadNewFacData(id);
public LoadNewFacData(id) {
    new DB_Query[900];
    printf("loading new faction...");
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `factions` WHERE `fID` = '%d'", id);
    mysql_tquery(db_handle, DB_Query, "newFac");
}

forward public newFac();
public newFac() {
    if(cache_num_rows() == 0) print("No factions created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "fID", fInfo[i][fID]);
            cache_get_value(i, "fName", fInfo[i][fName], 32);
            cache_get_value_int(i, "fAddress", fInfo[i][fAddress]);
            cache_get_value(i, "fLeader", fInfo[i][fLeader], 32);
            cache_get_value_int(i, "fType", fInfo[i][fType]);
            cache_get_value_int(i, "fPrice", fInfo[i][fPrice]);
            cache_get_value(i, "fRank1Name", fInfo[i][fRank1Name], 32);
            cache_get_value(i, "fRank2Name", fInfo[i][fRank2Name], 32);
            cache_get_value(i, "fRank3Name", fInfo[i][fRank3Name], 32);
            cache_get_value(i, "fRank4Name", fInfo[i][fRank4Name], 32);
            cache_get_value(i, "fRank5Name", fInfo[i][fRank5Name], 32);
            cache_get_value(i, "fRank6Name", fInfo[i][fRank6Name], 32);
            cache_get_value(i, "fRank7Name", fInfo[i][fRank7Name], 32);
            cache_get_value_float(i, "fInfoX", fInfo[i][fInfoX]);
            cache_get_value_float(i, "fInfoY", fInfo[i][fInfoY]);
            cache_get_value_float(i, "fInfoZ", fInfo[i][fInfoZ]);
            cache_get_value_float(i, "fDutyX", fInfo[i][fDutyX]);
            cache_get_value_float(i, "fDutyY", fInfo[i][fDutyY]);
            cache_get_value_float(i, "fDutyZ", fInfo[i][fDutyZ]);
            cache_get_value_float(i, "fClothesX", fInfo[i][fClothesX]);
            cache_get_value_float(i, "fClothesY", fInfo[i][fClothesY]);
            cache_get_value_float(i, "fClothesZ", fInfo[i][fClothesZ]);
            cache_get_value_float(i, "fEntX", fInfo[i][fEntX]);
            cache_get_value_float(i, "fEntY", fInfo[i][fEntY]);
            cache_get_value_float(i, "fEntZ", fInfo[i][fEntZ]);
            cache_get_value_float(i, "fExitX", fInfo[i][fExitX]);
            cache_get_value_float(i, "fExitY", fInfo[i][fExitY]);
            cache_get_value_float(i, "fExitZ", fInfo[i][fExitZ]);

            if(!strcmp(fInfo[i][fLeader], "NULL", true)){
                facInfoPickup[i] = CreateDynamicPickup(1273, 1, fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], -1);
            }
            if(strcmp(fInfo[i][fLeader], "NULL", true)){            
                facInfoPickup[i] = CreateDynamicPickup(1239, 1, fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], -1);
            }
            //facEntPickup[i] = CreateDynamicPickup(1559, 1, fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ], -1);
            //facExitPickup[i] = CreateDynamicPickup(1559, 1, fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ], -1);
            loadedFac++;
        }
    }
    return 1;
}

forward public FacsReceived();
public FacsReceived() {
    if(cache_num_rows() == 0) print("No factions created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "fID", fInfo[i][fID]);
            cache_get_value(i, "fName", fInfo[i][fName], 32);
            cache_get_value_int(i, "fAddress", fInfo[i][fAddress]);
            cache_get_value(i, "fLeader", fInfo[i][fLeader], 32);
            cache_get_value_int(i, "fType", fInfo[i][fType]);
            cache_get_value_int(i, "fPrice", fInfo[i][fPrice]);
            cache_get_value(i, "fRank1Name", fInfo[i][fRank1Name], 32);
            cache_get_value(i, "fRank2Name", fInfo[i][fRank2Name], 32);
            cache_get_value(i, "fRank3Name", fInfo[i][fRank3Name], 32);
            cache_get_value(i, "fRank4Name", fInfo[i][fRank4Name], 32);
            cache_get_value(i, "fRank5Name", fInfo[i][fRank5Name], 32);
            cache_get_value(i, "fRank6Name", fInfo[i][fRank6Name], 32);
            cache_get_value(i, "fRank7Name", fInfo[i][fRank7Name], 32);
            cache_get_value_float(i, "fInfoX", fInfo[i][fInfoX]);
            cache_get_value_float(i, "fInfoY", fInfo[i][fInfoY]);
            cache_get_value_float(i, "fInfoZ", fInfo[i][fInfoZ]);
            cache_get_value_float(i, "fDutyX", fInfo[i][fDutyX]);
            cache_get_value_float(i, "fDutyY", fInfo[i][fDutyY]);
            cache_get_value_float(i, "fDutyZ", fInfo[i][fDutyZ]);
            cache_get_value_float(i, "fClothesX", fInfo[i][fClothesX]);
            cache_get_value_float(i, "fClothesY", fInfo[i][fClothesY]);
            cache_get_value_float(i, "fClothesZ", fInfo[i][fClothesZ]);
            cache_get_value_float(i, "fEntX", fInfo[i][fEntX]);
            cache_get_value_float(i, "fEntY", fInfo[i][fEntY]);
            cache_get_value_float(i, "fEntZ", fInfo[i][fEntZ]);
            cache_get_value_float(i, "fExitX", fInfo[i][fExitX]);
            cache_get_value_float(i, "fExitY", fInfo[i][fExitY]);
            cache_get_value_float(i, "fExitZ", fInfo[i][fExitZ]);

            if(!strcmp(fInfo[i][fLeader], "NULL", true)){
                facInfoPickup[i] = CreateDynamicPickup(1273, 1, fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], -1);
            }
            if(strcmp(fInfo[i][fLeader], "NULL", true)){            
                facInfoPickup[i] = CreateDynamicPickup(1239, 1, fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], -1);
            }
            facEntPickup[i] = CreateDynamicPickup(1559, 1, fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ], -1);
            facExitPickup[i] = CreateDynamicPickup(1559, 1, fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ], -1);
            facClothesPickup[i] = CreateDynamicPickup(1275, 1, fInfo[i][fClothesX], fInfo[i][fClothesY], fInfo[i][fClothesZ], -1);
            facDutyPickup[i] = CreateDynamicPickup(1239, 1, fInfo[i][fDutyX], fInfo[i][fDutyY], fInfo[i][fDutyZ], -1);
            loadedFac++;
        }

        printf("** [MYSQL]:Loaded %d facs from the database.", cache_num_rows());
    }
    return 1;
}


forward public LoadDrugPrices();
public LoadDrugPrices(){
    new DB_Query[900];

    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `drugprices`");
    mysql_tquery(db_handle, DB_Query, "DrugPricesReceived");
}

forward public DrugPricesReceived();
public DrugPricesReceived(){
    if(cache_num_rows() == 0) return printf("No drugs created");
    else {
        for(new i = 0; i < cache_num_rows(); i++){
            cache_get_value_int(i, "drugId", drugInfo[loadedDrug][drugId]);
            cache_get_value(i, "drugName", drugInfo[loadedDrug][drugName],32);
            cache_get_value_int(i, "drugAmount", drugInfo[loadedDrug][drugAmount]);
            cache_get_value_int(i, "drugPrice", drugInfo[loadedDrug][drugPrice]);
            loadedDrug++;
        }
        printf("** [MYSQL] Loaded %d drugs", cache_num_rows());
    }
    return 1;
}

forward public LoadJobData();
public LoadJobData() {
    new DB_Query[900];

    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `jobs`");
    mysql_tquery(db_handle, DB_Query, "JobsReceived");
}

forward public LoadNewJobData(id);
public LoadNewJobData(id) {
    new DB_Query[900];
    mysql_format(db_handle, DB_Query, sizeof(DB_Query), "SELECT * FROM `jobs` WHERE `jID` = '%d'", id);
    mysql_tquery(db_handle, DB_Query, "newJob");
}


forward newJob();
public newJob() {
    if(cache_num_rows() == 0) print("Job does not exist");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "jID", jInfo[i][jID]);
            cache_get_value(i, "jName", jInfo[i][jName], 32);
            cache_get_value_int(i, "jPay", jInfo[i][jPay]);
            cache_get_value_float(i, "jobIX", jInfo[i][jobIX]);
            cache_get_value_float(i, "jobIY", jInfo[i][jobIY]);
            cache_get_value_float(i, "jobIZ", jInfo[i][jobIZ]);
            jobPickup[i] = CreateDynamicPickup(1239, 1, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], -1);
            loadedJob++;
            //`CreateDynamicPickup(19526, 1, factionInfo[i][facX], factionInfo[i][facY], factionInfo[i][facZ], 0, 0);

        }
        printf("[INFO]:Loaded a new job.", cache_num_rows());
    }
}

forward JobsReceived();
public JobsReceived() {
    if(cache_num_rows() == 0) print("No jobs have been created!");
    else {
        for (new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_int(i, "jID", jInfo[i][jID]);
            cache_get_value(i, "jName", jInfo[i][jName], 32);
            cache_get_value_int(i, "jPay", jInfo[i][jPay]);
            cache_get_value_float(i, "jobIX", jInfo[i][jobIX]);
            cache_get_value_float(i, "jobIY", jInfo[i][jobIY]);
            cache_get_value_float(i, "jobIZ", jInfo[i][jobIZ]);
            jobPickup[i] = CreateDynamicPickup(1239, 1, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], -1);
            loadedJob++;

        }
        printf("** [MYSQL]:Loaded %d jobs from the database.", cache_num_rows());

    }
    return 1;
}

public OnGameModeExit() {
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    return 1;
}

public OnPlayerConnect(playerid) {
    if(!IsPlayerNPC(playerid))
    {
        new query[200];
        pInfo[playerid][pMuted] = 1;
        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid, name, sizeof(name));

        SetPlayerSkin(playerid, maleSkins[random(11)]);
        SetPlayerPos(playerid, 163.984863, 1213.388305, 21.501449);
        SetPlayerFacingAngle(playerid, 221.263046);
        InterpolateCameraPos(playerid, 163.4399, 1179.7891, 23.3623, 178.1042, 1187.0188, 22.1915, 15000, CAMERA_MOVE);
        InterpolateCameraLookAt(playerid, 163.5655, 1180.7781, 23.2423, 177.8423, 1187.9811, 22.0065, 15000, CAMERA_MOVE);
        RemoveBuildingForPlayer(playerid, 669, -120.8750, 1110.4219, 18.6797, 0.25);

        LoadMapIcons(playerid);

        ApplyAnimation(playerid, "SMOKING", "M_smklean_loop", 4.0, true, false, false, false, 0, false); // Smoke

        mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `accounts` where `pName` = '%s'", name); // Get the player's name
        mysql_tquery(db_handle, query, "checkIfExists", "d", playerid); // Send to check if exists function


        // remove buildings


        //Player Textdraws
        
        dash1[playerid] = CreatePlayerTextDraw(playerid, 129.000000, 113.000000, "dashcam");
        PlayerTextDrawFont(playerid, dash1[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dash1[playerid], 0.295832, 1.750000);
        PlayerTextDrawTextSize(playerid, dash1[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, dash1[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dash1[playerid], 0);
        PlayerTextDrawAlignment(playerid, dash1[playerid], 1);
        PlayerTextDrawColor(playerid, dash1[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dash1[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dash1[playerid], 50);
        PlayerTextDrawUseBox(playerid, dash1[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dash1[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dash1[playerid], 0);

        dash2[playerid] = CreatePlayerTextDraw(playerid, 129.000000, 129.000000, "CAM01");
        PlayerTextDrawFont(playerid, dash2[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dash2[playerid], 0.295832, 1.750000);
        PlayerTextDrawTextSize(playerid, dash2[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, dash2[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dash2[playerid], 0);
        PlayerTextDrawAlignment(playerid, dash2[playerid], 1);
        PlayerTextDrawColor(playerid, dash2[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dash2[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dash2[playerid], 50);
        PlayerTextDrawUseBox(playerid, dash2[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dash2[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dash2[playerid], 0);

        dashPlate[playerid] = CreatePlayerTextDraw(playerid, 189.000000, 358.000000, "P PLATEHERE");
        PlayerTextDrawFont(playerid, dashPlate[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dashPlate[playerid], 0.279166, 1.750000);
        PlayerTextDrawTextSize(playerid, dashPlate[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, dashPlate[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dashPlate[playerid], 0);
        PlayerTextDrawAlignment(playerid, dashPlate[playerid], 1);
        PlayerTextDrawColor(playerid, dashPlate[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dashPlate[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dashPlate[playerid], 50);
        PlayerTextDrawUseBox(playerid, dashPlate[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dashPlate[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dashPlate[playerid], 0);

        dashSpeed[playerid] = CreatePlayerTextDraw(playerid, 291.000000, 358.000000, "S 90MPH");
        PlayerTextDrawFont(playerid, dashSpeed[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dashSpeed[playerid], 0.279166, 1.750000);
        PlayerTextDrawTextSize(playerid, dashSpeed[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, dashSpeed[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dashSpeed[playerid], 0);
        PlayerTextDrawAlignment(playerid, dashSpeed[playerid], 1);
        PlayerTextDrawColor(playerid, dashSpeed[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dashSpeed[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dashSpeed[playerid], 50);
        PlayerTextDrawUseBox(playerid, dashSpeed[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dashSpeed[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dashSpeed[playerid], 0);

        dashDist[playerid] = CreatePlayerTextDraw(playerid, 410.000000, 358.000000, "D 25M");
        PlayerTextDrawFont(playerid, dashDist[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dashDist[playerid], 0.279166, 1.750000);
        PlayerTextDrawTextSize(playerid, dashDist[playerid], 398.000000, 8.000000);
        PlayerTextDrawSetOutline(playerid, dashDist[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dashDist[playerid], 0);
        PlayerTextDrawAlignment(playerid, dashDist[playerid], 3);
        PlayerTextDrawColor(playerid, dashDist[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dashDist[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dashDist[playerid], 50);
        PlayerTextDrawUseBox(playerid, dashDist[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dashDist[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dashDist[playerid], 0);

        dashVid[playerid] = CreatePlayerTextDraw(playerid, 411.000000, 115.000000, "VID: vehId");
        PlayerTextDrawFont(playerid, dashVid[playerid], 2);
        PlayerTextDrawLetterSize(playerid, dashVid[playerid], 0.295832, 1.750000);
        PlayerTextDrawTextSize(playerid, dashVid[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, dashVid[playerid], 1);
        PlayerTextDrawSetShadow(playerid, dashVid[playerid], 0);
        PlayerTextDrawAlignment(playerid, dashVid[playerid], 3);
        PlayerTextDrawColor(playerid, dashVid[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, dashVid[playerid], 255);
        PlayerTextDrawBoxColor(playerid, dashVid[playerid], 50);
        PlayerTextDrawUseBox(playerid, dashVid[playerid], 0);
        PlayerTextDrawSetProportional(playerid, dashVid[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, dashVid[playerid], 0);


        businessBox[playerid] = CreatePlayerTextDraw(playerid, 63.000000, 141.000000, "`");
        PlayerTextDrawFont(playerid, businessBox[playerid], 0);
        PlayerTextDrawLetterSize(playerid, businessBox[playerid], 0.600000, 10.400004);
        PlayerTextDrawTextSize(playerid, businessBox[playerid], 206.500000, 5.000000);
        PlayerTextDrawSetOutline(playerid, businessBox[playerid], 1);
        PlayerTextDrawSetShadow(playerid, businessBox[playerid], 0);
        PlayerTextDrawAlignment(playerid, businessBox[playerid], 1);
        PlayerTextDrawColor(playerid, businessBox[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, businessBox[playerid], 255);
        PlayerTextDrawBoxColor(playerid, businessBox[playerid], 50);
        PlayerTextDrawUseBox(playerid, businessBox[playerid], 1);
        PlayerTextDrawSetProportional(playerid, businessBox[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, businessBox[playerid], 0);


        addressBox[playerid] = CreatePlayerTextDraw(playerid, 64.000000, 155.000000, "`");
        PlayerTextDrawFont(playerid, addressBox[playerid], 0);
        PlayerTextDrawLetterSize(playerid, addressBox[playerid], 0.600000, 9.049999);
        PlayerTextDrawTextSize(playerid, addressBox[playerid], 206.500000, 5.000000);
        PlayerTextDrawSetOutline(playerid, addressBox[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressBox[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressBox[playerid], 1);
        PlayerTextDrawColor(playerid, addressBox[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, addressBox[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressBox[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressBox[playerid], 1);
        PlayerTextDrawSetProportional(playerid, addressBox[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressBox[playerid], 0);

        addressName[playerid] = CreatePlayerTextDraw(playerid, 66.000000, 142.000000, "Name:");
        PlayerTextDrawFont(playerid, addressName[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressName[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressName[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressName[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressName[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressName[playerid], 1);
        PlayerTextDrawColor(playerid, addressName[playerid], -2686721);
        PlayerTextDrawBackgroundColor(playerid, addressName[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressName[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressName[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressName[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressName[playerid], 0);

        addressNameString[playerid] = CreatePlayerTextDraw(playerid, 106.000000, 142.000000, "Hardware Store");
        PlayerTextDrawFont(playerid, addressNameString[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressNameString[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressNameString[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressNameString[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressNameString[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressNameString[playerid], 1);
        PlayerTextDrawColor(playerid, addressNameString[playerid], -1);
        PlayerTextDrawBackgroundColor(playerid, addressNameString[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressNameString[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressNameString[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressNameString[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressNameString[playerid], 0);


        addressString[playerid] = CreatePlayerTextDraw(playerid, 66.000000, 158.000000, "Address:");
        PlayerTextDrawFont(playerid, addressString[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressString[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressString[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressString[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressString[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressString[playerid], 1);
        PlayerTextDrawColor(playerid, addressString[playerid], -2686721);
        PlayerTextDrawBackgroundColor(playerid, addressString[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressString[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressString[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressString[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressString[playerid], 0);

        addressStatus[playerid] = CreatePlayerTextDraw(playerid, 76.000000, 175.000000, "Status:");
        PlayerTextDrawFont(playerid, addressStatus[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressStatus[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressStatus[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressStatus[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressStatus[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressStatus[playerid], 1);
        PlayerTextDrawColor(playerid, addressStatus[playerid], -2686721);
        PlayerTextDrawBackgroundColor(playerid, addressStatus[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressStatus[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressStatus[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressStatus[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressStatus[playerid], 0);

        addressType[playerid] = CreatePlayerTextDraw(playerid, 84.000000, 191.000000, "Type:");
        PlayerTextDrawFont(playerid, addressType[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressType[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressType[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressType[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressType[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressType[playerid], 1);
        PlayerTextDrawColor(playerid, addressType[playerid], -2686721);
        PlayerTextDrawBackgroundColor(playerid, addressType[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressType[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressType[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressType[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressType[playerid], 0);

        addressPrice[playerid] = CreatePlayerTextDraw(playerid, 83.000000, 211.000000, "Price:");
        PlayerTextDrawFont(playerid, addressPrice[playerid], 1);
        PlayerTextDrawLetterSize(playerid, addressPrice[playerid], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, addressPrice[playerid], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, addressPrice[playerid], 1);
        PlayerTextDrawSetShadow(playerid, addressPrice[playerid], 0);
        PlayerTextDrawAlignment(playerid, addressPrice[playerid], 1);
        PlayerTextDrawColor(playerid, addressPrice[playerid], -2686721);
        PlayerTextDrawBackgroundColor(playerid, addressPrice[playerid], 255);
        PlayerTextDrawBoxColor(playerid, addressPrice[playerid], 50);
        PlayerTextDrawUseBox(playerid, addressPrice[playerid], 0);
        PlayerTextDrawSetProportional(playerid, addressPrice[playerid], 1);
        PlayerTextDrawSetSelectable(playerid, addressPrice[playerid], 0);

        PlayerAddress[playerid][0] = CreatePlayerTextDraw(playerid, 125.000000, 158.000000, "3000.street");
        PlayerTextDrawFont(playerid, PlayerAddress[playerid][0], 1);
        PlayerTextDrawLetterSize(playerid, PlayerAddress[playerid][0], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, PlayerAddress[playerid][0], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, PlayerAddress[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, PlayerAddress[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, PlayerAddress[playerid][0], 1);
        PlayerTextDrawColor(playerid, PlayerAddress[playerid][0], -1);
        PlayerTextDrawBackgroundColor(playerid, PlayerAddress[playerid][0], 255);
        PlayerTextDrawBoxColor(playerid, PlayerAddress[playerid][0], 50);
        PlayerTextDrawUseBox(playerid, PlayerAddress[playerid][0], 0);
        PlayerTextDrawSetProportional(playerid, PlayerAddress[playerid][0], 1);
        PlayerTextDrawSetSelectable(playerid, PlayerAddress[playerid][0], 0);

        PlayerAddress[playerid][1] = CreatePlayerTextDraw(playerid, 125.000000, 176.000000, "For Sale");
        PlayerTextDrawFont(playerid, PlayerAddress[playerid][1], 1);
        PlayerTextDrawLetterSize(playerid, PlayerAddress[playerid][1], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, PlayerAddress[playerid][1], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, PlayerAddress[playerid][1], 1);
        PlayerTextDrawSetShadow(playerid, PlayerAddress[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, PlayerAddress[playerid][1], 1);
        PlayerTextDrawColor(playerid, PlayerAddress[playerid][1], -1);
        PlayerTextDrawBackgroundColor(playerid, PlayerAddress[playerid][1], 255);
        PlayerTextDrawBoxColor(playerid, PlayerAddress[playerid][1], 50);
        PlayerTextDrawUseBox(playerid, PlayerAddress[playerid][1], 0);
        PlayerTextDrawSetProportional(playerid, PlayerAddress[playerid][1], 1);
        PlayerTextDrawSetSelectable(playerid, PlayerAddress[playerid][1], 0);

        PlayerAddress[playerid][2] = CreatePlayerTextDraw(playerid, 125.000000, 194.000000, "Business");
        PlayerTextDrawFont(playerid, PlayerAddress[playerid][2], 1);
        PlayerTextDrawLetterSize(playerid, PlayerAddress[playerid][2], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, PlayerAddress[playerid][2], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, PlayerAddress[playerid][2], 1);
        PlayerTextDrawSetShadow(playerid, PlayerAddress[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, PlayerAddress[playerid][2], 1);
        PlayerTextDrawColor(playerid, PlayerAddress[playerid][2], -1);
        PlayerTextDrawBackgroundColor(playerid, PlayerAddress[playerid][2], 255);
        PlayerTextDrawBoxColor(playerid, PlayerAddress[playerid][2], 50);
        PlayerTextDrawUseBox(playerid, PlayerAddress[playerid][2], 0);
        PlayerTextDrawSetProportional(playerid, PlayerAddress[playerid][2], 1);
        PlayerTextDrawSetSelectable(playerid, PlayerAddress[playerid][2], 0);

        PlayerAddress[playerid][3] = CreatePlayerTextDraw(playerid, 125.000000, 212.000000, "$100000");
        PlayerTextDrawFont(playerid, PlayerAddress[playerid][3], 1);
        PlayerTextDrawLetterSize(playerid, PlayerAddress[playerid][3], 0.345833, 1.799998);
        PlayerTextDrawTextSize(playerid, PlayerAddress[playerid][3], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, PlayerAddress[playerid][3], 1);
        PlayerTextDrawSetShadow(playerid, PlayerAddress[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, PlayerAddress[playerid][3], 1);
        PlayerTextDrawColor(playerid, PlayerAddress[playerid][3], -1);
        PlayerTextDrawBackgroundColor(playerid, PlayerAddress[playerid][3], 255);
        PlayerTextDrawBoxColor(playerid, PlayerAddress[playerid][3], 50);
        PlayerTextDrawUseBox(playerid, PlayerAddress[playerid][3], 0);
        PlayerTextDrawSetProportional(playerid, PlayerAddress[playerid][3], 1);
        PlayerTextDrawSetSelectable(playerid, PlayerAddress[playerid][3], 0);

        VEHSTUFF[playerid][0] = CreatePlayerTextDraw(playerid, 595.000000, 359.000000, "~n~~n~~n~");
        PlayerTextDrawFont(playerid, VEHSTUFF[playerid][0], 1);
        PlayerTextDrawLetterSize(playerid, VEHSTUFF[playerid][0], -0.004166, 1.500000);
        PlayerTextDrawTextSize(playerid, VEHSTUFF[playerid][0], 483.500000, 93.500000);
        PlayerTextDrawSetOutline(playerid, VEHSTUFF[playerid][0], 1);
        PlayerTextDrawSetShadow(playerid, VEHSTUFF[playerid][0], 0);
        PlayerTextDrawAlignment(playerid, VEHSTUFF[playerid][0], 1);
        PlayerTextDrawColor(playerid, VEHSTUFF[playerid][0], -1);
        PlayerTextDrawBackgroundColor(playerid, VEHSTUFF[playerid][0], 255);
        PlayerTextDrawBoxColor(playerid, VEHSTUFF[playerid][0], 50);
        PlayerTextDrawUseBox(playerid, VEHSTUFF[playerid][0], 1);
        PlayerTextDrawSetProportional(playerid, VEHSTUFF[playerid][0], 1);
        PlayerTextDrawSetSelectable(playerid, VEHSTUFF[playerid][0], 0);

        VEHSTUFF[playerid][1] = CreatePlayerTextDraw(playerid, 492.000000, 359.000000, "NAME:~n~SPEED:~n~FUEL:~n~");
        PlayerTextDrawFont(playerid, VEHSTUFF[playerid][1], 1);
        PlayerTextDrawLetterSize(playerid, VEHSTUFF[playerid][1], 0.370833, 1.500000);
        PlayerTextDrawTextSize(playerid, VEHSTUFF[playerid][1], 163.500000, 88.500000);
        PlayerTextDrawSetOutline(playerid, VEHSTUFF[playerid][1], 1);
        PlayerTextDrawSetShadow(playerid, VEHSTUFF[playerid][1], 0);
        PlayerTextDrawAlignment(playerid, VEHSTUFF[playerid][1], 1);
        PlayerTextDrawColor(playerid, VEHSTUFF[playerid][1], -2686721);
        PlayerTextDrawBackgroundColor(playerid, VEHSTUFF[playerid][1], 255);
        PlayerTextDrawBoxColor(playerid, VEHSTUFF[playerid][1], 50);
        PlayerTextDrawUseBox(playerid, VEHSTUFF[playerid][1], 0);
        PlayerTextDrawSetProportional(playerid, VEHSTUFF[playerid][1], 1);
        PlayerTextDrawSetSelectable(playerid, VEHSTUFF[playerid][1], 0);

        VEHSTUFF[playerid][2] = CreatePlayerTextDraw(playerid, 533.000000, 361.000000, "INFERNUS");
        PlayerTextDrawFont(playerid, VEHSTUFF[playerid][2], 1);
        PlayerTextDrawLetterSize(playerid, VEHSTUFF[playerid][2], 0.320832, 1.100000);
        PlayerTextDrawTextSize(playerid, VEHSTUFF[playerid][2], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, VEHSTUFF[playerid][2], 1);
        PlayerTextDrawSetShadow(playerid, VEHSTUFF[playerid][2], 0);
        PlayerTextDrawAlignment(playerid, VEHSTUFF[playerid][2], 1);
        PlayerTextDrawColor(playerid, VEHSTUFF[playerid][2], -1);
        PlayerTextDrawBackgroundColor(playerid, VEHSTUFF[playerid][2], 255);
        PlayerTextDrawBoxColor(playerid, VEHSTUFF[playerid][2], 50);
        PlayerTextDrawUseBox(playerid, VEHSTUFF[playerid][2], 0);
        PlayerTextDrawSetProportional(playerid, VEHSTUFF[playerid][2], 1);
        PlayerTextDrawSetSelectable(playerid, VEHSTUFF[playerid][2], 0);

        VEHSTUFF[playerid][3] = CreatePlayerTextDraw(playerid, 581.000000, 376.000000, "0 KM/H");
        PlayerTextDrawFont(playerid, VEHSTUFF[playerid][3], 1);
        PlayerTextDrawLetterSize(playerid, VEHSTUFF[playerid][3], 0.320832, 1.100000);
        PlayerTextDrawTextSize(playerid, VEHSTUFF[playerid][3], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, VEHSTUFF[playerid][3], 1);
        PlayerTextDrawSetShadow(playerid, VEHSTUFF[playerid][3], 0);
        PlayerTextDrawAlignment(playerid, VEHSTUFF[playerid][3], 3);
        PlayerTextDrawColor(playerid, VEHSTUFF[playerid][3], -1);
        PlayerTextDrawBackgroundColor(playerid, VEHSTUFF[playerid][3], 255);
        PlayerTextDrawBoxColor(playerid, VEHSTUFF[playerid][3], 50);
        PlayerTextDrawUseBox(playerid, VEHSTUFF[playerid][3], 0);
        PlayerTextDrawSetProportional(playerid, VEHSTUFF[playerid][3], 1);
        PlayerTextDrawSetSelectable(playerid, VEHSTUFF[playerid][3], 0);

        VEHSTUFF[playerid][4] = CreatePlayerTextDraw(playerid, 558.000000, 389.000000, "0 L");
        PlayerTextDrawFont(playerid, VEHSTUFF[playerid][4], 1);
        PlayerTextDrawLetterSize(playerid, VEHSTUFF[playerid][4], 0.320832, 1.100000);
        PlayerTextDrawTextSize(playerid, VEHSTUFF[playerid][4], 400.000000, 17.000000);
        PlayerTextDrawSetOutline(playerid, VEHSTUFF[playerid][4], 1);
        PlayerTextDrawSetShadow(playerid, VEHSTUFF[playerid][4], 0);
        PlayerTextDrawAlignment(playerid, VEHSTUFF[playerid][4], 3);
        PlayerTextDrawColor(playerid, VEHSTUFF[playerid][4], -1);
        PlayerTextDrawBackgroundColor(playerid, VEHSTUFF[playerid][4], 255);
        PlayerTextDrawBoxColor(playerid, VEHSTUFF[playerid][4], 50);
        PlayerTextDrawUseBox(playerid, VEHSTUFF[playerid][4], 0);
        PlayerTextDrawSetProportional(playerid, VEHSTUFF[playerid][4], 1);
        PlayerTextDrawSetSelectable(playerid, VEHSTUFF[playerid][4], 0);
    } 
    if(IsPlayerNPC(playerid)){
        new name[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid, name, sizeof(name));/*
        if(strcmp(name, "0", true) == 0){
            SetSpawnInfo(playerid, 0, 29, randomdrugdeals[0][0], randomdrugdeals[0][1], randomdrugdeals[0][2], 0, 0, 0,0 ,0 ,0 ,0);
            SpawnPlayer(playerid);
            printf("player is NPC and name = 1");
        }*/ 
        printf("%s", name);
    }

    return 1;
}

forward public LoadMapIcons(playerid);
public LoadMapIcons(playerid) {
    SetPlayerMapIcon(playerid, 1, 281.7589, 1411.7045, 9.8603, 24, 0, MAPICON_GLOBAL);
    for (new i = 0; i < loadedJob; i++) {
        if(jInfo[i][jID] == 1) {
            SetPlayerMapIcon(playerid, jInfo[i][jID] + 1, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], 60, 0, MAPICON_GLOBAL);
        }
        if(jInfo[i][jID] == 2) {
            SetPlayerMapIcon(playerid, jInfo[i][jID] + 1, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], 61, 0, MAPICON_GLOBAL);
        }
        if(jInfo[i][jID] == 3){
            SetPlayerMapIcon(playerid, jInfo[i][jID] + 1, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], 59, 0, MAPICON_GLOBAL);
            
        }
    }
    for(new i = 0; i < loadedHouse; i++){
        if(!strcmp(hInfo[i][hOwner], "NULL")){
            SetPlayerMapIcon(playerid, hInfo[i][hId]+10, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], 31, 0, MAPICON_GLOBAL);
        } else {
            SetPlayerMapIcon(playerid, hInfo[i][hId]+10, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], 32, 0, MAPICON_GLOBAL);
        }
    }
    return 1;
}

forward checkIfExists(playerid);
public checkIfExists(playerid) {
    // Checks to see if the user exists and show them a specific dialog dependant on registration status!
    new string[500];

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));
    if(cache_num_rows() > 0) {
        // User exists in the database!
        format(string, sizeof(string), "{FFFFFF} Welcome back to the server {A5EBF6}%s{FFFFFF}!\n\n Please input your password below to continue!", name);
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login System", string, "Login", "Quit");
    } else {
        // User does not exist in the database!
        format(string, sizeof(string), "{FFFFFF} Welcome, {A5EBF6}%s{FFFFFF}!\n\n{FFFFFF} This account is not registered!\n\n Please input a password below to continue!", GetName(playerid));
        Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Login System", string, "Register", "Quit");
    }
}

public OnPlayerDisconnect(playerid, reason) {
    if(pInfo[playerid][LoggedIn] == true) {
        SavePlayerData(playerid);

        PostCheckpoint[playerid] = 0;
        GarbageCheckpoint[playerid] = 0;
        dumpCheckPoint[playerid] = 0;
        speedoTimer[playerid] = 0;
        fuelTimer[playerid] = 0;

        if(pInfo[playerid][RentingVehicle] != INVALID_VEHICLE_ID) {
            UnrentVehicle(playerid, pInfo[playerid][RentingVehicle]);
        }
        printf("** [MYSQL] Player:%s data has been saved! Disconnecting user...", GetName(playerid));
        pInfo[playerid][LoggedIn] = false;
    }
    return 1;
}

/*- SAVING PLAYER DATA -*/
forward SaveNewPlayerData(playerid, hashed[BCRYPT_HASH_LENGTH]);
public SaveNewPlayerData(playerid, hashed[BCRYPT_HASH_LENGTH]) {
    new query[500];
    printf("** [MYSQL] Inserting new user account for:%s....", GetName(playerid));
    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `accounts` (`pName`, `pPassword`, `pEmail`, `pRegion`, `pHealth`, `pArmour`, `pBank`, `pCash`) VALUES ('%e', '%e', 'NULL', 'NULL', 100, 5, 0, 0)", GetName(playerid), hashed);
    mysql_query(db_handle, query);
    printf("** [MYSQL] Updating new account records...");
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pEmail` = '%e' WHERE  `pName` = '%e'", pInfo[playerid][pEmail], GetName(playerid));
    mysql_query(db_handle, query);
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pSkin` = '%d', `pGender` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pSkin], pInfo[playerid][pGender], GetName(playerid));
    mysql_query(db_handle, query);
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pAge` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pAge], GetName(playerid));
    mysql_query(db_handle, query);
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pRegion` = '%e' WHERE  `pName` = '%e'", pInfo[playerid][pRegion], GetName(playerid));
    mysql_query(db_handle, query);   
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pPhoneNumber` = 0 WHERE  `pName` = '%e'", GetName(playerid));
    mysql_query(db_handle, query); 
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeedAmount` = '%d', `pCokeAmount` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pWeedAmount], pInfo[playerid][pCokeAmount], GetName(playerid));
    mysql_query(db_handle, query);
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pLevel` = 1, `pExp` = 1, `pPayTimer` = 60, `pJobId` = 0, `pJobPay` = 0  WHERE  `pName` = '%e'", GetName(playerid));
    mysql_query(db_handle, query);

    SendClientMessage(playerid, 0x00FF00FF, "{99c0da}[SERVER]:{ABCDEF}You are now registered and logged in!");
    pInfo[playerid][LoggedIn] = true;
    pInfo[playerid][ID] = cache_insert_id();
    pInfo[playerid][pHealth] = 100;
    pInfo[playerid][pArmour] = 5;
    pInfo[playerid][pCash] = 1000;
    pInfo[playerid][pBank] = 0;
    pInfo[playerid][pLevel] = 1;
    pInfo[playerid][pExp] = 1;
    pInfo[playerid][pFactionId] = 0;
    pInfo[playerid][pFactionRank] = 0;
    pInfo[playerid][pFactionPay] = 0;
    pInfo[playerid][pJobId] = 0;
    pInfo[playerid][pJobPay] = 0;
    pInfo[playerid][pPayTimer] = 60;

    pInfo[playerid][pVehicleSlots] = 4;
    
    pInfo[playerid][pPhoneNumber] = 0;

    pInfo[playerid][CurrentState] = 0;
    pInfo[playerid][PostState] = 0;
    pInfo[playerid][GarbageState] = 0;

    SetPlayerScore(playerid, 1);
    GivePlayerMoney(playerid, pInfo[playerid][pCash]);

    BeginTutorial(playerid);
    return 1;
}
forward SavePlayerData(playerid);
public SavePlayerData(playerid) {
    new query[300], Float:armour, Float:health;

    /* get player stats*/
    pInfo[playerid][pCash] = GetPlayerMoney(playerid);
    GetPlayerHealth(playerid, health);
    pInfo[playerid][pHealth] = health;

    GetPlayerArmour(playerid, armour);
    pInfo[playerid][pArmour] = armour;

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pHealth` = '%f', `pArmour` = '%f', `pCash` = '%d', `pBank` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pHealth], pInfo[playerid][pArmour], pInfo[playerid][pCash], pInfo[playerid][pBank], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pLevel` = '%d', `pExp` = '%d', `pSkin` = '%d', `pPayTimer` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pLevel], pInfo[playerid][pExp], pInfo[playerid][pSkin], pInfo[playerid][pPayTimer], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pJobId` = '%d', `pJobPay` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pJobId], pInfo[playerid][pJobPay], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pFactionId` = '%d', `pFactionRank` = '%d', `pFactionRankname` = '%e', `pFactionPay` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pFactionId], pInfo[playerid][pFactionRank], pInfo[playerid][pFactionRankname], pInfo[playerid][pFactionPay], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pPhoneNumber` = '%d', `pPhoneModel` = '%d', `pGpsModel` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pPhoneNumber], pInfo[playerid][pPhoneModel], pInfo[playerid][pGpsModel], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeedAmount` = '%d', `pCokeAmount` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pWeedAmount], pInfo[playerid][pCokeAmount], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pCigAmount` = '%d', `pRopeAmount` = '%d', `pHasMask` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pCigAmount], pInfo[playerid][pRopeAmount], pInfo[playerid][pHasMask], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pDrivingLicense` = '%d', `pHeavyLicense` = '%d', `pPilotLicense` = '%d', `pGunLicense` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pDrivingLicense], pInfo[playerid][pHeavyLicense], pInfo[playerid][pPilotLicense], pInfo[playerid][pGunLicense], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pVehicleSlots` = '%d', `pVehicleSlotsUsed` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pVehicleSlots], pInfo[playerid][pVehicleSlotsUsed], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pPreferredSpawn` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pPreferredSpawn], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pFines` = '%d', `pMostRecentFine` = '%s' WHERE  `pName` = '%e'", pInfo[playerid][pFines], pInfo[playerid][pMostRecentFine], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWantedLevel` = '%d', `pMostRecentWantedReason` = '%s' WHERE  `pName` = '%e'", pInfo[playerid][pWantedLevel], pInfo[playerid][pMostRecentWantedReason], GetName(playerid));
    mysql_query(db_handle, query);
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pInPrisonType` = '%d', `pPrisonTimer` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pInPrisonType], pInfo[playerid][pPrisonTimer], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pDutyClothes` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pDutyClothes], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pAdminLevel` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pAdminLevel], GetName(playerid));
    mysql_query(db_handle, query);
    
    new weaponSlot[6][2];
    for(new i = 1; i < 5; i++){
        if(i == 2){
            GetPlayerWeaponData(playerid, i, weaponSlot[i][0], weaponSlot[i][1]);
            pInfo[playerid][pWeaponSlot1] = weaponSlot[i][0];
            pInfo[playerid][pWeaponSlot1Ammo] = weaponSlot[i][1];
            mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeaponSlot1` = '%d', `pWeaponSlot1Ammo` = '%d' WHERE  `pName` = '%e'",pInfo[playerid][pWeaponSlot1], pInfo[playerid][pWeaponSlot1Ammo], GetName(playerid));
            mysql_query(db_handle, query);
        }
        if(i == 3){
            GetPlayerWeaponData(playerid, i, weaponSlot[i][0], weaponSlot[i][1]);
            pInfo[playerid][pWeaponSlot2] = weaponSlot[i][0];
            pInfo[playerid][pWeaponSlot2Ammo] = weaponSlot[i][1];
            mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeaponSlot2` = '%d', `pWeaponSlot2Ammo` = '%d' WHERE  `pName` = '%e'",pInfo[playerid][pWeaponSlot2], pInfo[playerid][pWeaponSlot2Ammo], GetName(playerid));
            mysql_query(db_handle, query);
        }
        if(i == 4){
            GetPlayerWeaponData(playerid, i, weaponSlot[i][0], weaponSlot[i][1]);
            pInfo[playerid][pWeaponSlot3] = weaponSlot[i][0];
            pInfo[playerid][pWeaponSlot3Ammo] = weaponSlot[i][1];
            mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeaponSlot3` = '%d', `pWeaponSlot3Ammo` = '%d' WHERE  `pName` = '%e'",pInfo[playerid][pWeaponSlot3], pInfo[playerid][pWeaponSlot3Ammo], GetName(playerid));
            mysql_query(db_handle, query);
        }
    }

    SetTimerEx("SavePlayerData", 300000, false, "ds", playerid, "SA-MP"); //called "function" when 5 mins elapsed

    return 1;
}

public OnPlayerSpawn(playerid) {
    if(!IsPlayerNPC(playerid)){
        if(pInfo[playerid][LoggedIn] == true) {
            pInfo[playerid][pMuted] = 0;
            pInfo[playerid][CurrentState] = 0;
            pInfo[playerid][RentingVehicle] = INVALID_VEHICLE_ID;

            SetTimerEx("SavePlayerData", 300000, false, "ds", playerid, "SA-MP"); //called "function" when 5 mins elapsed
            SetTimerEx("payPlayerTimer", 30000, false, "ds", playerid, "SA-MP"); //called "function" when 10 seconds elapsed
        }
    }
    if(IsPlayerNPC(playerid)){
        printf("NPC: %d has connected to the server.", playerid);
        return 1;
    }
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
    HideSpeedoTextdraws(playerid);
    return 1;
}

public OnVehicleSpawn(vehicleid) {
    return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
    return 1;
}


public OnPlayerText(playerid, text[]) {
    if(pInfo[playerid][pMuted] == 0) {
        if(IsPlayerInRangeOfPoint(playerid, 5, 9998.7725,10012.2715,10001.0869)){
            if(fInfo[3][IsLive] == 1){
                new string[256];
                format(string, sizeof(string), "{00bfff}SANN Radio: %s says: %s", RPName(playerid), text);
                SendClientMessageToAll(COLOR_AQUA, string);
            }
        } else {
            if(pInfo[playerid][OnCall] >= 1 && pInfo[playerid][OnCall] != 911 && pInfo[playerid][OnCall] != 3170){ 
                new string[256];
                format(string, sizeof(string), "{FFFFE0}[PHONE] %s", RPName(playerid), text);
                for(new i = 0; i < MAX_PLAYERS; i++){
                    if(pInfo[i][pPhoneNumber] == pInfo[playerid][OnCall]){        
                        SendClientMessage(i, -1, string);
                        SendClientMessage(playerid, -1, string);
                    }
                }
            } else if(pInfo[playerid][OnCall] == 911){
                if(pInfo[playerid][AwaitingReason] == 0){
                    if(strfind(text, "police", true) != -1){
                        new string[256];
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        format(string, sizeof(string), "[PHONE]: Okay - what is the situation?");
                        SendClientMessage(playerid, -1, string);
                        pInfo[playerid][CalledService] = 1;
                        pInfo[playerid][AwaitingReason] = 1;
                    }
                    if(strfind(text, "medics", true) != -1){
                        new string[256];
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        format(string, sizeof(string), "[PHONE]: I'm patching you through. Whats the situation?");
                        SendClientMessage(playerid, -1, string);
                        pInfo[playerid][CalledService] = 2;
                        pInfo[playerid][AwaitingReason] = 1;
                    }
                    
                    if(strfind(text, "firefighter", true) != -1){
                        new string[256];
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        format(string, sizeof(string), "[PHONE]: We're putting you through now! Any information for the firefighters?");
                        SendClientMessageA(playerid, -1, string);
                        pInfo[playerid][CalledService] = 3;
                        pInfo[playerid][AwaitingReason] = 1;
                    }
                } else {     
                    if(pInfo[playerid][CalledService] == 1){
                        new string[256];     
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        new Float:px, Float:py, Float:pz;
                        GetPlayerPos(playerid, px, py, pz);
                        new msg[50];
                        format(msg, sizeof(msg), "%s", text);
                        AlertPolice(playerid, msg, px, py, pz);
                        format(string, sizeof(string), "[PHONE]: Thank you. The police have been notified.");

                        SendClientMessage(playerid, -1, string);
                        pInfo[playerid][CalledService] = 0;
                        pInfo[playerid][AwaitingReason] = 0;
                        pInfo[playerid][OnCall] = 0;
                        
                        format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        
                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                    }
                    if(pInfo[playerid][CalledService] == 2){
                        new string[256];     
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        new Float:px, Float:py, Float:pz;
                        GetPlayerPos(playerid, px, py, pz);
                        new msg[50];
                        format(msg, sizeof(msg), "%s", text);
                        AlertMedics(playerid, msg,0, px, py, pz);
                        format(string, sizeof(string), "[PHONE]: Thank you. The medics have been notified.");

                        SendClientMessage(playerid, -1, string);
                        pInfo[playerid][CalledService] = 0;
                        pInfo[playerid][AwaitingReason] = 0;
                        pInfo[playerid][OnCall] = 0;
                        
                        format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        
                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                    }
                    if(pInfo[playerid][CalledService] == 3){
                        new string[256];     
                        format(string, sizeof(string), "[PHONE]: %s", text);
                        SendClientMessage(playerid, -1, string);
                        new Float:px, Float:py, Float:pz;
                        GetPlayerPos(playerid, px, py, pz);
                        new msg[50];
                        format(msg, sizeof(msg), "%s", text);
                        AlertMedics(playerid, msg,0, px, py, pz);
                        format(string, sizeof(string), "[PHONE]: Thank you. The firefighters have been notified.");

                        SendClientMessage(playerid, -1, string);
                        pInfo[playerid][CalledService] = 0;
                        pInfo[playerid][AwaitingReason] = 0;
                        pInfo[playerid][OnCall] = 0;
                        
                        format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        
                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                    }
                }
            } else if(pInfo[playerid][OnCall] == 227){
                new string[256];
                format(string, sizeof(string), "[PHONE]: %s", text);
                SendClientMessage(playerid, -1, string);
                format(string, sizeof(string), "[PHONE]: Thank you, our engineers have been alerted!");
                SendClientMessage(playerid, -1, string);

                for(new i = 0; i < MAX_PLAYERS; i++){
                    if(pInfo[i][pFactionId] == 3){         
                        format(string, sizeof(string), "{FFFFFF}Radio: ALERT: %s, call code: %d", text, playerid);
                        printf("Mechanic alerted with msg: %s", text);
                        SendClientMessage(i, SERVERCOLOR, string);
                    }
                }
                
                pInfo[playerid][pAlertCall] = 3;
                format(pInfo[playerid][pAlertMsg], 80, "%s", text);
                
                pInfo[playerid][OnCall] = 0;
                        
                format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
                nearByAction(playerid, NICESKY, string);
                        
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
            } else if(pInfo[playerid][OnCall] == 3170){
                new string[256];
                format(string, sizeof(string), "[PHONE]: %s", text);
                SendClientMessage(playerid, -1, string);
                format(string, sizeof(string), "{00bfff}SANN Radio: %s says: %s", RPName(playerid), text);
                SendClientMessageToAll(COLOR_AQUA, string);
            } else if(IsPlayerInAnyVehicle(playerid) && GetVehicleModel(GetPlayerVehicleID(playerid)) == 582){
                new vid = GetPlayerVehicleID(playerid) - 1;
                if(vInfo[vid][IsLive] == 1){
                    new string[256];
                    format(string, sizeof(string), "{00bfff}SANN Radio: %s says: %s", RPName(playerid), text);
                    SendClientMessageToAll(COLOR_AQUA, string);
                } else {
                    new string[256];
                    format(string, sizeof(string), "%s[%i] says: %s", RPName(playerid), playerid, text);
                    nearByMessage(playerid, -1, string, 12.0);
                }
            } else  {
                new string[256];
                format(string, sizeof(string), "%s[%i] says: %s", RPName(playerid), playerid, text);
                nearByMessage(playerid, -1, string, 12.0);
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, PMuted);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 0;
}

/* Global fac cmds followed by specific fac cmds */
CMD:hire(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionRank] == 7){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, -1, "[SERVER]: /hire [playerid]");{
            if(pInfo[target][pFactionId] >= 1){
                SendClientMessage(playerid,  ADMINBLUE, "[SERVER]: This player is already in a faction!");
                return 1;
            } else {
                pInfo[target][pFactionId] = pInfo[playerid][pFactionId];
                pInfo[target][pFactionRank] = 1;
                SetFactionRanknameByRank(target, pInfo[playerid][pFactionId], 1);
                new string[256];
                format(string, sizeof(string), "[SERVER]: You have hired: %s !", RPName(target));
                SendClientMessage(playerid, ADMINBLUE, string);
                format(string, sizeof(string), "[SERVER]: You have been hired by: %s !", RPName(playerid));
                SendClientMessage(target, ADMINBLUE, string);
            }
        }
    }
    return 1;
}

CMD:fire(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionRank] == 7){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, -1, "[SERVER]: /fire [playerid]");{
            if(target != playerid){
                if(pInfo[target][pFactionId] != pInfo[playerid][pFactionId]){
                    SendClientMessage(playerid,  ADMINBLUE, "[SERVER]: This player is not a member of your faction!");
                    return 1;
                } else {
                    pInfo[target][pFactionId] = 0;
                    pInfo[target][pFactionRank] = 0;
                    new string[256];
                    format(string, sizeof(string), "[SERVER]: You have fired: %s !", RPName(target));
                    SendClientMessage(playerid, ADMINBLUE, string);
                    format(string, sizeof(string), "[SERVER]: You have been fired by: %s !", RPName(playerid));
                    SendClientMessage(target, ADMINBLUE, string);
                }
            }
        }
    }
    return 1;
}

CMD:demote(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionRank] == 7){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, -1, "[SERVER]: /demote [playerid]");{
            if(target != playerid){
                if(pInfo[target][pFactionRank] > 1){
                    pInfo[target][pFactionRank]--;
                    SetFactionRanknameByRank(target, pInfo[playerid][pFactionId], pInfo[target][pFactionRank]);
                    new string[256];
                    format(string, sizeof(string), "[SERVER]: You have demoted: %s!", RPName(target));
                    SendClientMessage(playerid, ADMINBLUE, string);
                    format(string, sizeof(string), "[SERVER]: You have demoted by: %s!", RPName(playerid));
                    SendClientMessage(target, ADMINBLUE, string);
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:promote(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionRank] == 7){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, -1, "[SERVER]: /promote [playerid]");{
            if(target != playerid){
                if(pInfo[target][pFactionRank] < 7){
                    pInfo[target][pFactionRank]++;
                    SetFactionRanknameByRank(target, pInfo[playerid][pFactionId], pInfo[target][pFactionRank]);
                    new string[256];
                    format(string, sizeof(string), "[SERVER]: You have promoted: %s!", RPName(target));
                    SendClientMessage(playerid, ADMINBLUE, string);
                    format(string, sizeof(string), "[SERVER]: You have promoted by: %s!", RPName(playerid));
                    SendClientMessage(target, ADMINBLUE, string);
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:rankname(playerid, params[]){
    if(pInfo[playerid][pFactionId] >= 1){
        if(pInfo[playerid][pFactionRank] >= 7){
            new target, rankname[32], string[256];
            if(sscanf(params, "ds", target, rankname)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /rankname [id] [rankname]"); {          
                pInfo[playerid][pFactionRankname] = rankname;
                format(string, sizeof(string), "> You have set %s's rankname to: %s!", RPName(target), rankname);
                SendClientMessage(playerid, ADMINBLUE, string);
                
                format(string, sizeof(string), "> %s %s has set your rankname to: %s!", pInfo[playerid][pFactionRankname], RPName(playerid), rankname);
                SendClientMessage(target, ADMINBLUE, string);
                return 1;
            }
        }
    }
    return 1;
}

CMD:duty(playerid, params[]){
    if(pInfo[playerid][pFactionId] >= 1){
        for(new i = 0; i < loadedFac; i++){
            if(fInfo[i][fType] == 2) {// a legal faction...
                if(IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fDutyX], fInfo[i][fDutyY], fInfo[i][fDutyZ])){
                    if(fInfo[i][fID] == pInfo[playerid][pFactionId]){
                        if(pInfo[playerid][pDuty] == 0){
                            if(pInfo[playerid][pDutyClothes] != 0){
                                SetPlayerSkin(playerid, pInfo[playerid][pDutyClothes]);
                                pInfo[playerid][pDuty] = 1;
                                GiveSpecificWeapons(playerid);

                                return 1;
                            } else {
                                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have not set your duty clothes!");
                                return 1;
                            }
                        } else {
                            pInfo[playerid][pDuty] = 0;
                            SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
                        }

                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You cannot use this duty point!");
                    }
                }
            }
        }
    }
    return 1;
}

stock GiveSpecificWeapons(playerid){
    if(pInfo[playerid][pFactionId] == 1){
        GivePlayerWeapon(playerid, 24, 182);
        GivePlayerWeapon(playerid, 41, 3000);
        GivePlayerWeapon(playerid, 31, 400);
    }
    if(pInfo[playerid][pFactionId] == 2){
        GivePlayerWeapon(playerid, 42, 5000);
        GivePlayerWeapon(playerid, 9, 1);
    }
    if(pInfo[playerid][pFactionId] == 4){
        GivePlayerWeapon(playerid, 43, 1000);
    }
    return 1;
}

stock randomEx(min,max) {
	return (min+random(max));
}

forward public startARandomFire();

public startARandomFire(){
    new selectedType;
    KillTimer(fireCallTimer[0]);
    printf("starting random fire, %dsinfo", sInfo[0][firePutOut]);
    DeleteAllFire();
    if(sInfo[0][firePutOut] == 1){
        sInfo[0][firePutOut] = 0;
        sInfo[0][lastFireAddress] = 0;
        sInfo[0][lastFireType] = 0;
        selectedType = randomEx(1,3);
        printf("%d", selectedType);
        if(selectedType == 1){
            // selected faction fire..
            new randomID, faction;
            faction = loadedFac;
            randomID = randomEx(1, faction);
            printf("Selected faction fire ID: %d", randomID);
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fID] == randomID && fInfo[i][fAddress] != 999999){
                    if(fInfo[i][fEntX] != 0){
                        AddFire(fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ], randomEx(250,700));
                        AddFire(fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ], randomEx(250, 600));
                        AddFire(fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], randomEx(250, 600));
                    }
                    if(fInfo[i][fEntX] == 0){
                        AddFire(fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], randomEx(250, 600));
                        AddFire(fInfo[i][fDutyX], fInfo[i][fDutyX], fInfo[i][fDutyZ], randomEx(250, 600));
                    }
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", fInfo[i][fAddress]);
                    AlertMedics(9999, string,fInfo[i][fAddress], fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ]);
                    fInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = fInfo[i][fAddress];
                    sInfo[0][lastFireType] = 1;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("Faction fire started at: %d.street!", fInfo[i][fAddress]);
                    return 1;
                }
            }
        }
        
        if(selectedType == 2){
            // selected business fire..
            new randomID, business;
            business = loadedBus;
            randomID = randomEx(1, business);
            printf("Selected business fire ID: %d", randomID);
            for(new i = 0; i < loadedBus; i++){
                if(bInfo[i][bId] == randomID){
                    if(bInfo[i][bEntX] != 0){
                        AddFire(bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ], randomEx(250,700));
                        AddFire(bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ], randomEx(250, 600));
                        AddFire(bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], randomEx(250, 600));
                    }
                    if(bInfo[i][bEntX] == 0){
                        AddFire(bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], randomEx(250, 600));
                        AddFire(bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ], randomEx(250, 600));
                    }
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", bInfo[i][bAddress]);
                    AlertMedics(9999, string, bInfo[i][bAddress], bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ]);
                    bInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = bInfo[i][bAddress];
                    sInfo[0][lastFireType] = 2;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("business fire started at: %d.street!", bInfo[i][bAddress]);
                    return 1;
                }
            }
        }
        
        if(selectedType == 3){
            // selected house fire..
            new randomID, house;
            house = loadedHouse;
            randomID = randomEx(1, house);
            printf("Selected house fire ID: %d", randomID);
            for(new i = 0; i < loadedHouse; i++){
                if(hInfo[i][hId] == randomID){
                    AddFire(hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ], randomEx(50,500));
                    AddFire(hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ], randomEx(50,500));
                    
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", hInfo[i][hAddress]);
                    AlertMedics(9999, string,hInfo[i][hAddress], hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ]);
                    hInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = hInfo[i][hAddress];
                    sInfo[0][lastFireType] = 3;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("house fire started at: %d.street!", hInfo[i][hAddress]);
                    return 1;
                }
            }
        }
    } else if(sInfo[0][firePutOut] == 0){
        sInfo[0][firePutOut] = 0;
        sInfo[0][lastFireAddress] = 0;
        sInfo[0][lastFireType] = 0;
        selectedType = randomEx(1,3);
        printf("%d", selectedType);
        if(selectedType == 1){
            // selected faction fire..
            new randomID, faction;
            faction = loadedFac;
            randomID = randomEx(1, faction);
            printf("Selected faction fire ID: %d", randomID);
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fID] == randomID && fInfo[i][fAddress] != 999999){
                    if(fInfo[i][fEntX] != 0){
                        AddFire(fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ], randomEx(250,700));
                        AddFire(fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ], randomEx(250, 600));
                        AddFire(fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], randomEx(250, 600));
                    }
                    if(fInfo[i][fEntX] == 0){
                        AddFire(fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ], randomEx(250, 600));
                        AddFire(fInfo[i][fDutyX], fInfo[i][fDutyX], fInfo[i][fDutyZ], randomEx(250, 600));
                    }
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", fInfo[i][fAddress]);
                    AlertMedics(9999, string,fInfo[i][fAddress], fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ]);
                    fInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = fInfo[i][fAddress];
                    sInfo[0][lastFireType] = 1;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("Faction fire started at: %d.street!", fInfo[i][fAddress]);
                    return 1;
                }
            }
        }
        
        if(selectedType == 2){
            // selected business fire..
            new randomID, business;
            business = loadedBus;
            randomID = randomEx(1, business);
            printf("Selected business fire ID: %d", randomID);
            for(new i = 0; i < loadedBus; i++){
                if(bInfo[i][bId] == randomID){
                    if(bInfo[i][bEntX] != 0){
                        AddFire(bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ], randomEx(250,700));
                        AddFire(bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ], randomEx(250, 600));
                        AddFire(bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], randomEx(250, 600));
                    }
                    if(bInfo[i][bEntX] == 0){
                        AddFire(bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], randomEx(250, 600));
                        AddFire(bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ], randomEx(250, 600));
                    }
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", bInfo[i][bAddress]);
                    AlertMedics(9999, string,bInfo[i][bAddress], bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ]);
                    bInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = bInfo[i][bAddress];
                    sInfo[0][lastFireType] = 2;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("business fire started at: %d.street!", bInfo[i][bAddress]);
                    return 1;
                }
            }
        }
        
        if(selectedType == 3){
            // selected house fire..
            new randomID, house;
            house = loadedHouse;
            randomID = randomEx(1, house);
            printf("Selected house fire ID: %d", randomID);
            for(new i = 0; i < loadedHouse; i++){
                if(hInfo[i][hId] == randomID){
                    AddFire(hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ], randomEx(50,500));
                    AddFire(hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ], randomEx(50,500));
                    
                    new string[50];
                    format(string, sizeof(string), "%d.street is on fire! Responders needed ASAP!", hInfo[i][hAddress]);
                    AlertMedics(9999, string,hInfo[i][hAddress], hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ]);
                    hInfo[i][OnFire] = 1;
                    sInfo[0][lastFireAddress] = hInfo[i][hAddress];
                    sInfo[0][lastFireType] = 3;
                    fireCallTimer[0] = SetTimer("startARandomFire", 900000, false);
                    printf("house fire started at: %d.street!", hInfo[i][hAddress]);
                    return 1;
                }
            }
        }
    }
    return 1;
}


stock AddFire(Float:x, Float:y, Float:z, Health)
{
    TotalFires++;
	new fireID = TotalFires;
	FireObj[fireID] = CreateObject(3461, x, y, z-2.61, 0, 0, 0.0);
	FirePos[fireID][0] = x, FirePos[fireID][1] = y, FirePos[fireID][2] = z;
	FireHealth[fireID] = Health;
	FireHealthMax[fireID] = Health;
	#if defined Labels
	    new string[128];
	    format(string, sizeof(string), "%d/%d", FireHealth[fireID], FireHealthMax[fireID]);
	    FireText[fireID] = Create3DTextLabel(string, 0xFFFFFFFFF, x, y, z, 20, 0);
	#endif
}


stock DeleteFire(fiID)
{
	DestroyObject(FireObj[fiID]);
	TotalFires--;
	FirePos[fiID][0] = 0, FirePos[fiID][1] = 0, FirePos[fiID][2] = 0;
	#if defined Labels
	    Delete3DTextLabel(FireText[fiID]);
	#endif
}
stock DeleteAllFire()
{
	new fiID;
	for(fiID = 0; fiID<MAX_FIRES; fiID++)
	{
		DestroyObject(FireObj[fiID]);
		TotalFires= 0;
		FirePos[fiID][0] = 0, FirePos[fiID][1] = 0, FirePos[fiID][2] = 0;
		#if defined Labels
	    	Delete3DTextLabel(FireText[fiID]);
		#endif
	}
}
stock IsValidFire(firID)
{
	if( (FirePos[firID][0] != 0) && (FirePos[firID][1] != 0) && (FirePos[firID][2] != 0) ) return true;
	else return false;
}

stock GetClosestFire(playerid)
{
	new i;
	for(i = 0; i<MAX_FIRES; i++)
	{
	    if(IsValidFire(i) && IsPlayerInRangeOfPoint(playerid, 1, FirePos[i][0],  FirePos[i][1],  FirePos[i][2]))
	    {
	        return i;
		}
	}
	return 0;
}





Float:DistanceCameraTargetToLocation(Float:CamX, Float:CamY, Float:CamZ,   Float:ObjX, Float:ObjY, Float:ObjZ,   Float:FrX, Float:FrY, Float:FrZ) {

	new Float:TGTDistance;
	TGTDistance = floatsqroot((CamX - ObjX) * (CamX - ObjX) + (CamY - ObjY) * (CamY - ObjY) + (CamZ - ObjZ) * (CamZ - ObjZ));
	new Float:tmpX, Float:tmpY, Float:tmpZ;
	tmpX = FrX * TGTDistance + CamX;
	tmpY = FrY * TGTDistance + CamY;
	tmpZ = FrZ * TGTDistance + CamZ;
	return floatsqroot((tmpX - ObjX) * (tmpX - ObjX) + (tmpY - ObjY) * (tmpY - ObjY) + (tmpZ - ObjZ) * (tmpZ - ObjZ));
}

stock PlayerFaces(playerid, Float:x, Float:y, Float:z, Float:radius)
{
        new Float:cx,Float:cy,Float:cz,Float:fx,Float:fy,Float:fz;
        GetPlayerCameraPos(playerid, cx, cy, cz);
        GetPlayerCameraFrontVector(playerid, fx, fy, fz);
        return (radius >= DistanceCameraTargetToLocation(cx, cy, cz, x, y, z, fx, fy, fz));
}

public VehicleToPoint(Float:radi, vehicleid, Float:x, Float:y, Float:z)
{
		new Float:oldposx, Float:oldposy, Float:oldposz;
		new Float:tempposx, Float:tempposy, Float:tempposz;
		GetVehiclePos(vehicleid, oldposx, oldposy, oldposz);
		tempposx = (oldposx -x);
		tempposy = (oldposy -y);
		tempposz = (oldposz -z);
		//printf("DEBUG: X:%f Y:%f Z:%f",posx,posy,posz);
		if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi)))
		{
			return 1;
		}
		return 0;
}

public HealthDown()
{
	new i,v,p;
	for(i = 0; i<MAX_FIRES; i++)
	{
		if(IsValidFire(i))
		{
			for(p = 0; p<MAX_PLAYERS; p++)
			{
				if(IsPlayerInRangeOfPoint(p, 1, FirePos[i][0], FirePos[i][1], FirePos[i][2]) && !IsPlayerInAnyVehicle(p))
				{
	  				new Float:HP;
		    		GetPlayerHealth(p, HP);
	  				SetPlayerHealth(p, HP-4);
				}	
			}
			for(v = 0; v<MAX_VEHICLES; v++)
			{
				if(VehicleToPoint(2, v, FirePos[i][0], FirePos[i][1], FirePos[i][2]))
				{
					new Float:HP;
		    		GetVehicleHealth(v, HP);
	  				SetVehicleHealth(v, HP-30);
				}
			}
		}
	}
}

CMD:dutyclothes(playerid, params[]){
    if(pInfo[playerid][pFactionId] >= 1){
        for(new i = 0; i < loadedFac; i++){
            if(pInfo[playerid][pFactionId] == 1){
                if(IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fClothesX], fInfo[i][fClothesY], fInfo[i][fClothesZ])){
                    new subString[64]; 
                    static string[sizeof(POLICECLOTHES) * sizeof(subString)];

                    if(string[0] == EOS){           
                        for (new si; si < sizeof(POLICECLOTHES); si++) {
                            format(subString, sizeof(subString), "%i(0.0, 0.0, -50.0, 1.5)\t%s\n", POLICECLOTHES[si][SKINID], POLICECLOTHES[si][SKINNAME]);
                            strcat(string, subString);
                        }
                    }

                    return ShowPlayerDialog(playerid, 9998, DIALOG_STYLE_PREVIEW_MODEL, "Police Clothes", string, "Accept", "Decline");

                }
            }
            if(pInfo[playerid][pFactionId] == 2){
                if(IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fClothesX], fInfo[i][fClothesY], fInfo[i][fClothesZ])){
                    new subString[64]; 
                    static string[sizeof(MEDICCLOTHES) * sizeof(subString)];

                    if(string[0] == EOS){           
                        for (new si; si < sizeof(MEDICCLOTHES); si++) {
                            format(subString, sizeof(subString), "%i(0.0, 0.0, -50.0, 1.5)\t%s\n", MEDICCLOTHES[si][SKINID], MEDICCLOTHES[si][SKINNAME]);
                            strcat(string, subString);
                        }
                    }

                    return ShowPlayerDialog(playerid, 9997, DIALOG_STYLE_PREVIEW_MODEL, "Medic Clothes", string, "Accept", "Decline");

                }
            }
            if(pInfo[playerid][pFactionId] == 3){
                if(IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fClothesX], fInfo[i][fClothesY], fInfo[i][fClothesZ])){
                    new subString[64]; 
                    static string[sizeof(TOWCLOTHES) * sizeof(subString)];

                    if(string[0] == EOS){           
                        for (new si; si < sizeof(TOWCLOTHES); si++) {
                            format(subString, sizeof(subString), "%i(0.0, 0.0, -50.0, 1.5)\t%s\n", TOWCLOTHES[si][SKINID], TOWCLOTHES[si][SKINNAME]);
                            strcat(string, subString);
                        }
                    }

                    return ShowPlayerDialog(playerid, 9996, DIALOG_STYLE_PREVIEW_MODEL, "Towing Company Clothes", string, "Accept", "Decline");

                }
            }
        }
    }
    return 1;
}

/* SHOP CMDS */
CMD:shop(playerid, params[]){
    // ifplayerinrangeofpoint (check if they are near a shop/hardware store)
    for(new i = 0; i < loadedBus; i++){
        if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
            SwitchBetweenBusinessType(playerid, bInfo[i][bType]);
        }
    }
    return 1;
}

forward public SwitchBetweenBusinessType(playerid, bustype);
public SwitchBetweenBusinessType(playerid, bustype){
    switch(bustype){
        case 1: {
            ShowMenuForPlayer(hardwaremenu, playerid); // show the hardware menu!
            TogglePlayerControllable(playerid, false); // freeze player so they can use the menu
            return 1;
        }
        case 2: {
            // 24/7 general store
            Dialog_Show(playerid, DIALOG_247, DIALOG_STYLE_LIST, "General Store", "Cigarretes ($14)\n\nRope ($30)\n\nMask ($150)\n\nLottery Ticket ($17)", "Purchase", "Decline");
            return 1;
        }
        case 3: {
            // ammunation
            if(pInfo[playerid][pGunLicense] == 1){
                ShowMenuForPlayer(AmmunationMenu, playerid);
                TogglePlayerControllable(playerid, false); // freeze player so they can use the menu
                return 1;
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not have a gun license!");
                return 1;
            }
        }
        case 5:{
            // car dealership
            if(pInfo[playerid][pVehicleSlotsUsed] < pInfo[playerid][pVehicleSlots]){
                // player has less than or equal to their vehicleslots.
                new subString[64]; 
                static string[sizeof(BUS_DEALERSHIP) * sizeof(subString)];

                if(string[0] == EOS){           
                    for (new i; i < sizeof(BUS_DEALERSHIP); i++) {
                        format(subString, sizeof(subString), "%i(0.0, 0.0, -50.0, 1.5)\t%s~n~~g~~h~$%i\n", BUS_DEALERSHIP[i][VEHICLE_MODELID], BUS_DEALERSHIP[i][VEHICLE_NAME], BUS_DEALERSHIP[i][VEHICLE_PRICE]);
                        strcat(string, subString);
                    }
                }

                return ShowPlayerDialog(playerid, 9999, DIALOG_STYLE_PREVIEW_MODEL, "Car Dealership", string, "Purchase", "Decline");
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have used all of your available vehicle slots!");
                return 1;
            }
        }
    }
    return 1;
}

CMD:createrentalvehicle(playerid, params[]){
    new vehid, busId, price,plate[32],query[900], Float:px, Float:py, Float:pz, Float:pa;
    if(pInfo[playerid][pAdminLevel] >= 5){
        GetPlayerPos(playerid, px, py, pz);
        GetPlayerFacingAngle(playerid, pa);
        if(sscanf(params, "ddds[32]", vehid, busId, price, plate)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createrentalvehicle [vehid] [busid] [price] [plate]");{
            mysql_format(db_handle, query, sizeof(query), "INSERT INTO `vehicles` (`vModelId`,`vOwner`,`vFuel`, `vBusId`,`vPlate`,`vRentalPrice`, `vParkedX`,`vParkedY`,`vParkedZ`, `vAngle`, `vRentalState`) VALUES ('%d', 'NULL', '100', '%d','%s','%d','%f','%f','%f', '%f', '1')", vehid, busId,plate,price, px,py,pz,pa);
            mysql_tquery(db_handle, query, "OnRentalVehCreated", "dddd", playerid,vehid, busId, price);
        }
        return 1;
    }
    return 1;
}

CMD:createfactionvehicle(playerid, params[]){
    new vehid, facid, price,plate[32],query[900], Float:px, Float:py, Float:pz, Float:pa;
    if(pInfo[playerid][pAdminLevel] >= 5){
        GetPlayerPos(playerid, px, py, pz);
        GetPlayerFacingAngle(playerid, pa);
        if(sscanf(params, "dds[32]", vehid, facid, plate)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createrentalvehicle [vehid] [facid] [plate]");{
            mysql_format(db_handle, query, sizeof(query), "INSERT INTO `vehicles` (`vModelId`,`vOwner`,`vFuel`, `vFacId`,`vPlate`,`vParkedX`,`vParkedY`,`vParkedZ`, `vAngle`, `vRentalState`) VALUES ('%d', 'NULL', '100', '%d','%s','%f','%f','%f', '%f', '0')", vehid, facid,plate, px,py,pz,pa);
            mysql_tquery(db_handle, query, "OnFactionVehCreated", "ddd", playerid,vehid, facid);
        }
        return 1;
    }
    return 1;
}

CMD:lockhouse(playerid, params[]){
    new name[32], string[256];
    for(new i = 0; i < loadedHouse; i++){
        if(IsPlayerInRangeOfPoint(playerid, 3, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ])){
            GetPlayerName(playerid, name, sizeof(name));
            if(!strcmp(name, hInfo[i][hOwner])){
                if(hInfo[i][hLockedState] == 0){
                    hInfo[i][hLockedState] = 1;
                    format(string, sizeof(string), "* %s takes their key from their pockets and locks the house door.", RPName(playerid));
                    nearByAction(playerid, NICESKY, string);
                    return 1;
                }
                if(hInfo[i][hLockedState] == 1){
                    hInfo[i][hLockedState] = 0;
                    format(string, sizeof(string), "* %s takes their key from their pockets and unlocks the house door.", RPName(playerid));
                    nearByAction(playerid, NICESKY, string);
                    return 1;
                }
            } else {
                TextDrawShowForPlayer(playerid, CantCommand);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
                return 1;
            }
        }
    }
    return 1;
}

CMD:createhouse(playerid, params[]){
    new address, type, price, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "ddd", address, type, price)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createhouse [hAddress] [hType] [hPrice]"); {
            if(type != 5 && type != 2 && type != 1) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} House types: 1(Sweets), 2(Ryders), 5 (Ganghouse)");
                return 1;
            }
            if(type == 1){
                GetPlayerPos(playerid, px, py, pz);
                mysql_format(db_handle, query, sizeof(query), "INSERT INTO `houses` (`hAddress`,`hType`,`hOwner`, `hPrice`, `hInfoX`,`hInfoY`,`hInfoZ`, `hExitX`, `hExitY`,`hExitZ`) VALUES ('%d', '%d', 'NULL', '%d','%f','%f','%f', '2527.654052','-1679.388305','1015.498596')", address,type, price, px, py, pz);
                mysql_tquery(db_handle, query, "OnHouseCreated", "dddd", playerid, address, type, price);
            }
            if(type == 2){
                GetPlayerPos(playerid, px, py, pz);
                mysql_format(db_handle, query, sizeof(query), "INSERT INTO `houses` (`hAddress`,`hType`,`hOwner`, `hPrice`, `hInfoX`,`hInfoY`,`hInfoZ`, `hExitX`, `hExitY`,`hExitZ`) VALUES ('%d', '%d', 'NULL', '%d','%f','%f','%f', '2454.717041','-1700.871582','1013.515197')", address,type, price, px, py, pz);
                mysql_tquery(db_handle, query, "OnHouseCreated", "dddd", playerid, address, type, price);
            }
            if(type == 5){
                GetPlayerPos(playerid, px, py, pz);
                mysql_format(db_handle, query, sizeof(query), "INSERT INTO `houses` (`hAddress`,`hType`,`hOwner`, `hPrice`, `hInfoX`,`hInfoY`,`hInfoZ`, `hExitX`, `hExitY`,`hExitZ`) VALUES ('%d', '%d', 'NULL', '%d','%f','%f','%f', '2350.339843','-1181.649902','1027.976562')", address,type, price, px, py, pz);
                mysql_tquery(db_handle, query, "OnHouseCreated", "dddd", playerid, address, type, price);
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

forward public OnHouseCreated(playerid, address, type, price);
public OnHouseCreated(playerid, address, type, price){
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} House: %d.street (%d) has been created for price: $%d!", address, cache_insert_id(), price);
    SendClientMessage(playerid, SERVERCOLOR, string);{
        LoadNewHouseData(cache_insert_id());
    }
    return 1;
}

CMD:createfac(playerid, params[]) {
    new name[32], type, address, price, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "sddd", name, type, address, price)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createfac [fName] [fType 1/2] [fAddress] [fPrice]");{
            GetPlayerPos(playerid, px, py, pz);
            mysql_format(db_handle, query, sizeof(query), "INSERT INTO `factions` (`fName`, `fType`, `fAddress`,`fPrice`, `fInfoX`, `fInfoY`, `fInfoZ`) VALUES ('%s', '%d', %d', '%d', '%f', '%f', '%f')", name, type, address, price, px, py, pz);

            mysql_tquery(db_handle, query, "OnFacCreated", "dsddd", playerid, name, type, address, price);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }    
    return 1;
}

CMD:setfacentr(playerid, params[]){
    new add, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d",add)) return SendClientMessage(playerid, SERVERCOLOR,  "[SERVER]:{FFFFFF} /setfacentr [fAddress]"); {
            GetPlayerPos(playerid, px, py, pz);

            mysql_format(db_handle, query, sizeof(query),  "UPDATE `factions` SET `fEntX` = '%f',`fEntY` = '%f',`fEntZ` = '%f' WHERE  `fAddress` = %d", px, py, pz, add);
            mysql_query(db_handle, query);

            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have set this faction's entrance point");
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fAddress] == add){
                    fInfo[i][fEntX] = px;
                    fInfo[i][fEntY] = py;
                    fInfo[i][fEntZ] = pz;
                    facEntPickup[fInfo[i][fID] - 1] = CreateDynamicPickup(1559, 1, px, py, pz, -1);
                }
            }
        }
    }
    return 1;
}

CMD:setfacduty(playerid, params[]){
    new add, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d",add)) return SendClientMessage(playerid, SERVERCOLOR,  "[SERVER]:{FFFFFF} /setfacduty [fAddress]"); {
            GetPlayerPos(playerid, px, py, pz);

            mysql_format(db_handle, query, sizeof(query),  "UPDATE `factions` SET `fDutyX` = '%f',`fDutyY` = '%f',`fDutyZ` = '%f' WHERE  `fAddress` = %d", px, py, pz, add);
            mysql_query(db_handle, query);

            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have set this faction's duty point");
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fAddress] == add){
                    fInfo[i][fDutyX] = px;
                    fInfo[i][fDutyY] = py;
                    fInfo[i][fDutyZ] = pz;
                    facDutyPickup[fInfo[i][fID] - 1] = CreateDynamicPickup(1239, 1, px, py, pz, -1);
                }
            }
        }
    }
    return 1;
}

CMD:setfacclothes(playerid, params[]){
    new add, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d",add)) return SendClientMessage(playerid, SERVERCOLOR,  "[SERVER]:{FFFFFF} /setfacclothes [fAddress]"); {
            GetPlayerPos(playerid, px, py, pz);

            mysql_format(db_handle, query, sizeof(query),  "UPDATE `factions` SET `fClothesX` = '%f',`fClothesY` = '%f',`fClothesZ` = '%f' WHERE  `fAddress` = %d", px, py, pz, add);
            mysql_query(db_handle, query);

            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have set this faction's clothes point");
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fAddress] == add){
                    fInfo[i][fClothesX] = px;
                    fInfo[i][fClothesY] = py;
                    fInfo[i][fClothesZ] = pz;
                    facEntPickup[fInfo[i][fID] - 1] = CreateDynamicPickup(1559, 1, px, py, pz, -1);
                }
            }
        }
    }
    return 1;
}


CMD:createbus(playerid, params[]){
    new name[32], type, address, intid, price, Float:infX, Float:infY, Float:infZ, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "sdddd", name, type, address, price, intid)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createbus [bName] [bType] [bAddress] [bPrice] [bIntId (0, 16, 6)]"); {
            GetPlayerPos(playerid, infX, infY, infZ);
            if(intid == 0){ // no mapping, or mapping MUST be set.
                mysql_format(db_handle, query, sizeof(query), "INSERT INTO `businesses` (`bName`,`bType`,`bOwner`, `bAddress`, `bPrice`, `bInfoX`,`bInfoY`,`bInfoZ`, `bIntId`) VALUES ('%s', '%d', 'NULL', '%d', '%d','%f','%f','%f', 0)", name, type,address,price, infX, infY, infZ);
                mysql_tquery(db_handle, query, "OnBusCreated", "dsddd", playerid, name, type, address, price);
            }
            if(intid == 16){ // 24/7
                mysql_format(db_handle, query, sizeof(query), "INSERT INTO `businesses` (`bName`,`bType`,`bOwner`, `bAddress`, `bPrice`, `bInfoX`,`bInfoY`,`bInfoZ`, `bIntId`, `bExitX`, `bExitY`, `bExitZ`) VALUES ('%s', '%d', 'NULL', '%d', '%d','%f','%f','%f', '%d', '-25.132598', '-139.066986', '1003.546875')", name, type,address,price, infX, infY, infZ, intid);
                mysql_tquery(db_handle, query, "OnBusCreated", "dsddd", playerid, name, type, address, price);
            }
            if(intid == 6){ // ammunation OR hardware store!
                if(type == 1){ // is a hardware store
                    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `businesses` (`bName`,`bType`,`bOwner`, `bAddress`, `bPrice`, `bInfoX`,`bInfoY`,`bInfoZ`, `bIntId`, `bExitX`, `bExitY`, `bExitZ`) VALUES ('%s', '%d', 'NULL', '%d', '%d','%f','%f','%f', '%d', '-2240.468505', '137.060440', '1035.414062')", name, type,address,price, infX, infY, infZ, intid);
                    mysql_tquery(db_handle, query, "OnBusCreated", "dsddd", playerid, name, type, address, price);
                }
                if(type == 3){ // is ammunation type.
                    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `businesses` (`bName`,`bType`,`bOwner`, `bAddress`, `bPrice`, `bInfoX`,`bInfoY`,`bInfoZ`, `bIntId`, `bExitX`, `bExitY`, `bExitZ`) VALUES ('%s', '%d', 'NULL', '%d', '%d','%f','%f','%f', '%d', '296.919982', '-108.071998', '1001.515625')", name, type,address,price, infX, infY, infZ, intid);
                    mysql_tquery(db_handle, query, "OnBusCreated", "dsddd", playerid, name, type, address, price);
                }
            }

        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:sethouseentr(playerid, params[]){
    new add, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d", add)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /sethouseentr [address]"); {
            GetPlayerPos(playerid, px,py,pz);

            mysql_format(db_handle, query, sizeof(query), "UPDATE `houses` SET `hEntX` = '%f', `hEntY` = '%f', `hEntZ` = '%f' WHERE `hAddress` = '%d'", px,py,pz, add);
            mysql_query(db_handle, query);

            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have set this house's entrance point!");
            for(new i = 0; i < loadedHouse; i++){
                if(hInfo[i][hAddress] == add){
                    hInfo[i][hEntX] = px;
                    hInfo[i][hEntY] = py;
                    hInfo[i][hEntZ] = pz;
                    houseEntPickup[hInfo[i][hId]-1] = CreateDynamicPickup(1559, 1, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ], -1);
                    return 1;
                }
            }

        }
    }
    return 1;
}

CMD:setbususe(playerid, params[]){
    new add, Float:px, Float:py, Float:pz, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d", add)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /setbususe [bAddress]"); {
            GetPlayerPos(playerid, px,py,pz);
            
            mysql_format(db_handle, query, sizeof(query),  "UPDATE `businesses` SET `bUseX` = '%f',`bUseY` = '%f',`bUseZ` = '%f' WHERE  `bAddress` = %d", px, py, pz, add);
            mysql_query(db_handle, query);

            for(new i = 0; i < loadedBus; i++){
                if(bInfo[i][bAddress] == add){
                    bInfo[i][bUseX] = px;
                    bInfo[i][bUseY] = py;
                    bInfo[i][bUseZ] = pz;
                    busUsePickup[bInfo[i][bId] - 1] = CreateDynamicPickup(1239, 1, px, py, pz, -1);
                }
            }
        }
    }
    return 1;
}

CMD:setbusentr(playerid, params[]){
    new id, Float:infX, Float:infY, Float:infZ, query[900];
    if(pInfo[playerid][pAdminLevel] >= 5){
        if(sscanf(params, "d", id)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /setbusentr [bId]"); {
            GetPlayerPos(playerid, infX, infY, infZ);

            mysql_format(db_handle, query, sizeof(query),  "UPDATE `businesses` SET `bEntX` = '%f',`bEntY` = '%f',`bEntZ` = '%f' WHERE  `bId` = %d", infX, infY, infZ, id);
            mysql_query(db_handle, query);

            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have set this business' entrance point");
            for(new i = 0; i < loadedBus; i++){
                if(bInfo[i][bId] == id){
                    bInfo[i][bEntX] = infX;
                    bInfo[i][bEntY] = infY;
                    bInfo[i][bEntZ] = infZ;
                    busUsePickup[bInfo[i][bId] - 1] = CreateDynamicPickup(1559, 1, infX, infY, infZ, -1);
                }
            }
            return 1;
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

/* COMMANDS */
CMD:stats(playerid, params[]) {
    ReturnStats(playerid, playerid);
    return 1;
}

CMD:dashcam(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 1){
        if(pInfo[playerid][pDuty] == 1){
            if(pInfo[playerid][DashCamStatus] == 0){
                new vidstr[32], vid;
                vid = GetPlayerVehicleID(playerid);
                dashtimer[playerid] = SetTimerEx("BeginDashCam", 250, false, "d", playerid);
                PlayerTextDrawShow(playerid, dash1[playerid]);
                PlayerTextDrawShow(playerid, dash2[playerid]);
                PlayerTextDrawShow(playerid, dashDist[playerid]);
                
                format(vidstr, sizeof(vidstr), "VID: %d", vid);
                PlayerTextDrawSetString(playerid, dashVid[playerid], vidstr);
                PlayerTextDrawShow(playerid, dashVid[playerid]);
                pInfo[playerid][DashCamStatus] = 1;
            }
            else {
                KillTimer(dashtimer[playerid]);
                PlayerTextDrawHide(playerid, dash1[playerid]);
                PlayerTextDrawHide(playerid, dash2[playerid]);
                PlayerTextDrawHide(playerid, dashDist[playerid]);
                PlayerTextDrawHide(playerid, dashVid[playerid]);
                PlayerTextDrawHide(playerid, dashSpeed[playerid]);
                PlayerTextDrawHide(playerid, dashPlate[playerid]);
                return 1;
            }
        }
    }

    return 1;
}

forward public BeginDashCam(playerid);
public BeginDashCam(playerid){
    new Float:x,Float:y,Float:z,Float:a;
    new string[256], plate[32], vidstr[32];
    new vehSpeed[32];
    new vid = GetPlayerVehicleID(playerid);
    GetVehiclePos(vid, x, y, z);
    GetVehicleZAngle(vid,a);
    x += floatsin(-a, degrees) * 15.0;
    y += floatcos(-a, degrees) * 15.0;
    KillTimer(dashtimer[playerid]);
    dashtimer[playerid] = SetTimerEx("BeginDashCam", 250, false, "d", playerid);
    format(plate, sizeof(plate), "P NONE");
    PlayerTextDrawSetString(playerid, dashPlate[playerid], plate);
    format(vehSpeed, sizeof(vehSpeed), "S NONE");
    PlayerTextDrawSetString(playerid, dashSpeed[playerid], vehSpeed);
    PlayerTextDrawShow(playerid, dashPlate[playerid]);
    PlayerTextDrawShow(playerid, dashSpeed[playerid]);
    for(new i = 0; i < loadedVeh; i++){
        if(GetVehicleDistanceFromPoint(vInfo[i][vID], x, y, z) <= 3){
            format(plate, sizeof(plate), "P %s", vInfo[i][vPlate]);
            PlayerTextDrawSetString(playerid, dashPlate[playerid], plate);

            new Float:speed, Float:final_speed;
            GetVehiclePos(vInfo[i][vID], x, y, z);
            GetVehicleVelocity(vInfo[i][vID], x, y, z);
            speed = floatsqroot(((x * x) + (y * y)) + (z * z)) * 100;
            final_speed = floatround(speed, floatround_round);
            
            format(vehSpeed, sizeof(vehSpeed), "S %dMPH", final_speed);
            PlayerTextDrawSetString(playerid, dashSpeed[playerid], vehSpeed);
            PlayerTextDrawShow(playerid, dashPlate[playerid]);
            PlayerTextDrawShow(playerid, dashSpeed[playerid]);
        }
    }
}

CMD:drag(playerid, params[]){
    new target, Float:px, Float:py, Float:pz, Float:tx, Float:ty, Float:tz;
    if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /drag [targetid]");{
        GetPlayerPos(target, tx, ty, tz);
        GetPlayerPos(playerid, px, py, pz);
        if(IsPlayerInRangeOfPoint(playerid, 1.5, tx, ty, tz)){
            if(IsPlayerCuffed(target)){
                if(pInfo[playerid][pDragged] == 0){
                    SetPlayerPos(target, px, py, pz);
                    SendClientMessage(playerid, ADMINBLUE, "> You are dragging a player!");
                    TogglePlayerControllable(target, false);
                    pInfo[playerid][pDragged] = 1;
                    dragState[target] = SetTimerEx("DragPlayer", 1000, false, "dd", playerid, target);
                } else {
                    pInfo[playerid][pDragged] = 0;
                    SendClientMessage(playerid, ADMINBLUE, "> You have stopped dragging this player!");
                    TogglePlayerControllable(target, true);
                    KillTimer(dragState[target]);
                }
            }
        }
    }
    return 1;
}

forward public DragPlayer(playerid, target);
public DragPlayer(playerid, target){
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    SetPlayerPos(target, px, py, pz);
    dragState[target] = SetTimerEx("DragPlayer", 1000, false, "dd", playerid, target);
    return 1;
}

CMD:flash(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 1 || pInfo[playerid][pFactionId] == 2){
      
        
        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525){
            if(vInfo[GetPlayerVehicleID(playerid)][SirenStatus] == 0){
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 1;
                myobject[GetPlayerVehicleID(playerid)] = CreateObject(19419,0,0,1000,0,0,0,100);
                AttachObjectToVehicle(myobject[GetPlayerVehicleID(playerid)], GetPlayerVehicleID(playerid), 0.000000,-0.449999,1.465000,0.000000,0.000000,0.000000);
                return 1;
            } else {
                DestroyObject(myobject[GetPlayerVehicleID(playerid)]);
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 0;
                return 1;
            }
        }
        
        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 599){
            // rancher
            if(vInfo[GetPlayerVehicleID(playerid)][SirenStatus] == 0){
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 1;
                rancherSiren[GetPlayerVehicleID(playerid)] = CreateObject(18646,0,0,-1000,0,0,0,100);
                AttachObjectToVehicle(rancherSiren[GetPlayerVehicleID(playerid)], GetPlayerVehicleID(playerid), 0.000000,0.000000,1.125000,0.000000,0.000000,0.000000);
            } else {
                DestroyObject(rancherSiren[GetPlayerVehicleID(playerid)]);
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 0;
            }

        }

        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 598){
            //cop car
            if(vInfo[GetPlayerVehicleID(playerid)][SirenStatus] == 0){
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 1;
                copCarSiren[GetPlayerVehicleID(playerid)] = CreateObject(18646,0,0,-1000,0,0,0,100);
                AttachObjectToVehicle(copCarSiren[GetPlayerVehicleID(playerid)], GetPlayerVehicleID(playerid), 0.000000,-0.300000,0.899999,0.000000,0.000000,0.000000);
            } else {
                DestroyObject(copCarSiren[GetPlayerVehicleID(playerid)]);
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 0;
            }
        }

        if(PLights[GetPlayerVehicleID(playerid)] == 0)
        {
            BlinkingLights(playerid);
            PLights[GetPlayerVehicleID(playerid)] = 1;
		}
		else if(PLights[GetPlayerVehicleID(playerid)] == 1)
            {
            ShutOffBlinkingLights(playerid);
            PLights[GetPlayerVehicleID(playerid)] = 0;
		}
        return 1;
    }
    if(pInfo[playerid][pFactionId] == 3){
        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525){
            if(vInfo[GetPlayerVehicleID(playerid)][SirenStatus] == 0){
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 1;
                myobject[GetPlayerVehicleID(playerid)] = CreateObject(19803,0,0,-1000,0,0,0,100);
                AttachObjectToVehicle(myobject[GetPlayerVehicleID(playerid)], GetPlayerVehicleID(playerid), 0.000000,0.000000,0.000000,0.000000,0.000000,0.000000);
            } else {
                DestroyObject(myobject[GetPlayerVehicleID(playerid)]);
                vInfo[GetPlayerVehicleID(playerid)][SirenStatus] = 0;
            }
        }
    }
    return 1;
}
public BlinkingLights(playerid)
{
	if ( IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleSeat(playerid) == 0 )
	{
		new Panels, Doors1, Lights, Tires;
		GetVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors1, Lights, Tires);
		UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors1, encode_lights(0,0,1,1), Tires);
        TLI = SetTimerEx("TimerBlinkingLights", 100, false, "d", GetPlayerVehicleID(playerid));
	}
}
public ShutOffBlinkingLights(playerid)
{
	if ( IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleSeat(playerid) == 0 )
	{
	   KillTimer(TLI);
	   KillTimer(TLI2);
	   new Panels, Doors1, Lights, Tires;
	   GetVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors1, Lights, Tires);
	   UpdateVehicleDamageStatus(GetPlayerVehicleID(playerid), Panels, Doors1, encode_lights(0,0,0,0), Tires);
	}
}
public encode_lights(light1, light2, light3, light4)
{
	return light1 | (light2 << 1) | (light3 << 2) | (light4 << 3);
}
public TimerBlinkingLights(vehicleid)
{
		new Panels, Doors1, Lights, Tires;
		GetVehicleDamageStatus(vehicleid, Panels, Doors1, Lights, Tires);
		UpdateVehicleDamageStatus(vehicleid, Panels, Doors1, encode_lights(1,1,0,0), Tires);
		TLI2 = SetTimerEx("TimerBlinkingLights3", 150, false, "d", vehicleid);
}
public TimerBlinkingLights2(vehicleid)
{
		new Panels, Doors1, Lights, Tires;
		GetVehicleDamageStatus(vehicleid, Panels, Doors1, Lights, Tires);
		UpdateVehicleDamageStatus(vehicleid, Panels, Doors1, encode_lights(0,0,1,1), Tires);
		TLI = SetTimerEx("TimerBlinkingLights", 150, false, "d", vehicleid);
}
forward TimerBlinkingLights3(vehicleid);
public TimerBlinkingLights3(vehicleid)
{
		new Panels, Doors1, Lights, Tires;
		GetVehicleDamageStatus(vehicleid, Panels, Doors1, Lights, Tires);
		UpdateVehicleDamageStatus(vehicleid, Panels, Doors1, encode_lights(1,1,1,1), Tires);
		TLI = SetTimerEx("TimerBlinkingLights2", 100, false, "d", vehicleid);
}

CMD:getcar(playerid, params[]){
    new plate[32], name[32];
    GetPlayerName(playerid, name, 32);
    if(sscanf(params, "s[32]", plate)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /getcar [PLATE]"); {
        for(new i = 0; i < loadedVeh; i++){
            if(!strcmp(vInfo[i][vPlate], plate, true)){
                if(vInfo[i][vImpounded] == 1){
                    if(!strcmp(vInfo[i][vOwner], name, true)){
                        if(GetPlayerMoney(playerid) >= vInfo[i][vFines] && pInfo[playerid][pCash] >= vInfo[i][vFines]){
                            SetVehiclePos(vInfo[i][vID], -185.0058, 1021.9856, 19.6558);
                            SetVehicleZAngle(vInfo[i][vID], 0);
                            vInfo[i][vImpounded] = 0;
                            vInfo[i][vFines] = 0;
                            vInfo[i][vParkedX] = -185.0058;
                            vInfo[i][vParkedY] = 1021.9856;
                            vInfo[i][vParkedZ] = 19.6558;
                            new DB_Query[900];
                            mysql_format(db_handle, DB_Query, sizeof(DB_Query), "UPDATE `vehicles` SET `vImpounded` = '0', `vFines` = '0', `vParkedX` = '%f', `vParkedY` = '%f', `vParkedZ` = '%f' WHERE `vPlate` = '%s'", -185.0058, 1021.9856, 19.6558, plate);
                            mysql_query(db_handle, DB_Query);
                            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have bought your car back from the impound!");
                            return 1;
                        }
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not own that vehicle!");
                        return 1;
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} That vehicle is not impounded!");
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:impound(playerid, params[]){
    new plate[32];
    if(pInfo[playerid][pFactionId] == 1){
        if(pInfo[playerid][pDuty] == 1){
            if(sscanf(params, "s[32]", plate)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /impound [PLATE]"); {
                for(new i = 0; i < loadedVeh; i++){
                    if(!strcmp(vInfo[i][vPlate], plate,  true)){
                        new Float:vehdist = GetVehicleDistanceFromPoint(vInfo[i][vID], -166.0709, 1018.1705, 18.7314);
                        printf("vid; %d %s, distance from point: %f", vInfo[i][vID], vInfo[i][vPlate], vehdist);
                        if(GetVehicleDistanceFromPoint(vInfo[i][vID], -166.0709, 1018.1705, 18.7314) <= 7){ // check to see if that veh is near that point..
                            if(vInfo[i][vFines] > 0){
                                new Float:x, Float:y, Float:z, DB_Query[900], string[256];
                                GetVehiclePos(vInfo[i][vID], x, y, z);
                                vInfo[i][vImpounded] = 1;
                                vInfo[i][vParkedX] = x;
                                vInfo[i][vParkedY] = y;
                                vInfo[i][vParkedZ] = z;
                                mysql_format(db_handle, DB_Query, sizeof(DB_Query), "UPDATE `vehicles` SET `vImpounded` = '%d', `vParkedX` = '%f', `vParkedY` = '%f', `vParkedZ` = '%f' WHERE `vPlate` = '%e'", 1, x, y, z, plate);
                                mysql_query(db_handle, DB_Query);
                                format(string, sizeof(string), "> Vehicle: %s has been impounded!", vInfo[i][vPlate]);
                                pInfo[playerid][pFactionPay] += 100; // give them 100 towards fac pay
                                SendClientMessage(playerid, ADMINBLUE, string);
                                //send client message saying it has worked
                                // detatch towed vehicle
                                DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
                                return 1;
                            } else {
                                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle does not have any fines!");
                                return 1;
                            }
                        } else {
                            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle is not near the impound point!");
                            return 1;
                        }
                    }
                }
            }
        } else {
            TextDrawShowForPlayer(playerid, NotOnDuty);
            SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:gate(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 1){
        if(IsPlayerInRangeOfPoint(playerid, 15, -180.2639, 1010.1957, 18.9288)){
            MoveDynamicObject(impoundGate, -180.2639, 1016.7477, 18.9288, 8000);
            SetTimerEx("MoveObjBack", 5000, false, "d", 7);
        }
    }
    return 1;
}

CMD:ticket(playerid, params[]){
    new target, plate[32], amount, reason[32], Float:x, Float:y, Float:z; // Ticket works on target player id, or plate id.
    if(pInfo[playerid][pFactionId] == 1){
        if(pInfo[playerid][pDuty] == 1){
            if(sscanf(params, "s[32]ds[32]", plate, amount, reason)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /ticket [plate/playerid] [amount] [reason]");{
                for(new i = 0; i < loadedVeh; i++){
                    if(!strcmp(vInfo[i][vPlate], plate, true)){
                        GetVehiclePos(vInfo[i][vID], x, y, z);
                        if(IsPlayerInRangeOfPoint(playerid, 3, x, y, z)){
                            vInfo[i][vFines] += amount;
                            format(vInfo[i][vMostRecentFine], 32, reason);
                            new string[256], DB_Query[900];
                            format(string, sizeof(string), "> You have written a ticket for: %s - ticket price: $%d - reason: %s", plate, amount, reason);
                            SendClientMessage(playerid, ADMINBLUE, string);
                            mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `vehicles` SET `vFines` = '%d', `vMostRecentFine` = '%s' WHERE `vPlate` = '%e'",vInfo[i][vFines], vInfo[i][vMostRecentFine], plate);
                            mysql_query(db_handle, DB_Query);
                        }
                    }
                }
            } 
            if(!sscanf(params, "dds[32]", target, amount, reason)) {
                if(IsPlayerConnected(target)){
                    GetPlayerPos(target, x, y, z);
                    if(IsPlayerInRangeOfPoint(playerid, 3, x, y, z)){
                        pInfo[target][pFines] += amount;
                        format(pInfo[target][pMostRecentFine], 32, reason);
                        new string[256];
                        format(string, sizeof(string), "> You have written a ticket for: %s - ticket price: $%d - reason: %s", RPName(target), amount, reason);
                        SendClientMessage(playerid, ADMINBLUE, string);
                        format(string, sizeof(string), "> You been given a ticket from %s - ticket price: $%d - reason: %s", RPName(playerid), amount, reason);
                        SendClientMessage(target, ADMINBLUE, string);
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Target is not connected.");
                    return 1;
                }
            }
        } else {
            TextDrawShowForPlayer(playerid, NotOnDuty);
            SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
        }
        return 1;
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:arrest(playerid, params[]){
    new target, length;
    if(pInfo[playerid][pFactionId] == 1){
        if(sscanf(params, "dd", target, length)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /arrest [id] [length]"); {
            if(pInfo[playerid][pDuty] == 1){
                // check if wanted level is 1 or greater than 1 if not player has not been charged, /ca
                //arrest player
                if(IsPlayerInRangeOfPoint(playerid, 3, -2653.4983, 2641.7468, 4080.4587)){
                    if(GetPlayerWantedLevel(target) >= 1){
                        pInfo[target][pInPrisonType] = 1;
                        pInfo[target][pPrisonTimer] = length;
                        SetPlayerPos(playerid, -2664.4351, 2637.7744, 4080.4587);
                        SetPlayerWantedLevel(target, 0);
                        SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", target, pInfo[target][pInPrisonType]);
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Player has not been charged!");
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not in range of the /arrest point!");
                }
            } else {
                TextDrawShowForPlayer(playerid, NotOnDuty);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

Dialog:DIALOG_ADVERTS(playerid, response, listitem, inputtext[]){
    if(response){
        new list[256], string[256];
        for (new i = 0; i < MAX_PLAYERS; i++) {
            if(listitem == i) {
                format(list, sizeof(list), "{FFCC00}*-----LOADED ADVERTISEMENT-----*{A9C4E4}\n\nContact Phone: %d\nAd Message: %s\n\nPlease either accept, or decline this advert!", pInfo[i][pPhoneNumber], pInfo[i][SentAdv]);
                pInfo[playerid][SelectedAd] = i;
            }
        }
        
        Dialog_Show(playerid, DIALOG_ADVERTCHOICE, DIALOG_STYLE_MSGBOX, "Advert", list, "Accept", "Decline");
    }
    return 1;
}

Dialog:DIALOG_ADVERTCHOICE(playerid, response, listitem, inputtext[]){
    new string[256];
    if(response){
        pInfo[pInfo[playerid][SelectedAd]][SentAdv] = 0;
        pInfo[pInfo[playerid][SelectedAd]][pBank] -= 100;
        pInfo[playerid][pFactionPay] += 100;
        SendClientMessage(pInfo[playerid][SelectedAd], ADMINBLUE, "> Your advert has been accepted!");
        format(string, sizeof(string), "> You have accepted advert: %d! (+$100)", pInfo[playerid][SelectedAd]);
        SendClientMessage(playerid, ADMINBLUE, string);
        format(string, sizeof(string), "{00bfff}[SANN Radio Advert]: %s, Contact Phone: %d.", pInfo[pInfo[playerid][SelectedAd]][AdvMsg], pInfo[pInfo[playerid][SelectedAd]][pPhoneNumber]);
        SendClientMessageToAll(-1, string);
    } else {
        pInfo[pInfo[playerid][SelectedAd]][SentAdv] = 0;
        SendClientMessage(pInfo[playerid][SelectedAd], ADMINBLUE, "> Your advert has been declined!");
        format(string, sizeof(string), "> You have declined advert: %d!", pInfo[playerid][SelectedAd]);
        SendClientMessage(playerid, ADMINBLUE, string);
    }
    return 1;
}

CMD:listallads(playerid, params[]){
    new list[1000], string[200], available;
    if(pInfo[playerid][pFactionId] == 4){
        for(new i = 0; i < MAX_PLAYERS; i++){
            if(pInfo[i][SentAdv] == 1){
                available++;
                format(string, sizeof(string), "Advert ID: %d\n", i);
                strcat(list, string);
            }
        }
        if(available >= 1){
            Dialog_Show(playerid, DIALOG_ADVERTS, DIALOG_STYLE_LIST, "Available Adverts", list, "Accept", "");
        } else {
            Dialog_Show(playerid, DIALOG_NOADV, DIALOG_STYLE_MSGBOX, "Available Adverts", "{FFCC00}*-----LOADED ADVERTISEMENT-----*{A9C4E4}\n\nThere are currently no available adverts.", "Accept", "");
        }
    }
    return 1;
}

CMD:acceptad(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 4){
        new targetid, string[256];
        if(sscanf(params, "d", targetid)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /acceptad [ID]");{
            if(IsPlayerConnected(targetid)){
                if(pInfo[targetid][SentAdv] == 1){
                    pInfo[targetid][SentAdv] = 0;
                    pInfo[targetid][pBank] -= 100;
                    pInfo[playerid][pFactionPay] += 100;
                    SendClientMessage(targetid, ADMINBLUE, "> Your advert has been accepted!");
                    format(string, sizeof(string), "> You have accepted advert: %d! (+$100)", targetid);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    format(string, sizeof(string), "{00bfff}[SANN Radio Advert]: %s, Contact Phone: %d.", pInfo[targetid][AdvMsg], pInfo[targetid][pPhoneNumber]);
                    SendClientMessageToAll(-1, string);
                    return 1;
                }
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:declinead(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 4){
        new targetid, string[256];
        if(sscanf(params, "d", targetid)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /declinead [ID]");{
            if(IsPlayerConnected(targetid)){
                if(pInfo[targetid][SentAdv] == 1){
                    pInfo[targetid][SentAdv] = 0;
                    SendClientMessage(targetid, ADMINBLUE, "> Your advert has been declined!");
                    format(string, sizeof(string), "> You have declined advert: %d!", targetid);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    return 1;
                }
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:sms(playerid, params[]){
    new number, msg[100], string[256];
    if(pInfo[playerid][pPhoneNumber] != 0 && pInfo[playerid][pPhoneModel] != 0){
        if(sscanf(params, "ds[100]", number, msg)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /sms [NUMBER] [MESSAGE]");{
            if(number == 3170){
                if(strlen(msg) >= 5 || strlen(msg) <= 75){             
                    pInfo[playerid][SentAdv] = 1;
                    format(pInfo[playerid][AdvMsg], 100, "%s", msg);
                    SendClientMessage(playerid, ADMINBLUE, "> You have sent an advert to be reviewed!");
                    for(new i = 0; i < MAX_PLAYERS; i++){
                        if(pInfo[i][pFactionId] == 4){
                            format(string, sizeof(string), "> Ad received: %s, /acceptad %d to accept this advert!", pInfo[playerid][AdvMsg], playerid);
                            SendClientMessageA(playerid, ADMINBLUE, string);
                        }
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Your advert must be between 5 and 75 characters long!");
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:call(playerid, params[]){
    new number;
    if(pInfo[playerid][pPhoneNumber] != 0 && pInfo[playerid][pPhoneModel] != 0){
        // has phone...
        if(sscanf(params, "d", number)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /call [NUMBER]"); {
            if(number == 911){
                new string[256];
                format(string, sizeof(string), "* %s takes out their phone and dials a number.", RPName(playerid));
                nearByAction(playerid, NICESKY, string);
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                BeginCalling(playerid, 911);
            }
            if(number == 227){
                new string[256];
                format(string, sizeof(string), "* %s takes out their phone and dials a number.", RPName(playerid));
                nearByAction(playerid, NICESKY, string);
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                BeginCalling(playerid, 227);
            }
            if(number == 3170) {
                new string[256];
                format(string, sizeof(string), "* %s takes out their phone and dials a number.", RPName(playerid));
                nearByAction(playerid, NICESKY, string);
                SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                BeginCalling(playerid, 3170);
            }
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pPhoneNumber] == number){
                    if(IsPlayerConnected(i)){
                        new string[256];
                        format(string, sizeof(string), "* %s takes out their phone and dials a number.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        pInfo[i][BeingCalled] = pInfo[playerid][pPhoneNumber];
                        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
                        BeginCalling(playerid, i);
                        PlayerPlaySound(playerid, 3600,0,0,0);
                        return 1;
                    }
                }
            }
        }
    } else {
        // no phone...
    }
    return 1;
}

forward BeginCalling(playerid, targetid);
public BeginCalling(playerid, targetid){
    if(targetid == 911){
        new string[256];
        format(string, sizeof(string), "{FFFFD5}Phone connecting sound...");
        SendClientMessage(playerid, -1, string);
        pInfo[playerid][OnCall] = 911;
        format(string, sizeof(string), "{FFFFD5}[PHONE]: This is the emergency services, what do you require?");
        SendClientMessage(playerid, -1, string);
        format(string, sizeof(string), "{FFFFD5}[PHONE]: Police, Medics or Firefighters?");
        SendClientMessage(playerid, -1, string);
        return 1;
    } 
    if(targetid == 227){
        new string[256];
        format(string, sizeof(string), "{FFFFD5}Phone connecting sound...");
        SendClientMessage(playerid, -1, string);
        pInfo[playerid][OnCall] = 227;
        format(string, sizeof(string), "{FFFFD5}[PHONE]: This is the Towing Company, how can we help?");
        SendClientMessage(playerid, -1, string);
        return 1;
    }
    if(targetid == 3170){
        new string[256], onlive;
        for(new i = 0; i < loadedFac; i++){
            if(fInfo[i][IsLive] == 1){
                onlive++;
            }
        }
        for(new io = 0; io < loadedVeh; io++){
            if(vInfo[io][IsLive] == 1){
                onlive++;
            }
        }
        if(onlive >= 1){            
            format(string, sizeof(string), "{FFFFD5}Phone connecting sound...");
            SendClientMessage(playerid, -1, string);
            format(string, sizeof(string), "PHONE: Line %d is calling... /takecall to answer!", playerid);
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pFactionId] == 4){     
                    SendClientMessage(i, ADMINBLUE, string);
                }
            }
            pInfo[playerid][pAlertCall] = 4;
            callTimer[playerid] = SetTimerEx("BeginCalling", 3000, false, "dd", playerid, targetid);
        } else {
            format(string, sizeof(string), "{FFFFD5}Phone connecting sound...");
            SendClientMessage(playerid, -1, string);
            format(string, sizeof(string), "{FFFFD5}[PHONE]: This is the San Andreas News Network, you cannot call in right now. Try again later.");
            SendClientMessage(playerid, -1, string);
            
            format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
            nearByAction(playerid, NICESKY, string);
                    
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        }
        return 1;
    }
    else {
        if(pInfo[playerid][OnCall] == 0){
            new string[256];
            format(string, sizeof(string), "PHONE: %d is calling... /accept to answer!", pInfo[playerid][pPhoneNumber]);
            SendClientMessage(targetid, ADMINBLUE, string);
            format(string, sizeof(string), "Phone ringing...  (( %s ))", RPName(targetid));
            nearByAction(targetid, NICESKY, string);
            
            format(string, sizeof(string), "{FFFFD5}Phone connecting sound...");
            SendClientMessage(playerid, -1, string);
            callTimer[playerid] = SetTimerEx("BeginCalling", 3000, false, "dd", playerid, targetid);
            new Float:x, Float:y, Float:z;
            GetPlayerPos(targetid, x, y, z);
            PlayerPlaySound(targetid, 23000, x, y, z);
        }
    }
    return 1;
}

CMD:accept(playerid, params[]){
    new string[256];
    if(pInfo[playerid][BeingCalled] >= 1){
        new pid;
        pid = PlayerIdByPhoneNumber(pInfo[playerid][BeingCalled]);
        if(pInfo[playerid][BeingCalled] == pInfo[pid][pPhoneNumber]){
            SetPlayerSpecialAction(pid, SPECIAL_ACTION_USECELLPHONE);    
            format(string, sizeof(string), "* %s takes out their phone and answers the call.", RPName(playerid));
            nearByAction(playerid, NICESKY, string);
            format(string, sizeof(string), "{FFFFD5} Call connected.");
            SendClientMessage(playerid, -1, string);
            SendClientMessage(pid, -1, string);
            pInfo[playerid][OnCall] = pInfo[pid][pPhoneNumber];
            pInfo[pid][OnCall] = pInfo[playerid][pPhoneNumber];
            pInfo[playerid][BeingCalled] = 0;
            pInfo[pid][BeingCalled] = 0;
            KillTimer(callTimer[playerid]);
            KillTimer(callTimer[pid]);
        }
        
    } else {
        if(pInfo[playerid][AwaitingHAccept] == 1){
            SetPlayerHealth(playerid, 100);
            format(string, sizeof(string),  "> You have accepted: %s' heal request!", RPName(pInfo[playerid][SentHAccept]));
            SendClientMessage(playerid, ADMINBLUE, string);
            pInfo[playerid][AwaitingHAccept] =0;
            format(string, sizeof(string), "> %s has accepted your heal request! (+$50)", RPName(playerid));
            pInfo[pInfo[playerid][SentHAccept]][pFactionPay] += 50;
            SendClientMessage(pInfo[playerid][SentHAccept], ADMINBLUE, string);
            return 1;
        }
        if(pInfo[playerid][AwaitingRAccept] == 1){
            if(IsPlayerInAnyVehicle(playerid)){
                SetVehicleHealth(GetPlayerVehicleID(playerid), 1000);
                format(string, sizeof(string),  "> You have accepted: %s' repair request!", RPName(pInfo[playerid][SentRAccept]));
                SendClientMessage(playerid, ADMINBLUE, string);
                pInfo[playerid][AwaitingRAccept] = 0;
                format(string, sizeof(string), "> %s has accepted your repair request! (+$%d)", RPName(playerid), pInfo[playerid][SentRPrice]);
                pInfo[pInfo[playerid][SentRAccept]][pFactionPay] += pInfo[playerid][SentRPrice];
                GivePlayerMoney(playerid, -pInfo[playerid][SentRPrice]);
                pInfo[playerid][pCash] -= pInfo[playerid][SentRPrice];
                SendClientMessage(pInfo[playerid][SentRAccept], ADMINBLUE, string);
                return 1;
            }
        }
    }
    return 1;
}

CMD:decline(playerid, params[]){
    new string[256];
    if(pInfo[playerid][AwaitingHAccept] == 1){
        format(string, sizeof(string), "> You have declined: %s' heal request!", RPName(pInfo[playerid][SentHAccept]));
        SendClientMessage(playerid, ADMINBLUE, string);
        pInfo[playerid][AwaitingHAccept] = 0;
        format(string, sizeof(string), "> %s has declined your heal request!", RPName(playerid));
        SendClientMessage(pInfo[playerid][SentHAccept], ADMINBLUE, string);
    }
    if(pInfo[playerid][AwaitingRAccept] == 1){
        format(string, sizeof(string), "> You have declined: %s' repair request!", RPName(pInfo[playerid][SentHAccept]));
        SendClientMessage(playerid, ADMINBLUE, string);
        pInfo[playerid][AwaitingRAccept] = 0;
        format(string, sizeof(string), "> %s has declined your repair request!", RPName(playerid));
        SendClientMessage(pInfo[playerid][SentRAccept], ADMINBLUE, string);
    }
    return 1;
}

stock PlayerIdByPhoneNumber(number){
    new pid;
    for(new i = 0; i < MAX_PLAYERS; i++){
        if(pInfo[i][pPhoneNumber] == number){
            pid = i;
            return pid;
        }
    }
}

CMD:hangup(playerid, params[]){
    new string[256];
    if(pInfo[playerid][OnCall] >= 1){
        if(pInfo[playerid][OnCall] == 3170){
            format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
            nearByAction(playerid, NICESKY, string);
            pInfo[playerid][OnCall] = 0;        
            SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pFactionId] == 4){
                    format(string, sizeof(string), "> Line %d has disconnected their call.", playerid);
                    SendClientMessage(i, ADMINBLUE, string);
                }
            }
        }
        for(new i = 0; i < MAX_PLAYERS; i++){
            if(IsPlayerConnected(i))
            {
                if(pInfo[i][OnCall] == pInfo[playerid][pPhoneNumber]){
                    format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(i));
                    nearByAction(i, NICESKY, string);
                    format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(playerid));
                    nearByAction(playerid, NICESKY, string);
                    pInfo[i][OnCall] = 0;
                    pInfo[playerid][OnCall] = 0;
                    
                    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
                    SetPlayerSpecialAction(i, SPECIAL_ACTION_NONE);
                }
            }
        }
    }
    return 1;
}

CMD:ca(playerid, params[]){
    new target, reason[32], string[256];
    if(pInfo[playerid][pFactionId] == 1){
        if(sscanf(params, "ds", target, reason)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /ca [target] [reason]");{
            if(pInfo[playerid][pDuty] == 1){
                if(pInfo[target][pWantedLevel] < 6){
                    pInfo[target][pWantedLevel]++;
                    format(pInfo[playerid][pMostRecentWantedReason], 32, reason);
                    SetPlayerWantedLevel(playerid, pInfo[target][pWantedLevel]);
                    for(new i = 0; i < MAX_PLAYERS; i++){
                        if(pInfo[i][pFactionId] == 1){
                            format(string, sizeof(string), "Radio: %s has been commited with charge: %s, over", RPName(target), reason);
                            SendClientMessage(i, -1, string);
                        }
                    }
                } else {
                    format(pInfo[playerid][pMostRecentWantedReason], 32, reason);
                    for(new i = 0; i < MAX_PLAYERS; i++){
                        if(pInfo[i][pFactionId] == 1){
                            format(string, sizeof(string), "Radio: %s has been commited with charge: %s, over", RPName(target), reason);
                            SendClientMessage(i, -1, string);
                        }
                    }
                }
            } else {
                TextDrawShowForPlayer(playerid, NotOnDuty);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
            }
            
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:heal(playerid, params[]){
    new target, string[256];
    if(pInfo[playerid][pFactionId] == 2){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /heal [id]"); {
            if(IsPlayerConnected(target)){
                new Float:x, Float:y, Float:z;
                GetPlayerPos(target, x, y, z);
                if(IsPlayerInRangeOfPoint(playerid, 1.5, x, y, z)){
                    SetPlayerHealth(target, 100);
                    format(string, sizeof(string), "> You have requested to heal: %s!", RPName(target));
                    SendClientMessage(playerid, ADMINBLUE, string);
                    
                    format(string, sizeof(string), "> You can now /accept (or /decline) this heal request from: %s!", RPName(playerid));
                    SendClientMessage(target, ADMINBLUE, string);
                    pInfo[target][AwaitingHAccept] = 1;
                    pInfo[target][SentHAccept] = playerid;
                    return 1;
                }
            }
        }
    }
    return 1;
}



CMD:cuff(playerid, params[]){
    new target, string[256];
    if(pInfo[playerid][pFactionId] == 1){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /cuff [id]");{
            if(pInfo[playerid][pDuty] == 1){               
                if(IsPlayerCuffed(target)){
                    SetPlayerCuffed(target, false);
                    format(string, sizeof(string), "* %s takes cuffs from their holster and cuffs %s.", RPName(playerid), RPName(target));
                    nearByAction(playerid, NICESKY, string);
                }
                else if(!IsPlayerCuffed(target)){
                    SetPlayerCuffed(target, true);
                    format(string, sizeof(string), "* %s uncuffs %s and places the cuffs back on their holster.", RPName(playerid), RPName(target));
                    nearByAction(playerid, NICESKY, string);
                }
            } else {
                TextDrawShowForPlayer(playerid, NotOnDuty);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:endcall(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionId] == 1 || pInfo[playerid][pFactionId] == 2 || pInfo[playerid][pFactionId] == 3){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /endcall [callcode]"); {
            if(IsPlayerConnected(target)){
                if(pInfo[target][pAlertCall] == 1 || pInfo[target][pAlertCall] == 2 || pInfo[target][pAlertCall] == 3){
                    pInfo[target][pAlertCall] = 0;
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have ended this call code.");
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Invalid call code!");
                    return 1;
                }
            }
        }
    } else if(pInfo[playerid][pFactionId] == 4){
        new string[256];
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /endcall [line]"); {
            if(pInfo[target][OnCall] == 3170) {                
                format(string, sizeof(string), "* %s ends the call and puts their phone away.", RPName(target));
                nearByAction(target, NICESKY, string);
                format(string, sizeof(string), "> You have ended the call on line: %d", target);
                SendClientMessage(playerid, ADMINBLUE, string);
                pInfo[target][OnCall] = 0;                    
                SetPlayerSpecialAction(target, SPECIAL_ACTION_NONE);
            } else {
                format(string, sizeof(string), "[SERVER]: {FFFFFF} Invalid line number!", target);
                SendClientMessage(playerid, SERVERCOLOR, string);
            }
        }
    } 
    else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:takecall(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionId] == 1 || pInfo[playerid][pFactionId] == 2 || pInfo[playerid][pFactionId] == 3 || pInfo[playerid][pFactionId] == 4){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /takecall [callcode]"); {
            if(pInfo[playerid][pDuty] == 1){
                if(target >= MAX_PLAYERS){
                    if(pInfo[playerid][pFactionId] == 2){
                        new addressOnFire, string[256], Float:fx, Float:fy, Float:fz;
                        addressOnFire = 0;
                        for(new i = 0; i < loadedFac; i++){
                            if(fInfo[i][fAddress] == target){
                                if(fInfo[i][OnFire] == 1){
                                    addressOnFire = target;
                                    fx = fInfo[i][fInfoX];
                                    fy = fInfo[i][fInfoY];
                                    fz = fInfo[i][fInfoZ];
                                }
                            }
                        }
                        for(new i = 0; i < loadedBus; i++){
                            if(bInfo[i][bAddress] == target){
                                if(bInfo[i][OnFire] == 1){
                                    addressOnFire = target;
                                    fx = bInfo[i][bInfoX];
                                    fy = bInfo[i][bInfoY];
                                    fz = bInfo[i][bInfoZ];
                                }
                            }
                        }
                        for(new i = 0; i < loadedHouse; i++){
                            if(hInfo[i][hAddress] == target){
                                if(hInfo[i][OnFire] == 1){
                                    addressOnFire = target;
                                    fx = hInfo[i][hInfoX];
                                    fy = hInfo[i][hInfoY];
                                    fz = hInfo[i][hInfoZ];
                                }
                            }
                        }
                        if(addressOnFire != 0){
                            policeCall[playerid] = CreateDynamicCP(fx, fy, fz, 2, -1, -1, -1, 10000);

                            for(new i = 0; i < MAX_PLAYERS; i++){
                                if(pInfo[i][pFactionId] == 2){
                                    format(string, sizeof(string), "{FFFFFF}Radio: %s %s has taken call code: %d!",pInfo[playerid][pFactionRankname],  RPName(playerid), target);
                                    SendClientMessage(i, SERVERCOLOR, string);
                                }
                            }
                        }
                    }
                } else {
                    if(pInfo[target][pAlertCall] == 1 || pInfo[target][pAlertCall] == 2){                        
                        new Float:tX, Float:tY, Float:tZ;
                        GetPlayerPos(target, tX, tY, tZ);
                        policeCall[playerid] = CreateDynamicCP(tX, tY, tZ, 2, -1, -1, -1, 10000);
                        for(new i = 0; i < MAX_PLAYERS; i++){
                            if(pInfo[i][pFactionId] == 1 || pInfo[i][pFactionId] == 2){
                                new string[256];
                                format(string, sizeof(string), "{FFFFFF}Radio: %s %s has taken call code: %d!",pInfo[playerid][pFactionRankname],  RPName(playerid), target);
                                SendClientMessage(i, SERVERCOLOR, string);
                                pInfo[target][pAlertCall] = 0;
                            }
                        }
                    } else if(pInfo[target][pAlertCall] == 3){
                        new Float:tX, Float:tY, Float:tZ;
                        GetPlayerPos(target, tX, tY, tZ);
                        towingCall[playerid] = CreateDynamicCP(tX, tY, tZ, 2, -1, -1, -1, 10000);
                        for(new i = 0; i < MAX_PLAYERS; i++){
                            if(pInfo[i][pFactionId] == 3){
                                new string[256];
                                format(string, sizeof(string), "{FFFFFF}Radio: %s %s has taken call code: %d!",pInfo[playerid][pFactionRankname],  RPName(playerid), target);
                                SendClientMessage(i, SERVERCOLOR, string);
                                pInfo[target][pAlertCall] = 0;
                            }
                        }
                    } else if(pInfo[target][pAlertCall] == 4) {
                        new string[256];
                        pInfo[target][OnCall] = 3170;
                        pInfo[target][pAlertCall] = 0;
                        SendClientMessage(target, -1, "Call connected.");
                        format(string, sizeof(string), "> You have accepted line: %d.", target);
                        SendClientMessage(playerid, ADMINBLUE, string);                    
                        KillTimer(callTimer[target]);
                        return 1;
                    } 
                    else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This is not a valid call code!");
                        return 1;
                    }
                }
            } else {
                TextDrawShowForPlayer(playerid, NotOnDuty);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:live(playerid, params[]){
    // /live: if in hq or news van, and live toggled, broadcast all MSGs to ALL players
    // players can call in, and if there is a van that is live, send them a /accept [number] request.
    // check to see if that player is calling 3170, if they are, accept/decline.
    if(pInfo[playerid][pFactionId] == 4){
        //if in range of point
        new vid;
        if(IsPlayerInAnyVehicle(playerid)){
            vid = GetPlayerVehicleID(playerid);
            if(GetVehicleModel(vid) == 582){
                vid -= 1;
                if(vInfo[vid][IsLive] == 0){
                    vInfo[vid][IsLive] = 1;
                    SendClientMessage(playerid, ADMINBLUE, "> You have enabled live broadcasting in this van.");
                } else {
                    vInfo[vid][IsLive] = 0;
                    SendClientMessage(playerid, ADMINBLUE, "> You have disabled live broadcasting in this van.");
                }
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 6, 9998.7725,10012.2715,10001.0869)){
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fID] == 4){
                    if(fInfo[i][IsLive] == 0){
                        fInfo[i][IsLive] = 1;
                        SendClientMessage(playerid, ADMINBLUE, "> You have enabled live broadcasting in the studio.");
                    } else {                        
                        fInfo[i][IsLive] = 0;
                        SendClientMessage(playerid, ADMINBLUE, "> You have disabled live broadcasting in the studio.");
                    }
                }
            }
        }
    }
    return 1;
}

CMD:repair(playerid, params[]){
    // /repair: sends  target ID if in range a request to repair, like /heal.
    // player can /accept or decline, but this time it will tell them a price
    // if player has that amount of cash, and accepts, give player $50 faction pay + whatever the amount was
    // send admins an alert of this, so we can prevent people abusing this CMD to charge players a lot, unless they have a reason
    new target, price;
    if(pInfo[playerid][pFactionId] == 3){
        if(sscanf(params, "dd", target, price)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /repair [id] [price]"); {
            new Float:x, Float:y, Float:z;
            GetPlayerPos(target, x, y, z);
            if(target != playerid){
                if(IsPlayerInAnyVehicle(target)) {
                    if(IsPlayerInRangeOfPoint(playerid, 1.5, x, y, z)) {
                        new string[256];
                        format(string, sizeof(string), "> You have sent %s a vehicle repair request!", RPName(target));
                        SendClientMessage(playerid, ADMINBLUE, string);
                        
                        format(string, sizeof(string), "> You can now /accept (or /decline) this repair request from: %s (Cost: $%d) !", RPName(playerid), price);
                        SendClientMessage(target, ADMINBLUE, string);
                        
                        pInfo[target][AwaitingRAccept] = 1;
                        pInfo[target][SentRAccept] = playerid;
                        pInfo[target][SentRPrice] = price;

                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} That player is not in a vehicle!");
                    return 1;
                }
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:refill(playerid, params[]){
    // player must be closest to the target vehicle.
    // freeze player and wait 5 s to refill
    // this can be done without charging a player, but must be RP'd to refill.
    new string[256];
    if(pInfo[playerid][pFactionId] == 3){
        new vid;
        vid = GetClosestVeh(playerid);
        if(!IsPlayerInAnyVehicle(playerid)){
            if(vInfo[vid][vFuel] < 100){
                new engine, lights, alarm, doors, bonnet, boot, objective;
                GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective); //will check that what is the state of the engine.
                if(engine == 0){
                    new difference = 100;
                    difference -= vInfo[vid][vFuel];
                    format(string, sizeof(string), "> You are refuelling this vehicle with: %d L of fuel.", difference);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    vInfo[vid][vFuel] += difference;
                    pInfo[playerid][pFactionPay] += 50;
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle's engine is still on!");
                    return 1;
                }
            } else {
                format(string,sizeof(string), "[SERVER]:{FFFFFF} This vehicle cannot hold any more fuel!");
                SendClientMessage(playerid, SERVERCOLOR, string);
                return 1;
            }
        } else {
            format(string,sizeof(string), "[SERVER]:{FFFFFF}  You cannot use this command in a vehicle!");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

stock GetClosestVeh(playerid){
    new vid = -2;
    new Float:x, Float:y, Float:z;
    for(new i = 0; i < MAX_VEHICLES; i++){
        GetVehiclePos(i, x, y, z);
        if(IsPlayerInRangeOfPoint(playerid, 3,x,y,z)){ // 3M from veh
            vid = i - 1;
            return vid;
        }
    }
}

CMD:pockets(playerid, params[]){
    ReturnPlayerInventory(playerid, playerid);
    return 1;
}

CMD:help(playerid, params[]) {
    new Usage[128];
    if(sscanf(params, "s[128]", Usage)) {
        if(pInfo[playerid][pAdminLevel] >= 1) {
            SendClientMessage(playerid, SERVERCOLOR, "[SYNTAX]:{FFFFFF} /help [Usage]");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} General, Chat, Faction, Job, Business, House, Phone");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} Helper, Moderator, Admin");
        } else if(pInfo[playerid][pModerator] >= 1) {
            SendClientMessage(playerid, SERVERCOLOR, "[SYNTAX]:{FFFFFF} /help [Usage]");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} General, Chat, Faction, Job, Business, House, Phone");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} Helper, Moderator");
        } else if(pInfo[playerid][pHelper] >= 1) {
            SendClientMessage(playerid, SERVERCOLOR, "[SYNTAX]:{FFFFFF} /help [Usage]");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} General, Chat, Faction, Job, Business, House, Phone");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} Helper");
        } else {
            SendClientMessage(playerid, SERVERCOLOR, "[SYNTAX]:{FFFFFF} /help [Usage]");
            SendClientMessage(playerid, SERVERCOLOR, "[USAGES]:{FFFFFF} General, Chat Faction, Job, Business, House, Phone");
        }
        return 1;
    } else {
        if(strcmp(Usage, "General", true) == 0) {
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} General Commands ::.");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/help, /admins, /mods, /helpers, /staff");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/shop, /stats, /pockets, /rentcar, /unrentcar");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/properties, /buyproperty, /sellproperty");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/getcar, /park");
        } else if(strcmp(Usage, "Job", true) == 0) {
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Job Commands ::.");
            if(pInfo[playerid][pJobId] == 4){
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /quitjob, /inventory, /collect");
            } else if(pInfo[playerid][pJobId] == 3) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /quitjob, /route");
            } else if(pInfo[playerid][pJobId] == 2) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /startjob, /collect, /dump, /quitjob");
            } else if(pInfo[playerid][pJobId] == 1) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /quitjob, /takepost");
            } else if(pInfo[playerid][pJobId] == 0) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /takejob, /listjobs");
            }
        } else if(strcmp(Usage, "Admin", true) == 0) {
            if(pInfo[playerid][pAdminLevel] >= 1) {
                SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Admin Commands ::.");
                if(pInfo[playerid][pAdminLevel] >= 5){
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /createbus, /setbusentr, /createrentalvehicle, /createhouse");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /createfactionvehicle, /setfacentr, /setfacduty, /setfacclothes");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /sethousentr, /setbususe, /createfac");
                }
                if(pInfo[playerid][pAdminLevel] >= 6) {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /createjob, /makeleader");
                }
            }
        } else if(strcmp(Usage, "Business", true) == 0){
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Business Commands ::.");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/collectsal, /properties, /sellproperty");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/buyproperty");
        } else if(strcmp(Usage, "House", true) == 0){
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} House Commands ::.");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/lockhouse, /properties, /sellproperty");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/buyproperty, /spawnpoint");
        } else if(strcmp(Usage, "Faction", true) == 0){
            if(pInfo[playerid][pFactionId] >= 1){
                if(pInfo[playerid][pFactionId] == 1){
                    SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Faction Commands ::.");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /cuff, /ticket, /ca (create alert), /arrest");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /impound, NumPad+ to tow a vehicle, /gate");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /listallcalls, /takecall, /endcall, /flash");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /duty, /dutyclothes");
                }
                if(pInfo[playerid][pFactionId] == 2){
                    SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Faction Commands ::.");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /heal");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /listallcalls, /takecall, /endcall, /flash");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /duty, /dutyclothes");
                }
                if(pInfo[playerid][pFactionId] == 3){
                    SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Faction Commands ::.");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /repair, /flash, /refill");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /takecall, /listallcalls, /endcall");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /duty, /dutyclothes");
                }
                if(pInfo[playerid][pFactionId] == 4){
                    SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Faction Commands ::.");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /live, /listallads, /acceptad, /declinead");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /takecall, /endcall, /listallcalls");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /duty, /dutyclothes");
                }
                if(pInfo[playerid][pFactionRank] == 7){
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /hire, /fire, /demote, /promote");
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /rankname");
                }
            }
        } else if(strcmp(Usage, "Phone", true) == 0){
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Phone Commands ::.");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: /call, /hangup, /sms");
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: Numbers: 911, 227 (Towing Co), 3170 (SANN)");
        }
    }
    return 1;
}


CMD:makeleader(playerid, params[]) {
    new target, facid, string[256];
    if(pInfo[playerid][pAdminLevel] == 6) {
        if(sscanf(params, "dd", target, facid)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /makeleader [ID] [facid]"); {
            pInfo[target][pFactionId] = facid;
            pInfo[target][pFactionRank] = 7;
            SetFactionRanknameByRank(playerid, facid - 1, 7);
            format(string, sizeof(string), "[SERVER]:{FFFFFF} You have made %s the leader of %s.", RPName(target), ReturnFacName(playerid, facid - 1));
            SendClientMessage(playerid, ADMINBLUE, string);
            format(string, sizeof(string), "[SERVER]:{FFFFFF} You have been made the leader of %s.", ReturnFacName(playerid, facid - 1));
            SendClientMessage(target, ADMINBLUE, string);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:createjob(playerid, params[]) {
    if(pInfo[playerid][pAdminLevel] == 6) {
        new Float:infX, Float:infY, Float:infZ, query[1000], joPay, joName[32];
        if(sscanf(params, "sd", joName, joPay)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /createjob [JOB NAME] [JOB PAY]"); {
            GetPlayerPos(playerid, infX, infY, infZ);
            CreateDynamicPickup(1239, 1, infX, infY, infZ, -1);

            mysql_format(db_handle, query, sizeof(query), "INSERT INTO `jobs` (`jName`,`jPay`, `jobIX`,`jobIY`,`jobIZ`) VALUES ('%s', '%d','%f','%f','%f')", joName, joPay, infX, infY, infZ);
            mysql_tquery(db_handle, query, "OnJobCreated", "ds", playerid, joName);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:takejob(playerid, params[]) {
    for (new i = 0; i < loadedJob; i++) {
        if(IsPlayerInRangeOfPoint(playerid, 5, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ])) {
            if(pInfo[playerid][pJobId] == 0) {
                pInfo[playerid][pJobId] = jInfo[i][jID];
                new string[256];
                format(string, sizeof(string), "[SERVER]:{FFFFFF} You have started working as a:{FFFFFF} %s", jInfo[i][jName]);
                SendClientMessage(playerid, SERVERCOLOR, string);
            } else {
                TextDrawShowForPlayer(playerid, CantCommand);
                SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

            }
        }
    }
    return 1;
}

CMD:quitjob(playerid, params[]) {
    if(pInfo[playerid][pJobId] >= 1) {
        if(pInfo[playerid][CurrentState] != 1)
        {
            for (new i = 0; i < loadedJob; i++) {
                if(pInfo[playerid][pJobId] == jInfo[i][jID]) {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have quit your job!");
                    pInfo[playerid][pJobId] = 0;
                    return 1;
                }
            }
        } else {
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You're current on a job! /endjob to end your job!");
            return 1;
        }
    } else {

        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);

    }
    return 1;
}

CMD:listjobs(playerid, params[]) {
    //if(IsPlayerInRangeOfPoint)
    new jobList[256], string[256];
    for (new i = 0; i < loadedJob; i++) {
        format(string, sizeof(string), "JOB:%s {FFFFFF}(%d)\n", jInfo[i][jName], jInfo[i][jID]);
        strcat(jobList, string);
    }
    Dialog_Show(playerid, DIALOG_JOB_LIST, DIALOG_STYLE_LIST, "Available Jobs", jobList, "Accept", "Decline");
    return 1;
}
//* drug dealer job */
CMD:inventory(playerid, params[]){
    if(pInfo[playerid][pJobId] == 4){ // if a drug dealer
        if(IsPlayerInRangeOfPoint(playerid, 73,814.9191,1683.5012,5.2813)){
            new drugList[256], string[256];
            for(new i = 0; i < loadedDrug; i++){
                format(string, sizeof(string), "Name: %s | Amount: %d | Price: %d\n", drugInfo[i][drugName], drugInfo[i][drugAmount], drugInfo[i][drugPrice]);
                strcat(drugList, string);
            }
            Dialog_Show(playerid, DIALOG_CHINVENTORY, DIALOG_STYLE_MSGBOX, "Crack House Inventory", drugList, "Accept", "");
        } else {
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not near the crack house!");
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}



//*postman job*/
CMD:takepost(playerid, params[]) {
    for (new i = 0; i < loadedJob; i++) {
        //if(strcmp(jInfo[i][jName], "Postman", true)) { // if the job name is Postman!
        if(IsPlayerInRangeOfPoint(playerid, 10, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ])) {
            if(pInfo[playerid][pJobId] == jInfo[i][jID]) {
                if(pInfo[playerid][CurrentState] != 1) {
                    pInfo[playerid][CurrentState] = 1;
                    new string[256];
                    new rand = random(15 - 3) + 3;

                    format(string, sizeof(string), "You have taken:%d wrapped up newspapers! \n\nDeliver them to the marked location and receive payment for your work!\n\nThe current price for one stack of newspapers is:%d", rand, jInfo[i][jPay]);
                    pInfo[playerid][PostState] = rand;
                    Dialog_Show(playerid, DIALOG_TAKEPOST, DIALOG_STYLE_MSGBOX, "Postman Job", string, "Continue", "");
                } else {
                    TextDrawShowForPlayer(playerid, CantTakePost);
                    SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
                }
            }
            return 1;
        }
        //}
    }
    return 1;
}

/* Garbageman job */
CMD:startjob(playerid, params[]) {
    /* Player must be in garbageman job(ID 2)
    Player must have garbagestate = 0
    CurrentState must be 0, awaiting job
    
    This command commences the job and creates random checkpoint from location list:RandomGarbageLocations.

    Must be in range of predefined point of rubbish, maybe have 10-20 garbage points which are randomly selected on entering the created checkpoint?
    */
    if(pInfo[playerid][pJobId] == 2) {
        DestroyDynamicCP(GarbageCheckpoint[0]);
        DestroyDynamicCP(PostCheckpoint[0]);
        DestroyDynamicCP(dumpCheckPoint[0]);
        for (new i = 0; i < loadedJob; i++) {
            if(jInfo[i][jID] == 2) {
                if(IsPlayerInRangeOfPoint(playerid, 10, jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ])) {
                    if(pInfo[playerid][CurrentState] == 0) { // awaiting job
                        if(pInfo[playerid][GarbageState] == 0) {
                            new string[256];
                            format(string, sizeof(string), "Thank you for starting your job!\n\nCollect the marked (check minimap) garbage bags and take them to the Dump (marked 'D')!\n\nThe current price per bag is:$%d", jInfo[i][jPay]);
                            Dialog_Show(playerid, DIALOG_STARTGARBAGE, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");
                        }
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not in range of the job point!");
                }
            }
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

CMD:properties(playerid, params[]){
    new name[32];
    GetPlayerName(playerid, name, sizeof(name));
    SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Owned Properties ::.");
    for(new i = 0; i < loadedBus; i++){
        if(!strcmp(name, bInfo[i][bOwner])){
            new string[256];
            format(string, sizeof(string), "[BUSINESS]: Address: %d.street | Name: %s ", bInfo[i][bAddress], bInfo[i][bName]);
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
    }
    for(new i = 0; i < loadedHouse; i++){
        if(!strcmp(name, hInfo[i][hOwner])){
            new string[256];
            format(string, sizeof(string), "[HOUSE]: Address: %d.street ", hInfo[i][hAddress]);
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
    }
    return 1;
}

CMD:spawnpoint(playerid, params[]){
    new add, name[32];
    GetPlayerName(playerid, name, sizeof(name));
    if(sscanf(params, "d", add)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /spawnpoint [Address]");{
        for(new i = 0; i < loadedHouse; i++){
            if(hInfo[i][hAddress] == add){
                if(!strcmp(hInfo[i][hOwner], name)){
                    new string[256];
                    format(string, sizeof(string), "> You have set your spawn point to: %d.street!", hInfo[i][hAddress]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPreferredSpawn] = add;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not own this property!");
                }
            }
        }
    }
    return 1;
}

CMD:buyproperty(playerid, params[]){
    new add;
    new name[32];
    GetPlayerName(playerid, name, sizeof(name));
    if(sscanf(params, "d", add)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /buyproperty [Address]"); {
        for(new i = 0; i < loadedBus; i++){
            if(bInfo[i][bAddress] == add){
                if(!strcmp(bInfo[i][bOwner], "NULL", true)){
                    if(GetPlayerMoney(playerid) >= bInfo[i][bPrice]){
                        new string[256], DB_Query[900];
                        format(string, sizeof(string), "> You have purchased %d.street for $%d!", bInfo[i][bAddress], bInfo[i][bPrice]);
                        SendClientMessage(playerid, ADMINBLUE, string);
                        GivePlayerMoney(playerid, -bInfo[i][bPrice]);
                        pInfo[playerid][pCash] -= bInfo[i][bPrice];
                        format(bInfo[i][bOwner], 32, name);
                        DestroyDynamicPickup(busInfoPickup[bInfo[i][bId]-1]);
                        busInfoPickup[bInfo[i][bId]-1] = CreateDynamicPickup(1239, 1, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], -1);
                        mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bOwner` = '%s' WHERE  `bId` = '%d'",name, bInfo[i][bId]);
                        mysql_query(db_handle, DB_Query);
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not have enough cash to purchase this property!");
                        return 1;
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This property is already owned!");
                    return 1;
                }
            }
        }
        for(new i = 0; i < loadedHouse; i++){
            if(hInfo[i][hAddress] == add){
                if(!strcmp(hInfo[i][hOwner], "NULL", true)){
                    if(GetPlayerMoney(playerid) >= hInfo[i][hPrice]){                        
                        new string[256], DB_Query[900];
                        format(string, sizeof(string), "> You have purchased %d.street for $%d!", hInfo[i][hAddress], hInfo[i][hPrice]);
                        SendClientMessage(playerid, ADMINBLUE, string);
                        GivePlayerMoney(playerid, -hInfo[i][hPrice]);
                        pInfo[playerid][pCash] -= hInfo[i][hPrice];
                        format(hInfo[i][hOwner], 32, name);
                        pInfo[playerid][pPreferredSpawn] = add;
                        DestroyDynamicPickup(houseInfoPickup[hInfo[i][hId]-1]);
                        houseInfoPickup[hInfo[i][hId]-1] = CreateDynamicPickup(1239, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
                        mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `houses` SET `hOwner` = '%s' WHERE  `hId` = '%d'",name, hInfo[i][hId]);
                        mysql_query(db_handle, DB_Query);
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not have enough cash to purchase this property!");
                        return 1;
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This property is already owned!");
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:sellproperty(playerid, params[]){
    // if in range of city hall
    new add;
    new name[32];
    GetPlayerName(playerid, name, sizeof(name));
    if(sscanf(params, "d", add)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /sellproperty [Address]"); {
        for(new i = 0; i < loadedBus; i++){
            if(bInfo[i][bAddress] == add){
                if(!strcmp(name, bInfo[i][bOwner])){
                    new string[256], DB_Query[900];
                    format(string, sizeof(string), "> You have sold %d.street for $%d!", bInfo[i][bAddress], bInfo[i][bPrice]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    format(bInfo[i][bOwner], 32, "NULL");
                    GivePlayerMoney(playerid, bInfo[i][bPrice]);
                    pInfo[playerid][pCash] += bInfo[i][bPrice];
                    DestroyDynamicPickup(busInfoPickup[bInfo[i][bId]-1]);
                    busInfoPickup[bInfo[i][bId]-1] = CreateDynamicPickup(1273, 1, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ], -1);
                    mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bOwner` = 'NULL' WHERE  `bId` = '%d'", bInfo[i][bId]);
                    mysql_query(db_handle, DB_Query);
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not own this property!");
                    return 1;
                }
            }
        }
        for(new i = 0; i < loadedHouse; i++){
            if(hInfo[i][hAddress] == add){
                if(!strcmp(name, hInfo[i][hOwner])){                       
                    new string[256], DB_Query[900];
                    format(string, sizeof(string), "> You have sold %d.street for $%d!", hInfo[i][hAddress], hInfo[i][hPrice]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    GivePlayerMoney(playerid, hInfo[i][hPrice]);
                    pInfo[playerid][pCash] += hInfo[i][hPrice];
                    format(hInfo[i][hOwner], 32, "NULL");
                    pInfo[playerid][pPreferredSpawn] = 0;
                    DestroyDynamicPickup(houseInfoPickup[hInfo[i][hId]-1]);
                    houseInfoPickup[hInfo[i][hId]-1] = CreateDynamicPickup(1273, 1, hInfo[i][hInfoX], hInfo[i][hInfoY], hInfo[i][hInfoZ], -1);
                    mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `houses` SET `hOwner` = 'NULL' WHERE  `hId` = '%d'", hInfo[i][hId]);
                    mysql_query(db_handle, DB_Query);
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You do not own this property!");
                    return 1;
                }
            }
        }
    }
    return 1;
}

CMD:collectsal(playerid, params[]){
    new name[32];
    GetPlayerName(playerid, name, sizeof(name));
    for(new i = 0; i < loadedBus; i++){
        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ])){
            if(!strcmp(name, bInfo[i][bOwner])){
                // if b owner
                GivePlayerMoney(playerid, bInfo[i][bSalary]);
                pInfo[playerid][pCash] += bInfo[i][bSalary];
                new string[256];                
                format(string, sizeof(string), "[SERVER]:{FFFFFF} You have collected $%d from your business!", bInfo[i][bSalary]);
                SendClientMessage(playerid, SERVERCOLOR, string);
                bInfo[i][bSalary] = 0;                            
                new DB_Query[900];
                mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bSalary` = '%d' WHERE  `bId` = '%d'", bInfo[i][bSalary], bInfo[i][bId]);
                mysql_query(db_handle, DB_Query);
                return 1;
            }
        }
    }
    return 1;
}

CMD:collect(playerid, params[]) {
    if(pInfo[playerid][pJobId] == 2) {
        new vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid == 0) {
            if(IsPlayerInDynamicCP(playerid, GarbageCheckpoint[0])) {
                if(pInfo[playerid][CurrentState] == 1) {
                    if(pInfo[playerid][GarbageState] <= 19) {
                        DestroyDynamicCP(GarbageCheckpoint[0]);
                        new rand = random(6 - 3) + 2;
                        new string[256];
                        for (new i = 0; i < loadedJob; i++) {
                            if(jInfo[i][jID] == 2) {
                                format(string, sizeof(string), "You have taken %d garbage bags! \n\nYou can take them straight to the Dump (marked 'D' on the minimap), or continue to the next checkpoint!\n\nThe current price for one garbage bag is $%d", rand, jInfo[i][jPay]);
                                pInfo[playerid][GarbageState] += rand;
                                Dialog_Show(playerid, DIALOG_COLLECT, DIALOG_STYLE_MSGBOX, "Garbageman Job", string, "Continue", "");
                                return 1;
                            }
                        }
                    } else {
                        /* Player must now go to the dump, and use /dump cmd at info point 
                            Need to define dump point
                            Need to set player pay after the dump is complete. Longer job = better pay
                        */

                        DestroyDynamicCP(GarbageCheckpoint[0]);
                        dumpCheckPoint[0] = CreateDynamicCP(281.7589, 1411.7045, 9.8603, 2, -1, -1, -1, 10000);
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You cannot hold any more garbage bags! Please visit the dump marked on the minimap!");
                    }
                }
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not at a Garbage collection point, check your minimap for the next point!");
                return 1;
            }
        } else {
            return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You must be on foot to collect garbage!");
        }
    }
    if(pInfo[playerid][pJobId] == 4){
        new dName[32], string[256], DB_Query[900]; 
        if(sscanf(params, "s", dName)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /collect [DRUGNAME]"); {
            // if player has 1 weed, allow
            if(strcmp(dName, "Weed", true) == 0) { // Check to see if inserted amount is less than 10
                // check if player's weed stat is less than 10.                           
                if(drugInfo[0][drugAmount] > 0){                  
                    if(GetPlayerMoney(playerid) >= drugInfo[0][drugPrice]){
                        if(pInfo[playerid][pWeedAmount] < 10){ 
                            // if weed stat is less than amount...
                            pInfo[playerid][pWeedAmount] += 1;
                            format(string, sizeof(string), "[SERVER]:{FFFFFF} You have purchased %d grams of weed!", 1);
                            SendClientMessage(playerid, SERVERCOLOR, string);
                            drugInfo[0][drugAmount] -= 1;
                            GivePlayerMoney(playerid, -drugInfo[0][drugPrice]);
                            pInfo[playerid][pCash] -= drugInfo[0][drugPrice];
                            mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `drugprices` SET `drugAmount` = '%d' WHERE  `drugId` = 1", drugInfo[0][drugAmount]);
                            mysql_query(db_handle, DB_Query);
                            if(pInfo[playerid][pPhoneNumber] != 0){
                                KillTimer(drugDealTimer[playerid]);
                                drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);
                            } else {
                                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have a phone, and therefore will not receive drug deal messages!");
                                return 1;
                            }
                        } else {
                            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You cannot carry any more Weed!");
                        }
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} The crack house does not have any Weed!");
                }
            } else if(strcmp(dName, "Cocaine", true) == 0) { 
                if(drugInfo[1][drugAmount] > 0){
                    if(GetPlayerMoney(playerid) >= drugInfo[1][drugPrice]){

                        if(pInfo[playerid][pCokeAmount] < 10){ 
                                // if coke stat is less than 10...
                                pInfo[playerid][pCokeAmount] += 1;
                                format(string, sizeof(string), "[SERVER]:{FFFFFF} You have purchased %d grams of cocaine!", 1);
                                SendClientMessage(playerid, SERVERCOLOR, string);
                                drugInfo[1][drugAmount] -= 1;
                                GivePlayerMoney(playerid, -drugInfo[1][drugPrice]);
                                pInfo[playerid][pCash] -= drugInfo[1][drugPrice];
                                mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `drugprices` SET `drugAmount` = '%d' WHERE  `drugId` = 2", drugInfo[0][drugAmount]);
                                mysql_query(db_handle, DB_Query);
                                if(pInfo[playerid][pPhoneNumber] != 0){
                                    KillTimer(drugDealTimer[playerid]);
                                    drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);
                                } else {
                                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have a phone, and therefore will not receive drug deal messages!");
                                    return 1;
                                }
                            } else {
                                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You cannot carry any more Cocaine!");
                            }
                        } 
                    } else {
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} The crack house does not have any Cocaine!");
                }
            }
        return 1;
    }
    if(pInfo[playerid][pJobId] != 2 || pInfo[playerid][pJobId] != 4)
    {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
        return 1;
    }
    return 1;
}

forward public BeginDrugDealing(playerid);
public BeginDrugDealing(playerid){
    if(pInfo[playerid][pWeedAmount] >= 1 || pInfo[playerid][pCokeAmount] >= 1){
        pInfo[playerid][CurrentState] = 1;
        new rand;
        new sizeOf = sizeof(randomdrugdeals);
        rand = random(sizeOf - 1) + 1;
        KillTimer(drugDealTimer[playerid]);
        drugDeal[playerid] = CreateDynamicCP(randomdrugdeals[rand][0], randomdrugdeals[rand][1], randomdrugdeals[rand][2], 2, -1, -1, -1, 10000);
        SendPlayerText(pInfo[playerid][pPhoneNumber], "Hey, you about? The usual at our normal spot.", 0);
        drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);
    }
    return 1;
}
forward public SendPlayerText(tnumber, message[100], from);
public SendPlayerText(tnumber, message[100], from){
    for (new i = 0; i < MAX_PLAYERS; i++){
        if(pInfo[i][pPhoneNumber] == tnumber)
        {
            new string[256];
            if(from == 0){
                format(string, sizeof(string), "Text msg received: %s, from: Unknown", message);
                SendClientMessage(i, SERVERCOLOR, string);
            }
            else {                
                format(string, sizeof(string), "Text msg received: %s, from: %d", message, from);
                SendClientMessage(i, SERVERCOLOR, string);
            }
        }
    }
    return 1;
}

CMD:dump(playerid, params[]) {
    if(IsPlayerInRangeOfPoint(playerid, 10, 281.7589, 1411.7045, 9.8603)) {
        if(pInfo[playerid][pJobId] == 2) {
            new vehicleid = GetPlayerVehicleID(playerid);
            if(vehicleid == 0) {
                if(pInfo[playerid][CurrentState] == 1) { // if started job
                    if(pInfo[playerid][GarbageState] >= 1) {
                        for (new i = 0; i < loadedJob; i++) {
                            if(jInfo[i][jID] == 2) {
                                new totalPay, string[256];
                                pInfo[playerid][CurrentState] = 0; // finish job
                                totalPay = pInfo[playerid][GarbageState] * jInfo[i][jPay];
                                pInfo[playerid][pJobPay] += totalPay;

                                format(string, sizeof(string), "Thank you for collecting %d garbage bags!\n\nReturn to the depot to resume collecting!\n\nYou will receive $%d on your next paycheck!", pInfo[playerid][GarbageState], totalPay);
                                Dialog_Show(playerid, DIALOG_DUMP, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");

                                pInfo[playerid][GarbageState] = 0;
                                return 1;
                            }
                        }
                    } else {
                        TextDrawShowForPlayer(playerid, NoBinBags);
                        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
                    }
                }
            } else {
                return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You must be on foot to dump your collected garbage!");
            }
        } else {
            TextDrawShowForPlayer(playerid, CantCommand);
            SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
        }
    }
    return 1;
}

/* bus job */
CMD:route(playerid, params[]) {
    if(pInfo[playerid][pJobId] == 3) { // check if valid job id 
        if(pInfo[playerid][CurrentState] == 0) { // not in state
            new vehid = GetPlayerVehicleID(playerid);
            if(IsPlayerInVehicle(playerid, vehid)) {
                if(GetVehicleModel(vehid) == 431) { // checking if in bus
                    ShowMenuForPlayer(busdrivermenu, playerid); // show the bus menu!
                    TogglePlayerControllable(playerid, false); // freeze player so they can use the menu
                }
            }
        } else {
            SendClientMessage(playerid, ADMINBLUE, "[SERVER]:{FFFFFF} You are already on a bus route!");
            return 1;
        }
    }
    return 1;
}

CMD:endjob(playerid, params[]) {
    if(pInfo[playerid][pJobId] >= 1) {
        // affect all jobs
        if(pInfo[playerid][CurrentState] == 1) {
            Dialog_Show(playerid, DIALOG_ENDJOB, DIALOG_STYLE_MSGBOX, "Ending job...", "Are you sure you want to end this current job?\n\nWARNING - This will forfeit ALL of your collected garbage bags/newspapers!", "Yes", "No");
        } else {
            TextDrawShowForPlayer(playerid, CantCommand);
            SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
        }
    } else {
        TextDrawShowForPlayer(playerid, CantCommand);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 1;
}

forward public OnPlayerBuyVehicle(playerid, playername[32]);
public OnPlayerBuyVehicle(playerid, playername[32]){
    LoadNewVehData(cache_insert_id());
}

forward public OnRentalVehCreated(playerid, vid, busid, price);
public OnRentalVehCreated(playerid, vid, busid, price){
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} Rental vehicle (bid: %d price: %d) created!", busid, price);
    SendClientMessage(playerid, -1, string); {
        LoadNewVehData(cache_insert_id());
    }
}

forward public OnFactionVehCreated(playerid, vid, facid);
public OnFactionVehCreated(playerid, vid, facid){
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} Faction vehicle (facid: %d) created!", facid);
    SendClientMessage(playerid, -1, string); {
        LoadNewVehData(cache_insert_id());
    }
}

forward public OnFacCreated(playerid, facName[32], type, address, price);
public OnFacCreated(playerid, facName[32], type, address, price){
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} Fac %s(%d TYPE %d ADDRESS %d.Street PRICE $%d) has beenb created!", facName, cache_insert_id(), type, address, price);
    SendClientMessage(playerid, -1, string);
}

forward public OnBusCreated(playerid, busName[32], type, address, price);
public OnBusCreated(playerid, busName[32], type, address, price){
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} Business %s(%d TYPE %d ADDRESS %d.Street PRICE $%d) has beenb created!", busName, cache_insert_id(), type, address, price);
    SendClientMessage(playerid, -1, string); {
        LoadNewBusData(cache_insert_id());
    }
}

forward public OnJobCreated(playerid, joName[32]);
public OnJobCreated(playerid, joName[32]) {
    new string[256];
    format(string, sizeof(string), "[SERVER]:{FFFFFF} Job %s(%d) has been created!", joName, cache_insert_id());
    SendClientMessage(playerid, -1, string); {
        LoadNewJobData(cache_insert_id());
    }
}


public OnPlayerCommandText(playerid, cmdtext[]) {
    if(strcmp("/mycommand", cmdtext, true, 10) == 0) {
        // Do something here
        return 1;
    }
    return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {

    new modelid;
    modelid = GetVehicleModel(vehicleid);
    if(!ispassenger) {
        if(modelid != 481) {
            // display vehicle speedo stuff
            PlayerTextDrawShow(playerid, VEHSTUFF[playerid][0]);
            PlayerTextDrawShow(playerid, VEHSTUFF[playerid][1]);
            PlayerTextDrawShow(playerid, VEHSTUFF[playerid][2]);
            PlayerTextDrawShow(playerid, VEHSTUFF[playerid][3]);
            PlayerTextDrawShow(playerid, VEHSTUFF[playerid][4]);

            new vehName[32];
            format(vehName, sizeof(vehName), "%s", GetVehicleName(vehicleid));
            PlayerTextDrawSetString(playerid, VEHSTUFF[playerid][2], vehName);
            new fuel[32];
            for (new i = 0; i < loadedVeh; i++) {
                if(vInfo[i][vID] == vehicleid) {
                    format(fuel, sizeof(fuel), "%d L", vInfo[i][vFuel]);
                    PlayerTextDrawSetString(playerid, VEHSTUFF[playerid][4], fuel);
                }
            }

            speedoTimer[playerid] = SetTimerEx("GetVehicleSpeed", 100, false, "dd", playerid);
            fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 100, false, "dd", playerid, GetPlayerVehicleID(playerid));
        }
    }
    return 1;
}


forward public SetVehicleFuel(playerid, vehid);
public SetVehicleFuel(playerid, vehid) {
    for (new i = 0; i < loadedVeh; i++) {
        if(vInfo[i][vID] == GetPlayerVehicleID(playerid)) {
            new engine, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(vInfo[i][vID], engine, lights, alarm, doors, bonnet, boot, objective); //will check that what is the state of the engine.
            if(engine == 1) {
                if(vInfo[i][vFuel] >= 1) {
                    vInfo[i][vFuel]--;
                    new fuel[32];
                    format(fuel, sizeof(fuel), "%d L", vInfo[i][vFuel]);
                    PlayerTextDrawSetString(playerid, VEHSTUFF[playerid][4], fuel);
                    fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 17500, false, "dd", playerid, vehid);
                } else {
                    SetVehicleParamsEx(vInfo[i][vID], false, lights, alarm, doors, bonnet, boot, objective); //will check that what is the state of the engine.
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle does not have enough fuel!");
                }
            }
        }
    }
    return 1;
}

forward public GetVehicleSpeed(playerid);
public GetVehicleSpeed(playerid) {
    new Float:x, Float:y, Float:z;
    new Float:speed, Float:final_speed;
    new vehSpeed[32];
    GetVehicleVelocity(GetPlayerVehicleID(playerid), x, y, z);
    speed = floatsqroot(((x * x) + (y * y)) + (z * z)) * 100;
    final_speed = floatround(speed, floatround_round);

    format(vehSpeed, sizeof(vehSpeed), "%.0f MPH", final_speed);
    PlayerTextDrawSetString(playerid, VEHSTUFF[playerid][3], vehSpeed);
    SetTimerEx("GetVehicleSpeed", 100, false, "dd", playerid);
    return 1;
}

forward public HideSpeedoTextdraws(playerid);
public HideSpeedoTextdraws(playerid) {
    PlayerTextDrawHide(playerid, VEHSTUFF[playerid][0]);
    PlayerTextDrawHide(playerid, VEHSTUFF[playerid][1]);
    PlayerTextDrawHide(playerid, VEHSTUFF[playerid][2]);
    PlayerTextDrawHide(playerid, VEHSTUFF[playerid][3]);
    PlayerTextDrawHide(playerid, VEHSTUFF[playerid][4]);
    KillTimer(speedoTimer[playerid]);
    KillTimer(fuelTimer[playerid]);
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    HideSpeedoTextdraws(playerid);
    return 1;
}


public OnPlayerStateChange(playerid, newstate, oldstate) {
    new vehicleid, name[32];
    GetPlayerName(playerid, name, sizeof(name));

    vehicleid = GetPlayerVehicleID(playerid); // check vehicle id;
    vehicleid -= 1; // taking one away to select correct veh;

    if(newstate == PLAYER_STATE_DRIVER) { // IF PLAYER IS DRIVER    
        if(vInfo[vehicleid][vRentalState] == VEHICLE_RENTABLE && vInfo[vehicleid][vRented] == VEHICLE_NOT_RENTED) { // check if vehicle is rentable + not rented NOT JOB RENTAL{
            new string[256];
            format(string, sizeof(string), "[SERVER]:{FFFFFF} This vehicle is rentable for {00FF00}$%d{FFFFFF}. Type /rentcar to rent it.", vInfo[vehicleid][vRentalPrice]);
            SendClientMessage(playerid, SERVERCOLOR, string);
            TurnVehicleEngineOff(vehicleid + 1);
            return 1;
        }
        if(vInfo[vehicleid][vJobId] >= 1 && vInfo[vehicleid][vJobId] != pInfo[playerid][pJobId]) { // check if job vehicle has been set. check if player not in right job.
            RemovePlayerFromVehicle(playerid);
            return 1;
        }
        if(vInfo[vehicleid][vJobId] >= 1 && vInfo[vehicleid][vJobId] == pInfo[playerid][pJobId]) { // check if a job vehicle and job id == player job id
            if(vInfo[vehicleid][vRentalState] == VEHICLE_RENTABLE && vInfo[vehicleid][vRented] == VEHICLE_NOT_RENTED) { // check if vehicle is rentable + not rented NOT JOB RENTAL{
                new string[256];
                format(string, sizeof(string), "[SERVER]:{FFFFFF} This vehicle is rentable for {00FF00}$%d{FFFFFF}. Type /rentcar to rent it.", vInfo[vehicleid][vRentalPrice]);
                SendClientMessage(playerid, SERVERCOLOR, string);
                TurnVehicleEngineOff(vehicleid + 1);
                return 1;
            }
        }
        if(vInfo[vehicleid][vJobId] == 0 && vInfo[vehicleid][vFacId] >= 1) { // check if not a job id and if fac id has been set.
            if(vInfo[vehicleid][vFacId] == pInfo[playerid][pFactionId]) {
                return 1;
            } else {
                RemovePlayerFromVehicle(playerid);
                return 1;
            }
        }

        if(!strcmp(name, vInfo[vehicleid][vOwner]))
            SendClientMessage(playerid, GREY, "must be a player veh");
        return 1;
    }
    if(newstate == PLAYER_STATE_ONFOOT){
        if(pInfo[playerid][DashCamStatus] == 1){
            pInfo[playerid][DashCamStatus] = 0;
            KillTimer(dashtimer[playerid]);
            PlayerTextDrawHide(playerid, dash1[playerid]);
            PlayerTextDrawHide(playerid, dash2[playerid]);
            PlayerTextDrawHide(playerid, dashPlate[playerid]);
            PlayerTextDrawHide(playerid, dashVid[playerid]);
            PlayerTextDrawHide(playerid, dashSpeed[playerid]);
            PlayerTextDrawHide(playerid, dashDist[playerid]);
            return 1;
        }
    }
    return 1;
}
CMD:rentcar(playerid, params[]) {
    new vehicleid;
    vehicleid = GetPlayerVehicleID(playerid);

    if(vehicleid == 0) {
        return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not in a vehicle!");
    }
    vehicleid -= 1;
    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Checking if vehicle is rentable....");
    SetTimerEx("RentCar", 1800, false, "dd", playerid, vehicleid);
    return 1;
}
CMD:unrentcar(playerid, params[]) {
    if(pInfo[playerid][RentingVehicle] != INVALID_VEHICLE_ID) {
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
            UnrentPlayerVehicle(playerid);
            return 1;
        } else {
            return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You must be in your rented vehicle to use this command!");
        }
    } else {
        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not renting a vehicle!");
        return 1;
    }
}

/* vehicle cmds */
CMD:lock(playerid, params[]){    
    new engine, lights, alarm, doors, bonnet, boot, objective, string[256], nname[256];
    new Float:x, Float:y, Float:z;
    format(nname, sizeof(nname), "%s", GetName(playerid));
    for(new i = 0; i < MAX_VEHICLES; i++){
        GetVehiclePos(i, x, y, z);
        if(IsPlayerInRangeOfPoint(playerid, 10,x,y,z)){
            if(vInfo[i][vFacId] == pInfo[playerid][pFactionId] || !strcmp(vInfo[i][vOwner], nname, true)){
                GetVehicleParamsEx(i, engine, lights, alarm, doors, bonnet, boot, objective);
                if(doors == 1){
                    SetVehicleParamsEx(i, engine, lights, alarm, false, bonnet, boot, objective);
                    format(string, sizeof(string), "* %s takes their keys and unlocks the vehicle.", RPName(playerid));
                    nearByAction(playerid, NICESKY, string);
                } else {
                    SetVehicleParamsEx(i, engine, lights, alarm, true, bonnet, boot, objective);
                    format(string, sizeof(string), "* %s takes their keys and locks the vehicle.", RPName(playerid));
                    nearByAction(playerid, NICESKY, string);
                }
            }
            return 1;
        }
    }
    return 1;
}

CMD:lights(playerid, params[]){
    new engine, lights, alarm, doors, bonnet, boot, objective, vid, string[256];
    vid = GetPlayerVehicleID(playerid);
    GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
    if(IsPlayerInVehicle(playerid, vid)){
        if(lights == 1){
            SetVehicleParamsEx(vid, engine, false, alarm, doors, bonnet, boot, objective);
            format(string, sizeof(string), "* %s turns the vehicles headlights off.", RPName(playerid));
            nearByAction(playerid, NICESKY, string);
        } else {
            SetVehicleParamsEx(vid, engine, true, alarm, doors, bonnet, boot, objective);
            format(string, sizeof(string), "* %s turns the vehicles headlights on.", RPName(playerid));
            nearByAction(playerid, NICESKY, string);        
        }
    }
    return 1;
}

CMD:park(playerid, params[]){
    new nname[32], Float:x, Float:y, Float:z, Float:a, DB_Query[900];
    if(IsPlayerInAnyVehicle(playerid)){
        format(nname, sizeof(nname), "%s", GetName(playerid));
        if(!strcmp(vInfo[GetPlayerVehicleID(playerid)][vOwner], nname, true)){
            GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
            vInfo[GetPlayerVehicleID(playerid)][vParkedX] = x;
            vInfo[GetPlayerVehicleID(playerid)][vParkedY] = y;
            vInfo[GetPlayerVehicleID(playerid)][vParkedZ] = z;
            GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
            vInfo[GetPlayerVehicleID(playerid)][vAngle] = a;
            SendClientMessage(playerid, ADMINBLUE,  "[SERVER]: You have parked this vehicle.");
            
            mysql_format(db_handle, DB_Query, sizeof(DB_Query), "UPDATE `vehicles` SET `vParkedX` = '%f', `vParkedY` = '%f', `vParkedZ` = '%f', `vAngle` = '%f' WHERE `vID` = '%d'", x, y, z, a, GetPlayerVehicleID(playerid));
            mysql_query(db_handle, DB_Query);
        }
        if(vInfo[GetPlayerVehicleID(playerid)][vFacId] == pInfo[playerid][pFactionId] && pInfo[playerid][pFactionRank] == 7){
            GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
            vInfo[GetPlayerVehicleID(playerid)][vParkedX] = x;
            vInfo[GetPlayerVehicleID(playerid)][vParkedY] = y;
            vInfo[GetPlayerVehicleID(playerid)][vParkedZ] = z;
            GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
            vInfo[GetPlayerVehicleID(playerid)][vAngle] = a;
            SendClientMessage(playerid, ADMINBLUE,  "[SERVER]: You have parked this vehicle.");            
            mysql_format(db_handle, DB_Query, sizeof(DB_Query), "UPDATE `vehicles` SET `vParkedX` = '%f', `vParkedY` = '%f', `vParkedZ` = '%f', `vAngle` = '%f' WHERE `vID` = '%d'", x, y, z, a, GetPlayerVehicleID(playerid));
            mysql_query(db_handle, DB_Query);
        }
    } else {

    }
    return 1;
}

CMD:engine(playerid, params[]) {
    new engine, lights, alarm, doors, bonnet, boot, objective;
    new vid, nname[32], string[256];

    vid = GetPlayerVehicleID(playerid);
    GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective);
    format(nname, sizeof(nname), "%s", GetName(playerid));
    for (new i = 0; i < loadedVeh; i++) {
        if(vInfo[i][vID] == GetPlayerVehicleID(playerid)) // if player in vehicle?
        {
            if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) { // if player driver
                GetVehicleParamsEx(vid, engine, lights, alarm, doors, bonnet, boot, objective); //will check that what is the state of the engine.
                if(vInfo[i][vRentingPlayer] == playerid) { // if rented by player
                    if(engine == 1) {
                        SetVehicleParamsEx(vid, false, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s takes their key from the igntion and turns the engine off.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        KillTimer(fuelTimer[playerid]);
                        return 1;
                    } else {
                        SetVehicleParamsEx(vid, true, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s inserts their key into the ignition and starts the engine.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 17500, false, "dd", playerid, vInfo[i][vID]);
                        return 1;
                    }
                }
                if(vInfo[i][vJobId] == pInfo[playerid][pJobId] && vInfo[i][vRentingPlayer] == playerid) {
                    if(engine == 1) {
                        SetVehicleParamsEx(vid, false, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s takes their key from the igntion and turns the engine off.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        KillTimer(fuelTimer[playerid]);
                        return 1;
                    } else {
                        SetVehicleParamsEx(vid, true, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s inserts their key into the ignition and starts the engine.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 17500, false, "dd", playerid, vInfo[i][vID]);
                        return 1;
                    }
                }
                if(!strcmp(vInfo[i][vOwner], nname, true)){
                    if(engine == 1) {
                        SetVehicleParamsEx(vid, false, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s takes their key from the igntion and turns the engine off.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        KillTimer(fuelTimer[playerid]);
                        return 1;
                    } else {
                        SetVehicleParamsEx(vid, true, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s inserts their key into the ignition and starts the engine.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 17500, false, "dd", playerid, vInfo[i][vID]);
                        return 1;
                    }
                }
                if(vInfo[i][vFacId] == pInfo[playerid][pFactionId]){
                    if(engine == 1) {
                        SetVehicleParamsEx(vid, false, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s takes their key from the igntion and turns the engine off.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        KillTimer(fuelTimer[playerid]);
                        return 1;
                    } else {
                        SetVehicleParamsEx(vid, true, lights, alarm, doors, bonnet, boot, objective);
                        format(string, sizeof(string), "* %s inserts their key into the ignition and starts the engine.", RPName(playerid));
                        nearByAction(playerid, NICESKY, string);
                        fuelTimer[playerid] = SetTimerEx("SetVehicleFuel", 17500, false, "dd", playerid, vInfo[i][vID]);
                        return 1;
                    }
                }
            }
        }
    }
    return 1;
}

forward public UnrentPlayerVehicle(playerid);
forward public UnrentVehicle(playerid, vehicleid);
public UnrentPlayerVehicle(playerid) {
    UnrentVehicle(playerid, pInfo[playerid][RentingVehicle]);
    pInfo[playerid][RentingVehicle] = INVALID_VEHICLE_ID;
    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have unrented your vehicle!");
    return 1;
}
public UnrentVehicle(playerid, vehicleid) {
    vInfo[vehicleid][vRented] = VEHICLE_NOT_RENTED;
    vInfo[vehicleid][vRentalState] = VEHICLE_RENTABLE;
    vInfo[vehicleid][vRentingPlayer] = INVALID_PLAYER_ID;
    TurnVehicleEngineOff(vehicleid);
    HideSpeedoTextdraws(playerid);
    RemovePlayerFromVehicle(playerid);
    SetVehicleToRespawn(vehicleid + 1);
    printf("** Unrenting vehicle..");
    return 1;
}

forward public RentCar(playerid, vehicleid);
public RentCar(playerid, vehicleid) {
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
        if(pInfo[playerid][RentingVehicle] != INVALID_VEHICLE_ID) {
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are already renting a vehicle.");
            return 1;
        }
        if(vInfo[vehicleid][vRentalState] == VEHICLE_NOT_RENTABLE) {
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle is not rentable.");
            return 1;
        }
        if(vInfo[vehicleid][vRented] == VEHICLE_RENTED || vInfo[vehicleid][vRentingPlayer] != INVALID_PLAYER_ID) {
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This vehicle is already rented.");
            return 1;
        }
        if(GetPlayerMoney(playerid) < vInfo[vehicleid][vRentalPrice]) {
            new string[256];
            format(string, sizeof(string), "[SERVER]:{FFFFFF} You need {00FF00}$%d {FFFFFF}to rent this vehicle, you only have {00FF00}$%d{FFFFFF}.", vInfo[vehicleid][vRentalPrice], GetPlayerMoney(playerid));
            SendClientMessage(playerid, SERVERCOLOR, string);
            return 1;
        }

        GivePlayerMoney(playerid, -vInfo[vehicleid][vRentalPrice]);
        pInfo[playerid][pCash] -= vInfo[vehicleid][vRentalPrice];
        pInfo[playerid][RentingVehicle] = vehicleid;
        vInfo[vehicleid][vRented] = VEHICLE_RENTED;
        vInfo[vehicleid][vRentingPlayer] = playerid;
        TurnVehicleEngineOff(vehicleid);
        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have rented the vehicle.");

        for(new i = 0; i < loadedBus; i++){
            if(bInfo[i][bId] == vInfo[vehicleid][vBusId]){
                new DB_Query[900];
                bInfo[i][bSalary] += vInfo[vehicleid][vRentalPrice];

                mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bSalary` = '%d' WHERE  `bId` = '%d'", bInfo[i][bSalary], bInfo[i][bId]);
                mysql_query(db_handle, DB_Query);

                //alert bus owner
                new busowner[32], name[32];
                format(busowner, sizeof(busowner), "%s", bInfo[i][bOwner]);

                for(new pi = 0; pi < MAX_PLAYERS; pi++){
                    GetPlayerName(pi, name, sizeof(name));
                    if(!strcmp(busowner, name, true)){
                        new string[100];
                        format(string, sizeof(string), "PLATE: %s has left the car lot! Rented by: %s for $%d", vInfo[vehicleid][vPlate], RPName(playerid), vInfo[vehicleid][vRentalPrice]);
                        SendPlayerText(pInfo[pi][pPhoneNumber], string, 0);
                        return 1;
                    }
                }
                return 1;
            }
        }
        return 1;
    } else {
        return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You are not in a vehicle! (This vehicle may be job-specific)");
    }
}

public OnPlayerEnterCheckpoint(playerid) {
    return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid) {
    if(checkpointid == GarbageCheckpoint[playerid]) {
        GameTextForPlayer(playerid, "/collect", 3000, 5);
    }
    if(checkpointid == PostCheckpoint[playerid]) //This checks what checkpoint it is before it continues
    {
        for (new i = 0; i < loadedJob; i++) {
            if(pInfo[playerid][CurrentState] == 1) {
                if(pInfo[playerid][pJobId] == jInfo[i][jID]) {
                    new totalPay, string[256];
                    pInfo[playerid][CurrentState] = 0;
                    totalPay = pInfo[playerid][PostState] * jInfo[i][jPay];
                    pInfo[playerid][pJobPay] += totalPay;

                    pInfo[playerid][PostState] = 0;
                    format(string, sizeof(string), "Thank you for posting these!\n\nPlease return to the depot to resume posting!\n\nYou will receive:$%d on your next paycheck!", totalPay);
                    Dialog_Show(playerid, DIALOG_DELIVERPOST, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");
                    return 1;
                }
            }
            return 1;
        }
        return 1;
    }
    if(checkpointid == JobCheckpoint[playerid]) {
        GameTextForPlayer(playerid, "/takejob", 3000, 5);
        DestroyDynamicCP(JobCheckpoint[0]);
    }
    if(checkpointid == drugDeal[playerid]){
        if(pInfo[playerid][CurrentState] == 1){
            DestroyDynamicCP(drugDeal[0]); // destroy drug CP for player.
            KillTimer(drugDealTimer[playerid]);
            pInfo[playerid][CurrentState] = 0;
            new availabletobuy = 0;
            // Send police message after 2 seconds of arriving...
            TogglePlayerControllable(playerid, false);
            new Float:px, Float:py, Float:pz;
            GetPlayerPos(playerid, px, py, pz);
            SetTimerEx("AlertPolice", 2000, false, "dsfff", playerid, "Possible drug dealing in progress!", px, py, pz);
            SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);

            if(pInfo[playerid][pWeedAmount] >= 1){ 
                availabletobuy = 1; // only got weed.
            }
            if(pInfo[playerid][pCokeAmount] >= 1){
                availabletobuy = 2; // has only got coke
            }
            if(pInfo[playerid][pWeedAmount] >= 1 && pInfo[playerid][pCokeAmount] >= 1)
            {
                availabletobuy = 3;// has both weed and coke
            }

            if(availabletobuy == 1){
                // only got weed.
                new string[256], giveMoney, money, randomWant;
                randomWant = random(pInfo[playerid][pWeedAmount] - 1) + 1;
                money = drugInfo[0][drugPrice] + (20 / 100 * drugInfo[0][drugPrice]);
                giveMoney = randomWant * money;
                SendPlayerText(pInfo[playerid][pPhoneNumber], "The cash is behind the bins, leave the weed there! I'll be there in 2!", 0);
                GivePlayerMoney(playerid, giveMoney);
                pInfo[playerid][pCash] += giveMoney;
                format(string, sizeof(string), "[SERVER]:{FFFFFF} You have sold %d/grams of weed for $%d!", randomWant, giveMoney);
                SendClientMessage(playerid, SERVERCOLOR, string);

                drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);

                return 1;
            }
            if(availabletobuy == 2){
                // only got coke
                new string[256], giveMoney, money, randomWant;
                randomWant = random(pInfo[playerid][pCokeAmount] - 1) + 1;
                money = drugInfo[1][drugPrice] - (20 / 100 * drugInfo[1][drugPrice]);            
                giveMoney = randomWant * money;
                SendPlayerText(pInfo[playerid][pPhoneNumber], "The cash is behind the bins, leave the coke there! I'll be there in 2!", 0);
                GivePlayerMoney(playerid, giveMoney);
                pInfo[playerid][pCash] += giveMoney;
                format(string, sizeof(string), "[SERVER]:{FFFFFF} You have sold %d/grams of coke for $%d!", randomWant, giveMoney);
                SendClientMessage(playerid, SERVERCOLOR, string);

                drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);

                return 1;
            }
            if(availabletobuy == 3){
                // has both.
                new randsel;
                randsel = random(2 - 1) + 1;
                drugDealTimer[playerid] = SetTimerEx("BeginDrugDealing", 300000, false, "d", playerid);

                if(randsel == 1){                    
                    new string[256], giveMoney, money, randomWant;
                    randomWant = random(pInfo[playerid][pCokeAmount] - 1) + 1;
                    money = drugInfo[0][drugPrice] - (20 / 100 * drugInfo[0][drugPrice]);
                    giveMoney = randomWant * money;
                    SendPlayerText(pInfo[playerid][pPhoneNumber], "The cash is behind the bins, leave the weed there! I'll be there in 2!", 0);
                    GivePlayerMoney(playerid, giveMoney);
                    pInfo[playerid][pCash] += giveMoney;
                    format(string, sizeof(string), "[SERVER]:{FFFFFF} You have sold %d/grams of weed for $%d!", randomWant, giveMoney);
                    SendClientMessage(playerid, SERVERCOLOR, string);
                                

                }
                if(randsel == 2){                    
                    new string[256], giveMoney, money, randomWant;
                    randomWant = random(pInfo[playerid][pCokeAmount] - 1) + 1;
                    money = drugInfo[1][drugPrice] - (20 / 100 * drugInfo[1][drugPrice]);
                    giveMoney = randomWant * money;
                    SendPlayerText(pInfo[playerid][pPhoneNumber], "The cash is behind the bins, leave the coke there! I'll be there in 2!", 0);
                    GivePlayerMoney(playerid, giveMoney);
                    pInfo[playerid][pCash] += giveMoney;
                    format(string, sizeof(string), "[SERVER]:{FFFFFF} You have sold %d/grams of coke for $%d!", randomWant, giveMoney);
                    SendClientMessage(playerid, SERVERCOLOR, string);
                }
                return 1;
            }
            return 1;
        }
    }

    if(checkpointid == policeCall[playerid]){
        if(pInfo[playerid][pFactionId] == 1 || pInfo[playerid][pFactionId] == 2)
        {
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pFactionId] == 1 || pInfo[i][pFactionId] == 2){
                    new string[256];
                    format(string, sizeof(string), "Radio: %s %s has arrived on the scene, over.", pInfo[playerid][pFactionRankname], RPName(playerid));
                    SendClientMessage(playerid, -1, string);
                    pInfo[playerid][pFactionPay] += 50;
                    DestroyDynamicCP(policeCall[playerid]);
                }
            }
        }
        return 1;
    }
    if(checkpointid == towingCall[playerid]){
        if(pInfo[playerid][pFactionId] == 3)
        {
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pFactionId] == 3){
                    new string[256];
                    format(string, sizeof(string), "Radio: %s %s has arrived to the towing call, over.", pInfo[playerid][pFactionRankname], RPName(playerid));
                    SendClientMessage(playerid, -1, string);
                    pInfo[playerid][pFactionPay] += 50;
                    DestroyDynamicCP(towingCall[playerid]);
                }
            }
        }
        return 1;
    }
    return 1;
}

forward public AlertPolice(playerid, message[50], Float:cX, Float:cY, Float:cZ);
public AlertPolice(playerid, message[50], Float:cX, Float:cY, Float:cZ){
    new string[256];
    pInfo[playerid][pAlertCall] = 1;
    format(pInfo[playerid][pAlertMsg], 80, "%s", message);

    for(new i = 0; i < MAX_PLAYERS; i++){
        if(pInfo[i][pFactionId] == 1){ // if player is a police officer
            format(string, sizeof(string), "{FFFFFF}Radio: ALERT: %s, call code: %d", message, playerid);
            printf("Officer alerted with msg: %s", message);
            SendClientMessage(i, SERVERCOLOR, string);
        }
    }
    return 1;
}

forward public AlertMedics(playerid, message[50], address, Float:cX, Float:cY, Float:cZ);
public AlertMedics(playerid, message[50],address, Float:cX, Float:cY, Float:cZ){
    new string[256];
    if(playerid == 9999){
        for(new i = 0; i < MAX_PLAYERS; i++){
            if(pInfo[i][pFactionId] == 2){ // if player is a police officer
                format(string, sizeof(string), "{FFFFFF}Radio: ALERT: %s, call code: %d", message, address);
                printf("Medics alerted with msg: %s", message);
                SendClientMessage(i, SERVERCOLOR, string);
            }
        }
    } else {
        pInfo[playerid][pAlertCall] = 2;
        format(pInfo[playerid][pAlertMsg], 80, "%s", message);

        for(new i = 0; i < MAX_PLAYERS; i++){
            if(pInfo[i][pFactionId] == 2){ // if player is a police officer
                format(string, sizeof(string), "{FFFFFF}Radio: ALERT: %s, call code: %d", message, playerid);
                printf("Medics alerted with msg: %s", message);
                SendClientMessage(i, SERVERCOLOR, string);
            }
        }
    }
    return 1;
}

CMD:listallcalls(playerid, params[]){
    if(pInfo[playerid][pFactionId] == 1 || pInfo[playerid][pFactionId] == 2 || pInfo[playerid][pFactionId] == 3 || pInfo[playerid][pFactionId] == 4){
        new string[256], substring[256];
        new firestr[256], subfirstr[256];
        new available, firav;
        
        available = 0;

        SendClientMessage(playerid, SPECIALORANGE, "**-----AVAILABLE CALLS-----**");
        if(pInfo[playerid][pFactionId] == 1){
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pAlertCall] == 1){
                    format(substring, sizeof(substring), "Call code: %d, ", i);
                    strcat(string, substring);
                    available++;
                }
            }
        }
        if(pInfo[playerid][pFactionId] == 2){
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pAlertCall] == 2){
                    format(substring, sizeof(substring), "Call code: %d, ", i);
                    strcat(string, substring);
                    available++;
                }
            }

            if(sInfo[0][firePutOut] != 1){
                if(sInfo[0][lastFireType] == 1){
                    //Last stated fire was a faction fire...
                    for(new i = 0; i < loadedFac; i++){
                        if(fInfo[i][OnFire] == 1){
                            format(subfirstr, sizeof(subfirstr), "Fire call: %d", fInfo[i][fAddress]);
                            strcat(firestr, subfirstr);
                            firav++;
                        }
                    }

                }
                if(sInfo[0][lastFireType] == 2){
                    //Last stated fire was a business fire...
                    for(new i = 0; i < loadedBus; i++){
                        if(bInfo[i][OnFire] == 1){
                            format(subfirstr, sizeof(subfirstr), "Fire call: %d", bInfo[i][bAddress]);
                            strcat(firestr, subfirstr);
                            firav++;
                        }
                    }
                    
                }
                if(sInfo[0][lastFireType] == 3){
                    //Last stated fire was a house fire...
                    for(new i = 0; i < loadedHouse; i++){
                        if(hInfo[i][OnFire] == 1){
                            format(subfirstr, sizeof(subfirstr), "Fire call: %d", hInfo[i][hAddress]);
                            strcat(firestr, subfirstr);
                            firav++;
                        }
                    }
                }
                if(firav >= 1){
                SendClientMessage(playerid, SERVERCOLOR, firestr);
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "No fire calls available.");
                }
            } else {            
                SendClientMessage(playerid, SERVERCOLOR, "No fire calls available.");
            }
        }
        if(pInfo[playerid][pFactionId] == 3){
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pAlertCall] == 3){
                    format(substring, sizeof(substring), "Call code: %d, ", i);
                    strcat(string, substring);
                    available++;
                }
            }
        }
        if(pInfo[playerid][pFactionId] == 4){
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pAlertCall] == 4){
                    format(substring, sizeof(substring), "Call code: %d, ", i);
                    strcat(string, substring);
                    available++;
                }
            }
        }
        if(available >= 1) {
            SendClientMessage(playerid, SERVERCOLOR, string);
        } else {
            SendClientMessage(playerid, SERVERCOLOR, "No calls available.");
        }
    }
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid) {
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid) {
    return 1;
}


public OnPlayerEnterDynamicRaceCP(playerid, checkpointid) {
    if(IsPlayerInDynamicRaceCP(playerid, busCheckpoint[playerid])) {
        new classicLength = sizeof(ClassicStops);
        new reversedLength = sizeof(FortCarsonLoopStops);
        new expressLength = sizeof(ExpressStops);
        new vehid = GetPlayerVehicleID(playerid);
        if(GetVehicleModel(vehid) == 431 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) { // dont do anything if not in this vehicle & NOT THE DRIVER.
            if(routeId[playerid] == 1) {
                if(pInfo[playerid][busStopState] < classicLength) {
                    pInfo[playerid][busStopState] += 1; // increase;

                    if(pInfo[playerid][busStopState] == classicLength - 1) {
                        DestroyDynamicRaceCP(busCheckpoint[playerid]);
                        pInfo[playerid][busStopState] = classicLength;
                        busCheckpoint[playerid] = CreateDynamicRaceCP(0, ClassicStops[pInfo[playerid][busStopState] - 1][0], ClassicStops[pInfo[playerid][busStopState] - 1][1], ClassicStops[pInfo[playerid][busStopState] - 1][2], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1); // select LAST checkpoint
                        TogglePlayerControllable(playerid, false);
                        SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                        return 1;
                    }
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(0, ClassicStops[pInfo[playerid][busStopState]][0], ClassicStops[pInfo[playerid][busStopState]][1], ClassicStops[pInfo[playerid][busStopState]][2], ClassicStops[pInfo[playerid][busStopState] + 1][0], ClassicStops[pInfo[playerid][busStopState] + 1][1], ClassicStops[pInfo[playerid][busStopState] + 1][2], 2.75, -1, -1, -1, 10000, -1);
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    return 1;
                }
                if(pInfo[playerid][busStopState] == classicLength) { // if is EQUAL to length -1 
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(1, jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1);
                    pInfo[playerid][busStopState] = classicLength + 1;
                    return 1;
                }
                if(pInfo[playerid][busStopState] > classicLength) {
                    new string[256];
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    pInfo[playerid][pJobPay] += RoutePay[routeId[playerid] - 1];
                    pInfo[playerid][busStopState] = 0;
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 2500, false, "d", playerid);
                    format(string, sizeof(string), "Thank you for completing this route!\n\nTo select another route, please type:/route and select another route!!\n\nYou will receive $%d on your next paycheck!", RoutePay[routeId[playerid] - 1]);
                    Dialog_Show(playerid, DIALOG_ROUTEFINISHED, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");

                    return 1;
                }
            }
            if(routeId[playerid] == 2) {
                if(pInfo[playerid][busStopState] < reversedLength) {
                    pInfo[playerid][busStopState] += 1; // increase;

                    if(pInfo[playerid][busStopState] == reversedLength - 1) {
                        DestroyDynamicRaceCP(busCheckpoint[playerid]);
                        pInfo[playerid][busStopState] = reversedLength;
                        busCheckpoint[playerid] = CreateDynamicRaceCP(0, FortCarsonLoopStops[pInfo[playerid][busStopState] - 1][0], FortCarsonLoopStops[pInfo[playerid][busStopState] - 1][1], FortCarsonLoopStops[pInfo[playerid][busStopState] - 1][2], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1); // select LAST checkpoint
                        TogglePlayerControllable(playerid, false);
                        SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                        return 1;
                    }
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(0, FortCarsonLoopStops[pInfo[playerid][busStopState]][0], FortCarsonLoopStops[pInfo[playerid][busStopState]][1], FortCarsonLoopStops[pInfo[playerid][busStopState]][2], FortCarsonLoopStops[pInfo[playerid][busStopState] + 1][0], FortCarsonLoopStops[pInfo[playerid][busStopState] + 1][1], FortCarsonLoopStops[pInfo[playerid][busStopState] + 1][2], 2.75, -1, -1, -1, 10000, -1);
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    return 1;
                }
                if(pInfo[playerid][busStopState] == reversedLength) { // if is EQUAL to length -1 
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(1, jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1);
                    pInfo[playerid][busStopState] = reversedLength + 1;
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    return 1;
                }
                if(pInfo[playerid][busStopState] > reversedLength) {
                    new string[256];
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    pInfo[playerid][pJobPay] += RoutePay[routeId[playerid] - 1];
                    pInfo[playerid][busStopState] = 0;
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 2500, false, "d", playerid);
                    format(string, sizeof(string), "Thank you for completing this route!\n\nTo select another route, please type:/route and select another route!!\n\nYou will receive $%d on your next paycheck!", RoutePay[routeId[playerid] - 1]);
                    Dialog_Show(playerid, DIALOG_ROUTEFINISHED, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");
                    return 1;
                }
            }
            if(routeId[playerid] == 3) {
                if(pInfo[playerid][busStopState] < expressLength) {
                    pInfo[playerid][busStopState] += 1; // increase;

                    if(pInfo[playerid][busStopState] == expressLength - 1) {
                        DestroyDynamicRaceCP(busCheckpoint[playerid]);
                        pInfo[playerid][busStopState] = expressLength;
                        busCheckpoint[playerid] = CreateDynamicRaceCP(0, ExpressStops[pInfo[playerid][busStopState] - 1][0], ExpressStops[pInfo[playerid][busStopState] - 1][1], ExpressStops[pInfo[playerid][busStopState] - 1][2], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1); // select LAST checkpoint
                        TogglePlayerControllable(playerid, false);
                        SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                        return 1;
                    }
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(0, ExpressStops[pInfo[playerid][busStopState]][0], ExpressStops[pInfo[playerid][busStopState]][1], ExpressStops[pInfo[playerid][busStopState]][2], ExpressStops[pInfo[playerid][busStopState] + 1][0], ExpressStops[pInfo[playerid][busStopState] + 1][1], ExpressStops[pInfo[playerid][busStopState] + 1][2], 2.75, -1, -1, -1, 10000, -1);
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    return 1;
                }
                if(pInfo[playerid][busStopState] == expressLength) { // if is EQUAL to length -1 
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    busCheckpoint[playerid] = CreateDynamicRaceCP(1, jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], jInfo[2][jobIX], jInfo[2][jobIY], jInfo[2][jobIZ], 2.75, -1, -1, -1, 10000, -1);
                    pInfo[playerid][busStopState] = expressLength + 1;
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 7500, false, "d", playerid);
                    return 1;
                }
                if(pInfo[playerid][busStopState] > expressLength) {
                    // must be finished.
                    new string[256];
                    DestroyDynamicRaceCP(busCheckpoint[playerid]);
                    pInfo[playerid][pJobPay] += RoutePay[routeId[playerid] - 1];
                    pInfo[playerid][busStopState] = 0;
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 2500, false, "d", playerid);
                    format(string, sizeof(string), "Thank you for completing this route!\n\nTo select another route, please type:/route and select another route!!\n\nYou will receive $%d on your next paycheck!", RoutePay[routeId[playerid] - 1]);
                    Dialog_Show(playerid, DIALOG_ROUTEFINISHED, DIALOG_STYLE_MSGBOX, "Job Complete!", string, "Continue", "");
                    return 1;
                }
            }
        } else {
            SendClientMessage(playerid, ADMINBLUE, "[SERVER]:{FFFFFF} You must be in a bus to collect this checkpoint!");
            return 1;
        }
    }
    return 1;
}

forward public UnfreezeAfterTime(target);
public UnfreezeAfterTime(target) {
    TogglePlayerControllable(target, true);
    return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid) {
    return 1;
}

public OnRconCommand(cmd[]) {
    return 1;
}

public OnPlayerRequestSpawn(playerid) {
    return 1;
}

public OnObjectMoved(objectid) {
    return 1;
}

public OnPlayerObjectMoved(playerid, objectid) {
    return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid) {
    if(pickupid == dumpPickup) {
        if(pInfo[playerid][pJobId] == 2) {
            GameTextForPlayer(playerid, "/dump", 3000, 5);
            return 1;
        }
    }
    return 1;
}

forward public CheckFaction(playerid);
public CheckFaction(playerid){
    for(new i = 0; i < loadedFac; i++){
        if(IsPlayerInRangeOfPoint(playerid, 3, fInfo[i][fInfoX], fInfo[i][fInfoY], fInfo[i][fInfoZ])){
            new facname[32], facadd[32], facleader[32], factype[32], facprice[32];

            format(facname, sizeof(facname), "%s", fInfo[i][fName]);
            PlayerTextDrawSetString(playerid, addressNameString[playerid], facname);

            format(facadd, sizeof(facadd), "%d.Street", fInfo[i][fAddress]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][0], facadd);

            if(!strcmp(fInfo[i][fLeader], "NULL", true)){
                format(facleader, sizeof(facleader), "For Sale");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], facleader);
            }
            if(strcmp(fInfo[i][fLeader], "NULL", true)){
                format(facleader, sizeof(facleader), "Sold");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], facleader);
            }
            
            format(factype, sizeof(factype), "Faction");
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][2], factype);
                
            format(facprice, sizeof(facprice), "$%d", fInfo[i][fPrice]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][3], facprice);
            
            PlayerTextDrawShow(playerid, businessBox[playerid]);
            PlayerTextDrawShow(playerid, addressName[playerid]);
            PlayerTextDrawShow(playerid, addressString[playerid]);
            PlayerTextDrawShow(playerid, addressStatus[playerid]);
            PlayerTextDrawShow(playerid, addressType[playerid]);
            PlayerTextDrawShow(playerid, addressPrice[playerid]);

            PlayerTextDrawShow(playerid, PlayerAddress[playerid][0]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][1]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][2]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][3]);
            PlayerTextDrawShow(playerid, addressNameString[playerid]);
                
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
            return 1;
        }
    }
    return 1;
}

forward public CheckBusiness(playerid);
public CheckBusiness(playerid){
    for(new i = 0; i < loadedBus; i++){
        if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bInfoX],bInfo[i][bInfoY], bInfo[i][bInfoZ])){
            new busName[32], busAdd[32], busOwner[32], busType[32], busPrice[32];

            format(busName, sizeof(busName), "%s", bInfo[i][bName]);
            PlayerTextDrawSetString(playerid, addressNameString[playerid], busName);

            format(busAdd, sizeof(busAdd), "%d.Street", bInfo[i][bAddress]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][0], busAdd);

            if(!strcmp(bInfo[i][bOwner], "NULL", true)){
                format(busOwner, sizeof(busOwner), "For Sale");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], busOwner);
            }
            if(strcmp(bInfo[i][bOwner], "NULL", true)){
                format(busOwner, sizeof(busOwner), "Sold");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], busOwner);
            }
                
            format(busType, sizeof(busType), "Business");
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][2], busType);
                
            format(busPrice, sizeof(busPrice), "$%d", bInfo[i][bPrice]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][3], busPrice);
                
            PlayerTextDrawShow(playerid, businessBox[playerid]);
            PlayerTextDrawShow(playerid, addressName[playerid]);
            PlayerTextDrawShow(playerid, addressString[playerid]);
            PlayerTextDrawShow(playerid, addressStatus[playerid]);
            PlayerTextDrawShow(playerid, addressType[playerid]);
            PlayerTextDrawShow(playerid, addressPrice[playerid]);

            PlayerTextDrawShow(playerid, PlayerAddress[playerid][0]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][1]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][2]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][3]);
            PlayerTextDrawShow(playerid, addressNameString[playerid]);
                
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
            return 1;
        }
        if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ])){ // display entrance stuff
            TextDrawShowForPlayer(playerid, accessDoor);
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
        }
        if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ])){ // display entrance stuff
            TextDrawShowForPlayer(playerid, accessDoor);
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
        }
        if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){ // display entrance stuff
            TextDrawShowForPlayer(playerid, accessDoor);
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
        }
    }
    return 1;
}

forward public CheckHouse(playerid);
public CheckHouse(playerid){
    for(new hi = 0; hi < loadedHouse; hi++){
        if(IsPlayerInRangeOfPoint(playerid,3, hInfo[hi][hInfoX], hInfo[hi][hInfoY], hInfo[hi][hInfoZ])){
            new houseAdd[32], houseOwner[32], houseType[32], housePrice[32];

            format(houseAdd, sizeof(houseAdd), "%d.Street", hInfo[hi][hAddress]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][0], houseAdd);

            if(!strcmp(hInfo[hi][hOwner], "NULL", true)){
                format(houseOwner, sizeof(houseOwner), "For Sale");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], houseOwner);
            }
            if(strcmp(hInfo[hi][hOwner], "NULL", true)){
                format(houseOwner, sizeof(houseOwner), "Sold");
                PlayerTextDrawSetString(playerid, PlayerAddress[playerid][1], houseOwner);
            }
                
            format(houseType, sizeof(houseType), "House");
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][2], houseType);
                
            format(housePrice, sizeof(housePrice), "$%d", hInfo[hi][hPrice]);
            PlayerTextDrawSetString(playerid, PlayerAddress[playerid][3], housePrice);

            PlayerTextDrawShow(playerid, addressBox[playerid]);
            PlayerTextDrawShow(playerid, addressString[playerid]);
            PlayerTextDrawShow(playerid, addressStatus[playerid]);
            PlayerTextDrawShow(playerid, addressType[playerid]);
            PlayerTextDrawShow(playerid, addressPrice[playerid]);

            PlayerTextDrawShow(playerid, PlayerAddress[playerid][0]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][1]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][2]);
            PlayerTextDrawShow(playerid, PlayerAddress[playerid][3]);
                
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
            
            return 1;
        }
        
        if(IsPlayerInRangeOfPoint(playerid, 3, hInfo[hi][hEntX], hInfo[hi][hEntY], hInfo[hi][hEntZ])){ // display entrance stuff
            TextDrawShowForPlayer(playerid, accessDoor);
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
            return 1;
        }
        if(IsPlayerInRangeOfPoint(playerid, 3, hInfo[hi][hEntX], hInfo[hi][hEntY], hInfo[hi][hEntZ])){ // display entrance stuff
            TextDrawShowForPlayer(playerid, accessDoor);
            SetTimerEx("RemoveTextdrawAfterTime", 4000, false, "d", playerid);
            return 1;
        }
    }
    return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid) { // check if player picked up pickup
    if(pickupid == jobPickup[pickupid - 1]) {
        if(pInfo[playerid][pJobId] == jobPickup[pickupid - 1]) {
            if(pInfo[playerid][pJobId] == 1) {
                GameTextForPlayer(playerid, "/takepost", 3000, 5);
                return 1;
            }
            if(pInfo[playerid][pJobId] == 2) {
                GameTextForPlayer(playerid, "/startjob", 3000, 5);
                return 1;
            }
            return 1;
        }
        if(pInfo[playerid][pJobId] == 0) {
            GameTextForPlayer(playerid, "/takejob", 3000, 5);
            return 1;
        }
    } else { 
        CheckBusiness(playerid);
        CheckHouse(playerid);
        CheckFaction(playerid);
    }
    return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid) {
    return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid) {
    return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2) {
    return 1;
}

forward public AssignPlayerPhoneNumber(playerid);
public AssignPlayerPhoneNumber(playerid){
    new n1[2],n2[2],n3[3],n4[4],n5[5], n6[6], phonestring[32];
    format(n1, sizeof(n1), "%d", random(9 - 1) + 1);
    strcat(phonestring, n1);
    format(n2, sizeof(n2), "%d", random(9 - 1) + 1);
    strcat(phonestring, n2);
    format(n3, sizeof(n3), "%d", random(9 - 1) + 1);
    strcat(phonestring, n3);
    format(n4, sizeof(n4), "%d", random(9 - 1) + 1);
    strcat(phonestring, n4);
    format(n5, sizeof(n5), "%d", random(9 - 1) + 1);
    strcat(phonestring, n5);    
    format(n6, sizeof(n6), "%d", random(9 - 1) + 1);
    strcat(phonestring, n6);
    pInfo[playerid][pPhoneNumber] = strval(phonestring);
    printf("** [INFO] New player number: %d saved.", strval(phonestring));
    return 1;
}

public OnPlayerSelectedMenuRow(playerid, row) {
    new Menu:currentMenu = GetPlayerMenu(playerid);
    // BUS DRIVER MENU
    if(currentMenu == busdrivermenu) {
        switch (row) {
            case 0:{
                SendClientMessage(playerid, ADMINBLUE, "> You have started the Classic bus route.");
                TogglePlayerControllable(playerid, true);
                BeginSelectedBusRoute(playerid, 1);
                pInfo[playerid][CurrentState] = 1;
            }
            case 1:{
                SendClientMessage(playerid, ADMINBLUE, "> You have started the Fort Carson Loop bus route.");
                TogglePlayerControllable(playerid, true);
                BeginSelectedBusRoute(playerid, 2);
                pInfo[playerid][CurrentState] = 1;
            }
            case 2:{
                SendClientMessage(playerid, ADMINBLUE, "> You have started the Express bus route.");
                TogglePlayerControllable(playerid, true);
                BeginSelectedBusRoute(playerid, 3);
                pInfo[playerid][CurrentState] = 1;
            }
        }
    }
    if(currentMenu == hardwaremenu){
        switch(row){
            case 0:{
                // phones menu
                ShowMenuForPlayer(phonemenu, playerid);
            }
            case 1:{
                // gps menu
                ShowMenuForPlayer(gpsmenu, playerid);
            }
        }
    }
    if(currentMenu == phonemenu){
        new string[256];
        switch(row){
            case 0: {
                //nokia
                if(GetPlayerMoney(playerid) >= 150){
                    AssignPlayerPhoneNumber(playerid);
                    format(string, sizeof(string), "> You have purchased a Nokia, your new phone number is: %d", pInfo[playerid][pPhoneNumber]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPhoneModel] = 1;
                    GivePlayerMoney(playerid, -150);
                    
                    pInfo[playerid][pCash] -= 150;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 150;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
            }
            case 1: {
                //LG
                if(GetPlayerMoney(playerid) >= 180){
                    AssignPlayerPhoneNumber(playerid);
                    format(string, sizeof(string), "> You have purchased a LG, your new phone number is: %d", pInfo[playerid][pPhoneNumber]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPhoneModel] = 2;
                    GivePlayerMoney(playerid, -180);
                    pInfo[playerid][pCash] -= 180;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 180;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
            }
            case 2: {
                //Sony
                if(GetPlayerMoney(playerid) >= 200){
                    AssignPlayerPhoneNumber(playerid);
                    format(string, sizeof(string), "> You have purchased a LG, your new phone number is: %d", pInfo[playerid][pPhoneNumber]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPhoneModel] = 3;
                    GivePlayerMoney(playerid, -200);
                    pInfo[playerid][pCash] -= 200;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 200;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
            }
            case 3: {
                //Samsung
                if(GetPlayerMoney(playerid) >= 250){                    
                    AssignPlayerPhoneNumber(playerid);
                    format(string, sizeof(string), "> You have purchased a Samsung, your new phone number is: %d", pInfo[playerid][pPhoneNumber]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPhoneModel] = 4;
                    GivePlayerMoney(playerid, -250);                    
                    pInfo[playerid][pCash] -= 250;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 250;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
            }
            case 4: {
                //ifruit X
                if(GetPlayerMoney(playerid) >= 300){                                 
                    AssignPlayerPhoneNumber(playerid);
                    format(string, sizeof(string), "> You have purchased an iFruit X, your new phone number is: %d", pInfo[playerid][pPhoneNumber]);
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pPhoneModel] = 5;
                    GivePlayerMoney(playerid, -300);
                    pInfo[playerid][pCash] -= 300;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 300;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
            }
        }
    }
    if(currentMenu == gpsmenu){
        new string[256];
        switch(row){
            case 0: { // tomtom
                if(GetPlayerMoney(playerid) >= 400){
                    format(string, sizeof(string), "> You have purchased a TomTom GPS!");
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pGpsModel] = 1;
                    GivePlayerMoney(playerid, -400);
                    pInfo[playerid][pCash] -= 400;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 400;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(gpsmenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this GPS! Choose another.");
                }
            }
            case 1: { // goclever
                if(GetPlayerMoney(playerid) >= 280){
                    format(string, sizeof(string), "> You have purchased a GoClever GPS!");
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pGpsModel] = 2;
                    GivePlayerMoney(playerid, -280);
                    pInfo[playerid][pCash] -= 280;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 280;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(gpsmenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this GPS! Choose another.");
                }
            }
            case 2: { // navroad
                if(GetPlayerMoney(playerid) >= 310){
                    format(string, sizeof(string), "> You have purchased a NavRoad GPS!");
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pGpsModel] = 3;
                    GivePlayerMoney(playerid, -310);
                    pInfo[playerid][pCash] -= 310;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 310;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(gpsmenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this GPS! Choose another.");
                }
            }            
            case 3: { // GARMIN
                if(GetPlayerMoney(playerid) >= 410){
                    format(string, sizeof(string), "> You have purchased a GARMIN GPS!");
                    SendClientMessage(playerid, ADMINBLUE, string);
                    pInfo[playerid][pGpsModel] = 3;
                    GivePlayerMoney(playerid, -410);
                    pInfo[playerid][pCash] -= 410;
                    TogglePlayerControllable(playerid, 1);
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 310;
                        }
                    }
                    return 1;
                } else {
                    ShowMenuForPlayer(gpsmenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this GPS! Choose another.");
                }
            }
        }
    }
    if(currentMenu == AmmunationMenu){
        switch(row)
        {
            case 0:
            {
                ShowMenuForPlayer(Pistols, playerid);
            }
            case 1:
            {
                ShowMenuForPlayer(SMGS, playerid);
            }
            case 2:
            {
                ShowMenuForPlayer(shotguns, playerid);
            }
            case 3:
            {
                ShowMenuForPlayer(Rifles, playerid);
            }
            case 4:
            {
                ShowMenuForPlayer(Armour, playerid);
            }
        }
    }
    if(currentMenu == Pistols){
        switch(row)
        {
            case 0:
            {
                if(GetPlayerMoney(playerid) >= 750){
                    GivePlayerWeapon(playerid, 22, 50);
                    GivePlayerMoney(playerid, -750);
                    pInfo[playerid][pCash] -= 750;
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a new Glock 18 with 50 bullets!");
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 750;
                            return 1;
                        }
                    }
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    return 1;
                }
            }
            case 1:
            {
                // deagle
                if(GetPlayerMoney(playerid) >= 1250){
                    GivePlayerWeapon(playerid, 24, 32);
                    GivePlayerMoney(playerid, -1250);                    
                    pInfo[playerid][pCash] -= 1250;
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a new Desert Eagle with 32 bullets!");
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 1250;
                            return 1;
                        }
                    }
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    return 1;
                }
            }
        }
    }
    if(currentMenu == SMGS){
        switch(row){
            case 0: {
                if(GetPlayerMoney(playerid) >= 5000){
                    GivePlayerWeapon(playerid, 29, 64);
                    GivePlayerMoney(playerid, -5000);
                    pInfo[playerid][pCash] -= 5000;
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a new MP5 with 64 bullets!");
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 1250;
                            return 1;
                        }
                    }
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    return 1;
                }
            }
        }
    }
    if(currentMenu == shotguns){
        switch(row)
        {
            case 0:
            {
                if(GetPlayerMoney(playerid) >= 3000){
                    GivePlayerWeapon(playerid, 25, 18);
                    GivePlayerMoney(playerid, -3000);
                    pInfo[playerid][pCash] -= 3000;
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a new Shotgun with 18 bullets!");  
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 3000;
                            return 1;
                        }
                    }
                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    return 1;
                }
            }
        }
    }
    if(currentMenu == Rifles){
        switch(row)
        {
            case 0:
            {
                // rifle
                if(GetPlayerMoney(playerid) >= 4500){
                    GivePlayerWeapon(playerid, 33, 15);
                    GivePlayerMoney(playerid, -4500);
                    pInfo[playerid][pCash] -= 4500;
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a new Rifle with 15 bullets!");
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 4500;
                            return 1;
                        }
                    }

                    return 1;
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                    return 1;
                }
            }
        }
    }
    if(currentMenu == Armour){
        switch(row)
        {
            case 0:
            {
                //Your Code Here
            }
            case 1:
            {
                //Your Code Here
            }
        }
    }
    return 1;
}

forward public BeginSelectedBusRoute(playerid, route);
public BeginSelectedBusRoute(playerid, route) {
    if(route == 1) {
        pInfo[playerid][busStopState] = 0;
        routeId[playerid] = route;
        busCheckpoint[playerid] = CreateDynamicRaceCP(0, ClassicStops[0][0], ClassicStops[0][1], ClassicStops[0][2], ClassicStops[1][0], ClassicStops[1][1], ClassicStops[1][2], 2.75, -1, -1, -1, 10000, -1);
        return 1;
    }
    if(route == 2) {
        pInfo[playerid][busStopState] = 0;
        routeId[playerid] = route;
        busCheckpoint[playerid] = CreateDynamicRaceCP(0, FortCarsonLoopStops[0][0], FortCarsonLoopStops[0][1], FortCarsonLoopStops[0][2], FortCarsonLoopStops[1][0], FortCarsonLoopStops[1][1], FortCarsonLoopStops[1][2], 2.75, -1, -1, -1, 10000, -1);
    }
    if(route == 3) {
        pInfo[playerid][busStopState] = 0;
        routeId[playerid] = route;
        busCheckpoint[playerid] = CreateDynamicRaceCP(0, ExpressStops[0][0], ExpressStops[0][1], ExpressStops[0][2], ExpressStops[1][0], ExpressStops[1][1], ExpressStops[1][2], 2.75, -1, -1, -1, 10000, -1);

    }
    return 1;
}

public OnPlayerExitedMenu(playerid)
{
    new Menu:currentMenu = GetPlayerMenu(playerid);
    if(currentMenu == phonemenu){
        ShowMenuForPlayer(hardwaremenu, playerid);
        return 1;
    }
    if(currentMenu == gpsmenu){
        ShowMenuForPlayer(hardwaremenu, playerid);
        return 1;
    }
    if(currentMenu == Pistols){
        ShowMenuForPlayer(AmmunationMenu, playerid);
        return 1;
    }
    if(currentMenu == SMGS){
        ShowMenuForPlayer(AmmunationMenu, playerid);
        return 1;
    }
    if(currentMenu == shotguns){
        ShowMenuForPlayer(AmmunationMenu, playerid);
        return 1;
    }
    if(currentMenu == Rifles){
        ShowMenuForPlayer(AmmunationMenu, playerid);
        return 1;
    }
    if(currentMenu == Armour){
        ShowMenuForPlayer(AmmunationMenu, playerid);
        return 1;
    }
    TogglePlayerControllable(playerid,1); // unfreeze the player when they exit a menu
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
    return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    
    if(newkeys & KEY_SPRINT){
        new i = 0;
        for(i = 0; i < loadedFac; i++){
            if(IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ])){
                TogglePlayerControllable(playerid, false);
                SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);
                SetPlayerInterior(playerid, 1);               
                SetPlayerVirtualWorld(playerid, fInfo[i][fID]);            
                SetPlayerPos(playerid, fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ]);
                return 1;
            }
            if(GetPlayerVirtualWorld(playerid) == fInfo[i][fID] && IsPlayerInRangeOfPoint(playerid, 1.5, fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ])){
                TogglePlayerControllable(playerid, false);
                SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);
                SetPlayerInterior(playerid, 0);               
                SetPlayerVirtualWorld(playerid, 0);            
                SetPlayerPos(playerid, fInfo[i][fEntX], fInfo[i][fEntY], fInfo[i][fEntZ]);
                return 1;
            }
        }
        for(i = 0; i < loadedBus; i++){
            if(IsPlayerInRangeOfPoint(playerid, 1.5, bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ])){
                TogglePlayerControllable(playerid, false);
                SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);
                SetPlayerInterior(playerid, bInfo[i][bIntId]);               
                SetPlayerVirtualWorld(playerid, bInfo[i][bId]);            
                SetPlayerPos(playerid, bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ]);
                return 1;
            }
            if(GetPlayerVirtualWorld(playerid) == bInfo[i][bId] && IsPlayerInRangeOfPoint(playerid, 1.5, bInfo[i][bExitX], bInfo[i][bExitY], bInfo[i][bExitZ])){
                    TogglePlayerControllable(playerid, false);
                    SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);
                    SetPlayerInterior(playerid, 0);               
                    SetPlayerVirtualWorld(playerid, 0);            
                    SetPlayerPos(playerid, bInfo[i][bEntX], bInfo[i][bEntY], bInfo[i][bEntZ]);
                    return 1;
            }
        }
        for(i = 0; i < loadedHouse; i++){
            if(IsPlayerInRangeOfPoint(playerid, 1.5, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ])){       
                if(hInfo[i][hLockedState] == 0){
                    if(hInfo[i][hType] == 5 || hInfo[i][hType] == 2 || hInfo[i][hType] == 1){
                        SetPlayerPos(playerid, hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ]);
                        SetPlayerInterior(playerid, hInfo[i][hType]);               
                        SetPlayerVirtualWorld(playerid, hInfo[i][hId]);            
                        TogglePlayerControllable(playerid, false);
                        SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);  
                    }
                    if(hInfo[i][hType] != 5 && hInfo[i][hType] != 2 && hInfo[i][hType] != 1){
                        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]: Contact administration, reason: House type not set.");
                        //send to admins?
                        return 1;
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This house is locked, you cannot enter!");
                }
                return 1;
            }
            if(GetPlayerVirtualWorld(playerid) == hInfo[i][hId] && IsPlayerInRangeOfPoint(playerid, 3, hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ])){ // and in range of the exit definition                
                TogglePlayerControllable(playerid, false);
                SetTimerEx("UnfreezeAfterTime", 5000, false, "d", playerid);
                SetPlayerPos(playerid, hInfo[i][hEntX], hInfo[i][hEntY], hInfo[i][hEntZ]);
                SetPlayerInterior(playerid, 0); 
                SetPlayerVirtualWorld(playerid, 0);
                return 1;
            }
        }
    }
    if(newkeys & KEY_SECONDARY_ATTACK){
        if(IsPlayerInRangeOfPoint(playerid, 1.5, -2689.0090, 2646.0640, 4086.7952))
        {
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(policeMainDoor, -2689.0090, 2647.3510, 4086.7952, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 1);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1.5, -2081.0562, 2903.3213, 5068.6650)){
            if(pInfo[playerid][pFactionId] == 2){
                MoveDynamicObject(medicsMainDoor, -2081.0413, 2904.2350, 5067.2153, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 8);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1.5, -2666.4624, 2643.0579, 4081.8079)){
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(policeMainCell, -2666.5525, 2640.3953, 4081.6809, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 2);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1, -2664.7583, 2643.6807, 4081.6809)){
            //cell1
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(cell2, -2663.4713, 2643.6807, 4081.6809, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 3);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1, -2658.3540, 2643.6592, 4081.6809)){
            //cell2
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(cell2,-2657.1840, 2643.6592, 4081.6809, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 4);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1, -2658.3525, 2640.1721, 4081.6809)){
            //cell3
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(cell3,-2657.1825, 2640.1721, 4081.6809, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 5);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
        if(IsPlayerInRangeOfPoint(playerid, 1, -2664.7888, 2640.1489, 4081.6809)){
            //cell4
            if(pInfo[playerid][pFactionId] == 1){
                MoveDynamicObject(cell4,-2663.4829, 2640.1558, 4081.6809, 2000);
                SetTimerEx("MoveObjBack", 5000, false, "d", 6);
                ApplyAnimation(playerid, "HEIST9", "Use_SwipeCard", 10.0, 0, 0, 0, 0, 0);
            }
        }
    }
    if(newkeys & KEY_SUBMISSION){
        if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 525){
			new Float:pX,Float:pY,Float:pZ;
			GetPlayerPos(playerid,pX,pY,pZ);
			new Float:vX,Float:vY,Float:vZ;
			new Found=0;
			new vid=0;
            while((vid<MAX_VEHICLES)&&(!Found))
   			{
   				vid++;
   				GetVehiclePos(vid,vX,vY,vZ);
   				if  ((floatabs(pX-vX)<7.0)&&(floatabs(pY-vY)<7.0)&&(floatabs(pZ-vZ)<7.0)&&(vid!=GetPlayerVehicleID(playerid)))
   			    {
   				    Found=1;
   				    if	(IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid)))
   				    {
   				        DetachTrailerFromVehicle(GetPlayerVehicleID(playerid));
   				    }
   				    AttachTrailerToVehicle(vid,GetPlayerVehicleID(playerid));
   				}
            }
        }
    }
    return 1;
}

forward public MoveObjBack(doorid);
public MoveObjBack(doorid){
    if(doorid == 1){
        MoveDynamicObject(policeMainDoor, -2689.0090, 2646.0640, 4086.7952, 2000);
        return 1;
    }
    if(doorid == 2){
        MoveDynamicObject(policeMainCell, -2666.5525, 2641.7993, 4081.6809, 2000);
    }
    if(doorid == 3){
        MoveDynamicObject(cell1,-2664.7583, 2643.6807, 4081.6809, 2000);
    }
    if(doorid == 4){
        MoveDynamicObject(cell2,-2658.3540, 2643.6592, 4081.6809, 2000);
    }
    if(doorid == 5){
        MoveDynamicObject(cell3,-2658.3525, 2640.1721, 4081.6809, 2000);      

    }
    if(doorid == 6){
        MoveDynamicObject(cell4,-2664.7700, 2640.1558, 4081.6809, 2000);   
    }
    if(doorid == 7) {
        //gate
        MoveDynamicObject(impoundGate, -180.2639, 1010.1957, 18.9288, 8000);
    }
    // 8 = medic
    if(doorid == 8){
        MoveDynamicObject(medicsMainDoor, -2081.0413, 2902.9480, 5067.2153, 2000);
    }
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success) {
    return 1;
}

public OnPlayerUpdate(playerid) {
    new newkeys,l,u;
	GetPlayerKeys(playerid, newkeys, l, u);
	new i;
	if(Holding(KEY_FIRE))
	{
        if(GetPlayerWeapon(playerid) == 42)
        {
            for(i = 0; i<MAX_FIRES; i++)
 	    	{
 	        	if(IsValidFire(i))
 	        	{
 	        	    if(PlayerFaces(playerid, FirePos[i][0],  FirePos[i][1],  FirePos[i][2], 1) && IsPlayerInRangeOfPoint(playerid, 4, FirePos[i][0],  FirePos[i][1],  FirePos[i][2]))
 	        		{
                        new pay;
			    		FireHealth[i]-=2;
					    #if defined Labels
				    		new string[128];
					    	format(string, sizeof(string), "FIRE(%d)\n\n%d/%d", i, FireHealth[i], FireHealthMax[i]);
							Update3DTextLabelText(FireText[i], 0xFFFFFFFF, string);
					    	//Delete3DTextLabel(FireText[i]);
						//FireText[i] = Create3DTextLabel(string, 0xFFFFFFFF, FirePos[i][0],  FirePos[i][1],  FirePos[i][2], 20, 0);
					    #endif
					    if(FireHealth[i] <= 0)
					    {
                            if(pInfo[playerid][pFactionId] == 2){
                                new firehp;
                                firehp = FireHealthMax[i];
                                pay = (firehp / 255) * 100;
                                pInfo[playerid][pFactionPay] += pay;
                                format(string, sizeof(string), "> You have extinguished a fire! (+$%d)", pay);
                                sInfo[0][firePutOut] = 1;
                                SendClientMessage(playerid, ADMINBLUE, string);
							    DeleteFire(i);
                            }
							CallRemoteFunction("OnFireDeath", "dd", i, playerid);
						}
					}
				}
			}
		}
	}
    return 1;
}

public OnPlayerStreamIn(playerid, forplayerid) {
    return 1;
}

public OnPlayerStreamOut(playerid, forplayerid) {
    return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid) {
    return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid) {
    return 1;
}

/* 3- DIALOGS -*/
Dialog:DIALOG_CARDEALER(playerid, response, listitem, inputtext[]){
    
    return 1;
}

Dialog:DIALOG_247(playerid, response, listitem, inputtext[]){
    if(response){
        if(listitem == 0){
            if(pInfo[playerid][pCigAmount] <= 20){ // has got less than 1 pack
                if(GetPlayerMoney(playerid) >= 14){
                    SendClientMessage(playerid, ADMINBLUE, "> You have purchased a pack of 20 cigarettes.");
                    pInfo[playerid][pCigAmount] = 20;
                    GivePlayerMoney(playerid, -14);
                    
                    pInfo[playerid][pCash] -= 14;
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX],bInfo[i][bUseY],bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 14;                            
                            new DB_Query[900];
                            mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bSalary` = '%d' WHERE  `bId` = '%d'", bInfo[i][bSalary], bInfo[i][bId]);
                            mysql_query(db_handle, DB_Query);
                            return 1;
                        }
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                }
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You already have a pack of cigarettes, finish that one first!");
            }
        }
        if(listitem == 1){
            if(GetPlayerMoney(playerid) >= 30){
                pInfo[playerid][pRopeAmount] += 1;
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have purchased a metre of rope!");
                GivePlayerMoney(playerid, -30);
                pInfo[playerid][pCash] -= 30;
                for(new i = 0; i < loadedBus; i++){
                    if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX],bInfo[i][bUseY],bInfo[i][bUseZ])){
                        bInfo[i][bSalary] += 30;                            
                        new DB_Query[900];
                        mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bSalary` = '%d' WHERE  `bId` = '%d'", bInfo[i][bSalary], bInfo[i][bId]);
                        mysql_query(db_handle, DB_Query);
                        return 1;
                    }
                }
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
            }
        }
        if(listitem == 2){
            if(pInfo[playerid][pHasMask] != 1){
                if(GetPlayerMoney(playerid) >= 150){
                    pInfo[playerid][pHasMask] = 1;
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have purchased a mask!");
                    GivePlayerMoney(playerid, -150);
                    pInfo[playerid][pCash] -= 150;
                    for(new i = 0; i < loadedBus; i++){
                        if(IsPlayerInRangeOfPoint(playerid, 5, bInfo[i][bUseX],bInfo[i][bUseY],bInfo[i][bUseZ])){
                            bInfo[i][bSalary] += 150;                            
                            new DB_Query[900];
                            mysql_format(db_handle, DB_Query, sizeof(DB_Query),  "UPDATE `businesses` SET `bSalary` = '%d' WHERE  `bId` = '%d'", bInfo[i][bSalary], bInfo[i][bId]);
                            mysql_query(db_handle, DB_Query);
                            return 1;
                        }
                    }
                } else {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash!");
                }
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You already have a mask!");
            }
        }
        if(listitem == 3){
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Lottery in development. Stay up to date on our forums.");
        }
    }
    return 1;
}

Dialog:DIALOG_ROUTEFINISHED(playerid, response, listitem, inputtext[]) {
    pInfo[playerid][CurrentState] = 0;
    return 1;
}

Dialog:DIALOG_JOB_LIST(playerid, response, listitem, inputtext[]) {
    for (new i = 0; i < loadedJob; i++) {
        if(listitem == jInfo[i][jID] - 1) {
            JobCheckpoint[0] = CreateDynamicCP(jInfo[i][jobIX], jInfo[i][jobIY], jInfo[i][jobIZ], 2, -1, -1, -1, 10000);
            SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} Go to the checkpoint on your minimap to find this job!");
            return 1;
        }
    }
    return 1;
}

Dialog:DIALOG_COLLECT(playerid, response, listitem, inputtext[]) {
    new randomLoc = random(sizeof(RandomGarbageLocations));
    GarbageCheckpoint[0] = CreateDynamicCP(RandomGarbageLocations[randomLoc][0], RandomGarbageLocations[randomLoc][1], RandomGarbageLocations[randomLoc][2], 2, -1, -1, -1, 10000);
    return 1;
}

Dialog:DIALOG_STARTGARBAGE(playerid, response, listitem, inputtext[]) {
    new randomLoc = random(sizeof(RandomGarbageLocations));
    GarbageCheckpoint[0] = CreateDynamicCP(RandomGarbageLocations[randomLoc][0], RandomGarbageLocations[randomLoc][1], RandomGarbageLocations[randomLoc][2], 2, -1, -1, -1, 10000);
    pInfo[playerid][CurrentState] = 1;
    pInfo[playerid][GarbageState] = 0;
    return 1;
}

Dialog:DIALOG_TAKEPOST(playerid, response, listitem, inputtext[]) {
    new randomLoc = random(sizeof(RandomPostLocations));
    PostCheckpoint[0] = CreateDynamicCP(RandomPostLocations[randomLoc][0], RandomPostLocations[randomLoc][1], RandomPostLocations[randomLoc][2], 2, -1, -1, -1, 10000);
    return 1;
}

Dialog:DIALOG_DELIVERPOST(playerid, response, listitem, inputtext[]) {
    DestroyDynamicCP(PostCheckpoint[0]);
    return 1;
}

Dialog:DIALOG_DUMP(playerid, response, listitem, inputtext[]) {
    DestroyDynamicCP(dumpCheckPoint[0]);
    return 1;
}

Dialog:DIALOG_ENDJOB(playerid, response, listitem, inputtext[]) {
    /* begin ending jobs */
    if(response) {
        pInfo[playerid][CurrentState] = 0;
        pInfo[playerid][PostState] = 0;
        pInfo[playerid][GarbageState] = 0;
        pInfo[playerid][busStopState] = 0;
        DestroyDynamicRaceCP(busCheckpoint[playerid]);
        DestroyDynamicCP(PostCheckpoint[0]);
        DestroyDynamicCP(GarbageCheckpoint[0]);
        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have ended your current job and have lost all of your collectables as a result!");
        return 1;
    } else {
        return 1;
    }
}

Dialog:DIALOG_QUIZ1(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // incorrect
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ2, DIALOG_STYLE_LIST, "What does 'OOC' stand for?", "Out of Character\nOut of control\nOcassionally Original Character", "Continue", "Quit");
        }

        if(listitem == 1) { // correct
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct! 'RP' stands for Roleplay!");
            Dialog_Show(playerid, DIALOG_QUIZ2, DIALOG_STYLE_LIST, "What does 'OOC' stand for?", "Out of Character\nOut of control\nOcassionally Original Character", "Continue", "Quit");
        }

        if(listitem == 2) { // incorrect
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ2, DIALOG_STYLE_LIST, "What does 'OOC' stand for?", "Out of Character\nOut of control\nOcassionally Original Character", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}

Dialog:DIALOG_QUIZ2(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // correct
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, 'OOC' stands for Out of Character!");
            Dialog_Show(playerid, DIALOG_QUIZ3, DIALOG_STYLE_LIST, "You see a police officer being shot at by a group of masked people, what do you do?", "Easy! Pull out a gun and begin firing at them.\nI would cautiously move back, to a safe location, and phone the police.\nQuickly steal their car and get away!", "Continue", "Quit");
        }

        if(listitem == 1) { // incorrect        
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ3, DIALOG_STYLE_LIST, "You see a police officer being shot at by a group of masked people, what do you do?", "Easy! Pull out a gun and begin firing at them.\nI would cautiously move back, to a safe location, and phone the police.\nQuickly steal their car and get away!", "Continue", "Quit");
        }

        if(listitem == 2) { // incorrect
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ3, DIALOG_STYLE_LIST, "You see a police officer being shot at by a group of masked people, what do you do?", "Easy! Pull out a gun and begin firing at them.\nI would cautiously move back, to a safe location, and phone the police.\nQuickly steal their car and get away!", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}
Dialog:DIALOG_QUIZ3(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // incorrect    
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ4, DIALOG_STYLE_LIST, "What is bunnyhopping?", "When you roleplay a bunny!\nKilling other players randomly.\nTapping shift to get to places quicker.", "Continue", "Quit");
        }

        if(listitem == 1) { // correct    
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, any other option would've be called:Power Gaming!");
            Dialog_Show(playerid, DIALOG_QUIZ4, DIALOG_STYLE_LIST, "What is bunnyhopping?", "When you roleplay a bunny!\nKilling other players randomly.\nTapping shift to get to places quicker.", "Continue", "Quit");
        }

        if(listitem == 2) { // incorrect
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ4, DIALOG_STYLE_LIST, "What is bunnyhopping?", "When you roleplay a bunny!\nKilling other players randomly.\nTapping shift to get to places quicker.", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}

Dialog:DIALOG_QUIZ4(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // incorrect    
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ5, DIALOG_STYLE_LIST, "What is deathmatching?", "Killing other players randomly; and in some cases, killig others repeatedly for no reason.\nRoleplaying a sucessful murder.\nTalking to the administrators about a bug.", "Continue", "Quit");
        }

        if(listitem == 1) { // incorrect  
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ5, DIALOG_STYLE_LIST, "What is deathmatching?", "Killing other players randomly; and in some cases, killig others repeatedly for no reason.\nRoleplaying a sucessful murder.\nTalking to the administrators about a bug.", "Continue", "Quit");
        }

        if(listitem == 2) { // correct
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, bunny hopping is hitting the shift key to jump and get places quicker! This is against the rules!");
            Dialog_Show(playerid, DIALOG_QUIZ5, DIALOG_STYLE_LIST, "What is deathmatching?", "Killing other players randomly; and in some cases, killig others repeatedly for no reason.\nRoleplaying a sucessful murder.\nTalking to the administrators about a bug.", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}

Dialog:DIALOG_QUIZ5(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // correct    
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, deathmatching is killing another player, without any reason to do so!");
            Dialog_Show(playerid, DIALOG_QUIZ6, DIALOG_STYLE_LIST, "What can /report be used for?", "Reporting another player, without a valid reason.\nReporting a in character crime.\nReporting a player, with a valid reason. For example:reporting a cheater, or bug exploiter.", "Continue", "Quit");
        }

        if(listitem == 1) { // incorrect  
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ6, DIALOG_STYLE_LIST, "What can /report be used for?", "Reporting another player, without a valid reason.\nReporting a in character crime.\nReporting a player, with a valid reason. For example:reporting a cheater, or bug exploiter.", "Continue", "Quit");
        }

        if(listitem == 2) { // incorrect
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ6, DIALOG_STYLE_LIST, "What can /report be used for?", "Reporting another player, without a valid reason.\nReporting a in character crime.\nReporting a player, with a valid reason. For example:reporting a cheater, or bug exploiter.", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}

Dialog:DIALOG_QUIZ6(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // incorrect  
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ7, DIALOG_STYLE_LIST, "Where can I get help for OOC reasons (and talk to the helper team)?", "The command is:/helpme\nThe command is:/pm.\nThe command is:/global.", "Continue", "Quit");
        }

        if(listitem == 1) { // incorrect  
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ7, DIALOG_STYLE_LIST, "Where can I get help for OOC reasons (and talk to the helper team)?", "The command is:/helpme\nThe command is:/pm.\nThe command is:/global.", "Continue", "Quit");
        }

        if(listitem == 2) { // correct
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, The correct usage of /report is to report a player with a valid reason, such as:deathmatching, cheating, bug exploiting ect!");
            Dialog_Show(playerid, DIALOG_QUIZ7, DIALOG_STYLE_LIST, "Where can I get help for OOC reasons (and talk to the helper team)?", "The command is:/helpme\nThe command is:/pm.\nThe command is:/global.", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}


Dialog:DIALOG_QUIZ7(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // correct  
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Correct, if you need help with something in game, please use /helpme to talk to the team!");
            Dialog_Show(playerid, DIALOG_QUIZ8, DIALOG_STYLE_LIST, "What is a bannable offense", "Roleplaying a normal citizen.\nUsing known exploits to gain an advantage.\nFollowing a police officers orders, and pulling over.", "Continue", "Quit");
        }

        if(listitem == 1) { // incorrect  
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ8, DIALOG_STYLE_LIST, "What is a bannable offense", "Roleplaying a normal citizen.\nUsing known exploits to gain an advantage.\nFollowing a police officers orders, and pulling over.", "Continue", "Quit");
        }

        if(listitem == 2) { // correct
            quizAttempts[playerid]++;
            SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Wrong answer!");
            Dialog_Show(playerid, DIALOG_QUIZ8, DIALOG_STYLE_LIST, "What is a bannable offense", "Roleplaying a normal citizen.\nUsing known exploits to gain an advantage.\nFollowing a police officers orders, and pulling over.", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;

}
Dialog:DIALOG_QUIZ8(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) { // correct 
            if(quizAttempts[playerid] >= 3) {
                KickWithMessage(playerid, "{99c0da}[SERVER]:{ABCDEF}You have failed the roleplay test, please visit our site and check the rules for help!");

                return 1;
            } else {
                SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Congratulations, you passed the roleplay test! Please watch the following tutorial to begin!");
                SaveNewPlayerData(playerid, passwordForFinalReg[playerid]);
            }
        }

        if(listitem == 1) { // incorrect  
            quizAttempts[playerid]++;
            if(quizAttempts[playerid] >= 3) {
                KickWithMessage(playerid, "{99c0da}[SERVER]:{ABCDEF}You have failed the roleplay test, please visit our site and check the rules for help!");

                return 1;
            } else {
                SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Congratulations, you passed the roleplay test! Please watch the following tutorial to begin!");
                SaveNewPlayerData(playerid, passwordForFinalReg[playerid]);
            }
        }

        if(listitem == 2) { // correct
            quizAttempts[playerid]++;
            if(quizAttempts[playerid] >= 3) {
                KickWithMessage(playerid, "{99c0da}[SERVER]:{ABCDEF}You have failed the roleplay test, please visit our site and check the rules for help!");

                return 1;
            } else {
                SendClientMessage(playerid, -1, "{99c0da}[SERVER]:{ABCDEF}Congratulations, you passed the roleplay test! Please watch the following tutorial to begin!");
                SaveNewPlayerData(playerid, passwordForFinalReg[playerid]);
            }
        }
    } else {
        Kick(playerid);
    }
    return 1;

}



Dialog:DIALOG_TOOMANYTRIES(playerid, response, listitem, inputtext[]) {
    Kick(playerid);
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[]) {
    SetPlayerPos(playerid, -194.1460, 1262.8966, 49.1071);
    InterpolateCameraPos(playerid, -194.1460, 1262.8966, 49.1071, -215.3474, 1140.1307, 49.1071, 15000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -193.2128, 1262.5261, 48.8320, -214.3721, 1140.3693, 48.9320, 15000, CAMERA_MOVE);

    if(response) {
        bcrypt_hash(inputtext, BCRYPT_COST, "HashPlayerPassword", "d", playerid);
    } else {
        Kick(playerid);
    }
    return 1;
}

Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[]) {
    if(response) {
        new query[256], playerName[MAX_PLAYER_NAME], password[BCRYPT_HASH_LENGTH];
        GetPlayerName(playerid, playerName, sizeof(playerName));

        mysql_format(db_handle, query, sizeof(query), "SELECT `pPassword` from `accounts` WHERE `pName` = '%e'", GetName(playerid));
        mysql_query(db_handle, query);
        cache_get_value(0, "pPassword", password, BCRYPT_HASH_LENGTH);
        bcrypt_check(inputtext, password, "OnPasswordChecked", "d", playerid);
    } else {
        Kick(playerid);
    }
    return 1;
}

Dialog:DIALOG_EMAIL(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(strfind(inputtext, "@", true) != -1) {
            SetPlayerPos(playerid, -596.0942, 943.0540, 37.5432);
            InterpolateCameraPos(playerid, -596.0942, 943.0540, 37.5432, -356.9250, 720.8551, 37.5432, 15000, CAMERA_MOVE);
            InterpolateCameraLookAt(playerid, -595.1951, 943.5001, 37.4531, -356.6473, 721.8198, 37.4981, 15000, CAMERA_MOVE);

            new string[256];
            format(pInfo[playerid][pEmail], 255, inputtext);

            format(string, sizeof(string), "Thanks, your email is:%s\n\nPlease insert your character's country of origin below!", inputtext);
            Dialog_Show(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Character Creation", "Male\nFemale", "Confirm", "");
        } else {
            Dialog_Show(playerid, DIALOG_EMAIL, DIALOG_STYLE_INPUT, "Email Registration", "The inputted string does not contain a:@ symbol! Please retry!\n\n Example:'example@example.com'!", "Continue", "Quit");
        }
    } else {
        Kick(playerid);
    }
    return 1;
}

Dialog:DIALOG_GENDER(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(listitem == 0) {
            pInfo[playerid][pGender] = 1;
            new genderString[150];
            format(genderString, sizeof(genderString), "{ABCDEF}You have selected:Male.\n\
    	     			{ABCDEF}Please, tell us how old your character is (between 18-96 years old).\n\n", pInfo[playerid][pName]);
            Dialog_Show(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Character Creation", genderString, "Register", "Leave");

            SetPlayerSkin(playerid, maleSkins[random(11)]);
            pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
        }
        if(listitem == 1) {
            pInfo[playerid][pGender] = 2;
            new genderString[150];
            format(genderString, sizeof(genderString), "{ABCDEF}You have selected:Female.\n\
    	     			{ABCDEF}Please, tell us how old your character is (between 18-96 years old).\n\n", pInfo[playerid][pName]);
            Dialog_Show(playerid, DIALOG_AGE, DIALOG_STYLE_INPUT, "Character Creation", genderString, "Register", "Leave");
            SetPlayerSkin(playerid, femaleSkins[random(10)]);
            pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
        }

    } else {
        Dialog_Show(playerid, DIALOG_GENDER, DIALOG_STYLE_LIST, "Character Creation", "Male\nFemale", "Confirm", "");
    }
    return 1;
}

Dialog:DIALOG_AGE(playerid, response, listitem, inputtext[]) {
    pInfo[playerid][pAge] = strval(inputtext[0]);

    new String[150], query[256];
    if(strval(inputtext[0]) >= 25) {
        pInfo[playerid][pAge] = strval(inputtext[0]);
        format(String, sizeof(String), "{ABCDEF}Wow, your character is old! You are a:%d year old!\n\
	 				{ABCDEF}Lastly, tell us where your character comes from. (eg:Los Santos or America)\n\n", pInfo[playerid][pAge]);

        Dialog_Show(playerid, DIALOG_REGION, DIALOG_STYLE_INPUT, "Character Creation", String, "Register", "Leave");
    }

    if(strval(inputtext[0]) <= 25) {
        pInfo[playerid][pAge] = strval(inputtext[0]);

        mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pAge` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pAge], GetName(playerid));
        mysql_query(db_handle, query);
        format(String, sizeof(String), "{ABCDEF}I'll need to see some ID please! You are a:%d year old!\n\
	 				{ABCDEF}Lastly, tell us where your character comes from. (eg:Los Santos or America)\n\n", pInfo[playerid][pAge]);
        Dialog_Show(playerid, DIALOG_REGION, DIALOG_STYLE_INPUT, "Character Creation", String, "Register", "Leave");
    }
}

Dialog:DIALOG_REGION(playerid, response, listitem, inputtext[]) {
    new string[256];
    if(response) {
        if(strlen(inputtext) < 1) {
            format(string, sizeof(string), "The inputted text was empty, please input a region below!", inputtext);
            Dialog_Show(playerid, DIALOG_REGION, DIALOG_STYLE_INPUT, "Registration System", string, "Continue", "Quit");
        } else {
            format(pInfo[playerid][pRegion], 32, "%s", inputtext);
            //SaveNewPlayerData(playerid, passwordForFinalReg[playerid]);
            //BeginTutorial(playerid);
            format(string, sizeof(string), "Reallife Play\nRoleplay\nRegistered Player");
            Dialog_Show(playerid, DIALOG_QUIZ1, DIALOG_STYLE_LIST, "What does 'RP' stand for?", string, "Continue", "Quit");
            quizAttempts[playerid] = 0;
        }
    } else {
        Kick(playerid);
    }
    return 1;
}

forward OnPasswordChecked(playerid);
public OnPasswordChecked(playerid) {
    new bool:match = bcrypt_is_equal();
    new string[300];

    if(match) {
        new query[300];
        mysql_format(db_handle, query, sizeof(query), "SELECT * from `accounts` WHERE `pName` = '%e'", GetName(playerid));
        mysql_tquery(db_handle, query, "OnPlayerLoad", "d", playerid);
    } else {
        if(tries[playerid] < 3) {
            tries[playerid]++;
            format(string, sizeof(string), "{FFFFFF} Welcome back to the server {A5EBF6}%s{FFFFFF}!\n\n That password was incorrect, please try again (%d/3)!", GetName(playerid), tries);
            Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login System", string, "Login", "Quit");
        } else {
            tries[playerid] = 0;
            Dialog_Show(playerid, DIALOG_TOOMANYTRIES, DIALOG_STYLE_MSGBOX, "Login System", "Too many login attempts!\n\n Try again later!", "Continue", "");
        }
    }
    return 1;
}

forward OnPlayerLoad(playerid);
public OnPlayerLoad(playerid) {
    cache_get_value_int(0, "ID", pInfo[playerid][ID]);
    cache_get_value(0, "pName", pInfo[playerid][pName], 128);
    cache_get_value(0, "pEmail", pInfo[playerid][pEmail], 128);
    cache_get_value_int(0, "pLevel", pInfo[playerid][pLevel]);
    cache_get_value_int(0, "pExp", pInfo[playerid][pExp]);
    cache_get_value_float(0, "pHealth", pInfo[playerid][pHealth]);
    cache_get_value_float(0, "pArmour", pInfo[playerid][pArmour]);
    cache_get_value(0, "pRegion", pInfo[playerid][pRegion], 32);
    cache_get_value_int(0, "pGender", pInfo[playerid][pGender]);
    cache_get_value_int(0, "pSkin", pInfo[playerid][pSkin]);
    cache_get_value_int(0, "pAge", pInfo[playerid][pAge]);
    cache_get_value_int(0, "pBank", pInfo[playerid][pBank]);
    cache_get_value_int(0, "pCash", pInfo[playerid][pCash]);
    cache_get_value_int(0, "pPayTimer", pInfo[playerid][pPayTimer]);    
    cache_get_value_int(0, "pPhoneNumber", pInfo[playerid][pPhoneNumber]);
    cache_get_value_int(0, "pPhoneModel", pInfo[playerid][pPhoneModel]);
    cache_get_value_int(0, "pGpsModel", pInfo[playerid][pGpsModel]);
    cache_get_value_int(0, "pFactionId", pInfo[playerid][pFactionId]);
    cache_get_value_int(0, "pFactionRank", pInfo[playerid][pFactionRank]);
    cache_get_value(0, "pFactionRankname", pInfo[playerid][pFactionRankname], 32);
    cache_get_value_int(0, "pFactionPay", pInfo[playerid][pFactionPay]);
    cache_get_value_int(0, "pDutyClothes", pInfo[playerid][pDutyClothes]);
    cache_get_value_int(0, "pJobId", pInfo[playerid][pJobId]);
    cache_get_value_int(0, "pJobPay", pInfo[playerid][pJobPay]);
    cache_get_value_int(0, "pWeedAmount", pInfo[playerid][pWeedAmount]);
    cache_get_value_int(0, "pCokeAmount", pInfo[playerid][pCokeAmount]);
    cache_get_value_int(0, "pCigAmount", pInfo[playerid][pCigAmount]);
    cache_get_value_int(0, "pRopeAmount", pInfo[playerid][pRopeAmount]);
    cache_get_value_int(0, "pHasMask", pInfo[playerid][pHasMask]);

    cache_get_value_int(0, "pDrivingLicense", pInfo[playerid][pDrivingLicense]);
    cache_get_value_int(0, "pHeavyLicense", pInfo[playerid][pHeavyLicense]);
    cache_get_value_int(0, "pPilotLicense", pInfo[playerid][pPilotLicense]);
    cache_get_value_int(0, "pGunLicense", pInfo[playerid][pGunLicense]);
    
    cache_get_value_int(0, "pWeaponSlot1", pInfo[playerid][pWeaponSlot1]);
    cache_get_value_int(0, "pWeaponSlot1Ammo", pInfo[playerid][pWeaponSlot1Ammo]);
    cache_get_value_int(0, "pWeaponSlot2", pInfo[playerid][pWeaponSlot2]);
    cache_get_value_int(0, "pWeaponSlot2Ammo", pInfo[playerid][pWeaponSlot2Ammo]);
    cache_get_value_int(0, "pWeaponSlot3", pInfo[playerid][pWeaponSlot3]);
    cache_get_value_int(0, "pWeaponSlot3Ammo", pInfo[playerid][pWeaponSlot3Ammo]);

    cache_get_value_int(0, "pVehicleSlots", pInfo[playerid][pVehicleSlots]);
    cache_get_value_int(0, "pVehicleSlotsUsed", pInfo[playerid][pVehicleSlotsUsed]);

    cache_get_value_int(0, "pFines", pInfo[playerid][pFines]);
    cache_get_value(0, "pMostRecentFine", pInfo[playerid][pMostRecentFine], 32);

    cache_get_value_int(0, "pWantedLevel", pInfo[playerid][pWantedLevel]);
    cache_get_value(0, "pMostRecentWantedReason", pInfo[playerid][pMostRecentWantedReason], 32);

    cache_get_value_int(0, "pInPrisonType", pInfo[playerid][pInPrisonType]);
    cache_get_value_int(0,"pPrisonTimer", pInfo[playerid][pPrisonTimer]);

    cache_get_value_int(0, "pPreferredSpawn", pInfo[playerid][pPreferredSpawn]);

    cache_get_value_int(0, "pAdminLevel", pInfo[playerid][pAdminLevel]);

    pInfo[playerid][LoggedIn] = true;
    SendClientMessage(playerid, -1, "Logged in");
    SetPlayerScore(playerid, pInfo[playerid][pLevel]);
    SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
    SetPlayerArmour(playerid, pInfo[playerid][pArmour]);
    GivePlayerMoney(playerid, pInfo[playerid][pCash]);
    new name[32];
    GetPlayerName(playerid, name, sizeof(name));
    if(pInfo[playerid][pPreferredSpawn] != 0){
        if(pInfo[playerid][pInPrisonType] == 0){
            for(new i = 0; i < loadedHouse; i++){
                if(hInfo[i][hAddress] == pInfo[playerid][pPreferredSpawn]){
                    SetPlayerWantedLevel(playerid, pInfo[playerid][pWantedLevel]);
                    SetPlayerVirtualWorld(playerid, hInfo[i][hId]);    
                    printf("%d", GetPlayerVirtualWorld(playerid));
                    SetPlayerInterior(playerid, hInfo[i][hType]);
                    SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], hInfo[i][hExitX], hInfo[i][hExitY], hInfo[i][hExitZ], 269.15, pInfo[playerid][pWeaponSlot1], pInfo[playerid][pWeaponSlot1Ammo], pInfo[playerid][pWeaponSlot2], pInfo[playerid][pWeaponSlot2Ammo], pInfo[playerid][pWeaponSlot3], pInfo[playerid][pWeaponSlot3Ammo]);
                    SpawnPlayer(playerid);
                }
            }
        } else if(pInfo[playerid][pInPrisonType] == 1){
            // in normal prison
            new randnum;
            randnum = random(3);
            if(randnum == 0){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2664.5139, 2645.7776, 4082.2140, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
            if(randnum == 1){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2659.2620, 2645.6013, 4080.8100, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
            if(randnum == 2){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2659.5981, 2637.6501, 4080.6925, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
        }
    } else {
        if(pInfo[playerid][pInPrisonType] == 0){
            SetPlayerWantedLevel(playerid, pInfo[playerid][pWantedLevel]);
            SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -204.5334, 1119.1626, 23.2031, 269.15, pInfo[playerid][pWeaponSlot1], pInfo[playerid][pWeaponSlot1Ammo], pInfo[playerid][pWeaponSlot2], pInfo[playerid][pWeaponSlot2Ammo], pInfo[playerid][pWeaponSlot3], pInfo[playerid][pWeaponSlot3Ammo]);
            SpawnPlayer(playerid);
        } else if(pInfo[playerid][pInPrisonType] == 1) {
            // in normal prison
            new randnum;
            randnum = random(3);
            if(randnum == 0){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2664.5139, 2645.7776, 4082.2140, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
            if(randnum == 1){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2659.2620, 2645.6013, 4080.8100, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
            if(randnum == 2){
                SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -2659.5981, 2637.6501, 4080.6925, 269.15, 0,0,0,0,0,0);
                SpawnPlayer(playerid);
                SetPlayerInterior(playerid, 1);
                SetPlayerVirtualWorld(playerid, 1);
                SetTimerEx("DecrementPrisonTimer", 1000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
            }
        }
    }
    return 1;
}

forward public DecrementPrisonTimer(playerid, prisontype);
public DecrementPrisonTimer(playerid, prisontype){
    if(prisontype == 1){
        if(pInfo[playerid][pPrisonTimer] == 0) {
            for(new i = 0; i < loadedFac; i++){
                if(fInfo[i][fID] == 1){
                    pInfo[playerid][pInPrisonType] = 0;
                    pInfo[playerid][pPrisonTimer] = 0;
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have been released from prison!");
                    SetPlayerPos(playerid, fInfo[i][fExitX], fInfo[i][fExitY], fInfo[i][fExitZ]);
                    return 1;
                }
            }
        }
        if(pInfo[playerid][pPrisonTimer] >= 1){
            pInfo[playerid][pPrisonTimer]--;
            printf("%d.", pInfo[playerid][pPrisonTimer]);
            SetTimerEx("DecrementPrisonTimer", 60000, false, "dd", playerid, pInfo[playerid][pInPrisonType]);
        }
    }
    return 1;
}

forward HashPlayerPassword(playerid);
public HashPlayerPassword(playerid) {
    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash);
    format(passwordForFinalReg[playerid], BCRYPT_HASH_LENGTH, hash);
    OnPlayerRegister(playerid);
    return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid) {
    Dialog_Show(playerid, DIALOG_EMAIL, DIALOG_STYLE_INPUT, "Email Registration", "Please insert your email below, this is used to link your account to our website!\n\n Example: 'example@example.com'!", "Continue", "Quit");
    return 1;
}

stock IsValidWeapon(weaponid){
    if((weaponid > 0 && weaponid < 19) || (weaponid > 21 && weaponid < 47))
        return 1; // it's valid weapon id so return 1

    return 0; // Invalid return 0
}

stock SetFactionRanknameByRank(playerid, facid, rank) {
    new rankbyid[32];
    if(rank == 1) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank1Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 2) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank2Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 3) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank3Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 4) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank4Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 5) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank5Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 6) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank6Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    if(rank == 7) {
        format(rankbyid, sizeof(rankbyid), "%s", fInfo[facid][fRank7Name]);
        pInfo[playerid][pFactionRankname] = rankbyid;
    }
    return 1;
}

stock GetName(playerid) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}

stock BeginTutorial(playerid) {
    TogglePlayerSpectating(playerid, true);
    SetPlayerPos(playerid, -186.4609, 1123.3984, 23.2031);
    InterpolateCameraPos(playerid, -186.0362, 1133.3577, 21.2427, -187.5258, 1099.3911, 21.2895, 25000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -186.9264, 1132.9102, 21.3127, -188.2667, 1100.0581, 21.3245, 25000, CAMERA_MOVE);

    TextDrawShowForPlayer(playerid, PublicTD[0]);
    TextDrawShowForPlayer(playerid, PublicTD[1]);
    TextDrawShowForPlayer(playerid, PublicTD[2]);
    SetTimerEx("ShowPoliceHeadQuarters", 20000, false, "ds", playerid, "SA-MP");
    return 1;
}


forward public ShowPoliceHeadQuarters(playerid);
public ShowPoliceHeadQuarters(playerid) {
    TextDrawHideForPlayer(playerid, PublicTD[0]);
    TextDrawHideForPlayer(playerid, PublicTD[1]);
    TextDrawHideForPlayer(playerid, PublicTD[2]);
    SetPlayerPos(playerid, -170.3750, 977.8984, 17.3672);
    InterpolateCameraPos(playerid, -186.1797, 962.0568, 23.6842, -188.7276, 1008.0828, 23.6842, 25000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -187.0024, 962.6221, 23.4840, -189.4971, 1007.4473, 23.5240, 25000, CAMERA_MOVE);

    TextDrawShowForPlayer(playerid, sheriffsoffice[0]);
    TextDrawShowForPlayer(playerid, sheriffsoffice[1]);
    TextDrawShowForPlayer(playerid, sheriffsoffice[2]);
    TextDrawShowForPlayer(playerid, sheriffsoffice[3]);
    SetTimerEx("ShowHospital", 20000, false, "ds", playerid, "SA-MP");
}

forward public ShowHospital(playerid);
public ShowHospital(playerid) {
    TextDrawHideForPlayer(playerid, sheriffsoffice[0]);
    TextDrawHideForPlayer(playerid, sheriffsoffice[1]);
    TextDrawHideForPlayer(playerid, sheriffsoffice[2]);
    TextDrawHideForPlayer(playerid, sheriffsoffice[3]);
    SetPlayerPos(playerid, -332.4063, 1072.2422, 18.7891);
    InterpolateCameraPos(playerid, -267.1151, 1079.9895, 29.3407, -325.9756, 1097.6803, 29.3407, 25000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -267.8675, 1079.3352, 29.130, -325.7708, 1096.7040, 29.1355, 25000, CAMERA_MOVE);
    TextDrawShowForPlayer(playerid, hospital[0]);
    TextDrawShowForPlayer(playerid, hospital[1]);
    TextDrawShowForPlayer(playerid, hospital[2]);
    SetTimerEx("ShowBank", 20000, false, "ds", playerid, "SA-MP");
}

forward public ShowBank(playerid);
public ShowBank(playerid) {
    TextDrawHideForPlayer(playerid, hospital[0]);
    TextDrawHideForPlayer(playerid, hospital[1]);
    TextDrawHideForPlayer(playerid, hospital[2]);

    SetPlayerPos(playerid, -174.2109, 1120.4531, 24.4063);
    InterpolateCameraPos(playerid, -201.2800, 1101.8776, 22.1507, -184.9772, 1089.4376, 22.0958, 25000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -200.3887, 1102.3276, 22.1106, -184.6169, 1090.3683, 21.9908, 25000, CAMERA_MOVE);

    TextDrawShowForPlayer(playerid, bank[0]);
    TextDrawShowForPlayer(playerid, bank[1]);
    TextDrawShowForPlayer(playerid, bank[2]);
    SetTimerEx("ShowCarDealership", 20000, false, "ds", playerid, "SA-MP");
}

forward public ShowCarDealership(playerid);
public ShowCarDealership(playerid) {
    TextDrawHideForPlayer(playerid, bank[0]);
    TextDrawHideForPlayer(playerid, bank[1]);
    TextDrawHideForPlayer(playerid, bank[2]);
    InterpolateCameraPos(playerid, -159.5010, 1175.6537, 40.0863, -107.4895, 1194.5828, 40.0863, 25000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -159.2729, 1176.6282, 39.7862, -108.2426, 1195.2413, 39.5612, 25000, CAMERA_MOVE);

    TextDrawShowForPlayer(playerid, cardealer[0]);
    TextDrawShowForPlayer(playerid, cardealer[1]);
    TextDrawShowForPlayer(playerid, cardealer[2]);
    SetTimerEx("FinishTutorial", 20000, false, "ds", playerid, "SA-MP");
}

forward public FinishTutorial(playerid);
public FinishTutorial(playerid) {
    TextDrawHideForPlayer(playerid, cardealer[0]);
    TextDrawHideForPlayer(playerid, cardealer[1]);
    TextDrawHideForPlayer(playerid, cardealer[2]);
    SetPlayerPos(playerid, -204.5334, 1119.1626, 23.2031);
    InterpolateCameraPos(playerid, -196.1429, 1189.0867, 20.6999, -196.6579, 1115.6125, 20.8931, 20000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, -196.1333, 1188.0886, 20.6276, -196.5824, 1114.6172, 20.8809, 20000, CAMERA_MOVE);
    TextDrawShowForPlayer(playerid, finishtutorial[0]);
    TextDrawShowForPlayer(playerid, finishtutorial[1]);
    TextDrawShowForPlayer(playerid, finishtutorial[2]);
    SetTimerEx("FinishTutorialSpawn", 20000, false, "d", playerid);
}
forward public FinishTutorialSpawn(playerid);
public FinishTutorialSpawn(playerid) {
    TextDrawHideForPlayer(playerid, finishtutorial[0]);
    TextDrawHideForPlayer(playerid, finishtutorial[1]);
    TextDrawHideForPlayer(playerid, finishtutorial[2]);
    SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -204.5334, 1119.1626, 23.2031, 269.15, 0, 0, 0, 0, 0, 0);
    TogglePlayerSpectating(playerid, false);
}

forward KickPublic(playerid);
public KickPublic(playerid) { Kick(playerid); }

stock KickWithMessage(playerid, message[]) {
    SendClientMessage(playerid, 0xFF4444FF, message);
    SetTimerEx("KickPublic", 1000, 0, "d", playerid);
}

/*Text formatting*/

stock nearByAction(playerid, color, string[], Float:Distance = 12.0) {
    new
    Float:nbCoords[3]; // Variable to store the position of the main player

    GetPlayerPos(playerid, nbCoords[0], nbCoords[1], nbCoords[2]); // Getting the main position

    for (new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerInRangeOfPoint(i, Distance, nbCoords[0], nbCoords[1], nbCoords[2]) && (GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))) { // Confirming if the player being looped is within range and is in the same virtual world and interior as the main player
            SendClientMessage(i, color, string); // Sending them the message if all checks out
        }
    }

    return 1;
}

forward public nearByMessage(playerid, color, string[], Float:Distance);
public nearByMessage(playerid, color, string[], Float:Distance) {
    new
    Float:nbCoords[3]; // Variable to store the position of the main player

    GetPlayerPos(playerid, nbCoords[0], nbCoords[1], nbCoords[2]); // Getting the main position

    for (new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerInRangeOfPoint(i, Distance, nbCoords[0], nbCoords[1], nbCoords[2]) && (GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))) { // Confirming if the player being looped is within range and is in the same virtual world and interior as the main player
            SendClientMessageA(i, color, string); // Sending them the message if all checks out
        } else if(IsPlayerInRangeOfPoint(i, 16, nbCoords[0], nbCoords[1], nbCoords[2]) && (GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))) { // Confirming if the player being looped is within range and is in the same virtual world and interior as the main player
            SendClientMessageA(i, GREY, string); // Sending them the message if all checks out
        }
    }
    return 1;
}

/* paying players */
forward public payPlayerTimer(playerid);
public payPlayerTimer(playerid) {
    if(pInfo[playerid][LoggedIn] == true) {
        if(pInfo[playerid][pPayTimer] < 61) {
            if(pInfo[playerid][pPayTimer] == 0) {

                new string[256];
                format(string, sizeof(string), "[SERVER]:**-------- PAYCHECK --------**");
                SendClientMessage(playerid, SPECIALORANGE, string);
                payPlayer(playerid);
            } else {
                pInfo[playerid][pPayTimer] -= 1;
                SetTimerEx("payPlayerTimer", 60000, false, "ds", playerid, "SA-MP"); //called "function" when 10 seconds elapsed

            }
        }
    }
    return 1;
}

forward public payPlayer(playerid);
public payPlayer(playerid) {
    new tax, salary = 250, totalpay, string[256];
    format(string, sizeof(string), "[SERVER]:{ABCDEF} Basic Salary: +$%d", salary);
    SendClientMessage(playerid, SPECIALORANGE, string);
    if(pInfo[playerid][pJobId] >= 1) {
        salary += pInfo[playerid][pJobPay]; // adding up their job's pay
        tax = (salary / 500) * 100;
        format(string, sizeof(string), "[SERVER]:{ABCDEF} Job Pay: +$%d | Job Tax: -$%d", pInfo[playerid][pJobPay], tax);
        SendClientMessage(playerid, SPECIALORANGE, string);
        pInfo[playerid][pJobPay] = 0;
    }
    if(pInfo[playerid][pFactionId] >= 1){
        salary += pInfo[playerid][pFactionPay];
        tax = (salary / 500) * 100;
        format(string, sizeof(string), "[SERVER]:{ABCDEF} Faction Pay: +$%d | Tax: -$%d", pInfo[playerid][pFactionPay], tax);
        SendClientMessage(playerid, SPECIALORANGE, string);
        pInfo[playerid][pFactionPay] = 0;
    }
    tax = (salary / 500) * 100;
    totalpay = salary - tax; // taxing their job's pay
    format(string, sizeof(string), "[SERVER]:{ABCDEF} Income: $%d | Tax: -$%d | Total Pay: +$%d", salary, tax, totalpay);
    SendClientMessage(playerid, SPECIALORANGE, string);
    pInfo[playerid][pPayTimer] = 60;
    pInfo[playerid][pBank] += totalpay;
    SetTimerEx("payPlayerTimer", 60000, false, "ds", playerid, "SA-MP"); //called "function" when 10 seconds elapsed

    if(pInfo[playerid][pExp] >= 8) {
        pInfo[playerid][pExp] = 0;
        pInfo[playerid][pLevel]++;
        format(string, sizeof(string), "[SERVER]:{ABCDEF} You have levelled up! (Level: %d)", pInfo[playerid][pLevel]);
        SendClientMessage(playerid, SPECIALORANGE, string);
    }
    if(pInfo[playerid][pExp] <= 8) {
        pInfo[playerid][pExp]++;
        format(string, sizeof(string), "[SERVER]:{ABCDEF} You have gained an experience point! (Exp: %d)", pInfo[playerid][pExp]);
        SendClientMessage(playerid, SPECIALORANGE, string);
    }

    return 1;
}

stock RPName(playerid) {
    new
    szName[MAX_PLAYER_NAME],
        stringPos;

    GetPlayerName(playerid, szName, sizeof(szName));
    stringPos = strfind(szName, "_");
    szName[stringPos] = ' ';
    return szName;
}

stock GetVehicleName(vehicleid) {
    new String[256];
    format(String, sizeof(String), "%s", VehicleNames[GetVehicleModel(vehicleid) - 400]);
    return String;
}

stock ReturnPlayerInventory(playerid, target){    
    new string[256];
    format(string, sizeof(string), "[SERVER]:**-------- %s's POCKETS --------**", RPName(target));
    SendClientMessage(playerid, SPECIALORANGE, string);
    if(GetPlayerMoney(target) > 0){        
        format(string, sizeof(string), "[SERVER]: $%d (CASH)", pInfo[target][pCash]);
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    if(pInfo[target][pPhoneModel] >= 1){
        if(pInfo[target][pPhoneModel] == 1){
            format(string, sizeof(string), "[SERVER]: Nokia (MOBILE)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pPhoneModel] == 2){
            format(string, sizeof(string), "[SERVER]: LG (MOBILE)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pPhoneModel] == 3){
            format(string, sizeof(string), "[SERVER]: Sony (MOBILE)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pPhoneModel] == 4){
            format(string, sizeof(string), "[SERVER]: Samsung (MOBILE)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pPhoneModel] == 5){
            format(string, sizeof(string), "[SERVER]: iFruit X (MOBILE)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
    }
    if(pInfo[target][pGpsModel] >= 1){
        if(pInfo[target][pGpsModel] == 1){            
            format(string, sizeof(string), "[SERVER]: TomTom (GPS)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pGpsModel] == 2){            
            format(string, sizeof(string), "[SERVER]: GoClever (GPS)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pGpsModel] == 3){            
            format(string, sizeof(string), "[SERVER]: NavRoad (GPS)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
        if(pInfo[target][pGpsModel] == 4){            
            format(string, sizeof(string), "[SERVER]: GARMIN (GPS)");
            SendClientMessage(playerid, SERVERCOLOR, string);
        }
    }
    if(pInfo[target][pCigAmount] >= 1){
        format(string, sizeof(string), "[SERVER]: %d cigarettes", pInfo[target][pCigAmount]);
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    if(pInfo[target][pRopeAmount] >= 1){
        format(string, sizeof(string), "[SERVER]: %d/m of Rope", pInfo[playerid][pRopeAmount]);
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    if(pInfo[target][pHasMask] == 1){
        format(string, sizeof(string), "[SERVER]: Mask");
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    if(pInfo[target][pWeedAmount] >= 1){        
        format(string, sizeof(string), "[SERVER]: %d/grams of Weed", pInfo[target][pWeedAmount]);
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    if(pInfo[target][pCokeAmount] >= 1){        
        format(string, sizeof(string), "[SERVER]: %d/grams of Cocaine", pInfo[target][pCokeAmount]);
        SendClientMessage(playerid, SERVERCOLOR, string);
    }
    return 1;
}

stock ReturnStats(playerid, target) {
    new string[256];
    format(string, sizeof(string), "[SERVER]:**-------- %s's STATISTICS --------**", RPName(target));
    SendClientMessage(playerid, SPECIALORANGE, string);
    format(string, sizeof(string), "[PLAYER]:{ABCDEF} Level: %d (%dexp/8) | Bank: $%d | Cash: $%d | Payment in: %dmins", pInfo[target][pLevel], pInfo[target][pExp], pInfo[target][pBank], pInfo[target][pCash], pInfo[target][pPayTimer]);
    SendClientMessage(playerid, SPECIALORANGE, string);
    if(pInfo[playerid][pFactionId] == 0) {
        format(string, sizeof(string), "[FACTION]:{ABCDEF} Faction (0): N/A | Ranknam: N/A");
        SendClientMessage(playerid, SPECIALORANGE, string);
    }
    for (new i = 0; i < loadedFac; i++) {
        if(pInfo[playerid][pFactionId] == fInfo[i][fID]) {
            format(string, sizeof(string), "[FACTION]:{ABCDEF} Faction (%d): %s | Rank: %d | Rankname: %s", pInfo[playerid][pFactionId], ReturnFacName(playerid, pInfo[playerid][pFactionId] - 1), pInfo[playerid][pFactionRank], pInfo[playerid][pFactionRankname]);
            SendClientMessage(playerid, SPECIALORANGE, string);
        }
    }
    if(pInfo[playerid][pJobId] == 0) {
        format(string, sizeof(string), "[JOB]:{ABCDEF} Job ID: N/A | Job name: N/A", pInfo[target][pJobId]);
        SendClientMessage(playerid, SPECIALORANGE, string);
    }
    for (new i = 0; i < loadedJob; i++) {
        if(pInfo[playerid][pJobId] == jInfo[i][jID]) {
            if(pInfo[playerid][pJobId] >= 1) {
                format(string, sizeof(string), "[JOB]:{ABCDEF} Job ID: %d | Job name: %s", pInfo[target][pJobId], jInfo[i][jName]);
                SendClientMessage(playerid, SPECIALORANGE, string);
            }
        }
    }
    format(string, sizeof(string), "[VEHICLES]:{ABCDEF} Vehicle slots: %d/%d", pInfo[target][pVehicleSlotsUsed], pInfo[target][pVehicleSlots]);
    SendClientMessage(playerid, SPECIALORANGE, string);
    return 1;
}

stock ReturnFacName(playerid, facid) {
    new string[32];
    /* loop through all factions...
    getfactionname from faction id?*/
    for (new i = 0; i < loadedFac; i++) {
        if(pInfo[playerid][pFactionId] >= 1) {
            format(string, sizeof(string), "%s", fInfo[facid][fName]);
            return string;
        }
    }
    return string;
}

stock TurnVehicleEngineOff(vehicleid) {
    new engine, lights, alarm, doors, bonnet, boot, objective;
    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
}

forward public RemoveTextdrawAfterTime(playerid);
public RemoveTextdrawAfterTime(playerid) {
    TextDrawHideForPlayer(playerid, Text:PMuted);
    TextDrawHideForPlayer(playerid, Text:CantCommand);
    TextDrawHideForPlayer(playerid, Text:NoHelpmes);
    TextDrawHideForPlayer(playerid, Text:NoReports);
    TextDrawHideForPlayer(playerid, Text:CantTakePost);
    TextDrawHideForPlayer(playerid, Text:NoBinBags);
    TextDrawHideForPlayer(playerid, Text:accessDoor);
    TextDrawHideForPlayer(playerid, Text:NotOnDuty);

    PlayerTextDrawHide(playerid, businessBox[playerid]);
    PlayerTextDrawHide(playerid, addressBox[playerid]);
    PlayerTextDrawHide(playerid, addressString[playerid]);
    PlayerTextDrawHide(playerid, addressStatus[playerid]);
    PlayerTextDrawHide(playerid, addressType[playerid]);
    PlayerTextDrawHide(playerid, addressPrice[playerid]);
    PlayerTextDrawHide(playerid, addressName[playerid]);

    PlayerTextDrawHide(playerid, PlayerAddress[playerid][0]);
    PlayerTextDrawHide(playerid, PlayerAddress[playerid][1]);
    PlayerTextDrawHide(playerid, PlayerAddress[playerid][2]);
    PlayerTextDrawHide(playerid, PlayerAddress[playerid][3]);
    PlayerTextDrawHide(playerid, addressNameString[playerid]);

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    if(dialogid == 9999){
        if(response){
            if(pInfo[playerid][pBank] < BUS_DEALERSHIP[listitem][VEHICLE_PRICE]){
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You cannot afford this vehicle!");
                return 1;
            }

            new query[900], num_plate[8];
            for(new i; i < 2; i++){
                num_plate[i] = 'A'+random('Z'-'A');
            }
            for(new i = 3; i < sizeof(num_plate); i++){
                num_plate[i] = '0'+random('9'-'0');
            }

            for(new i = 0; i < loadedBus; i++){
                if(IsPlayerInRangeOfPoint(playerid, 3, bInfo[i][bUseX], bInfo[i][bUseY], bInfo[i][bUseZ])){
                    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `vehicles` (`vModelId`, `vOwner`, `vRentalState`, `vPlate`, `vParkedX`, `vParkedY`, `vParkedZ`, `vAngle`) VALUES ('%d', '%s', '2', '%s', '%f', '%f', '%f', '90')", BUS_DEALERSHIP[listitem][VEHICLE_MODELID], GetName(playerid), num_plate, bInfo[i][bInfoX], bInfo[i][bInfoY], bInfo[i][bInfoZ]);
                    mysql_tquery(db_handle, query, "OnPlayerBuyVehicle","ds", playerid, GetName(playerid));
                    GameTextForPlayer(playerid, "~g~VEHICLE PURCHASED!", 3000, 3);
                    bInfo[i][bSalary] += BUS_DEALERSHIP[listitem][VEHICLE_PRICE];
                    pInfo[playerid][pVehicleSlotsUsed]++;
                    pInfo[playerid][pBank] -= BUS_DEALERSHIP[listitem][VEHICLE_PRICE];
                }
            }
        }
    }
    if(dialogid == 9998){
        if(response){
            pInfo[playerid][pDutyClothes] = POLICECLOTHES[listitem][SKINID];
            GameTextForPlayer(playerid, "~g~DUTY CLOTHES SELECTED!", 3000, 3);
        }
    }
    if(dialogid == 9997){
        if(response){
            pInfo[playerid][pDutyClothes] = MEDICCLOTHES[listitem][SKINID];
            GameTextForPlayer(playerid, "~g~DUTY CLOTHES SELECTED!", 3000, 3);
        }
    }
    if(dialogid == 9996){
        if(response){
            pInfo[playerid][pDutyClothes] = TOWCLOTHES[listitem][SKINID];
            GameTextForPlayer(playerid, "~g~DUTY CLOTHES SELECTED!", 3000, 3);
        }
    }
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
    return 1;
}