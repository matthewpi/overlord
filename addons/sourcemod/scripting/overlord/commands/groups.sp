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
        ReplyToCommand(client, "%s You must be a player to execute this command.", CONSOLE_PREFIX);
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

        // Get and format the translation.
        char buffer[512];
        GetTranslationNP(buffer, sizeof(buffer), "%T", "sm_groups Group", client, id, name, tag, group.GetImmunity(), flags);

        // Print the group information to the client's chat.
        ReplyToCommand(client, buffer);
        matched++;
    }

    // Print a message if no groups were listed.
    if(matched == 0) {
        // Get and format the translation.
        char buffer[512];
        GetTranslation(buffer, sizeof(buffer), "%T", "sm_groups None", client);

        // Send a message to the client.
        ReplyToCommand(client, buffer);
    }

    return Plugin_Handled;
}
