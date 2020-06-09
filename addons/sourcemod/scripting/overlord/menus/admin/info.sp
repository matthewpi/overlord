/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Overlord_AdminInfoMenu
 * ?
 */
void Overlord_AdminInfoMenu(const int client, const int adminId, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordAdminInfoMenu);
    menu.SetTitle("Overlord | Admins");

    Admin admin = g_hAdmins[adminId];
    if (admin == null) {
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
    if (aId != INVALID_ADMIN_ID) {
        immunity = aId.ImmunityLevel;
    }

    // Group: %s
    // Get the admin's group.
    Group group = g_hGroups[admin.GetGroupID()];
    int groupImmunity = 0;
    if (group != null) {
        group.GetName(temp, sizeof(temp));
        Format(display, sizeof(display), "Group: %s", temp);
        groupImmunity = group.GetImmunity();
    } else {
        display = "Group: None";
    }
    menu.AddItem("group", display, (immunity < groupImmunity) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    // End Group: %s

    // Server Group: %s
    // Get the admin's server group.
    group = g_hGroups[admin.GetServerGroupID()];
    groupImmunity = 0;
    if (group != null) {
        group.GetName(temp, sizeof(temp));
        Format(display, sizeof(display), "Server Group: %s", temp);
        groupImmunity = group.GetImmunity();
    } else {
        display = "Server Group: None";
    }
    menu.AddItem("serverGroup", display, (immunity < groupImmunity) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
    // End Server Group: %s

    // Created At: %s
    FormatTime(temp, sizeof(temp), "%Y-%m-%d %r", admin.GetCreatedAt());
    Format(display, sizeof(display), "Created At: %s", temp);
    menu.AddItem("createdAt", display);
    // END Created At: %s

    // Delete Admin
    menu.AddItem("delete", "Delete Admin");
    // END Delete Admin

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if (position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordAdminInfoMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            // Get the active admin id.
            int adminId = g_iOverlordMenu[client];

            // Get the admin object using the adminId.
            Admin admin = g_hAdmins[adminId];
            if (admin == null) {
                Overlord_AdminMenu(client);
                return;
            }

            if (StrEqual(info, "name", true)) {
                //Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
                g_iOverlordAction[client] = OVERLORD_ACTION_ADMIN_NAME;
                PrintToChat(client, "%s Please enter an \x10Admin Name\x01.", PREFIX);
            } else if (StrEqual(info, "steamId", true)) {
                Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
            } else if (StrEqual(info, "group", true)) {
                Overlord_AdminGroupMenu(client, adminId);
            } else if (StrEqual(info, "serverGroup", true)) {
                Overlord_AdminGroupMenu(client, adminId, -1, true);
            } else if (StrEqual(info, "delete", true)) {
                Overlord_AdminDeleteMenu(client, adminId);
            } else {
                Overlord_AdminInfoMenu(client, adminId, GetMenuSelectionPosition());
            }
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_AdminMenu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

/**
 * Overlord_AdminGroupMenu
 * ?
 */
void Overlord_AdminGroupMenu(const int client, const int adminId, const int position = -1, bool server = false) {
    Menu menu = CreateMenu((!server) ? Callback_OverlordAdminGroupMenu : Callback_OverlordAdminServerGroupMenu);
    menu.SetTitle("Overlord | Admins");

    // Update the "g_iOverlordMenu" array with the new adminId.
    g_iOverlordMenu[client] = adminId;

    char index[8];
    char name[32];
    for (int i = 1; i < sizeof(g_hGroups); i++) {
        // Get the admin object from the admins array.
        Group group = g_hGroups[i];
        if (group == null) {
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
    if (position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordAdminGroupMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            Handle_CallbackOverlordAdminGroupMenu(client, info);
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_AdminInfoMenu(client, g_iOverlordMenu[client]);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

static int Callback_OverlordAdminServerGroupMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            Handle_CallbackOverlordAdminGroupMenu(client, info, true);
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_AdminInfoMenu(client, g_iOverlordMenu[client]);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}

static void Handle_CallbackOverlordAdminGroupMenu(const int client, const char[] info, bool server = false) {
    // Get the currently selected admin id.
    int adminId = g_iOverlordMenu[client];

    // Get the admin object using the adminId.
    Admin admin = g_hAdmins[adminId];
    if (admin == null) {
        Overlord_AdminMenu(client);
        return;
    }

    // Get the selected groupId
    int groupId = StringToInt(info);

    // Get the group object using the groupId.
    Group group = g_hGroups[groupId];
    if (group == null) {
        Overlord_AdminMenu(client);
        return;
    }

    // Update the admin's group.
    if (!server) {
        admin.SetGroupID(group.GetID());
    } else {
        admin.SetServerGroupID(group.GetID());
    }

    // Get the admin's name.
    char adminName[32];
    admin.GetName(adminName, sizeof(adminName));

    // Get the group's name.
    char groupName[32];
    group.GetName(groupName, sizeof(groupName));

    // Reload the admin's privileges.
    Admin_RefreshId(adminId);

    // Send a message to the client.
    PrintToChat(client, "%s Set \x10%s\x01's %sgroup to \x07%s\x01.", PREFIX, adminName, (server) ? "server " : "", groupName);

    // Redraw the menu.
    Overlord_AdminGroupMenu(client, adminId, GetMenuSelectionPosition(), server);

    // Update the database.
    if (!server) {
        Backend_UpdateAdmin(adminId);
    } else {
        Backend_UpdateAdminServerGroup(adminId);
    }
}

/**
 * Overlord_AdminDeleteMenu
 * ?
 */
void Overlord_AdminDeleteMenu(const int client, const int adminId) {
    Menu menu = CreateMenu(Callback_OverlordAdminDeleteMenu);
    menu.SetTitle("Overlord | Delete Admin");

    // Update the "g_iOverlordMenu" array with the new adminId.
    g_iOverlordMenu[client] = adminId;

    menu.AddItem("true", "Yes");
    menu.AddItem("false", "No");

    // Display the menu to the client.
    menu.Display(client, 0);
}

static int Callback_OverlordAdminDeleteMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            if (StrEqual(info, "true", true)) {
                // Remove the admin's adminId.
                AdminId adminId = GetUserAdmin(client);
                if (adminId != INVALID_ADMIN_ID) {
                    RemoveAdmin(adminId);
                }

                // Delete the admin's database entry.
                Backend_DeleteAdmin(client);

                // Delete the admin object.
                delete g_hAdmins[g_iOverlordMenu[client]];

                // Call the "g_hOnAdminRemoved" forward.
                Call_StartForward(g_hOnAdminRemoved);
                Call_PushCell(adminId);
                Call_Finish();

                PrintToChat(client, "%s Deleted \x10%N\x01's admin.", PREFIX, g_iOverlordMenu[client]);
                Overlord_AdminMenu(client);
            } else {
                Overlord_AdminInfoMenu(client, g_iOverlordMenu[client]);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
