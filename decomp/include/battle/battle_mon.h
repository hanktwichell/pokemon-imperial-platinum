#ifndef POKEPLATINUM_BATTLE_BATTLE_MON_H
#define POKEPLATINUM_BATTLE_BATTLE_MON_H

#include "constants/moves.h"
#include "constants/pokemon.h"
#include "constants/string.h"

typedef struct MoveEffectsData {
    u32 disabledTurns : 3;
    u32 encoredTurns : 3;
    u32 chargedTurns : 2;
    u32 tauntedTurns : 3;
    u32 protectSuccessTurns : 2;
    u32 perishSongTurns : 2;
    u32 rolloutCount : 3;
    u32 furyCutterCount : 3;
    u32 stockpileCount : 3;
    u32 stockpileDefBoosts : 3;
    u32 stockpileSpDefBoosts : 3;
    u32 truant : 1;
    u32 flashFire : 1;

    u32 lockOnTarget : 2;
    u32 mimickedMoveSlot : 4;
    u32 bindTarget : 2;
    u32 meanLookTarget : 2;
    u32 lastResortCount : 3;
    u32 magnetRiseTurns : 3;
    u32 healBlockTurns : 3;
    u32 embargoTurns : 3;
    u32 canUnburden : 1;
    u32 metronomeTurns : 4;
    u32 micleBerry : 1;
    u32 custapBerry : 1;
    u32 quickClaw : 1;
    u32 meFirst : 1;
    u32 padding0004_1F : 1;

    int rechargeTurnNumber;
    int fakeOutTurnNumber;
    int slowStartTurnNumber;
    int meFirstTurnNumber;
    int substituteHP;
    u32 transformedPID;

    u16 disabledMove;
    u16 bindingMove;
    u16 encoredMove;
    u16 encoredMoveSlot;
    u16 lastResortMoves[4];
    u16 choiceLockedMove;
    u16 transformedGender;

    int itemHPRecovery;
} MoveEffectsData;

typedef struct BattleMon {
    u16 species;
    u16 attack;
    u16 defense;
    u16 speed;
    u16 spAttack;
    u16 spDefense;
    u16 moves[LEARNED_MOVES_MAX];

    u32 hpIV : 5;
    u32 attackIV : 5;
    u32 defenseIV : 5;
    u32 speedIV : 5;
    u32 spAttackIV : 5;
    u32 spDefenseIV : 5;
    u32 isEgg : 1;
    u32 hasNickname : 1;

    s8 statBoosts[NUM_BOOSTABLE_STATS];

    int weight;

    u8 type1;
    u8 type2;
    u8 formNum : 7; // Sovereign: 7 bits, for Alcremie's 63 forms (Platinum: 5)
    u8 isShiny : 1;
    u16 ability; // Sovereign: u16 (Gen IX ability IDs go past 255)

    u32 weatherAbilityAnnounced : 1;
    u32 intimidateAnnounced : 1;
    u32 traceAnnounced : 1;
    u32 downloadAnnounced : 1;
    u32 anticipationAnnounced : 1;
    u32 forewarnAnnounced : 1;
    u32 slowStartAnnounced : 1;
    u32 slowStartFinished : 1;
    u32 friskAnnounced : 1;
    u32 moldBreakerAnnounced : 1;
    u32 pressureAnnounced : 1;
    u32 freezeTurns : 2; // Sovereign: move attempts spent frozen (Pokémon Champions thaws on the third)
    u32 sovereignBoosterEnergy : 1; // Sovereign (item 11): Booster Energy powers its Protosynthesis or Quark Drive
    u32 sovereignProteanUsed : 1; // Sovereign (item 11): Protean or Libero has changed its type since it switched in
    u32 sovereignEntryAnnounced : 1; // Sovereign (item 11): its entry ability (Screen Cleaner) has run since it switched in
    u32 sovereignHPFormChecked : 1; // Sovereign (FM): Schooling or Shields Down has been checked since it switched in
    u32 sovereignIceFaceHail : 1; // Sovereign (FM): Ice Face has seen this snow (it restores the ice once per snow)
    u32 sovereignTeraShell : 1; // Sovereign (FM): Tera Shell works on the move hitting it now (it had full HP at its first hit)
    u32 sovereignBalloonAnnounced : 1; // Sovereign (item 11): its Air Balloon has been announced since it switched in

    u8 ppCur[LEARNED_MOVES_MAX];
    u8 ppUps[LEARNED_MOVES_MAX];

    u8 level;
    u8 friendship;

    u16 nickname[MON_NAME_LEN + 1];

    s32 curHP;
    u32 maxHP;

    u16 OTName[TRAINER_NAME_LEN + 1];

    u32 exp;
    u32 personality;
    u32 status;
    u32 statusVolatile;
    u32 OTId;

    u16 heldItem;
    u16 padding007A; // unused

    u8 timesDamaged;
    u8 trainerMessageFlags;
    u8 gender : 4;
    u8 OTGender : 4;
    u8 capturedBall;

    u32 moveEffectsMask;
    u32 moveEffectsTemp;
    MoveEffectsData moveEffectsData;
} BattleMon;

#endif // POKEPLATINUM_BATTLE_BATTLE_MON_H
