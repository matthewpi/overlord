/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

methodmap Admin < StringMap {
    public Admin() {
        return view_as<Admin>(new StringMap());
    }

    // id
    public int GetID() {
        int id;
        this.GetValue("id", id);
        return id;
    }

    public void SetID(const int id) {
        this.SetValue("id", id);
    }
    // END id

    // name
    public void GetName(char[] buffer, const int maxlen) {
        this.GetString("name", buffer, maxlen);
    }

    public void SetName(const char[] name) {
        this.SetString("name", name);
    }
    // END name

    // steamId
    public void GetSteamID(char[] buffer, const int maxlen) {
        this.GetString("steamId", buffer, maxlen);
    }

    public void SetSteamID(const char[] steamId) {
        this.SetString("steamId", steamId);
    }
    // END steamId

    // groupId
    public int GetGroupID() {
        int group;
        this.GetValue("groupId", group);
        return group;
    }

    public void SetGroupID(const int group) {
        this.SetValue("groupId", group);
    }
    // END groupId

    // admin_groups.groupId
    public int GetServerGroupID() {
        int serverGroupId;
        this.GetValue("serverGroupId", serverGroupId);
        return serverGroupId;
    }

    public void SetServerGroupID(const int serverGroupId) {
        this.SetValue("serverGroupId", serverGroupId);
    }
    // END admin_groups.groupId

    public int GetGroup() {
        int serverGroupId = this.GetServerGroupID();

        if(serverGroupId == 0) {
            return this.GetGroupID();
        }

        return serverGroupId;
    }

    // hidden
    public bool IsHidden() {
        bool hidden;
        this.GetValue("hidden", hidden);
        return hidden;
    }

    public void SetHidden(bool hidden) {
        this.SetValue("hidden", hidden);
    }
    // END hidden

    // createdAt
    public int GetCreatedAt() {
        int createdAt;
        this.GetValue("createdAt", createdAt);
        return createdAt;
    }

    public void SetCreatedAt(const int createdAt) {
        this.SetValue("createdAt", createdAt);
    }
    // END createdAt
}
