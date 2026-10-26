#include "macros/btlcmd.inc"

// Sovereign (item 11): Rocky Helmet. A contact move that hits the holder costs the attacker 1/6 of its max HP
// (hpCalcTemp), each hit, even as the holder faints (BattleControllerPlayer_AfterMoveMessage).

_000:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_SKIP_SPRITE_BLINK
    UpdateVarFromVar OPCODE_SET, BTLVAR_MSG_BATTLER_TEMP, BTLVAR_ATTACKER
    Call BATTLE_SUBSCRIPT_UPDATE_HP
    // {0} is hurt by {1}’s {2}!
    PrintMessage BattleStrings_Text_PokemonIsHurtByPokemonsItem_AllyAlly, TAG_NICKNAME_NICKNAME_ITEM, BTLSCR_ATTACKER, BTLSCR_DEFENDER, BTLSCR_DEFENDER
    Wait 
    WaitButtonABTime 30
    End 
