/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_RoundEnd (round_end)
 * This event is called on round end and handles the swapping of client's teams.
 */
public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
    // Loop through all clients.
    for(int client = 1; client < MaxClients; client++) {
        // Check if the client is invalid.
        if(!IsClientValid(client)) {
            continue;
        }

        // Check if the client should not be swapped.
        if(g_iSwapOnRoundEnd[client] == -1) {
            continue;
        }

        // Check if the client is already on their target team.
        if(GetClientTeam(client) == g_iSwapOnRoundEnd[client]) {
            // Update the array so they are not tried to be swapped again.
            g_iSwapOnRoundEnd[client] = -1;
            continue;
        }

        // Switch through all possible team choices.
        switch(g_iSwapOnRoundEnd[client]) {
            case CS_TEAM_T:
                // Swap the client to the terrorist team.
                CS_SwitchTeam(client, CS_TEAM_T);
            case CS_TEAM_CT:
                // Swap the client to the counter terrorist team.
                CS_SwitchTeam(client, CS_TEAM_CT);
            case CS_TEAM_SPECTATOR:
                // Swap the client to the spectator team.
                CS_SwitchTeam(client, CS_TEAM_SPECTATOR);
        }

        // Update the array so they are not tried to be swapped again.
        g_iSwapOnRoundEnd[client] = -1;
    }
}
