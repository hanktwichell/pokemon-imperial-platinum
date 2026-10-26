#include "macros/btlcmd.inc"

// Sovereign (item 11): Core Enforcer. After the hit, the target's Ability is suppressed if the target has already acted
// this turn (BTLVAR_SOVEREIGN_CORE_ENFORCER: not if it switched in during the turn, nor through an Ability Shield).

_000:
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_CORE_ENFORCER, 0, _end
    UpdateMonData OPCODE_FLAG_ON, BTLSCR_SIDE_EFFECT_MON, BATTLEMON_MOVE_EFFECTS_MASK, MOVE_EFFECT_ABILITY_SUPPRESSED
    // {0}’s ability was suppressed!
    PrintMessage BattleStrings_Text_PokemonsAbilityWasSuppressed_Ally, TAG_NICKNAME, BTLSCR_SIDE_EFFECT_MON
    Wait
    WaitButtonABTime 30

_end:
    End
