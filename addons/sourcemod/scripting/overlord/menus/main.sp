/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

void Overlord_Menu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordMenu);
    menu.SetTitle("Overlord v%s", OVERLORD_VERSION);

    menu.AddItem("admins", "Admins");
    menu.AddItem("groups", "Groups");
    menu.AddItem("settings", "Settings", ITEMDRAW_DISABLED);

    // Display the menu to the client.
    if(position == -1) {
        menu.Display(client, 0);
    } else {
        menu.DisplayAt(client, position, 0);
    }
}

static int Callback_OverlordMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch(action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            if(StrEqual(info, "admins", true)) {
                Overlord_AdminMenu(client);
            } else if(StrEqual(info, "groups", true)) {
                Overlord_GroupMenu(client);
            } else if(StrEqual(info, "settings", true)) {
                //Overlord_SettingsMenu(client);
                PrintToChat(client, "%s \x07Settings Menu\x01 has not been implemented yet.", PREFIX);
            } else {
                Overlord_Menu(client, GetMenuSelectionPosition());
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
