// Gamemode script
// Developers:
// - Olly
// - 

#include <a_samp>
#include <a_mysql>
#include <easyDialog>
#include <bcrypt>
#include <zcmd>
#include <sscanf2>
#include <streamer>

#define BCRYPT_COST 12
#define lenull(%1) \
((!( % 1[0])) || ((( % 1[0]) == '\1') && (!( % 1[1]))))
#define MAX_JOBS 50
#define MAX_FACTIONS 50


#define GREY 			0xCECECEFF
#define SPECIALORANGE   0xFFCC00FF // CRP Orange 0xFF8000FF
#define SERVERCOLOR 	0xA9C4E4FF //0x99CEFFFF 94ABC8
#define NICESKY 		0xC2A2DAFF // rp color
#define ADMINBLUE 		0x1D7CF2FF //0059E8

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

new Menu:busdrivermenu, Menu:hardwaremenu, Menu:phonemenu, Menu:gpsmenu;

new PostCheckpoint[MAX_PLAYERS], JobCheckpoint[MAX_PLAYERS], GarbageCheckpoint[MAX_PLAYERS];
new dumpCheckPoint[MAX_PLAYERS], routeId[MAX_PLAYERS], busCheckpoint[MAX_PLAYERS], drugDeal[MAX_PLAYERS];
new speedoTimer[MAX_PLAYERS], fuelTimer[MAX_PLAYERS], drugDealTimer[MAX_PLAYERS];

new policeCall[MAX_PLAYERS];

new dumpPickup, jobPickup[MAX_JOBS];

new PlayerText:VEHSTUFF[MAX_PLAYERS][5];
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

        pFactionId,
        pFactionRank,
        pFactionRankname[32],
        pFactionPay,

        pJobId,
        pJobPay,
        pWeedAmount,
        pCokeAmount,

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

        RentingVehicle
}
new pInfo[MAX_PLAYERS][ENUM_PLAYER_DATA];

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
        vRentalPrice
}
new vInfo[500][ENUM_VEH_DATA], loadedVeh;

enum ENUM_FAC_DATA {
    fID[32],
        fName[32],
        fType, // 1 = gang 2 = legal
        fRank1Name[32],
        fRank2Name[32],
        fRank3Name[32],
        fRank4Name[32],
        fRank5Name[32],
        fRank6Name[32],
        fRank7Name[32],
}
new fInfo[MAX_FACTIONS][ENUM_FAC_DATA], loadedFac;

enum ENUM_DRUG_PRICES{
    drugId[32],
    drugName[32],
    drugAmount,
    drugPrice
};
new drugInfo[15][ENUM_DRUG_PRICES], loadedDrug;

