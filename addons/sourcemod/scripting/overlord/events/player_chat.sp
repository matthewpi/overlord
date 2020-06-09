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
    if (!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if we need to handle a chat input.
    if (g_iOverlordAction[client] == OVERLORD_ACTION_NONE) {
        return Plugin_Continue;
    }

    if (StrEqual(args, "!abort")) {
        PrintToChat(client, "%s Aborted.", PREFIX);
        g_iOverlordAction[client] = OVERLORD_ACTION_NONE;
        return Plugin_Stop;
    }

    if (g_iOverlordAction[client] == OVERLORD_ACTION_ADMIN_NAME) {
        // Check if the message's arguments have less than 3 characters.
        if (strlen(args) < 3) {
            PrintToChat(client, "%s \x10Admin Name\x01 must be at least \x073\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Check if the message's arguments have more than 32 characters.
        if (strlen(args) > 32) {
            PrintToChat(client, "%s \x10Admin Name\x01 has a limit of \x0732\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Get the currently selected admin id.
        int adminId = g_iOverlordMenu[client];

        // Get the admin object using the admin id.
        Admin admin = g_hAdmins[adminId];
        if (admin == null) {
            PrintToChat(client, "%s Failed to find the admin object.", PREFIX);
            g_iOverlordAction[client] = OVERLORD_ACTION_NONE;
            return Plugin_Stop;
        }

        // Update the admin's name.
        admin.SetName(args);

        // Refresh the target's admin.
        Admin_RefreshId(adminId);

        // Print a message to the client.
        PrintToChat(client, "%s \x10%N\x01's \x07Admin Name\x01 has been set to \x10%s\x01.", PREFIX, adminId, args);

        // Display the admin info menu.
        Overlord_AdminInfoMenu(client, adminId);

        // Update the database.
        Backend_UpdateAdmin(client);
    } else if (g_iOverlordAction[client] == OVERLORD_ACTION_GROUP_NAME) {
        // Check if the message's arguments have less than 3 characters.
        if (strlen(args) < 3) {
            PrintToChat(client, "%s \x10Group Name\x01 must be at least \x073\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Check if the message's arguments have more than 32 characters.
        if (strlen(args) > 32) {
            PrintToChat(client, "%s \x10Group Name\x01 has a limit of \x0732\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Get the currently selected group id.
        int groupId = g_iOverlordMenu[client];

        // Get the group object using the group id.
        Group group = g_hGroups[groupId];
        if (group == null) {
            PrintToChat(client, "%s Failed to find the group object.", PREFIX);
            g_iOverlordAction[client] = OVERLORD_ACTION_NONE;
            return Plugin_Stop;
        }

        // Update the group's name.
        group.SetName(args);

        // Loop through all admins.
        for (int i = 1; i < sizeof(g_hAdmins); i++) {
            Admin admin = g_hAdmins[i];
            if (admin == null) {
                continue;
            }

            // Check if the admin's group matches the other group.
            if (admin.GetGroup() != group.GetID()) {
                continue;
            }

            // Refresh the admin.
            Admin_RefreshId(i);
        }

        // Print a message to the client.
        PrintToChat(client, "%s \x07Group Name\x01 has been set to \x10%s\x01.", PREFIX, args);

        // Display the admin info menu.
        Overlord_GroupInfoMenu(client, groupId);

        // Update the database.
        Backend_UpdateGroup(groupId);
    } else if (g_iOverlordAction[client] == OVERLORD_ACTION_GROUP_TAG) {
        // Check if the message's arguments have less than 3 characters.
        if (strlen(args) < 3) {
            PrintToChat(client, "%s \x10Group Tag\x01 must be at least \x073\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Check if the message's arguments have more than 16 characters.
        if (strlen(args) > 16) {
            PrintToChat(client, "%s \x10Group Tag\x01 has a limit of \x0716\x01 characters.", PREFIX);
            return Plugin_Stop;
        }

        // Get the currently selected group id.
        int groupId = g_iOverlordMenu[client];

        // Get the group object using the group id.
        Group group = g_hGroups[groupId];
        if(group == null) {
            PrintToChat(client, "%s Failed to find the group object.", PREFIX);
            g_iOverlordAction[client] = OVERLORD_ACTION_NONE;
            return Plugin_Stop;
        }

        // Update the group's name.
        group.SetTag(args);

        // Print a message to the client.
        PrintToChat(client, "%s \x07Group Tag\x01 has been set to \x10%s\x01.", PREFIX, args);

        // Display the admin info menu.
        Overlord_GroupInfoMenu(client, groupId);

        // Update the database.
        Backend_UpdateGroup(groupId);
    }

    g_iOverlordAction[client] = OVERLORD_ACTION_NONE;
    return Plugin_Stop;
}

/**
 * OnClientSayCommand_Post (player_chat)
 * This is not exactly an event, but it is similar to the "player_chat" event.
 */
public void OnClientSayCommand_Post(int client, const char[] command, const char[] args) {
    // Check if the client is invalid.
    if (!IsClientValid(client)) {
        return;
    }

    // True if the client posted the message in their team chat.
    bool teamChat = StrEqual(command, "say_team", true);
    // True if the client is alive.
    bool alive = IsPlayerAlive(client);

    // Check if the message isn't in the client's team chat and if the client is alive.
    if (!teamChat && alive) {
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

    if (!alive) {
        if (teamChat) {
            // Format the message
            Format(message, sizeof(message), "(\x10Dead %s Chat\x01) \x07%N\x01: \x03%s", teamName, client, args);

            // Print the message to admins.
            PrintToAdmins(message, flag, team, true);
        } else if (!g_cvDeadTalk.BoolValue) {
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
