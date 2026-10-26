#include "macros/btlcmd.inc"

// Sovereign (item 11): Dragon Tail and Circle Throw drag the target out after the hit (from
// subscript_force_target_to_switch_or_flee, without its messages when it can't).

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_CUR_HP, 0, _end
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_DEFENDER, ABILITY_SUCTION_CUPS, _end
    CheckIgnorableAbility CHECK_HAVE, BTLSCR_DEFENDER, ABILITY_GUARD_DOG, _end // Sovereign (item 11)
    CompareMonDataToValue OPCODE_EQU, BTLSCR_DEFENDER, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_INGRAIN, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_DOUBLES|BATTLE_TYPE_2vs2|BATTLE_TYPE_AI, _end
    TryWhirlwind _end
    TryRestoreStatusOnSwitch BTLSCR_DEFENDER, _switch
    UpdateMonData OPCODE_SET, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_NONE

_switch:
    DeletePokemon BTLSCR_DEFENDER
    Wait 
    CompareVarToValue OPCODE_FLAG_NOT, BTLVAR_BATTLE_TYPE, BATTLE_TYPE_TRAINER, _flee
    HealthBoxSlideOut BTLSCR_DEFENDER
    Wait 
    SwitchAndUpdateMon BTLSCR_FORCED_OUT
    Wait 
    PokemonSendOut BTLSCR_DEFENDER
    WaitTime 72
    HealthBoxSlideIn BTLSCR_DEFENDER
    Wait 
    // {0} was dragged out!
    PrintMessage BattleStrings_Text_PokemonWasDraggedOut_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    UpdateVarFromVar OPCODE_SET, BTLVAR_SWITCHED_MON, BTLVAR_DEFENDER
    Call BATTLE_SUBSCRIPT_HAZARDS_CHECK
    End 

_flee:
    FadeOutBattle 
    Wait 
    UpdateVar OPCODE_FLAG_ON, BTLVAR_RESULT_MASK, BATTLE_RESULT_PLAYER_FLED

_end:
    End 
