// Gamemode script
// Developers:
// - Olly
// - 

#include <a_samp>
#include <a_mysql>
#include <easyDialog>
#include <bcrypt>

#define BCRYPT_COST 12
#define lenull(%1) \
((!( % 1[0])) || ((( % 1[0]) == '\1') && (!( % 1[1]))))
#define MAX_JOBS 50


#define GREY 			0xCECECEFF

main() {
    print("\n----------------------------------");
    print(" Gamemode started... please wait...");
    print("----------------------------------\n");
}

/* 1- NEWS -*/
new MySQL:db_handle;

new Text:PublicTD[3];
new Text:sheriffsoffice[4];
new Text:hospital[3];
new Text:bank[3];
new Text:cardealer[3];
new Text:finishtutorial[3];
new Text:PMuted;
new Text:NoHelpmes;
new Text:NoReports;
new Text:CantCommand;


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

new tries[MAX_PLAYERS], passwordForFinalReg[MAX_PLAYERS][BCRYPT_HASH_LENGTH], quizAttempts[MAX_PLAYERS];

enum ENUM_PLAYER_DATA {
    ID[32],
        pName[MAX_PLAYER_NAME],
        pPassword[255],
        HashedPassword[BCRYPT_HASH_LENGTH],
        pEmail[128],
        pRegion[32],
        Float:pHealth,
        Float:pArmour,
        pGender,
        pSkin,
        pAge,
        pBank,
        pCash,
        pJobId,

        bool:LoggedIn,
        pMuted
}
new pInfo[MAX_PLAYERS][ENUM_PLAYER_DATA];

enum ENUM_JOB_DATA {
    jID[32],
    jName[32],
    jPay,
    Float:jobIX,
    Float:jobIY,
    Float:jobIZ
}
new jInfo[MAX_JOBS][ENUM_JOB_DATA];

/* 2- DIALOGS -*/

public OnGameModeInit() {
    mysql_log(ALL);
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

public OnGameModeExit() {
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    return 1;
}

public OnPlayerConnect(playerid) {
    new query[200];

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    SetPlayerSkin(playerid, maleSkins[random(11)]);
    SetPlayerPos(playerid, 163.984863, 1213.388305, 21.501449);
    SetPlayerFacingAngle(playerid, 221.263046);
    InterpolateCameraPos(playerid, 163.4399, 1179.7891, 23.3623, 178.1042, 1187.0188, 22.1915, 15000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 163.5655, 1180.7781, 23.2423, 177.8423, 1187.9811, 22.0065, 15000, CAMERA_MOVE);
    ApplyAnimation(playerid, "SMOKING", "M_smklean_loop", 4.0, true, false, false, false, 0, false); // Smoke

    mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `accounts` where `pName` = '%s'", name); // Get the player's name
    mysql_tquery(db_handle, query, "checkIfExists", "d", playerid); // Send to check if exists function
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

    SendClientMessage(playerid, 0x00FF00FF, "{99c0da}[SERVER]:{ABCDEF}You are now registered and logged in!");
    pInfo[playerid][LoggedIn] = true;
    pInfo[playerid][ID] = cache_insert_id();
    pInfo[playerid][pHealth] = 100;
    pInfo[playerid][pArmour] = 5;
    pInfo[playerid][pCash] = 1000;
    pInfo[playerid][pBank] = 0;

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
    printf("** [MYSQL] Player:%s data has been saved! Disconnecting user...", GetName(playerid));
    return 1;
}

public OnPlayerSpawn(playerid) {
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason) {
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

public OnPlayerCommandText(playerid, cmdtext[]) {
    if(strcmp("/mycommand", cmdtext, true, 10) == 0) {
        // Do something here
        return 1;
    }
    return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
    return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
    return 1;
}

public OnPlayerLeaveCheckpoint(playerid) {
    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid) {
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

public OnPlayerSelectedMenuRow(playerid, row) {
    return 1;
}

public OnPlayerExitedMenu(playerid) {
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
    cache_get_value_float(0, "pHealth", pInfo[playerid][pHealth]);
    cache_get_value_float(0, "pArmour", pInfo[playerid][pArmour]);
    cache_get_value(0, "pRegion", pInfo[playerid][pRegion], 32);
    cache_get_value_int(0, "pGender", pInfo[playerid][pGender]);
    cache_get_value_int(0, "pSkin", pInfo[playerid][pSkin]);
    cache_get_value_int(0, "pAge", pInfo[playerid][pAge]);
    cache_get_value_int(0, "pBank", pInfo[playerid][pBank]);
    cache_get_value_int(0, "pCash", pInfo[playerid][pCash]);

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

stock RPName(playerid) {
    new
    szName[MAX_PLAYER_NAME],
        stringPos;

    GetPlayerName(playerid, szName, sizeof(szName));
    stringPos = strfind(szName, "_");
    szName[stringPos] = ' ';
    return szName;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
    return 1;
}