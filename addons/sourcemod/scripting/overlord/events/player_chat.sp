/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * OnClientSayCommand (player_chat)
  * This is not exactly an event, but it is similar to the "player_chat" event.
  */
public Action OnClientSayCommand(int client, const char[] command, const char[] args) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if we are listening for a chat input.
    if(g_iOverlordAction[client] != -1) {
        if(g_iOverlordAction[client] == OVERLORD_ACTION_ADMIN_NAME) {
            // Check if the message's arguments have less than 3 characters.
            if(strlen(args) < 3) {
                PrintToChat(client, "%s \x10Admin Name\x01 must be at least \x073\x01 characters.", PREFIX);
                return Plugin_Stop;
            }

            // Check if the message's arguments have more than 32 characters.
            if(strlen(args) > 32) {
                PrintToChat(client, "%s \x10Admin Name\x01 has a limit of \x0732\x01 characters.", PREFIX);
                return Plugin_Stop;
            }

            // Get the currently selected admin id.
            int adminId = g_iOverlordMenu[client];

            // Get the admin object using the adminId.
            Admin admin = g_hAdmins[adminId];
            if(admin == null) {
                PrintToChat(client, "%s Failed to find the admin object.", PREFIX);
                return Plugin_Stop;
            }

            // Update the admin's name.
            admin.SetName(args);

            if(admin.GetGroup() != 0) {
                // Refresh the targ'ets admin.
                Admin_RefreshId(adminId);
            }

            // Print a message to the client.
            PrintToChat(client, "%s \x10%N\x01's \x07Admin Name\x01 has been set to \x10%s\x01.", PREFIX, adminId, args);

            // Update the database.
            Backend_UpdateAdmin(client);
        }

        g_iOverlordAction[client] = -1;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

/**
 * OnClientSayCommand_Post (player_chat)
 * This is not exactly an event, but it is similar to the "player_chat" event.
 */
public void OnClientSayCommand_Post(int client, const char[] command, const char[] args) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return;
    }

    // True if the client posted the message in their team chat.
    bool teamChat = StrEqual(command, "say_team", true);
    // True if the client is alive.
    bool alive = IsPlayerAlive(client);

    // Check if the message isn't in the client's team chat and if the client is alive.
    if(!teamChat && alive) {
        return;
    }

    // Define some variables for later use.
    char message[512];

    // Get the client's team.
    int team = GetClientTeam(client);

    // Get the team's name.
    char teamName[8];
    GetClientTeamName(team, teamName, sizeof(teamName));

    const AdminFlag flag = Admin_Chat;

    if(!alive) {
        if(teamChat) {
            // Format the message
            Format(message, sizeof(message), "(\x10Dead %s Chat\x01) \x07%N\x01: \x03%s", teamName, client, args);

            // Print the message to admins.
            PrintToAdmins(message, flag, team, true);
        } else if(!g_cvDeadTalk.BoolValue) {
            // Format the message
            Format(message, sizeof(message), "(\x10Dead Chat\x01) \x07%N\x01: \x03%s", client, args);

            // Print the message to admins.
            PrintToAdmins(message, flag, -1, true);
        }
    } else {
        // Format the message
        Format(message, sizeof(message), "(\x10%s Chat\x01) \x07%N\x01: \x03%s", teamName, client, args);

        // Print the message to admins.
        PrintToAdmins(message, flag, team, false);
    }
}
