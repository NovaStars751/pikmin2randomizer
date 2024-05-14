module p2cave_serial;

import std.conv;
import std.stdio;
import std.string;
import std.traits;

///Contains the root information of a given Pikmin 2 cave
struct P2Cave
{
	uint floorAmount; //Number of Floors
	P2Sublevel[] sublevel; //Sublevel info array
}

///Contains the root information of a given Pikmin 2 Sublevel
struct P2Sublevel
{
	uint floorID;         // Used for the floor start and floor end parameters of a cave, usually floor number - 1
	uint maxObjectNum;    // Ideal maximum number of objects in the main category that will spawn
	uint maxTreasureNum;  // Ideal maximum number of treasures that will spawn
	uint maxGateNum;      // Ideal maximum number of gates that will spawn
	uint roomNum;		  // Number of rooms in the sublevel
	float corridorProb;   // Probability of corridors relative to rooms
	ubyte hasGeyser;      // 0 = No Geyser, 1 = Has Geyser
	string unitDef;       // Lists the cave unit definition file used
	string lightDef;      // Lists the lighting definition file used
	string skybox;        // Lists the skybox used
	ubyte clog;           // 0 = No Clogged Hole, 1 = Has Clogged Hole
	ubyte echoStrength;   // Lists the echo strength of the cave (0-5)
	ubyte musicType;      // 0 = Normal Music, 1 = Mute till Boss, 2 = Rest Music
	ubyte solidPlane;     // 0 = No invisible plane, 1 = Has invisible plane
	ubyte deadendProb;    // Deadend Probability (0-100)
	ubyte formatVer;      // 1 = Normal, 0 = Ignore CapInfo section
	float wraithTimer;    // Time until an available Waterwraith would spawn
	ubyte seesawFlag;     // 0 = No Seesaw, (1-255) = Has Seesaw
	P2SubTeki tekiInfo;   // Enemy Information
	P2SubItem itemInfo;   // Treasure Information
	P2SubGate gateInfo;   // Gate Information
	P2SubCap capInfo;     // Cap Information
}

///Contains TekiInfo information of a given Sublevel
struct P2SubTeki
{
	uint tekiNum;        // Number of enemies
	P2TekiInfo[] tekiData; // Teki Information
}

///Contains enemy information of a given Sublevel TekiInfo section
struct P2TekiInfo
{
	P2FallTypes fallMethod; // The spawning method of the teki
	string tekiName;        // Internal identifier of teki
	string treasureName;    // Internal identifier of treasure teki carries
	ubyte weight;           // Random Filling Weight of teki
	ubyte spawnType;        // Determines spot type where teki spawns
							// 0 = "Easy", 1 = "Hard", 5 = Hazard, 6 = Plants, 8 = "Special"
}

///Contains ItemInfo information of a given Sublevel
struct P2SubItem
{
	uint treasureNum;        // Number of treasures
	P2ItemInfo[] itemData; // Item Information
}

///Contains treasure information of a given Sublevel ItemInfo section
struct P2ItemInfo
{
	string treasureName; // Internal identifier of treasure
	ubyte weight;        // Random Filling Weight, Usually just 10
}

///Contains GateInfo information of a given Sublevel
struct P2SubGate
{
	uint gateNum;        // Number of gates
	P2GateInfo[] gateData; // Gate Information
}

///Contains gate information of a given Sublevel GateInfo section
struct P2GateInfo
{
	string gateName; // Usually just "gate"
	float gateHP;    // The HP of the gate
	ubyte weight;    // Random filling weight
					 // May only read last digit, so 1 = spawns, 0 = doesnt spawn
}

///Contains CapInfo information of a given Sublevel
struct P2SubCap
{
	uint capNum;       // Number of Cap items
	P2CapInfo[] capData; // Cap Information
}

///Contains cap object information of a given Sublevel CapInfo section
struct P2CapInfo
{
	uint capType; // Deadend type to spawn in, usually 0
	/* Usually, CapInfo objects are just Tekis */
	P2FallTypes fallMethod; // The spawning method of the teki
	string tekiName;        // Internal identifier of teki
	string treasureName;    // Internal identifier of treasure teki carries
	ubyte weight;           // Random Filling Weight of Teki
	ubyte spawnType;        // Determines extra spawning rules
							// 0 = Spawn two copies of object, 1 = Normal Spawning
}

