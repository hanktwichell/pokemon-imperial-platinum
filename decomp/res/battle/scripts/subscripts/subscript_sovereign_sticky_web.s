#include "macros/btlcmd.inc"

// Sovereign (item 11): Sticky Web. Grounded Pokemon switching in on the foes' side lose 1 Speed stage.

_000:
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SOVEREIGN_FOE_SIDE_CONDITIONS, SIDE_CONDITION_SOVEREIGN_STICKY_WEB, _fail
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SOVEREIGN_FOE_SIDE_CONDITIONS, SIDE_CONDITION_SOVEREIGN_STICKY_WEB
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    // A sticky web has been laid out around your team's feet!
    PrintMessage BattleStrings_Text_SovereignStickyWebYourTeam, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER_ENEMY
    Wait 
    WaitButtonABTime 30
    End 

_fail:
    UpdateVar OPCODE_FLAG_ON, BTLVAR_MOVE_STATUS_FLAGS, MOVE_STATUS_FAILED
    End 
