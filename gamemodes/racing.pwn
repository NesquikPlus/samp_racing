#include <a_samp>
#include <core>
#include <float>

#pragma tabsize 0

#define COLOR_WHITE     0xFFFFFFFF
#define COLOR_GREEN     0x33AA33AA
#define COLOR_RED       0xAA3333AA
#define COLOR_YELLOW    0xFFFF00AA

#define MAX_RACES           32
#define MAX_CHECKPOINTS     64
#define MAX_RACE_NAME       32
#define CHECKPOINT_SIZE     8.0
#define RACE_REWARD_BASE    5000
#define RACE_REWARD_PER_CP  500
#define RACE_VEHICLE        411

#define MIN_VEHICLE_MODEL   400
#define MAX_VEHICLE_MODEL   611
#define VEHICLE_NAME_COUNT  212

#define RACES_INDEX         "races_index.txt"

enum E_PLAYER_STATE
{
    PSTATE_NONE = 0,
    PSTATE_CREATING,
    PSTATE_RACING
};

enum E_RACE_DATA
{
    rUsed,
    rName[MAX_RACE_NAME],
    rCPCount
};

new gRaces[MAX_RACES][E_RACE_DATA];
new Float:gRaceCheckpoints[MAX_RACES][MAX_CHECKPOINTS][3];

new E_PLAYER_STATE:gPlayerState[MAX_PLAYERS];
new gPlayerRace[MAX_PLAYERS];
new gPlayerCPIndex[MAX_PLAYERS];
new gPlayerVehicle[MAX_PLAYERS];

new gCreatorCPCount[MAX_PLAYERS];
new Float:gCreatorCP[MAX_PLAYERS][MAX_CHECKPOINTS][3];

