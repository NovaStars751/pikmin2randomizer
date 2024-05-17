module p2randomizer;

import p2cave_serial;
import p2gen_serial;
import p2treasure_serial;
import p2carcass_serial;
import std.algorithm;
import std.conv;
import std.random;
import std.range;
import std.stdio;

///Contains all possible valid options for the randomizer
struct P2RandoOptions
{
    ///Logic type for the randomizer(0 = Glitchless Logic 1 = Glitched Logic)
    int randoLogic;
    ///Game type for the randomizer(0 = Vanilla 1 = Brocoli Mode)
    int gameType;
    ///How the caves are randomized(0 = Swap 1 = Shuffled Floors 2 = Kurumizome Style 3 = Randomize)
    int caveType;
    ///What region version of treasures will be used (0 = US 1 = EUR 2 = JP)
    int treasureSkinType;
    ///How the overworld treasures are randomized (0 = Vanilla 1 = Shuffle 2 = Randomize)
    int groundTreasureType;
    ///How the overworld enemies are randomized (0 = Vanilla 1 = Shuffle 2 = Randomize)
    int groundTekiType;
    ///If not null, the seed that will be used for every cave
    string caveSeed = "";
}

///Contains all game state information for a Pikmin 2 Instance
struct P2Game
{
    P2CaveInfo[] caves;
    P2BGMInfo[] caveBgms;
    P2GenInfo[] gens;
    P2GameStage stageInfo;
    //P2EnemyInfo enemyParms; TBD
    //P2TreasureInfo treasureParms; TBD
    P2CarcassesInfo[] carcassConfig;
}

///Contains a string id & cave object pair
struct P2CaveInfo
{
    string caveName;
    P2Cave caveInfo;
}

///Contains a string id & cave bgm object pair
struct P2BGMInfo
{
    string bgmName;
    P2CaveBGM bgmInfo;
}

///Contains a string id & gen object pair
struct P2GenInfo
{
    string genName;
    P2Gen  genInfo;
}

struct P2CarcassesInfo
{
    string carcassName;
    P2Carcass carcassInfo;
}

string p2CaveFolder = "root/files/user/Mukki/mapunits/caveinfo/";

string[] p2CaveFilePaths = [
    "tutorial_1.txt",
    "tutorial_2.txt",
    "tutorial_3.txt",
    "forest_1.txt",
    "forest_2.txt",
    "forest_3.txt",
    "forest_4.txt",
    "yakushima_1.txt",
    "yakushima_2.txt",
    "yakushima_3.txt",
    "yakushima_4.txt",
    "last_1.txt",
    "last_2.txt",
    "last_3.txt",
];

string p2CaveBgmFolder = "root/files/user/Totaka/";

string[] p2CaveBgmFilePaths = [
    "BgmList_Tutorial.txt",
    "BgmList_Forest.txt",
    "BgmList_Yakushima.txt",
    "BgmList_Last.txt",
];

string p2GenFolder = "root/files/user/Abe/map/";

string[] p2GenFilePaths = [
    "tutorial/initgen.txt",
    "forest/initgen.txt",
    "yakushima/initgen.txt",
    "last/initgen.txt",
];

string p2StageFilePath = "root/files/user/Abe/stages.txt";

// all treasures that appear in caves, with exceptions
string[] p2caveTreasures = [
    "tape_yellow",
    "dia_a_red",
    "juji_key_fc",
    "donutswhite",
    "dia_c_green",
    "donuts_ichigo_s",
    "dia_b_blue",
    "fire_helmet",
    "chocoichigo_l",
    "diamond_red",
    "gum_tape",
    "g_futa_kajiwara",
    "kinoko_doku",
    "leaf_normal",
    "g_futa_titiyas",
    "ahiru_head",
    "kan_b_gold",
    "sinjyu",
    "kan_nichiro",
    "chocolate",
    "locket",
    "tape_blue",
    "diamond_blue",
    "gum_tape_s",
    "tel_dial",
    "sinkukan_c",
    "gear_silver",
    "bolt",
    "gear",
    "bane",
    "mojiban",
    "nut",
    "sinkukan",
    "channel",
    "bolt_l",
    "sinkukan_b",
    "denchi_1_black",
    "tape_red",
    "Xmas_item",
    "teala_dia_a",
    "chess_king_black",
    "toy_ring_c_blue",
    "bell_red",
    "toy_ring_a_green",
    "toy_ring_c_red",
    "toy_ring_c_green",
    "be_dama_red",
    "chess_king_white",
    "chess_queen_black",
    "yoyo_red",
    "bell_yellow",
];

