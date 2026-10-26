#include "macros/btlcmd.inc"


_000:
    CheckSubstitute BTLSCR_DEFENDER, _015
    CheckAbility CHECK_HAVE, BTLSCR_DEFENDER, ABILITY_COMATOSE, _sovereign_asleep // Sovereign (item 11): Comatose is as if asleep
    CompareMonDataToValue OPCODE_FLAG_NOT, BTLSCR_DEFENDER, BATTLEMON_STATUS, MON_CONDITION_SLEEP, _015

_sovereign_asleep:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_DREAM_EATER
    CalcCrit 
    CalcDamage 
    End 

_015:
    PrintAttackMessage 
    Wait 
    WaitButtonABTime 30
    // {0} wasn’t affected!
    PrintMessage BattleStrings_Text_PokemonWasntAffected_Ally, TAG_NICKNAME, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_NO_MORE_WORK
    End 
