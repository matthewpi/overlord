/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Disconnected_Menu
 * ?
 */
void Disconnected_Menu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_DisconnectedMenu);
    menu.SetTitle("Overlord | Disconnects");

    char info[32];
    char display[128];
    for (int i = 0; i < g_alDisconnected.Length; i++) {
        Player player = g_alDisconnected.Get(i);
        if (player == null) {
            continue;
        }

        Format(info, sizeof(info), "%i", i);
        player.GetName(display, sizeof(display));
        menu.AddItem(info, display);
    }

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if (position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_DisconnectedMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            int playerId = StringToInt(info);

            Player player = g_alDisconnected.Get(playerId);
            if (player == null) {
                Disconnected_Menu(client, GetMenuSelectionPosition());
                return;
            }

            Disconnected_PlayerMenu(client, playerId);
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_Menu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

/**
 * Disconnected_PlayerMenu
 * ?
 */
void Disconnected_PlayerMenu(const int client, const int playerId, const int position = -1) {
    Menu menu = CreateMenu(Callback_DisconnectedPlayerMenu);
    menu.SetTitle("Overlord | Disconnects");

    Player player = g_alDisconnected.Get(playerId);
    if (player == null) {
        Disconnected_Menu(client);
        return;
    }

    char info[32];
    Format(info, sizeof(info), "%i", playerId);

    char display[128];

    player.GetName(display, sizeof(display));
    Format(display, sizeof(display), "Name: %s", display);
    menu.AddItem(info, display);

    player.GetSteamID(display, sizeof(display));
    Format(display, sizeof(display), "Steam ID: %s", display);
    menu.AddItem(info, display);

    // Check if the client is an admin with the RCON flag.
    AdminId adminId = GetUserAdmin(client);
    if (adminId != INVALID_ADMIN_ID && GetAdminFlag(adminId, Admin_RCON)) {
        player.GetIpAddress(display, sizeof(display));
        Format(display, sizeof(display), "IP Address: %s", display);
        menu.AddItem(info, display);
    }

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if (position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_DisconnectedPlayerMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            int playerId = StringToInt(info);
            Disconnected_PlayerMenu(client, playerId, GetMenuSelectionPosition());
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                Disconnected_Menu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
