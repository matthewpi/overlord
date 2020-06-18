/**
 * Copyright (c) 2019 Matthew Penner <me@matthewp.io>
 * All rights reserved.
 */

// Materials
//#define OVERLORD_MAT_LIGHTNING "materials/lightning/laserbeam.vmt"
//#define OVERLORD_MAT_LIGHTNING "materials/overlord/laserbeam.vmt"
#define OVERLORD_MAT_LIGHTNING "overlord/laserbeam.vmt"

//#define OVERLORD_MAT_SMOKE "materials/sprites/steam1.vmt"
#define OVERLORD_MAT_SMOKE "sprites/steam1.vmt"
// END Materials

// Sounds
#define OVERLORD_SND_HOG "overlord/hog.mp3"
// END Sounds

public void AddAssetsToDownloadTable() {
    // Materials
    // AddFileToDownloadsTable(OVERLORD_MAT_LIGHTNING);

    // AddFileToDownloadsTable(OVERLORD_MAT_SMOKE);
    AddFileToDownloadsTable("materials/overlord/laserbeam.vmt");
    AddFileToDownloadsTable("materials/sprites/steam1.vmt");
    // END Materials

    // Sounds
    AddFileToDownloadsTable("sound/overlord/hog.mp3");
    // END Sounds
}

public void PrecacheAssets() {
    // Materials
    g_iLightningSprite = PrecacheModel(OVERLORD_MAT_LIGHTNING, true);
    g_iSmokeSprite = PrecacheModel(OVERLORD_MAT_SMOKE, true);
    // END Materials

    // Sounds
    PrecacheSound(OVERLORD_SND_HOG, true);
    // END Sounds
}
