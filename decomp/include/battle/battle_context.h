#ifndef POKEPLATINUM_BATTLE_BATTLE_CONTEXT_H
#define POKEPLATINUM_BATTLE_BATTLE_CONTEXT_H

#include "constants/battle.h"
#include "constants/pokemon.h"

#include "struct_decls/battle_system.h"
#include "struct_decls/font_oam.h"

#include "battle/ai_context.h"
#include "battle/battle_mon.h"
#include "battle_anim/struct_ball_rotation_decl.h"

#include "char_transfer.h"
#include "sprite_system.h"

typedef struct BattleContext BattleContext;

typedef struct BattleMessage {
    u8 commandCode;
    u8 tags;
    u16 id;
    int params[6];
    int digits;
    int battler;
} BattleMessage;

typedef struct FieldConditions {
    u32 weatherTurns;
    u8 futureSightTurns[MAX_BATTLERS];
    u8 wishTurns[MAX_BATTLERS];
    u16 futureSightMove[MAX_BATTLERS];
    int futureSightAttacker[MAX_BATTLERS];
    s32 futureSightDamage[MAX_BATTLERS];
    u8 wishTarget[MAX_BATTLERS];
} FieldConditions;

typedef struct SideConditions {
    u32 reflectUser : 2;
    u32 reflectTurns : 3;
    u32 lightScreenUser : 2;
    u32 lightScreenTurns : 3;
    u32 mistUser : 2;
    u32 mistTurns : 3;
    u32 safeguardUser : 2;
    u32 safeguardTurns : 3;
    u32 followMe : 1;
    u32 followMeUser : 2;
    u32 knockedOffItemsMask : 6;
    u32 padding00_1D : 3;

    u32 spikesLayers : 2;
    u32 toxicSpikesLayers : 2;
    u32 padding04_04 : 28;
} SideConditions;

typedef struct TurnFlags {
    u32 struggling : 1;
    u32 ppDecremented : 1;
    u32 protecting : 1;
    u32 helpingHand : 1;
    u32 magicCoat : 1;
    u32 snatching : 1;
    u32 roosting : 1;
    u32 fleeing : 2;
    u32 enduring : 1;
    u32 sovereignStatsRaised : 1; // Sovereign (item 11): a stat rose this turn (Burning Jealousy, Alluring Voice)
    u32 sovereignStatsLowered : 1; // Sovereign (item 11): a stat fell this turn (Lash Out)
    u32 sovereignUsedRound : 1; // Sovereign (item 11): used Round this turn (its partner's Round doubles)
    u32 padding00_0A : 19;

    int physicalDamageTakenFrom[MAX_BATTLERS];
    int physicalDamageLastAttacker;
    int physicalDamageAttackerMask;

    int specialDamageTakenFrom[MAX_BATTLERS];
    int specialDamageLastAttacker;
    int specialDamageAttackerMask;

    int lastDamageTaken;
    int lastAttacker;
    int assuranceDamageMask;
} TurnFlags;

typedef struct SelfTurnFlags {
    u32 skipPressureCheck : 1;
    u32 lightningRodActivated : 1;
    u32 stormDrainActivated : 1;
    u32 moldBreakerActivated : 1;
    u32 trickRoomActivated : 1;
    u32 focusItemActivated : 1;
    u32 repeatedMoveCount : 3;
    u32 padding00_09 : 23;

    int physicalDamageTaken;
    int physicalDamageLastAttacker;
    int specialDamageTaken;
    int specialDamageLastAttacker;
    int statusFlags;
    int shellBellDamageDealt;
} SelfTurnFlags;

typedef struct MoveFailFlags {
    u32 paralyzed : 1;
    u32 noEffect : 1;
    u32 imprisoned : 1;
    u32 infatuated : 1;
    u32 disabled : 1;
    u32 taunted : 1;
    u32 flinched : 1;
    u32 confused : 1;
    u32 gravity : 1;
    u32 healBlocked : 1;
    u32 padding00_0A : 22;
} MoveFailFlags;

typedef struct BattleScriptTaskData {
    BattleSystem *battleSys;
    BattleContext *battleCtx;
    BallRotation *ballRotation;
    ManagedSprite *sprites[2];
    FontOAM *fontOAM;
    CharTransferAllocation charTransferAllocation;
    int flag;
    int seqNum;
    int ball;
    int tmpData[8];
    void *tmpPtr[2];
} BattleScriptTaskData;

struct BattleContext {
    u8 curCommandState[MAX_BATTLERS];
    u8 nextCommandState[MAX_BATTLERS];

    int command;
    int commandNext;

