/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Command_Groups (sm_groups)
 * Prints a list of all loaded groups.
 */
public Action Command_Groups(const int client, const int args) {
	// Check if the client is invalid.
	if(!IsClientValid(client)) {
		ReplyToCommand(client, "%s You must be a client to execute this command.", CONSOLE_PREFIX);
		return Plugin_Handled;
	}

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
