#include "macros/btlcmd.inc"

// Sovereign (item 11): Final Gambit hit, so the user faints (as after Self-Destruct).

_000:
    UpdateVar OPCODE_SET, BTLVAR_CALC_TEMP, 0x10000000
    UpdateVarFromVar OPCODE_LEFT_SHIFT, BTLVAR_CALC_TEMP, BTLVAR_ATTACKER
    UpdateVarFromVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, BTLVAR_CALC_TEMP
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0
    UpdateVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, 32767
    UpdateHealthBar BTLSCR_ATTACKER
    Wait 
    End 
