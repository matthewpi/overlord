/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * GetPlayerCount
  * ?
  */
stock int GetPlayerCount() {
    int players = 0;
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        // Check if the client is stealthed.
        if(Overlord_IsStealthed(client)) {
            continue;
        }

        players++;
    }

    return players;
}

/**
 * GetBotCount
 * ?
 */
stock int GetBotCount() {
    int bots = 0;
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client, true)) {
            continue;
        }

        // Check if the client is not fake.
        if(!IsFakeClient(client)) {
            continue;
        }

        bots++;
    }

    return bots;
}

/**
 * GetStealthCount
 * ?
 */
public int GetStealthCount() {
    int stealthed = 0;
    for(int client = 1; client <= MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsFakeClient(client)) {
            continue;
        }

        // Check if the client is not stealthed.
        if(!Overlord_IsStealthed(client)) {
            continue;
        }

        stealthed++;
    }

    return stealthed;
}

/**
 * Stealth_TeamTimer
 * ?
 */
public void Stealth_TeamTimer(Event event) {
    CreateTimer(0.01, Timer_StealthTeamTimer, event);
}

/**
 * Timer_StealthTeamTimer
 * ?
 */
static Action Timer_StealthTeamTimer(Handle timer, Event event) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        event.Cancel();
        event = null;
        return Plugin_Stop;
    }

    // Get the client's selected team.
    int team = event.GetInt("team");

    // Get the client's name.
    char clientName[MAX_NAME_LENGTH];
    GetClientName(client, clientName, sizeof(clientName));

    // Get the client's auth id.
    char clientAuth[64];
    GetClientAuthId(client, AuthId_Engine, clientAuth, sizeof(clientAuth));

    // Check if the selected team is the spectator team.
    if(team == CS_TEAM_SPECTATOR) {
        event.Cancel();
        event = null;

        if(!Overlord_IsStealthed(client) && Overlord_CanStealth(client)) {
            // Create a new "player_disconnect" event.
            Event playerDisconnectEvent = CreateEvent("player_disconnect", true);

            // Check if the "playerDisconnectEvent" is not null.
            if(playerDisconnectEvent != null) {
                // Update "playerConnectEvent" information.
                playerDisconnectEvent.SetInt("userid", userId);
                playerDisconnectEvent.SetString("name", clientName);
                playerDisconnectEvent.SetString("networkid", clientAuth);
                playerDisconnectEvent.SetString("reason", "Disconnect");
                playerDisconnectEvent.SetInt("bot", false);

                // Loop through all clients on the server.
                for(int i = 1; i < MaxClients; i++) {
                    // Check if the client is invalid.
                    if(!IsClientValid(i)) {
                        continue;
                    }

                    // Check if the loop's client index equals the admin's.
                    if(client == i) {
                        continue;
                    }

                    // Fire the "playerDisconnectEvent" to the client.
                    playerDisconnectEvent.FireToClient(i);
                }

                // Cancel the "playerDisconnectEvent".
                playerDisconnectEvent.Cancel();

                // Update the client's stealth disconnect state.
                g_bStealthDisconnect[client] = true;
            }

            // Update the client's stealthed state.
            g_bStealthed[client] = true;
        }
    } else {
        if(g_bStealthDisconnect[client]) {
            // Create a new "player_connect" event.
            Event playerConnectEvent = CreateEvent("player_connect", true);

            // Check if the "playerConnectEvent" is not null.
            if(playerConnectEvent != null) {
                // Get the client's ip address. (including port)
                char clientAddress[32];
                GetClientIP(client, clientAddress, sizeof(clientAddress), false);

                // Update "playerConnectEvent" information.
                playerConnectEvent.SetInt("index", client);
                playerConnectEvent.SetInt("userid", userId);
                playerConnectEvent.SetString("name", clientName);
                playerConnectEvent.SetString("address", clientAddress);
                playerConnectEvent.SetString("networkid", clientAuth);
                playerConnectEvent.SetInt("bot", false);

                // Loop through all clients on the server.
                for(int i = 1; i < MaxClients; i++) {
                    // Check if the client is invalid.
                    if(!IsClientValid(i)) {
                        continue;
                    }

                    // Check if the loop's client index equals the admin's.
                    if(client == i) {
                        continue;
                    }

                    // Fire the "playerConnectEvent" to the client.
                    playerConnectEvent.FireToClient(i);
                }

                // Cancel the "playerConnectEvent".
                playerConnectEvent.Cancel();
            }

            // Update the "g_bStealthDisconnect" array.
            g_bStealthDisconnect[client] = false;
        }

        // Update the "g_bStealthed" array.
        g_bStealthed[client] = false;
        event.Fire();
        event = null;
    }

    // Check if the "player_team" event is not null.
    if(event != null) {
        event.Cancel();
        event = null;
    }

    return Plugin_Stop;
}

