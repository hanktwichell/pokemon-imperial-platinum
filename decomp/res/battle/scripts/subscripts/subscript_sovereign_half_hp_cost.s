#include "macros/btlcmd.inc"

// Sovereign (item 11): Steel Beam, Mind Blown and Chloroblast. The user loses half its max HP (rounded up) once per
// move, after the hit or after a miss (subscript_missed); Magic Guard prevents it.

_000:
    CompareVarToValue OPCODE_NEQ, BTLVAR_SOVEREIGN_HALF_HP_PAID, FALSE, _end
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_HALF_HP_PAID, TRUE
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_MAGIC_GUARD, _end
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateMonDataFromVar OPCODE_GET, BTLSCR_ATTACKER, BATTLEMON_MAX_HP, BTLVAR_HP_CALC_TEMP
    UpdateVar OPCODE_ADD, BTLVAR_HP_CALC_TEMP, 1
    UpdateVar OPCODE_DIV, BTLVAR_HP_CALC_TEMP, 2
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, -1
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} is hit with recoil!
    PrintMessage BattleStrings_Text_PokemonIsHitWithRecoil_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_end:
    End 
