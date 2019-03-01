/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * Event_PlayerTeamPre (player_team)
  * This event is called whenever a player selects a team, handles stealth admins.
  */
public Action Event_PlayerTeamPre(Event event, const char[] name, const bool dontBroadcast) {
    int userId = event.GetInt("userid");
    int client = GetClientOfUserId(userId);

    // Check if the client is invalid.
    if(!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if the client is not an admin.
    if(!Overlord_IsAdmin(client)) {
        return Plugin_Continue;
    }

    // Check if the client is disconnected?
    if(view_as<bool>(event.GetInt("disconnect"))) {
        return Plugin_Continue;
    }

    // Get the client's selected team.
    int team = event.GetInt("team");

    // Check if the selected team is the client's current team.
    if(team == GetClientTeam(client)) {
        return Plugin_Continue;
    }

    // Create a new "player_team" event.
    Event playerTeamEvent = CreateEvent("player_team", true);

    // Check if the "playerTeamEvent" is null.
    if(playerTeamEvent == null) {
        LogError("%s Failed to create \"player_team\" event.", CONSOLE_PREFIX);
        return Plugin_Continue;
    }

    // Update "playerTeamEvent" information.
    playerTeamEvent.SetInt("userid", userId);
    playerTeamEvent.SetInt("team", team);
    playerTeamEvent.SetInt("oldteam", event.GetInt("oldteam"));
    playerTeamEvent.SetInt("disconnect", false);

    event.BroadcastDisabled = true;

    // Check if the selected team is the spectator team.
    if(team == CS_TEAM_SPECTATOR) {
        playerTeamEvent.FireToClient(client);
    } else {
        g_bStealthed[client] = false;
    }

    Stealth_TeamTimer(playerTeamEvent);
    return Plugin_Continue;
}
