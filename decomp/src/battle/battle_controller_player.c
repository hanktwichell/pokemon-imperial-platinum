#include "battle/battle_controller_player.h"

#include "nitro/types.h"
#include <nitro.h>
#include <string.h>

#include "constants/battle.h"
#include "constants/game_options.h"
#include "constants/heap.h"
#include "constants/items.h"
#include "constants/moves.h"
#include "constants/narc.h"
#include "constants/pokemon.h"
#include "constants/species.h"
#include "generated/abilities.h"
#include "generated/game_records.h"
#include "generated/trainer_classes.h"

#include "struct_decls/battle_system.h"
#include "struct_defs/battler_data.h"
#include "struct_defs/trainer.h"

#include "battle/ai_context.h"
#include "battle/battle_context.h"
#include "battle/battle_controller.h"
#include "battle/battle_display.h"
#include "battle/battle_lib.h"
#include "battle/battle_main.h"
#include "battle/battle_script.h"
#include "battle/battle_system.h"
#include "battle/common.h"
#include "battle/message_defs.h"

#include "bag.h"
#include "communication_system.h"
#include "flags.h"
#include "heap.h"
#include "item.h"
#include "move_table.h"
#include "party.h"
#include "pokemon.h"
#include "screen_fade.h"
#include "sound_playback.h"
#include "sovereign_test.h"
#include "trainer_info.h"

#include "res/battle/scripts/sub_seq.naix"
#include "res/text/bank/battle_strings.h"

enum BattleControllerState {
    STATE_PROCESSING = 0,
    STATE_BREAK_OUT,
    STATE_DONE
};

typedef void (*BattleControlFunc)(BattleSystem *, BattleContext *);