public OnGameModeInit() {
    mysql_log(ALL);
    ManualVehicleEngineAndLights();
    // Don't use these lines if it's a filterscript
    SetGameModeText("Roleplay | v1");

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
    CreateBusStopObjects();
    LoadVehicleData();
    LoadDrugPrices();
    

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
            cache_get_value_int(i, "vID", vInfo[loadedVeh][vID]);
            cache_get_value_int(i, "vModelId", vInfo[loadedVeh][vModelId]);
            cache_get_value(i, "vOwner", vInfo[loadedVeh][vOwner], 32);
            cache_get_value_int(i, "vFuel", vInfo[loadedVeh][vFuel]);
            cache_get_value_int(i, "vJobId", vInfo[loadedVeh][vJobId]);
            cache_get_value_int(i, "vFacId", vInfo[loadedVeh][vFacId]);
            cache_get_value(i, "vPlate", vInfo[loadedVeh][vPlate], 32);
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
            SetVehicleNumberPlate(vehicleid, vInfo[i][vPlate]);
            loadedVeh++;
        }
        printf("** [MYSQL] Loaded %d vehicles from the database!", cache_num_rows());
    }
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
            cache_get_value(i, "fRank1Name", fInfo[i][fRank1Name], 32);
            cache_get_value(i, "fRank2Name", fInfo[i][fRank2Name], 32);
            cache_get_value(i, "fRank3Name", fInfo[i][fRank3Name], 32);
            cache_get_value(i, "fRank4Name", fInfo[i][fRank4Name], 32);
            cache_get_value(i, "fRank5Name", fInfo[i][fRank5Name], 32);
            cache_get_value(i, "fRank6Name", fInfo[i][fRank6Name], 32);
            cache_get_value(i, "fRank7Name", fInfo[i][fRank7Name], 32);
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
            cache_get_value(i, "fRank1Name", fInfo[i][fRank1Name], 32);
            cache_get_value(i, "fRank2Name", fInfo[i][fRank2Name], 32);
            cache_get_value(i, "fRank3Name", fInfo[i][fRank3Name], 32);
            cache_get_value(i, "fRank4Name", fInfo[i][fRank4Name], 32);
            cache_get_value(i, "fRank5Name", fInfo[i][fRank5Name], 32);
            cache_get_value(i, "fRank6Name", fInfo[i][fRank6Name], 32);
            cache_get_value(i, "fRank7Name", fInfo[i][fRank7Name], 32);
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
            cache_get_value_int(i, "jID", jInfo[loadedJob][jID]);
            cache_get_value(i, "jName", jInfo[loadedJob][jName], 32);
            cache_get_value_int(i, "jPay", jInfo[loadedJob][jPay]);
            cache_get_value_float(i, "jobIX", jInfo[loadedJob][jobIX]);
            cache_get_value_float(i, "jobIY", jInfo[loadedJob][jobIY]);
            cache_get_value_float(i, "jobIZ", jInfo[loadedJob][jobIZ]);
            jobPickup[loadedJob] = CreateDynamicPickup(1239, 1, jInfo[loadedJob][jobIX], jInfo[loadedJob][jobIY], jInfo[loadedJob][jobIZ], -1);
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
            cache_get_value_int(i, "jID", jInfo[loadedJob][jID]);
            cache_get_value(i, "jName", jInfo[loadedJob][jName], 32);
            cache_get_value_int(i, "jPay", jInfo[loadedJob][jPay]);
            cache_get_value_float(i, "jobIX", jInfo[loadedJob][jobIX]);
            cache_get_value_float(i, "jobIY", jInfo[loadedJob][jobIY]);
            cache_get_value_float(i, "jobIZ", jInfo[loadedJob][jobIZ]);
            jobPickup[loadedJob] = CreateDynamicPickup(1239, 1, jInfo[loadedJob][jobIX], jInfo[loadedJob][jobIY], jInfo[loadedJob][jobIZ], -1);
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


        LoadMapIcons(playerid);

        ApplyAnimation(playerid, "SMOKING", "M_smklean_loop", 4.0, true, false, false, false, 0, false); // Smoke

        mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `accounts` where `pName` = '%s'", name); // Get the player's name
        mysql_tquery(db_handle, query, "checkIfExists", "d", playerid); // Send to check if exists function


        // remove buildings

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
    
    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pPhoneNumber` = '%d', `pPhoneModel` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pPhoneNumber], pInfo[playerid][pPhoneModel], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pWeedAmount` = '%d', `pCokeAmount` = '%d' WHERE  `pName` = '%e'", pInfo[playerid][pWeedAmount], pInfo[playerid][pCokeAmount], GetName(playerid));
    mysql_query(db_handle, query);

    mysql_format(db_handle, query, sizeof(query), "UPDATE `accounts` SET `pAdminLevel` = '%d' WHERE `pName` = '%e'", pInfo[playerid][pAdminLevel], GetName(playerid));
    mysql_query(db_handle, query);
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
        new string[256];

        format(string, sizeof(string), "%s[%i] says:%s", RPName(playerid), playerid, text);
        nearByMessage(playerid, -1, string, 12.0);
    } else {
        TextDrawShowForPlayer(playerid, PMuted);
        SetTimerEx("RemoveTextdrawAfterTime", 3500, false, "d", playerid);
    }
    return 0;
}

/* SHOP CMDS */
CMD:shop(playerid, params[]){
    // ifplayerinrangeofpoint (check if they are near a shop/hardware store)
    ShowMenuForPlayer(hardwaremenu, playerid); // show the hardware menu!
    TogglePlayerControllable(playerid, false); // freeze player so they can use the menu

    return 1;
}


