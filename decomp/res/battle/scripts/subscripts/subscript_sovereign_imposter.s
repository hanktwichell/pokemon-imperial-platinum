#include "macros/btlcmd.inc"


    // Sovereign (item 11): Imposter. As it enters, the holder (BTLSCR_MSG_BATTLER_TEMP) transforms into the foe facing
    // it (BTLSCR_MSG_DEFENDER), as by Transform: the move's animation, then the copy.
_000:
    UpdateVar OPCODE_SET, BTLVAR_MSG_MOVE_TEMP, MOVE_TRANSFORM
    PlayMoveAnimationOnMons BTLSCR_MSG_TEMP, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_DEFENDER
    Wait 
    SovereignTransform BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_DEFENDER
    // {0} transformed into {1}!
    PrintMessage BattleStrings_Text_PokemonTransformedIntoPokemon_AllyAlly, TAG_NICKNAME_POKE, BTLSCR_MSG_BATTLER_TEMP, BTLSCR_MSG_DEFENDER
    Wait 
    WaitButtonABTime 30
    UpdateVar OPCODE_FLAG_OFF, BTLVAR_BATTLE_CTX_STATUS, SYSCTL_PLAYED_MOVE_ANIMATION
    End 