static void BattleControllerPlayer_InitBattleMons(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_StartEncounter(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_TrainerMessage(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_ShowBattleMon(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_InitCommandSelection(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CommandSelectionInput(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CalcTurnOrder(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckPreMoveActions(BattleSystem *battleSys, BattleContext *battleCtx);
static int Sovereign_TurnOrderClass(BattleContext *battleCtx, int battler);
static BOOL Sovereign_DragonDartsNext(BattleSystem *battleSys, BattleContext *battleCtx);

// Sovereign (item 11): Dragon Darts in a double battle. Each dart is a pass of the move at one target.
enum SovereignDarts {
    SOVEREIGN_DARTS_NONE = 0, // the darts don't split (a single battle, or no ally to aim at)
    SOVEREIGN_DARTS_FIRST, // the first dart is at the target
    SOVEREIGN_DARTS_SECOND, // the second dart is at the target's ally
    SOVEREIGN_DARTS_DONE, // the darts that are left go to one target
};
static void BattleControllerPlayer_BranchActions(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckFieldConditions(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckMonConditions(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckSideConditions(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_TurnEnd(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_FightCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_ItemCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_SwitchCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_FleeCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_SafariBallCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_SafariBaitCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_SafariRockCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_SafariFleeCommand(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_ExecScript(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_BeforeMove(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_TryMove(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_PrimaryEffect(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckMoveFailure(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_UseMove(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_UpdateHP(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_AfterMoveMessage(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LeftoverState29(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_AfterMoveEffects(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LoopMultiHit(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LeftoverState32(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LoopWhileFainted(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LoopSpreadMoves(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_FaintAfterSelfdestruct(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_TriggerAfterHitEffects(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_LeftoverState37(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_UpdateMoveBuffers(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_MoveEnd(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_CheckAnyFainted(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_HandleResult(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_ScreenWipe(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_EndFight(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_EndWait(BattleSystem *battleSys, BattleContext *battleCtx);

static int BattleControllerPlayer_CheckObedience(BattleSystem *battleSys, BattleContext *battleCtx, int *nextSeq);
static BOOL BattleControllerPlayer_DecrementPP(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_HasNoTarget(BattleSystem *battleSys, BattleContext *battleCtx);
static int BattleControllerPlayer_CheckTypeChart(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_CheckStatusDisruption(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_TriggerImmunityAbilities(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_LoadQuickClawCheck(BattleSystem *battleSys, BattleContext *battleCtx);
static int BattleControllerPlayer_CheckMoveHitAccuracy(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move);
static int BattleControllerPlayer_CheckMoveHitOverrides(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move);
static BOOL BattleControllerPlayer_MoveStolen(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_ReplaceFainted(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_CheckBattleOver(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_MustSelectTarget(BattleSystem *battleSys, BattleContext *battleCtx, u8 battler, u32 battleType, int *range, int moveSlot, u32 *target);
static void BattleControllerPlayer_ClearFlags(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_AnyFainted(BattleContext *battleCtx, int nextCmd, int nextCmdNoFainted, BOOL onlyFaint);
static BOOL BattleControllerPlayer_AnyExpPayout(BattleContext *battleCtx, int nextCmd, int nextCmdNoExp);
static void BattleControllerPlayer_UpdateFlagsWhenHit(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_TriggerAfterMoveHitEffects(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_CriticalMessage(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_FollowupMessage(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_RageBuilding(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_CheckExtraFlinch(BattleSystem *battleSys, BattleContext *battleCtx);
static BOOL BattleControllerPlayer_ToggleSemiInvulnMons(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleControllerPlayer_InitAI(BattleSystem *battleSys, BattleContext *battleCtx);
static void BattleSystem_RecordCommand(BattleSystem *battleSys, BattleContext *battleCtx);

extern u32 gTrainerAITable[];

static const BattleControlFunc sBattleControlCommands[] = {
    [BATTLE_CONTROL_GET_BATTLE_MON] = BattleControllerPlayer_InitBattleMons,
    [BATTLE_CONTROL_START_ENCOUNTER] = BattleControllerPlayer_StartEncounter,
    [BATTLE_CONTROL_TRAINER_MESSAGE] = BattleControllerPlayer_TrainerMessage,
    [BATTLE_CONTROL_SHOW_BATTLE_MON] = BattleControllerPlayer_ShowBattleMon,
    [BATTLE_CONTROL_INIT_COMMAND_SELECTION] = BattleControllerPlayer_InitCommandSelection,
    [BATTLE_CONTROL_COMMAND_SELECTION_INPUT] = BattleControllerPlayer_CommandSelectionInput,
    [BATTLE_CONTROL_CALC_TURN_ORDER] = BattleControllerPlayer_CalcTurnOrder,
    [BATTLE_CONTROL_CHECK_PRE_MOVE_ACTIONS] = BattleControllerPlayer_CheckPreMoveActions,
    [BATTLE_CONTROL_BRANCH_ACTIONS] = BattleControllerPlayer_BranchActions,
    [BATTLE_CONTROL_CHECK_FIELD_CONDITIONS] = BattleControllerPlayer_CheckFieldConditions,
    [BATTLE_CONTROL_CHECK_MON_CONDITIONS] = BattleControllerPlayer_CheckMonConditions,
    [BATTLE_CONTROL_CHECK_SIDE_CONDITIONS] = BattleControllerPlayer_CheckSideConditions,
    [BATTLE_CONTROL_TURN_END] = BattleControllerPlayer_TurnEnd,
    [BATTLE_CONTROL_FIGHT] = BattleControllerPlayer_FightCommand,
    [BATTLE_CONTROL_ITEM] = BattleControllerPlayer_ItemCommand,
    [BATTLE_CONTROL_PARTY] = BattleControllerPlayer_SwitchCommand,
    [BATTLE_CONTROL_RUN] = BattleControllerPlayer_FleeCommand,
    [BATTLE_CONTROL_SAFARI_BALL] = BattleControllerPlayer_SafariBallCommand,
    [BATTLE_CONTROL_SAFARI_BAIT] = BattleControllerPlayer_SafariBaitCommand,
    [BATTLE_CONTROL_SAFARI_ROCK] = BattleControllerPlayer_SafariRockCommand,
    [BATTLE_CONTROL_SAFARI_WAIT] = BattleControllerPlayer_SafariFleeCommand,
    [BATTLE_CONTROL_EXEC_SCRIPT] = BattleControllerPlayer_ExecScript,
    [BATTLE_CONTROL_BEFORE_MOVE] = BattleControllerPlayer_BeforeMove,
    [BATTLE_CONTROL_TRY_MOVE] = BattleControllerPlayer_TryMove,
    [BATTLE_CONTROL_PRIMARY_EFFECT] = BattleControllerPlayer_PrimaryEffect,
    [BATTLE_CONTROL_MOVE_FAILED] = BattleControllerPlayer_CheckMoveFailure,
    [BATTLE_CONTROL_USE_MOVE] = BattleControllerPlayer_UseMove,
    [BATTLE_CONTROL_UPDATE_HP] = BattleControllerPlayer_UpdateHP,
    [BATTLE_CONTROL_AFTER_MOVE_MESSAGE] = BattleControllerPlayer_AfterMoveMessage,
    [BATTLE_CONTROL_UNUSED_29] = BattleControllerPlayer_LeftoverState29,
    [BATTLE_CONTROL_AFTER_MOVE_EFFECT] = BattleControllerPlayer_AfterMoveEffects,
    [BATTLE_CONTROL_LOOP_MULTI_HIT] = BattleControllerPlayer_LoopMultiHit,
    [BATTLE_CONTROL_UNUSED_32] = BattleControllerPlayer_LeftoverState32,
    [BATTLE_CONTROL_LOOP_FAINTED] = BattleControllerPlayer_LoopWhileFainted,
    [BATTLE_CONTROL_LOOP_SPREAD_MOVES] = BattleControllerPlayer_LoopSpreadMoves,
    [BATTLE_CONTROL_FAINT_AFTER_SELFDESTRUCT] = BattleControllerPlayer_FaintAfterSelfdestruct,
    [BATTLE_CONTROL_TRIGGER_AFTER_HIT_EFFECTS] = BattleControllerPlayer_TriggerAfterHitEffects,
    [BATTLE_CONTROL_UNUSED_37] = BattleControllerPlayer_LeftoverState37,
    [BATTLE_CONTROL_UPDATE_MOVE_BUFFERS] = BattleControllerPlayer_UpdateMoveBuffers,
    [BATTLE_CONTROL_MOVE_END] = BattleControllerPlayer_MoveEnd,
    [BATTLE_CONTROL_CHECK_ANY_FAINTED] = BattleControllerPlayer_CheckAnyFainted,
    [BATTLE_CONTROL_RESULT] = BattleControllerPlayer_HandleResult,
    [BATTLE_CONTROL_SCREEN_WIPE] = BattleControllerPlayer_ScreenWipe,
    [BATTLE_CONTROL_FIGHT_END] = BattleControllerPlayer_EndFight,
    [BATTLE_CONTROL_END_WAIT] = BattleControllerPlayer_EndWait
};

void *BattleContext_New(BattleSystem *battleSys)
{
    BattleContext *battleContext = Heap_Alloc(HEAP_ID_BATTLE, sizeof(BattleContext));

    MI_CpuClearFast(battleContext, sizeof(BattleContext));

    BattleContext_Init(battleContext);
    BattleContext_InitCounters(battleSys, battleContext);
    BattleControllerPlayer_InitAI(battleSys, battleContext);

    MoveTable_Load(&battleContext->aiContext.moveTable);
    battleContext->aiContext.itemTable = ItemTable_Load(HEAP_ID_BATTLE);

    return battleContext;
}

BOOL BattleContext_Main(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->battleEndFlag == FALSE
        && BattleSystem_GetResultMask(battleSys)
        && (BattleSystem_GetResultMask(battleSys) & BATTLE_RESULT_TRY_FLEE_WAIT) == FALSE) {
        battleCtx->command = BATTLE_CONTROL_RESULT;
    }

    sBattleControlCommands[battleCtx->command](battleSys, battleCtx);

    if (battleCtx->command == BATTLE_CONTROL_END_WAIT) {
        return TRUE;
    }

    return FALSE;
}

void BattleContext_Free(BattleContext *battleCtx)
{
    Heap_Free(battleCtx->aiContext.itemTable);
    Heap_Free(battleCtx);
}

void BattleControllerPlayer_CheckMoveHit(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move)
{
    BattleControllerPlayer_CheckMoveHitAccuracy(battleSys, battleCtx, attacker, defender, move);
    BattleControllerPlayer_CheckMoveHitOverrides(battleSys, battleCtx, attacker, defender, move);
}

static void BattleControllerPlayer_InitBattleMons(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    for (int i = 0; i < maxBattlers; i++) {
        // Sovereign (decision 18): a battler with no Pokémon to send out (battle_main.c) starts as one that fainted
        // with none left to replace it: no HP, party slot 6, in the switching mask and with an inactive sprite.
        if (battleCtx->selectedPartySlot[i] == MAX_PARTY_SIZE) {
            battleCtx->battlersSwitchingMask |= FlagIndex(i);
            BattleDisplay_SovereignSetAbsentBattler(battleSys, i);
            continue;
        }

        BattleSystem_InitBattleMon(battleSys, battleCtx, i, battleCtx->selectedPartySlot[i]);
    }

    // Sovereign (item 11): Illusion picks its disguise once every lead is in place.
    for (int i = 0; i < maxBattlers; i++) {
        if (battleCtx->selectedPartySlot[i] != MAX_PARTY_SIZE) {
            Sovereign_SetIllusion(battleSys, battleCtx, i);
        }
    }

    battleCtx->hpTemp = battleCtx->battleMons[BATTLER_THEM].curHP;
    battleCtx->command = BATTLE_CONTROL_START_ENCOUNTER;
}

static void BattleControllerPlayer_StartEncounter(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_start_encounter);
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_TRAINER_MESSAGE;
}

static void BattleControllerPlayer_TrainerMessage(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleSystem_CheckTrainerMessage(battleSys, battleCtx)) {
        LOAD_SUBSEQ(subscript_trainer_message);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_SHOW_BATTLE_MON;
    } else {
        battleCtx->command = BATTLE_CONTROL_SHOW_BATTLE_MON;
    }

    BattleSystem_SortMonSpeedOrder(battleSys, battleCtx);
}

static void BattleControllerPlayer_ShowBattleMon(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int nextSeq = BattleSystem_TriggerEffectOnSwitch(battleSys, battleCtx);

    if (nextSeq) {
        LOAD_SUBSEQ(nextSeq);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    } else {
        BattleSystem_SortMonSpeedOrder(battleSys, battleCtx);
        BattleSystem_ShowStopPlaybackButton(battleSys);
        battleCtx->command = BATTLE_CONTROL_INIT_COMMAND_SELECTION;
    }
}

static void BattleControllerPlayer_InitCommandSelection(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int i; // this has to be declared up here to match
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (i = 0; i < maxBattlers; i++) {
        battleCtx->curCommandState[i] = 0;
        battleCtx->battleMons[i].moveEffectsTemp = battleCtx->battleMons[i].moveEffectsMask;
        battleCtx->recordedCommandFlags[i] = 0;
    }

    BattleSystem_SetCommandSelectionFlags(battleSys, 0);
    BattleSystem_LoadFightOverlay(battleSys, TRUE);

    battleCtx->command = BATTLE_CONTROL_COMMAND_SELECTION_INPUT;
}

enum CommandSelectionState {
    COMMAND_SELECTION_INIT = 0,
    COMMAND_SELECTION_SELECT,
    COMMAND_SELECTION_SELECT2,
    COMMAND_SELECTION_MOVE_SELECT_INIT,
    COMMAND_SELECTION_MOVE_SELECT,
    COMMAND_SELECTION_TARGET_SELECT_INIT,
    COMMAND_SELECTION_TARGET_SELECT,
    COMMAND_SELECTION_ITEM_SELECT_INIT,
    COMMAND_SELECTION_ITEM_SELECT,
    COMMAND_SELECTION_PARTY_SELECT_INIT,
    COMMAND_SELECTION_PARTY_SELECT,
    COMMAND_SELECTION_RUN_SELECT_INIT,
    COMMAND_SELECTION_RUN_SELECT,
    COMMAND_SELECTION_WAIT,
    COMMAND_SELECTION_END,
    COMMAND_SELECTION_ALERT_MESSAGE_WAIT,
    COMMAND_SELECTION_STRUGGLE_MESSAGE,
    COMMAND_SELECTION_CLEAR_TOUCH_SCREEN,
};

static inline BOOL SingleControllerForSide(BattleContext *battleCtx, int battler, int side)
{
    return battler == side + 2 && battleCtx->curCommandState[side] != COMMAND_SELECTION_END;
}

static void BattleControllerPlayer_CommandSelectionInput(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int battleType = BattleSystem_GetBattleType(battleSys);
    int battlersDone = 0;
    BattleMessage msg;

    for (int i = 0; i < maxBattlers; i++) {
        switch (battleCtx->curCommandState[i]) {
        case COMMAND_SELECTION_INIT:
            battleCtx->sovereignMegaPending &= ~FlagIndex(i); // Sovereign (E8): chosen again with the move

            // No need to reinitialize if the same controller acts for both battlers on a side.
            if ((battleType & BATTLE_TYPE_DOUBLES)
                && (battleType & BATTLE_TYPE_2vs2) == FALSE
                && (SingleControllerForSide(battleCtx, i, BATTLE_SIDE_PLAYER)
                    || SingleControllerForSide(battleCtx, i, BATTLE_SIDE_ENEMY))) {
                break;
            }

            // Sovereign (item 11): a Tatsugiri in its ally Dondozo's mouth (Commander) can't act.
            if ((battleCtx->battlersSwitchingMask | battleCtx->sovereignCommanding) & FlagIndex(i)) {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;
                break;
            } else if (Battler_CanPickCommand(battleCtx, i) == FALSE) {
                battleCtx->turnFlags[i].ppDecremented = TRUE;
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_FIGHT;
                break;
            }

            // Don't let slow AI processing delay the player from picking their action for the turn
            if (BattlerData_GetBootState(BattleSystem_GetBattlerData(battleSys, i)) == BATTLER_BOOT_STATE_AI || battleCtx->totalTurns) {
                BattleController_EmitSetCommandSelection(battleSys, battleCtx, i, battleCtx->selectedPartySlot[i]);
                battleCtx->curCommandState[i] = COMMAND_SELECTION_SELECT;
            } else {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_SELECT2;
            }

            break;

        case COMMAND_SELECTION_SELECT2:
            int j;
            for (j = 0; j < maxBattlers; j++) {
                if (j == i || BattlerData_GetBootState(BattleSystem_GetBattlerData(battleSys, j)) != BATTLER_BOOT_STATE_AI) {
                    continue;
                }

                if (battleCtx->curCommandState[j] != COMMAND_SELECTION_END) {
                    break;
                }
            }

            if (j == maxBattlers) {
                BattleController_EmitSetCommandSelection(battleSys, battleCtx, i, battleCtx->selectedPartySlot[i]);
                battleCtx->curCommandState[i] = COMMAND_SELECTION_SELECT;
            } else {
                break;
            }
            // fall-through

        case COMMAND_SELECTION_SELECT:
            if (BattleContext_IOBufferVal(battleCtx, i)) {
                battleCtx->battlerActions[i][BATTLE_ACTION_SELECTED_COMMAND] = battleCtx->ioBuffer[i][0];

                if (battleType & BATTLE_TYPE_PAL_PARK) {
                    switch (BattleContext_IOBufferVal(battleCtx, i)) {
                    case PLAYER_INPUT_PAL_PARK_BALL:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = BATTLE_CONTROL_FIGHT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_SAFARI_BALL;
                        break;

                    case PLAYER_INPUT_PAL_PARK_RUN:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = BATTLE_CONTROL_FIGHT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_RUN;
                        break;
                    }

                    break;
                } else if (battleType & BATTLE_TYPE_SAFARI) {
                    switch (BattleContext_IOBufferVal(battleCtx, i)) {
                    case PLAYER_INPUT_SAFARI_BALL:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_SAFARI_BALL;
                        break;

                    case PLAYER_INPUT_SAFARI_BAIT:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_SAFARI_BAIT;
                        break;

                    case PLAYER_INPUT_SAFARI_ROCK:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_SAFARI_ROCK;
                        break;

                    case PLAYER_INPUT_SAFARI_RUN:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_RUN;
                        break;

                    case PLAYER_INPUT_SAFARI_WAIT:
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_SAFARI_WAIT;
                        break;
                    }

                    break;
                }

                if (BattleContext_IOBufferVal(battleCtx, i) != PLAYER_INPUT_CANCEL) {
                    battleCtx->recordedCommandFlags[i] |= RECORDED_CMD_FLAG_ACTION;
                }

                switch (BattleContext_IOBufferVal(battleCtx, i)) {
                case PLAYER_INPUT_FIGHT:
                    if (BattleSystem_CheckInvalidMoves(battleSys, battleCtx, i, 0, CHECK_INVALID_ALL) == STRUGGLING_ALL) {
                        // Don't let the player select a move if they are out of PP on all moves
                        battleCtx->turnFlags[i].struggling = TRUE;

                        if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_RECORDING) {
                            battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                        } else {
                            battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                            battleCtx->nextCommandState[i] = COMMAND_SELECTION_STRUGGLE_MESSAGE;
                        }
                    } else if (battleCtx->battleMons[i].moveEffectsData.encoredMove) {
                        // Don't let the player select a move if they are under the effect of Encore
                        battleCtx->moveSlot[i] = battleCtx->battleMons[i].moveEffectsData.encoredMoveSlot;
                        battleCtx->moveSelected[i] = battleCtx->battleMons[i].moveEffectsData.encoredMove;
                        battleCtx->battlerActions[i][BATTLE_ACTION_TEMP_VALUE] = 0;

                        if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_RECORDING) {
                            battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                        } else {
                            battleCtx->curCommandState[i] = COMMAND_SELECTION_CLEAR_TOUCH_SCREEN;
                            battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
                        }
                    } else {
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_MOVE_SELECT_INIT;
                    }

                    battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_FIGHT;
                    break;

                case PLAYER_INPUT_ITEM:
                    if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_FRONTIER_LINK) {
                        msg.id = 593; // "Items can’t be used here."
                        msg.tags = TAG_NONE;
                        BattleController_EmitSetAlertMessage(battleSys, i, msg);

                        battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_INIT;
                    } else {
                        battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_ITEM;
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_ITEM_SELECT_INIT;
                    }
                    break;

                case PLAYER_INPUT_PARTY:
                    battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_PARTY;
                    battleCtx->curCommandState[i] = COMMAND_SELECTION_PARTY_SELECT_INIT;
                    break;

                case PLAYER_INPUT_RUN:
                    battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_RUN;
                    battleCtx->curCommandState[i] = COMMAND_SELECTION_RUN_SELECT_INIT;
                    break;

                case PLAYER_INPUT_CANCEL:
                    if (battleType & BATTLE_TYPE_LINK) {
                        BattleController_EmitStopGaugeAnimation(battleSys, i);
                        battleCtx->curCommandState[i] = BATTLE_CONTROL_GET_BATTLE_MON;
                        battleCtx->curCommandState[BattleSystem_GetPartner(battleSys, i)] = BATTLE_CONTROL_GET_BATTLE_MON;
                    } else if ((battleType & BATTLE_TYPE_DOUBLES) && i == BATTLER_PLAYER_2) {
                        BattleController_EmitStopGaugeAnimation(battleSys, i);
                        battleCtx->curCommandState[BATTLER_PLAYER_1] = BATTLE_CONTROL_GET_BATTLE_MON;
                        battleCtx->curCommandState[BATTLER_PLAYER_2] = BATTLE_CONTROL_GET_BATTLE_MON;
                    }

                    break;
                }
            }
            break;

        case COMMAND_SELECTION_MOVE_SELECT_INIT:
            BattleController_EmitShowMoveSelectMenu(battleSys, battleCtx, i);
            battleCtx->curCommandState[i] = COMMAND_SELECTION_MOVE_SELECT;
            // fall-through

        case COMMAND_SELECTION_MOVE_SELECT:
            if (BattleContext_IOBufferVal(battleCtx, i) == PLAYER_INPUT_CANCEL) {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_INIT;
            } else if (BattleContext_IOBufferVal(battleCtx, i)) {
                if ((battleCtx->ioBuffer[i][0] - 1) == 4) {
                    battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_RUN;
                    battleCtx->curCommandState[i] = COMMAND_SELECTION_RUN_SELECT_INIT;
                    break;
                } else if (BattleSystem_CanUseMove(battleSys, battleCtx, i, battleCtx->ioBuffer[i][0] - 1, &msg) == FALSE) {
                    if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_RECORDING) {
                        BattleSystem_SetStopRecording(battleSys, 1);
                        BattleSystem_IsRecordingStopped(battleSys, BattleSystem_GetBattleContext(battleSys));
                    } else {
                        BattleController_EmitSetAlertMessage(battleSys, i, msg);
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
                        battleCtx->nextCommandState[i] = COMMAND_SELECTION_MOVE_SELECT_INIT;
                    }
                } else {
                    // Sovereign (E8): the move menu's MEGA toggle comes in the input's second byte. Trainers' AI
                    // Mega Evolves as soon as it can (docs/MegaEvolution.md).
                    BOOL megaEvolve = BattlerData_GetBootState(BattleSystem_GetBattlerData(battleSys, i)) == BATTLER_BOOT_STATE_AI
                        || battleCtx->ioBuffer[i][1] != 0;

                    battleCtx->sovereignMegaPending &= ~FlagIndex(i);
                    if (megaEvolve && BattleSystem_SovereignMegaForm(battleSys, battleCtx, i)) {
                        battleCtx->sovereignMegaPending |= FlagIndex(i);
                    }

                    battleCtx->battlerActions[i][2] = battleCtx->ioBuffer[i][0];
                    battleCtx->moveSlot[i] = battleCtx->ioBuffer[i][0] - 1;
                    battleCtx->moveSelected[i] = battleCtx->battleMons[i].moves[battleCtx->moveSlot[i]];
                    battleCtx->curCommandState[i] = COMMAND_SELECTION_TARGET_SELECT_INIT;
                    battleCtx->recordedCommandFlags[i] |= RECORDED_CMD_FLAG_TARGET;
                }
            }
            break;

        case COMMAND_SELECTION_TARGET_SELECT_INIT:
            int target;
            if (BattleControllerPlayer_MustSelectTarget(battleSys, battleCtx, i, battleType, &target, battleCtx->moveSlot[i], &battleCtx->battlerActions[i][1])) {
                BattleCommand_EmitShowTargetSelectMenu(battleSys, battleCtx, target, i);
                battleCtx->curCommandState[i] = COMMAND_SELECTION_TARGET_SELECT;
            } else {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
            }
            break;

        case COMMAND_SELECTION_TARGET_SELECT:
            if (BattleContext_IOBufferVal(battleCtx, i) == PLAYER_INPUT_CANCEL) {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_MOVE_SELECT_INIT;
            } else if (BattleContext_IOBufferVal(battleCtx, i)) {
                battleCtx->battlerActions[i][1] = battleCtx->ioBuffer[i][0] - 1;
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;

                battleCtx->recordedCommandFlags[i] |= RECORDED_CMD_FLAG_MOVE_SLOT;
            }
            break;

        case COMMAND_SELECTION_ITEM_SELECT_INIT:
            BattleController_EmitShowBagMenu(battleSys, battleCtx, i);
            battleCtx->curCommandState[i] = COMMAND_SELECTION_ITEM_SELECT;
            // fall-through

        case COMMAND_SELECTION_ITEM_SELECT:
            if (BattleContext_IOBufferVal(battleCtx, i) == PLAYER_INPUT_CANCEL) {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_INIT;
            } else if (BattleContext_IOBufferVal(battleCtx, i)) {
                u32 *data = &battleCtx->ioBuffer[i][0];
                battleCtx->battlerActions[i][BATTLE_ACTION_TEMP_VALUE] = *data;
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
            }
            break;

        case COMMAND_SELECTION_PARTY_SELECT_INIT:
            int doublesSelection = 6;
            BOOL canSwitch = Battler_IsTrapped(battleSys, battleCtx, i);

            // Check the partner's selection in a double battle
            if ((BattleSystem_GetBattlerType(battleSys, i) == BATTLER_TYPE_PLAYER_SIDE_SLOT_2 || BattleSystem_GetBattlerType(battleSys, i) == BATTLER_TYPE_ENEMY_SIDE_SLOT_2)
                && (battleType == BATTLE_TYPE_TRAINER_DOUBLES
                    || battleType == BATTLE_TYPE_LINK_DOUBLES
                    || battleType == BATTLE_TYPE_FRONTIER_DOUBLES
                    || (battleType == BATTLE_TYPE_TAG_DOUBLES && BattleSystem_GetBattlerType(battleSys, i) == BATTLER_TYPE_PLAYER_SIDE_SLOT_2))) {
                int partner = BattleSystem_GetPartner(battleSys, i);

                if (battleCtx->battlerActions[partner][BATTLE_ACTION_PICK_COMMAND] == BATTLE_CONTROL_PARTY) {
                    doublesSelection = battleCtx->battlerActions[partner][2];
                }
            }

            BattleController_EmitShowPartyMenu(battleSys, battleCtx, i, 0, canSwitch, doublesSelection);
            battleCtx->curCommandState[i] = COMMAND_SELECTION_PARTY_SELECT;
            // fall-through

        case COMMAND_SELECTION_PARTY_SELECT:
            if (BattleContext_IOBufferVal(battleCtx, i) == PLAYER_INPUT_CANCEL) {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_INIT;
            } else if (BattleContext_IOBufferVal(battleCtx, i)) {
                battleCtx->battlerActions[i][BATTLE_ACTION_TEMP_VALUE] = battleCtx->ioBuffer[i][0] - 1;
                battleCtx->switchedPartySlot[i] = battleCtx->ioBuffer[i][0] - 1;
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
            }
            break;

        case COMMAND_SELECTION_RUN_SELECT_INIT:
            if (battleType & BATTLE_TYPE_FRONTIER) {
                // "Would you like to forfeit the match and quit now?"
                BattleController_EmitShowYesNoMenu(battleSys, battleCtx, i, 955, 0, NULL, NULL);
                battleCtx->curCommandState[i] = COMMAND_SELECTION_RUN_SELECT;
            } else if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_SOVEREIGN_TOTEM) {
                // Sovereign (decision 18): "There's no running from a Totem!"
                msg.tags = TAG_NONE;
                msg.id = BattleStrings_Text_SovereignTotemNoRunning;
                BattleController_EmitSetAlertMessage(battleSys, i, msg);

                battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
                battleCtx->nextCommandState[i] = COMMAND_SELECTION_INIT;
            } else if ((battleType & BATTLE_TYPE_TRAINER) && (battleType & BATTLE_TYPE_LINK) == FALSE) {
                if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_RECORDING) {
                    BattleSystem_SetStopRecording(battleSys, 1);
                    BattleSystem_IsRecordingStopped(battleSys, BattleSystem_GetBattleContext(battleSys));
                } else {
                    msg.tags = 0;
                    msg.id = 793;
                    BattleController_EmitSetAlertMessage(battleSys, i, msg);

                    battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
                    battleCtx->nextCommandState[i] = COMMAND_SELECTION_INIT;
                }
            } else if (Battler_IsTrappedMsg(battleSys, battleCtx, i, &msg)) {
                if (BattleSystem_GetBattleStatusMask(battleSys) & BATTLE_STATUS_RECORDING) {
                    BattleSystem_SetStopRecording(battleSys, 1);
                    BattleSystem_IsRecordingStopped(battleSys, BattleSystem_GetBattleContext(battleSys));
                } else {
                    BattleController_EmitSetAlertMessage(battleSys, i, msg);
                    battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
                    battleCtx->nextCommandState[i] = COMMAND_SELECTION_INIT;
                }
            } else {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_RUN_SELECT;
            }
            break;

        case COMMAND_SELECTION_RUN_SELECT:
            if (battleType & BATTLE_TYPE_FRONTIER) {
                if (BattleContext_IOBufferVal(battleCtx, i)) {
                    if (BattleContext_IOBufferVal(battleCtx, i) == PLAYER_INPUT_CANCEL) {
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_INIT;
                    } else {
                        battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
                    }
                }
            } else {
                battleCtx->curCommandState[i] = COMMAND_SELECTION_WAIT;
            }

            if ((battleType & BATTLE_TYPE_DOUBLES)
                && (battleType & BATTLE_TYPE_2vs2) == FALSE
                && (battleCtx->curCommandState[i] == COMMAND_SELECTION_WAIT)) {
                battleCtx->curCommandState[BattleSystem_GetPartner(battleSys, i)] = COMMAND_SELECTION_WAIT;
            }
            break;

        case COMMAND_SELECTION_WAIT:
            BattleController_EmitStopGaugeAnimation(battleSys, i);

            if (battleType == BATTLE_TYPE_LINK_DOUBLES) {
                if (battleCtx->curCommandState[BattleSystem_GetPartner(battleSys, i)] == COMMAND_SELECTION_END) {
                    BattleController_EmitPrintLinkWaitMessage(battleSys, i);
                }
            } else {
                BattleController_EmitPrintLinkWaitMessage(battleSys, i);
            }

            battleCtx->curCommandState[i] = COMMAND_SELECTION_END;
            // fall-through

        case COMMAND_SELECTION_END:
            battlersDone++;
            break;

        case COMMAND_SELECTION_ALERT_MESSAGE_WAIT:
            if (BattleContext_IOBufferVal(battleCtx, i)) {
                BattleIO_ClearBuffer(battleCtx, i);
                battleCtx->curCommandState[i] = battleCtx->nextCommandState[i];
            }
            break;

        case COMMAND_SELECTION_STRUGGLE_MESSAGE:
            msg.tags = TAG_NICKNAME;
            msg.id = 608; // "{0} has no moves left!"
            msg.params[0] = BattleSystem_NicknameTag(battleCtx, i);
            BattleController_EmitSetAlertMessage(battleSys, i, msg);

            battleCtx->curCommandState[i] = COMMAND_SELECTION_ALERT_MESSAGE_WAIT;
            battleCtx->nextCommandState[i] = COMMAND_SELECTION_WAIT;
            break;

        case COMMAND_SELECTION_CLEAR_TOUCH_SCREEN:
            BattleController_EmitClearTouchScreen(battleSys, i);
            battleCtx->curCommandState[i] = battleCtx->nextCommandState[i];
            break;
        }
    }

    if (battlersDone == maxBattlers) {
        BattleSystem_RecordCommand(battleSys, battleCtx);
        BattleSystem_LoadFightOverlay(battleSys, FALSE);

        battleCtx->command = BATTLE_CONTROL_CALC_TURN_ORDER;
        for (int i = 0; i < maxBattlers; i++) {
            if (battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] == BATTLE_CONTROL_PARTY) {
                BattleSystem_SwitchSlots(battleSys, battleCtx, i, battleCtx->switchedPartySlot[i]);
            }
        }
    }
}

static void BattleControllerPlayer_CalcTurnOrder(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int battler, i, j; // Must declare these here to match.

    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    int order = 0;

    battleCtx->sovereignQuickDraw = 0; // Sovereign (item 11): this turn's order sets it again (Quick Draw)

    if (battleType & (BATTLE_TYPE_SAFARI | BATTLE_TYPE_PAL_PARK)) {
        // The player always acts before a wild mon encountered in the Safari Zone or the Pal Park.
        for (battler = 0; battler < maxBattlers; battler++) {
            battleCtx->battlerActionOrder[battler] = battler;
        }
    } else {
        if (battleType & BATTLE_TYPE_LINK) {
            // Check if any battler decided to forfeit. If so, break out and process the forfeit first.
            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_RUN) {
                    order = 5;
                    break;
                }
            }
        } else {
            // If the player decided to Run using either of their mons, process that first.
            if (battleCtx->battlerActions[BATTLER_PLAYER_1][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_RUN) {
                battler = BATTLER_PLAYER_1;
                order = 5;
            }

            if (battleCtx->battlerActions[BATTLER_PLAYER_2][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_RUN) {
                battler = BATTLER_PLAYER_2;
                order = 5;
            }
        }

        if (order == 5) {
            battleCtx->battlerActionOrder[0] = battler;
            order = 1;

            // All other battlers should be defaulted to a position after the one running/forfeiting.
            for (i = 0; i < maxBattlers; i++) {
                if (i != battler) {
                    battleCtx->battlerActionOrder[order] = i;
                    order++;
                }
            }
        } else {
            // Items and switching are processed next.
            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_ITEM
                    || battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_PARTY) {
                    battleCtx->battlerActionOrder[order] = battler;
                    order++;
                }
            }

            // Fight is always processed last.
            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] != PLAYER_INPUT_ITEM
                    && battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] != PLAYER_INPUT_PARTY) {
                    battleCtx->battlerActionOrder[order] = battler;
                    order++;
                }
            }

            // Reorder battlers that chose to Fight according to their speed and priority.
            for (i = 0; i < maxBattlers - 1; i++) {
                for (j = i + 1; j < maxBattlers; j++) {
                    int battler1 = battleCtx->battlerActionOrder[i];
                    int battler2 = battleCtx->battlerActionOrder[j];

                    if (battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND] == battleCtx->battlerActions[battler2][BATTLE_ACTION_SELECTED_COMMAND]) {
                        BOOL skipPriority = battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND] != PLAYER_INPUT_FIGHT;
                        if (BattleSystem_CompareBattlerSpeed(battleSys, battleCtx, battler1, battler2, skipPriority)) {
                            battleCtx->battlerActionOrder[i] = battler2;
                            battleCtx->battlerActionOrder[j] = battler1;
                        }
                    }
                }
            }
        }
    }

    battleCtx->command = BATTLE_CONTROL_CHECK_PRE_MOVE_ACTIONS;
}

enum PreMoveActionState {
    PRE_MOVE_ACTION_START = 0,

    PRE_MOVE_ACTION_STATE_TIGHTEN_FOCUS = PRE_MOVE_ACTION_START,
    PRE_MOVE_ACTION_STATE_CHECK_RAGE_FLAG,
    PRE_MOVE_ACTION_STATE_SPEED_RNG,

    PRE_MOVE_ACTION_END
};

static void BattleControllerPlayer_CheckPreMoveActions(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int state = STATE_PROCESSING;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int battler;

    do {
        switch (battleCtx->turnStartCheckState) {
        case PRE_MOVE_ACTION_STATE_TIGHTEN_FOCUS:
            while (battleCtx->turnStartCheckTemp < maxBattlers) {
                battler = battleCtx->battlerActionOrder[battleCtx->turnStartCheckTemp];

                if (battleCtx->battlersSwitchingMask & FlagIndex(battler)) {
                    battleCtx->turnStartCheckTemp++;
                    continue;
                }

                battleCtx->turnStartCheckTemp++;

                if ((battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP) == FALSE
                    && Battler_SelectedMove(battleCtx, battler) == MOVE_FOCUS_PUNCH
                    && Battler_CheckTruant(battleCtx, battler) == FALSE
                    && battleCtx->turnFlags[battler].struggling == FALSE) {
                    BattleController_EmitClearMessageBox(battleSys);
                    battleCtx->msgBattlerTemp = battler;

                    LOAD_SUBSEQ(subscript_tighten_focus);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    return;
                }

                // Sovereign (item 11): Beak Blast heats up the user's beak, and Shell Trap sets its trap, before anyone
                // moves (Showdown's priority charge, which doesn't check for sleep).
                int sovereignMove = Battler_SelectedMove(battleCtx, battler);

                if ((sovereignMove == MOVE_BEAK_BLAST || sovereignMove == MOVE_SHELL_TRAP)
                    && battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
                    && battleCtx->battleMons[battler].curHP
                    && battleCtx->turnFlags[battler].struggling == FALSE) {
                    if (sovereignMove == MOVE_BEAK_BLAST) {
                        battleCtx->turnFlags[battler].sovereignBeakBlast = TRUE;
                        LOAD_SUBSEQ(subscript_sovereign_beak_blast_charge);
                    } else {
                        battleCtx->turnFlags[battler].sovereignShellTrap = TRUE;
                        LOAD_SUBSEQ(subscript_sovereign_shell_trap_set);
                    }

                    BattleController_EmitClearMessageBox(battleSys);
                    battleCtx->msgBattlerTemp = battler;
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    return;
                }
            }

            battleCtx->turnStartCheckTemp = 0;
            battleCtx->turnStartCheckState++;
            break;

        case PRE_MOVE_ACTION_STATE_CHECK_RAGE_FLAG:
            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_RAGE
                    && Battler_SelectedMove(battleCtx, battler) != MOVE_RAGE) {
                    // Sovereign: Platinum used &= VOLATILE_CONDITION_RAGE, which cleared every volatile status except Rage
                    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_RAGE;
                }
            }

            battleCtx->turnStartCheckState++;
            break;

        case PRE_MOVE_ACTION_STATE_SPEED_RNG:
            for (battler = 0; battler < MAX_BATTLERS; battler++) {
                battleCtx->speedRand[battler] = BattleSystem_RandNext(battleSys);
            }

            battleCtx->turnStartCheckState++;
            break;

        case PRE_MOVE_ACTION_END:
            battleCtx->turnStartCheckState = 0;
            state = STATE_DONE;
            break;
        }
    } while (state == STATE_PROCESSING);

    if (state == STATE_DONE) {
        battleCtx->command = BATTLE_CONTROL_BRANCH_ACTIONS;
    }
}

// Sovereign (E8): run the next pending Mega Evolution, fastest first, then the switch-in abilities it brings
// (Mega Charizard Y's Drought). Returns TRUE while a script was started; BranchActions runs again afterwards.
static BOOL BattleControllerPlayer_SovereignMegaEvolve(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if (battleCtx->sovereignMegaSwitchInCheck) {
        int nextSeq = BattleSystem_TriggerEffectOnSwitch(battleSys, battleCtx);

        if (nextSeq) {
            LOAD_SUBSEQ(nextSeq);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return TRUE;
        }

        battleCtx->sovereignMegaSwitchInCheck = FALSE;
    }

    for (int i = 0; i < maxBattlers && battleCtx->sovereignMegaPending; i++) {
        int battler = battleCtx->monSpeedOrder[i];

        if ((battleCtx->sovereignMegaPending & FlagIndex(battler)) == FALSE) {
            continue;
        }

        battleCtx->sovereignMegaPending &= ~FlagIndex(battler);

        // Checked again: a partner may have used the trainer's Mega Evolution already this turn.
        int form = BattleSystem_SovereignMegaForm(battleSys, battleCtx, battler);
        if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] != PLAYER_INPUT_FIGHT || form == 0) {
            continue;
        }

        BattleController_EmitClearMessageBox(battleSys);
        battleCtx->msgBattlerTemp = battler;
        battleCtx->msgItemTemp = battleCtx->battleMons[battler].heldItem;
        // MSG_TEMP: 1 for Mega Rayquaza (no stone: "fervent wish"), 2 for Ultra Burst (FM).
        BattleMon *megaMon = &battleCtx->battleMons[battler];
        if (Pokemon_SovereignUltraBurstForm(megaMon->species, megaMon->formNum, megaMon->heldItem) == form) {
            battleCtx->msgTemp = 2;
        } else {
            battleCtx->msgTemp = megaMon->species == SPECIES_RAYQUAZA;
        }
        BattleSystem_SovereignMegaEvolve(battleSys, battleCtx, battler, form);
        battleCtx->sovereignMegaResort = TRUE;
        battleCtx->sovereignMegaSwitchInCheck = TRUE;

        LOAD_SUBSEQ(subscript_sovereign_mega_evolution);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        return TRUE;
    }

    return FALSE;
}

static void BattleControllerPlayer_BranchActions(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if (BattleSystem_IsRecordingStopped(battleSys, battleCtx)) {
        return;
    }

    battleCtx->waitingBattlers = 0;
    for (int i = 0; i < maxBattlers; i++) {
        if (battleCtx->battlerActions[i][BATTLE_ACTION_PICK_COMMAND] != BATTLE_CONTROL_MOVE_END) {
            battleCtx->waitingBattlers++;
        }
    }

    BattleSystem_SortMonSpeedOrder(battleSys, battleCtx);

    // Sovereign (E8): Mega Evolution, after switches and items and before the turn's first move.
    if (battleCtx->turnOrderCounter < maxBattlers
        && battleCtx->battlerActions[battleCtx->battlerActionOrder[battleCtx->turnOrderCounter]][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
        && BattleControllerPlayer_SovereignMegaEvolve(battleSys, battleCtx)) {
        return;
    }

    // Sovereign: dynamic speed (Gen VIII+ / Pokémon Champions). Before each action, the battlers still waiting to
    // use a move are re-sorted by their current Speed and priority, so a Speed change earlier in the turn (Icy Wind,
    // paralysis, Tailwind...) affects who moves next. Gen IV fixed the order at the start of the turn. A Mega
    // Evolution's new Speed counts from its own turn (Gen VII+), so the order is re-sorted after one, too.
    if ((battleCtx->turnOrderCounter > 0 || battleCtx->sovereignMegaResort) && battleCtx->turnOrderCounter < maxBattlers - 1
        && (BattleSystem_GetBattleType(battleSys) & (BATTLE_TYPE_SAFARI | BATTLE_TYPE_PAL_PARK)) == FALSE) {
        for (int i = battleCtx->turnOrderCounter; i < maxBattlers - 1; i++) {
            for (int j = i + 1; j < maxBattlers; j++) {
                int battler1 = battleCtx->battlerActionOrder[i];
                int battler2 = battleCtx->battlerActionOrder[j];

                if (battleCtx->battlerActions[battler1][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
                    && battleCtx->battlerActions[battler2][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
                    && battleCtx->battlerActions[battler1][BATTLE_ACTION_PICK_COMMAND] != BATTLE_CONTROL_MOVE_END
                    && battleCtx->battlerActions[battler2][BATTLE_ACTION_PICK_COMMAND] != BATTLE_CONTROL_MOVE_END
                    && Sovereign_TurnOrderClass(battleCtx, battler1) == Sovereign_TurnOrderClass(battleCtx, battler2)
                    && BattleSystem_CompareBattlerSpeed(battleSys, battleCtx, battler1, battler2, FALSE)) {
                    battleCtx->battlerActionOrder[i] = battler2;
                    battleCtx->battlerActionOrder[j] = battler1;
                }
            }
        }
    }

    battleCtx->sovereignMegaResort = FALSE;

    if (battleCtx->turnOrderCounter == maxBattlers) {
        battleCtx->turnOrderCounter = 0;
        battleCtx->sovereignMegaPending = 0;
        battleCtx->command = BATTLE_CONTROL_CHECK_FIELD_CONDITIONS;

        // Sovereign (item 11): the HP before the end-of-turn damage, for Emergency Exit (BattleControllerPlayer_TurnEnd).
        for (int i = 0; i < maxBattlers; i++) {
            battleCtx->sovereignHPBeforeTurnEnd[i] = battleCtx->battleMons[i].curHP;
        }
    } else {
        battleCtx->command = battleCtx->battlerActions[battleCtx->battlerActionOrder[battleCtx->turnOrderCounter]][BATTLE_ACTION_PICK_COMMAND];
    }
}

enum FieldCondCheckState {
    FIELD_COND_CHECK_START = 0,

    FIELD_COND_CHECK_STATE_REFLECT = FIELD_COND_CHECK_START,
    FIELD_COND_CHECK_STATE_LIGHT_SCREEN,
    FIELD_COND_CHECK_STATE_SOVEREIGN_AURORA_VEIL,
    FIELD_COND_CHECK_STATE_MIST,
    FIELD_COND_CHECK_STATE_SAFEGUARD,
    FIELD_COND_CHECK_STATE_TAILWIND,
    FIELD_COND_CHECK_STATE_LUCKY_CHANT,
    FIELD_COND_CHECK_STATE_WISH,
    FIELD_COND_CHECK_STATE_RAINING,
    FIELD_COND_CHECK_STATE_SANDSTORM,
    FIELD_COND_CHECK_STATE_SUNNY,
    FIELD_COND_CHECK_STATE_HAILING,
    FIELD_COND_CHECK_STATE_DEEP_FOG,
    FIELD_COND_CHECK_STATE_GRAVITY,
    FIELD_COND_CHECK_STATE_SOVEREIGN_TERRAIN,
    FIELD_COND_CHECK_STATE_SOVEREIGN_ROOMS,

    FIELD_COND_CHECK_END
};

static inline void PrepareSubroutineSequence(BattleContext *battleCtx, int script)
{
    LOAD_SUBSEQ(script);
    battleCtx->commandNext = battleCtx->command;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
}

static inline void StepFieldConditionCheck(BattleContext *battleCtx, int state)
{
    if (state == STATE_PROCESSING) {
        battleCtx->fieldConditionCheckState++;
        battleCtx->fieldConditionCheckTemp = 0;
    }
}

static void BattleControllerPlayer_CheckFieldConditions(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int state = STATE_PROCESSING;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int side;

    do {
        // Explicit `== TRUE` is needed to match on these
        if (BattleControllerPlayer_AnyFainted(battleCtx, battleCtx->command, battleCtx->command, 1) == TRUE
            || BattleControllerPlayer_AnyExpPayout(battleCtx, battleCtx->command, battleCtx->command) == TRUE
            || BattleControllerPlayer_CheckBattleOver(battleSys, battleCtx) == TRUE) {
            return;
        }

        switch (battleCtx->fieldConditionCheckState) {
        case FIELD_COND_CHECK_STATE_REFLECT:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_REFLECT
                    && --battleCtx->sideConditions[side].reflectTurns == 0) {
                    battleCtx->sideConditionsMask[side] &= ~SIDE_CONDITION_REFLECT;
                    battleCtx->msgMoveTemp = MOVE_REFLECT;

                    PrepareSubroutineSequence(battleCtx, subscript_move_effect_end);
                    battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_LIGHT_SCREEN:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_LIGHT_SCREEN
                    && --battleCtx->sideConditions[side].lightScreenTurns == 0) {
                    battleCtx->sideConditionsMask[side] &= ~SIDE_CONDITION_LIGHT_SCREEN;
                    battleCtx->msgMoveTemp = MOVE_LIGHT_SCREEN;

                    PrepareSubroutineSequence(battleCtx, subscript_move_effect_end);
                    battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_SOVEREIGN_AURORA_VEIL: // Sovereign (item 11)
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_SOVEREIGN_AURORA_VEIL
                    && --battleCtx->sovereignAuroraVeilTurns[side] <= 0) {
                    battleCtx->sideConditionsMask[side] &= ~SIDE_CONDITION_SOVEREIGN_AURORA_VEIL;
                    battleCtx->msgMoveTemp = MOVE_AURORA_VEIL;

                    PrepareSubroutineSequence(battleCtx, subscript_move_effect_end);
                    battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_MIST:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_MIST
                    && --battleCtx->sideConditions[side].mistTurns == 0) {
                    battleCtx->sideConditionsMask[side] &= ~SIDE_CONDITION_MIST;
                    battleCtx->msgMoveTemp = MOVE_MIST;

                    PrepareSubroutineSequence(battleCtx, subscript_move_effect_end);
                    battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_SAFEGUARD:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_SAFEGUARD
                    && --battleCtx->sideConditions[side].safeguardTurns == 0) {
                    battleCtx->sideConditionsMask[side] &= ~SIDE_CONDITION_SAFEGUARD;
                    battleCtx->msgBattlerTemp = battleCtx->sideConditions[side].safeguardUser;

                    PrepareSubroutineSequence(battleCtx, subscript_safeguard_end);
                    battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_TAILWIND:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_TAILWIND) {
                    battleCtx->sideConditionsMask[side] -= SIDE_CONDITION_TAILWIND_SHIFT;

                    if ((battleCtx->sideConditionsMask[side] & SIDE_CONDITION_TAILWIND) == FALSE) {
                        PrepareSubroutineSequence(battleCtx, subscript_tailwind_end);
                        battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                        state = STATE_BREAK_OUT;
                    }
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_LUCKY_CHANT:
            while (battleCtx->fieldConditionCheckTemp < NUM_BATTLE_SIDES) {
                side = battleCtx->fieldConditionCheckTemp;

                if (battleCtx->sideConditionsMask[side] & SIDE_CONDITION_LUCKY_CHANT) {
                    battleCtx->sideConditionsMask[side] -= SIDE_CONDITION_LUCKY_CHANT_SHIFT;

                    if ((battleCtx->sideConditionsMask[side] & SIDE_CONDITION_LUCKY_CHANT) == FALSE) {
                        PrepareSubroutineSequence(battleCtx, subscript_lucky_chant_end);
                        battleCtx->msgBattlerTemp = BattleSystem_SideToBattler(battleSys, battleCtx, side);
                        state = STATE_BREAK_OUT;
                    }
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_WISH:
            while (battleCtx->fieldConditionCheckTemp < maxBattlers) {
                side = battleCtx->monSpeedOrder[battleCtx->fieldConditionCheckTemp]; // actually a battler, but must reuse side var to match

                if (battleCtx->fieldConditions.wishTurns[side]
                    && --battleCtx->fieldConditions.wishTurns[side] == 0
                    && battleCtx->battleMons[side].curHP) {
                    battleCtx->msgBattlerTemp = side;

                    battleCtx->msgBuffer.tags = TAG_NICKNAME;
                    battleCtx->msgBuffer.id = 533; // "{0}'s wish came true!"
                    battleCtx->msgBuffer.params[0] = side | (battleCtx->fieldConditions.wishTarget[side] << 8);

                    battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[side].maxHP, 2);

                    PrepareSubroutineSequence(battleCtx, subscript_wish_heal);
                    state = STATE_BREAK_OUT;
                }

                battleCtx->fieldConditionCheckTemp++;
                if (state) {
                    break;
                }
            }

            StepFieldConditionCheck(battleCtx, state);
            break;

        case FIELD_COND_CHECK_STATE_RAINING:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_RAINING) {
                if (battleCtx->fieldConditionsMask & FIELD_CONDITION_RAINING_PERM) {
                    battleCtx->msgBuffer.id = 801; // "Rain continues to fall."
                    battleCtx->msgBuffer.tags = TAG_NONE;

                    PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                } else {
                    if (--battleCtx->fieldConditions.weatherTurns == 0) {
                        PrepareSubroutineSequence(battleCtx, subscript_raining_end);
                    } else {
                        battleCtx->msgBuffer.id = 801; // "Rain continues to fall."
                        battleCtx->msgBuffer.tags = TAG_NONE;

                        PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                    }
                }

                battleCtx->scriptTemp = BATTLE_ANIMATION_WEATHER_RAIN;
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_SANDSTORM:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_SANDSTORM) {
                if (battleCtx->fieldConditionsMask & FIELD_CONDITION_SANDSTORM_PERM) {
                    battleCtx->msgBuffer.id = 805; // "The sandstorm rages."
                    battleCtx->msgBuffer.tags = TAG_NONE;

                    PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                } else {
                    if (--battleCtx->fieldConditions.weatherTurns == 0) {
                        PrepareSubroutineSequence(battleCtx, subscript_sandstorm_end);
                    } else {
                        battleCtx->msgBuffer.id = 805; // "The sandstorm rages."
                        battleCtx->msgBuffer.tags = TAG_NONE;

                        PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                    }
                }

                battleCtx->scriptTemp = BATTLE_ANIMATION_WEATHER_SAND;
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_SUNNY:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY) {
                if (battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY_PERM) {
                    battleCtx->msgBuffer.id = 808; // "The sunlight is strong."
                    battleCtx->msgBuffer.tags = TAG_NONE;

                    PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                } else {
                    if (--battleCtx->fieldConditions.weatherTurns == 0) {
                        PrepareSubroutineSequence(battleCtx, subscript_sunny_end);
                    } else {
                        battleCtx->msgBuffer.id = 808; // "The sunlight is strong."
                        battleCtx->msgBuffer.tags = TAG_NONE;

                        PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                    }
                }

                battleCtx->scriptTemp = BATTLE_ANIMATION_WEATHER_SUN;
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_HAILING:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_HAILING) {
                if (battleCtx->fieldConditionsMask & FIELD_CONDITION_HAILING_PERM) {
                    battleCtx->msgBuffer.id = 811; // "Hail continues to fall."
                    battleCtx->msgBuffer.tags = TAG_NONE;

                    PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                } else {
                    if (--battleCtx->fieldConditions.weatherTurns == 0) {
                        PrepareSubroutineSequence(battleCtx, subscript_hailing_end);
                    } else {
                        battleCtx->msgBuffer.id = 811; // "Hail continues to fall."
                        battleCtx->msgBuffer.tags = TAG_NONE;

                        PrepareSubroutineSequence(battleCtx, subscript_weather_continues);
                    }
                }

                battleCtx->scriptTemp = BATTLE_ANIMATION_WEATHER_HAIL;
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_DEEP_FOG:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_DEEP_FOG) {
                battleCtx->msgBuffer.id = 813; // "The fog is deep..."
                battleCtx->msgBuffer.tags = TAG_NONE;

                PrepareSubroutineSequence(battleCtx, subscript_weather_continues);

                battleCtx->scriptTemp = BATTLE_ANIMATION_WEATHER_FOG;
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_GRAVITY:
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) {
                battleCtx->fieldConditionsMask -= (1 << FIELD_CONDITION_GRAVITY_SHIFT);

                if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) == 0) {
                    PrepareSubroutineSequence(battleCtx, subscript_gravity_end);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_SOVEREIGN_TERRAIN:
            // Sovereign (item 11): count the terrain down; subscript_sovereign_terrain_end clears it.
            if (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN) {
                battleCtx->fieldConditionsMask -= (1 << FIELD_CONDITION_TERRAIN_TURNS_SHIFT);

                if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN_TURNS) == 0) {
                    PrepareSubroutineSequence(battleCtx, subscript_sovereign_terrain_end);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_STATE_SOVEREIGN_ROOMS:
            // Sovereign (item 11): count Magic Room and Wonder Room down, one end message per pass.
            if (battleCtx->sovereignMagicRoomTurns && --battleCtx->sovereignMagicRoomTurns == 0) {
                battleCtx->msgTemp = 0;
                PrepareSubroutineSequence(battleCtx, subscript_sovereign_room_end);
                state = STATE_BREAK_OUT;
                break; // Wonder Room is checked on the next pass
            }

            if (battleCtx->sovereignWonderRoomTurns && --battleCtx->sovereignWonderRoomTurns == 0) {
                battleCtx->msgTemp = 1;
                PrepareSubroutineSequence(battleCtx, subscript_sovereign_room_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->fieldConditionCheckState++;
            break;

        case FIELD_COND_CHECK_END:
            state = STATE_DONE;
            break;
        }
    } while (state == STATE_PROCESSING);

    if (state == STATE_BREAK_OUT) {
        BattleController_EmitClearMessageBox(battleSys);
    }

    if (state == STATE_DONE) {
        battleCtx->fieldConditionCheckState = FIELD_COND_CHECK_START;
        battleCtx->command = BATTLE_CONTROL_CHECK_MON_CONDITIONS;
    }
}

enum MonCondCheckState {
    MON_COND_CHECK_START = 0,

    MON_COND_CHECK_STATE_INGRAIN = MON_COND_CHECK_START,
    MON_COND_CHECK_STATE_SOVEREIGN_GRASSY_TERRAIN,
    MON_COND_CHECK_STATE_AQUA_RING,
    MON_COND_CHECK_STATE_ABILITY,
    MON_COND_CHECK_STATE_USE_ITEM,
    MON_COND_CHECK_STATE_LEFTOVERS,
    MON_COND_CHECK_STATE_LEECH_SEED,
    MON_COND_CHECK_STATE_POISON,
    MON_COND_CHECK_STATE_TOXIC,
    MON_COND_CHECK_STATE_BURN,
    MON_COND_CHECK_STATE_NIGHTMARE,
    MON_COND_CHECK_STATE_CURSE,
    MON_COND_CHECK_STATE_BIND,
    MON_COND_CHECK_STATE_SOVEREIGN_SALT_CURE,
    MON_COND_CHECK_STATE_SOVEREIGN_SYRUP_BOMB,
    MON_COND_CHECK_STATE_SOVEREIGN_OCTOLOCK,
    MON_COND_CHECK_STATE_BAD_DREAMS,
    MON_COND_CHECK_STATE_UPROAR,
    MON_COND_CHECK_STATE_THRASH,
    MON_COND_CHECK_STATE_DISABLE,
    MON_COND_CHECK_STATE_ENCORE,
    MON_COND_CHECK_STATE_LOCK_ON,
    MON_COND_CHECK_STATE_CHARGE,
    MON_COND_CHECK_STATE_TAUNT,
    MON_COND_CHECK_STATE_MAGNET_RISE,
    MON_COND_CHECK_STATE_SOVEREIGN_TELEKINESIS,
    MON_COND_CHECK_STATE_HEAL_BLOCK,
    MON_COND_CHECK_STATE_EMBARGO,
    MON_COND_CHECK_STATE_YAWN,
    MON_COND_CHECK_STATE_ITEM_CONDITION,
    MON_COND_CHECK_STATE_ITEM_DETRIMENTAL_EFFECT,

    MON_COND_CHECK_END
};

static void BattleControllerPlayer_CheckMonConditions(BattleSystem *battleSys, BattleContext *battleCtx)
{
    u8 state = STATE_PROCESSING;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    // Explicit `== TRUE` is needed to match on these.
    if (BattleControllerPlayer_AnyFainted(battleCtx, battleCtx->command, battleCtx->command, 1) == TRUE
        || BattleControllerPlayer_AnyExpPayout(battleCtx, battleCtx->command, battleCtx->command) == TRUE
        || BattleControllerPlayer_CheckBattleOver(battleSys, battleCtx) == TRUE) {
        return;
    }

    int i, battler;
    while (battleCtx->monConditionCheckTemp < maxBattlers) {
        battler = battleCtx->monSpeedOrder[battleCtx->monConditionCheckTemp];

        if (battleCtx->battlersSwitchingMask & FlagIndex(battler)) {
            battleCtx->monConditionCheckTemp++;
            continue;
        }

        switch (battleCtx->monConditionCheckState) {
        case MON_COND_CHECK_STATE_INGRAIN:
            if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_INGRAIN)
                && battleCtx->battleMons[battler].curHP != battleCtx->battleMons[battler].maxHP
                && battleCtx->battleMons[battler].curHP) {
                if (battleCtx->battleMons[battler].moveEffectsData.healBlockTurns) {
                    battleCtx->msgBattlerTemp = battler;
                    LOAD_SUBSEQ(subscript_cannot_heal);
                } else {
                    battleCtx->msgBattlerTemp = battler;
                    LOAD_SUBSEQ(subscript_ingrain_heal);
                }

                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_SOVEREIGN_GRASSY_TERRAIN:
            // Sovereign (item 11): Grassy Terrain heals grounded Pokemon by 1/16 of their max HP.
            if ((Sovereign_TerrainUnder(battleCtx, battler) & FIELD_CONDITION_TERRAIN_GRASSY)
                && battleCtx->battleMons[battler].curHP != battleCtx->battleMons[battler].maxHP
                && battleCtx->battleMons[battler].curHP
                && battleCtx->battleMons[battler].moveEffectsData.healBlockTurns == 0) {
                battleCtx->msgBattlerTemp = battler;
                LOAD_SUBSEQ(subscript_sovereign_grassy_terrain_heal);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_AQUA_RING:
            if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_AQUA_RING)
                && battleCtx->battleMons[battler].curHP != battleCtx->battleMons[battler].maxHP
                && battleCtx->battleMons[battler].curHP) {
                if (battleCtx->battleMons[battler].moveEffectsData.healBlockTurns) {
                    battleCtx->msgBattlerTemp = battler;
                    LOAD_SUBSEQ(subscript_cannot_heal);
                } else {
                    battleCtx->msgBattlerTemp = battler;
                    battleCtx->msgMoveTemp = MOVE_AQUA_RING;
                    battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, 16);
                    LOAD_SUBSEQ(subscript_aqua_ring_heal);
                }

                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;
        case MON_COND_CHECK_STATE_ABILITY:
            if (BattleSystem_TriggerTurnEndAbility(battleSys, battleCtx, battler) == TRUE) {
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_USE_ITEM:
            if (BattleSystem_TriggerHeldItem(battleSys, battleCtx, battler) == TRUE) {
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_LEFTOVERS:
            if (BattleSystem_TriggerLeftovers(battleSys, battleCtx, battler) == TRUE) {
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_LEECH_SEED:
            if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_LEECH_SEED)
                && battleCtx->battleMons[battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_LEECH_SEED_RECIPIENT].curHP
                && Battler_Ability(battleCtx, battler) != ABILITY_MAGIC_GUARD
                && battleCtx->battleMons[battler].curHP) {
                battleCtx->msgAttacker = battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_LEECH_SEED_RECIPIENT;
                battleCtx->msgDefender = battler;

                PrepareSubroutineSequence(battleCtx, subscript_leech_seed_effect);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_POISON:
            if ((battleCtx->battleMons[battler].status & MON_CONDITION_POISON) && battleCtx->battleMons[battler].curHP) {
                battleCtx->msgBattlerTemp = battler;
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1, 8);

                PrepareSubroutineSequence(battleCtx, subscript_poison_damage);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_TOXIC:
            if ((battleCtx->battleMons[battler].status & MON_CONDITION_TOXIC) && battleCtx->battleMons[battler].curHP) {
                battleCtx->msgBattlerTemp = battler;
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP, 16);

                // If we're not already at the maximum Toxic stage, increment the counter
                if ((battleCtx->battleMons[battler].status & MON_CONDITION_TOXIC_COUNTER) != MON_CONDITION_TOXIC_COUNTER) {
                    battleCtx->battleMons[battler].status += MON_CONDITION_TOXIC_COUNT_INC;
                }

                battleCtx->hpCalcTemp *= ((battleCtx->battleMons[battler].status & MON_CONDITION_TOXIC_COUNTER) >> 8);
                battleCtx->hpCalcTemp *= -1;

                PrepareSubroutineSequence(battleCtx, subscript_poison_damage);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_BURN:
            if ((battleCtx->battleMons[battler].status & MON_CONDITION_BURN) && battleCtx->battleMons[battler].curHP) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_burn_damage);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_NIGHTMARE:
            if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_NIGHTMARE) && battleCtx->battleMons[battler].curHP) {
                if ((battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP)
                    || Battler_Ability(battleCtx, battler) == ABILITY_COMATOSE) { // Sovereign (item 11): as if asleep
                    battleCtx->msgBattlerTemp = battler;

                    PrepareSubroutineSequence(battleCtx, subscript_nightmare_effect);
                    state = STATE_BREAK_OUT;
                } else {
                    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_NIGHTMARE;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_CURSE:
            if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CURSE) && battleCtx->battleMons[battler].curHP) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_curse_damage);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_BIND:
            if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_BIND) && battleCtx->battleMons[battler].curHP) {
                battleCtx->battleMons[battler].statusVolatile -= (1 << VOLATILE_CONDITION_BIND_SHIFT);

                if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_BIND) {
                    // Sovereign (item 11): twice as much if the Pokemon that bound it holds a Binding Band.
                    int binder = battleCtx->battleMons[battler].moveEffectsData.bindTarget;
                    battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1,
                        Battler_HeldItem(battleCtx, binder) == ITEM_BINDING_BAND ? 8 : 16);
                    LOAD_SUBSEQ(subscript_bind_effect);
                } else {
                    LOAD_SUBSEQ(subscript_bind_end);
                }

                battleCtx->msgMoveTemp = battleCtx->battleMons[battler].moveEffectsData.bindingMove;
                battleCtx->msgBattlerTemp = battler;
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_SOVEREIGN_SALT_CURE: // Sovereign (item 11): 1/16 of the max HP, 1/8 for Water and Steel (Champions)
            if ((battleCtx->sovereignSaltCure & FlagIndex(battler))
                && battleCtx->battleMons[battler].curHP
                && Battler_Ability(battleCtx, battler) != ABILITY_MAGIC_GUARD) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1,
                    (MON_HAS_TYPE(battler, TYPE_WATER) || MON_HAS_TYPE(battler, TYPE_STEEL)) ? 8 : 16);
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_sovereign_salt_cure_damage);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_SOVEREIGN_SYRUP_BOMB: // Sovereign (item 11): Speed -1, while the Syrup Bomb's user stays in
            if (battleCtx->sovereignSyrupBomb[battler] && battleCtx->battleMons[battler].curHP) {
                int source = battleCtx->sovereignSyrupBombSource[battler];

                if (battleCtx->battleMons[source].curHP == 0
                    || battleCtx->selectedPartySlot[source] != battleCtx->sovereignSyrupBombSourceSlot[battler]) {
                    battleCtx->sovereignSyrupBomb[battler] = 0;
                } else {
                    battleCtx->sovereignSyrupBomb[battler]--;
                    battleCtx->attacker = source; // the drop's source, for Mirror Armor
                    battleCtx->sideEffectMon = battler;
                    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_SPEED_DOWN_1_STAGE;
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;

                    PrepareSubroutineSequence(battleCtx, subscript_sovereign_syrup_bomb_drop);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_SOVEREIGN_OCTOLOCK: // Sovereign (item 11): Defense and Sp. Def -1, while the Octolock's user stays in
            if (battleCtx->sovereignOctolock[battler] && battleCtx->battleMons[battler].curHP) {
                int source = battleCtx->sovereignOctolockSource[battler];

                if (battleCtx->battleMons[source].curHP == 0
                    || battleCtx->selectedPartySlot[source] != battleCtx->sovereignOctolockSourceSlot[battler]) {
                    battleCtx->sovereignOctolock[battler] = 0;
                } else {
                    battleCtx->attacker = source; // the drops' source, for Clear Body and Mirror Armor
                    battleCtx->sideEffectMon = battler;
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;

                    PrepareSubroutineSequence(battleCtx, subscript_sovereign_octolock_drop);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_BAD_DREAMS:
            battleCtx->scriptTemp = BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE_FLAG, battler, ABILITY_BAD_DREAMS);

            if (((battleCtx->battleMons[battler].status & MON_CONDITION_SLEEP)
                    || Battler_Ability(battleCtx, battler) == ABILITY_COMATOSE) // Sovereign (item 11): as if asleep
                && Battler_Ability(battleCtx, battler) != ABILITY_MAGIC_GUARD
                && battleCtx->battleMons[battler].curHP
                && battleCtx->scriptTemp) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battler].maxHP * -1, 8);

                LOAD_SUBSEQ(subscript_bad_dreams);
                battleCtx->battleStatusMask |= SYSCTL_SKIP_SPRITE_BLINK;
                battleCtx->msgBattlerTemp = battler;
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_UPROAR:
            if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_UPROAR) {
                u8 j;
                for (j = 0; j < maxBattlers; j++) {
                    if ((battleCtx->battleMons[j].status & MON_CONDITION_SLEEP)
                        && battleCtx->battleMons[j].curHP
                        && Battler_Ability(battleCtx, j) != ABILITY_SOUNDPROOF) {
                        battleCtx->msgBattlerTemp = j;
                        PrepareSubroutineSequence(battleCtx, subscript_wake_up);
                        break;
                    }
                }

                if (j != maxBattlers) {
                    state = STATE_DONE;
                    break;
                }

                battleCtx->battleMons[battler].statusVolatile -= (1 << VOLATILE_CONDITION_UPROAR_SHIFT);

                if (BattleContext_MoveFailed(battleCtx, battler)) {
                    i = subscript_uproar_end;
                    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_UPROAR;
                    battleCtx->fieldConditionsMask &= ((FlagIndex(battler) << FIELD_CONDITION_UPROAR_SHIFT) ^ 0xFFFFFFFF);
                } else if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_UPROAR) {
                    i = subscript_uproar_continues;
                } else {
                    i = subscript_uproar_end;
                    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_UPROAR;
                    battleCtx->fieldConditionsMask &= ((FlagIndex(battler) << FIELD_CONDITION_UPROAR_SHIFT) ^ 0xFFFFFFFF);
                }

                battleCtx->msgBattlerTemp = battler;
                PrepareSubroutineSequence(battleCtx, i);
                state = STATE_BREAK_OUT;
            }

            if (state != STATE_DONE) {
                battleCtx->monConditionCheckState++;
            }
            break;

        case MON_COND_CHECK_STATE_THRASH:
            if (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_THRASH) {
                battleCtx->battleMons[battler].statusVolatile -= (1 << VOLATILE_CONDITION_THRASH_SHIFT);

                if (BattleContext_MoveFailed(battleCtx, battler)) {
                    battleCtx->battleMons[battler].statusVolatile &= ~VOLATILE_CONDITION_THRASH;
                } else if ((battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_THRASH) == FALSE
                    && (battleCtx->battleMons[battler].statusVolatile & VOLATILE_CONDITION_CONFUSION) == FALSE) {
                    battleCtx->sideEffectMon = battler;

                    PrepareSubroutineSequence(battleCtx, subscript_thrash_end);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_DISABLE:
            if (battleCtx->battleMons[battler].moveEffectsData.disabledMove) {
                for (i = 0; i < MAX_BATTLERS; i++) {
                    if (battleCtx->battleMons[battler].moveEffectsData.disabledMove == battleCtx->battleMons[battler].moves[i]) {
                        break;
                    }
                }

                if (i == MAX_BATTLERS) {
                    battleCtx->battleMons[battler].moveEffectsData.disabledTurns = 0;
                }

                if (battleCtx->battleMons[battler].moveEffectsData.disabledTurns) {
                    battleCtx->battleMons[battler].moveEffectsData.disabledTurns--;
                } else {
                    battleCtx->battleMons[battler].moveEffectsData.disabledMove = 0;
                    battleCtx->msgBattlerTemp = battler;

                    PrepareSubroutineSequence(battleCtx, subscript_disable_end);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_ENCORE:
            if (battleCtx->battleMons[battler].moveEffectsData.encoredMove) {
                for (i = 0; i < MAX_BATTLERS; i++) {
                    if (battleCtx->battleMons[battler].moveEffectsData.encoredMove == battleCtx->battleMons[battler].moves[i]) {
                        break;
                    }
                }

                // this chain is kind of ugly, but it does not match unless it is structured this way
                if (i == MAX_BATTLERS || (i != MAX_BATTLERS && battleCtx->battleMons[battler].ppCur[i] == 0)) {
                    battleCtx->battleMons[battler].moveEffectsData.encoredTurns = 0;
                }

                if (battleCtx->battleMons[battler].moveEffectsData.encoredTurns) {
                    battleCtx->battleMons[battler].moveEffectsData.encoredTurns--;
                } else {
                    battleCtx->battleMons[battler].moveEffectsData.encoredMove = 0;
                    battleCtx->msgBattlerTemp = battler;

                    PrepareSubroutineSequence(battleCtx, subscript_encore_end);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_LOCK_ON:
            if (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_LOCK_ON) {
                battleCtx->battleMons[battler].moveEffectsMask -= (1 << MOVE_EFFECT_LOCK_ON_SHIFT);
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_CHARGE:
            if (battleCtx->battleMons[battler].moveEffectsData.chargedTurns
                && --battleCtx->battleMons[battler].moveEffectsData.chargedTurns == 0) {
                battleCtx->battleMons[battler].moveEffectsMask &= ~MOVE_EFFECT_CHARGE;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_TAUNT:
            if (battleCtx->battleMons[battler].moveEffectsData.tauntedTurns
                && --battleCtx->battleMons[battler].moveEffectsData.tauntedTurns == 0) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_taunt_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_MAGNET_RISE:
            if (battleCtx->battleMons[battler].moveEffectsData.magnetRiseTurns
                && --battleCtx->battleMons[battler].moveEffectsData.magnetRiseTurns == 0) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_magnet_rise_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_SOVEREIGN_TELEKINESIS: // Sovereign (item 11)
            if (battleCtx->sovereignTelekinesis[battler] && --battleCtx->sovereignTelekinesis[battler] == 0) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_sovereign_telekinesis_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_HEAL_BLOCK:
            if (battleCtx->battleMons[battler].moveEffectsData.healBlockTurns
                && --battleCtx->battleMons[battler].moveEffectsData.healBlockTurns == 0) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_heal_block_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_EMBARGO:
            if (battleCtx->battleMons[battler].moveEffectsData.embargoTurns
                && --battleCtx->battleMons[battler].moveEffectsData.embargoTurns == 0) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, subscript_embargo_end);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_YAWN:
            if (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_YAWN) {
                battleCtx->battleMons[battler].moveEffectsMask -= (1 << MOVE_EFFECT_YAWN_SHIFT);

                if ((battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_YAWN) == FALSE) {
                    battleCtx->sideEffectMon = battler;
                    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_MOVE_EFFECT;

                    PrepareSubroutineSequence(battleCtx, subscript_fall_asleep);
                    state = STATE_BREAK_OUT;
                }
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_ITEM_CONDITION:
            int nextSeq;
            if (BattleSystem_TriggerHeldItemOnStatus(battleSys, battleCtx, battler, &nextSeq) == TRUE) {
                battleCtx->msgBattlerTemp = battler;

                PrepareSubroutineSequence(battleCtx, nextSeq);
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_STATE_ITEM_DETRIMENTAL_EFFECT:
            if (BattleSystem_TriggerDetrimentalHeldItem(battleSys, battleCtx, battler) == TRUE) {
                state = STATE_BREAK_OUT;
            }

            battleCtx->monConditionCheckState++;
            break;

        case MON_COND_CHECK_END:
            battleCtx->monConditionCheckState = MON_COND_CHECK_START;
            battleCtx->monConditionCheckTemp++;
            break;
        }

        if (state) {
            BattleController_EmitClearMessageBox(battleSys);
            return;
        }
    }

    battleCtx->monConditionCheckState = MON_COND_CHECK_START;
    battleCtx->monConditionCheckTemp = 0;
    battleCtx->command = BATTLE_CONTROL_CHECK_SIDE_CONDITIONS;
}

enum SideCondCheckState {
    SIDE_COND_CHECK_START = 0,

    SIDE_COND_CHECK_STATE_FUTURE_SIGHT = SIDE_COND_CHECK_START,
    SIDE_COND_CHECK_STATE_PERISH_SONG,
    SIDE_COND_CHECK_STATE_TRICK_ROOM,

    SIDE_COND_CHECK_END
};

static void BattleControllerPlayer_CheckSideConditions(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if (BattleControllerPlayer_AnyFainted(battleCtx, battleCtx->command, battleCtx->command, 1) == TRUE) {
        return;
    }

    BattleController_EmitClearMessageBox(battleSys);

    int battler;
    switch (battleCtx->sideConditionCheckState) {
    case SIDE_COND_CHECK_STATE_FUTURE_SIGHT:
        while (battleCtx->sideConditionCheckTemp < maxBattlers) {
            battler = battleCtx->monSpeedOrder[battleCtx->sideConditionCheckTemp];
            if (battleCtx->battlersSwitchingMask & FlagIndex(battler)) {
                battleCtx->sideConditionCheckTemp++;
                continue;
            }

            battleCtx->sideConditionCheckTemp++;
            if (battleCtx->fieldConditions.futureSightTurns[battler]
                && --battleCtx->fieldConditions.futureSightTurns[battler] == FALSE
                && battleCtx->battleMons[battler].curHP) {
                battleCtx->sideConditionsMask[BattleSystem_GetBattlerSide(battleSys, battler)] &= ~SIDE_CONDITION_FUTURE_SIGHT;

                battleCtx->msgBuffer.id = 475;
                battleCtx->msgBuffer.tags = TAG_NICKNAME_MOVE;
                battleCtx->msgBuffer.params[0] = BattleSystem_NicknameTag(battleCtx, battler);
                battleCtx->msgBuffer.params[1] = battleCtx->fieldConditions.futureSightMove[battler];

                battleCtx->msgBattlerTemp = battler;
                battleCtx->msgAttacker = battleCtx->fieldConditions.futureSightAttacker[battler];
                battleCtx->msgMoveTemp = battleCtx->fieldConditions.futureSightMove[battler];
                battleCtx->hpCalcTemp = battleCtx->fieldConditions.futureSightDamage[battler];

                PrepareSubroutineSequence(battleCtx, subscript_future_sight_damage);
                return;
            }
        }

        battleCtx->sideConditionCheckState++;
        battleCtx->sideConditionCheckTemp = 0;
        // fall-through

    case SIDE_COND_CHECK_STATE_PERISH_SONG:
        while (battleCtx->sideConditionCheckTemp < maxBattlers) {
            battler = battleCtx->monSpeedOrder[battleCtx->sideConditionCheckTemp];
            if (battleCtx->battlersSwitchingMask & FlagIndex(battler)) {
                battleCtx->sideConditionCheckTemp++;
                continue;
            }

            battleCtx->sideConditionCheckTemp++;
            if (battleCtx->battleMons[battler].moveEffectsMask & MOVE_EFFECT_PERISH_SONG) {
                if (battleCtx->battleMons[battler].moveEffectsData.perishSongTurns == 0) {
                    battleCtx->battleMons[battler].moveEffectsMask &= ~MOVE_EFFECT_PERISH_SONG;

                    battleCtx->msgTemp = battleCtx->battleMons[battler].moveEffectsData.perishSongTurns;
                    battleCtx->hpCalcTemp = battleCtx->battleMons[battler].curHP * -1;
                    battleCtx->battleStatusMask |= SYSCTL_SKIP_SPRITE_BLINK;
                } else {
                    battleCtx->msgTemp = battleCtx->battleMons[battler].moveEffectsData.perishSongTurns;
                    battleCtx->battleMons[battler].moveEffectsData.perishSongTurns--;
                }

                battleCtx->msgBattlerTemp = battler;
                PrepareSubroutineSequence(battleCtx, subscript_continue_perish_song);
                return;
            }
        }

        battleCtx->sideConditionCheckState++;
        battleCtx->sideConditionCheckTemp = 0;
        // fall-through

    case SIDE_COND_CHECK_STATE_TRICK_ROOM:
        if (battleCtx->fieldConditionsMask & FIELD_CONDITION_TRICK_ROOM) {
            battleCtx->fieldConditionsMask -= (1 << FIELD_CONDITION_TRICK_ROOM_SHIFT);
            if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_TRICK_ROOM) == FALSE) {
                PrepareSubroutineSequence(battleCtx, subscript_trick_room_end);
                return;
            }
        }

        battleCtx->sideConditionCheckState++;
        battleCtx->sideConditionCheckTemp = 0;
        break;

    default:
        break;
    }

    battleCtx->sideConditionCheckState = SIDE_COND_CHECK_START;
    battleCtx->sideConditionCheckTemp = 0;
    battleCtx->command = BATTLE_CONTROL_TURN_END;
}

static void BattleControllerPlayer_TurnEnd(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleControllerPlayer_AnyExpPayout(battleCtx, battleCtx->command, battleCtx->command) == TRUE
        || BattleControllerPlayer_CheckBattleOver(battleSys, battleCtx) == TRUE) {
        return;
    }

    // Sovereign (item 11): Emergency Exit and Wimp Out after the end-of-turn damage took the holder's HP above half
    // (weather, poison, a burn, Leech Seed, ...), fastest first, before the fainted are replaced.
    for (int i = 0; i < BattleSystem_GetMaxBattlers(battleSys); i++) {
        int battler = battleCtx->monSpeedOrder[i];

        if (Sovereign_EmergencyExitDue(battleCtx, battler, battleCtx->sovereignHPBeforeTurnEnd[battler])) {
            battleCtx->sovereignHPBeforeTurnEnd[battler] = 0;
            battleCtx->switchedMon = battler;
            LOAD_SUBSEQ(subscript_sovereign_emergency_exit);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return;
        }
    }

    if (BattleControllerPlayer_ReplaceFainted(battleSys, battleCtx) == TRUE) {
        return;
    }

    battleCtx->totalTurns++;
    battleCtx->meFirstTurnOrder++;
    battleCtx->sovereignInstructed = 0; // Sovereign (item 11): no extra action outlasts its turn
    battleCtx->sovereignExtraActor = 0;
    battleCtx->sovereignDancers = 0;
    battleCtx->sovereignDancing = FALSE;

    BattleContext_Init(battleCtx);
    BattleSystem_SetupNextTurn(battleSys, battleCtx);

    battleCtx->command = BATTLE_CONTROL_TRAINER_MESSAGE;
}

static void BattleControllerPlayer_FightCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL randomizeTarget = FALSE;
    battleCtx->attacker = battleCtx->battlerActionOrder[battleCtx->turnOrderCounter];

    // Sovereign (item 11): a Pokemon carried up by Sky Drop can't move; its move is lost without a word or any PP
    // (Showdown).
    if (Sovereign_SkyDropHolder(battleCtx, battleCtx->attacker) != BATTLER_NONE) {
        battleCtx->defender = BATTLER_NONE;
        battleCtx->command = BATTLE_CONTROL_MOVE_END;
        return;
    }

    battleCtx->sovereignHPBeforeAction[battleCtx->attacker] = ATTACKING_MON.curHP; // Sovereign (item 11): Emergency Exit

    if (ATTACKER_TURN_FLAGS.struggling) {
        battleCtx->moveTemp = MOVE_STRUGGLE;
        randomizeTarget = TRUE;
    } else if (ATTACKING_MON.moveEffectsData.encoredMove
        && ATTACKING_MON.moveEffectsData.encoredMove == ATTACKING_MON.moves[ATTACKING_MON.moveEffectsData.encoredMoveSlot]) {
        // Attacker is locked into one of its moves by Encore
        battleCtx->moveTemp = ATTACKING_MON.moveEffectsData.encoredMove;
        randomizeTarget = TRUE;
    } else if (ATTACKING_MON.moveEffectsData.encoredMove
        && ATTACKING_MON.moveEffectsData.encoredMove != ATTACKING_MON.moves[ATTACKING_MON.moveEffectsData.encoredMoveSlot]) {
        // Attacker is Encored, but does not actually know the move in the Encored slot. This can
        // happen if the attacker is Encored into something like Metronome. Note that this means
        // that if the attacker is Encored into a Metronome'd move that it knows, it will not be
        // forced to use that move the following turn.
        battleCtx->moveTemp = ATTACKING_MON.moves[ATTACKING_MON.moveEffectsData.encoredMoveSlot];
        ATTACKING_MON.moveEffectsData.encoredMove = MOVE_NONE;
        ATTACKING_MON.moveEffectsData.encoredMoveSlot = 0;
        ATTACKING_MON.moveEffectsData.encoredTurns = 0;
        randomizeTarget = TRUE;
    } else if (Battler_CanPickCommand(battleCtx, battleCtx->attacker) == FALSE) {
        // Relock the attacker into its move. There should be no override here, as the attacker
        // should not have been able to choose any input.
        battleCtx->moveTemp = battleCtx->moveLockedInto[battleCtx->attacker];
    } else if (battleCtx->moveSelected[battleCtx->attacker] != ATTACKING_MON.moves[battleCtx->moveSlot[battleCtx->attacker]]) {
        // If the attacker somehow selected a move that it does not know, prefer the move that's
        // actually in the chosen slot.
        battleCtx->moveTemp = ATTACKING_MON.moves[battleCtx->moveSlot[battleCtx->attacker]];
        randomizeTarget = TRUE;
    } else {
        battleCtx->moveTemp = ATTACKING_MON.moves[battleCtx->moveSlot[battleCtx->attacker]];
    }

    battleCtx->moveCur = battleCtx->moveTemp;
    battleCtx->command = BATTLE_CONTROL_BEFORE_MOVE;
    battleCtx->defender = BattleSystem_Defender(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveTemp, randomizeTarget, 0);

    // Sovereign (item 11): Sky Drop's second turn drops the Pokemon the user carries, if it's still up there.
    if (battleCtx->moveCur == MOVE_SKY_DROP && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED)) {
        battleCtx->defender = Sovereign_SkyDropTarget(battleCtx, battleCtx->attacker);
    }

    BattleController_EmitClearMessageBox(battleSys);
}

static void BattleControllerPlayer_ItemCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    battleCtx->attacker = battleCtx->battlerActionOrder[battleCtx->turnOrderCounter];
    battleCtx->defender = BattleSystem_RandomOpponent(battleSys, battleCtx, battleCtx->attacker);

    BattleItemUse *used = (BattleItemUse *)&battleCtx->battlerActions[battleCtx->attacker][BATTLE_ACTION_TEMP_VALUE];
    int nextSeq;
    if (BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)) {
        switch (battleCtx->aiContext.usedItemType[battleCtx->attacker >> 1]) {
        case ITEM_AI_CATEGORY_FULL_RESTORE:
            nextSeq = subscript_use_full_restore;
            break;

        case ITEM_AI_CATEGORY_RECOVER_HP:
            nextSeq = subscript_use_potion;
            break;

        case ITEM_AI_CATEGORY_RECOVER_STATUS:
            if ((battleCtx->aiContext.usedItemCondition[battleCtx->attacker >> 1] & ITEM_RECOVER_CONFUSION)
                && (battleCtx->aiContext.usedItemCondition[battleCtx->attacker >> 1] & ITEM_RECOVER_FULL)) {
                battleCtx->msgTemp = 6;
            } else {
                battleCtx->msgTemp = LowestBit(battleCtx->aiContext.usedItemCondition[battleCtx->attacker >> 1]);
            }

            nextSeq = subscript_use_status_recovery;
            break;

        case ITEM_AI_CATEGORY_STAT_BOOSTER:
            battleCtx->msgTemp = battleCtx->aiContext.usedItemCondition[battleCtx->attacker >> 1];
            nextSeq = subscript_use_stat_booster;
            break;

        case ITEM_AI_CATEGORY_GUARD_SPEC:
            nextSeq = subscript_use_guard_spec;
            break;
        }

        battleCtx->msgItemTemp = battleCtx->aiContext.usedItem[battleCtx->attacker >> 1];
    } else {
        switch (used->category) {
        case ITEM_BATTLE_CATEGORY_RECOVER_STATUS:
        case ITEM_BATTLE_CATEGORY_RECOVER_HP:
        case ITEM_BATTLE_CATEGORY_BATTLE_ITEMS:
            if (used->item == ITEM_POKE_DOLL || used->item == ITEM_FLUFFY_TAIL) {
                nextSeq = subscript_escape_item;
            } else {
                nextSeq = subscript_battle_item;
            }

            break;

        case ITEM_BATTLE_CATEGORY_POKE_BALLS:
            nextSeq = subscript_throw_pokeball;
            if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_TRAINER) == FALSE
                && (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_CATCH_TUTORIAL) == FALSE) {
                Bag_TryRemoveItem(BattleSystem_GetBag(battleSys), used->item, 1, HEAP_ID_BATTLE);
                Bag_SetLastBattleItemUsed(BattleSystem_GetBagCursor(battleSys), used->item, used->category);
            }

            break;
        }

        battleCtx->msgItemTemp = used->item;
    }

    LOAD_SUBSEQ(nextSeq);
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
    battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
}

static void BattleControllerPlayer_SwitchCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_switch_pokemon);

    battleCtx->attacker = battleCtx->battlerActionOrder[battleCtx->turnOrderCounter];
    battleCtx->switchedMon = battleCtx->attacker;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_CHECK_ANY_FAINTED;
    battleCtx->scriptTemp = 0;
    battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
}

static void BattleControllerPlayer_FleeCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    battleCtx->attacker = battleCtx->battlerActionOrder[battleCtx->turnOrderCounter];

    if (BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)
        && (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_LINK) == FALSE) {
        if (ATTACKING_MON.statusVolatile & (VOLATILE_CONDITION_BIND | VOLATILE_CONDITION_MEAN_LOOK)) {
            LOAD_SUBSEQ(subscript_enemy_escape_failed);
            battleCtx->scriptCursor = 0;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
        } else {
            LOAD_SUBSEQ(subscript_enemy_escape);
            battleCtx->scriptCursor = 0;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_FIGHT_END;
        }
    } else {
        if (Battler_CanEscape(battleSys, battleCtx, battleCtx->attacker)) {
            LOAD_SUBSEQ(subscript_escape);
            battleCtx->scriptCursor = 0;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_FIGHT_END;
        } else {
            LOAD_SUBSEQ(subscript_escape_failed);
            battleCtx->scriptCursor = 0;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
        }
    }
}

static void BattleControllerPlayer_SafariBallCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_throw_safari_ball);

    battleCtx->attacker = BATTLER_US;
    battleCtx->defender = BATTLER_THEM;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
    battleCtx->msgItemTemp = ITEM_SAFARI_BALL;

    int balls = BattleSystem_GetNumSafariBalls(battleSys) - 1;
    BattleSystem_SetNumSafariBalls(battleSys, balls);
    BattleController_EmitRefreshHPGauge(battleSys, battleCtx, BATTLER_US);
}

static void BattleControllerPlayer_SafariBaitCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_safari_throw_bait);

    battleCtx->attacker = BATTLER_US;
    battleCtx->defender = BATTLER_THEM;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
    battleCtx->scriptTemp = BattleSystem_RandNext(battleSys) % 10;

    if (battleCtx->safariCatchStage < SAFARI_STAGE_MAX) {
        battleCtx->safariCatchStage++;
    }

    if (battleCtx->scriptTemp != 0) {
        if (battleCtx->safariEscapeCount < SAFARI_STAGE_MAX) {
            battleCtx->safariEscapeCount++;
        }
    }
}

static void BattleControllerPlayer_SafariRockCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_safari_throw_rock);

    battleCtx->attacker = BATTLER_US;
    battleCtx->defender = BATTLER_THEM;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
    battleCtx->scriptTemp = BattleSystem_RandNext(battleSys) % 10;

    if (battleCtx->safariEscapeCount) {
        battleCtx->safariEscapeCount--;
    }

    if (battleCtx->scriptTemp != 0) {
        battleCtx->msgTemp = 1;

        if (battleCtx->safariCatchStage) {
            battleCtx->safariCatchStage--;
        }
    }
}

static void BattleControllerPlayer_SafariFleeCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_safari_escape);

    battleCtx->attacker = BATTLER_US;
    battleCtx->defender = BATTLER_THEM;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_MOVE_END;
}

enum ObedienceCheckResult {
    OBEY_CHECK_SUCCESS = 0,
    OBEY_CHECK_DO_NOTHING,
    OBEY_CHECK_DIFFERENT_MOVE,
    OBEY_CHECK_HIT_SELF
};

/**
 * @brief Check if the attacking battler obeys its trainer.
 *
 * If the obedience check is failed, then nextSeq will be populated with an
 * interjecting subroutine sequence that should be invoked instead of the
 * move that its trainer chose.
 *
 * @param battleSys
 * @param battleCtx
 * @param[out] nextSeq  A subroutine sequence to override the chosen move
 * @return A value from enum ObedienceCheckResult describing the check result
 */
static int BattleControllerPlayer_CheckObedience(BattleSystem *battleSys, BattleContext *battleCtx, int *nextSeq)
{
    int rand1, rand2; // must be defined up here to match
    u8 maxLevel = 0;
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    TrainerInfo *trInfo = BattleSystem_GetTrainerInfo(battleSys, 0);

    // These separate sentinels do not match if chained into a single sentinel
    if (battleType & BATTLE_TYPE_FRONTIER_LINK) {
        return OBEY_CHECK_SUCCESS;
    }
    if (BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)) {
        return OBEY_CHECK_SUCCESS;
    }
    if ((battleType & BATTLE_TYPE_AI)
        && BattleSystem_GetBattlerType(battleSys, battleCtx->attacker) == BATTLER_TYPE_PLAYER_SIDE_SLOT_2) {
        return OBEY_CHECK_SUCCESS;
    }
    // Sovereign (E10): as in Renegade Platinum, a traded Pokémon always obeys, whatever its level
    return OBEY_CHECK_SUCCESS;
    if (BattleSystem_TrainerIsOT(battleSys, battleCtx) == TRUE) {
        return OBEY_CHECK_SUCCESS;
    }
    if (Battler_CanPickCommand(battleCtx, battleCtx->attacker) == FALSE) {
        return OBEY_CHECK_SUCCESS;
    }
    if (battleCtx->moveCur == MOVE_BIDE && (battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN)) {
        return OBEY_CHECK_SUCCESS;
    }
    if (TrainerInfo_BadgeCount(trInfo) >= 8) {
        return OBEY_CHECK_SUCCESS;
    }

    maxLevel = 10;
    if (TrainerInfo_BadgeCount(trInfo) >= 2) {
        maxLevel = 30;
    }
    if (TrainerInfo_BadgeCount(trInfo) >= 4) {
        maxLevel = 50;
    }
    if (TrainerInfo_BadgeCount(trInfo) >= 6) {
        maxLevel = 70;
    }

    if (ATTACKING_MON.level <= maxLevel) {
        return OBEY_CHECK_SUCCESS;
    }

    rand1 = ((BattleSystem_RandNext(battleSys) & 0xFF) * (ATTACKING_MON.level + maxLevel)) >> 8;
    if (rand1 < maxLevel) {
        return OBEY_CHECK_SUCCESS;
    }

    if (battleCtx->moveCur == MOVE_RAGE) {
        ATTACKING_MON.statusVolatile &= ~VOLATILE_CONDITION_RAGE;
    }

    if ((ATTACKING_MON.status & MON_CONDITION_SLEEP)
        && (battleCtx->moveCur == MOVE_SNORE || battleCtx->moveCur == MOVE_SLEEP_TALK)) {
        *nextSeq = subscript_disobey_while_asleep;
        return OBEY_CHECK_DO_NOTHING;
    }

    rand1 = ((BattleSystem_RandNext(battleSys) & 0xFF) * (ATTACKING_MON.level + maxLevel)) >> 8;
    if (rand1 < maxLevel) {
        rand1 = BattleSystem_CheckInvalidMoves(battleSys, battleCtx, battleCtx->attacker, FlagIndex(ATTACKER_MOVE_SLOT), CHECK_INVALID_ALL);

        if (rand1 == STRUGGLING_ALL) {
            *nextSeq = subscript_disobey_do_nothing;
            return OBEY_CHECK_DO_NOTHING;
        }

        do {
            rand2 = BattleSystem_RandNext(battleSys) & 3;
        } while (rand1 & FlagIndex(rand2));

        ATTACKER_MOVE_SLOT = rand2;
        battleCtx->moveTemp = ATTACKING_MON.moves[ATTACKER_MOVE_SLOT];
        battleCtx->moveCur = battleCtx->moveTemp;
        battleCtx->defender = BattleSystem_Defender(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveTemp, TRUE, 0);

        if (battleCtx->defender == BATTLER_NONE) {
            ATTACKER_ACTION[BATTLE_ACTION_CHOOSE_TARGET] = BattleSystem_RandomOpponent(battleSys, battleCtx, battleCtx->attacker);
        } else {
            ATTACKER_ACTION[BATTLE_ACTION_CHOOSE_TARGET] = battleCtx->defender;
        }

        *nextSeq = subscript_disobey_orders;
        battleCtx->multiHitCheckFlags |= SYSCTL_SKIP_OBEDIENCE_CHECK;
        return OBEY_CHECK_DIFFERENT_MOVE;
    }

    maxLevel = ATTACKING_MON.level - maxLevel;
    rand1 = BattleSystem_RandNext(battleSys) & 0xFF;
    if ((rand1 < maxLevel && (ATTACKING_MON.status & MON_CONDITION_ANY) == FALSE)
        && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_VITAL_SPIRIT
        && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_INSOMNIA
        && Sovereign_VeilHolder(battleSys, battleCtx, BATTLER_NONE, battleCtx->attacker, ABILITY_SWEET_VEIL) == BATTLER_NONE // Sovereign (item 11): its own or its partner's Sweet Veil
        && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_COMATOSE // Sovereign (item 11)
        && (battleCtx->fieldConditionsMask & FIELD_CONDITION_UPROAR) == FALSE) {
        *nextSeq = subscript_disobey_sleep;
        return OBEY_CHECK_DO_NOTHING;
    }

    rand1 -= maxLevel;
    if (rand1 < maxLevel) {
        battleCtx->defender = battleCtx->attacker;
        battleCtx->msgBattlerTemp = battleCtx->defender;

        battleCtx->hpCalcTemp = CALC_SELF_HIT(MOVE_POUND, 40);
        battleCtx->hpCalcTemp = BattleSystem_CalcDamageVariance(battleSys, battleCtx, battleCtx->hpCalcTemp);
        battleCtx->hpCalcTemp *= -1;

        *nextSeq = subscript_disobey_hit_self;
        battleCtx->battleStatusMask |= SYSCTL_CHECK_LOOP_ONLY_ONCE;
        return OBEY_CHECK_HIT_SELF;
    }

    *nextSeq = subscript_disobey_do_nothing;
    return OBEY_CHECK_DO_NOTHING;
}

/**
 * @brief Determine the PP cost for a particular move (depending on its target(s))
 * and decucts that amount from the used move.
 *
 * @param battleSys
 * @param battleCtx
 * @return Always FALSE.
 */
static BOOL BattleControllerPlayer_DecrementPP(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int ppCost = 1;
    if (ATTACKER_SELF_TURN_FLAGS.skipPressureCheck == FALSE && battleCtx->defender != BATTLER_NONE) {
        if (battleCtx->moveTemp == MOVE_IMPRISON) {
            ppCost += BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE, battleCtx->attacker, ABILITY_PRESSURE);
        } else {
            switch (battleCtx->aiContext.moveTable[battleCtx->moveTemp].range) {
            case RANGE_ALL_ADJACENT:
            case RANGE_FIELD:
                // Number of mons on the field with Pressure
                ppCost += BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_EXCEPT_ME, battleCtx->attacker, ABILITY_PRESSURE);
                break;

            case RANGE_ADJACENT_OPPONENTS:
            case RANGE_OPPONENT_SIDE:
                // Number of mons on the enemy side with Pressure
                ppCost += BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_THEIR_SIDE, battleCtx->attacker, ABILITY_PRESSURE);
                break;

            case RANGE_USER_SIDE:
            case RANGE_USER:
            case RANGE_USER_OR_ALLY:
            case RANGE_ALLY:
                break;

            default:
                if (battleCtx->attacker != battleCtx->defender
                    && Battler_Ability(battleCtx, battleCtx->defender) == ABILITY_PRESSURE) {
                    ppCost++;
                }

                break;
            }
        }
    }

#ifdef SOVEREIGN_TEST
    // Test build only: in god mode the player's moves cost no PP, so a long run of battles (the Battle Marathon) can't
    // leave a test lead with no move to use (include/sovereign_test.h).
    if (gSovereignTestGodMode && (battleCtx->attacker & 1) == BATTLE_SIDE_PLAYER) {
        ppCost = 0;
    }
#endif

    int moveSlot = Battler_SlotForMove(&ATTACKING_MON, battleCtx->moveTemp);
    if (ATTACKER_TURN_FLAGS.ppDecremented == FALSE && ATTACKER_TURN_FLAGS.struggling == FALSE) {
        ATTACKER_TURN_FLAGS.ppDecremented = 1;

        if (ATTACKING_MON.ppCur[moveSlot] && moveSlot < LEARNED_MOVES_MAX) {
            if (ATTACKING_MON.ppCur[moveSlot] > ppCost) {
                ATTACKING_MON.ppCur[moveSlot] -= ppCost;
            } else {
                ATTACKING_MON.ppCur[moveSlot] = 0;
            }

            BattleMon_CopyToParty(battleSys, battleCtx, battleCtx->attacker);
        } else {
            battleCtx->moveStatusFlags |= MOVE_STATUS_NO_PP;
        }
    } else if (ATTACKING_MON.ppCur[moveSlot] == 0
        && (battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN) == FALSE
        && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED) == FALSE
        && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_THRASH) == FALSE
        && MON_IS_UPROARING(battleCtx->attacker) == FALSE
        && moveSlot < LEARNED_MOVES_MAX) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_NO_PP;
    }

    return FALSE;
}

/**
 * @brief Determine if the currently-used move still has a valid target.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the move should now fail due to having no target; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_HasNoTarget(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    BOOL solarMove = FALSE;

    if (NO_TARGET) {
        LOAD_SUBSEQ(subscript_no_target);
        battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        result = TRUE;
    }

    // Sovereign (item 11): the weather as it acts on the user's moves (Utility Umbrella, Mega Sol)
    if (CURRENT_MOVE_DATA.effect == BATTLE_EFFECT_SKIP_CHARGE_TURN_IN_SUN
        && (Sovereign_MoveWeather(battleSys, battleCtx, battleCtx->attacker) & FIELD_CONDITION_SUNNY)) {
        solarMove = TRUE;
    }

    // Don't alter the target for charge-turn moves that are just charging up this turn
    if (battleCtx->defender == BATTLER_NONE
        && Move_IsMultiTurn(battleCtx, battleCtx->moveCur) == TRUE
        && result == FALSE
        && solarMove == FALSE
        && Battler_HeldItemEffect(battleCtx, battleCtx->attacker) != HOLD_EFFECT_CHARGE_SKIP
        && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED) == FALSE) {
        battleCtx->defender = battleCtx->attacker;
    }

    return result;
}

/**
 * @brief Invoke the type-effectiveness chart to determine the current move's
 * effectiveness on its target.
 *
 * Note: Levitate is included in the type-effectiveness chart as a functional
 * immunity to Ground-type attacks.
 *
 * @param battleSys
 * @param battleCtx
 * @return Always 0.
 */
static int BattleControllerPlayer_CheckTypeChart(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if ((CURRENT_MOVE_DATA.range != RANGE_USER
            && CURRENT_MOVE_DATA.range != RANGE_USER_SIDE
            && CURRENT_MOVE_DATA.power
            && (battleCtx->battleStatusMask & SYSCTL_IGNORE_IMMUNITIES) == FALSE
            && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE)
        || battleCtx->moveCur == MOVE_THUNDER_WAVE) {
        battleCtx->damage = BattleSystem_ApplyTypeChart(battleSys,
            battleCtx,
            battleCtx->moveCur,
            battleCtx->moveType,
            battleCtx->attacker,
            battleCtx->defender,
            battleCtx->damage,
            &battleCtx->moveStatusFlags);

        if (battleCtx->moveStatusFlags & MOVE_STATUS_INEFFECTIVE) {
            battleCtx->moveFailFlags[battleCtx->attacker].noEffect = TRUE;
        }
    }

    return 0;
}

enum CheckStatusState {
    CHECK_STATUS_START = 0,

    CHECK_STATUS_STATE_SLEEP,
    CHECK_STATUS_STATE_FREEZE,
    CHECK_STATUS_STATE_TRUANT,
    CHECK_STATUS_STATE_RECHARGING,
    CHECK_STATUS_STATE_FLINCH,
    CHECK_STATUS_STATE_DISABLE,
    CHECK_STATUS_STATE_TAUNT,
    CHECK_STATUS_STATE_IMPRISON,
    CHECK_STATUS_STATE_GRAVITY,
    CHECK_STATUS_STATE_HEAL_BLOCK,
    CHECK_STATUS_STATE_SOVEREIGN_THROAT_CHOP,
    CHECK_STATUS_STATE_CONFUSION,
    CHECK_STATUS_STATE_PARALYSIS,
    CHECK_STATUS_STATE_ATTRACT,
    CHECK_STATUS_STATE_BIDE,
    CHECK_STATUS_STATE_SELF_THAW,

    CHECK_STATUS_END,
};

enum CheckStatusAction {
    CHECK_STATUS_LOOP_BACK = 0,
    CHECK_STATUS_DISRUPT_MOVE, // wholly disrupt the move; attacker does not get a turn
    CHECK_STATUS_GO_TO_SCRIPT, // execute a given script, then proceed with the chosen move
    CHECK_STATUS_DONE,
};

/**
 * @brief Determine if status should disrupt the attacker's current turn.
 *
 * "Disruption" is defined as the attacker functionally wasting a turn, e.g.,
 * continuing to sleep, or being fully paralyzed. Some status conditions have a
 * "partial disruption," where an interjecting subroutine will be run before
 * the attacker executes its move, e.g. confusion or infatuation.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if there is a disruption effect to apply or an interjecting
 * script to invoke before the attacker executes its move for turn.
 */
static BOOL BattleControllerPlayer_CheckStatusDisruption(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int moveEffect = battleCtx->aiContext.moveTable[battleCtx->moveCur].effect;
    int result = CHECK_STATUS_LOOP_BACK;

    do {
        switch (battleCtx->statusCheckState) {
        case CHECK_STATUS_START:
            ATTACKING_MON.statusVolatile &= ~VOLATILE_CONDITION_DESTINY_BOND;
            ATTACKING_MON.moveEffectsMask &= ~MOVE_EFFECT_GRUDGE;
            battleCtx->sovereignGlaiveRush &= ~FlagIndex(battleCtx->attacker); // Sovereign (item 11): its next move
            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_SLEEP:
            if (ATTACKING_MON.status & MON_CONDITION_SLEEP) {
                if ((battleCtx->fieldConditionsMask & FIELD_CONDITION_UPROAR)
                    && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_SOUNDPROOF) {
                    battleCtx->msgBattlerTemp = battleCtx->attacker;

                    LOAD_SUBSEQ(subscript_wake_up);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                    result = CHECK_STATUS_GO_TO_SCRIPT;
                } else if ((battleCtx->moveCur != MOVE_SLEEP_TALK && battleCtx->moveTemp == MOVE_SLEEP_TALK) == FALSE) {
                    int sleepDec;
                    if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_EARLY_BIRD) {
                        sleepDec = 2;
                    } else {
                        sleepDec = 1;
                    }

                    if ((ATTACKING_MON.status & MON_CONDITION_SLEEP) < sleepDec) {
                        ATTACKING_MON.status &= ~MON_CONDITION_SLEEP;
                    } else {
                        ATTACKING_MON.status -= sleepDec;
                    }

                    if (ATTACKING_MON.status & MON_CONDITION_SLEEP) {
                        if (battleCtx->moveCur != MOVE_SNORE && battleCtx->moveTemp != MOVE_SLEEP_TALK) {
                            LOAD_SUBSEQ(subscript_sleeping);

                            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                            battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                            result = CHECK_STATUS_GO_TO_SCRIPT;
                        }
                    } else {
                        battleCtx->msgBattlerTemp = battleCtx->attacker;

                        LOAD_SUBSEQ(subscript_wake_up);
                        battleCtx->commandNext = battleCtx->command;
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                        result = CHECK_STATUS_GO_TO_SCRIPT;
                    }
                }
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_FREEZE:
            if (ATTACKING_MON.status & MON_CONDITION_FREEZE) {
                // Sovereign: Pokémon Champions thaw rule. 1/4 chance on each move attempt (Gen IV-IX: 1/5, no limit),
                // and a sure thaw on the third attempt, so a Pokémon loses at most two turns to freeze.
                if (ATTACKING_MON.freezeTurns < 2 && BattleSystem_RandNext(battleSys) % 4 != 0) {
                    ATTACKING_MON.freezeTurns++;

                    if (Sovereign_MoveThawsUser(battleCtx->moveCur, moveEffect) == FALSE) {
                        LOAD_SUBSEQ(subscript_frozen);
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                        battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                        result = CHECK_STATUS_DISRUPT_MOVE;
                    }
                } else {
                    battleCtx->msgBattlerTemp = battleCtx->attacker;
                    ATTACKING_MON.freezeTurns = 0;

                    LOAD_SUBSEQ(subscript_thaw_out);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                    result = CHECK_STATUS_GO_TO_SCRIPT;
                }
            } else {
                ATTACKING_MON.freezeTurns = 0;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_TRUANT:
            if (Battler_CheckTruant(battleCtx, battleCtx->attacker) == TRUE) {
                LOAD_SUBSEQ(subscript_loafing_around);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_RECHARGING:
            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_RECHARGING) {
                ATTACKING_MON.statusVolatile &= ~VOLATILE_CONDITION_RECHARGING;

                LOAD_SUBSEQ(subscript_recharging);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_FLINCH:
            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_FLINCH) {
                ATTACKING_MON.statusVolatile &= ~VOLATILE_CONDITION_FLINCH;
                battleCtx->moveFailFlags[battleCtx->attacker].flinched = TRUE;

                LOAD_SUBSEQ(subscript_flinched);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_DISABLE:
            if (ATTACKING_MON.moveEffectsData.disabledMove == battleCtx->moveTemp) {
                battleCtx->moveFailFlags[battleCtx->attacker].disabled = TRUE;

                LOAD_SUBSEQ(subscript_move_is_disabled);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_TAUNT:
            if (ATTACKING_MON.moveEffectsData.tauntedTurns
                && battleCtx->aiContext.moveTable[battleCtx->moveCur].power == 0) {
                battleCtx->moveFailFlags[battleCtx->attacker].taunted = TRUE;

                LOAD_SUBSEQ(subscript_move_fail_taunted);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_IMPRISON:
            if (Move_Imprisoned(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
                battleCtx->moveFailFlags[battleCtx->attacker].imprisoned = TRUE;

                LOAD_SUBSEQ(subscript_move_is_imprisoned);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_GRAVITY:
            if (Move_FailsInHighGravity(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
                battleCtx->moveFailFlags[battleCtx->attacker].gravity = TRUE;

                LOAD_SUBSEQ(subscript_move_fail_gravity);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_HEAL_BLOCK:
            if (Move_HealBlocked(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveCur)) {
                battleCtx->moveFailFlags[battleCtx->attacker].healBlocked = TRUE;

                LOAD_SUBSEQ(subscript_move_is_heal_blocked);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_SOVEREIGN_THROAT_CHOP:
            // Sovereign (item 11): Throat Chop stops sound moves chosen before it hit.
            if (battleCtx->sovereignThroatChop[battleCtx->attacker] && Move_IsSound(battleCtx->moveCur)) {
                battleCtx->msgMoveTemp = MOVE_THROAT_CHOP;
                LOAD_SUBSEQ(subscript_sovereign_move_blocked);
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                result = CHECK_STATUS_DISRUPT_MOVE;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_CONFUSION:
            battleCtx->statusCheckState++;

            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                ATTACKING_MON.statusVolatile -= (1 << VOLATILE_CONDITION_CONFUSION_SHIFT);

                if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_CONFUSION) {
                    // Sovereign: Gen VII+ / Champions self-hit chance, 33% (Gen IV: 50%).
                    if (BattleSystem_RandNext(battleSys) % 100 >= 33) {
                        LOAD_SUBSEQ(subscript_confused);
                        battleCtx->commandNext = battleCtx->command;
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                        result = CHECK_STATUS_GO_TO_SCRIPT;
                    } else {
                        battleCtx->moveFailFlags[battleCtx->attacker].confused = TRUE;
                        battleCtx->defender = battleCtx->attacker;
                        battleCtx->msgBattlerTemp = battleCtx->defender;

                        battleCtx->hpCalcTemp = CALC_SELF_HIT(MOVE_STRUGGLE, 40);
                        battleCtx->hpCalcTemp = BattleSystem_CalcDamageVariance(battleSys, battleCtx, battleCtx->hpCalcTemp);
                        battleCtx->hpCalcTemp *= -1;

                        // Sovereign (FM): Disguise takes the hit, as in the Gen VII+ games, and costs 1/8 max HP.
                        int bustedForm = Pokemon_SovereignDisguiseBustedForm(ATTACKING_MON.species, ATTACKING_MON.formNum);
                        if (bustedForm >= 0
                            && Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_DISGUISE
                            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
                            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->attacker, bustedForm);
                            battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP, 8) * -1;
                            LOAD_SUBSEQ(subscript_sovereign_disguise_confusion);
                        } else {
                            LOAD_SUBSEQ(subscript_hurt_self_in_confusion);
                        }
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                        battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED;

                        result = CHECK_STATUS_DISRUPT_MOVE;
                    }
                } else {
                    LOAD_SUBSEQ(subscript_snap_out_of_confusion);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    result = CHECK_STATUS_GO_TO_SCRIPT;
                }
            }
            break;

        case CHECK_STATUS_STATE_PARALYSIS:
            if ((ATTACKING_MON.status & MON_CONDITION_PARALYSIS)
                && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD) {
                // Sovereign: Pokémon Champions full-paralysis chance, 1/8 (Gen IV-IX: 1/4).
                if (BattleSystem_RandNext(battleSys) % 8 == 0) {
                    battleCtx->moveFailFlags[battleCtx->attacker].paralyzed = TRUE;

                    LOAD_SUBSEQ(subscript_fully_paralyzed);
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                    battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                    result = CHECK_STATUS_DISRUPT_MOVE;
                }
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_ATTRACT:
            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_ATTRACT) {
                battleCtx->msgBattlerTemp = LowestBit(
                    (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_ATTRACT) >> VOLATILE_CONDITION_ATTRACT_SHIFT);

                if (BattleSystem_RandNext(battleSys) & 1) {
                    LOAD_SUBSEQ(subscript_infatuated);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    result = CHECK_STATUS_GO_TO_SCRIPT;
                } else {
                    battleCtx->moveFailFlags[battleCtx->attacker].infatuated = TRUE;

                    LOAD_SUBSEQ(subscript_immobilized_by_love);
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                    battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;

                    result = CHECK_STATUS_DISRUPT_MOVE;
                }
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_STATE_BIDE:
            battleCtx->statusCheckState++;

            if (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_BIDE) {
                ATTACKING_MON.statusVolatile -= (1 << VOLATILE_CONDITION_BIDE_SHIFT);

                if ((ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_BIDE) == FALSE
                    && battleCtx->storedDamage[battleCtx->attacker]) {
                    battleCtx->damage = battleCtx->storedDamage[battleCtx->attacker] * 2;

                    if (battleCtx->battleMons[battleCtx->lastHitByBattler[battleCtx->attacker]].curHP) {
                        battleCtx->defender = battleCtx->lastHitByBattler[battleCtx->attacker];
                    } else {
                        battleCtx->defender = BattleSystem_RandomOpponent(battleSys, battleCtx, battleCtx->attacker);

                        if (DEFENDING_MON.curHP == 0) {
                            LOAD_SUBSEQ(subscript_bide_no_target);
                            battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;
                            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                            result = CHECK_STATUS_GO_TO_SCRIPT;
                            break;
                        }
                    }
                }

                LOAD_SUBSEQ(subscript_bide_end);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                result = CHECK_STATUS_GO_TO_SCRIPT;
            }
            break;

        case CHECK_STATUS_STATE_SELF_THAW:
            if ((ATTACKING_MON.status & MON_CONDITION_FREEZE)
                && Sovereign_MoveThawsUser(battleCtx->moveCur, moveEffect)) {
                LOAD_SUBSEQ(subscript_defrosted_by_move);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                result = CHECK_STATUS_GO_TO_SCRIPT;
            }

            battleCtx->statusCheckState++;
            break;

        case CHECK_STATUS_END:
            battleCtx->statusCheckState = CHECK_STATUS_START;
            result = CHECK_STATUS_DONE;
            break;
        }
    } while (result == CHECK_STATUS_LOOP_BACK);

    BattleMon_CopyToParty(battleSys, battleCtx, battleCtx->attacker);

    if (result == CHECK_STATUS_DISRUPT_MOVE) {
        battleCtx->battleStatusMask |= SYSCTL_CHECK_LOOP_ONLY_ONCE;
        battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
    }

    return result != CHECK_STATUS_DONE;
}

enum ImmunityAbilityState {
    IMMUNITY_ABILITY_STATE_START = 0,

    IMMUNITY_ABILITY_STATE_CHECK = IMMUNITY_ABILITY_STATE_START,

    IMMUNITY_ABILITY_STATE_END
};

/**
 * @brief Trigger any applicable immunity abilities.
 *
 * Immunity abilities include (but are not limited to) those similar to:
 * - Volt Absorb
 * - Flash Fire
 * - Soundproof
 *
 * Of note: Levitate is *not* checked here; it is checked as part of the type-
 * effectiveness chart.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if there is an interjecting subroutine to execute instead of
 * the rest of the user's move.
 */
static BOOL BattleControllerPlayer_TriggerImmunityAbilities(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int result = STATE_PROCESSING;

    do {
        switch (battleCtx->abilityCheckState) {
        case IMMUNITY_ABILITY_STATE_CHECK:
            int nextSeq = BattleSystem_TriggerImmunityAbility(battleCtx, battleCtx->attacker, battleCtx->defender);

            if ((nextSeq && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE)
                || nextSeq == subscript_blocked_by_soundproof) {
                LOAD_SUBSEQ(nextSeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;

                result = STATE_BREAK_OUT;
            }

            battleCtx->abilityCheckState++;
            break;

        case IMMUNITY_ABILITY_STATE_END:
            battleCtx->abilityCheckState = IMMUNITY_ABILITY_STATE_START;
            result = STATE_DONE;
            break;
        }
    } while (result == STATE_PROCESSING);

    return result != STATE_DONE;
}

/**
 * @brief Load the Quick Claw effect subroutine sequence.
 *
 * Activation checks are all handled within the loaded subroutine sequence.
 *
 * @param battleSys
 * @param battleCtx
 * @return Always TRUE.
 */
static BOOL BattleControllerPlayer_LoadQuickClawCheck(BattleSystem *battleSys, BattleContext *battleCtx)
{
    // Sovereign (item 11): Quick Draw's message instead, when it let the Pokemon move first.
    if (battleCtx->sovereignQuickDraw & FlagIndex(battleCtx->attacker)) {
        battleCtx->sovereignQuickDraw &= ~FlagIndex(battleCtx->attacker);
        LOAD_SUBSEQ(subscript_sovereign_quick_draw);
    } else {
        LOAD_SUBSEQ(subscript_check_quick_claw);
    }

    battleCtx->commandNext = battleCtx->command;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

    return TRUE;
}

#include "data/hit_rate_stages.h"

static inline int CalcMoveType(BattleContext *battleCtx, int attacker, int move)
{
    // Sovereign (item 11): Normalize, the -ate abilities and Liquid Voice.
    return Sovereign_ElectrifyType(battleCtx, attacker, move,
        Sovereign_AbilityMoveType(Battler_Ability(battleCtx, attacker), move, battleCtx->moveType ? battleCtx->moveType : MOVE_DATA(move).type));
}

/**
 * @brief Check if an attacker's specified move will hit a defender.
 *
 * This is the basic Accuracy formula. It does NOT handle special cases such as:
 * - OHKO moves
 * - perfectly-accurate moves (e.g. Aerial Ace, Vital Throw)
 * - moves which become perfectly-accurate in certain weather conditions
 * - effects which override the standard accuracy formula (e.g. No Guard)
 *
 * If the move is deemed to miss its target, then the move status flags will be
 * updated with MOVE_STATUS_MISSED.
 *
 * @param battleSys
 * @param battleCtx
 * @param attacker  The attacking battler
 * @param defender  The defending battler
 * @param move      The attacker's move
 * @return Always 0.
 */
static int BattleControllerPlayer_CheckMoveHitAccuracy(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move)
{
    if (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_CATCH_TUTORIAL) {
        return 0;
    }

    u8 moveType = CalcMoveType(battleCtx, attacker, move);
    u8 moveClass = MOVE_DATA(move).class;
    s8 accStages = battleCtx->battleMons[attacker].statBoosts[BATTLE_STAT_ACCURACY] - 6;
    s8 evaStages = 6 - battleCtx->battleMons[defender].statBoosts[BATTLE_STAT_EVASION];

    if (Battler_Ability(battleCtx, attacker) == ABILITY_SIMPLE) {
        accStages *= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SIMPLE) == TRUE) {
        evaStages *= 2;
    }
    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_UNAWARE) == TRUE) {
        accStages = 0;
    }
    if (Battler_Ability(battleCtx, attacker) == ABILITY_UNAWARE) {
        evaStages = 0;
    }
    if (MON_IS_IDENTIFIED(defender) && evaStages < 0) {
        evaStages = 0;
    }
    // Sovereign (item 11): Mind's Eye ignores the target's raised evasion.
    if (Battler_Ability(battleCtx, attacker) == ABILITY_MINDS_EYE && evaStages < 0) {
        evaStages = 0;
    }
    // Sovereign (item 11): Sacred Sword, Chip Away and Darkest Lariat ignore the target's evasion stage.
    if (move == MOVE_SACRED_SWORD || move == MOVE_CHIP_AWAY || move == MOVE_DARKEST_LARIAT) {
        evaStages = 0;
    }

    s8 sumStages = 6 + evaStages + accStages;
    if (sumStages < 0) {
        sumStages = 0;
    }
    if (sumStages > 12) {
        sumStages = 12;
    }

    u16 hitRate = MOVE_DATA(move).accuracy;
    if (hitRate == 0) {
        return 0;
    }

    // Charge-up moves don't consider accuracy on their first turn
    if (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) {
        return 0;
    }

    // These moves shouldn't use this formula
    if (battleCtx->battleStatusMask & SYSCTL_NONSTANDARD_ACC_CHECK) {
        return 0;
    }

    // Sovereign (item 11): Wonder Skin makes status moves aimed at the holder at most 50% accurate.
    if (moveClass == CLASS_STATUS && hitRate > 50 && attacker != defender
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_WONDER_SKIN) == TRUE) {
        hitRate = 50;
    }

    // Sovereign (item 11): Hurricane shares Thunder's weather accuracy. A target holding a Utility Umbrella feels no sun,
    // but a Mega Sol user's moves always act as in harsh sunlight.
    if (((NO_CLOUD_NINE && (Sovereign_BattlerWeather(battleCtx, defender) & FIELD_CONDITION_SUNNY))
            || Battler_Ability(battleCtx, attacker) == ABILITY_MEGA_SOL)
        && (MOVE_DATA(move).effect == BATTLE_EFFECT_THUNDER || MOVE_DATA(move).effect == BATTLE_EFFECT_HURRICANE)) {
        hitRate = 50;
    }

    hitRate *= HitRateByStage[sumStages].numerator;
    hitRate /= HitRateByStage[sumStages].denominator;

    if (Battler_Ability(battleCtx, attacker) == ABILITY_COMPOUND_EYES) {
        hitRate = hitRate * 130 / 100;
    }

    if (NO_CLOUD_NINE) {
        if (WEATHER_IS_SAND && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SAND_VEIL) == TRUE) {
            hitRate = hitRate * 80 / 100;
        }

        if (WEATHER_IS_HAIL && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_SNOW_CLOAK) == TRUE) {
            hitRate = hitRate * 80 / 100;
        }

        if (battleCtx->fieldConditionsMask & FIELD_CONDITION_DEEP_FOG) {
            hitRate = hitRate * 6 / 10;
        }
    }

    if (Battler_Ability(battleCtx, attacker) == ABILITY_HUSTLE && moveClass == CLASS_PHYSICAL) {
        hitRate = hitRate * 80 / 100;
    }

    // Sovereign (item 11): Victory Star raises the accuracy of the holder and its ally by 10% each.
    for (int victoryStars = BattleSystem_CountAbility(battleSys, battleCtx, COUNT_ALIVE_BATTLERS_OUR_SIDE, attacker, ABILITY_VICTORY_STAR); victoryStars > 0; victoryStars--) {
        hitRate = hitRate * 110 / 100;
    }

    if (Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_TANGLED_FEET) == TRUE
        && (battleCtx->battleMons[defender].statusVolatile & VOLATILE_CONDITION_CONFUSION)) {
        hitRate = hitRate * 50 / 100;
    }

    int itemEffect = Battler_HeldItemEffect(battleCtx, defender);
    int itemPower = Battler_HeldItemPower(battleCtx, defender, 0);

    if (itemEffect == HOLD_EFFECT_ACC_REDUCE) {
        hitRate = hitRate * (100 - itemPower) / 100;
    }

    itemEffect = Battler_HeldItemEffect(battleCtx, attacker);
    itemPower = Battler_HeldItemPower(battleCtx, attacker, 0);

    if (itemEffect == HOLD_EFFECT_ACCURACY_UP) {
        hitRate = hitRate * (100 + itemPower) / 100;
    }

    if (itemEffect == HOLD_EFFECT_ACCURACY_UP_SLOWER && Battler_MovedThisTurn(battleCtx, defender) == TRUE) {
        hitRate = hitRate * (100 + itemPower) / 100;
    }

    if (battleCtx->battleMons[attacker].moveEffectsData.micleBerry) {
        battleCtx->battleMons[attacker].moveEffectsData.micleBerry = FALSE;
        hitRate = hitRate * 120 / 100;
    }

    if (battleCtx->fieldConditionsMask & FIELD_CONDITION_GRAVITY) {
        hitRate = hitRate * 10 / 6;
    }

    if ((BattleSystem_RandNext(battleSys) % 100) + 1 > hitRate) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_MISSED;
    }

    return 0;
}

/**
 * @brief Check if any effects will override an attacker's move hitting its
 * target.
 *
 * This is where the following effects are checked:
 * - Protect
 * - Lock-On / Mind Reader
 * - No Guard
 * - Thunder / Blizzard (in rain / hail, respectively)
 * - Semi-invulnerability (Fly, Bounce, Dig, Dive, Shadow Force)
 *
 * @param battleSys
 * @param battleCtx
 * @param attacker  The attacking battler
 * @param defender  The defending battler
 * @param move      The attacker's move
 * @return Always 0.
 */
// Sovereign (item 11): where a battler that hasn't moved yet stands in the rest of this turn's action order, or -1.
static int Sovereign_TurnOrderIndex(BattleSystem *battleSys, BattleContext *battleCtx, int battler)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (int i = battleCtx->turnOrderCounter + 1; i < maxBattlers; i++) {
        if (battleCtx->battlerActionOrder[i] == battler) {
            return i;
        }
    }

    return -1;
}

// Sovereign (item 11): where a battler's action stays in the rest of the turn's order, as Showdown's action order: 0 when
// After You or Round moved it up, 2 when Quash moved it last, 1 otherwise. Dynamic speed re-sorts only within a class.
static int Sovereign_TurnOrderClass(BattleContext *battleCtx, int battler)
{
    if (battleCtx->turnFlags[battler].sovereignMovedUp) {
        return 0;
    }

    return battleCtx->turnFlags[battler].sovereignQuashed ? 2 : 1;
}

// Sovereign (item 11): After You moves the target up to act next; Quash moves it to act last.
static void Sovereign_ReorderTurn(BattleSystem *battleSys, BattleContext *battleCtx, int battler, BOOL toLast)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int pos = Sovereign_TurnOrderIndex(battleSys, battleCtx, battler);
    int i;

    if (pos < 0) {
        return;
    }

    // The dynamic-speed re-sort before each action keeps the battler where this puts it (Sovereign_TurnOrderClass).
    if (toLast) {
        battleCtx->turnFlags[battler].sovereignQuashed = TRUE;
    } else {
        battleCtx->turnFlags[battler].sovereignMovedUp = TRUE;
    }

    if (toLast) {
        for (i = pos; i < maxBattlers - 1; i++) {
            battleCtx->battlerActionOrder[i] = battleCtx->battlerActionOrder[i + 1];
        }
        battleCtx->battlerActionOrder[maxBattlers - 1] = battler;
    } else {
        for (i = pos; i > battleCtx->turnOrderCounter + 1; i--) {
            battleCtx->battlerActionOrder[i] = battleCtx->battlerActionOrder[i - 1];
        }
        battleCtx->battlerActionOrder[battleCtx->turnOrderCounter + 1] = battler;
    }
}

// Sovereign (item 11): after a Round, the first Pokemon still to act this turn that chose Round (on either side) moves
// right after it, and its Round has double power.
static void Sovereign_CallNextRound(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (int i = battleCtx->turnOrderCounter + 1; i < maxBattlers; i++) {
        int battler = battleCtx->battlerActionOrder[i];

        if (battleCtx->battlerActions[battler][BATTLE_ACTION_SELECTED_COMMAND] == PLAYER_INPUT_FIGHT
            && battleCtx->moveSelected[battler] == MOVE_ROUND
            && battleCtx->battleMons[battler].curHP) {
            Sovereign_ReorderTurn(battleSys, battleCtx, battler, FALSE);
            battleCtx->turnFlags[battler].sovereignRoundCalled = TRUE;
            return;
        }
    }
}

// Sovereign (item 11): sends Dragon Darts' next dart, once a dart is done, as Showdown's smart targeting does. The second
// dart goes to the target's ally. When the first can't hit the target (a miss, Protect, an immunity), both go to the
// ally; when the second can't hit the ally, or the ally has fainted, it goes back to the target. TRUE when a dart is on
// its way.
static BOOL Sovereign_DragonDartsNext(BattleSystem *battleSys, BattleContext *battleCtx)
{
    // An immunity ability (Volt Absorb on an Electrified dart) ends the pass with MOVE_STATUS_NO_MORE_WORK.
    BOOL missed = (battleCtx->moveStatusFlags & (MOVE_STATUS_DID_NOT_HIT | MOVE_STATUS_NO_MORE_WORK)) != FALSE;
    int target = battleCtx->sovereignDartsTargets[0];
    int hits = 1;
    int checks = SYSCTL_MULTI_HIT_MOVE; // back at the target the first dart hit: no checks again

    switch (battleCtx->sovereignDarts) {
    case SOVEREIGN_DARTS_FIRST:
        battleCtx->sovereignDarts = SOVEREIGN_DARTS_DONE;

        if (missed) {
            // Both darts at the ally.
            target = battleCtx->sovereignDartsTargets[1];
            hits = 0; // the move's script sets 2
            checks = SYSCTL_HIT_MULTIPLE_TARGETS;
        } else if (battleCtx->battleMons[battleCtx->sovereignDartsTargets[1]].curHP) {
            battleCtx->sovereignDarts = SOVEREIGN_DARTS_SECOND;
            target = battleCtx->sovereignDartsTargets[1];
            checks = SYSCTL_HIT_MULTIPLE_TARGETS;
        }
        break;

    case SOVEREIGN_DARTS_SECOND:
        battleCtx->sovereignDarts = SOVEREIGN_DARTS_DONE;

        if (missed == FALSE) {
            return FALSE;
        }
        break;

    default:
        return FALSE;
    }

    if (battleCtx->battleMons[target].curHP == 0) {
        return FALSE;
    }

    BattleSystem_SetupLoop(battleSys, battleCtx);
    battleCtx->defender = target;
    battleCtx->multiHitCheckFlags = checks;
    battleCtx->multiHitCounter = hits;
    battleCtx->multiHitNumHits = hits;
    battleCtx->battleStatusMask &= ~SYSCTL_PLAYED_MOVE_ANIMATION; // each dart plays the animation
    battleCtx->command = BATTLE_CONTROL_BEFORE_MOVE;

    return TRUE;
}

static int BattleControllerPlayer_CheckMoveHitOverrides(BattleSystem *battleSys, BattleContext *battleCtx, int attacker, int defender, int move)
{
    battleCtx->sovereignShieldContact = MOVE_NONE; // Sovereign (item 11)
    battleCtx->sovereignGuardBlock = MOVE_NONE;

    // Sovereign (item 11): unlike other charge turns, Sky Drop's first can be blocked by Protect and the like and dodged
    // by a Pokemon out of reach (Showdown); it ignores accuracy all the same (BattleControllerPlayer_CheckMoveHitAccuracy).
    if ((battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) && move != MOVE_SKY_DROP) {
        return 0;
    }

    // Sovereign (item 11): Sky Drop's drop doesn't hurt a Flying type.
    if (move == MOVE_SKY_DROP
        && (battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN) == FALSE
        && attacker != defender
        && MON_HAS_TYPE(defender, TYPE_FLYING)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
        return 0;
    }

    // Sovereign (item 11): a Tatsugiri in its ally Dondozo's mouth (Commander) avoids every move aimed at it, No Guard's
    // and Lock-On's too (Showdown checks it before any other effect).
    if (attacker != defender && (battleCtx->sovereignCommanding & FlagIndex(defender))) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_SEMI_INVULNERABLE;
        return 0;
    }

    // Sovereign (item 11): Unseen Fist's and Piercing Drill's contact moves go through protection, at 1/4 damage
    // (Champions).
    BOOL unseenFist = (Battler_Ability(battleCtx, attacker) == ABILITY_UNSEEN_FIST || Battler_Ability(battleCtx, attacker) == ABILITY_PIERCING_DRILL)
        && (MOVE_DATA(move).flags & MOVE_FLAG_MAKES_CONTACT);
    battleCtx->sovereignThroughProtect = FALSE;

    if (battleCtx->turnFlags[defender].protecting
        && unseenFist
        && (MOVE_DATA(move).flags & MOVE_FLAG_CAN_PROTECT)
        && MOVE_DATA(move).class != CLASS_STATUS) {
        battleCtx->sovereignThroughProtect = TRUE;
    }

    if (battleCtx->turnFlags[defender].protecting
        && unseenFist == FALSE
        && (MOVE_DATA(move).flags & MOVE_FLAG_CAN_PROTECT)
        && (MOVE_DATA(move).class != CLASS_STATUS || Sovereign_ShieldBlocksStatusMoves(battleCtx->sovereignShieldMove[defender])) // Sovereign (item 11)
        && (move != MOVE_CURSE || Move_IsGhostCurse(battleCtx, move, attacker) == TRUE) // Ghost-Curse can be Protected
        && (Move_IsMultiTurn(battleCtx, move) == FALSE
            || (battleCtx->battleStatusMask & SYSCTL_LAST_OF_MULTI_TURN)
            || move == MOVE_SKY_DROP)) { // Sovereign (item 11): Protect stops Sky Drop's lift
        Battler_UnlockMoveChoice(battleSys, battleCtx, attacker);
        battleCtx->moveStatusFlags |= MOVE_STATUS_PROTECTED;

        // Sovereign (item 11): King's Shield, Spiky Shield and the like punish a contact move they block
        // (subscript_missed).
        if (Sovereign_ShieldHasContactPenalty(battleCtx->sovereignShieldMove[defender])
            && Sovereign_MakesContact(battleCtx, attacker, move)) {
            battleCtx->sovereignShieldContact = battleCtx->sovereignShieldMove[defender];
        }

        return 0;
    }

    if ((battleCtx->battleStatusMask & SYSCTL_NONSTANDARD_ACC_CHECK) == FALSE
        && (MON_IS_LOCKED_ONTO(attacker, defender)
            || (battleCtx->sovereignTelekinesis[defender] && MOVE_DATA(move).effect != BATTLE_EFFECT_ONE_HIT_KO) // Sovereign (item 11)
            || (battleCtx->sovereignGlaiveRush & FlagIndex(defender)) // Sovereign (item 11)
            || Battler_Ability(battleCtx, attacker) == ABILITY_NO_GUARD
            || Battler_Ability(battleCtx, defender) == ABILITY_NO_GUARD)) {
        battleCtx->moveStatusFlags &= ~MOVE_STATUS_MISSED;
        return 0;
    }

    // Sovereign (item 11): a Mega Sol user's moves act as in harsh sunlight, never in rain or snow.
    if (NO_CLOUD_NINE && Battler_Ability(battleCtx, attacker) != ABILITY_MEGA_SOL) {
        // Sovereign (item 11): the Forces of Nature's storms never miss in rain either, unless the target holds a Utility
        // Umbrella.
        if ((Sovereign_BattlerWeather(battleCtx, defender) & FIELD_CONDITION_RAINING)
            && (MOVE_DATA(move).effect == BATTLE_EFFECT_THUNDER || MOVE_DATA(move).effect == BATTLE_EFFECT_HURRICANE
                || move == MOVE_BLEAKWIND_STORM || move == MOVE_WILDBOLT_STORM || move == MOVE_SANDSEAR_STORM)) {
            battleCtx->moveStatusFlags &= ~MOVE_STATUS_MISSED;
        }

        if (WEATHER_IS_HAIL && MOVE_DATA(move).effect == BATTLE_EFFECT_BLIZZARD) {
            battleCtx->moveStatusFlags &= ~MOVE_STATUS_MISSED;
        }
    }

    if ((battleCtx->moveStatusFlags & MOVE_STATUS_BYPASSED_ACCURACY) == FALSE
        && CURRENT_MOVE_DATA.range != RANGE_OPPONENT_SIDE
        && (((battleCtx->battleStatusMask & SYSCTL_HIT_DURING_FLY) == FALSE && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_AIRBORNE))
            || ((battleCtx->battleStatusMask & SYSCTL_HIT_DURING_SHADOW_FORCE) == FALSE && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_SHADOW_FORCE))
            || ((battleCtx->battleStatusMask & SYSCTL_HIT_DURING_DIG) == FALSE && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_UNDERGROUND))
            || ((battleCtx->battleStatusMask & SYSCTL_HIT_DURING_DIVE) == FALSE && (battleCtx->battleMons[defender].moveEffectsMask & MOVE_EFFECT_UNDERWATER)))) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_SEMI_INVULNERABLE;
    }

    // Sovereign (item 11): Telepathy avoids its partner's damaging moves; Bulletproof blocks ball and bomb moves.
    if (attacker != defender
        && MOVE_DATA(move).class != CLASS_STATUS
        && BattleSystem_GetBattlerSide(battleSys, attacker) == BattleSystem_GetBattlerSide(battleSys, defender)
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_TELEPATHY) == TRUE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    if (attacker != defender
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_BULLETPROOF) == TRUE
        && Move_IsBallOrBomb(move)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    // Sovereign (item 11): powder moves don't affect Grass types or Overcoat (Gen VI+).
    if (attacker != defender && Move_IsPowder(move) && Battler_SovereignPowderImmune(battleCtx, attacker, defender)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    // Sovereign (item 11): Wide Guard blocks spread moves aimed at its side, Quick Guard foes' priority moves, Mat Block
    // damaging moves and Crafty Shield status moves aimed at a Pokemon there. subscript_missed names the guard. Unseen
    // Fist gets through all but Crafty Shield, at 1/4 damage.
    if (attacker != defender) {
        int guards = battleCtx->sovereignSideGuards[BattleSystem_GetBattlerSide(battleSys, defender)];

        if ((guards & 1)
            && (MOVE_DATA(move).range == RANGE_ADJACENT_OPPONENTS || MOVE_DATA(move).range == RANGE_ALL_ADJACENT)) {
            battleCtx->sovereignGuardBlock = MOVE_WIDE_GUARD;
        } else if ((guards & 2)
            && BattleSystem_GetBattlerSide(battleSys, attacker) != BattleSystem_GetBattlerSide(battleSys, defender)
            && Sovereign_MovePriority(battleCtx, attacker, move) > 0) {
            battleCtx->sovereignGuardBlock = MOVE_QUICK_GUARD;
        } else if ((guards & 4)
            && MOVE_DATA(move).class != CLASS_STATUS
            && (MOVE_DATA(move).flags & MOVE_FLAG_CAN_PROTECT)) {
            battleCtx->sovereignGuardBlock = MOVE_MAT_BLOCK;
        } else if ((guards & 8)
            && MOVE_DATA(move).class == CLASS_STATUS
            && (MOVE_DATA(move).range == RANGE_SINGLE_TARGET
                || MOVE_DATA(move).range == RANGE_ADJACENT_OPPONENTS
                || MOVE_DATA(move).range == RANGE_ALL_ADJACENT
                || MOVE_DATA(move).range == RANGE_ALLY)) {
            battleCtx->sovereignGuardBlock = MOVE_CRAFTY_SHIELD;
        }

        if (unseenFist && battleCtx->sovereignGuardBlock && battleCtx->sovereignGuardBlock != MOVE_CRAFTY_SHIELD) {
            battleCtx->sovereignGuardBlock = MOVE_NONE;
            battleCtx->sovereignThroughProtect = TRUE;
        }

        if (battleCtx->sovereignGuardBlock) {
            battleCtx->moveStatusFlags |= MOVE_STATUS_PROTECTED;
        }
    }

    // Sovereign (item 11): Good as Gold makes the holder immune to other Pokemon's status moves aimed at it.
    if (attacker != defender
        && MOVE_DATA(move).class == CLASS_STATUS
        && (MOVE_DATA(move).range == RANGE_SINGLE_TARGET
            || MOVE_DATA(move).range == RANGE_ADJACENT_OPPONENTS
            || MOVE_DATA(move).range == RANGE_ALL_ADJACENT
            || MOVE_DATA(move).range == RANGE_ALLY)
        && Battler_IgnorableAbility(battleCtx, attacker, defender, ABILITY_GOOD_AS_GOLD) == TRUE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    // Sovereign (item 11): Aroma Veil, the target's own or its partner's, keeps Attract, Disable, Encore, Heal Block,
    // Taunt and Torment off it. subscript_missed names the veil.
    if (Sovereign_AromaVeilBlocks(battleSys, battleCtx, attacker, defender, move)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    // Sovereign (item 11): After You and Quash fail against a target that has already moved this turn.
    if ((move == MOVE_AFTER_YOU || move == MOVE_QUASH) && Sovereign_TurnOrderIndex(battleSys, battleCtx, defender) < 0) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Synchronoise only affects targets that share a type with the user.
    if (move == MOVE_SYNCHRONOISE
        && attacker != defender
        && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL) != BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_1, NULL)
        && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL) != BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_2, NULL)
        && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL) != BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_1, NULL)
        && BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL) != BattleMon_Get(battleCtx, attacker, BATTLEMON_TYPE_2, NULL)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    // Sovereign (item 11): Bestow can't give away an item that sets the user's form (a Mega Stone, an Orb...).
    if (move == MOVE_BESTOW && Battler_SovereignHeldItemLocked(battleCtx, attacker)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Belch fails unless the user has eaten a Berry this battle.
    if (move == MOVE_BELCH && (battleCtx->sovereignAteBerry[attacker] & FlagIndex(battleCtx->selectedPartySlot[attacker])) == FALSE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Upper Hand fails unless the target is about to use a priority move this turn.
    if (move == MOVE_UPPER_HAND
        && (battleCtx->battlerActions[defender][BATTLE_ACTION_PICK_COMMAND] == BATTLE_CONTROL_MOVE_END
            || Sovereign_MovePriority(battleCtx, defender, Battler_SelectedMove(battleCtx, defender)) <= 0
            || MOVE_DATA(Battler_SelectedMove(battleCtx, defender)).class == CLASS_STATUS)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Poltergeist fails against a target holding no item.
    if (move == MOVE_POLTERGEIST && battleCtx->battleMons[defender].heldItem == ITEM_NONE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Psychic Terrain protects grounded Pokemon from foes' priority moves; Steel Roller fails without
    // a terrain.
    if (attacker != defender
        && BattleSystem_GetBattlerSide(battleSys, attacker) != BattleSystem_GetBattlerSide(battleSys, defender)
        && (Sovereign_TerrainUnder(battleCtx, defender) & FIELD_CONDITION_TERRAIN_PSYCHIC)
        && Sovereign_MovePriority(battleCtx, attacker, move) > 0) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }
    if (move == MOVE_STEEL_ROLLER && (battleCtx->fieldConditionsMask & FIELD_CONDITION_TERRAIN) == FALSE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_FAILED;
    }

    // Sovereign (item 11): Queenly Majesty, Dazzling and Armor Tail block foes' priority moves aimed at their side.
    if (attacker != defender
        && BattleSystem_GetBattlerSide(battleSys, attacker) != BattleSystem_GetBattlerSide(battleSys, defender)
        && Sovereign_MovePriority(battleCtx, attacker, move) > 0) {
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
        for (int i = 0; i < maxBattlers; i++) {
            if (BattleSystem_GetBattlerSide(battleSys, i) == BattleSystem_GetBattlerSide(battleSys, defender)
                && battleCtx->battleMons[i].curHP
                && (Battler_IgnorableAbility(battleCtx, attacker, i, ABILITY_QUEENLY_MAJESTY) == TRUE
                    || Battler_IgnorableAbility(battleCtx, attacker, i, ABILITY_DAZZLING) == TRUE
                    || Battler_IgnorableAbility(battleCtx, attacker, i, ABILITY_ARMOR_TAIL) == TRUE)) {
                battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
                break;
            }
        }
    }

    // Sovereign (item 11): since Gen VII, a status move boosted by Prankster doesn't affect a Dark-type foe it targets.
    if (Battler_Ability(battleCtx, attacker) == ABILITY_PRANKSTER
        && MOVE_DATA(move).class == CLASS_STATUS
        && attacker != defender
        && BattleSystem_GetBattlerSide(battleSys, attacker) != BattleSystem_GetBattlerSide(battleSys, defender)
        && (MOVE_DATA(move).range == RANGE_SINGLE_TARGET
            || MOVE_DATA(move).range == RANGE_ADJACENT_OPPONENTS
            || MOVE_DATA(move).range == RANGE_ALL_ADJACENT)
        && (BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_1, NULL) == TYPE_DARK
            || BattleMon_Get(battleCtx, defender, BATTLEMON_TYPE_2, NULL) == TYPE_DARK)) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_INEFFECTIVE;
    }

    return 0;
}