/* COMMANDS */
CMD:stats(playerid, params[]) {
    ReturnStats(playerid, playerid);
    return 1;
}

CMD:takecall(playerid, params[]){
    new target;
    if(pInfo[playerid][pFactionId] == 1){
        if(sscanf(params, "d", target)) return SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} /takecall [callcode]"); {
            if(pInfo[target][pAlertCall] == 1)
            {                        
                new Float:tX, Float:tY, Float:tZ;
                GetPlayerPos(target, tX, tY, tZ);
                policeCall[0] = CreateDynamicCP(tX, tY, tZ, 2, -1, -1, -1, 10000);
                for(new i = 0; i < MAX_PLAYERS; i++){
                    if(pInfo[i][pFactionId] == 1){
                        new string[256];
                        format(string, sizeof(string), "{FFFFFF}Radio: %s has taken call code: %d!", RPName(playerid), target);
                        SendClientMessage(i, SERVERCOLOR, string);
                    }
                }
            } else {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} This is not a valid call code!");
                return 1;
            }
        }
    }
    return 1;
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
        } else if(strcmp(Usage, "Job", true) == 0) {
            SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Job Commands ::.");
            if(pInfo[playerid][pJobId] == 3) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /quitjob, /route");
            } else if(pInfo[playerid][pJobId] == 2) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /startjob, /collect, /dump, /quitjob");
            } else if(pInfo[playerid][pJobId] == 1) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /quitjob, /takepost");
            } else if(pInfo[playerid][pJobId] == 0) {
                SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{A9C4E4} /takejob, /listjobs");
            }
        } else if(strcmp(Usage, "Admin", true) == 0) {
            if(pInfo[playerid][pAdminLevel] > 1) {
                SendClientMessage(playerid, SPECIALORANGE, "[SERVER]:. ::{FFCC00} Admin Commands ::.");
                if(pInfo[playerid][pAdminLevel] == 6) {
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:/createjob, /makeleader");

                }
            }
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
                            GivePlayerMoney(playerid, -drugInfo[0][drugPrice])
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
                                GivePlayerMoney(playerid, -drugInfo[1][drugPrice])
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
            if(pInfo[playerid][pFactionId] == vInfo[vehicleid][vFacId]) {

            }
            RemovePlayerFromVehicle(playerid);
        }

        if(!strcmp(name, vInfo[vehicleid][vOwner]))
            SendClientMessage(playerid, GREY, "must be a player veh");
        return 1;
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
                if(vInfo[i][vJobId] == pInfo[playerid][pJobId]) {
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
        pInfo[playerid][RentingVehicle] = vehicleid;
        vInfo[vehicleid][vRented] = VEHICLE_RENTED;
        vInfo[vehicleid][vRentingPlayer] = playerid;
        TurnVehicleEngineOff(vehicleid);
        SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You have rented the vehicle.");
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
    if(checkpointid == drugDeal[0]){
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
                    format(string, sizeof(string), "[SERVER]:{FFFFFF} You have sold %d/grams of coke for $%d!", randomWant, giveMoney);
                    SendClientMessage(playerid, SERVERCOLOR, string);
                }
                return 1;
            }
            return 1;
        }
    }

    if(checkpointid == policeCall[0]){
        if(pInfo[playerid][pFactionId] == 1)
        {
            for(new i = 0; i < MAX_PLAYERS; i++){
                if(pInfo[i][pFactionId] == 1){
                    new string[256];
                    format(string, sizeof(string), "Radio: %s %s has arrived on the scene, over.", pInfo[playerid][pFactionRankname], RPName(playerid));
                    SendClientMessage(playerid, SERVERCOLOR, string);
                    pInfo[playerid][pFactionPay] += 50;
                }
            }
        }
        return 1;
    }
    return 1;
}

forward public AlertPolice(playerid, message[32], Float:cX, Float:cY, Float:cZ);
public AlertPolice(playerid, message[32], Float:cX, Float:cY, Float:cZ){
    new string[256];
    pInfo[playerid][pAlertCall] = 1;
    format(pInfo[playerid][pAlertMsg], 64, "%s", message);

    for(new i = 0; i < MAX_PLAYERS; i++){
        if(pInfo[i][pFactionId] == 1){ // if player is a police officer
            format(string, sizeof(string), "{FFFFFF}Radio: %s, call code: %d", message, playerid);
            SendClientMessage(i, SERVERCOLOR, string);
            return 1;
        }
    }
    return 1;
}

