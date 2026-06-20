#include <a_samp>
#include <core>
#include <float>
#include "../include/vehicle_names.inc"
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"

#pragma tabsize 0

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33AA
#define COLOR_RED       0xAA3333AA
#define COLOR_YELLOW    0xFFFF00AA

#define CITY_LOS_SANTOS     0
#define CITY_SAN_FIERRO     1
#define CITY_LAS_VENTURAS   2

#define MAX_RACES           64
#define MAX_CHECKPOINTS     128
#define MAX_RACE_NAME       32
#define CHECKPOINT_SIZE     8.0
#define RACE_REWARD_BASE    5000
#define RACE_REWARD_PER_CP  500
#define RACE_VEHICLE        411

#define RACES_INDEX         "races_index.txt"

enum E_PLAYER_STATE
{
    PSTATE_NONE = 0,
    PSTATE_CREATING,
    PSTATE_WAITING,
    PSTATE_RACING
};

enum E_RACE_DATA
{
    rUsed,
    rName[MAX_RACE_NAME],
    rCPCount,
    rVehicle
};

new gRaces[MAX_RACES][E_RACE_DATA];
new Float:gRaceCheckpoints[MAX_RACES][MAX_CHECKPOINTS][3];

new E_PLAYER_STATE:gPlayerState[MAX_PLAYERS];
new gPlayerRace[MAX_PLAYERS];
new gPlayerCPIndex[MAX_PLAYERS];
new gPlayerVehicle[MAX_PLAYERS];

new gCreatorCPCount[MAX_PLAYERS];
new Float:gCreatorCP[MAX_PLAYERS][MAX_CHECKPOINTS][3];

// Per-race session state
new gRaceCountdown[MAX_RACES];   // -1=no session, 1-15=counting, 0=race running
new gRaceSession[MAX_RACES];     // session ID to invalidate stale timer callbacks
new gRaceFinishPos[MAX_RACES];   // how many players have finished this session

// Grand Larceny freeroam
new gTotalVehiclesFromFiles;
new gPlayerCitySelection[MAX_PLAYERS];
new gPlayerHasCitySelected[MAX_PLAYERS];
new gPlayerLastCitySelectionTick[MAX_PLAYERS];

new Text:txtClassSelHelper;
new Text:txtLosSantos;
new Text:txtSanFierro;
new Text:txtLasVenturas;

forward RaceCountdownTick(raceid, sessionid);

forward Float:GetAngleToPoint(Float:x1, Float:y1, Float:x2, Float:y2);

main()
{
    print("\n----------------------------------");
    print("  Racing & Freeroam Gamemode");
    print("  (Grand Larceny + Racing)");
    print("----------------------------------\n");
}

