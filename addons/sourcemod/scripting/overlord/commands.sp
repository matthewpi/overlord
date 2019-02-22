/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Admins (sm_admins)
 * Prints a list of all online and non-hidden admins.
 */
public Action Command_Admins(const int client, const int args) {
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
		PrintToChat(client, "%s There are currently no \x10VIPs\x01 online.", PREFIX);
	}

	return Plugin_Handled;
}

/**
 * Command_VIP (sm_vip)
 * Prints a list of all online VIPs.
 */
public Action Command_VIP(const int client, const int args) {
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

		// Check if the group isn't VIP.
		if(group.GetImmunity() != 0) {
			continue;
		}

		// Get the vip's steamid.
		char steamId[64];
		admin.GetSteamID(steamId, sizeof(steamId));

		// Print the vip information to the client's chat.
		PrintToChat(client, " \x02%N\x01 \x0F%s\x01", i, steamId);
		matched++;
	}

	// Print a message if no vips were listed.
	if(matched == 0) {
		PrintToChat(client, "%s There are currently no \x10VIPs\x01 online.", PREFIX);
	}

	return Plugin_Handled;
}

/**
 * Command_Groups (sm_groups)
 * Prints a list of all loaded groups.
 */
public Action Command_Groups(const int client, const int args) {
	// Loop through all groups.
	int matched = 0;
	for(int i = 1; i < sizeof(g_hGroups); i++) {
		// Get the group object from the groups array.
		Group group = g_hGroups[i];
		if(group == null) {
			continue;
		}

		// Get the group's id.
		int id = group.GetID();

		// Get the group's name.
		char name[32];
		group.GetName(name, sizeof(name));

		// Get the group's tag.
		char tag[16];
		group.GetTag(tag, sizeof(tag));

		// Get the group's flags.
		char flags[26];
		group.GetFlags(flags, sizeof(flags));

		// Print the group information to the client's chat.
		PrintToChat(client, "%s %i \x10%s \x01\"\x07%s\x01\" \x0E%i\x01 | \x09%s\x01", PREFIX, id, name, tag, group.GetImmunity(), flags);
	}

	// Print a message if no groups were listed.
	if(matched == 0) {
		PrintToChat(client, "%s There are no \x10Groups\x01 loaded.", PREFIX);
	}

	return Plugin_Handled;
}

/**
 * Command_Hide (sm_hide)
 * Admin command that allows them to toggle their hidden status.
 */
public Action Command_Hide(const int client, const int args) {
	// Check if the client isn't an admin
	if(GetUserAdmin(client) == INVALID_ADMIN_ID) {
		PrintToChat(client, "%s No permission.", PREFIX);
		return Plugin_Handled;
	}

	// Get the client's admin.
	Admin admin = g_hAdmins[client];
	if(admin == null) {
		return Plugin_Handled;
	}

	// Update the admin's hidden state.
	admin.SetHidden(!admin.IsHidden());

	// Notify the admin.
	PrintToChat(client, "%s \x10%N\x01 is now %s\x01 to all players.", PREFIX, client, admin.IsHidden() ? "\x04Hidden" : "\x07Visible");

	return Plugin_Handled;
}