    int fieldConditionCheckState;
    int fieldConditionCheckTemp;
    int monConditionCheckState;
    int monConditionCheckTemp;
    int sideConditionCheckState;
    int sideConditionCheckTemp;
    int turnStartCheckState;
    int turnStartCheckTemp;
    int afterMoveHitCheckState;
    int afterMoveHitCheckTemp;
    int afterMoveMessageType;
    int afterMoveMessageState;
    int afterMoveEffectState;

    int afterMoveEffectTemp;
    int beforeMoveCheckState;
    int tryMoveCheckState;
    int statusCheckState;
    int abilityCheckState;
    int switchInCheckState;
    int vanishedCheckTemp;

    int padding0060;

    int attacker;
    int attackerTemp;
    int defender;
    int defenderTemp;
    int faintedMon;
    int switchedMon;
    int switchedMonTemp;
    int abilityMon;
    int magicCoatMon;
    int sideEffectType;
    int sideEffectParam;
    int sideEffectFlags;
    int sideEffectMon;
    int lastBattlerId;

    int gainedExp;
    int sharedExp;
    u32 sideGetExpMask[2];

    enum NarcID scriptNarc;
    int scriptFile;
    int scriptCursor;
    int scriptStackPointer;
    enum NarcID scriptStackNarc[BATTLE_SCRIPT_STACK_MAX];
    int scriptStackFile[BATTLE_SCRIPT_STACK_MAX];
    int scriptStackCursor[BATTLE_SCRIPT_STACK_MAX];

    int turnOrderCounter;
    int waitCounter;

    BattleMessage msgBuffer;
    int msgBattlerTemp;
    int msgAttacker;
    int msgDefender;
    int msgMoveTemp;
    int msgItemTemp;
    int msgAbilityTemp;
    int msgTemp;
    int calcTemp;
    int scriptTemp;

    u32 battlerStatusFlags[MAX_BATTLERS];
    u32 payDayCount;
    int totalTurns;
    int totalFainted[MAX_BATTLERS];
    int totalDamage[MAX_BATTLERS];
    int meFirstTurnOrder;

    BattleScriptTaskData *taskData;
    void *tmpData;

    u32 fieldConditionsMask;
    FieldConditions fieldConditions;

    u32 sideConditionsMask[NUM_BATTLE_SIDES];
    SideConditions sideConditions[NUM_BATTLE_SIDES];

    TurnFlags turnFlags[MAX_BATTLERS];
    SelfTurnFlags selfTurnFlags[MAX_BATTLERS];
    MoveFailFlags moveFailFlags[MAX_BATTLERS];

    AIContext aiContext; // has the move and item data tables
    u32 *aiScriptTemp;
    u32 aiScriptCursor;

    u32 battleStatusMask;
    u32 battleStatusMask2;

    int damage;
    int hitDamage;
    int criticalBoosts;
    int criticalMul;
    int movePower;
    int powerMul;
    int hpCalcTemp;
    int moveType;
    int moveEffectChance;
    int prizeMoneyMul;
    u32 moveStatusFlags;
    u32 sideEffectDirectFlags;
    u32 sideEffectIndirectFlags;
    u32 sideEffectAbilityFlags;
    u8 multiHitCounter;
    u8 multiHitNumHits;
    u8 battlerCounter;
    u8 beatUpCounter;

    BOOL multiHitLoop;
    u32 multiHitCheckFlags;
    u32 multiHitAccuracyCheck;

    u32 clearVolatileStatus[MAX_BATTLERS];

    u8 selectedPartySlot[MAX_BATTLERS];
    u8 switchedPartySlot[MAX_BATTLERS];
    u8 aiSwitchedPartySlot[MAX_BATTLERS];

    u32 battlerActions[MAX_BATTLERS][MAX_BATTLE_ACTIONS];
    u8 battlerActionOrder[MAX_BATTLERS];
    u8 monSpeedOrder[MAX_BATTLERS];
    u32 monSpeedValues[MAX_BATTLERS];

    u8 ioQueue[MAX_LINK_BATTLERS][MAX_BATTLERS][BATTLE_IO_QUEUE_SIZE];
    u8 ioBuffer[MAX_BATTLERS][BATTLE_IO_BUFFER_SIZE];
    int battleScript[BATTLE_SCRIPT_SIZE_MAX];

    BattleMon battleMons[MAX_BATTLERS];