/**
 * Stealth_SetTransmit
 * ?
 */
public Action Stealth_SetTransmit(const int entity, const int client) {
    if(entity == client || entity < 1 || entity > MaxClients) {
        return Plugin_Continue;
    }

    if(g_bStealthed[entity]) {
        return Plugin_Continue;
    }

    return Plugin_Handled;
}

/**
 * Stealth_PlayerManagerThinkPost
 * ?
 */
public void Stealth_PlayerManagerThinkPost(const int entity) {
    // Loop through all clients on the server.
    for(int client = 1; client < MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        SetEntProp(entity, Prop_Send, "m_bConnected", !g_bStealthed[client], _, client);
    }
}

stock void Stealth_PrintCustomStatus(const int client) {
    // hostname: sea1.stacktrace.fun - dev1
    // version : 1.36.7.9 secure
    // os      : Linux
    // type    : community dedicated
    // map     : de_mirage
    // players : 1 humans, 0 bots (16/0 max) (not hibernating)
    // # userid name uniqueid connected ping loss state rate
    // #  4 1 "T.w² | matthew" STEAM_1:1:530997 06:08 48 0 active 786432
    // #end

    // Get the server's hostname.
    char hostname[64];
    g_cvServerHostname.GetString(hostname, sizeof(hostname));

    // Get the server's ip address.
    char ipAddress[16];
    g_cvServerIp.GetString(ipAddress, sizeof(ipAddress));

    // Get the server's port.
    char port[8];
    g_cvServerPort.GetString(port, sizeof(port));

    bool windows = true;
    char version[32] = "1.36.7.8";
    bool secure = false;
    bool found = GetSystemInformation(windows, version, sizeof(version), secure);
    if(!found) {
        LogMessage("%s PrintCustomStatus: !found", CONSOLE_PREFIX);
        return;
    }

    PrintToConsole(client, "Connected to %s:%s", ipAddress, port);
    PrintToConsole(client, "hostname: %s", hostname);
    PrintToConsole(client, "version : %s %s", version, secure ? "secure" : "insecure");
    PrintToConsole(client, "os      :  %s", windows ? "Windows" : "Linux");        // There is a second space before "%s" for a reason.
    PrintToConsole(client, "type    :  community dedicated");// There is a second space before "community" for a reason.
    PrintToConsole(client, "map     : %s", g_cServerMap);
    PrintToConsole(client, "players : %d humans, %d bots %s (not hibernating)", GetPlayerCount(), GetBotCount(), "(16/0 max)");
    PrintToConsole(client, "");
    PrintToConsole(client, "# userid name uniqueid connected ping loss state rate");

    char clientAuth[64];
    char clientTime[9];
    int clientPing;
    int clientLoss;
    char clientRate[9];
    for(int i = 1; i <= MaxClients; i++) {
        // Check if the client is stealthed.
        if(Overlord_IsStealthed(i)) {
            continue;
        }

        // Check if the client is invalid.
        if(!IsClientValid(i, true)) {
            continue;
        }

        // Check if the client is not fake.
        if(!IsFakeClient(i)) {
            // Get the client's steam id.
            GetClientAuthId(i, AuthId_Steam2, clientAuth, sizeof(clientAuth));

            // Get client's time.
            FormatShortTime(RoundToFloor(GetClientTime(i)), clientTime, sizeof(clientTime));

            // Get client's ping.
            clientPing = RoundFloat(GetClientLatency(i, NetFlow_Both) * 1000.0);

            // Get client's loss.
            clientLoss = RoundFloat(GetClientAvgLoss(i, NetFlow_Both));

            // Get client's rate.
            GetClientInfo(i, "rate", clientRate, 9);

            // Print the client's line to the console.
            PrintToConsole(client, "#  %d %d \"%N\" %s %s %d %d active %s", GetClientUserId(i), i, i, clientAuth, clientTime, clientPing, clientLoss, clientRate);
        } else {
            PrintToConsole(client, "# %d \"%N\" BOT active %d", GetClientUserId(i), i, 128.0);
        }
    }

    PrintToConsole(client, "#end");
}

stock bool GetSystemInformation(bool& windows, char[] buffer, const int maxlen, bool& secure) {
    char serverStatus[512];
    char statusBuffer[64];
    ServerCommandEx(serverStatus, sizeof(serverStatus), "status");

    windows = StrContains(serverStatus, "os      :  Windows", true) != -1;
    secure = StrContains(serverStatus, " secure  ", true) != -1;

    Regex regex = CompileRegex("version : (.*?)(?=\\/)");
    int matches = regex.Match(serverStatus);

    if(matches > 0) {
        regex.GetSubString(0, statusBuffer, sizeof(statusBuffer));
    }

    delete regex;

    ReplaceString(statusBuffer, sizeof(statusBuffer), "version : ", "");
    strcopy(buffer, maxlen, statusBuffer);
    return true;
}