/**
 * @brief Check if the attacker's move for the turn has been stolen.
 *
 * A move can be stolen either by targeting a battler which used Magic Coat
 * or by using a move which can be affected by Snatch. If a move is stolen
 * in this way, then an interjecting subroutine will be loaded into the
 * sequence buffer for execution.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the move should be stolen and its targets updated, FALSE
 * otherwise.
 */
static BOOL BattleControllerPlayer_MoveStolen(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int i, battler; // must declare up here to match
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    if (battleCtx->defender == BATTLER_NONE) {
        return FALSE;
    }

    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && DEFENDER_TURN_FLAGS.magicCoat
        && (CURRENT_MOVE_DATA.flags & MOVE_FLAG_CAN_MAGIC_COAT)) {
        DEFENDER_TURN_FLAGS.magicCoat = FALSE;

        battleCtx->moveProtect[battleCtx->attacker] = FALSE;
        battleCtx->movePrevByBattler[battleCtx->attacker] = battleCtx->moveTemp;
        battleCtx->movePrev = battleCtx->moveTemp;

        battleCtx->battleStatusMask |= SYSCTL_REUSE_LAST_MOVE;

        LOAD_SUBSEQ(subscript_magic_coat);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        BattleSystem_DecPPForPressure(battleCtx, battleCtx->defender, battleCtx->attacker);
        return TRUE;
    }

    // Sovereign (item 11): Magic Bounce reflects status moves like Magic Coat, every turn. A move it has already
    // reflected is not reflected again.
    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (battleCtx->battleStatusMask & SYSCTL_REUSE_LAST_MOVE) == FALSE
        && battleCtx->attacker != battleCtx->defender
        && (CURRENT_MOVE_DATA.flags & MOVE_FLAG_CAN_MAGIC_COAT)
        && DEFENDING_MON.curHP
        && Battler_IgnorableAbility(battleCtx, battleCtx->attacker, battleCtx->defender, ABILITY_MAGIC_BOUNCE) == TRUE) {
        battleCtx->moveProtect[battleCtx->attacker] = FALSE;
        battleCtx->movePrevByBattler[battleCtx->attacker] = battleCtx->moveTemp;
        battleCtx->movePrev = battleCtx->moveTemp;

        battleCtx->battleStatusMask |= SYSCTL_REUSE_LAST_MOVE;

        LOAD_SUBSEQ(subscript_sovereign_magic_bounce);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        return TRUE;
    }

    for (i = 0; i < maxBattlers; i++) {
        battler = battleCtx->monSpeedOrder[i];
        if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
            && battleCtx->turnFlags[battler].snatching
            && (CURRENT_MOVE_DATA.flags & MOVE_FLAG_CAN_SNATCH)) {
            battleCtx->msgBattlerTemp = battler;
            battleCtx->turnFlags[battler].snatching = FALSE;

            if ((battleCtx->battleStatusMask & SYSCTL_REUSE_LAST_MOVE) == FALSE) {
                battleCtx->moveProtect[battleCtx->attacker] = 0;
                battleCtx->movePrevByBattler[battleCtx->attacker] = battleCtx->moveTemp;
                battleCtx->movePrev = battleCtx->moveTemp;

                battleCtx->battleStatusMask |= SYSCTL_REUSE_LAST_MOVE;
            }

            LOAD_SUBSEQ(subscript_snatch);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            BattleSystem_DecPPForPressure(battleCtx, battler, battleCtx->attacker);
            return TRUE;
        }
    }

    return FALSE;
}

