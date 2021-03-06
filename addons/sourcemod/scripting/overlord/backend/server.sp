/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

/**
 * Backend_GetServerId
 * Loads this server's id for loading admins.
 */
public void Backend_GetServerId() {
    // Check if the g_dbOverlord handle is invalid.
    if (g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_GetServerId() due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Get the server's ip address.
    char ipAddress[16];
    g_cvServerIp.GetString(ipAddress, sizeof(ipAddress));

    int bufferLength = strlen(ipAddress) * 2 + 1;
    char[] escapedIpAddress = new char[bufferLength];
    g_dbOverlord.Escape(ipAddress, escapedIpAddress, bufferLength);

    // Get the server's port.
    char port[8];
    g_cvServerPort.GetString(port, sizeof(port));

    bufferLength = strlen(port) * 2 + 1;
    char[] escapedPort = new char[bufferLength];
    g_dbOverlord.Escape(port, escapedPort, bufferLength);

    // Create and format the query.
    char query[512];
    Format(query, sizeof(query), GET_SERVER, escapedIpAddress, escapedPort);

    // Execute the query.
    g_dbOverlord.Query(Callback_GetServerId, query);
}

/**
 * Callback_GetServerId
 * Backend callback for Backend_GetServerId()
 */
static void Callback_GetServerId(Database database, DBResultSet results, const char[] error, any data) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_GetServerId", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Handle empty result set.
    if (results.RowCount == 0) {
        LogMessage("%s Failed to find server entry, creating one..", CONSOLE_PREFIX);
        Backend_InsertServer();
        return;
    }

    // Get table column indexes.
    int idIndex;
    if (!results.FieldNameToNum("id", idIndex)) { LogError("%s Failed to locate \"id\" field in table \"overlord_servers\".", CONSOLE_PREFIX); return; }

    // Loop through query results.
    while (results.FetchRow()) {
        g_iServerId = results.FetchInt(idIndex);
        LogMessage("%s Found server entry. (id: %i)", CONSOLE_PREFIX, g_iServerId);
    }
}

/**
 * Backend_InsertServer
 * Inserts this server's information into the database.
 */
static void Backend_InsertServer() {
    // Check if the g_dbOverlord handle is invalid.
    if (g_dbOverlord == INVALID_HANDLE) {
        LogError("%s Failed to run Backend_InsertServer() due to an invalid database handle.", CONSOLE_PREFIX);
        return;
    }

    // Get the server's hostname.
    char hostname[64];
    g_cvServerHostname.GetString(hostname, sizeof(hostname));

    int bufferLength = strlen(hostname) * 2 + 1;
    char[] escapedHostname = new char[bufferLength];
    g_dbOverlord.Escape(hostname, escapedHostname, bufferLength);

    // Get the server's ip address.
    char ipAddress[16];
    g_cvServerIp.GetString(ipAddress, sizeof(ipAddress));

    bufferLength = strlen(ipAddress) * 2 + 1;
    char[] escapedIpAddress = new char[bufferLength];
    g_dbOverlord.Escape(ipAddress, escapedIpAddress, bufferLength);

    // Get the server's port.
    char port[8];
    g_cvServerPort.GetString(port, sizeof(port));

    bufferLength = strlen(port) * 2 + 1;
    char[] escapedPort = new char[bufferLength];
    g_dbOverlord.Escape(port, escapedPort, bufferLength);

    // Get the server's rcon password.
    char rconPassword[64];
    g_cvServerRconPassword.GetString(rconPassword, sizeof(rconPassword));

    bufferLength = strlen(rconPassword) * 2 + 1;
    char[] escapedRconPassword = new char[bufferLength];
    g_dbOverlord.Escape(rconPassword, escapedRconPassword, bufferLength);

    // Create and format the query.
    char query[512];
    Format(query, sizeof(query), INSERT_SERVER, escapedHostname, escapedIpAddress, escapedPort, escapedRconPassword);

    // Execute the query.
    g_dbOverlord.Query(Callback_InsertServer, query);
}

/**
 * Callback_InsertServer
 * Backend callback for Backend_InsertServer()
 */
static void Callback_InsertServer(Database database, DBResultSet results, const char[] error, any data) {
    // Handle query error.
    if (results == null) {
        LogError("%s Query failure. %s >> %s", CONSOLE_PREFIX, "Callback_InsertServer", (strlen(error) > 0 ? error : "Unknown."));
        return;
    }

    // Log that the insertion was successful.
    LogMessage("%s Inserted server successfully.", CONSOLE_PREFIX);

    // Retrieve the newly inserted server id. (potential insert/select loop, TODO: add limiter)
    Backend_GetServerId();
}