string[] p2caveUpgrades = [
    "fue_a",
    "fue_b",
    "fue_wide",
    "fue_pullout",
    "light_a",
    "suit_powerup",
    "suit_fire",
    "dashboots",
    "radar_a",
    "radar_b",
    "key",
];


P2Game serializeGame()
{
    P2Game game;
    for (int i = 0; i < p2CaveFilePaths.length; i++)
    {
        File caveFile = File(p2CaveFolder ~ p2CaveFilePaths[i], "r");
        game.caves ~= P2CaveInfo(p2CaveFilePaths[i], serializeCave(caveFile));
        caveFile.close();
    }
    for (int i = 0; i < p2CaveBgmFilePaths.length; i++)
    {
        File caveBgmFile = File(p2CaveBgmFolder ~ p2CaveBgmFilePaths[i], "r");
        game.caveBgms ~= P2BGMInfo(p2CaveBgmFilePaths[i], serializeCaveBgm(caveBgmFile));
        caveBgmFile.close();
    }
    for (int i = 0; i < p2GenFilePaths.length; i++)
    {
        File genFile = File(p2GenFolder ~ p2GenFilePaths[i], "r");
        game.gens ~= P2GenInfo(p2GenFilePaths[i], serializeGen(genFile));
        genFile.close();
    }
    File stagetxt = File (p2StageFilePath, "r");
    game.stageInfo = serializeStage(stagetxt);
    stagetxt.close();
    return game;
}

int deserializeGame(P2Game game)
{
    for (int i = 0; i < game.caves.length; i++)
    {
        P2CaveInfo cave = game.caves[i];
        deserializeCave(cave.caveInfo, p2CaveFolder ~ cave.caveName);
    }
    for (int i = 0; i < game.caveBgms.length; i++)
    {
        P2BGMInfo caveBgm = game.caveBgms[i];
        deserializeCaveBgm(caveBgm.bgmInfo, p2CaveBgmFolder ~ caveBgm.bgmName);
    }
    for (int i = 0; i < game.gens.length; i++)
    {
        P2GenInfo gen = game.gens[i];
        deserializeGen(gen.genInfo, p2GenFolder ~ gen.genName);
    }
    deserializeStage(game.stageInfo, p2StageFilePath);
    return 1;
}