    u32 moveTemp;
    u32 moveCur;
    u32 movePrev;
    u32 moveLockedInto[MAX_BATTLERS];
    u16 moveProtect[MAX_BATTLERS];
    u16 moveHit[MAX_BATTLERS];
    u16 moveHitBattler[MAX_BATTLERS];
    u16 moveHitType[MAX_BATTLERS];
    u16 movePrevByBattler[MAX_BATTLERS];
    u16 moveCopied[MAX_BATTLERS];
    u16 moveCopiedHit[MAX_BATTLERS][MAX_BATTLERS];
    u16 moveSketched[MAX_BATTLERS];
    u16 moveSelected[MAX_BATTLERS];
    u16 moveSlot[MAX_BATTLERS];
    u16 conversion2Move[MAX_BATTLERS];
    u16 conversion2Battler[MAX_BATTLERS];
    u16 conversion2Type[MAX_BATTLERS];
    u16 metronomeMove[MAX_BATTLERS];

    int storedDamage[MAX_BATTLERS];
    int lastHitByBattler[MAX_BATTLERS];
    int battlerSpeedTemp;
    u8 battlersSwitchingMask;
    u8 levelUpMons;
    u16 padding310A;

    u16 speedRand[MAX_BATTLERS];

    int flingTemp;
    int flingScript;

    u8 safariCatchStage;
    u8 safariEscapeCount;
    u8 runAttempts;
    u8 battleEndFlag;

    u8 magnitude;
    u8 fieldWeatherChecked;
    s16 hpTemp;

    u16 recycleItem[MAX_BATTLERS];

    u8 partyOrder[MAX_BATTLERS][MAX_PARTY_SIZE];

    BOOL expJinglePlayed;

    int linkBattleTimeout;

    u8 recordedCommandFlags[MAX_BATTLERS];

    int waitingBattlers;

    u32 battleProgressFlag : 1;
    u32 padding3154_01 : 31;

    // Sovereign (E8): Mega Evolution. Battler masks use FlagIndex(battler).
    u8 sovereignMegaPending; // battlers who chose to Mega Evolve before this turn's moves
    u8 sovereignMegaUsed; // trainers who have Mega Evolved this battle (BattleSystem_SovereignMegaTrainerBit)
    u8 sovereignMegaResort; // a Mega Evolved this turn: re-sort the remaining moves by the new Speed
    u8 sovereignMegaSwitchInCheck; // a Mega Evolved: check switch-in abilities (Drought, Intimidate...) again
    u8 sovereignTotemAuraDone; // Sovereign (decision 18): the Totem's aura has flared at the start of its trial
    u8 sovereignMoveFormBattler; // Sovereign (FM): 1 + the battler whose move changes its form at move end (Relic Song)

