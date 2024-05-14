module p2gen_serial;

import std.conv;
import std.stdio;
import std.string;
import std.traits;

///Contains the root information of a given generator file
struct P2Gen
{
    P2VersionID ver;       // The file version
    Vec3 startPos;         // XYZ starting position of generator
    float startDir;        // Starting angle of generator
    uint numGen;           // Number of objects contained
    P2GenObj[] generators; // Generator Object array
}

enum P2VersionID
{
    VER1 = "{v0.1}",
    VER3 = "{v0.3}",
}

struct Vec3
{
    float x;
    float y;
    float z;
}

struct P2GenObj
{
    P2VersionID ver;         // Generator version
    int reserved;            // Affects loading behavior, 0 = Loads once, (1, ..) = Can load multiple times, 
                             // (.., -1) = Unknown
    uint respawnDays;        // 0 = always spawn, even after leaving cave, (1, ..) = Wait this many days to respawn
    // ubyte[] comment; #NOT NECESSARY FOR OBJECT OPERATION
    Vec3 pos;                // Spawn position of object
    Vec3 offset;             // Position offset from spawn position
    P2ObjectTag entityType;  // INTERNAL: Used at runtime to know what the stored object is
    P2GenObjInfo genData;    // Contains the specific object information
}

union P2GenObjInfo
{
    P2GenOnyon onyonInfo;
    P2GenCave caveInfo;
    P2GenPiki pikiInfo;
    P2GenTeki tekiInfo;
    P2GenPelt peltInfo;   // Treasures, Pellets
    P2GenBrdg bridgeInfo;
    P2GenGate gateInfo;
    P2GenDgat egateInfo;  // Electric Gate
    P2GenRock moldInfo;   // Spiderwort mold
    P2GenBarl clogInfo;
    P2GenPlnt bewyInfo;   // Burgeoning Spiderwort
    P2GenUjms ujmsInfo;   // Ujimushi
    P2GenWeed weedInfo;   // Nectar Grass/Rocks
    P2GenDwfl dwflInfo;   // Weight Blocks, Paper Bags, Downfloors
    P2GenPkhd pkhdInfo;   // Pikmin Sprout (Unused)
    P2GenMitu mituInfo;   // Nectar/Spray (Unused)
    P2GenHole holeInfo;   // Cave Hole Object (Unused)
    P2GenWarp warpInfo;   // Geyser Object (Unused)
}

enum P2EntityType
{
    ITEM = "{item} {0002}",
    PIKI = "{piki} {0001}",
    TEKI = "{teki} {0005}",
    PELT = "{pelt} {0000}",
}

///Internal use only: For knowing what the P2GenObjInfo union is in a struct instance
enum P2ObjectTag
{
    ONYN = "{onyn}",
    PIKI = "{piki}",
    CAVE = "{cave}",
    TEKI = "{teki}",
    PELT = "{pelt}",
    BRDG = "{brdg}",
    GATE = "{gate}",
    DGAT = "{dgat}",
    ROCK = "{rock}",
    BARL = "{barl}",
    PLNT = "{plnt}",
    UJMS = "{ujms}",
    WEED = "{weed}",
    DWFL = "{dwfl}",
    PKHD = "{pkhd}",
    MITU = "{mitu}",
    HOLE = "{hole}",
    WARP = "{warp}",
}

struct P2GenOnyon
{
    Vec3 rotation;
    string locVersion = "{0001}";  // item local version (usually 1)
    ubyte index;                   // 0 = Blue 1 = Red 2 = Yellow 4 = Ship
    ubyte afterBoot;               // 0 = Wild onion 1 = Landing site onion
}

struct P2GenCave
{
    Vec3 rotation;
    string locVersion = "{0002}";
    string caveDef; // Filename of Cave info
    string unitDef; // Filename of Cave Unit info
    string caveID;  // stages.txt ID of Cave
    FogParm fogInfo;// Info about cave fog
}

struct FogParm
{
    float startZ;
    float endZ;
    float startTime;
    float endTime;
    ubyte[3] color;
    float distance;
    float enterDist;
    float exitDist;
}

struct P2GenPiki
{
    ubyte pikiType; // 0 = Blue 1 = Red 2 = Yellow 3 = Purple 4 = White
    ubyte pikiNum;
    ubyte pikiSpawnType; // 1 = Wild, 0 = Recruited(?)
}