new gVehicleNames[VEHICLE_NAME_COUNT][] =
{
    {"Landstalker"},
    {"Bravura"},
    {"Buffalo"},
    {"Linerunner"},
    {"Perrenial"},
    {"Sentinel"},
    {"Dumper"},
    {"Firetruck"},
    {"Trashmaster"},
    {"Stretch"},
    {"Manana"},
    {"Infernus"},
    {"Voodoo"},
    {"Pony"},
    {"Mule"},
    {"Cheetah"},
    {"Ambulance"},
    {"Leviathan"},
    {"Moonbeam"},
    {"Esperanto"},
    {"Taxi"},
    {"Washington"},
    {"Bobcat"},
    {"Mr Whoopee"},
    {"BF Injection"},
    {"Hunter"},
    {"Premier"},
    {"Enforcer"},
    {"Securicar"},
    {"Banshee"},
    {"Predator"},
    {"Bus"},
    {"Rhino"},
    {"Barracks"},
    {"Hotknife"},
    {"Trailer 1"},
    {"Previon"},
    {"Coach"},
    {"Cabbie"},
    {"Stallion"},
    {"Rumpo"},
    {"RC Bandit"},
    {"Romero"},
    {"Packer"},
    {"Monster"},
    {"Admiral"},
    {"Squalo"},
    {"Seasparrow"},
    {"Pizzaboy"},
    {"Tram"},
    {"Trailer 2"},
    {"Turismo"},
    {"Speeder"},
    {"Reefer"},
    {"Tropic"},
    {"Flatbed"},
    {"Yankee"},
    {"Caddy"},
    {"Solair"},
    {"Berkley's RC Van"},
    {"Skimmer"},
    {"PCJ-600"},
    {"Faggio"},
    {"Freeway"},
    {"RC Baron"},
    {"RC Raider"},
    {"Glendale"},
    {"Oceanic"},
    {"Sanchez"},
    {"Sparrow"},
    {"Patriot"},
    {"Quad"},
    {"Coastguard"},
    {"Dinghy"},
    {"Hermes"},
    {"Sabre"},
    {"Rustler"},
    {"ZR-350"},
    {"Walton"},
    {"Regina"},
    {"Comet"},
    {"BMX"},
    {"Burrito"},
    {"Camper"},
    {"Marquis"},
    {"Baggage"},
    {"Dozer"},
    {"Maverick"},
    {"News Chopper"},
    {"Rancher"},
    {"FBI Rancher"},
    {"Virgo"},
    {"Greenwood"},
    {"Jetmax"},
    {"Hotring"},
    {"Sandking"},
    {"Blista Compact"},
    {"Police Maverick"},
    {"Boxville"},
    {"Benson"},
    {"Mesa"},
    {"RC Goblin"},
    {"Hotring Racer A"},
    {"Hotring Racer B"},
    {"Bloodring Banger"},
    {"Rancher"},
    {"Super GT"},
    {"Elegant"},
    {"Journey"},
    {"Bike"},
    {"Mountain Bike"},
    {"Beagle"},
    {"Cropdust"},
    {"Stunt"},
    {"Tanker"},
    {"Roadtrain"},
    {"Nebula"},
    {"Majestic"},
    {"Buccaneer"},
    {"Shamal"},
    {"Hydra"},
    {"FCR-900"},
    {"NRG-500"},
    {"HPV1000"},
    {"Cement Truck"},
    {"Tow Truck"},
    {"Fortune"},
    {"Cadrona"},
    {"FBI Truck"},
    {"Willard"},
    {"Forklift"},
    {"Tractor"},
    {"Combine"},
    {"Feltzer"},
    {"Remington"},
    {"Slamvan"},
    {"Blade"},
    {"Freight"},
    {"Streak"},
    {"Vortex"},
    {"Vincent"},
    {"Bullet"},
    {"Clover"},
    {"Sadler"},
    {"Firetruck LA"},
    {"Hustler"},
    {"Intruder"},
    {"Primo"},
    {"Cargobob"},
    {"Tampa"},
    {"Sunrise"},
    {"Merit"},
    {"Utility"},
    {"Nevada"},
    {"Yosemite"},
    {"Windsor"},
    {"Monster A"},
    {"Monster B"},
    {"Uranus"},
    {"Jester"},
    {"Sultan"},
    {"Stratum"},
    {"Elegy"},
    {"Raindance"},
    {"RC Tiger"},
    {"Flash"},
    {"Tahoma"},
    {"Savanna"},
    {"Bandito"},
    {"Freight Flat"},
    {"Streak Carriage"},
    {"Kart"},
    {"Mower"},
    {"Duneride"},
    {"Sweeper"},
    {"Broadway"},
    {"Tornado"},
    {"AT-400"},
    {"DFT-30"},
    {"Huntley"},
    {"Stafford"},
    {"BF-400"},
    {"Newsvan"},
    {"Tug"},
    {"Trailer 3"},
    {"Emperor"},
    {"Wayfarer"},
    {"Euros"},
    {"Hotdog"},
    {"Club"},
    {"Freight Carriage"},
    {"Trailer 3"},
    {"Andromada"},
    {"Dodo"},
    {"RC Cam"},
    {"Launch"},
    {"Police Car (LSPD)"},
    {"Police Car (SFPD)"},
    {"Police Car (LVPD)"},
    {"Police Ranger"},
    {"Picador"},
    {"S.W.A.T. Van"},
    {"Alpha"},
    {"Phoenix"},
    {"Glendale"},
    {"Sadler"},
    {"Luggage Trailer A"},
    {"Luggage Trailer B"},
    {"Stair Trailer"},
    {"Boxville"},
    {"Farm Plow"},
    {"Utility Trailer"}
};

forward DelayedSpawn(playerid);
forward Float:GetAngleToPoint(Float:x1, Float:y1, Float:x2, Float:y2);

main()
{
    print("\n----------------------------------");
    print("  Racing Gamemode");
    print("----------------------------------\n");
}

public OnGameModeInit()
{
    SetGameModeText("Racing");
    ShowPlayerMarkers(1);
    ShowNameTags(1);

    AddPlayerClass(265, 1536.0, -1374.0, 13.5, 90.0, 0, 0, 0, 0, -1, -1);

    EnsureRaceStorage();
    LoadAllRaces();

    return 1;
}

public OnPlayerConnect(playerid)
{
    gPlayerState[playerid] = PSTATE_NONE;
    gPlayerRace[playerid] = -1;
    gPlayerCPIndex[playerid] = 0;
    gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    gCreatorCPCount[playerid] = 0;

    SendClientMessage(playerid, COLOR_WHITE, "Welcome to the {FF8800}Racing{FFFFFF} server!");
    SendClientMessage(playerid, COLOR_WHITE, "Create tracks: {FFFF00}/create_race{FFFFFF}, {FFFF00}/cp{FFFFFF}, {FFFF00}/save_race [name]");
    SendClientMessage(playerid, COLOR_WHITE, "Race a track: {FFFF00}/start_race [name]{FFFFFF}  |  Cancel: {FFFF00}/cancel_race");
    SendClientMessage(playerid, COLOR_WHITE, "Spawn a car: {FFFF00}/spawn_car [name]{FFFFFF}  (e.g. /spawn_car infernus)");
    SendClientMessage(playerid, COLOR_WHITE, "Type {FFFF00}/help{FFFFFF} for a full list of commands.");

    SetTimerEx("DelayedSpawn", 500, false, "i", playerid);

    return 1;
}

