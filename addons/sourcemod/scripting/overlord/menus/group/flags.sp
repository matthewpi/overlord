/**
 * Overlord_GroupFlagsMenu
 * ?
 */
void Overlord_GroupFlagsMenu(const int client, const int groupId, const int position = -1) {
    Group group = g_hGroups[groupId];
    if (group == null) {
        return;
    }

    Menu menu = CreateMenu(Callback_OverlordGroupFlagsMenu);
    menu.SetTitle("Overlord | Groups");

    // Update the "g_iOverlordMenu" array with the new groupId.
    g_iOverlordMenu[client] = groupId;

    char name[32];
    group.GetName(name, sizeof(name));

    GroupId adminGroupId = FindAdmGroup(name);
    if (adminGroupId == INVALID_GROUP_ID) {
        LogMessage("%s Failed to locate admin group. (name=%s)", CONSOLE_PREFIX, name);
        return;
    }

    if (adminGroupId.HasFlag(Admin_Reservation)) {
        menu.AddItem("reservation", "[-] Reservation");
    } else {
        menu.AddItem("reservation", "[+] Reservation");
    }

    if (adminGroupId.HasFlag(Admin_Generic)) {
        menu.AddItem("generic", "[-] Generic");
    } else {
        menu.AddItem("generic", "[+] Generic");
    }

    if (adminGroupId.HasFlag(Admin_Kick)) {
        menu.AddItem("kick", "[-] Kick");
    } else {
        menu.AddItem("kick", "[+] Kick");
    }

    if (adminGroupId.HasFlag(Admin_Ban)) {
        menu.AddItem("ban", "[-] Ban");
    } else {
        menu.AddItem("ban", "[+] Ban");
    }

    if (adminGroupId.HasFlag(Admin_Unban)) {
        menu.AddItem("unban", "[-] Unban");
    } else {
        menu.AddItem("unban", "[+] Unban");
    }

    if (adminGroupId.HasFlag(Admin_Slay)) {
        menu.AddItem("slay", "[-] Slay");
    } else {
        menu.AddItem("slay", "[+] Slay");
    }

    if (adminGroupId.HasFlag(Admin_Changemap)) {
        menu.AddItem("map", "[-] Map");
    } else {
        menu.AddItem("map", "[+] Map");
    }

    if (adminGroupId.HasFlag(Admin_Convars)) {
        menu.AddItem("cvars", "[-] Convars");
    } else {
        menu.AddItem("cvars", "[+] Convars");
    }

    if (adminGroupId.HasFlag(Admin_Config)) {
        menu.AddItem("config", "[-] Config");
    } else {
        menu.AddItem("config", "[+] Config");
    }

    if (adminGroupId.HasFlag(Admin_Chat)) {
        menu.AddItem("chat", "[-] Chat");
    } else {
        menu.AddItem("chat", "[+] Chat");
    }

    if (adminGroupId.HasFlag(Admin_Vote)) {
        menu.AddItem("vote", "[-] Vote");
    } else {
        menu.AddItem("vote", "[+] Vote");
    }

    if (adminGroupId.HasFlag(Admin_Password)) {
        menu.AddItem("password", "[-] Password");
    } else {
        menu.AddItem("password", "[+] Password");
    }

    if (adminGroupId.HasFlag(Admin_RCON)) {
        menu.AddItem("rcon", "[-] RCON");
    } else {
        menu.AddItem("rcon", "[+] RCON");
    }

    if (adminGroupId.HasFlag(Admin_Cheats)) {
        menu.AddItem("cheats", "[-] Cheats");
    } else {
        menu.AddItem("cheats", "[+] Cheats");
    }

    if (adminGroupId.HasFlag(Admin_Root)) {
        menu.AddItem("root", "[-] Root");
    } else {
        menu.AddItem("root", "[+] Root");
    }

    if (adminGroupId.HasFlag(Admin_Custom1)) {
        menu.AddItem("custom1", "[-] Custom 1");
    } else {
        menu.AddItem("custom1", "[+] Custom 1");
    }

    if (adminGroupId.HasFlag(Admin_Custom2)) {
        menu.AddItem("custom2", "[-] Custom 2");
    } else {
        menu.AddItem("custom2", "[+] Custom 2");
    }

    if (adminGroupId.HasFlag(Admin_Custom3)) {
        menu.AddItem("custom3", "[-] Custom 3");
    } else {
        menu.AddItem("custom3", "[+] Custom 3");
    }

    if (adminGroupId.HasFlag(Admin_Custom4)) {
        menu.AddItem("custom4", "[-] Custom 4");
    } else {
        menu.AddItem("custom4", "[+] Custom 4");
    }

    if (adminGroupId.HasFlag(Admin_Custom5)) {
        menu.AddItem("custom5", "[-] Custom 5");
    } else {
        menu.AddItem("custom5", "[+] Custom 5");
    }

    if (adminGroupId.HasFlag(Admin_Custom6)) {
        menu.AddItem("custom6", "[-] Custom 6");
    } else {
        menu.AddItem("custom6", "[+] Custom 6");
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

static int Callback_OverlordGroupFlagsMenu(Menu menu, MenuAction action, int client, int itemNum) {
    switch (action) {
        case MenuAction_Select: {
            char info[32];
            menu.GetItem(itemNum, info, sizeof(info));

            // Get the active group id.
            int groupId = g_iOverlordMenu[client];

            // Get the group object using the groupId.
            Group group = g_hGroups[groupId];
            if (group == null) {
                Overlord_GroupMenu(client);
                return;
            }

            char name[32];
            group.GetName(name, sizeof(name));

            GroupId adminGroupId = FindAdmGroup(name);
            if (adminGroupId == INVALID_GROUP_ID) {
                LogMessage("%s Failed to locate admin group. (name=%s)", CONSOLE_PREFIX, name);
                return;
            }

            AdminFlag flag;
            if (StrEqual(info, "reservation")) {
                flag = Admin_Reservation;
            } else if (StrEqual(info, "generic")) {
                flag = Admin_Generic;
            } else if (StrEqual(info, "kick")) {
                flag = Admin_Kick;
            } else if (StrEqual(info, "ban")) {
                flag = Admin_Ban;
            } else if (StrEqual(info, "unban")) {
                flag = Admin_Unban;
            } else if (StrEqual(info, "slay")) {
                flag = Admin_Slay;
            } else if (StrEqual(info, "map")) {
                flag = Admin_Changemap;
            } else if (StrEqual(info, "cvars")) {
                flag = Admin_Convars;
            } else if (StrEqual(info, "config")) {
                flag = Admin_Config;
            } else if (StrEqual(info, "chat")) {
                flag = Admin_Chat;
            } else if (StrEqual(info, "vote")) {
                flag = Admin_Vote;
            } else if (StrEqual(info, "password")) {
                flag = Admin_Password;
            } else if (StrEqual(info, "rcon")) {
                flag = Admin_RCON;
            } else if (StrEqual(info, "cheats")) {
                flag = Admin_Cheats;
            } else if (StrEqual(info, "root")) {
                flag = Admin_Root;
            } else if (StrEqual(info, "custom1")) {
                flag = Admin_Custom1;
            } else if (StrEqual(info, "custom2")) {
                flag = Admin_Custom2;
            } else if (StrEqual(info, "custom3")) {
                flag = Admin_Custom3;
            } else if (StrEqual(info, "custom4")) {
                flag = Admin_Custom4;
            } else if (StrEqual(info, "custom5")) {
                flag = Admin_Custom5;
            } else if (StrEqual(info, "custom6")) {
                flag = Admin_Custom6;
            } else {
                LogMessage("%s Unknown admin flag: %s", CONSOLE_PREFIX, info);
                return;
            }
            
            // Toggle the flag.
            adminGroupId.SetFlag(flag, !adminGroupId.HasFlag(flag));

            if (adminGroupId.HasFlag(flag)) {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Add Group Flag", client, name, info);

                // Send the translated message to the client.
                PrintToChat(client, buffer);
            } else {
                // Get and format the translation.
                char buffer[512];
                GetTranslation(buffer, sizeof(buffer), "%T", "Remove Group Flag", client, name, info);

                // Send the translated message to the client.
                PrintToChat(client, buffer);
            }

            // Get the group's flag bitstring.
            int flagBits = adminGroupId.GetFlags();

            AdminFlag flags[32];
            int flagCount = FlagBitsToArray(flagBits, flags, sizeof(flags));

            int flagBit;
            char flagString[32];
            int flagStringCount = 0;
            for (int i = 0; i < flagCount; i++) {
                if (!FindFlagChar(flags[i], flagBit)) {
                    PrintToConsole(client, "%s Failed to find flag char.", CONSOLE_PREFIX);
                    continue;
                }

                // Add the flagbit to the flag string.
                flagString[flagStringCount] = flagBit;
                flagStringCount++;
            }

            // Update the group's flags.
            group.SetFlags(flagString);

            Backend_UpdateGroup(groupId);

            Overlord_GroupFlagsMenu(client, groupId, GetMenuSelectionPosition());
        }

        case MenuAction_Cancel: {
            if (itemNum == MenuCancel_ExitBack) {
                Overlord_GroupInfoMenu(client, g_iOverlordMenu[client]);
            }
        }

        case MenuAction_End: {
            delete menu;
        }
    }
}
