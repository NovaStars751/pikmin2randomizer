module p2enemy_serial;

import std.conv;
import std.stdio;
import std.string;
import std.traits;

struct P2EnemyPhysics
{
    float friction;
    float wallReflection;
    float faceDirAdjust;
    float accel;
    float bounceFactor;
}

struct P2EnemyStats
{
    float life;
    float lifeHeight;
    float lifeRecovery;
    float mapHit;
    float polyPerimeter;
    float withPikmin;
    float radiusLOD;
    float damageScaleXZ;
    float damageScaleY;
    float damageFrame;
    float quality;
    float speed;
    float recoveryRate;
    float maxRotateSpeed;
    float territory;
    float homeRange;
    float privateRange;
    float visibilityRange;
    float highHorizon;
    float horizonAngle;
    float exploringDistance;
    float exploringHigh;
    float explorationAngle;
    float shakePower;
    float shakeDamage;
    float shakeRange;
    float shakeRate;
    float attackableRange;
    float attackableAngle;
    float leaderDamage;
    float alertTime;
    float sprayStunTimer;
    float pPikminDamage;
    float pPikminStunChance;
    float pPikminStunTime;
    float shakeShotA;
    float shakeAttatchment1;
    float shakeShotB;
    float shakeAttatchment2;
    float shakeShotC;
    float shakeAttatchment3;
    float shakeShotD;
}