struct P2GenTeki
{
    ubyte tekiID;      // Enemy ID
    ubyte birthType;   // 0 = Normal, 1 = Falls from the sky
    ubyte tekiNum;     // Number of this enemy to spawn if spawnType is >= 2
    float dirAngle;    // Facing direction
    ubyte spawnType;   // <1 = Single, >=2 = Multiple
    float radius;      // Deviation radius of teki, 0 = No deviation
    float enemySize;   // Apparently unused
    ushort treasureID; // ID of treasure to drop (x+768 for normal, x+1024 for explorers kit)
    ubyte pelletColor; // Pellet color to drop, 0 = Blue 1 = Red 2 = Yellow 3 = Random
    ubyte pelletSize;  // Pellet size (can only be 1, 5, 10, 20)
    ubyte pelletMin;   // Min num of pellets to drop
    ubyte pelletMax;   // Max num of pellets to drop
    float pelletProb;  // Probability of pellet to drop, 1 = 100%
    string tekiVer;    // {????} for enemies, {0001} for posies, {0000} for honeywisps
    ubyte posyBehavior;// PELLET POSY ONLY: Dictates cycling behavior, identical to pelletColor in values
    ubyte posySize;    // PELLET POSY ONLY: Dictates pellet size, identical to pelletSize in values
    ubyte posyStage;   // PELLET POSY ONLY: Dictates pellet posy growth stage 0 = Sprout 1 = Stem 2 = Bloomed
    float honeyfly;    // HONEYWISP ONLY: Dictates honeywisp flying duration
    float honeyslide;  // HONEYWISP ONLY: Dictates honeywisp sliding duration
}

struct P2GenPelt
{
    ubyte peltType; // 0 = pellet 3 = treasure 4 = explorers kit
    Vec3 rotation;
    string peltVer;
    ubyte treasureID;
}

struct P2GenBrdg
{
    Vec3 rotation;
    string brdgVer;
    ubyte brdgType; // 0 = Short 1 = Sloped 2 = Long
}

struct P2GenGate
{
    Vec3 rotation;
    string gateVer;
    float gateLife;
    ubyte gateColor; // 0 = White 1 = Black
}

struct P2GenDgat
{
    Vec3 rotation;
    string dgatVer;
    float dgatLife;
}

struct P2GenRock
{
    Vec3 rotation;
    //string rockVer; # Usually {0000}
}

struct P2GenBarl
{
    Vec3 rotation;
    //string barlVer; # Usually {0000}
}

struct P2GenPlnt
{
    Vec3 rotation;
    //string plntVer; # Usually {0001}
    ubyte plntType; // 0 = Spicy 1 = Bitter 2 = Mixed
}

struct P2GenUjms
{
    Vec3 rotation;
    //string ujmsVer; # Usually {0000}
    ubyte numUjms; // Number of bugs in group
}

struct P2GenWeed
{
    Vec3 rotation;
    //string plntVer; # Usually {0001}
    ubyte numWeed;  // Number of objects in group
    ubyte weedType; // 0 = Rocks 1 = Grass
}

struct P2GenDwfl
{
    Vec3 rotation;
    //string dwflVer; # Usually {0002}
    ushort dwflWeight;  // Required weight to press
    ubyte dwflType;     // 0 = Small Block 1 = Large Block 2 = Paper Bag
    ubyte dwflBehavior; // 0 = Press permanently 1 = Seesaw
    string dwflID;      // SEESAW ONLY: When two dwfl's have the same id, they are paired
}

struct P2GenPkhd
{
    Vec3 rotation;
    //string pkhdVer; # Usually {0000}
}

struct P2GenMitu
{
    Vec3 rotation;
}

struct P2GenHole
{
    Vec3 rotation;
    //string holeVer; # Usually {0000}
}

struct P2GenWarp
{
    Vec3 rotation;
    //string warpVer; # Usually {0000}
}

