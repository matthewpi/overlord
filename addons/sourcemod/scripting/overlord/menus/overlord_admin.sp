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

    // Get the client's immunity level.
    int immunity = 0;
    AdminId adminId = GetUserAdmin(client);
    if(adminId != INVALID_ADMIN_ID) {
        immunity = adminId.ImmunityLevel;
    }

    char index[8];
    char name[32];
    for(int i = 1; i < sizeof(g_hAdmins); i++) {
        // Get the admin object from the admins array.
        Admin admin = g_hAdmins[i];
        if(admin == null) {
            continue;
        }

        // Check if the admin has no group.
        if(admin.GetGroup() == 0) {
            continue;
        }

        // Get the admin's group.
        Group group = g_hGroups[admin.GetGroup()];
        if(group == null) {
            continue;
        }

        // Check if the group is an actual admin group. (not VIP or default)
        if(group.GetImmunity() == 0) {
            continue;
        }

        // Check if the admin is hidden and if the client's immunity is less than the group's.
        if(admin.IsHidden() && immunity < group.GetImmunity()) {
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

    // Update the "g_iOverlordMenu" array with the new adminId.
    g_iOverlordMenu[client] = adminId;

    char display[64];
    char temp[64];

    // Name: %s
    admin.GetName(temp, sizeof(temp));
    Format(display, sizeof(display), "Name: %s", temp);
    menu.AddItem("name", display);
    // END Name: %s

    // Steam ID: %s
    GetClientAuthId(adminId, AuthId_Steam2, temp, sizeof(temp));
    Format(display, sizeof(display), "Steam ID: %s", temp);
    menu.AddItem("steamId", display);
    // END Steam ID: %s

    // Get the client's immunity level.
    int immunity = 0;
    AdminId aId = GetUserAdmin(client);
    if(aId != INVALID_ADMIN_ID) {
        immunity = aId.ImmunityLevel;
    }

    // Get the admin's group.
    Group group = g_hGroups[admin.GetGroup()];
    if(group == null) {
        return;
    }

    // Group: %s
    group.GetName(temp, sizeof(temp));
    Format(display, sizeof(display), "Group: %s", temp);
    menu.AddItem("group", display, (immunity < group.GetImmunity()) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    // End Group: %s

    // Created At: %s
    FormatTime(temp, sizeof(temp), "%Y-%m-%d %r", admin.GetCreatedAt());
    Format(display, sizeof(display), "Created At: %s", temp);
    menu.AddItem("createdAt", display);
    // END Created At: %s

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

            // Get the active admin id.
            int adminId = g_iOverlordMenu[client];

            // Get the admin object using the adminId.
            Admin admin = g_hAdmins[adminId];
            if(admin == null) {
                Overlord_AdminMenu(client);
                return;
            }

            if(StrEqual(info, "name", true)) {
                // TODO: idk
                Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
            } else if(StrEqual(info, "steamId", true)) {
                // TODO: idk
                Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
            } else if(StrEqual(info, "group", true)) {
                Overlord_AdminGroupMenu(client, adminId);
            } else {
                Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
            }
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

/**
 * Overlord_GroupMenu
 * ?
 */
void Overlord_AdminGroupMenu(const int client, const int adminId, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordAdminGroupMenu);
    menu.SetTitle("Overlord | Admins");

    // Update the "g_iOverlordMenu" array with the new adminId.
    g_iOverlordMenu[client] = adminId;

    char index[8];
    char name[32];
    for(int i = 1; i < sizeof(g_hGroups); i++) {
        // Get the admin object from the admins array.
        Group group = g_hGroups[i];
        if(group == null) {
            continue;
        }

        // Format the client index as a char array.
        Format(index, sizeof(index), "%i", i);

        // Get the admin's name.
        group.GetName(name, sizeof(name));

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

static int Callback_OverlordAdminGroupMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            // Get the currently selected admin id.
            int adminId = g_iOverlordMenu[client];

            // Get the admin object using the adminId.
            Admin admin = g_hAdmins[adminId];
            if(admin == null) {
                Overlord_AdminMenu(client);
                return;
            }

            // Get the selected groupId
            int groupId = StringToInt(info);

            // Get the group object using the groupId.
            Group group = g_hGroups[groupId];
            if(group == null) {
                Overlord_AdminMenu(client);
                return;
            }

            // Update the admin's group.
            admin.SetGroup(group.GetID());

            // Get the admin's name.
            char adminName[32];
            admin.GetName(adminName, sizeof(adminName));

            // Get the group's name.
            char groupName[32];
            group.GetName(groupName, sizeof(groupName));

            // Send a message to the client.
            PrintToChat(client, "%s Set \x10%s\x01's group to \x07%s\x01.", PREFIX, adminName, groupName);

            // Redraw the menu.
            Overlord_AdminGroupMenu(client, adminId, GetMenuSelectionPosition());
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                Overlord_AdminInfoMenu(client, g_iOverlordMenu[client]);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
