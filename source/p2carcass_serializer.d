module p2carcass_serial;

import std.conv;
import std.stdio;
import std.string;
import std.traits;

struct P2Carcass
{
    uint configSize;
    P2CarcassConfig subcarcass;
}

struct P2CarcassConfig
{
    string name;
    string archive;
    string bmd;
    uint radius;
    uint p_radius;
    uint height;
    uint inertiascaling;
    string particletype;
    uint numparticles;
    float particlesize;
    float friction;
    uint min;
    uint max;
    // uint pikicountmax; UNUSED VALUE MOMENT :O
    // uint pikicountmin;
    string dynamics;
    uint money;
    float offset1;
    float offset2;
    float offset3;
}

P2Carcass serializeCarcass(File carcasstxt)
{
    P2Carcass carcass;

    // Skip past useless data
    carcasstxt.readln(); carcasstxt.readln(); carcasstxt.readln();
    carcass.configSize = to!uint(carcasstxt.readln().split[0]);

    string curLine;
    // Main Carcass Loop
    for (int i = 0; i < carcass.configSize; i++)
    {
        P2CarcassConfig carcasses;
        carcasstxt.readln();
        carcasses.name = carcasstxt.readln().split[1];
        carcasses.archive = carcasstxt.readln().split[1];
        carcasses.bmd = carcasstxt.readln().split[1];
        carcasses.radius = to!uint(carcasstxt.readln().split[1]);
        carcasses.p_radius = to!uint(carcasstxt.readln().split[1]);
        carcasses.height = to!uint(carcasstxt.readln().split[1]);
        carcasses.inertiascaling = to!uint(carcasstxt.readln().split[1]);
        carcasses.particletype = carcasstxt.readln().split[1];
        carcasses.numparticles = to!uint(carcasstxt.readln().split[1]);
        carcasses.particlesize = to!float(carcasstxt.readln().split[1]);
        carcasses.friction = to!float(carcasstxt.readln().split[1]);
        carcasses.min = to!uint(carcasstxt.readln().split[1]);
        carcasses.max = to!uint(carcasstxt.readln().split[1]);
        carcasstxt.readln(); carcasstxt.readln(); // skips unused value reference omg
        carcasses.dynamics = carcasstxt.readln().split[1];
        carcasses.money = to!uint(carcasstxt.readln().split[1]);
        carcasses.offset1 = to!float(carcasstxt.readln().split[1]);
        carcasses.offset2 = to!float(carcasstxt.readln().split[2]);
        carcasses.offset3 = to!float(carcasstxt.readln().split[3]);
        carcasstxt.readln();
        carcass.subcarcass ~= carcasses;
    }
    carcasstxt.close();
    return carcass;
}

int deserializeCarcass(P2Carcass carcass, string filepath)
{
    File carcasstxt = File(filepath, "w");
    a = carcass.subcarcass[i].offset1, " ", carcass.subcarcass[i].offset2, " ", carcass.subcarcass[i].offset3;
    carcasstxt.writeln(carcass.configSize);
    for (int i = 0; i < carcass.subcarcass.length; i++)
    {
        carcasstxt.writefln("{\n\tname\t\t%s", carcass.subcarcass[i].name);
        carcasstxt.writefln("{\n\tarchive\t\t%s", carcass.subcarcass[i].archive);
        carcasstxt.writefln("{\n\tbmd\t\t%s", carcass.subcarcass[i].bmd);
        carcasstxt.writefln("{\n\tradius\t\t%s", carcass.subcarcass[i].radius);
        carcasstxt.writefln("{\n\tp_radius\t\t%s", carcass.subcarcass[i].p_radius);
        carcasstxt.writefln("{\n\theight\t\t%s", carcass.subcarcass[i].height);
        carcasstxt.writefln("{\n\tinertiascaling\t\t%s", carcass.subcarcass[i].inertiascaling);
        carcasstxt.writefln("{\n\tparticletype\t\t%s", carcass.subcarcass[i].particletype);
        carcasstxt.writefln("{\n\tnumparticles\t\t%s", carcass.subcarcass[i].numparticles);
        carcasstxt.writefln("{\n\tparticlesize\t\t%s", carcass.subcarcass[i].particlesize);
        carcasstxt.writefln("{\n\tfriction\t\t%s", carcass.subcarcass[i].friction);
        carcasstxt.writefln("{\n\tmin\t\t%s", carcass.subcarcass[i].min);
        carcasstxt.writefln("{\n\tmax\t\t%s", carcass.subcarcass[i].max);
        carcasstxt.writefln("{\n\tdynamics\t\t%s", carcass.subcarcass[i].dynamics);
        carcasstxt.writefln("{\n\tmoney\t\t%s", carcass.subcarcass[i].money);
        carcasstxt.writefln("{\n\toffset\t\t%s", a);
    }
    carcasstxt.writeln("\tend\n}");

    carcasstxt.close();
    return 1;
}