static void BattleControllerPlayer_ExecScript(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleScript_Exec(battleSys, battleCtx) == TRUE) {
        battleCtx->scriptCursor = 0;
        battleCtx->command = battleCtx->commandNext;
    }
}

enum BeforeMoveState {
    BEFORE_MOVE_START = 0,

    BEFORE_MOVE_STATE_QUICK_CLAW = BEFORE_MOVE_START,
    BEFORE_MOVE_STATE_STATUS_DISRUPTION,
    BEFORE_MOVE_STATE_CHECK_OBEDIENCE,
    BEFORE_MOVE_STATE_DECREMENT_PP,
    BEFORE_MOVE_STATE_CHECK_TARGET_EXISTS,
    BEFORE_MOVE_STATE_CHECK_STOLEN,
    BEFORE_MOVE_STATE_REDIRECT_TARGET,

    BEFORE_MOVE_END,
};

static void BattleControllerPlayer_BeforeMove(BattleSystem *battleSys, BattleContext *battleCtx)
{
    switch (battleCtx->beforeMoveCheckState) {
    case BEFORE_MOVE_STATE_QUICK_CLAW:
        battleCtx->sovereignGemBoost = 0; // Sovereign (item 11): a Gem powers up only the move it was used for
        battleCtx->sovereignHalfHPPaid = FALSE; // Sovereign (item 11): Steel Beam & co. cost half the HP once per move
        BattleControllerPlayer_LoadQuickClawCheck(battleSys, battleCtx);
        battleCtx->beforeMoveCheckState++;
        return;

    case BEFORE_MOVE_STATE_STATUS_DISRUPTION:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_STATUS_CHECK) == FALSE
            && BattleControllerPlayer_CheckStatusDisruption(battleSys, battleCtx) == TRUE) {
            return;
        }
        battleCtx->beforeMoveCheckState++;

    case BEFORE_MOVE_STATE_CHECK_OBEDIENCE:
        int result;
        int nextSeq;

        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_OBEDIENCE_CHECK) == FALSE) {
            result = BattleControllerPlayer_CheckObedience(battleSys, battleCtx, &nextSeq);

            if (result) {
                switch (result) {
                case OBEY_CHECK_DO_NOTHING:
                    battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;
                    break;
                case OBEY_CHECK_DIFFERENT_MOVE:
                    battleCtx->commandNext = battleCtx->command;
                    break;
                case OBEY_CHECK_HIT_SELF:
                    battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED;
                    break;
                }

                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                LOAD_SUBSEQ(nextSeq);

                return;
            }
        }

        battleCtx->beforeMoveCheckState++;

    case BEFORE_MOVE_STATE_DECREMENT_PP:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_PP_DECREMENT) == FALSE
            && BattleControllerPlayer_DecrementPP(battleSys, battleCtx) == TRUE) {
            return;
        }

        battleCtx->beforeMoveCheckState++;

    case BEFORE_MOVE_STATE_CHECK_TARGET_EXISTS:
        if (BattleControllerPlayer_HasNoTarget(battleSys, battleCtx) == TRUE) {
            return;
        }

        battleCtx->beforeMoveCheckState++;

    case BEFORE_MOVE_STATE_CHECK_STOLEN:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_STOLEN_CHECK) == FALSE
            && BattleControllerPlayer_MoveStolen(battleSys, battleCtx) == 1) {
            return;
        }

        battleCtx->beforeMoveCheckState++;

    case BEFORE_MOVE_STATE_REDIRECT_TARGET:
        BattleSystem_CheckRedirectionAbilities(battleSys, battleCtx, battleCtx->attacker, battleCtx->moveCur);
        battleCtx->beforeMoveCheckState = BEFORE_MOVE_START;
    }

    // Sovereign (item 11): Shell Trap fails, with no attack message, unless a foe's physical move sprang it this turn.
    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && battleCtx->moveCur == MOVE_SHELL_TRAP
        && battleCtx->turnFlags[battleCtx->attacker].sovereignShellTrapHit == FALSE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
        battleCtx->battleStatusMask |= SYSCTL_CHECK_LOOP_ONLY_ONCE;
        LOAD_SUBSEQ(subscript_sovereign_shell_trap_fail);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_MOVE_FAILED;
        return;
    }

    // Sovereign (item 11): damaging Fire moves fizzle out in heavy rain, Water moves evaporate in extremely harsh
    // sunlight.
    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (battleCtx->fieldConditionsMask & FIELD_CONDITION_SOVEREIGN_PRIMAL)
        && NO_CLOUD_NINE
        && CURRENT_MOVE_DATA.class != CLASS_STATUS) {
        int moveType = CalcMoveType(battleCtx, battleCtx->attacker, battleCtx->moveCur);

        if (((battleCtx->fieldConditionsMask & FIELD_CONDITION_RAINING) && moveType == TYPE_FIRE)
            || ((battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY) && moveType == TYPE_WATER)) {
            battleCtx->msgTemp = (battleCtx->fieldConditionsMask & FIELD_CONDITION_SUNNY) ? 1 : 0;
            battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
            battleCtx->battleStatusMask |= SYSCTL_CHECK_LOOP_ONLY_ONCE; // a spread move fizzles out once
            LOAD_SUBSEQ(subscript_sovereign_primal_fizzle);
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_MOVE_FAILED;
            return;
        }
    }

    // Sovereign (item 11): Powder. A Fire move used by a Pokemon covered in powder explodes: it fails and hurts the
    // user. Heavy rain, above, comes first.
    if ((battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && battleCtx->turnFlags[battleCtx->attacker].sovereignPowdered
        && CalcMoveType(battleCtx, battleCtx->attacker, battleCtx->moveCur) == TYPE_FIRE) {
        battleCtx->moveStatusFlags |= MOVE_STATUS_NO_MORE_WORK;
        battleCtx->battleStatusMask |= SYSCTL_CHECK_LOOP_ONLY_ONCE;
        LOAD_SUBSEQ(subscript_sovereign_powder_explode);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED; // the explosion can make the user faint
        return;
    }

    if (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) {
        battleCtx->command = BATTLE_CONTROL_MOVE_FAILED;
    } else {
        battleCtx->battleStatusMask2 |= SYSCTL_MOVE_SUCCEEDED;

        // Sovereign (item 11): Sky Drop's second turn, past full paralysis and the like: the user lets its target go
        // (BattleControllerPlayer_FightCommand aimed the drop at it).
        if (battleCtx->moveCur == MOVE_SKY_DROP
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_MOVE_LOCKED)
            && battleCtx->defender != BATTLER_NONE
            && Sovereign_SkyDropTarget(battleCtx, battleCtx->attacker) == battleCtx->defender) {
            Sovereign_SkyDropLetGo(battleCtx, battleCtx->attacker, battleCtx->defender);
        }

        // Sovereign (item 11): in a double battle, Dragon Darts aimed at a foe throws one dart at it and one at its
        // ally, each a pass of the move at one target (Sovereign_DragonDartsNext).
        if (battleCtx->moveCur == MOVE_DRAGON_DARTS
            && battleCtx->sovereignDarts == SOVEREIGN_DARTS_NONE
            && battleCtx->multiHitNumHits == 0
            && (BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_DOUBLES)
            && battleCtx->defender != BATTLER_NONE
            && BattleSystem_GetBattlerSide(battleSys, battleCtx->defender) != BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)) {
            int ally = BattleSystem_GetPartner(battleSys, battleCtx->defender);

            if (ally != battleCtx->defender && battleCtx->battleMons[ally].curHP) {
                battleCtx->sovereignDarts = SOVEREIGN_DARTS_FIRST;
                battleCtx->sovereignDartsTargets[0] = battleCtx->defender;
                battleCtx->sovereignDartsTargets[1] = ally;
                battleCtx->multiHitCounter = 1;
                battleCtx->multiHitNumHits = 1;
                battleCtx->multiHitAccuracyCheck = SYSCTL_MULTI_HIT_MOVE;
            }
        }

        // Sovereign (item 11): Parental Bond makes a single-target damaging move hit twice, the second hit at 1/4
        // power (BtlCmd_CalcDamage). Multi-hit, charging, self-KO and fixed-damage moves are left alone.
        if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_PARENTAL_BOND
            && battleCtx->multiHitNumHits == 0
            && CURRENT_MOVE_DATA.class != CLASS_STATUS
            && CURRENT_MOVE_DATA.power > 1
            && CURRENT_MOVE_DATA.range == RANGE_SINGLE_TARGET
            && Move_IsMultiTurn(battleCtx, battleCtx->moveCur) == FALSE
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_MULTI_HIT
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_HIT_TWICE
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_POISON_MULTI_HIT
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_HIT_THREE_TIMES
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_SOVEREIGN_POPULATION_BOMB
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_HALVE_DEFENSE
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_UPROAR
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_FLING
            && CURRENT_MOVE_DATA.effect != BATTLE_EFFECT_RECHARGE_AFTER
            && battleCtx->moveCur != MOVE_FINAL_GAMBIT
            && battleCtx->moveCur != MOVE_SKY_DROP) {
            battleCtx->sovereignParentalBond = TRUE;
            battleCtx->multiHitCounter = 2;
            battleCtx->multiHitNumHits = 2;
            battleCtx->multiHitAccuracyCheck = SYSCTL_MULTI_HIT_MOVE;
        }

        BattleSystem_LoadScript(battleCtx, NARC_INDEX_BATTLE__SKILL__WAZA_SEQ, battleCtx->moveCur);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_TRY_MOVE;

        BattleSystem_UpdateLastResort(battleSys, battleCtx);
    }

    BattleSystem_UpdateMetronomeCount(battleSys, battleCtx);
}

