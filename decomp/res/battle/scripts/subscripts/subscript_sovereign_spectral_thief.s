#include "macros/btlcmd.inc"

// Sovereign (item 11): Spectral Thief, before it hits (a direct side effect, run once the move has got past accuracy,
// protection and immunities). The user steals the target's stat rises (BTLVAR_SOVEREIGN_SPECTRAL_THIEF), and the damage
// is calculated again with the new stages, keeping the critical hit roll.

_000:
    PrintAttackMessage
    Wait
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SPECTRAL_THIEF, 0, _attack
    PlayBattleAnimation BTLSCR_ATTACKER, BATTLE_ANIMATION_STAT_BOOST
    Wait
    // {0} stole the target’s boosted stats!
    PrintMessage BattleStrings_Text_SovereignStoleBoosts_Ally, TAG_NICKNAME, BTLSCR_ATTACKER
    Wait
    WaitButtonABTime 30
    CalcDamage

_attack:
    Call BATTLE_SUBSCRIPT_ATTACK_MESSAGE_AND_ANIMATION
    End