///Takes a given gen file and serializes it
P2Gen serializeGen(File gentxt)
{
    P2Gen gen;
    string curLine;
    // Grab root info
    gentxt.readln(); // Skip comment
    gen.ver = cast(P2VersionID) gentxt.readln().split[0];
    curLine = gentxt.readln();
    gen.startPos = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), to!float(curLine.split[2]));
    gen.startDir = to!float(gentxt.readln().split[0]);
    gen.numGen = to!uint(gentxt.readln().split[0]);

    // Main gen object loop
    for (int i = 0; i < gen.numGen; i++)
    {
        P2GenObj genObj;

        // Skip Comment and open bracket
        gentxt.readln();
        gentxt.readln();

        // Grab root info
        curLine = gentxt.readln();
        genObj.ver = cast(P2VersionID) curLine.split[0];
        genObj.reserved = to!int(gentxt.readln().split[0]);
        curLine = gentxt.readln();
        genObj.respawnDays = to!uint(curLine[0..$-9].split[0]);
        gentxt.readln(); // Skip comment line
        curLine = gentxt.readln();
        genObj.pos = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), to!float(curLine.split[2]));
        curLine = gentxt.readln();
        genObj.offset = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), to!float(curLine.split[2]));

        // Grab entity info
        curLine = gentxt.readln();
        if (indexOf(curLine, to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM)) != -1)
        {
            gentxt.readln(); // Skip Bracket
            // Figure out what item this is
            curLine = gentxt.readln().split[0];
            genObj.entityType = cast(P2ObjectTag) curLine;
            if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.ONYN))
            {
                P2GenOnyon onynObj;

                curLine = gentxt.readln();
                onynObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                onynObj.index = to!ubyte(gentxt.readln().split[0]);
                onynObj.afterBoot = to!ubyte(gentxt.readln().split[0]);

                // All done, prepare reader pos and add object
                gentxt.readln();
                genObj.genData.onyonInfo = onynObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.CAVE))
            {
                P2GenCave caveObj;

                curLine = gentxt.readln();
                caveObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                caveObj.caveDef = gentxt.readln().split[0];
                caveObj.unitDef = gentxt.readln().split[0];
                caveObj.caveID = gentxt.readln().split[0];
                gentxt.readln(); gentxt.readln(); // Skip Comment and bracket

                // Grab FogParm info
                caveObj.fogInfo.startZ = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.endZ = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.startTime = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.endTime = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.color = [ to!ubyte(gentxt.readln().split[2]), to!ubyte(gentxt.readln().split[2]), 
                    to!ubyte(gentxt.readln().split[2]) ];
                caveObj.fogInfo.distance = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.enterDist = to!float(gentxt.readln().split[2]);
                caveObj.fogInfo.exitDist = to!float(gentxt.readln().split[2]);

                // All done, prepare reader pos and add object
                gentxt.readln(); gentxt.readln(); gentxt.readln();
                genObj.genData.caveInfo = caveObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.BRDG))
            {
                P2GenBrdg brdgObj;

                curLine = gentxt.readln();
                brdgObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                brdgObj.brdgType = to!ubyte(gentxt.readln()[0..$-10].split[0]);

                gentxt.readln();
                genObj.genData.bridgeInfo = brdgObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.GATE))
            {
                P2GenGate gateObj;

                curLine = gentxt.readln();
                gateObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                gateObj.gateLife = to!float(gentxt.readln()[0..$-8].split[0]);
                gateObj.gateColor = to!ubyte(gentxt.readln().split[0]);

                gentxt.readln();
                genObj.genData.gateInfo = gateObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.DGAT))
            {
                P2GenDgat dgatObj;

                curLine = gentxt.readln();
                dgatObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                curLine = gentxt.readln();
                dgatObj.dgatLife = to!float(curLine[0..indexOf(curLine, "#")+1].split[0]);

                gentxt.readln();
                genObj.genData.egateInfo = dgatObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.ROCK))
            {
                P2GenRock rockObj;

                curLine = gentxt.readln();
                rockObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln(); gentxt.readln();
                genObj.genData.moldInfo = rockObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.BARL))
            {
                P2GenBarl barlObj;

                curLine = gentxt.readln();
                barlObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln(); gentxt.readln();
                genObj.genData.clogInfo = barlObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.PLNT))
            {
                P2GenPlnt plntObj;

                curLine = gentxt.readln();
                plntObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                plntObj.plntType = to!ubyte(gentxt.readln()[0..$-8].split[0]);

                gentxt.readln();
                genObj.genData.bewyInfo = plntObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.UJMS))
            {
                P2GenUjms ujmsObj;

                curLine = gentxt.readln();
                ujmsObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                ujmsObj.numUjms = to!ubyte(gentxt.readln()[0..$-10].split[0]);

                gentxt.readln();
                genObj.genData.ujmsInfo = ujmsObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.WEED))
            {
                P2GenWeed weedObj;

                curLine = gentxt.readln();
                weedObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                weedObj.numWeed = to!ubyte(gentxt.readln()[0..$-10].split[0]);
                weedObj.weedType = to!ubyte(gentxt.readln()[0..$-8].split[0]);

                gentxt.readln();
                genObj.genData.weedInfo = weedObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.DWFL))
            {
                P2GenDwfl dwflObj;

                curLine = gentxt.readln();
                dwflObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));
                gentxt.readln(); // Skip version
                dwflObj.dwflWeight = to!ushort(gentxt.readln()[0..$-10].split[0]);
                dwflObj.dwflType = to!ubyte(gentxt.readln().split[0]);
                dwflObj.dwflBehavior = to!ubyte(gentxt.readln().split[0]);
                dwflObj.dwflID = gentxt.readln().split[0];

                gentxt.readln();
                genObj.genData.dwflInfo = dwflObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.PKHD))
            {
                P2GenPkhd pkhdObj;

                curLine = gentxt.readln();
                pkhdObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln(); gentxt.readln();
                genObj.genData.pkhdInfo = pkhdObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.MITU))
            {
                P2GenMitu mituObj;

                curLine = gentxt.readln();
                mituObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln();
                genObj.genData.mituInfo = mituObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.HOLE))
            {
                P2GenHole holeObj;

                curLine = gentxt.readln();
                holeObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln(); gentxt.readln();
                genObj.genData.holeInfo = holeObj;
            }
            else if (curLine == to!string(cast(OriginalType!P2EntityType) P2ObjectTag.WARP))
            {
                P2GenWarp warpObj;

                curLine = gentxt.readln();
                warpObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                    to!float(curLine.split[2]));

                gentxt.readln(); gentxt.readln();
                genObj.genData.warpInfo = warpObj;
            }

            // All done, prepare read position
            gentxt.readln(); gentxt.readln(); gentxt.readln(); gentxt.readln();
        }
        else if (indexOf(curLine, to!string(cast(OriginalType!P2EntityType) P2EntityType.PIKI)) != -1)
        {
            genObj.entityType = P2ObjectTag.PIKI;

            gentxt.readln(); // Skip bracket
            P2GenPiki pikiObj;
            pikiObj.pikiType = to!ubyte(gentxt.readln()[0..$-4].split[2]);
            pikiObj.pikiNum = to!ubyte(gentxt.readln()[0..$-4].split[2]);
            pikiObj.pikiSpawnType = to!ubyte(gentxt.readln()[0..$-12].split[2]);
            
            // All done, prepare read position and add object
            gentxt.readln(); gentxt.readln();
            genObj.genData.pikiInfo = pikiObj;
        }
        else if (indexOf(curLine, to!string(cast(OriginalType!P2EntityType) P2EntityType.TEKI)) != -1)
        {
            genObj.entityType = P2ObjectTag.TEKI;
            P2GenTeki tekiObj;

            tekiObj.tekiID = to!ubyte(curLine.split[2]); // They put the ID NEXT to the teki tag
            tekiObj.birthType = to!ubyte(gentxt.readln().split[0]);
            tekiObj.tekiNum = to!ubyte(gentxt.readln().split[0]);
            tekiObj.dirAngle = to!float(gentxt.readln().split[0]);
            tekiObj.spawnType = to!ubyte(gentxt.readln().split[0]);
            tekiObj.radius = to!float(gentxt.readln().split[0]);
            tekiObj.enemySize = to!float(gentxt.readln().split[0]);
            tekiObj.treasureID = to!ushort(gentxt.readln()[0..$-20].split[0]);
            tekiObj.pelletColor = to!ubyte(gentxt.readln().split[0]);
            tekiObj.pelletSize = to!ubyte(gentxt.readln().split[0]);
            tekiObj.pelletMin = to!ubyte(gentxt.readln().split[0]);
            tekiObj.pelletMax = to!ubyte(gentxt.readln().split[0]);
            tekiObj.pelletProb = to!float(gentxt.readln().split[0]);
            tekiObj.tekiVer = gentxt.readln().split[0];
            // Handle Pellet Posy info, if there is any
            if (tekiObj.tekiVer == "{0001}")
            {
                tekiObj.posyBehavior = to!ubyte(gentxt.readln().split[0]);
                tekiObj.posySize = to!ubyte(gentxt.readln().split[0]);
                tekiObj.posyStage = to!ubyte(gentxt.readln().split[0]);
            }
            else if (tekiObj.tekiVer == "{0000}")
            {
                tekiObj.honeyfly = to!float(gentxt.readln().split[0]);
                tekiObj.honeyslide = to!float(gentxt.readln().split[0]);
            }

            gentxt.readln(); gentxt.readln(); gentxt.readln(); gentxt.readln();
            genObj.genData.tekiInfo = tekiObj;
        }
        else if (indexOf(curLine, to!string(cast(OriginalType!P2EntityType) P2EntityType.PELT)) != -1)
        {
            genObj.entityType = P2ObjectTag.PELT;
            P2GenPelt peltObj;

            gentxt.readln();
            peltObj.peltType = to!ubyte(gentxt.readln().split[0]);
            curLine = gentxt.readln();
            peltObj.rotation = Vec3(to!float(curLine.split[0]), to!float(curLine.split[1]), 
                to!float(curLine.split[2]));
            gentxt.readln(); // Skip Version
            peltObj.treasureID = to!ubyte(gentxt.readln().split[0]);

            gentxt.readln(); gentxt.readln(); gentxt.readln(); gentxt.readln();
            genObj.genData.peltInfo = peltObj;
        }
        // All done, prepare read position and add object
        gentxt.readln();
        gen.generators ~= genObj;
    }

    gentxt.close();
    return gen;
}

