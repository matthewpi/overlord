/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * OnClientSayCommand_Post (player_chat)
 * This is not exactly an event, but it is similar to the "player_chat" event.
 */
public void OnClientSayCommand_Post(int client, const char[] command, const char[] args) {
    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return;
    }

    // Check if we are listening for a chat input.
    if(g_iOverlordAction[client] != -1) {
        g_iOverlordAction[client] = -1;
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
    PrintToServer(g_cvDeadTalk.BoolValue ? "true" : "false");

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
