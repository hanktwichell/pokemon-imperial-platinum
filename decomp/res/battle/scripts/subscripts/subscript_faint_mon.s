#include "macros/btlcmd.inc"


_000:
    IncrementGameRecord BTLSCR_FAINTED_MON, BATTLER_TYPE_SOLO_ENEMY, RECORD_FAINTED_IN_BATTLE
    IncrementGameRecord BTLSCR_FAINTED_MON, BATTLER_TYPE_SOLO_PLAYER, RECORD_FAINTED_ENEMY_MON
    PlayFaintAnimation 
    Wait 
    HealthBoxSlideOut BTLSCR_FAINTED_MON
    // {0} fainted!
    PrintMessage BattleStrings_Text_PokemonFainted_Ally, TAG_NICKNAME, BTLSCR_FAINTED_MON
    Wait 
    WaitButtonABTime 30
    CompareVarToValue OPCODE_FLAG_SET, BTLVAR_BATTLE_CTX_STATUS_2, SYSCTL_NO_EXPERIENCE_GIVEN, _023

_023:
    // Sovereign (item 11): Soul-Heart. Each Pokémon that faints raises the Sp. Atk of every other Soul-Heart holder on
    // the field 1 stage, in speed order. Reading BTLVAR_SOVEREIGN_SOUL_HEART_MON makes the next holder the side-effect
    // target, and gives the side-effect battler, type and param back once there are no more.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_SOUL_HEART_MON, 0, _sovereign_end
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_PARAM, MOVE_SUBSCRIPT_PTR_SP_ATTACK_UP_1_STAGE
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_TYPE, SIDE_EFFECT_TYPE_ABILITY
    Call BATTLE_SUBSCRIPT_UPDATE_STAT_STAGE
    GoTo _023

_sovereign_end:
    // Sovereign (item 11): Receiver and Power of Alchemy. The fainted Pokémon's ally takes over its ability.
    CompareVarToValue OPCODE_EQU, BTLVAR_SOVEREIGN_RECEIVER, 0, _sovereign_done
    // {0}’s {1} was taken over!
    PrintMessage BattleStrings_Text_SovereignAbilityTakenOver_Ally, TAG_NICKNAME_ABILITY, BTLSCR_FAINTED_MON, BTLSCR_FAINTED_MON
    Wait
    WaitButtonABTime 30

_sovereign_done:
    End 
