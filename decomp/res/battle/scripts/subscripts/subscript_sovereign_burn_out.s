#include "macros/btlcmd.inc"

// Sovereign (item 11): after Burn Up (Fire) or Double Shock (Electric) hits, the user loses that type. With another
// type it keeps only that one (in both slots); with none it becomes typeless (TYPE_SOVEREIGN_TYPELESS, both slots).
// As with any type change, a type added by Trick-or-Treat or Forest's Curse goes too. Switching out restores its
// types. Arceus and Silvally keep theirs (Multitype, RKS System).

_000:
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPECIES, SPECIES_ARCEUS, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_SPECIES, SPECIES_SILVALLY, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_DOUBLE_SHOCK, _electric

_fire:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, TYPE_FIRE, _fire_second
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_FIRE, _fire_typeless
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    GoTo _fire_message

_fire_second:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_FIRE, _end
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    GoTo _fire_message

_fire_typeless:
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, TYPE_SOVEREIGN_TYPELESS
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_SOVEREIGN_TYPELESS

_fire_message:
    // {0} burned itself out!
    PrintMessage BattleStrings_Text_SovereignBurnedItselfOut_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_electric:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, TYPE_ELECTRIC, _electric_second
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_ELECTRIC, _electric_typeless
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    GoTo _electric_message

_electric_second:
    CompareMonDataToValue OPCODE_NEQ, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_ELECTRIC, _end
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, BTLVAR_CALC_TEMP
    UpdateMonDataFromVar OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, BTLVAR_CALC_TEMP
    GoTo _electric_message

_electric_typeless:
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_1, TYPE_SOVEREIGN_TYPELESS
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_TYPE_2, TYPE_SOVEREIGN_TYPELESS

_electric_message:
    // {0} used up all its electricity!
    PrintMessage BattleStrings_Text_SovereignUsedUpAllItsElectricity_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 

_end:
    End 
