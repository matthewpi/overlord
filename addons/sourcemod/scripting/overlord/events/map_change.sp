/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Event_MapChange (changelevel, map)
 * Potential crash fix for panorama. "Maps are rendered in either HDR, LDR or both, when clients switch from one to the other CSGO crashes."
 */
public Action Event_MapChange(int client, const char[] command, int args) {
    for(int i = 1; i <= MaxClients; i++) {
        if(!IsClientConnected(i) || IsFakeClient(i)) {
            continue;
        }

        ClientCommand(i, "retry");
    }
}