enum P2FallTypes
{
	FT_NONE = "",
	PIKMIN_CAPTAIN = "$",
	//FUNGUS_AMONGUS_UNUSED = "$0",
	PIKMIN_CAPTAIN_SUSSY = "$1",
	PIKMIN = "$2",
	CAPTAIN = "$3",
	PIKMIN_CARRY = "$4",
	PURPLE_STOMP = "$5",
}

///Contains information for a cave bgmlist instance
struct P2CaveBGM
{
	ubyte caveNum; // Number of caves to handle
	P2BGMList[] bgmLists;
}

///Contains BGM List info for a given cave
struct P2BGMList
{
	uint sublevelNum;
	string[] songs;
}

///Serialize a Pikmin 2 Cave text file, returning a structured object
P2Cave serializeCave(File caveTxt)
{
	P2Cave cave;
	// Setup flooramount
	string curLine; // Will be used to hold text file data
	// Find cave info
	do
	{
		curLine = caveTxt.readln();
	} while(indexOf(curLine, "{c000}") == -1);
	// We found flooramount line! Process it
	cave.floorAmount = to!uint(curLine[0..$-5].split[2]);
	caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to important data
	
	// Main Sublevel Loop
	for (uint i = 0; i < cave.floorAmount; i++)
	{
		P2Sublevel sublevel;
		// Sublevel Information
		do
		{
			curLine = caveTxt.readln();
			
			if (indexOf(curLine, "{f000}") != -1)
			{
				sublevel.floorID = to!uint(curLine[0..$-12].split[2]);
			}
			else if (indexOf(curLine, "{f002}") != -1)
			{
				sublevel.maxObjectNum = to!uint(curLine[0..$-12].split[2]);
			}
			else if (indexOf(curLine, "{f003}") != -1)
			{
				sublevel.maxTreasureNum = to!uint(curLine[0..$-18].split[2]);
			}
			else if (indexOf(curLine, "{f004}") != -1)
			{
				sublevel.maxGateNum = to!uint(curLine[0..$-16].split[2]);
			}
			else if (indexOf(curLine, "{f005}") != -1)
			{
				sublevel.roomNum = to!uint(curLine[0..$-12].split[2]);
			}
			else if (indexOf(curLine, "{f006}") != -1)
			{
				sublevel.corridorProb = to!float(curLine[0..$-16].split[2]);
			}
			else if (indexOf(curLine, "{f007}") != -1)
			{
				sublevel.hasGeyser = to!ubyte(curLine[0..$-20].split[2]);
			}
			else if (indexOf(curLine, "{f008}") != -1)
			{
				sublevel.unitDef = curLine[0..$-16].split[2];
			}
			else if (indexOf(curLine, "{f009}") != -1)
			{
				sublevel.lightDef = curLine[0..$-14].split[2];
			}
			else if (indexOf(curLine, "{f00A}") != -1)
			{
				sublevel.skybox = curLine.split[2];
			}
			else if (indexOf(curLine, "{f010}") != -1)
			{
				sublevel.clog = to!ubyte(curLine[0..$-36].split[2]);
			}
			else if (indexOf(curLine, "{f011}") != -1)
			{
				sublevel.echoStrength = to!ubyte(curLine[0..$-8].split[2]);
			}
			else if (indexOf(curLine, "{f012}") != -1)
			{
				sublevel.musicType = to!ubyte(curLine[0..$-8].split[2]);
			}
			else if (indexOf(curLine, "{f013}") != -1)
			{
				sublevel.solidPlane = to!ubyte(curLine[0..$-8].split[2]);
			}
			else if (indexOf(curLine, "{f014}") != -1)
			{
				sublevel.deadendProb = to!ubyte(curLine[0..$-16].split[2]);
			}
			else if (indexOf(curLine, "{f015}") != -1)
			{
				sublevel.formatVer = to!ubyte(curLine.split[2]);
			}
			else if (indexOf(curLine, "{f016}") != -1)
			{
				sublevel.wraithTimer = to!float(curLine.split[2]);
			}
		} while(indexOf(curLine, "{_eof}") == -1);
		caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to next section

		// Handle Teki Info
		sublevel.tekiInfo.tekiNum = to!uint(caveTxt.readln().split[0]);
		for (uint j = 0; j < sublevel.tekiInfo.tekiNum; j++)
		{
			P2TekiInfo tekiData;
			// Read teki name
			curLine = caveTxt.readln();
			string tekiName = curLine.split[0];
			string tekiWeight = curLine.split[1];

			// Check for falling type
			if (indexOf(tekiName, "$") != -1)
			{
				if (indexOf(tekiName, "$1") != -1)
				{
					tekiData.fallMethod = P2FallTypes.PIKMIN_CAPTAIN_SUSSY;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$2") != -1)
				{
					tekiData.fallMethod = P2FallTypes.PIKMIN;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$3") != -1)
				{
					tekiData.fallMethod = P2FallTypes.CAPTAIN;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$4") != -1)
				{
					tekiData.fallMethod = P2FallTypes.PIKMIN_CARRY;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$5") != -1)
				{
					tekiData.fallMethod = P2FallTypes.PURPLE_STOMP;
					tekiName = tekiName[2..$];
				}
				else
				{
					tekiData.fallMethod = P2FallTypes.PIKMIN_CAPTAIN;
					tekiName = tekiName[1..$];
				}
			}
			else
			{
				tekiData.fallMethod = P2FallTypes.FT_NONE;
			}

			// Parse enemy name and treasure(Ignore certain plants when checking for treasure)
			if (indexOf(tekiName, "_") != -1 && indexOf(tekiName, "KareOoinu") == -1 
				&& indexOf(tekiName, "Ooinu") == -1 && indexOf(tekiName, "Wakame") == -1)
			{
				long separator = indexOf(tekiName, "_");
				tekiData.tekiName = tekiName[0..separator];
				tekiData.treasureName = tekiName[separator+1..$];
			}
			else
			{
				tekiData.tekiName = tekiName;
			}
			tekiData.weight = to!ubyte(tekiWeight);
			// Read teki spawn type
			tekiData.spawnType = to!ubyte(caveTxt.readln().split[0]);
			sublevel.tekiInfo.tekiData ~= tekiData;
		}
		caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to next section

		// Handle Item Info
		sublevel.itemInfo.treasureNum = to!uint(caveTxt.readln().split[0]);
		for (uint j = 0; j < sublevel.itemInfo.treasureNum; j++)
		{
			P2ItemInfo itemData;
			curLine = caveTxt.readln();
			itemData.treasureName = curLine.split[0];
			itemData.weight = to!ubyte(curLine.split[1]);
			sublevel.itemInfo.itemData ~= itemData;
		}
		caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to next section

		// Handle Gate Info
		sublevel.gateInfo.gateNum = to!uint(caveTxt.readln().split[0]);
		for (uint j = 0; j < sublevel.gateInfo.gateNum ; j++)
		{
			P2GateInfo gateData;
			curLine = caveTxt.readln();
			gateData.gateName = curLine.split[0];
			gateData.gateHP = to!float(curLine.split[1]);
			gateData.weight = to!ubyte(caveTxt.readln().split[0]);
			sublevel.gateInfo.gateData ~= gateData;
		}
		caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to next section

		// Handle Cap Info
		sublevel.capInfo.capNum = to!uint(caveTxt.readln().split[0]);
		for (uint j = 0; j < sublevel.capInfo.capNum ; j++)
		{
			P2CapInfo capData;
			// Grab CapType
			capData.capType = to!ubyte(caveTxt.readln().split[0]);

			// Grab Object line
			curLine = caveTxt.readln();
			string tekiName = curLine.split[0];
			string tekiWeight = curLine.split[1];

			// Check for falling type
			if (indexOf(tekiName, "$") != -1)
			{
				if (indexOf(tekiName, "$1") != -1)
				{
					capData.fallMethod = P2FallTypes.PIKMIN_CAPTAIN_SUSSY;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$2") != -1)
				{
					capData.fallMethod = P2FallTypes.PIKMIN;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$3") != -1)
				{
					capData.fallMethod = P2FallTypes.CAPTAIN;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$4") != -1)
				{
					capData.fallMethod = P2FallTypes.PIKMIN_CARRY;
					tekiName = tekiName[2..$];
				}
				else if (indexOf(tekiName, "$5") != -1)
				{
					capData.fallMethod = P2FallTypes.PURPLE_STOMP;
					tekiName = tekiName[2..$];
				}
				else
				{
					capData.fallMethod = P2FallTypes.PIKMIN_CAPTAIN;
					tekiName = tekiName[1..$];
				}
			}
			else
			{
				capData.fallMethod = P2FallTypes.FT_NONE;
			}

			// Parse object name and treasure(Ignore certain plants when checking for treasure)
			if (indexOf(tekiName, "_") != -1 && indexOf(tekiName, "KareOoinu") == -1 
				&& indexOf(tekiName, "Ooinu") == -1 && indexOf(tekiName, "Wakame") == -1)
			{
				long separator = indexOf(tekiName, "_");
				capData.tekiName = tekiName[0..separator];
				capData.treasureName = tekiName[separator+1..$];
			}
			else
			{
				capData.tekiName = tekiName;
			}
			capData.weight = to!ubyte(tekiWeight);
			// Read teki spawn type
			capData.spawnType = to!ubyte(caveTxt.readln().split[0]);
			sublevel.capInfo.capData ~= capData;
		}
		caveTxt.readln(); caveTxt.readln(); caveTxt.readln(); // Skip to next section
		cave.sublevel ~= sublevel;
	}
	
	caveTxt.close();
	return cave;
}

///Deserializes a Pikmin 2 Cave struct back into a txt file
int deserializeCave(P2Cave cave, string filepath)
{
	File cavetxt = File(filepath, "w");

	// Deserialize CaveInfo
	cavetxt.writefln("{\n\t{c000} 4 %s\n\t{_eof}\n}\n%s", cave.floorAmount, cave.floorAmount);

	// Main Sublevel loop
	for (uint i = 0; i < cave.floorAmount; i++)
	{
		// Deserialize Sublevel Info
		cavetxt.writefln("{\n\t{f000} 4 %s\n\t{f001} 4 %s", cave.sublevel[i].floorID,cave.sublevel[i].floorID);
		cavetxt.writefln("\t{f002} 4 %s", cave.sublevel[i].maxObjectNum);
		cavetxt.writefln("\t{f003} 4 %s", cave.sublevel[i].maxTreasureNum);
		cavetxt.writefln("\t{f004} 4 %s", cave.sublevel[i].maxGateNum);
		cavetxt.writefln("\t{f014} 4 %s", cave.sublevel[i].deadendProb);
		cavetxt.writefln("\t{f005} 4 %s", cave.sublevel[i].roomNum);
		cavetxt.writefln("\t{f006} 4 %s", cave.sublevel[i].corridorProb);
		cavetxt.writefln("\t{f007} 4 %s", cave.sublevel[i].hasGeyser);
		cavetxt.writefln("\t{f008} -1 %s", cave.sublevel[i].unitDef);
		cavetxt.writefln("\t{f009} -1 %s", cave.sublevel[i].lightDef);
		cavetxt.writefln("\t{f00A} -1 %s", cave.sublevel[i].skybox);
		cavetxt.writefln("\t{f010} 4 %s", cave.sublevel[i].clog);
		cavetxt.writefln("\t{f011} 4 %s", cave.sublevel[i].echoStrength);
		cavetxt.writefln("\t{f012} 4 %s", cave.sublevel[i].musicType);
		cavetxt.writefln("\t{f013} 4 %s", cave.sublevel[i].solidPlane);
		cavetxt.writefln("\t{f015} 4 %s", cave.sublevel[i].formatVer);
		cavetxt.writefln("\t{f016} 4 %s", cave.sublevel[i].wraithTimer);
		cavetxt.writefln("\t{_eof}\n}");

		// Deserialize Teki Info
		cavetxt.writefln("{\n\t%s", cave.sublevel[i].tekiInfo.tekiNum);
		for (uint j = 0; j < cave.sublevel[i].tekiInfo.tekiNum; j++)
		{
			// Write Teki Fall type, if any
			cavetxt.writef("\t%s", to!string(cast(OriginalType!P2FallTypes) cave.sublevel[i].tekiInfo.tekiData[j].fallMethod));
			// Write Teki name
			cavetxt.write(cave.sublevel[i].tekiInfo.tekiData[j].tekiName);
			// Write carried treasure, if there is any
			if (cave.sublevel[i].tekiInfo.tekiData[j].treasureName != "")
			{
				cavetxt.writef("_%s", cave.sublevel[i].tekiInfo.tekiData[j].tekiName);
			}
			// Write Teki weight
			cavetxt.writefln(" %s", cave.sublevel[i].tekiInfo.tekiData[j].weight);
			// Write Teki type
			cavetxt.writefln("\t%s", cave.sublevel[i].tekiInfo.tekiData[j].spawnType);
		}

		// Deserialize Item Info
		cavetxt.writefln("}\n{\n\t%s", cave.sublevel[i].itemInfo.treasureNum);
		for (uint j = 0; j < cave.sublevel[i].itemInfo.treasureNum; j++)
		{
			cavetxt.writefln("\t%s %s", cave.sublevel[i].itemInfo.itemData[j].treasureName, 
				cave.sublevel[i].itemInfo.itemData[j].weight);
		}

		// Deserialize Gate Info
		cavetxt.writefln("}\n{\n\t%s", cave.sublevel[i].gateInfo.gateNum);
		for (uint j = 0; j < cave.sublevel[i].gateInfo.gateNum; j++)
		{
			cavetxt.writefln("\t%s %s\n\t%s", cave.sublevel[i].gateInfo.gateData[j].gateName, 
				cave.sublevel[i].gateInfo.gateData[j].gateHP, cave.sublevel[i].gateInfo.gateData[j].weight);
		}

		// Deserialize Cap Info
		cavetxt.writefln("}\n{\n\t%s", cave.sublevel[i].capInfo.capNum);
		for (uint j = 0; j < cave.sublevel[i].capInfo.capNum; j++)
		{
			// Write captype
			cavetxt.writefln("\t%s", cave.sublevel[i].capInfo.capData[j].capType);
			// Write Teki Fall type, if any
			cavetxt.writef("\t%s", to!string(cast(OriginalType!P2FallTypes) cave.sublevel[i].capInfo.capData[j].fallMethod));
			// Write Teki name
			cavetxt.write(cave.sublevel[i].capInfo.capData[j].tekiName);
			// Write carried treasure, if there is any
			if (cave.sublevel[i].capInfo.capData[j].treasureName != "")
			{
				cavetxt.writef("_%s", cave.sublevel[i].capInfo.capData[j].treasureName);
			}
			// Write Teki weight
			cavetxt.writefln(" %s", cave.sublevel[i].capInfo.capData[j].weight);
			// Write Teki type
			cavetxt.writefln("\t%s", cave.sublevel[i].capInfo.capData[j].spawnType);
		}
		cavetxt.writeln("}");
	}

	cavetxt.close();
	return 1;
}

P2CaveBGM serializeCaveBgm(File caveBGM)
{
	P2CaveBGM bgm;

	// Skip to first element
	caveBGM.readln(); caveBGM.readln(); caveBGM.readln(); caveBGM.readln();
	bgm.caveNum = to!ubyte(strip(caveBGM.readln()));
	// Prepare for loop
	string curLine;
	caveBGM.readln(); caveBGM.readln();
	for (int i = 0; i < bgm.caveNum; i++)
	{
		P2BGMList bgmList;

		// Skip Comment and bracket
		caveBGM.readln(); caveBGM.readln();
		curLine = caveBGM.readln();
		// Strip everything past # and apply
		bgmList.sublevelNum = to!uint(strip(curLine[0..indexOf(curLine, "#")]));

		for (int j = 0; j < bgmList.sublevelNum; j++)
		{
			curLine = caveBGM.readln();
			bgmList.songs ~= curLine[0..indexOf(curLine, "#")].split[0];
		}

		caveBGM.readln(); caveBGM.readln();
		bgm.bgmLists ~= bgmList;
	}

	caveBGM.close();
	return bgm;
}

int deserializeCaveBgm(P2CaveBGM bgm, string filepath)
{
	File caveBGM = File(filepath, "w");

	caveBGM.writeln(bgm.caveNum);

	for (int i = 0; i < bgm.caveNum; i++)
	{

		caveBGM.writefln("{\n\t%s", bgm.bgmLists[i].sublevelNum);
		for (int j = 0; j < bgm.bgmLists[i].sublevelNum; j++)
		{
			caveBGM.writefln("\t%s", bgm.bgmLists[i].songs[j]);
		}
		caveBGM.writeln("}");
	}

	caveBGM.close();
	return 1;
}