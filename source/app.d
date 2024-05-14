import p2randomizer;
import raylib;
import raygui;
import std.format;
import std.stdio;

int main()
{
    // GUI or YAML will set up this object on its own
    P2RandoOptions rand = P2RandoOptions(0, 0, 0, 0, 0, 0, "");
    return randomizeGame(rand);
}