CMD:listallcalls(playerid, params[]){
    new string[256];
    
    SendClientMessage(playerid, SPECIALORANGE, "**-----AVAILABLE CALLS-----**");
    for(new i = 0; i < MAX_PLAYERS; i++){
        if(pInfo[i][pAlertCall] == 1){
            format(string, sizeof(string), "Call code: %d,", playerid);
            SendClientMessage(playerid, SERVERCOLOR, string);
            return 1;
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
                    TogglePlayerControllable(playerid, 1);
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
                    TogglePlayerControllable(playerid, 1);
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
                    TogglePlayerControllable(playerid, 1);
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
                    TogglePlayerControllable(playerid, 1);
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
                    GivePlayerMoney(playerid, -250);
                    TogglePlayerControllable(playerid, 1);
                    return 1;
                } else {
                    ShowMenuForPlayer(phonemenu, playerid);
                    SendClientMessage(playerid, SERVERCOLOR, "[SERVER]:{FFFFFF} You don't have enough cash for this phone! Choose another.");
                }
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
    TogglePlayerControllable(playerid,1); // unfreeze the player when they exit a menu
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
    return 1;
}

public OnRconLoginAttempt(ip[], password[], success) {
    return 1;
}

public OnPlayerUpdate(playerid) {
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
    cache_get_value_int(0, "pFactionId", pInfo[playerid][pFactionId]);
    cache_get_value_int(0, "pFactionRank", pInfo[playerid][pFactionRank]);
    cache_get_value(0, "pFactionRankname", pInfo[playerid][pFactionRankname], 32);
    cache_get_value_int(0, "pJobId", pInfo[playerid][pJobId]);
    cache_get_value_int(0, "pJobPay", pInfo[playerid][pJobPay]);
    cache_get_value_int(0, "pWeedAmount", pInfo[playerid][pWeedAmount]);
    cache_get_value_int(0, "pCokeAmount", pInfo[playerid][pCokeAmount]);

    cache_get_value_int(0, "pAdminLevel", pInfo[playerid][pAdminLevel]);

    pInfo[playerid][LoggedIn] = true;
    SendClientMessage(playerid, -1, "Logged in");
    SetPlayerHealth(playerid, pInfo[playerid][pHealth]);
    SetPlayerArmour(playerid, pInfo[playerid][pArmour]);
    GivePlayerMoney(playerid, pInfo[playerid][pCash]);
    SetSpawnInfo(playerid, 0, pInfo[playerid][pSkin], -204.5334, 1119.1626, 23.2031, 269.15, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
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
            SendClientMessage(i, color, string); // Sending them the message if all checks out
        } else if(IsPlayerInRangeOfPoint(i, 16, nbCoords[0], nbCoords[1], nbCoords[2]) && (GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))) { // Confirming if the player being looped is within range and is in the same virtual world and interior as the main player
            SendClientMessage(i, GREY, string); // Sending them the message if all checks out
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
        format(string, sizeof(string), "[SERVER]:{ABCDEF} Faction Pay: +$%d | Job Tax: -$%d", pInfo[playerid][pFactionPay], tax);
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
    SendClientMessage(target, SPECIALORANGE, string);
    if(GetPlayerMoney(target) > 0){        
        format(string, sizeof(string), "[SERVER]: $%d (CASH)", pInfo[target][pCash]);
        SendClientMessage(target, SERVERCOLOR, string);
    }    
    if(pInfo[target][pWeedAmount] >= 1){        
        format(string, sizeof(string), "[SERVER]: %d/grams of Weed", pInfo[target][pWeedAmount]);
        SendClientMessage(target, SERVERCOLOR, string);
    }
    if(pInfo[target][pCokeAmount] >= 1){        
        format(string, sizeof(string), "[SERVER]: %d/grams of Cocaine", pInfo[target][pCokeAmount]);
        SendClientMessage(target, SERVERCOLOR, string);
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
            return 1;
        }
    }
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
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
    return 1;
}