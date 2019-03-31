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

    if(adminId.HasFlag(Admin_Custom6)) {
        menu.AddItem("new", "New..");
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

        // Add the item to the menu.
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

            if(StrEqual(info, "new", true)) {
                Overlord_NewAdminMenu(client);
            } else {
                int adminId = StringToInt(info);

                Admin admin = g_hAdmins[adminId];
                if(admin == null) {
                    Overlord_AdminMenu(client, GetMenuSelectionPosition());
                    return;
                }

                Overlord_AdminInfoMenu(client, adminId);
            }
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
