/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Overlord_GroupMenu
 * ?
 */
void Overlord_GroupMenu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordGroupMenu);
    menu.SetTitle("Overlord | Groups");

    AdminId adminId = GetUserAdmin(client);
    if(adminId != INVALID_ADMIN_ID && adminId.HasFlag(Admin_Custom6)) {
        menu.AddItem("new", "New..");
    }

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

static int Callback_OverlordGroupMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            if(StrEqual(info, "new", true)) {

            } else {
                int groupId = StringToInt(info);

                Group group = g_hGroups[groupId];
                if(group == null) {
                    Overlord_GroupMenu(client, GetMenuSelectionPosition());
                    return;
                }

                Overlord_GroupInfoMenu(client, groupId);
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