enum TryMoveState {
    TRY_MOVE_START = 0,

    TRY_MOVE_STATE_CHECK_VALID_TARGET = TRY_MOVE_START,
    TRY_MOVE_STATE_TRIGGER_REDIRECTION_ABILITIES,
    TRY_MOVE_STATE_SOVEREIGN_STANCE_CHANGE, // Sovereign (FM)
    TRY_MOVE_STATE_SOVEREIGN_PROTEAN, // Sovereign (item 11)
    TRY_MOVE_STATE_CHECK_MOVE_HITS,
    TRY_MOVE_STATE_CHECK_MOVE_HIT_OVERRIDES,
    TRY_MOVE_STATE_CHECK_TYPE_CHART,
    TRY_MOVE_STATE_TRIGGER_IMMUNITY_ABILITIES,
    TRY_MOVE_STATE_SOVEREIGN_GULP_MISSILE, // Sovereign (FM)

    TRY_MOVE_END,
};

static void BattleControllerPlayer_TryMove(BattleSystem *battleSys, BattleContext *battleCtx)
{
    switch (battleCtx->tryMoveCheckState) {
    case TRY_MOVE_STATE_CHECK_VALID_TARGET:
        battleCtx->tryMoveCheckState++;

        if (BattleControllerPlayer_HasNoTarget(battleSys, battleCtx) == TRUE) {
            return;
        }

    case TRY_MOVE_STATE_TRIGGER_REDIRECTION_ABILITIES:
        battleCtx->tryMoveCheckState++;

        if (BattleSystem_TriggerRedirectionAbilities(battleSys, battleCtx) == TRUE) {
            return;
        }

    case TRY_MOVE_STATE_SOVEREIGN_STANCE_CHANGE: {
        // Sovereign (FM): Stance Change turns Aegislash to Blade Forme before an attack, and back to Shield Forme
        // before King's Shield.
        battleCtx->tryMoveCheckState++;

        int stanceForm = ATTACKING_MON.formNum;
        if (battleCtx->moveCur == MOVE_KINGS_SHIELD) {
            stanceForm = 0;
        } else if (CURRENT_MOVE_DATA.class != CLASS_STATUS) {
            stanceForm = 1;
        }

        if (Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_STANCE_CHANGE
            && ATTACKING_MON.species == SPECIES_AEGISLASH
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && stanceForm != ATTACKING_MON.formNum) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->attacker, stanceForm);
            battleCtx->msgBattlerTemp = battleCtx->attacker;
            LOAD_SUBSEQ(subscript_form_change);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return;
        }
    }

    case TRY_MOVE_STATE_SOVEREIGN_PROTEAN: {
        // Sovereign (item 11): Protean and Libero change the user's type to its move's, once per switch-in.
        battleCtx->tryMoveCheckState++;

        int ability = Battler_Ability(battleCtx, battleCtx->attacker);
        int moveType = CalcMoveType(battleCtx, battleCtx->attacker, battleCtx->moveCur);

        if ((ability == ABILITY_PROTEAN || ability == ABILITY_LIBERO)
            && ATTACKING_MON.sovereignProteanUsed == FALSE
            && battleCtx->moveCur != MOVE_STRUGGLE
            && (ATTACKING_MON.type1 != moveType || ATTACKING_MON.type2 != moveType)) {
            ATTACKING_MON.sovereignProteanUsed = TRUE;
            battleCtx->msgTemp = moveType;
            LOAD_SUBSEQ(subscript_sovereign_protean);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return;
        }
    }

    case TRY_MOVE_STATE_CHECK_MOVE_HITS:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_ACCURACY_CHECK) == FALSE
            && battleCtx->defender != BATTLER_NONE
            && BattleControllerPlayer_CheckMoveHitAccuracy(battleSys, battleCtx, battleCtx->attacker, battleCtx->defender, battleCtx->moveCur) == 1) {
            return;
        }

        battleCtx->tryMoveCheckState++;

    case TRY_MOVE_STATE_CHECK_MOVE_HIT_OVERRIDES:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_ACCURACY_OVERRIDES) == FALSE
            && battleCtx->defender != BATTLER_NONE
            && BattleControllerPlayer_CheckMoveHitOverrides(battleSys, battleCtx, battleCtx->attacker, battleCtx->defender, battleCtx->moveCur) == 1) {
            return;
        }

        battleCtx->tryMoveCheckState++;

    case TRY_MOVE_STATE_CHECK_TYPE_CHART:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_TYPE_CHART_CHECK) == FALSE
            && battleCtx->defender != BATTLER_NONE
            && BattleControllerPlayer_CheckTypeChart(battleSys, battleCtx) == 1) {
            return;
        }

        battleCtx->tryMoveCheckState++;

    case TRY_MOVE_STATE_TRIGGER_IMMUNITY_ABILITIES:
        if ((battleCtx->multiHitCheckFlags & SYSCTL_SKIP_IMMUNITY_TRIGGERS) == FALSE
            && battleCtx->defender != BATTLER_NONE
            && BattleControllerPlayer_TriggerImmunityAbilities(battleSys, battleCtx) == 1) {
            return;
        }

        battleCtx->tryMoveCheckState++;

    case TRY_MOVE_STATE_SOVEREIGN_GULP_MISSILE: {
        // Sovereign (FM): Gulp Missile. Cramorant catches an Arrokuda (Gulping Form) above half its HP, or a Pikachu
        // (Gorging Form) at half or less, when its Surf hits or as it dives (Dive's first turn). A hit spits the catch
        // back (BattleSystem_TriggerAbilityOnHit).
        battleCtx->tryMoveCheckState++;

        int gulpForm = Pokemon_SovereignAbilityForm(ATTACKING_MON.species, ATTACKING_MON.formNum, ABILITY_GULP_MISSILE);

        if ((battleCtx->moveCur == MOVE_SURF || battleCtx->moveCur == MOVE_DIVE)
            && gulpForm >= 0
            && Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_GULP_MISSILE
            && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE) {
            // The Gorging Form comes right after the Gulping Form.
            if (ATTACKING_MON.curHP <= ATTACKING_MON.maxHP / 2) {
                gulpForm++;
            }

            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->attacker, gulpForm);
            battleCtx->msgBattlerTemp = battleCtx->attacker;
            LOAD_SUBSEQ(subscript_sovereign_gulp_missile_catch);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return;
        }
    }

    case TRY_MOVE_END:
        battleCtx->tryMoveCheckState = TRY_MOVE_START;
        break;
    }

    battleCtx->command = BATTLE_CONTROL_PRIMARY_EFFECT;
}

