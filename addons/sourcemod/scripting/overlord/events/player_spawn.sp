/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_PlayerSpawn (player_spawn)
 * This event is called whenever a player is spawned.
 */
public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(event.GetInt("userid"));

    // Check is the client is invalid.
    if (!IsClientValid(client)) {
        return Plugin_Continue;
    }

    // Check if collisions are disabled and that the collision group is valid.
    if (!g_cvCollisions.BoolValue && g_iCollisionGroup != -1) {
        SetEntData(client, g_iCollisionGroup, 2, 4, true);
    }

    // Give armor to the player based off of "armor_t" or "armor_ct" convar.
    int team = GetClientTeam(client);
    if (g_cvArmorT.IntValue > 0 && team == CS_TEAM_T) {
        if (g_cvArmorT.IntValue > 0) {
            SetEntProp(client, Prop_Send, "m_ArmorValue", 100);

            if (g_cvArmorT.IntValue == 2) {
                SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
            }
        }

        DisarmClient(client);
    } else if (g_cvArmorCT.IntValue > 0 && team == CS_TEAM_CT) {
        if (g_cvArmorCT.IntValue > 0) {
            SetEntProp(client, Prop_Send, "m_ArmorValue", 100);

            if (g_cvArmorCT.IntValue == 2) {
                SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
            }
        }

        DisarmClient(client);
        GivePlayerItem(client, "weapon_m4a1");
        GivePlayerItem(client, "weapon_deagle");
        GivePlayerItem(client, "weapon_hegrenade");
        GivePlayerItem(client, "weapon_smokegrenade");
        GivePlayerItem(client, "weapon_flashbang");
        GivePlayerItem(client, "weapon_incgrenade");
        GivePlayerItem(client, "weapon_tagrenade");
        GivePlayerItem(client, "weapon_healthshot");
    }

    // Loop through all of the admin's following entires.
    for (int i = 1; i < sizeof(g_iFollowing); i++) {
        // Check if the follow entry does not equal the spawned client.
        if (g_iFollowing[i] != client) {
            continue;
        }

        // Check if the admin is invalid.
        if (!IsClientValid(i)) {
            continue;
        }

        // Set who the admin is spectating.
        FakeClientCommand(i, "spec_player \"%N\"", g_iFollowing[i]);
    }

    return Plugin_Continue;
}
