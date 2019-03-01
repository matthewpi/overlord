/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Status (status)
 * ?
 */
public Action Command_Status(const int client, const char[] command, const int args) {
    if(client < 1) {
        return Plugin_Continue;
    }

    if(GetStealthCount() < 1) {
        return Plugin_Continue;
    }

    Stealth_PrintCustomStatus(client);

    return Plugin_Stop;
}