int deserializeGen(P2Gen gen, string filepath)
{
    File gentxt = File(filepath, "w");

    // Deserialize Root info
    gentxt.writeln(to!string(cast(OriginalType!P2VersionID)gen.ver));
    gentxt.writefln("%s %s %s", gen.startPos.x, gen.startPos.y, gen.startPos.z);
    gentxt.writeln(gen.startDir);
    gentxt.writeln(gen.numGen);
    
    // Main Generator Object Loop
    for (int i = 0; i < gen.numGen; i++)
    {
        P2GenObj genObj = gen.generators[i];
        // Deserialize main info
        gentxt.writefln("{\n\t%s\n\t%s\n\t0", to!string(cast(OriginalType!P2VersionID)genObj.ver), genObj.reserved, 
            genObj.respawnDays);
        gentxt.writeln("\t0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"); // Dummy comment
        gentxt.writefln("\t%s %s %s", genObj.pos.x, genObj.pos.y, genObj.pos.z);
        gentxt.writefln("\t%s %s %s", genObj.offset.x, genObj.offset.y, genObj.offset.z);

        // Deserialize Object info
        final switch (genObj.entityType)
        {
            case P2ObjectTag.ONYN:
                P2GenOnyon onynInfo = genObj.genData.onyonInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", onynInfo.rotation.x, onynInfo.rotation.y, onynInfo.rotation.z);
                gentxt.writeln("\t\t{0001}");
                gentxt.writefln("\t\t%s", onynInfo.index);
                gentxt.writefln("\t\t%s\n\t}\n\t{\n\t\t{_eof}\n\t}\n}", onynInfo.afterBoot);
                break;
            case P2ObjectTag.PIKI:
                P2GenPiki pikiInfo = genObj.genData.pikiInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.PIKI));
                gentxt.writefln("\t\t{p000} 4 %s", pikiInfo.pikiType);
                gentxt.writefln("\t\t{p001} 4 %s", pikiInfo.pikiNum);
                gentxt.writefln("\t\t{p002} 4 %s", pikiInfo.pikiSpawnType);
                gentxt.writefln("\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.CAVE:
                P2GenCave caveInfo = genObj.genData.caveInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", caveInfo.rotation.x, caveInfo.rotation.y, caveInfo.rotation.z);
                gentxt.writeln("\t\t{0002}");
                gentxt.writefln("\t\t%s", caveInfo.caveDef);
                gentxt.writefln("\t\t%s", caveInfo.unitDef);
                gentxt.writefln("\t\t%s", caveInfo.caveID);
                gentxt.writefln("\t\t{\n\t\t\t{fg00} 4 %s", caveInfo.fogInfo.startZ);
                gentxt.writefln("\t\t\t{fg01} 4 %s", caveInfo.fogInfo.endZ);
                gentxt.writefln("\t\t\t{fg02} 4 %s", caveInfo.fogInfo.startTime);
                gentxt.writefln("\t\t\t{fg03} 4 %s", caveInfo.fogInfo.endTime);
                gentxt.writefln("\t\t\t{fg04} 1 %s", caveInfo.fogInfo.color[0]);
                gentxt.writefln("\t\t\t{fg05} 1 %s", caveInfo.fogInfo.color[1]);
                gentxt.writefln("\t\t\t{fg06} 1 %s", caveInfo.fogInfo.color[2]);
                gentxt.writefln("\t\t\t{fg07} 4 %s", caveInfo.fogInfo.distance);
                gentxt.writefln("\t\t\t{fg08} 4 %s", caveInfo.fogInfo.enterDist);
                gentxt.writefln("\t\t\t{fg09} 4 %s", caveInfo.fogInfo.exitDist);
                gentxt.writefln("\t\t\t{_eof}\n\t\t}\n\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.TEKI:
                P2GenTeki tekiInfo = genObj.genData.tekiInfo;
                gentxt.writefln("\t%s %s", to!string(cast(OriginalType!P2EntityType) P2EntityType.TEKI),
                     tekiInfo.tekiID);
                gentxt.writefln("\t%s", tekiInfo.birthType);
                gentxt.writefln("\t%s", tekiInfo.tekiNum);
                gentxt.writefln("\t%s", tekiInfo.dirAngle);
                gentxt.writefln("\t%s", tekiInfo.spawnType);
                gentxt.writefln("\t%s", tekiInfo.radius);
                gentxt.writefln("\t%s", tekiInfo.enemySize);
                gentxt.writefln("\t%s", tekiInfo.treasureID);
                gentxt.writefln("\t%s", tekiInfo.pelletColor);
                gentxt.writefln("\t%s", tekiInfo.pelletSize);
                gentxt.writefln("\t%s", tekiInfo.pelletMin);
                gentxt.writefln("\t%s", tekiInfo.pelletMax);
                gentxt.writefln("\t%s", tekiInfo.pelletProb);
                gentxt.writefln("\t%s", tekiInfo.tekiVer);
                // Deserialze Pelley Posy info if necessary
                if (tekiInfo.tekiVer == "{0001}")
                {
                    gentxt.writefln("\t%s", tekiInfo.posyBehavior);
                    gentxt.writefln("\t%s", tekiInfo.posySize);
                    gentxt.writefln("\t%s", tekiInfo.posyStage);
                }
                else if (tekiInfo.tekiVer == "{0000}")
                {
                    gentxt.writefln("\t%s", tekiInfo.honeyfly);
                    gentxt.writeln(tekiInfo.honeyslide);
                }
                gentxt.writeln("\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.PELT:
                P2GenPelt peltInfo = genObj.genData.peltInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.PELT));
                gentxt.writefln("\t\t%s", peltInfo.peltType);
                gentxt.writefln("\t\t%s %s %s", peltInfo.rotation.x, peltInfo.rotation.y, peltInfo.rotation.z);
                gentxt.writefln("{0000}\n%s }\n\t{\n\t\t{_eof}\n\t}\n}", peltInfo.treasureID);
                break;
            case P2ObjectTag.BRDG:
                P2GenBrdg brdgInfo = genObj.genData.bridgeInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", brdgInfo.rotation.x, brdgInfo.rotation.y, brdgInfo.rotation.z);
                gentxt.writefln("\t\t{0001}\n\t\t%s", brdgInfo.brdgType);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.GATE:
                P2GenGate gateInfo = genObj.genData.gateInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", gateInfo.rotation.x, gateInfo.rotation.y, gateInfo.rotation.z);
                gentxt.writefln("\t\t{0002}\n\t\t%s\n\t\t%s", gateInfo.gateLife, gateInfo.gateColor);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.DGAT:
                P2GenDgat dgatInfo = genObj.genData.egateInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", dgatInfo.rotation.x, dgatInfo.rotation.y, dgatInfo.rotation.z);
                gentxt.writefln("\t\t{0000}\n\t\t%s", dgatInfo.dgatLife);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.ROCK:
                P2GenRock rockInfo = genObj.genData.moldInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", rockInfo.rotation.x, rockInfo.rotation.y, rockInfo.rotation.z);
                gentxt.writeln("\t\t{0000}");
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.BARL:
                P2GenBarl barlInfo = genObj.genData.clogInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", barlInfo.rotation.x, barlInfo.rotation.y, barlInfo.rotation.z);
                gentxt.writeln("\t\t{0000}");
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.PLNT:
                P2GenPlnt plntInfo = genObj.genData.bewyInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", plntInfo.rotation.x, plntInfo.rotation.y, plntInfo.rotation.z);
                gentxt.writefln("\t\t{0001}\n\t\t%s", plntInfo.plntType);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.UJMS:
                P2GenUjms ujmsInfo = genObj.genData.ujmsInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", ujmsInfo.rotation.x, ujmsInfo.rotation.y, ujmsInfo.rotation.z);
                gentxt.writefln("\t\t{0001}\n\t\t%s", ujmsInfo.numUjms);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.WEED:
                P2GenWeed weedInfo = genObj.genData.weedInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", weedInfo.rotation.x, weedInfo.rotation.y, weedInfo.rotation.z);
                gentxt.writefln("\t\t{0001}\n\t\t%s\n\t\t%s", weedInfo.numWeed, weedInfo.weedType);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.DWFL:
                P2GenDwfl dwflInfo = genObj.genData.dwflInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", dwflInfo.rotation.x, dwflInfo.rotation.y, dwflInfo.rotation.z);
                gentxt.writefln("\t\t{0002}\n\t\t%s\n\t\t%s\n\t\t%s\n\t\t%s", dwflInfo.dwflWeight, dwflInfo.dwflType, 
                    dwflInfo.dwflBehavior, dwflInfo.dwflID);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.PKHD:
                P2GenPkhd pkhdInfo = genObj.genData.pkhdInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", pkhdInfo.rotation.x, pkhdInfo.rotation.y, pkhdInfo.rotation.z);
                gentxt.writefln("\t\t{0000}\n\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.MITU:
                P2GenMitu mituInfo = genObj.genData.mituInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", mituInfo.rotation.x, mituInfo.rotation.y, mituInfo.rotation.z);
                gentxt.writefln("\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.HOLE:
                P2GenHole holeInfo = genObj.genData.holeInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", holeInfo.rotation.x, holeInfo.rotation.y, holeInfo.rotation.z);
                gentxt.writefln("\t\t{0000}\n\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
            case P2ObjectTag.WARP:
                P2GenWarp warpInfo = genObj.genData.warpInfo;
                gentxt.writefln("\t%s\n\t{", to!string(cast(OriginalType!P2EntityType) P2EntityType.ITEM));
                gentxt.writefln("\t\t%s", to!string(cast(OriginalType!P2ObjectTag) genObj.entityType));
                gentxt.writefln("\t\t%s %s %s", warpInfo.rotation.x, warpInfo.rotation.y, warpInfo.rotation.z);
                gentxt.writefln("\t\t{0000}\n\t}\n\t{\n\t\t{_eof}\n\t}\n}");
                break;
        }
    }

    gentxt.close();
    return 1;
}


/* STAGES.TXT HANDLER (idk where else is appropriate to put this stuff) */

///Contains information from stages.txt
struct P2GameStage
{
    uint numStages;
    P2Stage[] stages;
}

///Contains information for a given stage instance
struct P2Stage
{
    string name;
    string folder;
    string abe_folder;
    string model;
    string collision;
    string waterbox;
    string mapcode;
    string route;
    Vec3 start;
    float startangle;
    P2StageGen stageGenNonloop;
    P2StageGen stageGenloop;
    P2StageCave stageCave;
    ushort groundTreasure;
}

struct P2StageGen
{
    uint genNum;
    P2StageGenInfo[] gens;
}

struct P2StageGenInfo
{
    string filename;
    uint dayStart;
    uint dayEnd; // This is duplicated in the file
}

struct P2StageCave
{
    uint caveNum;
    P2StageCaveInfo[] caves;
}

struct P2StageCaveInfo
{
    string caveID;
    uint treasureNum;
    string caveFilename;
}

P2GameStage serializeStage(File stagetxt)
{
    P2GameStage stageInfo;

    // Skip padding
    stagetxt.readln(); stagetxt.readln(); stagetxt.readln(); stagetxt.readln();
    stageInfo.numStages = to!uint(stagetxt.readln().split[0]);

    string curLine;
    // Main loop
    for (int i = 0; i < stageInfo.numStages; i++)
    {
        P2Stage stage;

        // Skip to entry
        do
        {
            curLine = stagetxt.readln();
        } while(indexOf(curLine, "{") == -1);
        stage.name = stagetxt.readln().split[1];
        stage.folder = stagetxt.readln().split[1];
        stage.abe_folder = stagetxt.readln().split[1];
        stage.model = stagetxt.readln().split[1];
        stage.collision = stagetxt.readln().split[1];
        stage.waterbox = stagetxt.readln().split[1];
        stage.mapcode = stagetxt.readln().split[1];
        stage.route = stagetxt.readln().split[1];
        curLine = stagetxt.readln();
        stage.start = Vec3(to!float(curLine.split[1]), to!float(curLine.split[2]), to!float(curLine.split[3]));
        stage.startangle = to!float(stagetxt.readln().split[1]);
        // Skip To next data
        stagetxt.readln(); stagetxt.readln(); stagetxt.readln(); stagetxt.readln();
        // NONLOOP GEN
        stage.stageGenNonloop.genNum = to!uint(strip(stagetxt.readln()));
        for (int j = 0; j < stage.stageGenNonloop.genNum; j++)
        {
            curLine = stagetxt.readln();
            stage.stageGenNonloop.gens ~= P2StageGenInfo(curLine.split[0], to!uint(curLine.split[1]), 
                to!uint(curLine.split[2]));
        }
        // Skip To next data
        stagetxt.readln(); stagetxt.readln(); stagetxt.readln();
        // LOOP GEN
        stage.stageGenloop.genNum = to!uint(strip(stagetxt.readln()));
        for (int j = 0; j < stage.stageGenloop.genNum; j++)
        {
            curLine = stagetxt.readln();
            stage.stageGenloop.gens ~= P2StageGenInfo(curLine.split[0], to!uint(curLine.split[1]), 
                to!uint(curLine.split[2]));
        }
        // Skip To next data
        stagetxt.readln(); stagetxt.readln(); stagetxt.readln();
        // CAVE INFO
        stage.stageCave.caveNum = to!uint(strip(stagetxt.readln()));
        for (int j = 0; j < stage.stageCave.caveNum; j++)
        {
            curLine = stagetxt.readln();
            stage.stageCave.caves ~= P2StageCaveInfo(curLine.split[0], to!uint(curLine.split[1]), curLine.split[2]);
        }
        // Skip To next data
        stagetxt.readln(); stagetxt.readln(); stagetxt.readln();
        // GROUND TREASURES
        stage.groundTreasure = to!ushort(strip(stagetxt.readln()));


        stageInfo.stages ~= stage;
    }

    stagetxt.close();
    return stageInfo;
}

int deserializeStage(P2GameStage stage, string filepath)
{
    File stagetxt = File(filepath, "w");

    stagetxt.writeln(stage.numStages);

    for (int i = 0; i < stage.numStages; i++)
    {
        P2Stage stageInfo = stage.stages[i];
        stagetxt.writefln("{\n\tname\t%s", stageInfo.name);
        stagetxt.writefln("\tfolder\t%s", stageInfo.folder);
        stagetxt.writefln("\tabe_folder\t%s", stageInfo.abe_folder);
        stagetxt.writefln("\tmodel\t%s", stageInfo.model);
        stagetxt.writefln("\tcollision\t%s", stageInfo.collision);
        stagetxt.writefln("\twaterbox\t%s", stageInfo.waterbox);
        stagetxt.writefln("\tmapcode\t%s", stageInfo.mapcode);
        stagetxt.writefln("\troute\t%s", stageInfo.route);
        stagetxt.writefln("\tstart\t%s %s %s", stageInfo.start.x, stageInfo.start.y, stageInfo.start.z);
        stagetxt.writefln("\tstartangle\t%s\n\tend", stageInfo.startangle);
        // NONLOOP GEN
        stagetxt.writefln("\t%s", stageInfo.stageGenNonloop.genNum);
        for (int j = 0; j < stageInfo.stageGenNonloop.genNum; j++)
        {
            stagetxt.writefln("\t\t%s \t%s\t%s\t%s", stageInfo.stageGenNonloop.gens[j].filename, 
                stageInfo.stageGenNonloop.gens[j].dayStart, stageInfo.stageGenNonloop.gens[j].dayEnd, 
                stageInfo.stageGenNonloop.gens[j].dayEnd);
        }
        // LOOP GEN
        stagetxt.writefln("\t%s", stageInfo.stageGenloop.genNum);
        for (int j = 0; j < stageInfo.stageGenloop.genNum; j++)
        {
            stagetxt.writefln("\t\t%s \t%s\t%s\t%s", stageInfo.stageGenloop.gens[j].filename, 
                stageInfo.stageGenloop.gens[j].dayStart, stageInfo.stageGenloop.gens[j].dayEnd, 
                stageInfo.stageGenloop.gens[j].dayEnd);
        }
        // CAVE INFO
        stagetxt.writefln("\t%s", stageInfo.stageCave.caveNum);
        for (int j = 0; j < stageInfo.stageCave.caveNum; j++)
        {
            stagetxt.writefln("\t\t%s\t\t%s\t\t%s", stageInfo.stageCave.caves[j].caveID, 
                stageInfo.stageCave.caves[j].treasureNum, stageInfo.stageCave.caves[j].caveFilename);
        }
        // GROUND TREASURES
        stagetxt.writefln("\t%s\n}", stageInfo.groundTreasure);
    }

    stagetxt.close();
    return 1;
}