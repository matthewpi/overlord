/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Admins (sm_admins)
 * Prints a list of all online and non-hidden admins.
 */
public Action Command_Admins(const int client, const int args) {
	// Check if the client is invalid.
	if(!IsClientValid(client)) {
		ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
		return Plugin_Handled;
	}

	// Get the client's immunity level.
	int immunity = 0;
	AdminId adminId = GetUserAdmin(client);
	if(adminId != INVALID_ADMIN_ID) {
		immunity = adminId.ImmunityLevel;
	}

	// Loop through all admins.
	int matched = 0;
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

		// Get the admin's steamid.
		char steamId[64];
		admin.GetSteamID(steamId, sizeof(steamId));

		// Get the admin's group name.
		char groupName[32];
		group.GetName(groupName, sizeof(groupName));

		// Print the admin information to the client's chat.
		PrintToChat(client, " \x02%N\x01 \x0F%s\x01 \x10%s\x01%s", i, steamId, groupName, admin.IsHidden() ? " (\x09Hidden\x01)" : "");
		matched++;
	}

	// Print a message if no admins were listed.
	if(matched == 0) {
		PrintToChat(client, "%s There are currently no \x10Admins\x01 online.", PREFIX);
	}

	return Plugin_Handled;
}
