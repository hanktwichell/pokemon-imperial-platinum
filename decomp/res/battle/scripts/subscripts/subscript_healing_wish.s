#include "macros/btlcmd.inc"

// Sovereign (item 11): Healing Wish as in Gen IX. The user faints and leaves the wish in its slot. The Pokémon that
// comes into the slot (at the end of the turn, or later) is healed before the entry hazards hit it, if it needs it
// (subscript_hazards_check); one that doesn't leaves the wish for the next (Gen VIII+). Platinum switched the
// replacement in at once and healed it after the hazards.

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
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_HEALING_WISH_ATTACKER, SOVEREIGN_WISH_HEALING_WISH
    End 
