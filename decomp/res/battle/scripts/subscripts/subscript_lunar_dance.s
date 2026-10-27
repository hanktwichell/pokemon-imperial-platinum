#include "macros/btlcmd.inc"

// Sovereign (item 11): Lunar Dance as in Gen IX. As Healing Wish (subscript_healing_wish), and the Pokémon healed gets
// its PP back too; one that needs none of it leaves the wish for the next.

_000:
    UpdateMonData OPCODE_SET, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0
    UpdateVar OPCODE_SET, BTLVAR_HP_CALC_TEMP, 32767
    UpdateHealthBar BTLSCR_ATTACKER
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    TryFaintMon BTLSCR_ATTACKER
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_MON_FAINTED
    Call BATTLE_SUBSCRIPT_FAINT_MON
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_PAYOUT_EXP
    Call BATTLE_SUBSCRIPT_GRANT_EXP
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_HEALING_WISH_ATTACKER, SOVEREIGN_WISH_LUNAR_DANCE
    End 
