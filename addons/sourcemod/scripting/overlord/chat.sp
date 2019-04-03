/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

#define CHAT_LENGTH_NAME    64
#define CHAT_LENGTH_INPUT   128
#define CHAT_LENGTH_MESSAGE 256

#define CHAT_FLAGS_INVALID   0
#define CHAT_FLAGS_ALL       (1 << 0)
#define CHAT_FLAGS_TEAM      (1 << 1)
#define CHAT_FLAGS_DEAD      (1 << 2)
#define CHAT_FLAGS_SPECTATOR (1 << 3)

StringMap g_mChatTranslations = null;
ArrayList g_alMessages = null;

/**
 * Chat_Register
 * ?
 */
public void Chat_Register() {
    UserMsg sayText2 = GetUserMessageId("SayText2");

    if(sayText2 == INVALID_MESSAGE_ID) {
        LogMessage("%s This server does not support \"SayText2\", disabling chat formatting.", CONSOLE_PREFIX);
        return;
    }

    g_mChatTranslations = new StringMap();
    g_mChatTranslations.SetString("Cstrike_Chat_All", "Chat All");
    g_mChatTranslations.SetString("Cstrike_Chat_AllDead", "Chat All Dead");
    g_mChatTranslations.SetString("Cstrike_Chat_AllSpec", "Chat All Spectator");
    g_mChatTranslations.SetString("Cstrike_Chat_T", "Chat Team T");
    g_mChatTranslations.SetString("Cstrike_Chat_T_Dead", "Chat Team T Dead");
    g_mChatTranslations.SetString("Cstrike_Chat_CT", "Chat Team CT");
    g_mChatTranslations.SetString("Cstrike_Chat_CT_Dead", "Chat Team CT Dead");
    g_mChatTranslations.SetString("Cstrike_Chat_Spec", "Chat Team Spectator");

    g_alMessages = new ArrayList();

    HookUserMessage(sayText2, Chat_OnSayText2, true);
}

/**
 * Chat_ProcessQueue
 * ?
 */
public void Chat_ProcessQueue() {
    for(int i = 0; i < g_alMessages.Length; i++) {
        DataPack pack = g_alMessages.Get(i);
        pack.Reset();

        int client = pack.ReadCell();
        int recipientCountStart = pack.ReadCell();
        int recipientCount;
        int[] clients = new int[recipientCountStart];
        ArrayList recipients = new ArrayList();

        for(int j = 0; j < recipientCountStart; j++) {
            int buffer = pack.ReadCell();

            if(IsClientValid(buffer)) {
                clients[recipientCount++] = buffer;
                recipients.Push(buffer);
            }
        }

        bool console = view_as<bool>(pack.ReadCell());

        // Get the translation name.
        char translationName[32];
        pack.ReadString(translationName, sizeof(translationName));

        // Get the sender's name.
        char senderName[CHAT_LENGTH_NAME];
        pack.ReadString(senderName, sizeof(senderName));

        // Get the message content.
        char messageContent[CHAT_LENGTH_INPUT];
        pack.ReadString(messageContent, sizeof(messageContent));

        // Get the sender's team name.
        int team = GetClientTeam(client);
        char teamName[32];
        GetClientTeamName(team, teamName, sizeof(teamName));

        char userTag[32] = "\x03[\x01Beginner\x03] ";
        char extra[32];

        // Check if the user is an admin.
        Admin admin = g_hAdmins[client];
        if(admin != null) {
            char adminSteamId[32];
            admin.GetSteamID(adminSteamId, sizeof(adminSteamId));

            if(StrEqual(adminSteamId, "STEAM_1:1:530997", true)) {
                // Add a sexy user tag. :)
                userTag = "\x03[\x01Autist\x03] ";

                // Add a dark red name color.
                Format(senderName, sizeof(senderName), "\x02%s", senderName);

                // Add a dark red message color.
                Format(messageContent, sizeof(messageContent), "\x02%s", messageContent);
            }

            // Get and format the group tag.
            Group group = g_hGroups[admin.GetGroup()];
            if(group != null) {
                char groupTag[16];
                group.GetTag(groupTag, sizeof(groupTag));
                Format(extra, sizeof(extra), "\x03(%s) ", groupTag);
            }
        }

        // Check if the sender is on the spectator team.
        if(team == CS_TEAM_SPECTATOR) {
            // Remove the user tag.
            userTag = "";
        }

        char prefix[64];
        Format(prefix, sizeof(prefix), "%s%s[%s]", userTag, extra, teamName);

        char translatedMessage[CHAT_LENGTH_MESSAGE];
        Format(translatedMessage, sizeof(translatedMessage), "%t", translationName, senderName, messageContent, prefix);

        Handle msg = StartMessage("SayText2", clients, recipientCount, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);

        if(pack.ReadCell()) {
            Protobuf protobuf = UserMessageToProtobuf(msg);

            protobuf.SetInt("ent_idx", client);
            protobuf.SetBool("chat", console);

            protobuf.SetString("msg_name", translatedMessage);
            protobuf.AddString("params", "");
            protobuf.AddString("params", "");
            protobuf.AddString("params", "");
            protobuf.AddString("params", "");
        } else {
            BfWrite buf = UserMessageToBfWrite(msg);
            buf.WriteByte(client);
            buf.WriteByte(console);
            buf.WriteString(translatedMessage);
        }

        EndMessage();

        delete recipients;
        delete pack;

        g_alMessages.Erase(i);
    }
}

