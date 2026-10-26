#include "macros/btlcmd.inc"

// Sovereign (item 11): Ceaseless Edge lays a layer of Spikes, and Stone Axe Stealth Rock, on the user's foes' side
// after the hit (even through a Substitute). Not with Sheer Force, which powers the move up instead, nor once the user
// has fainted.

_000:
    CheckAbility CHECK_HAVE, BTLSCR_ATTACKER, ABILITY_SHEER_FORCE, _end
    CompareMonDataToValue OPCODE_EQU, BTLSCR_ATTACKER, BATTLEMON_CUR_HP, 0, _end
    CompareVarToValue OPCODE_EQU, BTLVAR_CURRENT_MOVE, MOVE_STONE_AXE, _stealth_rock
    TrySpikes _end
    // Spikes were scattered all around your team’s feet!
    PrintMessage BattleStrings_Text_SpikesWereScatteredAllAroundYourTeamsFeet, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER_ENEMY
    Wait 
    WaitButtonABTime 30
    End 

_stealth_rock:
    // the target's side is the foes' side unless the move hit an ally
    IfSameSide BTLSCR_ATTACKER, BTLSCR_DEFENDER, _end
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_SIDE_CONDITIONS_DEFENDER, SIDE_CONDITION_STEALTH_ROCK, _end
    UpdateVar OPCODE_FLAG_ON, BTLVAR_SIDE_CONDITIONS_DEFENDER, SIDE_CONDITION_STEALTH_ROCK
    // Pointed stones float in the air around your team!
    PrintMessage BattleStrings_Text_PointedStonesFloatInTheAirAroundYourTeam, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER_ENEMY
    Wait 
    WaitButtonABTime 30

_end:
    End 
