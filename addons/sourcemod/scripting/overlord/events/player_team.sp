/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * Event_PlayerTeamPre (player_team)
  * This event is called whenever a player selects a team, handles stealth admins.
  */
public Action Event_PlayerTeamPre(Event event, const char[] name, const bool dontBroadcast) {
    return Plugin_Continue;
}
