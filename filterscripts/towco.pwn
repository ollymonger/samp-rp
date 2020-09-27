// This is a comment
// uncomment the line below if you want to write a filterscript
#define FILTERSCRIPT

#include <a_samp>
#include <streamer>

#if defined FILTERSCRIPT

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Loading Towing Co mapping!");
	print("--------------------------------------\n");
	
CreateDynamicObject(2957, -110.76970, 1140.16638, 19.90280,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(2957, -111.47170, 1140.28271, 19.90280,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(1233, -107.24144, 1114.32788, 20.05120,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19817, -110.08910, 1134.24146, 17.78730,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19903, -113.77009, 1126.99182, 18.73757,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19903, -113.77010, 1128.27881, 18.73760,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(1686, -113.77010, 1129.79993, 18.62060,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19899, -114.17320, 1138.69666, 18.73530,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19900, -114.17320, 1136.94165, 18.73530,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19900, -114.17320, 1136.12268, 18.73530,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(19900, -114.17320, 1135.18665, 18.73530,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(974, -104.91100, 1125.29004, 19.42140,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(1215, -107.72570, 1122.95251, 19.15000,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(1215, -107.72570, 1118.62354, 19.15000,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(1215, -107.72570, 1122.95251, 19.15000,   0.00000, 0.00000, 0.00000);
CreateDynamicObject(7246, -112.95444, 1125.58154, 20.29804,   0.00000, 0.00000, 0.00000);

	
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{
	print("\n----------------------------------");
	print(" Blank Gamemode by your name here");
	print("----------------------------------\n");
}

#endif

public OnGameModeInit()
{
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
