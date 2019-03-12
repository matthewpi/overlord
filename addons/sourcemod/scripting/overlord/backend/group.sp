/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Backend_LoadGroups
 * Loads all groups from the database.
 */
public void Backend_LoadGroups() {
    // Check if the g_dbOverlord handle is invalid.
    if(g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_LoadGroups() due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Execute GET_GROUPS query.
    g_dbOverlord.Query(Callback_LoadGroups, GET_GROUPS);
}

/**
 * Callback_LoadGroups
 * Backend callback for Backend_LoadGroups()
 */
static void Callback_LoadGroups(Database database, DBResultSet results, const char[] error, any data) {
    // Handle query error.
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_LoadGroups", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Get table column indexes.
    int idIndex;
    int nameIndex;
    int tagIndex;
    int immunityIndex;
    int flagsIndex;
    if(!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"overlord_groups\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("name", nameIndex)) { LogError("%s Failed to locate \"name\" field in table \"overlord_groups\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("tag", tagIndex)) { LogError("%s Failed to locate \"tag\" field in table \"overlord_groups\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("immunity", immunityIndex)) { LogError("%s Failed to locate \"immunity\" field in table \"overlord_groups\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("flags", flagsIndex)) { LogError("%s Failed to locate \"flags\" field in table \"overlord_groups\".", CONSOLE_PREFIX); return; }
    // END Get table column indexes.

    Group groups[GROUP_MAX];
    int groupCount = 0;

    // Loop through query results.
    while(results.FetchRow()) {
        // Pull row information.
        int id = results.FetchInt(idIndex);
        char name[32];
        char tag[16];
        int immunity = results.FetchInt(immunityIndex);
        char flags[26];

        results.FetchString(nameIndex, name, sizeof(name));
        results.FetchString(tagIndex, tag, sizeof(tag));
        results.FetchString(flagsIndex, flags, sizeof(flags));
        // END Pull row information.

        // Create group object and set properties.
        Group group = new Group();
        group.SetID(id);
        group.SetName(name);
        group.SetTag(tag);
        group.SetImmunity(immunity);
        group.SetFlags(flags);

        // Admin group
        GroupId groupId = CreateAdmGroup(name);
        if(groupId == INVALID_GROUP_ID) {
            // Find existing admin group.
            groupId = FindAdmGroup(name);
            if(groupId == INVALID_GROUP_ID) {
                // Log that we failed to find an existing admin group.
                LogError("%s Failed to locate existing admin group.", CONSOLE_PREFIX);
                continue;
            }
        }
        // END Admin group

        // Set admin group immunity level.
        groupId.ImmunityLevel = immunity;

        // Set admin group flags.
        AdminFlag flag;
        int i = 0;
        while(flags[i] != '\0') {
            // Get an AdminFlag by using the char.
            if(!FindFlagByChar(flags[i], flag)) {
                continue;
            }

            // Add the AdminFlag to the group.
            groupId.SetFlag(flag, true);
            // Increment. (what flag are we on)
            i++;
        }
        // END Set admin group flags.

        // Add group to groups array.
        groups[id] = group;

        // Increment group count.
        groupCount++;
    }

    // Log group count.
    LogMessage("%s Loaded %i admin groups.", CONSOLE_PREFIX, groupCount);

    // Update global group array.
    g_hGroups = groups;
}