public OnGameModeInit()
{
    SetGameModeText("Racing & Freeroam");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(1);
    SetNameTagDrawDistance(40.0);
    EnableStuntBonusForAll(0);
    DisableInteriorEnterExits();
    SetWeather(2);
    SetWorldTime(11);

    ClassSel_InitTextDraws();

    AddPlayerClass(298,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(299,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(300,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(301,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(302,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(303,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(304,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(305,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(280,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(281,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(282,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(283,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(284,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(285,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(286,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(287,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(288,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(289,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(265,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(266,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(267,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(268,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(269,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(270,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(1,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(2,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(3,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(4,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(5,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(6,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(8,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(42,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(65,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(86,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(119,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(149,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(208,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(273,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(47,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(48,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(49,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(50,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(51,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(52,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(53,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(54,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(55,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(56,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(57,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(58,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(68,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(69,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(70,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(71,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(72,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(73,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(75,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(76,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(78,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(79,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(80,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(81,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(82,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(83,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(84,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(85,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(87,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(88,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(89,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(91,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(92,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(93,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(95,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(96,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(97,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(98,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
    AddPlayerClass(99,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/trains.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    gTotalVehiclesFromFiles += LoadStaticVehiclesFromFile("vehicles/red_county.txt");
    printf("Total vehicles from files: %d", gTotalVehiclesFromFiles);

    EnsureRaceStorage();
    LoadAllRaces();

    for(new i = 0; i < MAX_RACES; i++)
    {
        gRaceCountdown[i] = -1;
        gRaceSession[i] = 0;
        gRaceFinishPos[i] = 0;
    }

    return 1;
}

public OnPlayerConnect(playerid)
{
    gPlayerState[playerid] = PSTATE_NONE;
    gPlayerRace[playerid] = -1;
    gPlayerCPIndex[playerid] = 0;
    gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    gCreatorCPCount[playerid] = 0;

    gPlayerCitySelection[playerid] = -1;
    gPlayerHasCitySelected[playerid] = 0;
    gPlayerLastCitySelectionTick[playerid] = GetTickCount();

    GameTextForPlayer(playerid, "~w~Racing & Freeroam", 3000, 4);
    SendClientMessage(playerid, COLOR_WHITE, "Welcome to {88AA88}G{FFFFFF}rand {88AA88}L{FFFFFF}arceny {FF8800}Racing{FFFFFF}!");
    SendClientMessage(playerid, COLOR_WHITE, "Create tracks: {FFFF00}/create_race{FFFFFF}, {FFFF00}/cp{FFFFFF}, {FFFF00}/editcp{FFFFFF}, {FFFF00}/rmcp{FFFFFF}, {FFFF00}/save_race [name]");
    SendClientMessage(playerid, COLOR_WHITE, "Race a track: {FFFF00}/start_race [name]{FFFFFF}  |  Cancel: {FFFF00}/cancel_race");
    SendClientMessage(playerid, COLOR_WHITE, "Spawn a car: {FFFF00}/spawn_car [name]{FFFFFF}  (e.g. /spawn_car infernus)");
    SendClientMessage(playerid, COLOR_WHITE, "Type {FFFF00}/help{FFFFFF} for a full list of commands.");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ResetPlayerRace(playerid);
    gCreatorCPCount[playerid] = 0;
    gPlayerState[playerid] = PSTATE_NONE;
    gPlayerCitySelection[playerid] = -1;
    gPlayerHasCitySelected[playerid] = 0;

    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid)) return 1;

    if(gPlayerState[playerid] == PSTATE_WAITING || gPlayerState[playerid] == PSTATE_RACING)
        return 1;

    new randSpawn = 0;

    SetPlayerInterior(playerid, 0);
    TogglePlayerClock(playerid, 0);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, 30000);

    if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid])
    {
        randSpawn = random(sizeof(gRandomSpawns_LosSantos));
        SetPlayerPos(playerid,
            gRandomSpawns_LosSantos[randSpawn][0],
            gRandomSpawns_LosSantos[randSpawn][1],
            gRandomSpawns_LosSantos[randSpawn][2]);
        SetPlayerFacingAngle(playerid, gRandomSpawns_LosSantos[randSpawn][3]);
    }
    else if(CITY_SAN_FIERRO == gPlayerCitySelection[playerid])
    {
        randSpawn = random(sizeof(gRandomSpawns_SanFierro));
        SetPlayerPos(playerid,
            gRandomSpawns_SanFierro[randSpawn][0],
            gRandomSpawns_SanFierro[randSpawn][1],
            gRandomSpawns_SanFierro[randSpawn][2]);
        SetPlayerFacingAngle(playerid, gRandomSpawns_SanFierro[randSpawn][3]);
    }
    else if(CITY_LAS_VENTURAS == gPlayerCitySelection[playerid])
    {
        randSpawn = random(sizeof(gRandomSpawns_LasVenturas));
        SetPlayerPos(playerid,
            gRandomSpawns_LasVenturas[randSpawn][0],
            gRandomSpawns_LasVenturas[randSpawn][1],
            gRandomSpawns_LasVenturas[randSpawn][2]);
        SetPlayerFacingAngle(playerid, gRandomSpawns_LasVenturas[randSpawn][3]);
    }

    GivePlayerWeapon(playerid, WEAPON_DEAGLE, 100);
    GivePlayerWeapon(playerid, WEAPON_UZI, 100);
    TogglePlayerClock(playerid, 0);

    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(gPlayerState[playerid] == PSTATE_RACING)
    {
        SendClientMessage(playerid, COLOR_RED, "You died and failed the race. Use /start_race to try again.");
        ResetPlayerRace(playerid);
        return 1;
    }

    gPlayerHasCitySelected[playerid] = 0;

    if(killerid == INVALID_PLAYER_ID)
    {
        ResetPlayerMoney(playerid);
    }
    else
    {
        new playercash = GetPlayerMoney(playerid);
        if(playercash > 0)
        {
            GivePlayerMoney(killerid, playercash);
            ResetPlayerMoney(playerid);
        }
    }

    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid)) return 1;

    if(gPlayerHasCitySelected[playerid])
    {
        ClassSel_SetupCharSelection(playerid);
        return 1;
    }

    if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
    {
        TogglePlayerSpectating(playerid, 1);
        TextDrawShowForPlayer(playerid, txtClassSelHelper);
        gPlayerCitySelection[playerid] = -1;
    }

    return 0;
}

public OnPlayerUpdate(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    if(IsPlayerNPC(playerid)) return 1;

    if(!gPlayerHasCitySelected[playerid] &&
        GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
    {
        ClassSel_HandleCitySelection(playerid);
        return 1;
    }

    if(GetPlayerWeapon(playerid) == WEAPON_MINIGUN)
    {
        Kick(playerid);
        return 0;
    }

    return 1;
}

stock TeleportPlayerToCoords(playerid, Float:x, Float:y)
{
    SetPlayerPos(playerid, x, y, 500.0);
    SetPlayerPosFindZ(playerid, x, y, 500.0);
}

stock TeleportVehicleWithPlayer(playerid, vehicleid, Float:x, Float:y)
{
    new Float:angle;
    GetVehicleZAngle(vehicleid, angle);

    SetVehiclePos(vehicleid, x, y, 500.0);
    SetVehicleZAngle(vehicleid, angle);
    SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);

    RemovePlayerFromVehicle(playerid);
    SetPlayerPos(playerid, x, y, 500.0);
    SetPlayerPosFindZ(playerid, x, y, 500.0);

    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);

    SetVehiclePos(vehicleid, px, py, pz);
    SetVehicleZAngle(vehicleid, angle);
    SetVehicleVelocity(vehicleid, 0.0, 0.0, 0.0);
    LinkVehicleToInterior(vehicleid, GetPlayerInterior(playerid));
    SetVehicleVirtualWorld(vehicleid, GetPlayerVirtualWorld(playerid));
    PutPlayerInVehicle(playerid, vehicleid, 0);
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if(gPlayerState[playerid] != PSTATE_RACING && IsPlayerInAnyVehicle(playerid))
    {
        TeleportVehicleWithPlayer(playerid, GetPlayerVehicleID(playerid), fX, fY);
    }
    else
    {
        TeleportPlayerToCoords(playerid, fX, fY);
    }

    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if(gPlayerState[playerid] != PSTATE_RACING) return 1;

    new raceid = gPlayerRace[playerid];
    if(raceid < 0 || !gRaces[raceid][rUsed]) return 1;

    new cpCount = gRaces[raceid][rCPCount];
    new cpIndex = gPlayerCPIndex[playerid];

    if(cpIndex >= cpCount) return 1;

    if(cpIndex < cpCount - 1)
    {
        gPlayerCPIndex[playerid]++;
        ShowRaceCheckpoint(playerid, raceid, gPlayerCPIndex[playerid]);

        new msg[96];
        format(msg, sizeof(msg), "Checkpoint %d/%d reached.", gPlayerCPIndex[playerid], cpCount);
        SendClientMessage(playerid, COLOR_GREEN, msg);
    }
    else
    {
        new baseReward = RACE_REWARD_BASE + (cpCount * RACE_REWARD_PER_CP);
        new finishPos = gRaceFinishPos[raceid] + 1;
        gRaceFinishPos[raceid]++;

        new pct;
        if(finishPos == 1)      pct = 100;
        else if(finishPos == 2) pct = 75;
        else if(finishPos == 3) pct = 50;
        else                    pct = 25;
        new reward = (baseReward * pct) / 100;
        GivePlayerMoney(playerid, reward);

        new posStr[8];
        if(finishPos == 1)      format(posStr, sizeof(posStr), "1st");
        else if(finishPos == 2) format(posStr, sizeof(posStr), "2nd");
        else if(finishPos == 3) format(posStr, sizeof(posStr), "3rd");
        else                    format(posStr, sizeof(posStr), "%dth", finishPos);

        new msg[128];
        format(msg, sizeof(msg), "Race complete! You finished %s and earned $%d.", posStr, reward);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        GameTextForPlayer(playerid, "~g~Race complete!", 3000, 5);

        new pname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pname, sizeof(pname));
        new announce[128];
        format(announce, sizeof(announce), "%s finished %s in \"%s\" and earned $%d!", pname, posStr, gRaces[raceid][rName], reward);
        SendClientMessageToAll(COLOR_YELLOW, announce);

        ResetPlayerRace(playerid, true);
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new idx;
    new cmd[256];
    new params[256];

    cmd = strtok(cmdtext, idx);
    params = strtok(cmdtext, idx);

    if(strcmp(cmd, "/create_race", true) == 0)
    {
        if(gPlayerState[playerid] == PSTATE_RACING)
        {
            SendClientMessage(playerid, COLOR_RED, "Finish or cancel your current race first (/cancel_race).");
            return 1;
        }

        ResetPlayerRace(playerid, true);
        gPlayerState[playerid] = PSTATE_CREATING;
        gCreatorCPCount[playerid] = 0;
        SyncPlayerVehicleFromSeat(playerid);

        SendClientMessage(playerid, COLOR_GREEN, "Race creation started. Drive to each point and use /cp to place checkpoints.");
        SendClientMessage(playerid, COLOR_GREEN, "Use /editcp to move or /rmcp to remove the last checkpoint. When done: /save_race [name] [vehicle]  |  Abort: /cancel_race");
        return 1;
    }

    if(strcmp(cmd, "/cp", true) == 0)
    {
        if(gPlayerState[playerid] != PSTATE_CREATING)
        {
            SendClientMessage(playerid, COLOR_RED, "You are not creating a race. Use /create_race first.");
            return 1;
        }

        if(gCreatorCPCount[playerid] >= MAX_CHECKPOINTS)
        {
            SendClientMessage(playerid, COLOR_RED, "Maximum number of checkpoints reached for one race.");
            return 1;
        }

        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        new cp = gCreatorCPCount[playerid];
        gCreatorCP[playerid][cp][0] = x;
        gCreatorCP[playerid][cp][1] = y;
        gCreatorCP[playerid][cp][2] = z;
        gCreatorCPCount[playerid]++;

        new msg[96];
        format(msg, sizeof(msg), "Checkpoint %d placed at your position.", cp + 1);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        ShowCreatorCheckpoints(playerid);
        return 1;
    }

    if(strcmp(cmd, "/editcp", true) == 0)
    {
        if(gPlayerState[playerid] != PSTATE_CREATING)
        {
            SendClientMessage(playerid, COLOR_RED, "You are not creating a race. Use /create_race first.");
            return 1;
        }

        if(gCreatorCPCount[playerid] < 1)
        {
            SendClientMessage(playerid, COLOR_RED, "No checkpoints placed yet. Use /cp first.");
            return 1;
        }

        new cp = gCreatorCPCount[playerid] - 1;
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);

        gCreatorCP[playerid][cp][0] = x;
        gCreatorCP[playerid][cp][1] = y;
        gCreatorCP[playerid][cp][2] = z;

        new msg[96];
        format(msg, sizeof(msg), "Checkpoint %d moved to your position.", cp + 1);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        ShowCreatorCheckpoints(playerid);
        return 1;
    }

    if(strcmp(cmd, "/rmcp", true) == 0)
    {
        if(gPlayerState[playerid] != PSTATE_CREATING)
        {
            SendClientMessage(playerid, COLOR_RED, "You are not creating a race. Use /create_race first.");
            return 1;
        }

        if(gCreatorCPCount[playerid] < 1)
        {
            SendClientMessage(playerid, COLOR_RED, "No checkpoints to remove. Use /cp first.");
            return 1;
        }

        gCreatorCPCount[playerid]--;

        new msg[96];
        format(msg, sizeof(msg), "Checkpoint %d removed. %d checkpoint(s) remaining.", gCreatorCPCount[playerid] + 1, gCreatorCPCount[playerid]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        ShowCreatorCheckpoints(playerid);
        return 1;
    }

    if(strcmp(cmd, "/save_race", true) == 0)
    {
        if(gPlayerState[playerid] != PSTATE_CREATING)
        {
            SendClientMessage(playerid, COLOR_RED, "You are not creating a race. Use /create_race first.");
            return 1;
        }

        if(!strlen(params))
        {
            SendClientMessage(playerid, COLOR_RED, "Usage: /save_race [race_name] [vehicle]");
            return 1;
        }

        if(gCreatorCPCount[playerid] < 2)
        {
            SendClientMessage(playerid, COLOR_RED, "You need at least 2 checkpoints before saving a race.");
            return 1;
        }

        new raceName[MAX_RACE_NAME];
        if(!NormalizeRaceName(params, raceName, sizeof(raceName)))
        {
            SendClientMessage(playerid, COLOR_RED, "Invalid race name. Use letters, numbers, and underscores only.");
            return 1;
        }

        new vehicleArg[64];
        format(vehicleArg, sizeof(vehicleArg), "%s", strtok(cmdtext, idx));
        if(!strlen(vehicleArg))
        {
            SendClientMessage(playerid, COLOR_RED, "Usage: /save_race [race_name] [vehicle]  (e.g. /save_race highway infernus)");
            return 1;
        }

        new raceVehicle = GetVehicleModelFromInput(vehicleArg);
        if(raceVehicle == -1)
        {
            SendClientMessage(playerid, COLOR_RED, "Unknown vehicle name. Example: infernus, sultan, nrg500");
            return 1;
        }

        new raceid = FindRaceByName(raceName);
        if(raceid == -1)
        {
            raceid = GetFreeRaceSlot();
            if(raceid == -1)
            {
                SendClientMessage(playerid, COLOR_RED, "Server race limit reached. Delete a race before saving a new one.");
                return 1;
            }
        }

        gRaces[raceid][rUsed] = true;
        format(gRaces[raceid][rName], MAX_RACE_NAME, "%s", raceName);
        gRaces[raceid][rCPCount] = gCreatorCPCount[playerid];
        gRaces[raceid][rVehicle] = raceVehicle;

        for(new i = 0; i < gCreatorCPCount[playerid]; i++)
        {
            gRaceCheckpoints[raceid][i][0] = gCreatorCP[playerid][i][0];
            gRaceCheckpoints[raceid][i][1] = gCreatorCP[playerid][i][1];
            gRaceCheckpoints[raceid][i][2] = gCreatorCP[playerid][i][2];
        }

        if(!SaveRaceToFile(raceid))
        {
            SendClientMessage(playerid, COLOR_RED, "Failed to save the race file.");
            return 1;
        }

        AddRaceToIndex(raceName);

        DisablePlayerRaceCheckpoint(playerid);
        DisablePlayerCheckpoint(playerid);
        gCreatorCPCount[playerid] = 0;
        gPlayerState[playerid] = PSTATE_NONE;
        SyncPlayerVehicleFromSeat(playerid);

        new msg[128];
        format(msg, sizeof(msg), "Race \"%s\" saved with %d checkpoints (%s).", raceName, gRaces[raceid][rCPCount], gVehicleNames[raceVehicle - MIN_VEHICLE_MODEL]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }

    if(strcmp(cmd, "/start_race", true) == 0)
    {
        if(gPlayerState[playerid] == PSTATE_CREATING)
        {
            SendClientMessage(playerid, COLOR_RED, "Finish or cancel race creation first (/save_race or /cancel_race).");
            return 1;
        }

        if(gPlayerState[playerid] == PSTATE_WAITING || gPlayerState[playerid] == PSTATE_RACING)
        {
            SendClientMessage(playerid, COLOR_RED, "You are already in a race. Use /cancel_race to leave.");
            return 1;
        }

        if(!strlen(params))
        {
            SendClientMessage(playerid, COLOR_RED, "Usage: /start_race [race_name]");
            return 1;
        }

        new raceName[MAX_RACE_NAME];
        if(!NormalizeRaceName(params, raceName, sizeof(raceName)))
        {
            SendClientMessage(playerid, COLOR_RED, "Invalid race name.");
            return 1;
        }

        new raceid = FindRaceByName(raceName);
        if(raceid == -1)
        {
            SendClientMessage(playerid, COLOR_RED, "That race does not exist.");
            return 1;
        }

        if(gRaceCountdown[raceid] == 0)
        {
            SendClientMessage(playerid, COLOR_RED, "That race is already running. Wait for the next session.");
            return 1;
        }

        new Float:sx = gRaceCheckpoints[raceid][0][0];
        new Float:sy = gRaceCheckpoints[raceid][0][1];
        new Float:sz = gRaceCheckpoints[raceid][0][2];
        new Float:angle = 0.0;

        if(gRaces[raceid][rCPCount] > 1)
            angle = GetAngleToPoint(sx, sy, gRaceCheckpoints[raceid][1][0], gRaceCheckpoints[raceid][1][1]);

        // Count existing waiters to compute a grid spawn slot
        new waiterSlot = 0;
        for(new wi = 0; wi < MAX_PLAYERS; wi++)
        {
            if(!IsPlayerConnected(wi) || wi == playerid) continue;
            if(gPlayerState[wi] == PSTATE_WAITING && gPlayerRace[wi] == raceid)
                waiterSlot++;
        }

        // Spread players sideways from the start (alternating left/right)
        new Float:perpAngle = angle - 90.0;
        new Float:sideOff;
        if(waiterSlot % 2 == 0)
            sideOff = float(waiterSlot / 2) * 5.0;
        else
            sideOff = -(float(waiterSlot / 2) + 1.0) * 5.0;
        new Float:spawnX = sx + sideOff * floatsin(-perpAngle, degrees);
        new Float:spawnY = sy + sideOff * floatcos(-perpAngle, degrees);

        ResetPlayerRace(playerid);

        if(gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(gPlayerVehicle[playerid]);
            gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
        }

        gPlayerVehicle[playerid] = CreateVehicle(gRaces[raceid][rVehicle], spawnX, spawnY, sz, angle, -1, -1, -1);
        PutPlayerInVehicle(playerid, gPlayerVehicle[playerid], 0);
        TogglePlayerControllable(playerid, 0);

        gPlayerState[playerid] = PSTATE_WAITING;
        gPlayerRace[playerid] = raceid;
        gPlayerCPIndex[playerid] = 0;

        new pname[MAX_PLAYER_NAME];
        GetPlayerName(playerid, pname, sizeof(pname));

        if(gRaceCountdown[raceid] == -1)
        {
            gRaceCountdown[raceid] = 15;
            gRaceSession[raceid]++;
            SetTimerEx("RaceCountdownTick", 1000, false, "ii", raceid, gRaceSession[raceid]);

            new msg[128];
            format(msg, sizeof(msg), "%s started a session for \"%s\"! Use /start_race %s to join (%ds countdown)", pname, raceName, raceName, gRaceCountdown[raceid]);
            SendClientMessageToAll(COLOR_YELLOW, msg);
        }
        else
        {
            new msg[128];
            format(msg, sizeof(msg), "%s joined \"%s\"! (%ds remaining - /start_race %s to join)", pname, raceName, gRaceCountdown[raceid], raceName);
            SendClientMessageToAll(COLOR_YELLOW, msg);
        }

        new countdownTxt[16];
        format(countdownTxt, sizeof(countdownTxt), "~y~%d", gRaceCountdown[raceid]);
        GameTextForPlayer(playerid, countdownTxt, 1500, 3);

        return 1;
    }

    if(strcmp(cmd, "/cancel_race", true) == 0)
    {
        if(gPlayerState[playerid] == PSTATE_NONE)
        {
            SendClientMessage(playerid, COLOR_RED, "You are not creating or running a race.");
            return 1;
        }

        ResetPlayerRace(playerid);
        gCreatorCPCount[playerid] = 0;
        gPlayerState[playerid] = PSTATE_NONE;

        SendClientMessage(playerid, COLOR_YELLOW, "Race creation/run cancelled.");
        return 1;
    }

    if(strcmp(cmd, "/list_races", true) == 0)
    {
        new found = 0;
        SendClientMessage(playerid, COLOR_WHITE, "Available races:");

        for(new i = 0; i < MAX_RACES; i++)
        {
            if(!gRaces[i][rUsed]) continue;

            new msg[96];
            format(msg, sizeof(msg), "- %s (%d checkpoints, %s)", gRaces[i][rName], gRaces[i][rCPCount], gVehicleNames[gRaces[i][rVehicle] - MIN_VEHICLE_MODEL]);
            SendClientMessage(playerid, COLOR_YELLOW, msg);
            found++;
        }

        if(!found)
        {
            SendClientMessage(playerid, COLOR_RED, "No races saved yet. Create one with /create_race.");
        }

        return 1;
    }

    if(strcmp(cmd, "/spawn_car", true) == 0)
    {
        if(gPlayerState[playerid] == PSTATE_RACING)
        {
            SendClientMessage(playerid, COLOR_RED, "You cannot spawn a car while racing. Finish or cancel first (/cancel_race).");
            return 1;
        }

        if(!strlen(params))
        {
            SendClientMessage(playerid, COLOR_RED, "Usage: /spawn_car [vehicle name]");
            return 1;
        }

        new modelInput[64];
        if(!GetCommandArgument(cmdtext, modelInput, sizeof(modelInput)))
        {
            SendClientMessage(playerid, COLOR_RED, "Usage: /spawn_car [vehicle name]");
            return 1;
        }

        new modelid = GetVehicleModelFromInput(modelInput);
        if(modelid == -1)
        {
            SendClientMessage(playerid, COLOR_RED, "Unknown vehicle. Example: /spawn_car infernus");
            return 1;
        }

        if(!SpawnPlayerVehicle(playerid, modelid))
        {
            SendClientMessage(playerid, COLOR_RED, "Failed to spawn the vehicle.");
            return 1;
        }

        new msg[64];
        format(msg, sizeof(msg), "%s spawned.", gVehicleNames[modelid - MIN_VEHICLE_MODEL]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        return 1;
    }

    if(strcmp(cmd, "/help", true) == 0)
    {
        ShowPlayerHelp(playerid);
        return 1;
    }

    return 0;
}

ShowPlayerHelp(playerid)
{
    SendClientMessage(playerid, COLOR_WHITE, "========== {FF8800}Racing Server Commands{FFFFFF} ==========");
    SendClientMessage(playerid, COLOR_YELLOW, "/create_race {FFFFFF}- Start creating a new race track");
    SendClientMessage(playerid, COLOR_YELLOW, "/cp {FFFFFF}- Place a checkpoint at your position (while creating)");
    SendClientMessage(playerid, COLOR_YELLOW, "/editcp {FFFFFF}- Move the last checkpoint to your position (while creating)");
    SendClientMessage(playerid, COLOR_YELLOW, "/rmcp {FFFFFF}- Remove the last checkpoint (while creating)");
    SendClientMessage(playerid, COLOR_YELLOW, "/save_race [name] [vehicle] {FFFFFF}- Save the track (e.g. /save_race highway infernus)");
    SendClientMessage(playerid, COLOR_YELLOW, "/start_race [name] {FFFFFF}- Join/start a race (15s countdown, others can join)");
    SendClientMessage(playerid, COLOR_YELLOW, "/cancel_race {FFFFFF}- Cancel race creation or an active race");
    SendClientMessage(playerid, COLOR_YELLOW, "/list_races {FFFFFF}- Show all saved race tracks");
    SendClientMessage(playerid, COLOR_YELLOW, "/spawn_car [name] {FFFFFF}- Spawn a vehicle by name (not while racing)");
    SendClientMessage(playerid, COLOR_YELLOW, "/help {FFFFFF}- Show this command list");
    SendClientMessage(playerid, COLOR_WHITE, "==============================================");
}

ResetPlayerRace(playerid, bool:keepVehicle = false)
{
    DisablePlayerRaceCheckpoint(playerid);
    DisablePlayerCheckpoint(playerid);
    TogglePlayerControllable(playerid, 1);

    if(!keepVehicle && gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(gPlayerVehicle[playerid]);
        gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    }

    // If the player was actively racing, check whether the session is now empty
    if(gPlayerState[playerid] == PSTATE_RACING)
    {
        new raceid = gPlayerRace[playerid];
        if(raceid >= 0 && gRaceCountdown[raceid] == 0)
        {
            new stillRacing = 0;
            for(new i = 0; i < MAX_PLAYERS; i++)
            {
                if(!IsPlayerConnected(i) || i == playerid) continue;
                if(gPlayerState[i] == PSTATE_RACING && gPlayerRace[i] == raceid)
                    stillRacing++;
            }
            if(stillRacing == 0)
            {
                gRaceCountdown[raceid] = -1;
                gRaceFinishPos[raceid] = 0;
            }
        }
    }

    gPlayerRace[playerid] = -1;
    gPlayerCPIndex[playerid] = 0;

    if(gPlayerState[playerid] == PSTATE_RACING || gPlayerState[playerid] == PSTATE_WAITING)
        gPlayerState[playerid] = PSTATE_NONE;
}

public RaceCountdownTick(raceid, sessionid)
{
    if(sessionid != gRaceSession[raceid]) return 0;

    gRaceCountdown[raceid]--;

    if(gRaceCountdown[raceid] > 0)
    {
        new countdownTxt[16];
        format(countdownTxt, sizeof(countdownTxt), "~y~%d", gRaceCountdown[raceid]);

        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!IsPlayerConnected(i)) continue;
            if(gPlayerState[i] == PSTATE_WAITING && gPlayerRace[i] == raceid)
                GameTextForPlayer(i, countdownTxt, 1500, 3);
        }

        SetTimerEx("RaceCountdownTick", 1000, false, "ii", raceid, sessionid);
    }
    else
    {
        // Countdown finished - launch all waiting players
        gRaceCountdown[raceid] = 0;
        gRaceFinishPos[raceid] = 0;

        new launched = 0;
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(!IsPlayerConnected(i)) continue;
            if(gPlayerState[i] != PSTATE_WAITING || gPlayerRace[i] != raceid) continue;

            gPlayerState[i] = PSTATE_RACING;
            gPlayerCPIndex[i] = 0;
            TogglePlayerControllable(i, 1);
            ShowRaceCheckpoint(i, raceid, 0);
            GameTextForPlayer(i, "~g~GO!", 2000, 3);
            launched++;
        }

        if(launched == 0)
            gRaceCountdown[raceid] = -1;
    }
    return 1;
}

SyncPlayerVehicleFromSeat(playerid)
{
    if(IsPlayerInAnyVehicle(playerid))
        gPlayerVehicle[playerid] = GetPlayerVehicleID(playerid);
}

SpawnPlayerVehicle(playerid, modelid)
{
    if(gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(gPlayerVehicle[playerid]);
        gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    }

    new Float:x, Float:y, Float:z, Float:facing;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, facing);

    new Float:size_x, Float:size_y, Float:size_z;
    GetVehicleModelInfo(modelid, VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);

    new Float:distance = size_x + 0.5;
    x += (distance * floatsin(-facing, degrees));
    y += (distance * floatcos(-facing, degrees));

    facing += 90.0;
    if(facing > 360.0) facing -= 360.0;

    new vehicleid = CreateVehicle(modelid, x, y, z + (size_z * 0.25), facing, -1, -1, -1);
    if(vehicleid == INVALID_VEHICLE_ID) return 0;

    gPlayerVehicle[playerid] = vehicleid;
    PutPlayerInVehicle(playerid, vehicleid, 0);
    return 1;
}

GetCommandArgument(const cmdtext[], dest[], size)
{
    new pos = strfind(cmdtext, " ", false);
    if(pos == -1)
    {
        dest[0] = EOS;
        return 0;
    }

    pos++;
    while(cmdtext[pos] == ' ') pos++;

    if(cmdtext[pos] == EOS)
    {
        dest[0] = EOS;
        return 0;
    }

    format(dest, size, "%s", cmdtext[pos]);
    return 1;
}

GetVehicleModelFromInput(const input[])
{
    if(IsNumericString(input))
    {
        new modelid = strval(input);
        if(modelid >= MIN_VEHICLE_MODEL && modelid <= MAX_VEHICLE_MODEL)
        {
            return modelid;
        }
        return -1;
    }

    for(new i = 0; i < VEHICLE_NAME_COUNT; i++)
    {
        if(!strcmp(gVehicleNames[i], input, true))
        {
            return MIN_VEHICLE_MODEL + i;
        }
    }

    for(new i = 0; i < VEHICLE_NAME_COUNT; i++)
    {
        if(strfind(gVehicleNames[i], input, true) != -1)
        {
            return MIN_VEHICLE_MODEL + i;
        }
    }

    return -1;
}

IsNumericString(const str[])
{
    if(!strlen(str)) return 0;

    for(new i = 0; str[i]; i++)
    {
        if(str[i] < '0' || str[i] > '9') return 0;
    }

    return 1;
}

ClassSel_SetupCharSelection(playerid)
{
    if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS)
    {
        SetPlayerInterior(playerid, 11);
        SetPlayerPos(playerid, 508.7362, -87.4335, 998.9609);
        SetPlayerFacingAngle(playerid, 0.0);
        SetPlayerCameraPos(playerid, 508.7362, -83.4335, 998.9609);
        SetPlayerCameraLookAt(playerid, 508.7362, -87.4335, 998.9609);
    }
    else if(gPlayerCitySelection[playerid] == CITY_SAN_FIERRO)
    {
        SetPlayerInterior(playerid, 3);
        SetPlayerPos(playerid, -2673.8381, 1399.7424, 918.3516);
        SetPlayerFacingAngle(playerid, 181.0);
        SetPlayerCameraPos(playerid, -2673.2776, 1394.3859, 918.3516);
        SetPlayerCameraLookAt(playerid, -2673.8381, 1399.7424, 918.3516);
    }
    else if(gPlayerCitySelection[playerid] == CITY_LAS_VENTURAS)
    {
        SetPlayerInterior(playerid, 3);
        SetPlayerPos(playerid, 349.0453, 193.2271, 1014.1797);
        SetPlayerFacingAngle(playerid, 286.25);
        SetPlayerCameraPos(playerid, 352.9164, 194.5702, 1014.1875);
        SetPlayerCameraLookAt(playerid, 349.0453, 193.2271, 1014.1797);
    }
}

ClassSel_InitCityNameText(Text:txtInit)
{
    TextDrawUseBox(txtInit, 0);
    TextDrawLetterSize(txtInit, 1.25, 3.0);
    TextDrawFont(txtInit, 0);
    TextDrawSetShadow(txtInit, 0);
    TextDrawSetOutline(txtInit, 1);
    TextDrawColor(txtInit, 0xEEEEEEFF);
    TextDrawBackgroundColor(txtClassSelHelper, 0x000000FF);
}

ClassSel_InitTextDraws()
{
    txtLosSantos = TextDrawCreate(10.0, 380.0, "Los Santos");
    ClassSel_InitCityNameText(txtLosSantos);
    txtSanFierro = TextDrawCreate(10.0, 380.0, "San Fierro");
    ClassSel_InitCityNameText(txtSanFierro);
    txtLasVenturas = TextDrawCreate(10.0, 380.0, "Las Venturas");
    ClassSel_InitCityNameText(txtLasVenturas);

    txtClassSelHelper = TextDrawCreate(10.0, 415.0,
        " Press ~b~~k~~GO_LEFT~ ~w~or ~b~~k~~GO_RIGHT~ ~w~to switch cities.~n~ Press ~r~~k~~PED_FIREWEAPON~ ~w~to select.");
    TextDrawUseBox(txtClassSelHelper, 1);
    TextDrawBoxColor(txtClassSelHelper, 0x222222BB);
    TextDrawLetterSize(txtClassSelHelper, 0.3, 1.0);
    TextDrawTextSize(txtClassSelHelper, 400.0, 40.0);
    TextDrawFont(txtClassSelHelper, 2);
    TextDrawSetShadow(txtClassSelHelper, 0);
    TextDrawSetOutline(txtClassSelHelper, 1);
    TextDrawBackgroundColor(txtClassSelHelper, 0x000000FF);
    TextDrawColor(txtClassSelHelper, 0xFFFFFFFF);
}

ClassSel_SetupSelectedCity(playerid)
{
    if(gPlayerCitySelection[playerid] == -1)
        gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;

    if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS)
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerCameraPos(playerid, 1630.6136, -2286.0298, 110.0);
        SetPlayerCameraLookAt(playerid, 1887.6034, -1682.1442, 47.6167);

        TextDrawShowForPlayer(playerid, txtLosSantos);
        TextDrawHideForPlayer(playerid, txtSanFierro);
        TextDrawHideForPlayer(playerid, txtLasVenturas);
    }
    else if(gPlayerCitySelection[playerid] == CITY_SAN_FIERRO)
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerCameraPos(playerid, -1300.8754, 68.0546, 129.4823);
        SetPlayerCameraLookAt(playerid, -1817.9412, 769.3878, 132.6589);

        TextDrawHideForPlayer(playerid, txtLosSantos);
        TextDrawShowForPlayer(playerid, txtSanFierro);
        TextDrawHideForPlayer(playerid, txtLasVenturas);
    }
    else if(gPlayerCitySelection[playerid] == CITY_LAS_VENTURAS)
    {
        SetPlayerInterior(playerid, 0);
        SetPlayerCameraPos(playerid, 1310.6155, 1675.9182, 110.7390);
        SetPlayerCameraLookAt(playerid, 2285.2944, 1919.3756, 68.2275);

        TextDrawHideForPlayer(playerid, txtLosSantos);
        TextDrawHideForPlayer(playerid, txtSanFierro);
        TextDrawShowForPlayer(playerid, txtLasVenturas);
    }
}

ClassSel_SwitchToNextCity(playerid)
{
    gPlayerCitySelection[playerid]++;
    if(gPlayerCitySelection[playerid] > CITY_LAS_VENTURAS)
        gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
    PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
    gPlayerLastCitySelectionTick[playerid] = GetTickCount();
    ClassSel_SetupSelectedCity(playerid);
}

ClassSel_SwitchToPreviousCity(playerid)
{
    gPlayerCitySelection[playerid]--;
    if(gPlayerCitySelection[playerid] < CITY_LOS_SANTOS)
        gPlayerCitySelection[playerid] = CITY_LAS_VENTURAS;
    PlayerPlaySound(playerid, 1053, 0.0, 0.0, 0.0);
    gPlayerLastCitySelectionTick[playerid] = GetTickCount();
    ClassSel_SetupSelectedCity(playerid);
}

ClassSel_HandleCitySelection(playerid)
{
    new Keys, ud, lr;
    GetPlayerKeys(playerid, Keys, ud, lr);

    if(gPlayerCitySelection[playerid] == -1)
    {
        ClassSel_SwitchToNextCity(playerid);
        return;
    }

    if((GetTickCount() - gPlayerLastCitySelectionTick[playerid]) < 500) return;

    if(Keys & KEY_FIRE)
    {
        gPlayerHasCitySelected[playerid] = 1;
        TextDrawHideForPlayer(playerid, txtClassSelHelper);
        TextDrawHideForPlayer(playerid, txtLosSantos);
        TextDrawHideForPlayer(playerid, txtSanFierro);
        TextDrawHideForPlayer(playerid, txtLasVenturas);
        TogglePlayerSpectating(playerid, 0);
        return;
    }

    if(lr > 0)
        ClassSel_SwitchToNextCity(playerid);
    else if(lr < 0)
        ClassSel_SwitchToPreviousCity(playerid);
}

ShowCreatorCheckpoints(playerid)
{
    new count = gCreatorCPCount[playerid];
    if(count < 1)
    {
        DisablePlayerRaceCheckpoint(playerid);
        DisablePlayerCheckpoint(playerid);
        return;
    }

    new last = count - 1;
    new Float:lx = gCreatorCP[playerid][last][0];
    new Float:ly = gCreatorCP[playerid][last][1];
    new Float:lz = gCreatorCP[playerid][last][2];

    if(count >= 2)
    {
        new prev = count - 2;
        new Float:px = gCreatorCP[playerid][prev][0];
        new Float:py = gCreatorCP[playerid][prev][1];
        new Float:pz = gCreatorCP[playerid][prev][2];

        SetPlayerCheckpoint(playerid, px, py, pz, CHECKPOINT_SIZE);
        SetPlayerRaceCheckpoint(playerid, 1, lx, ly, lz, lx, ly, lz, CHECKPOINT_SIZE);
    }
    else
    {
        DisablePlayerCheckpoint(playerid);
        SetPlayerRaceCheckpoint(playerid, 1, lx, ly, lz, lx, ly, lz, CHECKPOINT_SIZE);
    }
}

ShowRaceCheckpoint(playerid, raceid, cpIndex)
{
    new cpCount = gRaces[raceid][rCPCount];

    new Float:x = gRaceCheckpoints[raceid][cpIndex][0];
    new Float:y = gRaceCheckpoints[raceid][cpIndex][1];
    new Float:z = gRaceCheckpoints[raceid][cpIndex][2];

    if(cpIndex < cpCount - 1)
    {
        new Float:nx = gRaceCheckpoints[raceid][cpIndex + 1][0];
        new Float:ny = gRaceCheckpoints[raceid][cpIndex + 1][1];
        new Float:nz = gRaceCheckpoints[raceid][cpIndex + 1][2];
        SetPlayerRaceCheckpoint(playerid, 0, x, y, z, nx, ny, nz, CHECKPOINT_SIZE);
    }
    else
    {
        SetPlayerRaceCheckpoint(playerid, 1, x, y, z, x, y, z, CHECKPOINT_SIZE);
    }
}

Float:GetAngleToPoint(Float:x1, Float:y1, Float:x2, Float:y2)
{
    return atan2(y2 - y1, x2 - x1) - 90.0;
}

GetFreeRaceSlot()
{
    for(new i = 0; i < MAX_RACES; i++)
    {
        if(!gRaces[i][rUsed]) return i;
    }
    return -1;
}

FindRaceByName(const name[])
{
    for(new i = 0; i < MAX_RACES; i++)
    {
        if(!gRaces[i][rUsed]) continue;
        if(!strcmp(gRaces[i][rName], name, true)) return i;
    }
    return -1;
}

NormalizeRaceName(const input[], dest[], size)
{
    if(strlen(input) < 1 || strlen(input) >= MAX_RACE_NAME) return 0;

    for(new i = 0; input[i]; i++)
    {
        if((input[i] >= 'a' && input[i] <= 'z') ||
           (input[i] >= 'A' && input[i] <= 'Z') ||
           (input[i] >= '0' && input[i] <= '9') ||
           input[i] == '_')
        {
            continue;
        }
        return 0;
    }

    format(dest, size, "%s", input);
    return 1;
}

GetRaceFilePath(const raceName[], dest[], size)
{
    format(dest, size, "race_%s.race", raceName);
}

EnsureRaceStorage()
{
    if(!fexist(RACES_INDEX))
    {
        new File:file = fopen(RACES_INDEX, io_write);
        if(file) fclose(file);
    }
}

LoadAllRaces()
{
    if(!fexist(RACES_INDEX)) return;

    new File:file = fopen(RACES_INDEX, io_read);
    if(!file) return;

    new line[MAX_RACE_NAME];

    while(fread(file, line))
    {
        TrimNewline(line);

        if(strlen(line) < 1) continue;
        if(FindRaceByName(line) != -1) continue;

        new raceid = GetFreeRaceSlot();
        if(raceid == -1) break;

        if(LoadRaceFromFile(line, raceid))
        {
            gRaces[raceid][rUsed] = true;
            format(gRaces[raceid][rName], MAX_RACE_NAME, "%s", line);
        }
    }

    fclose(file);
}

LoadRaceFromFile(const raceName[], raceid)
{
    new path[96];
    GetRaceFilePath(raceName, path, sizeof(path));

    if(!fexist(path)) return 0;

    new File:file = fopen(path, io_read);
    if(!file) return 0;

    new line[128];
    if(!fread(file, line))
    {
        fclose(file);
        return 0;
    }

    new firstIdx;
    new cpToken[16];
    format(cpToken, sizeof(cpToken), "%s", strtok(line, firstIdx));
    new cpCount = strval(cpToken);
    if(cpCount < 2 || cpCount > MAX_CHECKPOINTS)
    {
        fclose(file);
        return 0;
    }

    new vehicleToken[16];
    format(vehicleToken, sizeof(vehicleToken), "%s", strtok(line, firstIdx));
    new vehicleModel = strlen(vehicleToken) ? strval(vehicleToken) : RACE_VEHICLE;
    if(vehicleModel < MIN_VEHICLE_MODEL || vehicleModel > MAX_VEHICLE_MODEL)
        vehicleModel = RACE_VEHICLE;

    gRaces[raceid][rCPCount] = cpCount;
    gRaces[raceid][rVehicle] = vehicleModel;

    for(new i = 0; i < cpCount; i++)
    {
        if(!fread(file, line))
        {
            fclose(file);
            return 0;
        }

        if(!ParseCheckpointLine(line, gRaceCheckpoints[raceid][i][0], gRaceCheckpoints[raceid][i][1], gRaceCheckpoints[raceid][i][2]))
        {
            fclose(file);
            return 0;
        }
    }

    fclose(file);
    return 1;
}

SaveRaceToFile(raceid)
{
    new path[96];
    GetRaceFilePath(gRaces[raceid][rName], path, sizeof(path));

    new File:file = fopen(path, io_write);
    if(!file) return 0;

    new line[128];
    format(line, sizeof(line), "%d %d\r\n", gRaces[raceid][rCPCount], gRaces[raceid][rVehicle]);
    fwrite(file, line);

    for(new i = 0; i < gRaces[raceid][rCPCount]; i++)
    {
        format(line, sizeof(line), "%.4f %.4f %.4f\r\n",
            gRaceCheckpoints[raceid][i][0],
            gRaceCheckpoints[raceid][i][1],
            gRaceCheckpoints[raceid][i][2]);
        fwrite(file, line);
    }

    fclose(file);
    return 1;
}

AddRaceToIndex(const raceName[])
{
    if(!fexist(RACES_INDEX))
    {
        new File:create = fopen(RACES_INDEX, io_write);
        if(!create) return 0;
        fclose(create);
    }

    new File:read = fopen(RACES_INDEX, io_read);
    if(read)
    {
        new line[MAX_RACE_NAME];
        while(fread(read, line))
        {
            TrimNewline(line);
            if(!strcmp(line, raceName, true))
            {
                fclose(read);
                return 1;
            }
        }
        fclose(read);
    }

    new File:append = fopen(RACES_INDEX, io_append);
    if(!append) return 0;

    new entry[48];
    format(entry, sizeof(entry), "%s\r\n", raceName);
    fwrite(append, entry);
    fclose(append);
    return 1;
}

ParseCheckpointLine(const line[], &Float:x, &Float:y, &Float:z)
{
    new idx;
    new part[256];

    format(part, sizeof(part), "%s", strtok(line, idx));
    if(!strlen(part)) return 0;
    x = floatstr(part);

    format(part, sizeof(part), "%s", strtok(line, idx));
    if(!strlen(part)) return 0;
    y = floatstr(part);

    format(part, sizeof(part), "%s", strtok(line, idx));
    if(!strlen(part)) return 0;
    z = floatstr(part);

    return 1;
}

TrimNewline(string[])
{
    new len = strlen(string);
    while(len > 0 && (string[len - 1] == '\n' || string[len - 1] == '\r'))
    {
        string[len - 1] = '\0';
        len--;
    }
}