static void BattleControllerPlayer_PrimaryEffect(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int nextSeq;
    if (BattleSystem_TriggerPrimaryEffect(battleSys, battleCtx, &nextSeq) == TRUE) {
        LOAD_SUBSEQ(nextSeq);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_MOVE_FAILED;

        return;
    }

    battleCtx->command = BATTLE_CONTROL_MOVE_FAILED;
}

static void BattleControllerPlayer_CheckMoveFailure(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->moveStatusFlags & MOVE_STATUS_NO_MORE_WORK) {
        battleCtx->command = BATTLE_CONTROL_LOOP_SPREAD_MOVES;
    } else if (battleCtx->moveStatusFlags & MOVE_STATUS_NO_PP) {
        LOAD_SUBSEQ(subscript_no_pp);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;
    } else if (battleCtx->multiHitLoop && (battleCtx->moveStatusFlags & MOVE_STATUS_MISSED)) {
        // Thrashing moves have a special status flag.
        battleCtx->moveStatusFlags &= ~MOVE_STATUS_MISSED;
        battleCtx->moveStatusFlags |= MOVE_STATUS_MULTI_HIT_DISRUPTED;
        battleCtx->command = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;
    } else if (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) {
        LOAD_SUBSEQ(subscript_missed);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED; // crash damage can kill
    } else {
        battleCtx->command = BATTLE_CONTROL_USE_MOVE;
    }
}

static void BattleControllerPlayer_UseMove(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_use_move);
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    battleCtx->commandNext = BATTLE_CONTROL_UPDATE_HP;
}

static void BattleControllerPlayer_UpdateHP(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->moveStatusFlags & MOVE_STATUS_ONE_HIT_KO) {
        battleCtx->damage = DEFENDING_MON.maxHP * -1;
    }

    if (battleCtx->damage) {
        int itemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->defender);
        int itemPower = Battler_HeldItemPower(battleCtx, battleCtx->defender, 0);

        GF_ASSERT(battleCtx->damage < 0);

        // Sovereign (item 11): a contact move that goes through protection with Unseen Fist or Piercing Drill does 1/4
        // damage.
        if (battleCtx->sovereignThroughProtect && battleCtx->damage < -1) {
            battleCtx->damage /= 4;
        }

        if (BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker) == BattleSystem_GetBattlerSide(battleSys, battleCtx->defender)) {
            BattleController_EmitIncrementRecord(battleSys, battleCtx->attacker, 0, RECORD_ATTACKED_ALLY);
        }

        battleCtx->lastHitByBattler[battleCtx->defender] = battleCtx->attacker;

        if ((DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_SUBSTITUTE) && battleCtx->damage < 0
            && Sovereign_BypassesSubstitute(battleCtx, battleCtx->attacker, battleCtx->defender, battleCtx->moveCur) == FALSE) { // Sovereign (item 11)
            if (DEFENDING_MON.moveEffectsData.substituteHP + battleCtx->damage <= 0) {
                ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt += DEFENDING_MON.moveEffectsData.substituteHP * -1;
                DEFENDING_MON.statusVolatile &= ~VOLATILE_CONDITION_SUBSTITUTE;
                battleCtx->hitDamage = DEFENDING_MON.moveEffectsData.substituteHP * -1;
                DEFENDING_MON.moveEffectsData.substituteHP = 0;
            } else {
                ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt += battleCtx->damage;
                DEFENDING_MON.moveEffectsData.substituteHP += battleCtx->damage;
                battleCtx->hitDamage = battleCtx->damage;
            }

            DEFENDER_SELF_TURN_FLAGS.statusFlags |= SELF_TURN_FLAG_SUBSTITUTE_HIT;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            LOAD_SUBSEQ(subscript_hit_substitute);
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;

            return;
        }

        // Sovereign (FM): Disguise takes the first hit in Mimikyu's place. The move does no damage; the disguise is
        // busted (Busted Mimikyu stays busted until the battle ends, through switches, fainting and revival) and costs
        // 1/8 of Mimikyu's max HP. Only a move's hit gets here: Life Orb, poison, burn, weather and entry hazards
        // don't bust it. Mold Breaker ignores it, and a substitute takes the hit first.
        if (battleCtx->damage < 0
            && (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && Pokemon_SovereignDisguiseBustedForm(DEFENDING_MON.species, DEFENDING_MON.formNum) >= 0
            && Battler_IgnorableAbility(battleCtx, battleCtx->attacker, battleCtx->defender, ABILITY_DISGUISE) == TRUE) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->defender,
                Pokemon_SovereignDisguiseBustedForm(DEFENDING_MON.species, DEFENDING_MON.formNum));
            battleCtx->moveStatusFlags &= ~(MOVE_STATUS_BASIC_EFFECTIVENESS | MOVE_STATUS_CRITICAL_HIT | MOVE_STATUS_ONE_HIT_KO);
            battleCtx->hitDamage = 0;
            battleCtx->msgBattlerTemp = battleCtx->defender;
            battleCtx->hpCalcTemp = BattleSystem_Divide(DEFENDING_MON.maxHP, 8) * -1;

            LOAD_SUBSEQ(subscript_sovereign_disguise);
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;
            battleCtx->battleStatusMask |= SYSCTL_MOVE_HIT;

            return;
        }

        // Sovereign (FM): Ice Face takes the first physical hit in Eiscue's place, at no cost. The move does no damage
        // and Eiscue becomes Noice Face, through switches, until snow brings the ice back
        // (BattleSystem_TriggerFormChange) or the battle ends. Mold Breaker ignores it, and a substitute takes the hit
        // first. Of a multi-hit move, only the first hit is blocked.
        if (battleCtx->damage < 0
            && CURRENT_MOVE_DATA.class == CLASS_PHYSICAL
            && (DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE
            && Pokemon_SovereignAbilityForm(DEFENDING_MON.species, DEFENDING_MON.formNum, ABILITY_ICE_FACE) >= 0
            && Battler_IgnorableAbility(battleCtx, battleCtx->attacker, battleCtx->defender, ABILITY_ICE_FACE) == TRUE) {
            BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->defender,
                Pokemon_SovereignAbilityForm(DEFENDING_MON.species, DEFENDING_MON.formNum, ABILITY_ICE_FACE));
            battleCtx->moveStatusFlags &= ~(MOVE_STATUS_BASIC_EFFECTIVENESS | MOVE_STATUS_CRITICAL_HIT | MOVE_STATUS_ONE_HIT_KO);
            battleCtx->hitDamage = 0;
            battleCtx->msgBattlerTemp = battleCtx->defender;

            LOAD_SUBSEQ(subscript_sovereign_ice_face);
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;
            battleCtx->battleStatusMask |= SYSCTL_MOVE_HIT;

            return;
        }

        if (CURRENT_MOVE_DATA.effect == BATTLE_EFFECT_LEAVE_WITH_1_HP
            && DEFENDING_MON.curHP + battleCtx->damage <= 0) {
            battleCtx->damage = (DEFENDING_MON.curHP - 1) * -1;
        }

        if (DEFENDER_TURN_FLAGS.enduring == 0) {
            if (itemEffect == HOLD_EFFECT_MAYBE_ENDURE && (BattleSystem_RandNext(battleSys) % 100) < itemPower) {
                DEFENDER_SELF_TURN_FLAGS.focusItemActivated = TRUE;
            }

            if (itemEffect == HOLD_EFFECT_ENDURE && DEFENDING_MON.curHP == DEFENDING_MON.maxHP) {
                DEFENDER_SELF_TURN_FLAGS.focusItemActivated = TRUE;
            }
        }

        if ((DEFENDER_TURN_FLAGS.enduring || DEFENDER_SELF_TURN_FLAGS.focusItemActivated)
            && DEFENDING_MON.curHP + battleCtx->damage <= 0) {
            battleCtx->damage = (DEFENDING_MON.curHP - 1) * -1;

            if (DEFENDER_TURN_FLAGS.enduring) {
                battleCtx->moveStatusFlags |= MOVE_STATUS_ENDURED;
            } else {
                battleCtx->moveStatusFlags |= MOVE_STATUS_ENDURED_ITEM;
            }
        }

        battleCtx->sovereignHPBeforeHit[battleCtx->defender] = DEFENDING_MON.curHP; // Sovereign (item 11)

        // Sovereign (item 11): Rage Fist counts the hits a Pokemon takes from other Pokemon's moves since it came in
        // (Champions; BattleSystem_UpdateAfterSwitch resets it).
        if (battleCtx->defender != battleCtx->attacker
            && battleCtx->sovereignTimesHit[battleCtx->defender][battleCtx->selectedPartySlot[battleCtx->defender]] < 6) {
            battleCtx->sovereignTimesHit[battleCtx->defender][battleCtx->selectedPartySlot[battleCtx->defender]]++;
        }
        battleCtx->storedDamage[battleCtx->defender] += battleCtx->damage;

        if (battleCtx->battleMons[battleCtx->defender].timesDamaged < 0xFF) {
            battleCtx->battleMons[battleCtx->defender].timesDamaged++;
        }

        if (CURRENT_MOVE_DATA.class == CLASS_PHYSICAL) {
            DEFENDER_TURN_FLAGS.physicalDamageTakenFrom[battleCtx->attacker] = battleCtx->damage;
            DEFENDER_TURN_FLAGS.physicalDamageLastAttacker = battleCtx->attacker;
            DEFENDER_TURN_FLAGS.physicalDamageAttackerMask |= FlagIndex(battleCtx->attacker);
            DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken = battleCtx->damage;
            DEFENDER_SELF_TURN_FLAGS.physicalDamageLastAttacker = battleCtx->attacker;
        } else if (CURRENT_MOVE_DATA.class == CLASS_SPECIAL) {
            DEFENDER_TURN_FLAGS.specialDamageTakenFrom[battleCtx->attacker] = battleCtx->damage;
            DEFENDER_TURN_FLAGS.specialDamageLastAttacker = battleCtx->attacker;
            DEFENDER_TURN_FLAGS.specialDamageAttackerMask |= FlagIndex(battleCtx->attacker);
            DEFENDER_SELF_TURN_FLAGS.specialDamageTaken = battleCtx->damage;
            DEFENDER_SELF_TURN_FLAGS.specialDamageLastAttacker = battleCtx->attacker;
        }

        if (DEFENDING_MON.curHP + battleCtx->damage <= 0) {
            ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt += DEFENDING_MON.curHP * -1;
        } else {
            ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt += battleCtx->damage;
        }

        DEFENDER_TURN_FLAGS.lastDamageTaken = battleCtx->damage;
        DEFENDER_TURN_FLAGS.lastAttacker = battleCtx->attacker;
        battleCtx->msgBattlerTemp = battleCtx->defender;
        battleCtx->hpCalcTemp = battleCtx->damage;

        LOAD_SUBSEQ(subscript_update_hp);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;
        battleCtx->battleStatusMask |= SYSCTL_MOVE_HIT;
    } else {
        battleCtx->command = BATTLE_CONTROL_AFTER_MOVE_MESSAGE;
    }
}

// Sovereign (item 11): TRUE when the attacker's contact move hit a Rocky Helmet holder (not its Substitute): the
// attacker loses 1/6 of its max HP (hpCalcTemp), each hit, even as the holder faints. Magic Guard stops it.
// Sovereign (item 11): a Pokemon heating up its beak (Beak Blast) burns a Pokemon whose contact move hits it.
static BOOL Sovereign_BeakBlastBurns(BattleContext *battleCtx)
{
    return battleCtx->defender != BATTLER_NONE
        && battleCtx->defender != battleCtx->attacker
        && battleCtx->turnFlags[battleCtx->defender].sovereignBeakBlast
        && Battler_SubstituteWasHit(battleCtx, battleCtx->defender) == FALSE
        && ATTACKING_MON.curHP
        && ATTACKING_MON.status == MON_CONDITION_NONE
        && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur);
}

// Sovereign (item 11): a foe's physical move that hits a Pokemon that set a shell trap springs it: that Pokemon moves
// right after (if it hasn't moved yet), and its Shell Trap works.
static void Sovereign_SpringShellTrap(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int trapper = battleCtx->defender;

    if (trapper == BATTLER_NONE
        || battleCtx->turnFlags[trapper].sovereignShellTrap == FALSE
        || battleCtx->turnFlags[trapper].sovereignShellTrapHit
        || BattleSystem_GetBattlerSide(battleSys, trapper) == BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)
        || Battler_SubstituteWasHit(battleCtx, trapper)
        || (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
        || (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken == 0 && DEFENDER_SELF_TURN_FLAGS.specialDamageTaken == 0)
        || Sovereign_HitsPhysically(battleCtx, battleCtx->attacker, trapper, battleCtx->moveCur) == FALSE) {
        return;
    }

    battleCtx->turnFlags[trapper].sovereignShellTrapHit = TRUE;
    Sovereign_ReorderTurn(battleSys, battleCtx, trapper, FALSE);
}

static BOOL Sovereign_RockyHelmetHurts(BattleContext *battleCtx)
{
    if (battleCtx->defender == BATTLER_NONE
        || battleCtx->defender == battleCtx->attacker
        || Battler_HeldItem(battleCtx, battleCtx->defender) != ITEM_ROCKY_HELMET
        || Battler_SubstituteWasHit(battleCtx, battleCtx->defender)
        || ATTACKING_MON.curHP == 0
        || Battler_Ability(battleCtx, battleCtx->attacker) == ABILITY_MAGIC_GUARD
        || (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
        || (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken == 0 && DEFENDER_SELF_TURN_FLAGS.specialDamageTaken == 0)
        || Sovereign_MakesContact(battleCtx, battleCtx->attacker, battleCtx->moveCur) == FALSE) {
        return FALSE;
    }

    battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKING_MON.maxHP * -1, 6);
    return TRUE;
}

// Sovereign (item 11): Order Up. When a Dondozo that a Tatsugiri commands (Commander) hits with it, its Attack, Defense
// or Speed rises by 1, by the Tatsugiri's form, after the move's damage.
static BOOL Sovereign_OrderUpBoosts(BattleContext *battleCtx)
{
    int attacker = battleCtx->attacker;
    int stat = battleCtx->sovereignOrderUpStat[attacker];

    if (battleCtx->moveCur != MOVE_ORDER_UP
        || (battleCtx->sovereignCommanded & FlagIndex(attacker)) == FALSE
        || ATTACKING_MON.curHP == 0
        || (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
        || ATTACKING_MON.statBoosts[stat] >= 12) { // MAX_STAT_STAGE
        return FALSE;
    }

    battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE + (stat - BATTLE_STAT_ATTACK);
    battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
    battleCtx->sideEffectMon = attacker;
    return TRUE;
}

// Sovereign (item 11): a damaging move that hit an Illusion Pokémon (not its substitute) ends the illusion, after the
// move's added effects, as in Showdown (subscript_sovereign_illusion_end).
static BOOL Sovereign_IllusionBroken(BattleContext *battleCtx)
{
    int defender = battleCtx->defender;

    if (defender == BATTLER_NONE
        || battleCtx->sovereignIllusion[defender] == 0
        || Battler_SubstituteWasHit(battleCtx, defender)
        || (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS)
        || CURRENT_MOVE_DATA.class == CLASS_STATUS
        || (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken == 0 && DEFENDER_SELF_TURN_FLAGS.specialDamageTaken == 0)) {
        return FALSE;
    }

    battleCtx->sovereignIllusion[defender] = 0;
    battleCtx->msgBattlerTemp = defender;
    return TRUE;
}

enum AfterMoveMessageState {
    AFTER_MOVE_MESSAGE_START = 0,

    ONE_HIT_CRITICAL = 0,
    ONE_HIT_STATUS,
    ONE_HIT_TRIGGER_SECONDARY,
    ONE_HIT_SOVEREIGN_ORDER_UP, // Sovereign (item 11)
    ONE_HIT_FORM_CHANGE,
    ONE_HIT_RAGE,
    ONE_HIT_SOVEREIGN_ILLUSION, // Sovereign (item 11)
    ONE_HIT_TRIGGER_ABILITY,
    ONE_HIT_SOVEREIGN_ROCKY_HELMET, // Sovereign (item 11)
    ONE_HIT_SOVEREIGN_BEAK_BLAST, // Sovereign (item 11): and Shell Trap
    ONE_HIT_EXTRA_FLINCH,

    MULTI_HIT_CRITICAL = 0,
    MULTI_HIT_TRIGGER_SECONDARY,
    MULTI_HIT_SOVEREIGN_ORDER_UP, // Sovereign (item 11)
    MULTI_HIT_FORM_CHANGE,
    MULTI_HIT_RAGE,
    MULTI_HIT_SOVEREIGN_ILLUSION, // Sovereign (item 11)
    MULTI_HIT_TRIGGER_ABILITY,
    MULTI_HIT_SOVEREIGN_ROCKY_HELMET, // Sovereign (item 11)
    MULTI_HIT_SOVEREIGN_BEAK_BLAST, // Sovereign (item 11): and Shell Trap
    MULTI_HIT_STATUS,
    MULTI_HIT_EXTRA_FLINCH,
};

static void BattleControllerPlayer_AfterMoveMessage(BattleSystem *battleSys, BattleContext *battleCtx)
{
    switch (battleCtx->afterMoveMessageType) {
    case AFTER_MOVE_MESSAGE_ONE_HIT:
        switch (battleCtx->afterMoveMessageState) {
        case ONE_HIT_CRITICAL:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_CriticalMessage(battleSys, battleCtx) == TRUE) {
                return;
            }

        case ONE_HIT_STATUS:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_FollowupMessage(battleSys, battleCtx) == TRUE) {
                return;
            }

        case ONE_HIT_TRIGGER_SECONDARY:
            int secondaryEffSeq;

            battleCtx->afterMoveMessageState++;
            if (BattleSystem_TriggerSecondaryEffect(battleSys, battleCtx, &secondaryEffSeq) == TRUE
                && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE) {
                LOAD_SUBSEQ(secondaryEffSeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_SOVEREIGN_ORDER_UP:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_OrderUpBoosts(battleCtx)) {
                LOAD_SUBSEQ(subscript_update_stat_stage);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_FORM_CHANGE:
            battleCtx->afterMoveMessageState++;

            // Shaymin changes forms from Sky to Land whenever it is Frozen.
            LOAD_SUBSEQ(subscript_check_shaymin_form);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;

        case ONE_HIT_RAGE:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_RageBuilding(battleSys, battleCtx) == TRUE) {
                return;
            }

        case ONE_HIT_SOVEREIGN_ILLUSION:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_IllusionBroken(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_illusion_end);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_TRIGGER_ABILITY:
            int abilitySeq;

            battleCtx->afterMoveMessageState++;
            if (BattleSystem_TriggerAbilityOnHit(battleSys, battleCtx, &abilitySeq) == TRUE) {
                LOAD_SUBSEQ(abilitySeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_SOVEREIGN_ROCKY_HELMET:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_RockyHelmetHurts(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_rocky_helmet);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_SOVEREIGN_BEAK_BLAST:
            battleCtx->afterMoveMessageState++;
            Sovereign_SpringShellTrap(battleSys, battleCtx);

            if (Sovereign_BeakBlastBurns(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_beak_blast_burn);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case ONE_HIT_EXTRA_FLINCH:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_CheckExtraFlinch(battleSys, battleCtx) == TRUE) {
                return;
            }

        default:
            break;
        }
        break;

    case AFTER_MOVE_MESSAGE_MULTI_HIT:
        switch (battleCtx->afterMoveMessageState) {
        case MULTI_HIT_CRITICAL:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_CriticalMessage(battleSys, battleCtx) == TRUE) {
                return;
            }

        case MULTI_HIT_TRIGGER_SECONDARY:
            int secondaryEffSeq;

            battleCtx->afterMoveMessageState++;
            if (BattleSystem_TriggerSecondaryEffect(battleSys, battleCtx, &secondaryEffSeq) == TRUE
                && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE) {
                LOAD_SUBSEQ(secondaryEffSeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_SOVEREIGN_ORDER_UP:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_OrderUpBoosts(battleCtx)) {
                LOAD_SUBSEQ(subscript_update_stat_stage);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_FORM_CHANGE:
            battleCtx->afterMoveMessageState++;

            // Shaymin changes forms from Sky to Land whenever it is Frozen.
            LOAD_SUBSEQ(subscript_check_shaymin_form);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;

        case MULTI_HIT_RAGE:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_RageBuilding(battleSys, battleCtx) == TRUE) {
                return;
            }

        case MULTI_HIT_SOVEREIGN_ILLUSION:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_IllusionBroken(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_illusion_end);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_TRIGGER_ABILITY:
            int abilitySeq;

            battleCtx->afterMoveMessageState++;
            if (BattleSystem_TriggerAbilityOnHit(battleSys, battleCtx, &abilitySeq) == TRUE) {
                LOAD_SUBSEQ(abilitySeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_SOVEREIGN_ROCKY_HELMET:
            battleCtx->afterMoveMessageState++;
            if (Sovereign_RockyHelmetHurts(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_rocky_helmet);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_SOVEREIGN_BEAK_BLAST:
            battleCtx->afterMoveMessageState++;
            Sovereign_SpringShellTrap(battleSys, battleCtx);

            if (Sovereign_BeakBlastBurns(battleCtx)) {
                LOAD_SUBSEQ(subscript_sovereign_beak_blast_burn);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                return;
            }

        case MULTI_HIT_STATUS:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_FollowupMessage(battleSys, battleCtx) == TRUE) {
                return;
            }

        case MULTI_HIT_EXTRA_FLINCH:
            battleCtx->afterMoveMessageState++;
            if (BattleControllerPlayer_CheckExtraFlinch(battleSys, battleCtx) == TRUE) {
                return;
            }

        default:
            break;
        }
        break;
    }

    battleCtx->afterMoveMessageState = AFTER_MOVE_MESSAGE_START;
    battleCtx->command = BATTLE_CONTROL_AFTER_MOVE_EFFECT;
}

static void BattleControllerPlayer_LeftoverState29(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return;
}

static inline int CalcCurrentMoveType(BattleContext *battleCtx)
{
    // Sovereign (item 11): Normalize, the -ate abilities and Liquid Voice.
    return Sovereign_ElectrifyType(battleCtx, battleCtx->attacker, battleCtx->moveCur,
        Sovereign_AbilityMoveType(Battler_Ability(battleCtx, battleCtx->attacker), battleCtx->moveCur, battleCtx->moveType ? battleCtx->moveType : CURRENT_MOVE_DATA.type));
}

enum AfterMoveEffectState {
    AFTER_MOVE_EFFECT_START = 0,

    AFTER_MOVE_EFFECT_TOGGLE_VANISH_FLAG = AFTER_MOVE_EFFECT_START,
    AFTER_MOVE_EFFECT_SYNCHRONIZE_STATUS,
    AFTER_MOVE_EFFECT_TRIGGER_SWITCH_IN_EFFECTS,
    AFTER_MOVE_EFFECT_ATTACKER_ITEM,
    AFTER_MOVE_EFFECT_DEFENDER_ITEM,
    AFTER_MOVE_EFFECT_TRIGGER_ITEMS_ON_HIT,
    AFTER_MOVE_EFFECT_THAW_DEFENDER,
    AFTER_MOVE_EFFECT_HELD_ITEM_STATUS,

    AFTER_MOVE_EFFECT_END
};

static void BattleControllerPlayer_AfterMoveEffects(BattleSystem *battleSys, BattleContext *battleCtx)
{
    switch (battleCtx->afterMoveEffectState) {
    case AFTER_MOVE_EFFECT_TOGGLE_VANISH_FLAG:
        BOOL anyFlipped = FALSE;
        while (battleCtx->afterMoveEffectTemp < BattleSystem_GetMaxBattlers(battleSys)) {
            if ((battleCtx->battleMons[battleCtx->afterMoveEffectTemp].moveEffectsMask & MOVE_EFFECT_SEMI_INVULNERABLE) == FALSE
                && (battleCtx->battleMons[battleCtx->afterMoveEffectTemp].moveEffectsTemp & MOVE_EFFECT_SEMI_INVULNERABLE)) {
                battleCtx->battleMons[battleCtx->afterMoveEffectTemp].moveEffectsTemp &= ~MOVE_EFFECT_SEMI_INVULNERABLE;

                LOAD_SUBSEQ(subscript_vanish_off);
                battleCtx->msgBattlerTemp = battleCtx->afterMoveEffectTemp;
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                anyFlipped = TRUE;
            }

            battleCtx->afterMoveEffectTemp++;

            if (anyFlipped) {
                return;
            }
        }

        battleCtx->afterMoveEffectState++;
        battleCtx->afterMoveEffectTemp = 0;

    case AFTER_MOVE_EFFECT_SYNCHRONIZE_STATUS:
        battleCtx->afterMoveEffectState++;

        if (BattleSystem_SynchronizeStatus(battleSys, battleCtx, battleCtx->command) == TRUE) {
            return;
        }

    case AFTER_MOVE_EFFECT_TRIGGER_SWITCH_IN_EFFECTS:
        int switchinSeq = BattleSystem_TriggerEffectOnSwitch(battleSys, battleCtx);
        if (switchinSeq) {
            LOAD_SUBSEQ(switchinSeq);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;
        }

        battleCtx->afterMoveEffectState++;

    case AFTER_MOVE_EFFECT_ATTACKER_ITEM:
        battleCtx->afterMoveEffectState++;

        if (BattleSystem_TriggerHeldItem(battleSys, battleCtx, battleCtx->attacker) == TRUE) {
            return;
        }

    case AFTER_MOVE_EFFECT_DEFENDER_ITEM:
        battleCtx->afterMoveEffectState++;

        if (battleCtx->defender != BATTLER_NONE && BattleSystem_TriggerHeldItem(battleSys, battleCtx, battleCtx->defender) == TRUE) {
            return;
        }

    case AFTER_MOVE_EFFECT_TRIGGER_ITEMS_ON_HIT:
        battleCtx->afterMoveEffectState++;

        int itemSeq;
        if (BattleSystem_TriggerHeldItemOnHit(battleSys, battleCtx, &itemSeq) == TRUE) {
            LOAD_SUBSEQ(itemSeq);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;
        }

    case AFTER_MOVE_EFFECT_THAW_DEFENDER:
        int moveType = CalcCurrentMoveType(battleCtx);
        battleCtx->afterMoveEffectState++;

        if (battleCtx->defender != BATTLER_NONE
            && (DEFENDING_MON.status & MON_CONDITION_FREEZE)
            && (battleCtx->moveStatusFlags & MOVE_STATUS_MULTI_HIT_DISRUPTED) == FALSE
            && battleCtx->defender != battleCtx->attacker
            && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
            && DEFENDING_MON.curHP
            && (moveType == TYPE_FIRE // Sovereign (item 11): Scald, Steam Eruption and Scorching Sands thaw it too
                || battleCtx->moveCur == MOVE_SCALD
                || battleCtx->moveCur == MOVE_STEAM_ERUPTION
                || battleCtx->moveCur == MOVE_SCORCHING_SANDS)) {
            battleCtx->msgBattlerTemp = battleCtx->defender;

            LOAD_SUBSEQ(subscript_thaw_out);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;
        }

    case AFTER_MOVE_EFFECT_HELD_ITEM_STATUS:
        int battler;
        BOOL result = FALSE;
        int nextSeq;

        while (battleCtx->afterMoveEffectTemp < BattleSystem_GetMaxBattlers(battleSys)) {
            battler = battleCtx->monSpeedOrder[battleCtx->afterMoveEffectTemp];

            if (battleCtx->battlersSwitchingMask & FlagIndex(battler)) {
                battleCtx->afterMoveEffectTemp++;
                continue;
            }

            battleCtx->afterMoveEffectTemp++;

            if (BattleSystem_TriggerHeldItemOnStatus(battleSys, battleCtx, battler, &nextSeq) == TRUE) {
                battleCtx->msgBattlerTemp = battler;

                LOAD_SUBSEQ(nextSeq);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                result = TRUE;
                break;
            }
        }

        if (result == FALSE) {
            battleCtx->afterMoveEffectState++;
            battleCtx->afterMoveEffectTemp = 0;
        }
        break;

    default:
        break;
    }

    battleCtx->afterMoveEffectState = AFTER_MOVE_EFFECT_START;
    battleCtx->afterMoveEffectTemp = 0;
    battleCtx->command = BATTLE_CONTROL_LOOP_MULTI_HIT;
}

static void BattleControllerPlayer_LeftoverState32(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return;
}

// Sovereign (item 11): Scale Shot changes the user's stats after its last hit.
static int Sovereign_HitXTimesSubscript(BattleContext *battleCtx)
{
    if (battleCtx->moveCur == MOVE_SCALE_SHOT && ATTACKING_MON.curHP) {
        return subscript_sovereign_scale_shot;
    }

    return subscript_hit_x_times;
}

static void BattleControllerPlayer_LoopMultiHit(BattleSystem *battleSys, BattleContext *battleCtx)
{
    // Sovereign (item 11): a Dragon Darts dart on a target of its own shows no hit count.
    if (battleCtx->sovereignDarts != SOVEREIGN_DARTS_NONE && battleCtx->multiHitNumHits == 1) {
        battleCtx->command = BATTLE_CONTROL_LOOP_FAINTED;
        return;
    }

    if (battleCtx->multiHitNumHits) {
        if (battleCtx->faintedMon == BATTLER_NONE
            && (ATTACKING_MON.status & MON_CONDITION_SLEEP) == FALSE // e.g., Effect Spore
            && (battleCtx->moveStatusFlags & MOVE_STATUS_MULTI_HIT_DISRUPTED) == FALSE) {
            if (--battleCtx->multiHitCounter) {
                battleCtx->multiHitLoop = TRUE;
                BattleSystem_SetupLoop(battleSys, battleCtx);

                battleCtx->battleStatusMask &= ~SYSCTL_PLAYED_MOVE_ANIMATION; // force the animation to play again
                battleCtx->multiHitCheckFlags = battleCtx->multiHitAccuracyCheck;

                BattleSystem_LoadScript(battleCtx, NARC_INDEX_BATTLE__SKILL__WAZA_SEQ, battleCtx->moveCur); // reload the move's script
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_TRY_MOVE;
            } else {
                battleCtx->msgTemp = battleCtx->multiHitNumHits;

                LOAD_SUBSEQ(Sovereign_HitXTimesSubscript(battleCtx));
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED;
            }
        } else {
            if (battleCtx->faintedMon != BATTLER_NONE || (ATTACKING_MON.status & MON_CONDITION_SLEEP)) {
                // If an effect (such as Effect Spore) puts the attacker to sleep or the target faints
                // during the multi-hit loop, immediately terminate it.
                battleCtx->msgTemp = battleCtx->multiHitNumHits - battleCtx->multiHitCounter + 1;
            } else {
                battleCtx->msgTemp = battleCtx->multiHitNumHits - battleCtx->multiHitCounter;
            }

            LOAD_SUBSEQ(Sovereign_HitXTimesSubscript(battleCtx));
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            battleCtx->commandNext = BATTLE_CONTROL_LOOP_FAINTED;
        }

        BattleController_EmitClearMessageBox(battleSys);
    } else {
        battleCtx->command = BATTLE_CONTROL_LOOP_FAINTED;
    }
}

static void BattleControllerPlayer_LoopWhileFainted(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->battleStatusMask & SYSCTL_MON_FAINTED) {
        BattleControllerPlayer_AnyFainted(battleCtx, BATTLE_CONTROL_LOOP_FAINTED, BATTLE_CONTROL_LOOP_FAINTED, FALSE);
    } else {
        battleCtx->command = BATTLE_CONTROL_LOOP_SPREAD_MOVES;
    }
}

static void BattleControllerPlayer_LoopSpreadMoves(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->battleStatusMask2 & SYSCTL_MAGIC_COAT_REFLECTED) {
        battleCtx->battleStatusMask2 &= ~SYSCTL_MAGIC_COAT_REFLECTED;
        battleCtx->defender = battleCtx->attacker;
        battleCtx->attacker = battleCtx->magicCoatMon;
    }

    BattleControllerPlayer_UpdateFlagsWhenHit(battleSys, battleCtx);

    // Sovereign (FM): a move that changes the user's form (Relic Song) does it at move end, once it has hit a target.
    if ((battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE
        && Pokemon_SovereignMoveForm(ATTACKING_MON.species, ATTACKING_MON.formNum, battleCtx->moveCur) >= 0) {
        battleCtx->sovereignMoveFormBattler = battleCtx->attacker + 1;
    }

    if (Sovereign_DragonDartsNext(battleSys, battleCtx)) { // Sovereign (item 11)
        BattleController_EmitClearMessageBox(battleSys);
    } else if (Sovereign_MoveRange(battleCtx, battleCtx->attacker, battleCtx->moveCur) == RANGE_ADJACENT_OPPONENTS // Sovereign (item 11)
        && (battleCtx->battleStatusMask & SYSCTL_CHECK_LOOP_ONLY_ONCE) == FALSE
        && battleCtx->battlerCounter < BattleSystem_GetMaxBattlers(battleSys)) {
        battleCtx->multiHitCheckFlags = SYSCTL_HIT_MULTIPLE_TARGETS;

        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys); // unused, but must stay to match
        BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, battleCtx->attacker);
        u8 battlerType = BattlerData_GetBattlerType(battlerData);

        do {
            int battler = battleCtx->monSpeedOrder[battleCtx->battlerCounter++];
            if ((battleCtx->battlersSwitchingMask & FlagIndex(battler)) == FALSE && battleCtx->battleMons[battler].curHP) {
                battlerData = BattleSystem_GetBattlerData(battleSys, battler);

                // Loop back to the start of the move if battlers are on opposite sides
                if (((battlerType & BATTLER_THEM) && (BattlerData_GetBattlerType(battlerData) & BATTLER_THEM) == FALSE)
                    || ((battlerType & BATTLER_THEM) == FALSE && (BattlerData_GetBattlerType(battlerData) & BATTLER_THEM))) {
                    BattleSystem_SetupLoop(battleSys, battleCtx);
                    battleCtx->defender = battler;
                    battleCtx->command = BATTLE_CONTROL_BEFORE_MOVE;
                    break;
                }
            }
        } while (battleCtx->battlerCounter < BattleSystem_GetMaxBattlers(battleSys));

        BattleController_EmitClearMessageBox(battleSys);
    } else if (CURRENT_MOVE_DATA.range == RANGE_ALL_ADJACENT
        && (battleCtx->battleStatusMask & SYSCTL_CHECK_LOOP_ONLY_ONCE) == FALSE
        && battleCtx->battlerCounter < BattleSystem_GetMaxBattlers(battleSys)) {
        battleCtx->multiHitCheckFlags = SYSCTL_HIT_MULTIPLE_TARGETS;
        int maxBattlers = BattleSystem_GetMaxBattlers(battleSys); // unused, but must stay to match.

        do {
            int battler = battleCtx->monSpeedOrder[battleCtx->battlerCounter++];
            if ((battleCtx->battlersSwitchingMask & FlagIndex(battler)) == FALSE
                && battleCtx->battleMons[battler].curHP
                && battler != battleCtx->attacker) {
                BattleSystem_SetupLoop(battleSys, battleCtx);
                battleCtx->defender = battler;
                battleCtx->command = BATTLE_CONTROL_BEFORE_MOVE;
                break;
            }
        } while (battleCtx->battlerCounter < BattleSystem_GetMaxBattlers(battleSys));

        BattleController_EmitClearMessageBox(battleSys);
    } else {
        battleCtx->command = BATTLE_CONTROL_FAINT_AFTER_SELFDESTRUCT;
    }
}

static void BattleControllerPlayer_FaintAfterSelfdestruct(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->battleStatusMask & SYSCTL_MON_SELFDESTRUCTED) {
        battleCtx->faintedMon = LowestBit((battleCtx->battleStatusMask & SYSCTL_MON_SELFDESTRUCTED) >> SYSCTL_MON_SELFDESTRUCTED_SHIFT);
        battleCtx->sovereignSideFaintTurn[battleCtx->faintedMon & 1] = battleCtx->totalTurns + 1; // Sovereign (item 11): Retaliate
        battleCtx->battleStatusMask &= ~SYSCTL_MON_SELFDESTRUCTED;

        LOAD_SUBSEQ(subscript_after_selfdestruct);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_TRIGGER_AFTER_HIT_EFFECTS;
    } else {
        battleCtx->command = BATTLE_CONTROL_TRIGGER_AFTER_HIT_EFFECTS;
    }
}

