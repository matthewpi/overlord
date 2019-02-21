/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#define TABLE_SERVERS "\
CREATE TABLE IF NOT EXISTS `overlord_servers` (\
    `id`        INT(11)     AUTO_INCREMENT,\
    `name`      VARCHAR(64) NOT NULL,\
    `ipAddress` VARCHAR(16) NOT NULL,\
    `port`      VARCHAR(5)  NOT NULL,\
    `rconPass`  VARCHAR(64) NOT NULL,\
    PRIMARY KEY (`id`, `name`),\
    CONSTRAINT `overlord_servers_id_uindex` UNIQUE (`id`),\
    CONSTRAINT `overlord_servers_name_uindex` UNIQUE (`name`),\
    CONSTRAINT `overlord_servers_ipAddress_port_uindex` UNIQUE (`ipAddress`, `port`)\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

#define TABLE_GROUPS "\
CREATE TABLE IF NOT EXISTS `overlord_groups` (\
    `id`       INT(11)     AUTO_INCREMENT,\
    `name`     VARCHAR(32) DEFAULT 'Default' NOT NULL,\
    `tag`      VARCHAR(12) DEFAULT ''        NOT NULL,\
    `immunity` INT(4)      DEFAULT 0         NOT NULL,\
    `flags`    VARCHAR(26) DEFAULT ''        NOT NULL,\
    PRIMARY KEY (`id`, `name`, `tag`),\
    CONSTRAINT `overlord_groups_id_uindex` UNIQUE (`id`),\
    CONSTRAINT `overlord_groups_name_uindex` UNIQUE (`name`),\
    CONSTRAINT `overlord_groups_tag_uindex` UNIQUE (`tag`)\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

#define TABLE_ADMINS "\
CREATE TABLE IF NOT EXISTS `overlord_admins` (\
    `id`        INT(11)     AUTO_INCREMENT,\
    `name`      VARCHAR(32) NOT NULL,\
    `steamId`   VARCHAR(64) NOT NULL,\
    `hidden`    TINYINT(1)  DEFAULT 0 NOT NULL,\
    `active`    TINYINT(1)  DEFAULT 1 NOT NULL,\
    `createdAt` TIMESTAMP   DEFAULT CURRENT_TIMESTAMP() NOT NULL,\
    `updatedAt` TIMESTAMP   DEFAULT CURRENT_TIMESTAMP() NOT NULL ON UPDATE CURRENT_TIMESTAMP(),\
    PRIMARY KEY (`id`, `name`, `steamId`),\
    CONSTRAINT `overlord_admins_id_uindex` UNIQUE (`id`),\
    CONSTRAINT `overlord_admins_name_uindex` UNIQUE (`name`),\
    CONSTRAINT `overlord_admins_steamId_uindex` UNIQUE (`steamId`)\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

#define TABLE_ADMIN_GROUPS "\
CREATE TABLE IF NOT EXISTS `overlord_admin_groups` (\
    `id`        INT(11)    AUTO_INCREMENT,\
    `adminId`   INT(11)    NOT NULL,\
    `groupId`   INT(11)    NOT NULL,\
    `serverId`  INT(11)    NOT NULL,\
    `active`    TINYINT(1) DEFAULT 1 NOT NULL,\
    `createdAt` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP() NOT NULL,\
    `updatedAt` TIMESTAMP  DEFAULT CURRENT_TIMESTAMP() NOT NULL ON UPDATE CURRENT_TIMESTAMP(),\
    `expiresAt` TIMESTAMP  DEFAULT NULL NULL,\
    PRIMARY KEY (`id`, `adminId`, `groupId`),\
    CONSTRAINT `overlord_admin_groups_id_uindex` UNIQUE (`id`),\
    CONSTRAINT `overlord_admin_groups_adminId_serverId_uindex` UNIQUE (`adminId`, `serverId`),\
    FOREIGN KEY `overlord_admin_groups_overlord_admins_id_fk` (`adminId`) REFERENCES `overlord_admins` (`id`) ON UPDATE CASCADE,\
    FOREIGN KEY `overlord_admin_groups_overlord_groups_id_fk` (`groupId`) REFERENCES `overlord_groups` (`id`) ON UPDATE CASCADE,\
    FOREIGN KEY `overlord_admin_groups_overlord_servers_id_fk` (`serverId`) REFERENCES `overlord_servers` (`id`) ON UPDATE CASCADE\
) ENGINE=InnoDB DEFAULT CHARSET 'utf8';\
"

#define GET_SERVER "\
SELECT `overlord_servers`.`id` FROM `overlord_servers` WHERE `overlord_servers`.`ipAddress` = '%s' AND `overlord_servers`.`port` = '%s' LIMIT 1;\
"

#define INSERT_SERVER "\
INSERT INTO `overlord_servers` (`name`, `ipAddress`, `port`, `rconPass`) VALUES ('%s', '%s', '%s', '%s');\
"

#define GET_GROUPS "\
SELECT `overlord_groups`.`id`, `overlord_groups`.`name`, `overlord_groups`.`tag`, `overlord_groups`.`immunity`, `overlord_groups`.`flags` FROM `overlord_groups`;\
"

#define GET_ADMIN  "\
SELECT `overlord_admins`.`id`, `overlord_admins`.`name`, `overlord_admins`.`steamId`, `overlord_admins`.`hidden`,\
    `overlord_admins`.`active`, UNIX_TIMESTAMP(`overlord_admins`.`createdAt`) AS `createdAt`, `overlord_admin_groups`.`groupId`\
FROM `overlord_admins`\
    LEFT OUTER JOIN `overlord_admin_groups` ON `overlord_admins`.`id` = `overlord_admin_groups`.`adminId`\
                                           AND `overlord_admin_groups`.`serverId` = %i \
WHERE `overlord_admins`.`steamId` = '%s' LIMIT 1;\
"

#define UPDATE_ADMIN "\
UPDATE `overlord_admins` SET `overlord_admins`.`hidden` = %i WHERE `overlord_admins`.`steamId` = '%s' LIMIT 1;\
"

Database g_hDatabase;

/**
 * Backend_Connnection
 * Handles the database connection callback.
 */
public void Backend_Connnection(Database database, const char[] error, any data) {
    if(database == null) {
        SetFailState("%s Failed to connect to server.  Error: %s", CONSOLE_PREFIX, error);
        return;
    }

    g_hDatabase = database;
    LogMessage("%s Connected to database.", CONSOLE_PREFIX);

    Transaction transaction = SQL_CreateTransaction();
    transaction.AddQuery(TABLE_SERVERS);
    transaction.AddQuery(TABLE_GROUPS);
    transaction.AddQuery(TABLE_ADMINS);
    transaction.AddQuery(TABLE_ADMIN_GROUPS);
    SQL_ExecuteTransaction(g_hDatabase, transaction, Callback_SuccessTableTransaction, Callback_ErrorTableTransaction);
    Backend_GetServerId();
    Backend_LoadGroups();

    for(int i = 1; i <= MaxClients; i++) {
        if(!IsClientValid(i)) {
            continue;
        }

        char steamId[64];
        GetClientAuthId(i, AuthId_Steam2, steamId, sizeof(steamId));
        Backend_GetAdmin(i, steamId);
        // TODO: Transaction?
    }

    CreateTimer(15.0, Timer_TagAll, _, TIMER_REPEAT);
}

static void Callback_SuccessTableTransaction(Database database, any data, int numQueries, Handle[] results, any[] queryData) {
    //LogMessage("%s Created database tables successfully.", CONSOLE_PREFIX);
}

static void Callback_ErrorTableTransaction(Database database, any data, int numQueries, const char[] error, int failIndex, any[] queryData) {
    LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_ErrorTableTransaction", (strlen(error) > 0 ? error : "Unknown."));
}

/**
 * Backend_GetServerId
 * Loads this server's id for loading admins.
 */
static void Backend_GetServerId() {
    char ipAddress[16];
    g_cvServerIp.GetString(ipAddress, sizeof(ipAddress));
    char port[8];
    g_cvServerPort.GetString(port, sizeof(port));

    char query[512];
    Format(query, sizeof(query), GET_SERVER, ipAddress, port);
    g_hDatabase.Query(Callback_GetServerId, query);
}

static void Callback_GetServerId(Database database, DBResultSet results, const char[] error, any data) {
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_GetServerId", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Handle empty result set.
    if(results.RowCount == 0) {
        LogMessage("%s Failed to find server entry, creating one..", CONSOLE_PREFIX);
        Backend_InsertServer();
        return;
    }

    int idIndex;
    if(!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"overlord_servers\".", CONSOLE_PREFIX); return; }

    while(results.FetchRow()) {
        g_iServerId = results.FetchInt(idIndex);
        LogMessage("%s Found server entry. (id: %i)", CONSOLE_PREFIX, g_iServerId);
    }
}

/**
 * Backend_InsertServer
 * Inserts this server's information into the database.
 */
static void Backend_InsertServer() {
    char name[64];
    g_cvServerHostname.GetString(name, sizeof(name));
    char ipAddress[16];
    g_cvServerIp.GetString(ipAddress, sizeof(ipAddress));
    char port[8];
    g_cvServerPort.GetString(port, sizeof(port));
    char rconPassword[64];
    g_cvServerRconPassword.GetString(rconPassword, sizeof(rconPassword));

    char query[512];
    Format(query, sizeof(query), INSERT_SERVER, name, ipAddress, port, rconPassword);
    g_hDatabase.Query(Callback_InsertServer, query);
}

static void Callback_InsertServer(Database database, DBResultSet results, const char[] error, any data) {
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_InsertServer", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    LogMessage("%s Inserted server successfully.", CONSOLE_PREFIX);
    Backend_GetServerId();
}

/**
 * Backend_LoadGroups
 * Loads all groups from the database.
 */
public void Backend_LoadGroups() {
    g_hDatabase.Query(Callback_LoadGroups, GET_GROUPS);
}

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
            if(!FindFlagByChar(flags[i], flag)) {
                continue;
            }

            groupId.SetFlag(flag, true);
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

/**
 * Backend_GetAdmin
 * Loads a user's admin information.
 */
public void Backend_GetAdmin(int client, const char[] steamId) {
    char query[512];
    Format(query, sizeof(query), GET_ADMIN, g_iServerId, steamId);
    g_hDatabase.Query(Callback_GetAdmin, query, client);
}

static void Callback_GetAdmin(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_GetAdmin", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Ignore empty result set.
    if(results.RowCount == 0) {
        return;
    }

    // Get table column indexes.
    int idIndex;
    int nameIndex;
    int steamIdIndex;
    int groupIdIndex;
    int hiddenIndex;
    int activeIndex;
    int createdAtIndex;
    if(!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("name", nameIndex)) { LogError("%s Failed to locate \"name\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("steamId", steamIdIndex)) { LogError("%s Failed to locate \"steamId\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("groupId", groupIdIndex)) { LogError("%s Failed to locate \"groupId\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("hidden", hiddenIndex)) { LogError("%s Failed to locate \"hidden\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("active", activeIndex)) { LogError("%s Failed to locate \"active\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    if(!results.FieldNameToNum("createdAt", createdAtIndex)) { LogError("%s Failed to locate \"createdAt\" field in table \"overlord_admins\".", CONSOLE_PREFIX); return; }
    // END Get table column indexes.

    // Loop through query results.
    while(results.FetchRow()) {
        // Check if admin is deactivated.
        if(results.FetchInt(activeIndex) == 0) {
            LogMessage("%s Found admin for '%N', but it is deactivated.", CONSOLE_PREFIX, client);
            continue;
        }

        // Pull row information.
        int id = results.FetchInt(idIndex);
        char name[32];
        char steamId[64];
        int group = results.FetchInt(groupIdIndex);
        bool hidden = false;
        if(results.FetchInt(hiddenIndex) == 1) {
            hidden = true;
        }
        int createdAt = results.FetchInt(createdAtIndex);

        results.FetchString(nameIndex, name, sizeof(name));
        results.FetchString(steamIdIndex, steamId, sizeof(steamId));
        // END Pull row information.

        // Log that we found an admin.
        LogMessage("%s Found admin for '%N' (Steam ID: %s)", CONSOLE_PREFIX, client, steamId);

        // Create admin object and set properties.
        Admin admin = new Admin();
        admin.SetID(id);
        admin.SetName(name);
        admin.SetSteamID(steamId);
        admin.SetGroup(group);
        admin.SetHidden(hidden);
        admin.SetCreatedAt(createdAt);

        // Create admin
        AdminId adminId = GetUserAdmin(client);
        if(adminId == INVALID_ADMIN_ID) {
            adminId = CreateAdmin(name);
            SetUserAdmin(client, adminId, true);
        }
        // END Create admin

        // Add admin group if one isn't already present.
        if(adminId.GroupCount == 0) {
            Group userGroup = g_hGroups[group];
            if(userGroup == null) {
                continue;
            }

            char groupName[32];
            userGroup.GetName(groupName, sizeof(groupName));

            GroupId groupId = FindAdmGroup(groupName);
            if(groupId == INVALID_GROUP_ID) {
                LogError("%s Failed to locate existing admin group.", CONSOLE_PREFIX);
                continue;
            }

            if(!adminId.InheritGroup(groupId)) {
                LogError("%s Failed to inherit admin group.", CONSOLE_PREFIX);
                continue;
            }
        }
        // END Add admin group if one isn't already present.

        // Set admin's tag.
        Admin_SetTagDelayed(client);

        // Add admin to admins array.
        g_hAdmins[client] = admin;
    }
}

/**
 * Backend_UpdateAdmin
 * Updates a user's admin information.
 */
public void Backend_UpdateAdmin(int client) {
    // Get client's admin.
    Admin admin = g_hAdmins[client];
    if(admin == null) {
        return;
    }

    // Get admin's steam id.
    char steamId[64];
    admin.GetSteamID(steamId, sizeof(steamId));

    // Create and format the query.
    char query[512];
    Format(query, sizeof(query), UPDATE_ADMIN, admin.IsHidden() ? 1 : 0, steamId);

    // Run the query.
    g_hDatabase.Query(Callback_UpdateAdmin, query, client);
}

static void Callback_UpdateAdmin(Database database, DBResultSet results, const char[] error, int client) {
    // Handle query error.
    if(results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_UpdateAdmin", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Log that we saved the admin's information.
    LogMessage("%s Saved admin information for %i.", CONSOLE_PREFIX, client);
}
