/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

methodmap Admin < StringMap {
    public Admin() {
        return view_as<Admin>(new StringMap());
    }

    public int GetID() {
        int id;
        this.GetValue("id", id);
        return id;
    }

    public void SetID(int id) {
        this.SetValue("id", id);
    }

    public void GetName(char[] buffer, int maxlen) {
        this.GetString("name", buffer, maxlen);
    }

    public void SetName(const char[] name) {
        this.SetString("name", name);
    }

    public void GetSteamID(char[] buffer, int maxlen) {
        this.GetString("steamId", buffer, maxlen);
    }

    public void SetSteamID(const char[] steamId) {
        this.SetString("steamId", steamId);
    }

    public int GetGroup() {
        int group;
        this.GetValue("group", group);
        return group;
    }

    public void SetGroup(int group) {
        this.SetValue("group", group);
    }

    public bool IsHidden() {
        bool hidden;
        this.GetValue("hidden", hidden);
        return hidden;
    }

    public void SetHidden(bool hidden) {
        this.SetValue("hidden", hidden);
    }

    public int GetCreatedAt(char[] buffer, int maxlen) {
        int createdAt;
        this.GetValue("createdAt", createdAt);
        return createdAt;
    }

    public void SetCreatedAt(int createdAt) {
        this.SetValue("createdAt", createdAt);
    }
}