static void BattleControllerPlayer_TriggerAfterHitEffects(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleControllerPlayer_TriggerAfterMoveHitEffects(battleSys, battleCtx) == TRUE) {
        return;
    }

    battleCtx->command = BATTLE_CONTROL_UPDATE_MOVE_BUFFERS;
}

static void BattleControllerPlayer_LeftoverState37(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return;
}

static void BattleControllerPlayer_UpdateMoveBuffers(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if ((battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN)
        || (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN)) {
        if (Battler_SovereignChoiceLocks(battleCtx, battleCtx->attacker)) { // Sovereign (item 11): Gorilla Tactics too
            if (battleCtx->moveTemp != MOVE_STRUGGLE
                && (battleCtx->moveTemp != MOVE_U_TURN || (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE)
                && (battleCtx->moveTemp != MOVE_BATON_PASS || (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED) == FALSE)) {
                ATTACKING_MON.moveEffectsData.choiceLockedMove = battleCtx->moveTemp;
            }
        } else {
            ATTACKING_MON.moveEffectsData.choiceLockedMove = MOVE_NONE;
        }
    }

    if ((battleCtx->battleStatusMask & SYSCTL_REUSE_LAST_MOVE) == FALSE) {
        if (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN) {
            battleCtx->moveProtect[battleCtx->attacker] = battleCtx->moveCur;
            battleCtx->movePrev = battleCtx->moveTemp;
        } else {
            battleCtx->moveProtect[battleCtx->attacker] = MOVE_NONE;
            battleCtx->movePrev = MOVE_NONE;
        }

        if (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED) {
            battleCtx->movePrevByBattler[battleCtx->attacker] = battleCtx->moveTemp;
        } else {
            battleCtx->movePrevByBattler[battleCtx->attacker] = MOVE_NONE;
        }

        // Sovereign (item 11): Stomping Tantrum and Temper Flare remember a failed move; Round tells its partner's.
        battleCtx->sovereignLastMoveFailed[battleCtx->attacker] = (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED) == FALSE;

        // Sovereign (item 11): Fusion Flare and Fusion Bolt look at the last move that worked this turn; Gigaton Hammer
        // and Blood Moon at the user's last move.
        if (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED) {
            battleCtx->sovereignLastMoveThisTurn = battleCtx->moveTemp;
            battleCtx->sovereignLastMoveTurn = battleCtx->totalTurns + 1;
        }
        if (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN) {
            battleCtx->sovereignLastMoveUsed[battleCtx->attacker] = battleCtx->moveTemp;
        }
        // Sovereign (item 11): until the user's next move, moves never miss it and deal double damage.
        if (battleCtx->moveTemp == MOVE_GLAIVE_RUSH && (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)) {
            battleCtx->sovereignGlaiveRush |= FlagIndex(battleCtx->attacker);
        }
        if (battleCtx->moveTemp == MOVE_BEAK_BLAST) {
            battleCtx->turnFlags[battleCtx->attacker].sovereignBeakBlast = FALSE; // Sovereign (item 11)
        }
        if (battleCtx->moveTemp == MOVE_ROUND && (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN)) {
            Sovereign_CallNextRound(battleSys, battleCtx);
        }

        // Echoed Voice remembers its streak.
        if (battleCtx->moveTemp == MOVE_ECHOED_VOICE && (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)) {
            battleCtx->sovereignEchoedVoiceCount = Sovereign_EchoedVoiceCount(battleCtx);
            battleCtx->sovereignEchoedVoiceTurn = battleCtx->totalTurns + 1;
        }

        // After You and Quash reorder the rest of the turn.
        if ((battleCtx->moveTemp == MOVE_AFTER_YOU || battleCtx->moveTemp == MOVE_QUASH)
            && (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)
            && battleCtx->defender != BATTLER_NONE) {
            Sovereign_ReorderTurn(battleSys, battleCtx, battleCtx->defender, battleCtx->moveTemp == MOVE_QUASH);
        }
    }

    if (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN) {
        battleCtx->moveSketched[battleCtx->attacker] = battleCtx->moveTemp;
    }

    BattleControllerPlayer_UpdateFlagsWhenHit(battleSys, battleCtx);
    BattleSystem_VerifyMetronomeCount(battleSys, battleCtx);

    battleCtx->command = BATTLE_CONTROL_MOVE_END;
}

// Sovereign (FM): the user's move changed its form (Relic Song: Meloetta's Aria and Pirouette Formes). A Pokémon that
// fainted or transformed keeps its form.
static BOOL BattleControllerPlayer_SovereignMoveFormChange(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (battleCtx->sovereignMoveFormBattler == 0) {
        return FALSE;
    }

    int battler = battleCtx->sovereignMoveFormBattler - 1;
    BattleMon *mon = &battleCtx->battleMons[battler];
    int form = Pokemon_SovereignMoveForm(mon->species, mon->formNum, battleCtx->moveCur);

    battleCtx->sovereignMoveFormBattler = 0;
    if (mon->curHP == 0 || (mon->statusVolatile & VOLATILE_CONDITION_TRANSFORM) || form < 0) {
        return FALSE;
    }

    BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battler, form);
    battleCtx->msgBattlerTemp = battler;
    LOAD_SUBSEQ(subscript_form_change);
    battleCtx->commandNext = battleCtx->command;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

    return TRUE;
}

// Sovereign (item 11): sets a battler up to use a move now as an extra action (BattleControllerPlayer_SovereignExtraAction).
// Its turn flag ppDecremented is set aside meanwhile: noPP spares the move's PP.
static void BattleControllerPlayer_SovereignStartExtraAction(BattleSystem *battleSys, BattleContext *battleCtx, int battler, int move, BOOL noPP)
{
    BattleContext_Init(battleCtx);
    battleCtx->sovereignExtraActor = battler + 1;
    battleCtx->sovereignExtraActorPP = battleCtx->turnFlags[battler].ppDecremented;
    battleCtx->turnFlags[battler].ppDecremented = noPP;
    battleCtx->attacker = battler;
    battleCtx->moveTemp = move;
    battleCtx->moveCur = move;
    battleCtx->sovereignHPBeforeAction[battler] = battleCtx->battleMons[battler].curHP; // Emergency Exit
    battleCtx->command = BATTLE_CONTROL_BEFORE_MOVE;
    BattleController_EmitClearMessageBox(battleSys);
}

// Sovereign (item 11): extra actions, run as a move is over and before the turn goes on (BattleControllerPlayer_MoveEnd);
// a battler that hasn't acted yet this turn still gets its own action. Returns TRUE when one starts.
// - Instruct: its target uses its last move again (the target it chose this turn), at its own PP cost.
// - Dancer: when another Pokémon's dance move works, each Dancer in battle copies it, the slowest first, at no PP cost.
//   A copy aims at the move's target when that's a foe of the Dancer's and the Dancer's ally used it, and otherwise at
//   the move's user. A copy sets off no other Dancer.
static BOOL BattleControllerPlayer_SovereignExtraAction(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    int battler, i;

    if (battleCtx->sovereignExtraActor) {
        battleCtx->turnFlags[battleCtx->sovereignExtraActor - 1].ppDecremented = battleCtx->sovereignExtraActorPP;
        battleCtx->sovereignExtraActor = 0;
    }

    if (battleCtx->sovereignDancing == FALSE
        && Sovereign_IsDanceMove(battleCtx->moveCur)
        && (battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)) {
        battleCtx->sovereignDancers = 0;
        battleCtx->sovereignDanceMove = battleCtx->moveCur;
        battleCtx->sovereignDanceUser = battleCtx->attacker;
        battleCtx->sovereignDanceTarget = battleCtx->defender;

        for (i = 0; i < maxBattlers; i++) {
            if (i != battleCtx->attacker
                && battleCtx->battleMons[i].curHP
                && Battler_Ability(battleCtx, i) == ABILITY_DANCER
                && (battleCtx->battleMons[i].moveEffectsMask & MOVE_EFFECT_SEMI_INVULNERABLE) == FALSE) {
                battleCtx->sovereignDancers |= FlagIndex(i);
            }
        }
    }

    battleCtx->sovereignDancing = FALSE;

    if (battleCtx->sovereignInstructed) {
        battler = battleCtx->sovereignInstructed - 1;
        battleCtx->sovereignInstructed = 0;

        if (Sovereign_CanInstruct(battleCtx, battler)) {
            BattleControllerPlayer_SovereignStartExtraAction(battleSys, battleCtx, battler, battleCtx->movePrevByBattler[battler], FALSE);
            battleCtx->defender = BattleSystem_Defender(battleSys, battleCtx, battler, battleCtx->moveTemp, FALSE, 0);
            return TRUE;
        }
    }

    while (battleCtx->sovereignDancers) {
        battler = BATTLER_NONE;

        for (i = 0; i < maxBattlers; i++) {
            if ((battleCtx->sovereignDancers & FlagIndex(i))
                && (battler == BATTLER_NONE || battleCtx->battleMons[i].speed < battleCtx->battleMons[battler].speed)) {
                battler = i;
            }
        }

        battleCtx->sovereignDancers &= ~FlagIndex(battler);

        if (battleCtx->battleMons[battler].curHP && Battler_Ability(battleCtx, battler) == ABILITY_DANCER) {
            int user = battleCtx->sovereignDanceUser;
            int target = battleCtx->sovereignDanceTarget;
            int side = BattleSystem_GetBattlerSide(battleSys, battler);

            BattleControllerPlayer_SovereignStartExtraAction(battleSys, battleCtx, battler, battleCtx->sovereignDanceMove, TRUE);
            battleCtx->sovereignDancing = TRUE;

            if (MOVE_DATA(battleCtx->moveTemp).range == RANGE_SINGLE_TARGET) {
                battleCtx->defender = (target != BATTLER_NONE
                                          && BattleSystem_GetBattlerSide(battleSys, target) != side
                                          && BattleSystem_GetBattlerSide(battleSys, user) == side)
                    ? target
                    : user;

                if (battleCtx->battleMons[battleCtx->defender].curHP == 0) {
                    battleCtx->defender = BattleSystem_Defender(battleSys, battleCtx, battler, battleCtx->moveTemp, TRUE, 0);
                }
            } else {
                battleCtx->defender = BattleSystem_Defender(battleSys, battleCtx, battler, battleCtx->moveTemp, FALSE, 0);
            }

            return TRUE;
        }
    }

    return FALSE;
}

static void BattleControllerPlayer_MoveEnd(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if ((BattleSystem_GetBattleType(battleSys) & BATTLE_TYPE_NO_MOVES) == FALSE) {
        if (BattleSystem_RecoverStatusByAbility(battleSys, battleCtx, battleCtx->attacker, FALSE) == TRUE
            || (battleCtx->defender != BATTLER_NONE
                && BattleSystem_RecoverStatusByAbility(battleSys, battleCtx, battleCtx->defender, FALSE) == TRUE)
            || BattleControllerPlayer_AnyExpPayout(battleCtx, battleCtx->command, battleCtx->command) == TRUE
            || BattleControllerPlayer_CheckBattleOver(battleSys, battleCtx) == TRUE) {
            return;
        }

        int nextSeq = BattleSystem_TriggerEffectOnSwitch(battleSys, battleCtx);
        if (nextSeq) {
            LOAD_SUBSEQ(nextSeq);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            return;
        }

        if (BattleControllerPlayer_ToggleSemiInvulnMons(battleSys, battleCtx) == TRUE) {
            return;
        }

        if (BattleControllerPlayer_SovereignMoveFormChange(battleSys, battleCtx) == TRUE) {
            return;
        }

        // Sovereign (item 11): Emergency Exit and Wimp Out after the user's own damaging move cost it its HP above half
        // (recoil, crash, Life Orb, a Rocky Helmet; not a hit on itself in confusion).
        int user = battleCtx->attacker;

        if ((battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)
            && CURRENT_MOVE_DATA.class != CLASS_STATUS
            && Sovereign_EmergencyExitDue(battleCtx, user, battleCtx->sovereignHPBeforeAction[user])) {
            battleCtx->sovereignHPBeforeAction[user] = 0;
            battleCtx->switchedMon = user;
            LOAD_SUBSEQ(subscript_sovereign_emergency_exit);
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
            return;
        }

        BattleControllerPlayer_ClearFlags(battleSys, battleCtx);
    }

    battleCtx->battlerActions[battleCtx->battlerActionOrder[battleCtx->turnOrderCounter]][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;

    if (BattleControllerPlayer_SovereignExtraAction(battleSys, battleCtx) == TRUE) { // Sovereign (item 11)
        return;
    }

    if (ATTACKER_SELF_TURN_FLAGS.trickRoomActivated) {
        BattleSystem_SortMonActionOrder(battleSys, battleCtx);
        BattleSystem_SortMonSpeedOrder(battleSys, battleCtx);
        battleCtx->turnOrderCounter = 0;
    } else {
        battleCtx->turnOrderCounter++;
    }

    BattleContext_Init(battleCtx);
    battleCtx->command = BATTLE_CONTROL_BRANCH_ACTIONS;
}

static void BattleControllerPlayer_CheckAnyFainted(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleControllerPlayer_AnyFainted(battleCtx, battleCtx->command, battleCtx->command, TRUE) == TRUE) {
        return;
    }

    battleCtx->command = BATTLE_CONTROL_MOVE_END;
}

static void BattleControllerPlayer_HandleResult(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (BattleSystem_GetResultMask(battleSys) & BATTLE_RESULT_TRY_FLEE) {
        battleCtx->command = BATTLE_CONTROL_FIGHT_END;
    } else if (BattleSystem_GetResultMask(battleSys) == BATTLE_RESULT_LOSE
        || BattleSystem_GetResultMask(battleSys) == BATTLE_RESULT_DRAW) {
        LOAD_SUBSEQ(subscript_battle_lost);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_FIGHT_END;
    } else if (BattleSystem_GetResultMask(battleSys) == BATTLE_RESULT_WIN) {
        LOAD_SUBSEQ(subscript_battle_won);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_FIGHT_END;
    } else if (BattleSystem_GetResultMask(battleSys) == BATTLE_RESULT_CAPTURED_MON) {
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = BATTLE_CONTROL_FIGHT_END;
    } else if (BattleSystem_GetResultMask(battleSys) == BATTLE_RESULT_PLAYER_FLED) {
        battleCtx->command = BATTLE_CONTROL_FIGHT_END;
    }

    battleCtx->battleEndFlag = TRUE;
}

static void BattleControllerPlayer_ScreenWipe(BattleSystem *battleSys, BattleContext *battleCtx)
{
    if (IsScreenFadeDone() == TRUE) {
        battleCtx->command = BATTLE_CONTROL_FIGHT_END;
    }
}

static void BattleControllerPlayer_EndFight(BattleSystem *battleSys, BattleContext *battleCtx)
{
    u32 battleType = BattleSystem_GetBattleType(battleSys);

    if ((battleType & BATTLE_TYPE_LINK) == FALSE) {
        Party *playerParty = BattleSystem_GetParty(battleSys, BATTLER_US);
        Pokemon_ApplyPokerus(playerParty);
        Pokemon_ValidatePokerus(playerParty);
    }

    if (battleType & BATTLE_TYPE_LINK) {
        CommSys_SendMessage(22);
    }

    battleCtx->command = BATTLE_CONTROL_END_WAIT;
}

static void BattleControllerPlayer_EndWait(BattleSystem *battleSys, BattleContext *battleCtx)
{
    return;
}

/**
 * @brief Try to replace any and all fainted battlers.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if an interjecting subroutine should be executed.
 */
static BOOL BattleControllerPlayer_ReplaceFainted(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    int i; // must be declared here to match
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    int retCommand = battleCtx->command;

    for (i = 0; i < maxBattlers; i++) {
        battleCtx->battlerStatusFlags[i] &= ~BATTLER_STATUS_SWITCHING;

        if (((battleType & BATTLE_TYPE_DOUBLES) && (battleType & BATTLE_TYPE_2vs2_TAG) == FALSE)
            || ((battleType & BATTLE_TYPE_TAG) && BattleSystem_GetBattlerSide(battleSys, i) == FALSE)) {
            // If both of this side's mons have been defeated, replace slot 1 first.
            if (battleCtx->battleMons[i].curHP == 0 && battleCtx->battleMons[i ^ 2].curHP == 0 && (i & 2)) {
                continue;
            }

            if (battleCtx->battleMons[i].curHP == 0) {
                int j;
                int curHP;
                int totalHP = 0;
                int monsAlive = 0;
                Party *party = BattleSystem_GetParty(battleSys, i);
                BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, i); // this has to go here, even though it's unused

                // Check that there are still living mons in the party.
                for (j = 0; j < Party_GetCurrentCount(party); j++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(party, j);
                    if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != FALSE
                        && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG
                        && (curHP = Pokemon_GetValue(mon, MON_DATA_HP, NULL))) {
                        monsAlive++;
                        if (battleCtx->selectedPartySlot[i ^ 2] != j) {
                            totalHP += curHP;
                        }
                    }
                }

                // Sovereign (decision 18): a fainted Totem calls no more helpers.
                if (BattleSystem_GetBattlerSide(battleSys, i) && BattleSystem_SovereignTotemFainted(battleSys)) {
                    totalHP = 0;
                }

                if (totalHP == 0) {
                    battleCtx->battlersSwitchingMask |= FlagIndex(i); // TODO: rename this field
                    battleCtx->selectedPartySlot[i] = 6;
                } else {
                    battleCtx->commandNext = retCommand;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                    battleCtx->battlerStatusFlags[i] |= BATTLER_STATUS_SWITCHING;
                }
            }
        } else if (battleCtx->battleMons[i].curHP == 0) {
            int j;
            int curHP = 0;
            Party *party = BattleSystem_GetParty(battleSys, i);
            BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, i);

            for (j = 0; j < Party_GetCurrentCount(party); j++) {
                Pokemon *mon = Party_GetPokemonBySlotIndex(party, j);

                if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != FALSE
                    && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG) {
                    curHP += Pokemon_GetValue(mon, MON_DATA_HP, NULL);
                }
            }

            if (curHP == 0) {
                battleCtx->battlersSwitchingMask |= FlagIndex(i);
                battleCtx->selectedPartySlot[i] = 6;
            } else {
                battleCtx->commandNext = retCommand;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
                battleCtx->battlerStatusFlags[i] |= BATTLER_STATUS_SWITCHING;
            }
        }
    }

    if (battleCtx->command == BATTLE_CONTROL_EXEC_SCRIPT) {
        if ((battleType & BATTLE_TYPE_FORCED_SET_MODE) == FALSE
            && BattleSystem_GetBattleStyle(battleSys) == OPTIONS_BATTLE_STYLE_SHIFT
            && ((battleCtx->battlerStatusFlags[0] & BATTLER_STATUS_SWITCHING) == FALSE
                || (battleCtx->battlerStatusFlags[1] & BATTLER_STATUS_SWITCHING) == FALSE)
            && BattleSystem_AnyReplacementMons(battleSys, battleCtx, BATTLER_US)) {
            // If the player is flagged as replacing a fainted mon, then inform the script
            // to skip ahead to showing the party list without prompt.
            if (battleCtx->battlerStatusFlags[0] & BATTLER_STATUS_SWITCHING) {
                battleCtx->scriptTemp = FALSE;
            } else {
                battleCtx->scriptTemp = TRUE;
            }

            LOAD_SUBSEQ(subscript_replace_fainted);
        } else {
            LOAD_SUBSEQ(subscript_show_party_list);
        }

        result = TRUE;
    }

    return result;
}

/**
 * @brief Check if the battle is over.
 *
 * Battle result flags will be updated as part of this routine according to the
 * final state. Additionally, victory music will be loaded according to the
 * defeated trainer's class.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the battle is over (regardless of the result); FALSE if the
 * battle is still in-progress.
 */
static BOOL BattleControllerPlayer_CheckBattleOver(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int i;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    u8 battleResult = BATTLE_IN_PROGRESS;

    for (i = 0; i < maxBattlers; i++) {
        if ((battleType == BATTLE_TYPE_TRAINER_WITH_AI_PARTNER || battleType == BATTLE_TYPE_AI_PARTNER)
            && BattleSystem_GetBattlerSide(battleSys, i) == BATTLER_US) {
            // If the player has no more usable Pokemon in a tag battle with an AI-controlled partner,
            // flag the battle as lost.
            if (BattleSystem_GetBattlerType(battleSys, i) == BATTLER_TYPE_PLAYER_SIDE_SLOT_1
                && battleCtx->battleMons[i].curHP == 0) {
                int totalPartyHP = 0;
                Party *party = BattleSystem_GetParty(battleSys, i);
                BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, i);

                for (int j = 0; j < Party_GetCurrentCount(party); j++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(party, j);
                    if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_NONE
                        && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG) {
                        totalPartyHP += Pokemon_GetValue(mon, MON_DATA_HP, NULL);
                    }
                }

                if (totalPartyHP == 0) {
                    battleResult |= BATTLE_RESULT_LOSE;
                }
            }
        } else if ((battleType & BATTLE_TYPE_2vs2) || ((battleType & BATTLE_TYPE_TAG) && BattleSystem_GetBattlerSide(battleSys, i))) {
            if (battleCtx->battleMons[i].curHP == 0) {
                int totalPartyHP = 0;
                Party *party = BattleSystem_GetParty(battleSys, i);
                Party *partnerParty = BattleSystem_GetParty(battleSys, BattleSystem_GetPartner(battleSys, i));
                BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, i);

                for (int j = 0; j < Party_GetCurrentCount(party); j++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(party, j);
                    if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_NONE
                        && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG) {
                        totalPartyHP += Pokemon_GetValue(mon, MON_DATA_HP, NULL);
                    }
                }

                for (int j = 0; j < Party_GetCurrentCount(partnerParty); j++) {
                    Pokemon *mon = Party_GetPokemonBySlotIndex(partnerParty, j);
                    if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_NONE
                        && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG) {
                        totalPartyHP += Pokemon_GetValue(mon, MON_DATA_HP, NULL);
                    }
                }

                if (totalPartyHP == 0) {
                    if (BattlerData_GetBattlerType(battlerData) & BATTLER_THEM) {
                        battleResult |= BATTLE_RESULT_WIN;
                    } else {
                        battleResult |= BATTLE_RESULT_LOSE;
                    }
                }
            }
        } else if (battleCtx->battleMons[i].curHP == 0) {
            int totalPartyHP = 0;
            Party *party = BattleSystem_GetParty(battleSys, i);
            BattlerData *battlerData = BattleSystem_GetBattlerData(battleSys, i);

            for (int j = 0; j < Party_GetCurrentCount(party); j++) {
                Pokemon *mon = Party_GetPokemonBySlotIndex(party, j);
                if (Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_NONE
                    && Pokemon_GetValue(mon, MON_DATA_SPECIES_OR_EGG, NULL) != SPECIES_EGG) {
                    totalPartyHP += Pokemon_GetValue(mon, MON_DATA_HP, NULL);
                }
            }

            if (totalPartyHP == 0) {
                if (BattlerData_GetBattlerType(battlerData) & BATTLER_THEM) {
                    battleResult |= BATTLE_RESULT_WIN;
                } else {
                    battleResult |= BATTLE_RESULT_LOSE;
                }
            }
        }
    }

    // Sovereign (decision 18): once the Totem has fainted it calls no more helpers, so its trial is won when no wild
    // Pokemon is left standing on the field, even with helpers still in the wild party.
    if (BattleSystem_SovereignTotemFainted(battleSys)
        && battleCtx->battleMons[BATTLER_ENEMY_1].curHP == 0
        && battleCtx->battleMons[BATTLER_ENEMY_2].curHP == 0) {
        battleResult |= BATTLE_RESULT_WIN;
    }

    // Have to keep this ugly double-chain in order to match. Simplified: we win a trainer/frontier battle and it's not
    // a link battle.
    if ((battleResult == BATTLE_RESULT_WIN && (battleType & BATTLE_TYPE_TRAINER) && (battleType & BATTLE_TYPE_LINK) == FALSE)
        || (battleResult == BATTLE_RESULT_WIN && (battleType & BATTLE_TYPE_FRONTIER) && (battleType & BATTLE_TYPE_LINK) == FALSE)) {
        Trainer *trainer = BattleSystem_GetTrainer(battleSys, BATTLER_ENEMY_1);

        switch (trainer->header.trainerType) {
        case TRAINER_CLASS_LEADER_ROARK:
        case TRAINER_CLASS_LEADER_GARDENIA:
        case TRAINER_CLASS_LEADER_WAKE:
        case TRAINER_CLASS_LEADER_MAYLENE:
        case TRAINER_CLASS_LEADER_FANTINA:
        case TRAINER_CLASS_LEADER_CANDICE:
        case TRAINER_CLASS_LEADER_BYRON:
        case TRAINER_CLASS_LEADER_VOLKNER:
            Sound_PlayBGM(VICTORY_GYM_LEADER_sseq);
            break;

        case TRAINER_CLASS_TOWER_TYCOON:
        case TRAINER_CLASS_HALL_MATRON:
        case TRAINER_CLASS_FACTORY_HEAD:
        case TRAINER_CLASS_ARCADE_STAR:
        case TRAINER_CLASS_CASTLE_VALET:
            Sound_PlayBGM(VICTORY_FRONTIER_BRAIN_sseq);
            break;

        case TRAINER_CLASS_CHAMPION_CYNTHIA:
            Sound_PlayBGM(VICTORY_CHAMPION_sseq);
            break;

        case TRAINER_CLASS_COMMANDER_MARS:
        case TRAINER_CLASS_COMMANDER_JUPITER:
        case TRAINER_CLASS_COMMANDER_SATURN:
        case TRAINER_CLASS_GALACTIC_GRUNT_MALE:
        case TRAINER_CLASS_GALACTIC_GRUNT_FEMALE:
            Sound_PlayBGM(VICTORY_GALACTIC_GRUNT_sseq);
            break;

        case TRAINER_CLASS_GALACTIC_BOSS:
            Sound_PlayBGM(VICTORY_CYRUS_sseq);
            break;

        case TRAINER_CLASS_ELITE_FOUR_AARON:
        case TRAINER_CLASS_ELITE_FOUR_BERTHA:
        case TRAINER_CLASS_ELITE_FOUR_FLINT:
        case TRAINER_CLASS_ELITE_FOUR_LUCIAN:
            Sound_PlayBGM(VICTORY_ELITE_FOUR_sseq);
            break;

        default:
            Sound_PlayBGM(VICTORY_TRAINER_sseq);
            break;
        }

        BattleSystem_SetRedHPSoundFlag(battleSys, 2);
    }

    if (battleResult) {
        BattleSystem_SetResultMask(battleSys, battleResult);
    }

    return battleResult != 0;
}

