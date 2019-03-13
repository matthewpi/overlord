/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Overlord_AdminMenu
 * ?
 */
void Overlord_AdminMenu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordAdminMenu);
    menu.SetTitle("Overlord | Admins");

    char index[8];
    char name[32];
    for(int i = 1; i < sizeof(g_hAdmins); i++) {
        // Get the admin object from the admins array.
        Admin admin = g_hAdmins[i];
        if(admin == null) {
            continue;
        }

        // Format the client index as a char array.
        Format(index, sizeof(index), "%i", i);

        // Get the admin's name.
        admin.GetName(name, sizeof(name));

        menu.AddItem(index, name);
    }

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordAdminMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            int adminId = StringToInt(info);

            Admin admin = g_hAdmins[adminId];
            if(admin == null) {
                Overlord_AdminMenu(client, GetMenuSelectionPosition());
                return;
            }

            Overlord_AdminInfoMenu(client, adminId);
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                Overlord_Menu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

/**
 * Overlord_AdminInfoMenu
 * ?
 */
void Overlord_AdminInfoMenu(const int client, const int adminId, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordAdminInfoMenu);
    menu.SetTitle("Overlord | Admins");

    Admin admin = g_hAdmins[adminId];
    if(admin == null) {
        return;
    }

    char index[32];
    char display[64];
    char temp[64];

    // Name: %s
    Format(index, sizeof(index), "%i;name", adminId);
    admin.GetName(temp, sizeof(temp));
    Format(display, sizeof(display), "Name: %s", temp);
    menu.AddItem(index, display);
    // END Name: %s

    // Steam ID: %s
    Format(index, sizeof(index), "%i;steamId", adminId);
    GetClientAuthId(adminId, AuthId_Steam2, temp, sizeof(temp));
    Format(display, sizeof(display), "Steam ID: %s", temp);
    menu.AddItem(index, display);
    // End Steam ID: %s

    // Group: %s
    Format(index, sizeof(index), "%i;group", adminId);
    Overlord_GetAdminGroupName(adminId, temp, sizeof(temp));
    Format(display, sizeof(display), "Group: %s", temp);
    menu.AddItem(index, display);
    // End Group: %s

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordAdminInfoMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                Overlord_AdminMenu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
