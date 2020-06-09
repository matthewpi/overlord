/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Overlord_NewAdminMenu
 * ?
 */
void Overlord_NewAdminMenu(const int client, const int position = -1) {
    Menu menu = CreateMenu(Callback_OverlordNewAdminMenu);
    menu.SetTitle("Overlord | New Admin");

    char info[32];
    char display[128];
    for (int i = 1; i <= MaxClients; i++) {
        // Check if the client is invalid.
        if (!IsClientValid(i)) {
            continue;
        }

        // Check if the client is an admin
        if (g_hAdmins[i] != null) {
            continue;
        }

        Format(info, sizeof(info), "%i", i);
        Format(display, sizeof(display), "%N", i);

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

static int Callback_OverlordNewAdminMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));
            int adminId = StringToInt(info);

            // Check if the client is invalid.
            if (!IsClientValid(adminId)) {
                return;
            }

            // Get the client's steam id.
            char steamId[64];
            GetClientAuthId(adminId, AuthId_Steam2, steamId, sizeof(steamId));

            Admin admin = new Admin();
            admin.SetID(-1);
            admin.SetName("unknown");
            admin.SetSteamID(steamId);
            admin.SetGroupID(0);
            admin.SetServerGroupID(0);
            admin.SetHidden(false);
            admin.SetCreatedAt(GetTime());

            // Save the admin object.
            g_hAdmins[adminId] = admin;
            PrintToChat(client, "%s Added \x10%N\x01 to the list of \x07Admins\x01.", PREFIX, adminId);

            // Call the "g_hOnAdminAdded" forward.
            Call_StartForward(g_hOnAdminAdded);
            Call_PushCell(adminId);
            Call_Finish();

            // Display the admin info menu.
            Overlord_AdminInfoMenu(client, adminId);

            // Insert the new admin.
            Backend_InsertAdmin(adminId);
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