/**
 * @brief Determine if the battler must select its target according to the move
 * selected.
 *
 * @param battleSys
 * @param battleCtx
 * @param battler       The battler choosing its move.
 * @param battleType
 * @param[out] range    Outputs the range of the move being used.
 * @param moveSlot      The slot in the battler's move-pool.
 * @param[out] target   Outputs where to initialize the target selection cursor.
 * @return TRUE if the user must select a target for its move; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_MustSelectTarget(BattleSystem *battleSys, BattleContext *battleCtx, u8 battler, u32 battleType, int *range, int moveSlot, u32 *target)
{
    if (battleCtx->battleMons[battler].moves[moveSlot] == MOVE_CURSE
        && Move_IsGhostCurse(battleCtx, battleCtx->battleMons[battler].moves[moveSlot], battler) == FALSE) {
        *range = RANGE_USER;
    } else {
        *range = MOVE_DATA(battleCtx->battleMons[battler].moves[moveSlot]).range;
    }

    if (battleType & BATTLE_TYPE_DOUBLES) {
        if (*range == RANGE_ALLY) {
            if ((battleCtx->battlersSwitchingMask & FlagIndex(BattleSystem_GetPartner(battleSys, battler))) == FALSE) {
                return TRUE;
            }

            return FALSE;
        }

        return TRUE;
    }

    if (*range & RANGE_MY_SIDE) {
        *target = battler;
    } else {
        *target = battler ^ 1;
    }

    return FALSE;
}

/**
 * @brief Clear flags which dissipate at the end of the turn and any volatile
 * condition flags as requested.
 *
 * @param battleSys
 * @param battleCtx
 */
static void BattleControllerPlayer_ClearFlags(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int i;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);

    for (i = 0; i < maxBattlers; i++) {
        battleCtx->battleMons[i].statusVolatile &= (battleCtx->clearVolatileStatus[i] ^ 0xFFFFFFFF);
        battleCtx->clearVolatileStatus[i] = VOLATILE_CONDITION_NONE;
    }

    battleCtx->moveHit[battleCtx->attacker] = MOVE_NONE;
    battleCtx->conversion2Move[battleCtx->attacker] = MOVE_NONE;
}

/**
 * @brief Check if there are any fainted battlers and load the appropriate
 * subroutine.
 *
 * If a battler is fainted, then its command will be re-assigned so as to flag
 * it as functionally done for the turn.
 *
 * @param battleCtx
 * @param nextCmd           The next command to queue if a battler has fainted.
 * @param nextCmdNoFainted  The next command to queue if no battler has fainted.
 * @param onlyFaint         If TRUE, then standard FAINT_MON subroutine will be
 *                          loaded if any battler has fainted. If FALSE, then the
 *                          subroutine which checks for on-faint triggers will be
 *                          loaded instead (e.g., Destiny Bond, Grudge).
 * @return TRUE if any battler has fainted; FALSE if none have fainted.
 */
static BOOL BattleControllerPlayer_AnyFainted(BattleContext *battleCtx, int nextCmd, int nextCmdNoFainted, BOOL onlyFaint)
{
    int i = 0;
    int battlerBit = FlagIndex(battleCtx->monSpeedOrder[i]) << SYSCTL_MON_FAINTED_SHIFT;
    if (battleCtx->battleStatusMask & SYSCTL_MON_FAINTED) {
        // Faint battlers in speed order
        while ((battleCtx->battleStatusMask & battlerBit) == FALSE) {
            i++;
            battlerBit = FlagIndex(battleCtx->monSpeedOrder[i]) << SYSCTL_MON_FAINTED_SHIFT;
        }

        battleCtx->battleStatusMask &= (battlerBit ^ 0xFFFFFFFF);
        battleCtx->faintedMon = LowestBit(battlerBit >> SYSCTL_MON_FAINTED_SHIFT);
        battleCtx->sovereignSideFaintTurn[battleCtx->faintedMon & 1] = battleCtx->totalTurns + 1; // Sovereign (item 11): Retaliate

        if (onlyFaint == TRUE) {
            LOAD_SUBSEQ(subscript_faint_mon);
        } else {
            LOAD_SUBSEQ(subscript_faint_check_destiny_bond);
        }

        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = nextCmd;
        battleCtx->battlerActions[battleCtx->faintedMon][BATTLE_ACTION_PICK_COMMAND] = BATTLE_CONTROL_MOVE_END;

        return TRUE;
    }

    battleCtx->command = nextCmdNoFainted;
    return FALSE;
}

/**
 * @brief Check if any battlers should be paid experience points and load the
 * appropriate subroutine.
 *
 * @param battleCtx
 * @param nextCmd       The next command to queue if a battler has fainted.
 * @param nextCmdNoExp  The next command to queue if no battler has fainted.
 * @return TRUE if the exp payout subroutine should be invoked; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_AnyExpPayout(BattleContext *battleCtx, int nextCmd, int nextCmdNoExp)
{
    if (battleCtx->battleStatusMask2 & SYSCTL_PAYOUT_EXP) {
        int battler = 1 << SYSCTL_PAYOUT_EXP_SHIFT;
        while ((battleCtx->battleStatusMask2 & battler) == FALSE) {
            battler = battler << 1;
        }

        battleCtx->battleStatusMask2 &= (battler ^ 0xFFFFFFFF);
        battleCtx->faintedMon = LowestBit(battler >> SYSCTL_PAYOUT_EXP_SHIFT);

        LOAD_SUBSEQ(subscript_grant_exp);
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        battleCtx->commandNext = nextCmd;

        return TRUE;
    }

    battleCtx->command = nextCmdNoExp;
    return FALSE;
}

/**
 * @brief Update any and all flags appropriate to being hit by a move.
 *
 * @param battleSys
 * @param battleCtx
 */
static void BattleControllerPlayer_UpdateFlagsWhenHit(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int moveType = CalcCurrentMoveType(battleCtx);
    if ((MOVE_DATA(battleCtx->moveTemp).flags & MOVE_FLAG_CAN_MIRROR_MOVE)
        && (battleCtx->battleStatusMask & SYSCTL_REUSE_LAST_MOVE) == FALSE
        && battleCtx->defender != BATTLER_NONE
        && battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN) {
        battleCtx->moveCopied[battleCtx->defender] = battleCtx->moveTemp;
        battleCtx->moveCopiedHit[battleCtx->defender][battleCtx->attacker] = battleCtx->moveTemp;
    }

    if (battleCtx->defender != BATTLER_NONE) {
        if (((battleCtx->battleStatusMask & SYSCTL_FIRST_OF_MULTI_TURN)
                || (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN))
            && Battler_SovereignChoiceLocks(battleCtx, battleCtx->defender) == FALSE) { // Sovereign (item 11)
            DEFENDING_MON.moveEffectsData.choiceLockedMove = MOVE_NONE;
        }

        if ((battleCtx->battleStatusMask & SYSCTL_REUSE_LAST_MOVE) == FALSE) {
            if (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN) {
                battleCtx->moveHit[battleCtx->defender] = battleCtx->moveCur;
                battleCtx->moveHitBattler[battleCtx->defender] = battleCtx->attacker;
                battleCtx->moveHitType[battleCtx->defender] = moveType;
                battleCtx->movePrev = battleCtx->moveTemp;
            } else {
                battleCtx->moveHit[battleCtx->defender] = MOVE_NONE;
                battleCtx->moveHitBattler[battleCtx->defender] = BATTLER_NONE;
                battleCtx->moveHitType[battleCtx->defender] = TYPE_NORMAL;
                battleCtx->movePrev = MOVE_NONE;
            }

            if ((battleCtx->battleStatusMask2 & SYSCTL_MOVE_SUCCEEDED)
                && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE) {
                switch (CURRENT_MOVE_DATA.range) {
                case RANGE_USER:
                case RANGE_USER_SIDE:
                case RANGE_FIELD:
                case RANGE_OPPONENT_SIDE:
                case RANGE_ALLY:
                case RANGE_USER_OR_ALLY:
                    battleCtx->conversion2Move[battleCtx->defender] = MOVE_NONE;
                    battleCtx->conversion2Battler[battleCtx->defender] = BATTLER_NONE;
                    battleCtx->conversion2Type[battleCtx->defender] = TYPE_NORMAL;
                    break;

                default:
                    battleCtx->conversion2Move[battleCtx->defender] = battleCtx->moveCur;
                    battleCtx->conversion2Battler[battleCtx->defender] = battleCtx->attacker;
                    battleCtx->conversion2Type[battleCtx->defender] = moveType;
                    break;
                }
            } else {
                battleCtx->conversion2Move[battleCtx->defender] = MOVE_NONE;
                battleCtx->conversion2Battler[battleCtx->defender] = BATTLER_NONE;
                battleCtx->conversion2Type[battleCtx->defender] = TYPE_NORMAL;
            }
        }
    }
}

/**
 * @brief Load the Critical Hit message subroutine.
 *
 * @param battleSys
 * @param battleCtx
 * @return Always TRUE.
 */
static BOOL BattleControllerPlayer_CriticalMessage(BattleSystem *battleSys, BattleContext *battleCtx)
{
    LOAD_SUBSEQ(subscript_critical_hit);
    battleCtx->commandNext = battleCtx->command;
    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

    return TRUE;
}

/**
 * @brief Load the follow-up message subroutine.
 *
 * This subroutine is responsible for displaying messages such as the "But
 * nothing happened!" message for Splash, "It's a one-hit KO!" for OHKO moves,
 * and the effectiveness-messages that display after a move hits.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the follow-up subroutine should be executed; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_FollowupMessage(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    if (battleCtx->moveStatusFlags) {
        if (battleCtx->multiHitNumHits) {
            if (battleCtx->faintedMon != BATTLER_NONE
                || battleCtx->multiHitCounter == 1
                || (battleCtx->moveStatusFlags & MOVE_STATUS_MULTI_HIT_DISRUPTED)) {
                result = TRUE;
            }
        } else {
            result = TRUE;
        }
    }

    if (result == TRUE) {
        LOAD_SUBSEQ(subscript_move_followup_message);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
    }

    return result;
}

/**
 * @brief Load the Rage Is Building subroutine sequence, if applicable.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the subroutine was loaded for execution; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_RageBuilding(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    if (battleCtx->defender == BATTLER_NONE) {
        return result;
    }

    if ((DEFENDING_MON.statusVolatile & VOLATILE_CONDITION_RAGE)
        && (battleCtx->moveStatusFlags & MOVE_STATUS_MULTI_HIT_DISRUPTED) == FALSE
        && battleCtx->defender != battleCtx->attacker
        && DEFENDING_MON.curHP
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK] < 12) {
        DEFENDING_MON.statBoosts[BATTLE_STAT_ATTACK]++;

        LOAD_SUBSEQ(subscript_rage_is_building);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;
        result = TRUE;
    }

    return result;
}

/**
 * @brief Check if an additional flinch effect should be applied due to King's
 * Rock.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if the flinch should be applied; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_CheckExtraFlinch(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    int itemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->attacker);
    int itemPower = Battler_HeldItemPower(battleCtx, battleCtx->attacker, 0);

    if (battleCtx->defender != BATTLER_NONE
        && itemEffect == HOLD_EFFECT_SOMETIMES_FLINCH
        && (battleCtx->moveStatusFlags & MOVE_STATUS_NO_EFFECTS) == FALSE
        && (DEFENDER_SELF_TURN_FLAGS.physicalDamageTaken || DEFENDER_SELF_TURN_FLAGS.specialDamageTaken)
        && (BattleSystem_RandNext(battleSys) % 100) < itemPower
        && (CURRENT_MOVE_DATA.flags & MOVE_FLAG_TRIGGERS_KINGS_ROCK)
        && DEFENDING_MON.curHP) {
        battleCtx->sideEffectMon = battleCtx->defender;
        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;

        LOAD_SUBSEQ(subscript_flinch_mon);
        battleCtx->commandNext = battleCtx->command;
        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

        result = TRUE;
    }

    return result;
}

/**
 * @brief Toggles the visibility of a semi-invulnerable battler off.
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if a semi-invulnerable battler should be made visible; FALSE
 * otherwise.
 */
static BOOL BattleControllerPlayer_ToggleSemiInvulnMons(BattleSystem *battleSys, BattleContext *battleCtx)
{
    BOOL result = FALSE;
    while (battleCtx->vanishedCheckTemp < BattleSystem_GetMaxBattlers(battleSys)) {
        if ((battleCtx->battleMons[battleCtx->vanishedCheckTemp].moveEffectsMask & MOVE_EFFECT_SEMI_INVULNERABLE) == FALSE
            && (battleCtx->battleMons[battleCtx->vanishedCheckTemp].moveEffectsTemp & MOVE_EFFECT_SEMI_INVULNERABLE)) {
            battleCtx->battleMons[battleCtx->vanishedCheckTemp].moveEffectsTemp &= ~MOVE_EFFECT_SEMI_INVULNERABLE;

            LOAD_SUBSEQ(subscript_vanish_off);
            battleCtx->msgBattlerTemp = battleCtx->vanishedCheckTemp;
            battleCtx->commandNext = battleCtx->command;
            battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

            result = TRUE;
        }

        battleCtx->vanishedCheckTemp++;
        if (result == TRUE) {
            break;
        }
    }

    if (result == FALSE) {
        battleCtx->vanishedCheckTemp = 0;
    }

    return result;
}

enum AfterMoveHitState {
    AFTER_MOVE_HIT_START = 0,

    AFTER_MOVE_HIT_STATE_RAGE = AFTER_MOVE_HIT_START,
    AFTER_MOVE_HIT_STATE_SHELL_BELL,
    AFTER_MOVE_HIT_STATE_LIFE_ORB,
    AFTER_MOVE_HIT_STATE_KNOCKOUT_ABILITY, // Sovereign (item 11)
    AFTER_MOVE_HIT_STATE_DEFIANT, // Sovereign (item 11)
    AFTER_MOVE_HIT_STATE_SOVEREIGN_ITEMS, // Sovereign (item 11)

    AFTER_MOVE_HIT_STATE_END
};

/**
 * @brief Trigger effects which apply after a move hits its target.
 *
 * This handles:
 * - turning off the Rage flag if the attacker did not use Rage again
 * - granting Shell Bell HP restoration
 * - deducting HP due to Life Orb
 *
 * @param battleSys
 * @param battleCtx
 * @return TRUE if any interjecting subroutine must be executed; FALSE otherwise.
 */
static BOOL BattleControllerPlayer_TriggerAfterMoveHitEffects(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int machineState = STATE_PROCESSING;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys); // unused, but must remain to match
    int itemEffect = Battler_HeldItemEffect(battleCtx, battleCtx->attacker);
    int itemPower = Battler_HeldItemPower(battleCtx, battleCtx->attacker, 0);

    if (BattleControllerPlayer_AnyFainted(battleCtx, battleCtx->command, battleCtx->command, TRUE) == TRUE) {
        return TRUE;
    }

    do {
        switch (battleCtx->afterMoveHitCheckState) {
        case AFTER_MOVE_HIT_STATE_RAGE:
            if ((ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_RAGE) && battleCtx->moveCur != MOVE_RAGE) {
                ATTACKING_MON.statusVolatile &= ~VOLATILE_CONDITION_RAGE;
            }

            battleCtx->afterMoveHitCheckState++;
            break;

        case AFTER_MOVE_HIT_STATE_SHELL_BELL:
            if (battleCtx->defender != BATTLER_NONE
                && itemEffect == HOLD_EFFECT_HP_RESTORE_ON_DMG
                && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
                && (battleCtx->battleStatusMask & SYSCTL_MOVE_HIT)
                && ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt
                && battleCtx->attacker != battleCtx->defender
                && ATTACKING_MON.curHP < ATTACKING_MON.maxHP
                && ATTACKING_MON.curHP) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(ATTACKER_SELF_TURN_FLAGS.shellBellDamageDealt * -1, itemPower);
                battleCtx->msgBattlerTemp = battleCtx->attacker;

                LOAD_SUBSEQ(subscript_restore_a_little_hp);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                machineState = STATE_BREAK_OUT;
            }

            battleCtx->afterMoveHitCheckState++;
            break;

        case AFTER_MOVE_HIT_STATE_LIFE_ORB:
            if (itemEffect == HOLD_EFFECT_HP_DRAIN_ON_ATK
                && Battler_Ability(battleCtx, battleCtx->attacker) != ABILITY_MAGIC_GUARD
                && Move_SheerForceApplies(battleCtx, battleCtx->attacker, battleCtx->moveCur) == FALSE // Sovereign (item 11)
                && (battleCtx->battleStatusMask2 & SYSCTL_UTURN_ACTIVE) == FALSE
                && (battleCtx->battleStatusMask & SYSCTL_MOVE_HIT)
                && CURRENT_MOVE_DATA.class != CLASS_STATUS
                && ATTACKING_MON.curHP) {
                battleCtx->hpCalcTemp = BattleSystem_Divide(battleCtx->battleMons[battleCtx->attacker].maxHP * -1, 10);
                battleCtx->msgBattlerTemp = battleCtx->attacker;

                LOAD_SUBSEQ(subscript_lose_hp_from_item);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                machineState = STATE_BREAK_OUT;
            }

            battleCtx->afterMoveHitCheckState++;
            break;

        case AFTER_MOVE_HIT_STATE_KNOCKOUT_ABILITY: {
            // Sovereign (item 11): Moxie, Chilling Neigh, Grim Neigh (and As One, which has one of them) and Beast Boost
            // raise a stat for each foe the move knocked out. afterMoveHitCheckTemp marks the foes already counted.
            int ability = Battler_Ability(battleCtx, battleCtx->attacker);
            int foe, stat = -1;
            BOOL fellStinger = battleCtx->moveCur == MOVE_FELL_STINGER; // Sovereign (item 11): Attack +3 on a knockout

            if ((ability == ABILITY_MOXIE || ability == ABILITY_CHILLING_NEIGH || ability == ABILITY_GRIM_NEIGH || ability == ABILITY_BEAST_BOOST
                    || ability == ABILITY_AS_ONE_GLASTRIER || ability == ABILITY_AS_ONE_SPECTRIER || ability == ABILITY_EELEVATE || ability == ABILITY_BATTLE_BOND
                    || fellStinger)
                && ATTACKING_MON.curHP) {
                for (foe = 0; foe < maxBattlers; foe++) {
                    if ((battleCtx->afterMoveHitCheckTemp & FlagIndex(foe)) == FALSE
                        && BattleSystem_GetBattlerSide(battleSys, foe) != BattleSystem_GetBattlerSide(battleSys, battleCtx->attacker)
                        && battleCtx->battleMons[foe].curHP == 0
                        && ((battleCtx->selfTurnFlags[foe].physicalDamageTaken && battleCtx->selfTurnFlags[foe].physicalDamageLastAttacker == battleCtx->attacker)
                            || (battleCtx->selfTurnFlags[foe].specialDamageTaken && battleCtx->selfTurnFlags[foe].specialDamageLastAttacker == battleCtx->attacker))) {
                        battleCtx->afterMoveHitCheckTemp |= FlagIndex(foe);
                        break;
                    }
                }

                // Sovereign (FM): Battle Bond makes Greninja Ash-Greninja when its move knocks out a foe.
                if (foe < maxBattlers && ability == ABILITY_BATTLE_BOND && fellStinger == FALSE) {
                    int ashForm = Pokemon_SovereignAbilityForm(ATTACKING_MON.species, ATTACKING_MON.formNum, ABILITY_BATTLE_BOND);

                    if (ashForm >= 0 && (ATTACKING_MON.statusVolatile & VOLATILE_CONDITION_TRANSFORM) == FALSE) {
                        BattleSystem_SovereignChangeBattleForm(battleSys, battleCtx, battleCtx->attacker, ashForm);
                        battleCtx->msgBattlerTemp = battleCtx->attacker;

                        LOAD_SUBSEQ(subscript_sovereign_battle_bond);
                        battleCtx->commandNext = battleCtx->command;
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                        machineState = STATE_BREAK_OUT;
                    }
                    break; // stay in this state to look for another knocked-out foe
                }

                if (foe < maxBattlers && fellStinger) {
                    if (ATTACKING_MON.statBoosts[BATTLE_STAT_ATTACK] < 12) { // MAX_STAT_STAGE
                        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_INDIRECT;
                        battleCtx->sideEffectMon = battleCtx->attacker;

                        LOAD_SUBSEQ(subscript_sovereign_fell_stinger);
                        battleCtx->commandNext = battleCtx->command;
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                        machineState = STATE_BREAK_OUT;
                    }
                    break; // stay in this state to look for another knocked-out foe
                } else if (foe < maxBattlers) {
                    if (ability == ABILITY_MOXIE || ability == ABILITY_CHILLING_NEIGH || ability == ABILITY_AS_ONE_GLASTRIER) {
                        stat = BATTLE_STAT_ATTACK;
                    } else if (ability == ABILITY_GRIM_NEIGH || ability == ABILITY_AS_ONE_SPECTRIER) {
                        stat = BATTLE_STAT_SP_ATTACK;
                    } else {
                        // Beast Boost: the highest of Attack, Defense, Sp. Atk, Sp. Def and Speed (ties go to the first).
                        u16 stats[5] = { ATTACKING_MON.attack, ATTACKING_MON.defense, ATTACKING_MON.spAttack, ATTACKING_MON.spDefense, ATTACKING_MON.speed };
                        u8 statIDs[5] = { BATTLE_STAT_ATTACK, BATTLE_STAT_DEFENSE, BATTLE_STAT_SP_ATTACK, BATTLE_STAT_SP_DEFENSE, BATTLE_STAT_SPEED };
                        int best = 0;
                        for (int i = 1; i < 5; i++) {
                            if (stats[i] > stats[best]) {
                                best = i;
                            }
                        }
                        stat = statIDs[best];
                    }

                    if (ATTACKING_MON.statBoosts[stat] < 12) { // MAX_STAT_STAGE
                        battleCtx->sideEffectParam = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE + (stat - BATTLE_STAT_ATTACK);
                        battleCtx->sideEffectType = SIDE_EFFECT_TYPE_ABILITY;
                        battleCtx->sideEffectMon = battleCtx->attacker;

                        LOAD_SUBSEQ(subscript_update_stat_stage);
                        battleCtx->commandNext = battleCtx->command;
                        battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                        machineState = STATE_BREAK_OUT;
                    }
                    break; // stay in this state to look for another knocked-out foe
                }
            }

            battleCtx->afterMoveHitCheckState++;
            break;
        }

        case AFTER_MOVE_HIT_STATE_DEFIANT: {
            // Sovereign (item 11): Defiant (Attack +2) and Competitive (Sp. Atk +2) after a foe's move lowered a stat, and
            // Defiant, Competitive or Rattled after an Intimidate mid-turn.
            int battler;

            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->sovereignDefiantPending & FlagIndex(battler)) {
                    break;
                }
            }

            if (battler < maxBattlers) {
                battleCtx->sovereignDefiantPending &= ~FlagIndex(battler);

                if (Sovereign_SetupStatDropReaction(battleCtx, battler)) {
                    LOAD_SUBSEQ(subscript_update_stat_stage);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    machineState = STATE_BREAK_OUT;
                }
                break; // stay in this state for any other pending battler
            }

            // Sovereign (item 11): the Adrenaline Orb after an Intimidate mid-turn.
            for (battler = 0; battler < maxBattlers; battler++) {
                if (battleCtx->sovereignAdrenalinePending & FlagIndex(battler)) {
                    break;
                }
            }

            if (battler < maxBattlers) {
                battleCtx->sovereignAdrenalinePending &= ~FlagIndex(battler);

                if (Sovereign_SetupAdrenalineOrb(battleCtx, battler)) {
                    LOAD_SUBSEQ(subscript_sovereign_item_stat_up);
                    battleCtx->commandNext = battleCtx->command;
                    battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                    machineState = STATE_BREAK_OUT;
                }
                break; // stay in this state for any other pending battler
            }

            battleCtx->afterMoveHitCheckState++;
            break;
        }

        case AFTER_MOVE_HIT_STATE_SOVEREIGN_ITEMS: {
            // Sovereign (item 11): the attacker's held items that act after its move, then are used up: Throat Spray
            // (Sp. Atk +1 after a sound move that worked) and Blunder Policy (Speed +2 after a move that missed).
            int item = Battler_HeldItem(battleCtx, battleCtx->attacker);
            int stat = -1;
            int param = MOVE_SUBSCRIPT_PTR_ATTACK_UP_1_STAGE;

            if (item == ITEM_THROAT_SPRAY
                && Move_IsSound(battleCtx->moveCur)
                && (battleCtx->battleStatusMask2 & SYSCTL_ATTACK_MESSAGE_SHOWN)
                && (battleCtx->moveStatusFlags & MOVE_STATUS_DID_NOT_HIT) == FALSE) {
                stat = BATTLE_STAT_SP_ATTACK;
            } else if (item == ITEM_BLUNDER_POLICY && (battleCtx->moveStatusFlags & MOVE_STATUS_MISSED)) {
                stat = BATTLE_STAT_SPEED;
                param = MOVE_SUBSCRIPT_PTR_ATTACK_UP_2_STAGES;
            }

            battleCtx->afterMoveHitCheckState++;

            if (stat >= 0 && ATTACKING_MON.curHP && ATTACKING_MON.statBoosts[stat] < 12) { // MAX_STAT_STAGE
                battleCtx->msgBattlerTemp = battleCtx->attacker;
                battleCtx->msgItemTemp = item;
                battleCtx->sideEffectParam = param + (stat - BATTLE_STAT_ATTACK);
                battleCtx->msgTemp = 0;

                LOAD_SUBSEQ(subscript_sovereign_item_stat_up);
                battleCtx->commandNext = battleCtx->command;
                battleCtx->command = BATTLE_CONTROL_EXEC_SCRIPT;

                machineState = STATE_BREAK_OUT;
            }
            break;
        }

        case AFTER_MOVE_HIT_STATE_END:
            battleCtx->afterMoveHitCheckState = 0;
            battleCtx->afterMoveHitCheckTemp = 0;
            machineState = STATE_DONE;
            break;
        }
    } while (machineState == STATE_PROCESSING);

    return machineState == STATE_BREAK_OUT;
}

/**
 * @brief Initialize the battle AI with appropriate items from loaded trainer
 * data.
 *
 * @param battleSys
 * @param battleCtx
 */
static void BattleControllerPlayer_InitAI(BattleSystem *battleSys, BattleContext *battleCtx)
{
    u32 battleType = BattleSystem_GetBattleType(battleSys);
    MI_CpuClear32(&battleCtx->aiContext, sizeof(AIContext));

    if ((battleType & BATTLE_TYPE_TRAINER) && (battleType & BATTLE_TYPE_NO_AI_ITEMS) == FALSE) {
        for (int battler = 0; battler < MAX_BATTLERS; battler++) {
            if (battler & BATTLER_THEM) {
                // Only enemy AI can use items
                for (int i = 0; i < MAX_TRAINER_ITEMS; i++) {
                    u16 item = BattleSystem_GetTrainerItem(battleSys, battler, i);
                    if (item != ITEM_NONE) {
                        battleCtx->aiContext.trainerItems[battler >> 1][battleCtx->aiContext.trainerItemCounts[battler >> 1]] = item;
                        battleCtx->aiContext.trainerItemCounts[battler >> 1]++;
                    }
                }
            }
        }
    }

    battleCtx->aiScriptTemp = gTrainerAITable;
}

static void BattleSystem_RecordCommand(BattleSystem *battleSys, BattleContext *battleCtx)
{
    int battler;
    int maxBattlers = BattleSystem_GetMaxBattlers(battleSys);
    u8 recordedAction;

    for (battler = 0; battler < maxBattlers; battler++) {
        if (battleCtx->battlerActions[battler][0] != BATTLE_CONTROL_MOVE_END) {
            if (battleCtx->recordedCommandFlags[battler] & RECORDED_CMD_FLAG_ACTION) {
                recordedAction = (battleCtx->battlerActions[battler][0] - BATTLE_CONTROL_FIGHT) + 1;
                BattleSystem_Record(battleSys, battler, recordedAction);
            }

            switch (battleCtx->battlerActions[battler][0]) {
            case BATTLE_CONTROL_FIGHT:
                if (battleCtx->recordedCommandFlags[battler] & RECORDED_CMD_FLAG_TARGET) {
                    recordedAction = battleCtx->battlerActions[battler][2];

                    // Sovereign (E8): the move slot's top bit records a Mega Evolution (Task_RecordingShowMoveSelectMenu).
                    if (battleCtx->sovereignMegaPending & FlagIndex(battler)) {
                        recordedAction |= 0x80;
                    }

                    BattleSystem_Record(battleSys, battler, recordedAction);
                }

                if (battleCtx->recordedCommandFlags[battler] & RECORDED_CMD_FLAG_MOVE_SLOT) {
                    recordedAction = battleCtx->battlerActions[battler][1] + 1;
                    BattleSystem_Record(battleSys, battler, recordedAction);
                }
                break;
            case BATTLE_CONTROL_ITEM:
                recordedAction = battleCtx->battlerActions[battler][2] & 0xff;
                BattleSystem_Record(battleSys, battler, recordedAction);
                recordedAction = (battleCtx->battlerActions[battler][2] & 0xff00) >> 16;
                BattleSystem_Record(battleSys, battler, recordedAction);
                break;
            case BATTLE_CONTROL_PARTY:
                recordedAction = battleCtx->battlerActions[battler][2] + 1;
                BattleSystem_Record(battleSys, battler, recordedAction);
                break;
            case BATTLE_CONTROL_RUN:
                BattleSystem_Record(battleSys, battler, 1);
                break;
            default:
                break;
            }
        }
    }
}// Sovereign (item 11): moves that thaw out a frozen user (Gen IX's defrost moves).
static BOOL Sovereign_MoveThawsUser(int move, int moveEffect)
{
    switch (move) {
    case MOVE_FUSION_FLARE:
    case MOVE_SCALD:
    case MOVE_STEAM_ERUPTION:
    case MOVE_BURN_UP:
    case MOVE_SCORCHING_SANDS:
    case MOVE_PYRO_BALL:
    case MOVE_MATCHA_GOTCHA:
        return TRUE;
    }

    return moveEffect == BATTLE_EFFECT_THAW_AND_BURN_HIT || moveEffect == BATTLE_EFFECT_RECOIL_BURN_HIT;
}


