#include "macros/btlcmd.inc"

// Sovereign (item 11): Red Card. The Pokémon that hit the holder (BTLSCR_DEFENDER) is dragged out, as by Dragon Tail
// (BattleSystem_TriggerHeldItemOnHit). The card is used up even when Suction Cups or Ingrain keep the attacker in.

_000:
    PlayBattleAnimation BTLSCR_DEFENDER, BATTLE_ANIMATION_HELD_ITEM
    Wait 
    // {0} held up its Red Card against {1}!
    PrintMessage BattleStrings_Text_SovereignHeldUpRedCard_AllyAlly, TAG_NICKNAME_NICKNAME, BTLSCR_DEFENDER, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    RemoveItem BTLSCR_DEFENDER
    // Reading the var swaps the attacker and the defender (always 1), so subscript_sovereign_drag_out drags the
    // attacker; the second read swaps them back.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWAP_SHIELD_ROLES, 0, _end
    Call BATTLE_SUBSCRIPT_SOVEREIGN_DRAG_OUT
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SWAP_SHIELD_ROLES, 0, _end

_end:
    End 