/**
 * Chat_OnSayText2
 * ?
 */
public Action Chat_OnSayText2(UserMsg msgId, BfRead msg, const int[] players, int playerCount, bool reliable, bool init) {
    bool isProtobuf = (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf);

    // Get the sender of the message.
    int sender;
    if(isProtobuf) {
        sender = UserMessageToProtobuf(msg).ReadInt("ent_idx");
    } else {
        sender = msg.ReadByte();
    }

    if(sender == 0) {
        return Plugin_Continue;
    }

    // Get a boolean based off of if the message was sent by the console.
    bool console;
    if(isProtobuf) {
        console = UserMessageToProtobuf(msg).ReadBool("chat");
    } else {
        console = (msg.ReadByte() ? true : false);
    }

    char translationNameTemp[128];
    if(isProtobuf) {
        UserMessageToProtobuf(msg).ReadString("msg_name", translationNameTemp, sizeof(translationNameTemp));
    } else {
        msg.ReadString(translationNameTemp, sizeof(translationNameTemp));
    }

    char translationName[128];
    if(!g_mChatTranslations.GetString(translationNameTemp, translationName, sizeof(translationName))) {
        return Plugin_Continue;
    }

    int messageFlags;
    if(StrContains(translationNameTemp, "All", false) != -1) {
        messageFlags = messageFlags | CHAT_FLAGS_ALL;
    }
    if(StrContains(translationNameTemp, "Cstrike_Chat_CT", false) != -1 || StrContains(translationNameTemp, "Cstrike_Chat_T", false) != -1) {
        messageFlags = messageFlags | CHAT_FLAGS_TEAM;
    }
    if(StrContains(translationNameTemp, "Spec", false) != -1) {
        messageFlags = messageFlags | CHAT_FLAGS_SPECTATOR;
    }
    if(StrContains(translationNameTemp, "Dead", false) != -1) {
        messageFlags = messageFlags | CHAT_FLAGS_DEAD;
    }

    // Get the sender's name.
    char senderName[CHAT_LENGTH_NAME];
    if(isProtobuf) {
        UserMessageToProtobuf(msg).ReadString("params", senderName, sizeof(senderName), 0);
    } else {
        msg.ReadString(senderName, sizeof(senderName));
    }

    // Get the message content.
    char messageContent[CHAT_LENGTH_INPUT];
    if(isProtobuf) {
        UserMessageToProtobuf(msg).ReadString("params", messageContent, sizeof(messageContent), 1);
    } else {
        msg.ReadString(messageContent, sizeof(messageContent));
    }

    // Get the message's recipients.
    ArrayList recipients = new ArrayList();
    for(int i = 0; i < playerCount; i++) {
        recipients.Push(players[i]);
    }

    // Create a timer to print the message during the next GameFrame.
    DataPack pack = new DataPack();
    int recipientCount = recipients.Length;

    pack.WriteCell(sender);

    for(int i = 0; i < recipientCount; i++) {
        int recipient = recipients.Get(i);

        if(!IsClientValid(recipient)) {
            recipientCount--;
            recipients.Erase(i);
        }
    }

    pack.WriteCell(recipientCount);

    for(int i = 0; i < recipientCount; i++) {
        pack.WriteCell(recipients.Get(i));
    }

    pack.WriteCell(console);
    pack.WriteString(translationName);
    pack.WriteString(senderName);
    pack.WriteString(messageContent);
    g_alMessages.Push(pack);
    pack.WriteCell(isProtobuf);
    pack.WriteCell(messageFlags);

    delete recipients;

    // Prevent the original message from being sent.
    return Plugin_Handled;
}
