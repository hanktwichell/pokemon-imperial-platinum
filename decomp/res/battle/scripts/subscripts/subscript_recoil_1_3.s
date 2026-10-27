#include "macros/btlcmd.inc"


_000:
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_ROCK_HEAD, _038
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_MAGIC_GUARD, _038
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    UpdateVarFromVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, BTLVAR_HIT_DAMAGE
    CompareVarToValue OPCODE_EQU, BTLVAR_HP_CALC_TEMP, 0, _025
    // Sovereign: 33/100 of the damage, rounded (Gen V+). Platinum took 1/3. The damage is negative here.
    UpdateVar OPCODE_MUL, BTLVAR_HP_CALC_TEMP, 33
    UpdateVar OPCODE_ADD, BTLVAR_HP_CALC_TEMP, -50
    DivideVarByValue BTLVAR_HP_CALC_TEMP, 100

_025:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} is hit with recoil!
    PrintMessage BattleStrings_Text_PokemonIsHitWithRecoil_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30

_038:
    End 