///Takes the chosen randomizer options and applies them to the extracted Pikmin 2 ISO
int randomizeGame(P2RandoOptions randoSettings)
{
    // NOTE: Set Seed Randomization DIFFERS BETWEEN PLATFORMS!!!!!!!!!!!!! https://issues.dlang.org/show_bug.cgi?id=15147
    // Assuming the iso is already extracted and placed next to us, serialize the information
    writeln("Reading game data...");
    P2Game game = serializeGame();
    writeln("Done!");

    // Time to randomize!
    // 1. Randomize the Caves
    final switch (randoSettings.caveType)
    {
        case 0: // Swap: Swap a cave with another
            /* MAIN LOGIC RULES:
               1. Emergence Cave must stay the same in Vanilla Gametype
               2. White Flower Garden must stay the same or move to Hole of Beasts in Vanilla Gametype
            */
            // Create a struct array containing cave filename and cave treasure amount
            writeln("Swapping Caves....");
            struct CaveSwapInfo
            {
                uint treasureNum;
                string caveFilename;

            }
            CaveSwapInfo[] caveList;
            // Ugly but I've yet to find a clean for loop method for this
            // Instanting a fixed length array bars us from randomShuffle since it fails isRandomAccess
            
            int stagesR = 0;
            int cavesR = 1;
            while (stagesR != 3 && cavesR != 3) {
                caveList ~= CaveSwapInfo(game.stageInfo.stages[stagesR].stageCave.caves[cavesR].treasureNum, 
                game.stageInfo.stages[stagesR].stageCave.caves[cavesR].caveFilename);
                cavesR++;
                if (cavesR == 3 && stagesR == 0) {
                    cavesR = 0;
                    stagesR++;
                } elif (cavesR == 4); {
                    cavesR = 0;
                    stagesR++;
                }
            }

           // caveList ~= CaveSwapInfo(game.stageInfo.stages[0].stageCave.caves[1].treasureNum, 
           //     game.stageInfo.stages[0].stageCave.caves[1].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[0].stageCave.caves[2].treasureNum, 
           //     game.stageInfo.stages[0].stageCave.caves[2].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[1].stageCave.caves[0].treasureNum, 
           //     game.stageInfo.stages[1].stageCave.caves[0].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[1].stageCave.caves[1].treasureNum, 
           //     game.stageInfo.stages[1].stageCave.caves[1].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[1].stageCave.caves[2].treasureNum, 
           //     game.stageInfo.stages[1].stageCave.caves[2].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[1].stageCave.caves[3].treasureNum, 
           //    game.stageInfo.stages[1].stageCave.caves[3].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[2].stageCave.caves[0].treasureNum, 
           //     game.stageInfo.stages[2].stageCave.caves[0].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[2].stageCave.caves[1].treasureNum, 
           //     game.stageInfo.stages[2].stageCave.caves[1].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[2].stageCave.caves[2].treasureNum, 
           //     game.stageInfo.stages[2].stageCave.caves[2].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[2].stageCave.caves[3].treasureNum, 
           //     game.stageInfo.stages[2].stageCave.caves[3].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[3].stageCave.caves[0].treasureNum, 
           //     game.stageInfo.stages[3].stageCave.caves[0].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[3].stageCave.caves[1].treasureNum, 
           //     game.stageInfo.stages[3].stageCave.caves[1].caveFilename);
           // caveList ~= CaveSwapInfo(game.stageInfo.stages[3].stageCave.caves[2].treasureNum, 
           //     game.stageInfo.stages[3].stageCave.caves[2].caveFilename);


            // Shuffle the struct array
            auto rnd = MinstdRand0(unpredictableSeed);
            caveList.randomShuffle(rnd);
            // GLITCHLESS LOGIC && VANILLA: Ensure forest_2.txt will either be untouched or moved to forest_1.txt
            for (int i = 0; i < caveList.length; i++)
            {
                if (caveList[i].caveFilename == "forest_2.txt" && (i <= 1 || i >= 4))
                {
                    writefln("forest_2.txt is in element %s! swapping...", i);
                    swap(caveList[to!uint(uniform!"[])"(2, 3, rnd))], caveList[i]);
                }
            }

            // Apply this list to stages.txt
            game.stageInfo.stages[0].stageCave.caves[1].caveFilename = caveList[0].caveFilename;
            game.stageInfo.stages[0].stageCave.caves[1].treasureNum =  caveList[0].treasureNum;
            game.stageInfo.stages[0].stageCave.caves[2].caveFilename = caveList[1].caveFilename;
            game.stageInfo.stages[0].stageCave.caves[2].treasureNum =  caveList[1].treasureNum;
            game.stageInfo.stages[1].stageCave.caves[0].caveFilename = caveList[2].caveFilename;
            game.stageInfo.stages[1].stageCave.caves[0].treasureNum =  caveList[2].treasureNum;
            game.stageInfo.stages[1].stageCave.caves[1].caveFilename = caveList[3].caveFilename;
            game.stageInfo.stages[1].stageCave.caves[1].treasureNum =  caveList[3].treasureNum;
            game.stageInfo.stages[1].stageCave.caves[2].caveFilename = caveList[4].caveFilename;
            game.stageInfo.stages[1].stageCave.caves[2].treasureNum =  caveList[4].treasureNum;
            game.stageInfo.stages[1].stageCave.caves[3].caveFilename = caveList[5].caveFilename;
            game.stageInfo.stages[1].stageCave.caves[3].treasureNum =  caveList[5].treasureNum;
            game.stageInfo.stages[2].stageCave.caves[0].caveFilename = caveList[6].caveFilename;
            game.stageInfo.stages[2].stageCave.caves[0].treasureNum =  caveList[6].treasureNum;
            game.stageInfo.stages[2].stageCave.caves[1].caveFilename = caveList[7].caveFilename;
            game.stageInfo.stages[2].stageCave.caves[1].treasureNum =  caveList[7].treasureNum;
            game.stageInfo.stages[2].stageCave.caves[2].caveFilename = caveList[8].caveFilename;
            game.stageInfo.stages[2].stageCave.caves[2].treasureNum =  caveList[8].treasureNum;
            game.stageInfo.stages[2].stageCave.caves[3].caveFilename = caveList[9].caveFilename;
            game.stageInfo.stages[2].stageCave.caves[3].treasureNum =  caveList[9].treasureNum;
            game.stageInfo.stages[3].stageCave.caves[0].caveFilename = caveList[10].caveFilename;
            game.stageInfo.stages[3].stageCave.caves[0].treasureNum =  caveList[10].treasureNum;
            game.stageInfo.stages[3].stageCave.caves[1].caveFilename = caveList[11].caveFilename;
            game.stageInfo.stages[3].stageCave.caves[1].treasureNum =  caveList[11].treasureNum;
            game.stageInfo.stages[3].stageCave.caves[2].caveFilename = caveList[12].caveFilename;
            game.stageInfo.stages[3].stageCave.caves[2].treasureNum =  caveList[12].treasureNum;
            
            // Create a new BGM list and apply said list based on what caves moved around
            P2BGMInfo[] newBGM;
            newBGM = [
                P2BGMInfo(game.caveBgms[0].bgmName, P2CaveBGM(3, 
                    [
                        caveIDtoBGMList(game.stageInfo.stages[0].stageCave.caves[0].caveFilename, game.caveBgms), 
                        caveIDtoBGMList(caveList[0].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[1].caveFilename, game.caveBgms)
                    ])), // Tutorial

                P2BGMInfo(game.caveBgms[1].bgmName, P2CaveBGM(4, 
                    [
                        caveIDtoBGMList(caveList[2].caveFilename, game.caveBgms), 
                        caveIDtoBGMList(caveList[3].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[4].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[5].caveFilename, game.caveBgms),
                    ])), // Forest

                P2BGMInfo(game.caveBgms[2].bgmName, P2CaveBGM(4, 
                    [
                        caveIDtoBGMList(caveList[6].caveFilename, game.caveBgms), 
                        caveIDtoBGMList(caveList[7].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[8].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[9].caveFilename, game.caveBgms),
                    ])), // Yakushima
                
                P2BGMInfo(game.caveBgms[3].bgmName, P2CaveBGM(3, 
                    [
                        caveIDtoBGMList(caveList[10].caveFilename, game.caveBgms), 
                        caveIDtoBGMList(caveList[11].caveFilename, game.caveBgms),
                        caveIDtoBGMList(caveList[12].caveFilename, game.caveBgms),
                    ])), // Last
            ];
            game.caveBgms = newBGM;
            
            writeln("Done!");
            break;
        case 1: // Strip: Strip each cave of their sublevels and then randomize them around
        
            /* MAIN LOGIC RULES:
               1. Emergence Cave sublevel 2 must be in new tutorial_1.txt in Vanilla Gametype
               2. WFG 3 must either be in tutorial_1.txt, forest_1.txt, or forest_2.txt in Vanilla Gametype
            */
            // UNIMPLEMENTED
            break;
        case 2: // Kurumizome Style: Caves are the same length, but have some properties randomized
            /* MAIN LOGIC RULES:
               1. Match sublevel length of original
               2. Final sublevels in caves that contain an explorers kit must have an explorers kit item
               3. Whites must be discovered on WFG 3, Purples must be discovered by EC 2
               4. EC 2 Must have AW Globe
            */
            // UNIMPLEMENTED
            break;
        case 3: // Randomize: Randomly generate entire caves
            /* MAIN LOGIC RULES:
               1. AW Globe must remain in VoR in Vanilla Gametype
               2. Purples must be found in tutorial_1.txt in Vanilla Gametype
            */
            // UNIMPLEMENTED
            break;
    }

    // 2. Randomize the treasure gens
    /*final switch(randoSettings.groundTreasureType)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
    }*/

    // All done, lets try to deserialize!
    writeln("Applying changes...");
    int attempt = deserializeGame(game);
    writeln("Done!");
    return attempt;
}

