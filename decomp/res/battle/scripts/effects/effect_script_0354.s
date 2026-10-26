#include "macros/btlcmd.inc"

// Sovereign (item 11): Eerie Spell. Damage, then (effect chance, 100%) subscript_sovereign_eerie_spell on the target.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_TO_DEFENDER|MOVE_SUBSCRIPT_PTR_SOVEREIGN_EERIE_SPELL
    CalcCrit 
    CalcDamage 
    End 
