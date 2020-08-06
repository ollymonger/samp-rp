// Gamemode script
// Developers:
// - Olly
// - 

#include <a_samp>
#include <a_mysql>
#include <easyDialog>
#include <bcrypt>

#define BCRYPT_COST 12

main() {
    print("\n----------------------------------");
    print(" Gamemode started... please wait...");
    print("----------------------------------\n");
}

/* 1- NEWS -*/
new MySQL:db_handle;

new 
	bool:LoggedIn[MAX_PLAYERS];

enum ENUM_PLAYER_DATA {
    ID[32],
        pName[MAX_PLAYER_NAME],
        pPassword[65],
        HashedPassword[255],
        pEmail[128],
        pBank,
        pCash
}
new pInfo[MAX_PLAYERS][ENUM_PLAYER_DATA];

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


    return 1;
}

public OnGameModeExit() {
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
    SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
    return 1;
}

public OnPlayerConnect(playerid) {
    new query[200];

    new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    mysql_format(db_handle, query, sizeof(query), "SELECT * FROM `accounts` where `pName` = '%s'", name); // Get the player's name
    printf("connected");
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
    return 1;
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
Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[]) {
    if(response) {
        bcrypt_hash(inputtext, BCRYPT_COST, "HashPlayerPassword", "d", playerid);
    } else {
        Kick(playerid);
    }
}
Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[]) {
    if(response) {
        new query[256], playerName[MAX_PLAYER_NAME], password[BCRYPT_HASH_LENGTH];
        GetPlayerName(playerid, playerName, sizeof(playerName));

        mysql_format(db_handle, query, sizeof(query), "SELECT `pPassword` from `accounts` WHERE `pName` = '%e'", GetName(playerid));
        mysql_query(db_handle, query);
        cache_get_value_name(0, "pPassword", password, BCRYPT_HASH_LENGTH);
        bcrypt_check(inputtext, password, "OnPasswordCheck", "d", playerid);
    } else {
        Kick(playerid);
    }
}
forward OnPasswordChecked(playerid);
public OnPasswordChecked(playerid) {
    new bool:match = bcrypt_is_equal();
    if(match) {
        new query[300];
        mysql_format(db_handle, query, sizeof(query), "SELECT * from `accounts` WHERE `pName` = '%e'", GetName(playerid));
        mysql_tquery(db_handle, query, "OnPlayerLoad", "d", playerid);
    } else {
        new string[100];
        format(string, sizeof(string), "{FFFFFF} Welcome back to the server {A5EBF6}%s{FFFFFF}!\n\n That password was incorrect, please try again!", GetName(playerid));
        Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login System", string, "Login", "Quit");
    }
    return 1;
}

forward OnPlayerLoad(playerid);
public OnPlayerLoad(playerid) {
    cache_get_value_int(0, "ID", pInfo[playerid][ID]);
    cache_get_value(0, "pName", pInfo[playerid][pName], 128);
    cache_get_value(0, "pEmail", pInfo[playerid][pEmail], 128);
    cache_get_value_int(0, "pBank", pInfo[playerid][pBank]);
    cache_get_value_int(0, "pCash", pInfo[playerid][pCash]);
    
	LoggedIn[playerid] = true;
    SendClientMessage(playerid, -1, "Logged in");
    return 1;
}

forward HashPlayerPassword(playerid);
public HashPlayerPassword(playerid) {
    new hash[BCRYPT_HASH_LENGTH], query[300];
    bcrypt_get_hash(hash);
    mysql_format(db_handle, query, sizeof(query), "INSERT INTO `accounts` (`pName`, `pPassword`, `pEmail`, `pBank`, `pCash`) VALUES ('%e', '%e', 'NULL', 0, 0)", GetName(playerid), hash);
    mysql_tquery(db_handle, query, "OnPlayerRegister", "d", playerid);
    return 1;
}

stock GetName(playerid) {
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid, name, sizeof(name));
    return name;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
    return 1;
}