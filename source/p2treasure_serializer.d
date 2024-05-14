module p2treasure_serial;

import std.conv;
import std.stdio;
import std.string;
import std.traits;

///Contains the root information for the treasure config file
struct P2Treasure
{
    uint treasureNum;
    TreasureInfo[] treasures;
}

///Contains information for a given treasure instance
struct TreasureInfo
{
    string name;
    string archive;
    string bmd;
    string animmgr;
    string colltree;
    ushort radius;
    ushort p_radius;
    ushort height;
    ushort inertiascaling;
    string particletype;
    ushort numparticles;
    ushort particlesize;
    float friction;
    ushort min;
    ushort max;
    //ushort pikicountmax; # These are unused, free memory!!!!
    //ushort pikicountmin;
    string dynamics;
    uint money;
    string unique;
    ubyte code;
    ushort dictionary;
    ushort depth;
    ushort depth_max;
    ushort depth_a;
    ushort depth_b;
    ushort depth_c;
    ushort depth_d;
    string message = ""; // Only found in Explorer's kit items
}

///Returns a P2Treasure object when given a File handle to otakara_config.txt or item_config.txt
P2Treasure serializeTreasure(File treasuretxt)
{
    P2Treasure treasure;

    // Skip file header
    treasuretxt.readln(); treasuretxt.readln(); treasuretxt.readln();
    treasure.treasureNum = to!uint(treasuretxt.readln().split[0]);

    string curLine;
    // Main treasure loop
    for (int i = 0; i < treasure.treasureNum; i++)
    {
        TreasureInfo otakara;
        treasuretxt.readln(); // Skip bracket
        otakara.name = treasuretxt.readln().split[1];
        otakara.archive = treasuretxt.readln().split[1];
        otakara.bmd = treasuretxt.readln().split[1];
        otakara.animmgr = treasuretxt.readln().split[1];
        otakara.colltree = treasuretxt.readln().split[1];
        otakara.radius = to!ushort(treasuretxt.readln().split[1]);
        otakara.p_radius = to!ushort(treasuretxt.readln().split[1]);
        otakara.height = to!ushort(treasuretxt.readln().split[1]);
        otakara.inertiascaling = to!ushort(treasuretxt.readln().split[1]);
        otakara.particletype = treasuretxt.readln().split[1];
        otakara.numparticles = to!ushort(treasuretxt.readln().split[1]);
        otakara.particlesize = to!ushort(treasuretxt.readln().split[1]);
        otakara.friction = to!float(treasuretxt.readln().split[1]);
        otakara.min = to!ushort(treasuretxt.readln().split[1]);
        otakara.max = to!ushort(treasuretxt.readln().split[1]);
        treasuretxt.readln(); treasuretxt.readln(); // Skip unused values
        otakara.dynamics = treasuretxt.readln().split[1];
        otakara.money = to!uint(treasuretxt.readln().split[1]);
        otakara.unique = treasuretxt.readln().split[1];
        // Depending on what value is next, we either have an explorers kit item or a treasure
        curLine = treasuretxt.readln();
        if (indexOf(curLine, "code") != -1)
        {
            // Treasure
            otakara.code = to!ubyte(curLine.split[1]);
            otakara.dictionary = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_max = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_a = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_b = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_c = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_d = to!ushort(treasuretxt.readln().split[1]);

        }
        else
        {
            // Explorers Kit
            otakara.depth = to!ushort(curLine.split[1]);
            otakara.depth_max = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_a = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_b = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_c = to!ushort(treasuretxt.readln().split[1]);
            otakara.depth_d = to!ushort(treasuretxt.readln().split[1]);
            otakara.message = treasuretxt.readln().split[1];
            otakara.code = to!ubyte(curLine.split[1]);
            otakara.dictionary = to!ushort(treasuretxt.readln().split[1]);
        }
        treasuretxt.readln(); treasuretxt.readln(); // Prepare reader
        treasure.treasures ~= otakara;
    }

    treasuretxt.close();
    return treasure;
}

