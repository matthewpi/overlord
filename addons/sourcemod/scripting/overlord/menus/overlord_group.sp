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

            int groupId = StringToInt(info);

            Group group = g_hGroups[groupId];
            if(group == null) {
                Overlord_GroupMenu(client, GetMenuSelectionPosition());
                return;
            }

            Overlord_GroupInfoMenu(client, groupId);
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
 * Overlord_GroupInfoMenu
 * ?
 */
void Overlord_GroupInfoMenu(const int client, const int groupId, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordGroupInfoMenu);
    menu.SetTitle("Overlord | Groups");

    Group group = g_hGroups[groupId];
    if(group == null) {
        return;
    }

    char index[32];
    char display[64];
    char temp[64];

    // Name: %s
    Format(index, sizeof(index), "%i;name", groupId);
    group.GetName(temp, sizeof(temp));
    Format(display, sizeof(display), "Name: %s", temp);
    menu.AddItem(index, display);
    // END Name: %s

    // Enable the menu exit back button.
    menu.ExitBackButton = true;

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordGroupInfoMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));
        }

        case MenuAction_Cancel: {
            if(itemNum == MenuCancel_ExitBack) {
                Overlord_GroupMenu(client);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