    // Sovereign (item 11): battlers whose Defiant or Competitive was triggered by a foe's move lowering their stats;
    // the boost is applied after the move (BattleControllerPlayer_TriggerAfterMoveHitEffects).
    u8 sovereignDefiantPending;
    u8 sovereignAdrenalinePending; // Sovereign (item 11): Intimidate targeted these Adrenaline Orb holders (flags by battler)
    u8 sovereignMirrorHerbRises[MAX_BATTLERS][NUM_BOOSTABLE_STATS]; // Sovereign (item 11): the foes' stat rises a Mirror Herb holder will copy, by stat
    u8 sovereignMirrorHerbHolder; // Sovereign (item 11): the holder copying them (BTLVAR_SOVEREIGN_MIRROR_HERB_NEXT)
    u16 sovereignLastMoveThisTurn; // Sovereign (item 11): the last move that worked this turn (Fusion Flare and Fusion Bolt)
    u16 sovereignLastMoveTurn; // Sovereign (item 11): totalTurns + 1 when it worked
    u16 sovereignLastMoveUsed[MAX_BATTLERS]; // Sovereign (item 11): each battler's last move used (Gigaton Hammer, Blood Moon)
    int sovereignStrengthSapHeal; // Sovereign (item 11): Strength Sap's healing, the target's Attack before its drop
    u8 sovereignLastMoveFailed[MAX_BATTLERS]; // Sovereign (item 11): Stomping Tantrum and Temper Flare
    u32 sovereignTerrainTemp; // Sovereign (item 11): BTLVAR_SOVEREIGN_TERRAIN_EFFECT_MON
    u32 sovereignHeroPending; // Sovereign (FM): a Palafin that became Hero and hasn't come back in (BattleSystem_SovereignHeroBit)
    int sovereignLaserFocus[MAX_BATTLERS]; // Sovereign (item 11): turns of Laser Focus left (its moves always crit)
    int sovereignThroatChop[MAX_BATTLERS]; // Sovereign (item 11): turns it can't use sound moves (Throat Chop)
    int sovereignSmackedDown[MAX_BATTLERS]; // Sovereign (item 11): grounded by Smack Down
    int sovereignSideGuards[2]; // Sovereign (item 11): this turn's Wide Guard (1), Quick Guard (2), Mat Block (4) and
    // Crafty Shield (8) for each side
    int sovereignSideFaintTurn[2]; // Sovereign (item 11): totalTurns + 1 when a Pokemon on the side last fainted (Retaliate)
    int sovereignAuroraVeilTurns[2]; // Sovereign (item 11)
    int sovereignEchoedVoiceTurn; // Sovereign (item 11): totalTurns + 1 of the last Echoed Voice (0 = none yet)
    int sovereignEchoedVoiceCount; // Sovereign (item 11): consecutive turns of Echoed Voice, up to 5
    u8 sovereignOncePerBattle[MAX_BATTLERS]; // Sovereign (item 11): party slots whose Intrepid Sword or Dauntless Shield has triggered
    u8 sovereignParentalBond; // Sovereign (item 11): the current move hits a second time through Parental Bond
    u8 sovereignThroughProtect; // Sovereign (item 11): the current hit goes through protection with Unseen Fist or Piercing Drill
    int sovereignHPBeforeHit[MAX_BATTLERS]; // Sovereign (item 11): each battler's HP before the last hit it took (Berserk, Innards Out)
    int sovereignDragonCheer[MAX_BATTLERS]; // Sovereign (item 11): Dragon Cheer's crit stages (1, or 2 for a Dragon type)
    u8 sovereignAteBerry[MAX_BATTLERS]; // Sovereign (item 11): party slots that have eaten a Berry this battle (Belch)
    u16 sovereignCudChewBerry[MAX_BATTLERS]; // Sovereign (item 11): the Berry Cud Chew will eat again (ITEM_NONE for none)
    int sovereignCudChewTurn[MAX_BATTLERS]; // Sovereign (item 11): the turn it was eaten; Cud Chew eats it at the end of a later one
    int sovereignMagicRoomTurns; // Sovereign (item 11): turns of Magic Room left (held items have no effect)
    int sovereignWonderRoomTurns; // Sovereign (item 11): turns of Wonder Room left (Defense and Sp. Def swapped)
    int sovereignTelekinesis[MAX_BATTLERS]; // Sovereign (item 11): turns of Telekinesis left on each battler
    int sovereignMirrorArmorHolder; // Sovereign (item 11): 1 + the Mirror Armor holder while a drop goes back to its source
    u8 sovereignQuickDraw; // Sovereign (item 11): battlers Quick Draw lets move first this turn (for its message)
    u8 sovereignSoulHeartDone; // Sovereign (item 11): Soul-Heart holders whose Sp. Atk already rose for this faint
    int sovereignSoulHeartSaved[3]; // Sovereign (item 11): the side-effect battler, type and param Soul-Heart borrows
    int sovereignInHazards; // Sovereign (item 11): TRUE while subscript_hazards_check runs (Infiltrator)
    u8 sovereignGemBoost; // Sovereign (item 11): 1 + the attacker whose Gem powered up its current move's damage
    int sovereignHalfHPPaid; // Sovereign (item 11): the current move's user paid Steel Beam's half-HP cost already
    u8 sovereignGlaiveRush; // Sovereign (item 11): battlers that used Glaive Rush, until their next move (flags by battler)
    u8 sovereignSaltCure; // Sovereign (item 11): battlers hurt by Salt Cure at the end of each turn (flags by battler)
    u8 sovereignSyrupBomb[MAX_BATTLERS]; // Sovereign (item 11): Syrup Bomb's Speed drops left on each battler
    u8 sovereignSyrupBombSource[MAX_BATTLERS]; // Sovereign (item 11): the battler whose Syrup Bomb it was
    u8 sovereignSyrupBombSourceSlot[MAX_BATTLERS]; // Sovereign (item 11): that battler's party slot (it must stay in)
    u8 sovereignTimesHit[MAX_BATTLERS][MAX_PARTY_SIZE]; // Sovereign (item 11): hits each party slot has taken since it came in (Rage Fist)
    u8 sovereignTarShot; // Sovereign (item 11): battlers Tar Shot made weaker to Fire, until they switch out (flags by battler)
    u8 sovereignHappyHour; // Sovereign (item 11): the player's side used Happy Hour (double prize money)
    u16 sovereignShieldMove[MAX_BATTLERS]; // Sovereign (item 11): the Protect-like move protecting each battler this turn
    int sovereignShieldContact; // Sovereign (item 11): the shield whose contact penalty is due (subscript_missed)
    int sovereignGuardBlock; // Sovereign (item 11): the side guard that blocked the move (Wide Guard, Mat Block, ...)
};

#endif // POKEPLATINUM_BATTLE_BATTLE_CONTEXT_H