int deserializeTreasure(P2Treasure treasure, string filepath)
{
    File treasuretxt = File(filepath, "w");

    treasuretxt.writeln(treasure.treasureNum);
    for (int i = 0; i < treasure.treasures.length; i++)
    {
        treasuretxt.writefln("{\n\tname\t\t%s", treasure.treasures[i].name);
        treasuretxt.writefln("\tarchive\t\t%s", treasure.treasures[i].archive);
        treasuretxt.writefln("\tbmd\t\t%s", treasure.treasures[i].bmd);
        treasuretxt.writefln("\tanimmgr\t\t%s", treasure.treasures[i].animmgr);
        treasuretxt.writefln("\tcolltree\t\t%s", treasure.treasures[i].colltree);
        treasuretxt.writefln("\tradius\t\t%s", treasure.treasures[i].radius);
        treasuretxt.writefln("\tp_radius\t\t%s", treasure.treasures[i].p_radius);
        treasuretxt.writefln("\theight\t\t%s", treasure.treasures[i].height);
        treasuretxt.writefln("\tinertiascaling\t\t%s", treasure.treasures[i].inertiascaling);
        treasuretxt.writefln("\tparticletype\t\t%s", treasure.treasures[i].particletype);
        treasuretxt.writefln("\tnumparticles\t\t%s", treasure.treasures[i].numparticles);
        treasuretxt.writefln("\tparticlesize\t\t%s", treasure.treasures[i].particlesize);
        treasuretxt.writefln("\tfriction\t\t%s", treasure.treasures[i].friction);
        treasuretxt.writefln("\tmin\t\t%s", treasure.treasures[i].min);
        treasuretxt.writefln("\tmax\t\t%s", treasure.treasures[i].max);
        treasuretxt.writefln("\tdynamics\t\t%s", treasure.treasures[i].dynamics);
        treasuretxt.writefln("\tmoney\t\t%s", treasure.treasures[i].money);
        treasuretxt.writefln("\tunique\t\t%s", treasure.treasures[i].unique);
        if (treasure.treasures[i].message == "")
        {
            // Treasure
            treasuretxt.writefln("\tcode\t\t%s", treasure.treasures[i].code);
            treasuretxt.writefln("\tdictionary\t\t%s", treasure.treasures[i].dictionary);
            treasuretxt.writefln("\tdepth\t\t%s", treasure.treasures[i].depth);
            treasuretxt.writefln("\tdepth_max\t\t%s", treasure.treasures[i].depth_max);
            treasuretxt.writefln("\tdepth_a\t\t%s", treasure.treasures[i].depth_a);
            treasuretxt.writefln("\tdepth_b\t\t%s", treasure.treasures[i].depth_b);
            treasuretxt.writefln("\tdepth_c\t\t%s", treasure.treasures[i].depth_c);
            treasuretxt.writefln("\tdepth_d\t\t%s", treasure.treasures[i].depth_d);
        }
        else
        {
            // Explorers Kit
            treasuretxt.writefln("\tdepth\t\t%s", treasure.treasures[i].depth);
            treasuretxt.writefln("\tdepth_max\t\t%s", treasure.treasures[i].depth_max);
            treasuretxt.writefln("\tdepth_a\t\t%s", treasure.treasures[i].depth_a);
            treasuretxt.writefln("\tdepth_b\t\t%s", treasure.treasures[i].depth_b);
            treasuretxt.writefln("\tdepth_c\t\t%s", treasure.treasures[i].depth_c);
            treasuretxt.writefln("\tdepth_d\t\t%s", treasure.treasures[i].depth_d);
            treasuretxt.writefln("\tmessage\t\t%s", treasure.treasures[i].message);
            treasuretxt.writefln("\tcode\t\t%s", treasure.treasures[i].code);
            treasuretxt.writefln("\tdictionary\t\t%s", treasure.treasures[i].dictionary);
        }
        treasuretxt.writeln("\tend\n}");
    }

    treasuretxt.close();
    return 1;
}