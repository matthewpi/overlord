/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

 /**
  * Sourcemod_TextMessage
  * ?
  */
public Action Sourcemod_TextMessage(UserMsg msgId, Protobuf protobuf, const int[] players, int playerCount, bool reliable, bool init) {
    // Check if the message is not reliable.
    if(!reliable) {
        return Plugin_Continue;
    }

    char buffer[256];
    protobuf.ReadString("params", buffer, sizeof(buffer), 0);

    if(StrContains(buffer, "[SM]") == 0) {
        DataPack pack;
        CreateDataTimer(0.0, Timer_TextMessage, pack);

        pack.WriteCell(playerCount);
        for(int i = 0; i < playerCount; i++) {
            pack.WriteCell(players[i]);
        }
        pack.WriteString(buffer);
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

/**
 * Timer_TextMessage
 * ?
 */
static Action Timer_TextMessage(Handle timer, DataPack pack) {
    // Reset the pack to the beginning so we can read it.
    pack.Reset();

    int playerCount = pack.ReadCell();
    int players[MAXPLAYERS + 1];
    int client = 0;
    int count = 0;

    // Loop through all players in the datapack.
    for(int i = 0; i < playerCount; i++) {
        client = pack.ReadCell();

        // Check if client is ingame.
        if(IsClientInGame(client)) {
            players[count++] = client;
        }
    }

    if(count < 1) {
        return;
    }

    playerCount = count;

    char buffer[256];
    pack.ReadString(buffer, sizeof(buffer));

    // Replace the sourcemod prefix.
    ReplaceStringEx(buffer, sizeof(buffer), "[SM]", "[\x07Sourcemod\x01]\x08");

    Protobuf msg = view_as<Protobuf>(StartMessage("SayText2", players, playerCount, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS));
    msg.SetInt("ent_idx", -1);
    msg.SetBool("chat", true);
    msg.SetString("msg_name", buffer);
    msg.AddString("params", "");
    msg.AddString("params", "");
    msg.AddString("params", "");
    msg.AddString("params", "");
    EndMessage();
}