public DelayedSpawn(playerid)
{
    if(!IsPlayerConnected(playerid)) return 0;
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ResetPlayerRace(playerid);
    gCreatorCPCount[playerid] = 0;
    gPlayerState[playerid] = PSTATE_NONE;

    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerInterior(playerid, 0);
    TogglePlayerClock(playerid, 0);
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, 1000);

    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    if(gPlayerState[playerid] == PSTATE_RACING)
    {
        SendClientMessage(playerid, COLOR_RED, "You died and failed the race. Use /start_race to try again.");
        ResetPlayerRace(playerid);
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
        new reward = RACE_REWARD_BASE + (cpCount * RACE_REWARD_PER_CP);
        GivePlayerMoney(playerid, reward);

        new msg[128];
        format(msg, sizeof(msg), "Race complete! You finished \"%s\" and earned $%d.", gRaces[raceid][rName], reward);
        SendClientMessage(playerid, COLOR_GREEN, msg);
        GameTextForPlayer(playerid, "~g~Race complete!", 3000, 5);

        ResetPlayerRace(playerid);
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
        SendClientMessage(playerid, COLOR_GREEN, "When finished, use /save_race [name]. Use /cancel_race to abort.");
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
            SendClientMessage(playerid, COLOR_RED, "Usage: /save_race [race_name]");
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

        gCreatorCPCount[playerid] = 0;
        gPlayerState[playerid] = PSTATE_NONE;
        SyncPlayerVehicleFromSeat(playerid);

        new msg[96];
        format(msg, sizeof(msg), "Race \"%s\" saved with %d checkpoints.", raceName, gRaces[raceid][rCPCount]);
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

        ResetPlayerRace(playerid);

        gPlayerState[playerid] = PSTATE_RACING;
        gPlayerRace[playerid] = raceid;
        gPlayerCPIndex[playerid] = 0;

        new Float:sx = gRaceCheckpoints[raceid][0][0];
        new Float:sy = gRaceCheckpoints[raceid][0][1];
        new Float:sz = gRaceCheckpoints[raceid][0][2];
        new Float:angle = 0.0;

        if(gRaces[raceid][rCPCount] > 1)
        {
            angle = GetAngleToPoint(sx, sy, gRaceCheckpoints[raceid][1][0], gRaceCheckpoints[raceid][1][1]);
        }

        if(gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(gPlayerVehicle[playerid]);
            gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
        }

        gPlayerVehicle[playerid] = CreateVehicle(RACE_VEHICLE, sx, sy, sz, angle, -1, -1, -1);
        PutPlayerInVehicle(playerid, gPlayerVehicle[playerid], 0);

        ShowRaceCheckpoint(playerid, raceid, 0);

        new msg[96];
        format(msg, sizeof(msg), "Race \"%s\" started! Collect %d checkpoints in order.", raceName, gRaces[raceid][rCPCount]);
        SendClientMessage(playerid, COLOR_GREEN, msg);
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
            format(msg, sizeof(msg), "- %s (%d checkpoints)", gRaces[i][rName], gRaces[i][rCPCount]);
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
    SendClientMessage(playerid, COLOR_YELLOW, "/save_race [name] {FFFFFF}- Save the track you are creating");
    SendClientMessage(playerid, COLOR_YELLOW, "/start_race [name] {FFFFFF}- Start racing a saved track");
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

    if(!keepVehicle && gPlayerVehicle[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(gPlayerVehicle[playerid]);
        gPlayerVehicle[playerid] = INVALID_VEHICLE_ID;
    }

    gPlayerRace[playerid] = -1;
    gPlayerCPIndex[playerid] = 0;

    if(gPlayerState[playerid] == PSTATE_RACING)
    {
        gPlayerState[playerid] = PSTATE_NONE;
    }
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

    new cpCount = strval(line);
    if(cpCount < 2 || cpCount > MAX_CHECKPOINTS)
    {
        fclose(file);
        return 0;
    }

    gRaces[raceid][rCPCount] = cpCount;

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
    format(line, sizeof(line), "%d\r\n", gRaces[raceid][rCPCount]);
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

strtok(const string[], &index)
{
    new length = strlen(string);
    while((index < length) && (string[index] <= ' '))
    {
        index++;
    }

    new offset = index;
    new result[256];
    while((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
    {
        result[index - offset] = string[index];
        index++;
    }
    result[index - offset] = EOS;
    return result;
}
