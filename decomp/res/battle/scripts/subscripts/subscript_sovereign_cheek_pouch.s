#include "macros/btlcmd.inc"

// Sovereign (item 11): Cheek Pouch. A Pokémon that eats its Berry also restores a third of its max HP
// (subscript_pluck_check; BTLVAR_SOVEREIGN_CHEEK_POUCH_MSG_TEMP worked out the HP). The eater is BTLSCR_MSG_TEMP.

_000:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} restored HP using its {1}!
    PrintMessage BattleStrings_Text_PokemonRestoredHPUsingItsAbility_Ally, TAG_NICKNAME_ABILITY, BTLSCR_MSG_TEMP, BTLSCR_MSG_BATTLER_TEMP
    Wait 
    WaitButtonABTime 30
    End 
