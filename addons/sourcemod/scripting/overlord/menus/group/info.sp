/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Overlord_GroupInfoMenu
 * ?
 */
void Overlord_GroupInfoMenu(const int client, const int groupId, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordGroupInfoMenu);
    menu.SetTitle("Overlord | Groups");

    Group group = g_hGroups[groupId];
    if (group == null) {
        return;
    }

    // Update the "g_iOverlordMenu" array with the new groupId.
    g_iOverlordMenu[client] = groupId;

    char display[64];
    char temp[64];

    // Name: %s
    group.GetName(temp, sizeof(temp));
    Format(display, sizeof(display), "Name: %s", temp);
    menu.AddItem("name", display);
    // END Name: %s

    // Tag: %s
    group.GetTag(temp, sizeof(temp));
    Format(display, sizeof(display), "Tag: %s", temp);
    menu.AddItem("tag", display);
    // END Tag: %s

    // Immunity: %i
    Format(display, sizeof(display), "Immunity: %i", group.GetImmunity());
    menu.AddItem("immunity", display);
    // END Immunity: %i

    // Flags: %s
    group.GetFlags(temp, sizeof(temp));
    Format(display, sizeof(display), "Flags: %s", temp);
    menu.AddItem("flags", display);
    // END Flags: %s

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if (position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordGroupInfoMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            // Get the active admin id.
            int groupId = g_iOverlordMenu[client];

            // Get the admin object using the adminId.
            Group group = g_hGroups[groupId];
            if (group == null) {
                Overlord_GroupMenu(client);
                return;
            }

            if (StrEqual(info, "name", true)) {
                //Overlord_GroupInfoMenu(client, groupId, GetMenuSelectionPosition());
                g_iOverlordAction[client] = OVERLORD_ACTION_GROUP_NAME;
                PrintToChat(client, "%s Please enter an \x10Group Name\x01.", PREFIX);
            } else if (StrEqual(info, "tag", true)) {
                //Overlord_GroupInfoMenu(client, groupId, GetMenuSelectionPosition());
                g_iOverlordAction[client] = OVERLORD_ACTION_GROUP_TAG;
                PrintToChat(client, "%s Please enter an \x10Group Tag\x01.", PREFIX);
            } else if (StrEqual(info, "immunity", true)) {
                // TODO: Create a menu with immunity levels?
                Overlord_GroupInfoMenu(client, groupId, GetMenuSelectionPosition());
            } else if (StrEqual(info, "flags", true)) {
                // TODO: Create a menu with all sourcemod admin flags, have a checkmark or star to symbol if the group already has that flag.
                Overlord_GroupInfoMenu(client, groupId, GetMenuSelectionPosition());
            } else {
                Overlord_GroupInfoMenu(client, groupId, GetMenuSelectionPosition());
            }
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_GroupMenu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
