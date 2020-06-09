/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

methodmap Group < StringMap {
    public Group() {
        return view_as<Group>(new StringMap());
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

    // tag
    public void GetTag(char[] buffer, const int maxlen) {
        this.GetString("tag", buffer, maxlen);
    }

    public void SetTag(const char[] tag) {
        this.SetString("tag", tag);
    }
    // END tag

    // immunity
    public int GetImmunity() {
        int immunity;
        this.GetValue("immunity", immunity);
        return immunity;
    }

    public void SetImmunity(const int immunity) {
        this.SetValue("immunity", immunity);
    }
    // END immunity

    // flags
    public void GetFlags(char[] buffer, const int maxlen) {
        this.GetString("flags", buffer, maxlen);
    }

    public void SetFlags(const char[] flags) {
        this.SetString("flags", flags);
    }
    // END flags
}