///Helper Function: returns corresponding cave BGM list when given string id. 
///Ensure this is called *before* applying changes to the game
P2BGMList caveIDtoBGMList(string caveID, P2BGMInfo[] vanillaBGM)
{
    final switch (caveID)
    {
        case "tutorial_1.txt":
            return vanillaBGM[0].bgmInfo.bgmLists[0];
        case "tutorial_2.txt":
            return vanillaBGM[0].bgmInfo.bgmLists[1];
        case "tutorial_3.txt":
            return vanillaBGM[0].bgmInfo.bgmLists[2];
        case "forest_1.txt":
            return vanillaBGM[1].bgmInfo.bgmLists[0];
        case "forest_2.txt":
            return vanillaBGM[1].bgmInfo.bgmLists[1];
        case "forest_3.txt":
            return vanillaBGM[1].bgmInfo.bgmLists[2];
        case "forest_4.txt":
            return vanillaBGM[1].bgmInfo.bgmLists[3];
        case "yakushima_1.txt":
            return vanillaBGM[2].bgmInfo.bgmLists[0];
        case "yakushima_2.txt":
            return vanillaBGM[2].bgmInfo.bgmLists[1];
        case "yakushima_3.txt":
            return vanillaBGM[2].bgmInfo.bgmLists[2];
        case "yakushima_4.txt":
            return vanillaBGM[2].bgmInfo.bgmLists[3];
        case "last_1.txt":
            return vanillaBGM[3].bgmInfo.bgmLists[0];
        case "last_2.txt":
            return vanillaBGM[3].bgmInfo.bgmLists[1];
        case "last_3.txt":
            return vanillaBGM[3].bgmInfo.bgmLists[2];
    }
}