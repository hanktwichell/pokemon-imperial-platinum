#include "macros/btlcmd.inc"

// Sovereign (item 11): Cursed Body disabled the attacker's move (set in BattleSystem_TriggerAbilityOnHit).

_000:
    // {0}’s {1} was disabled!
    PrintMessage BattleStrings_Text_PokemonsMoveWasDisabled_Ally, TAG_NICKNAME_MOVE, BTLSCR_ATTACKER, BTLSCR_MSG_TEMP
    Wait 
    WaitButtonABTime 30
    End 
