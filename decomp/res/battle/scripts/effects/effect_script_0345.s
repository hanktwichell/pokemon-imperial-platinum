#include "macros/btlcmd.inc"

// Sovereign (item 11): Ceaseless Edge and Stone Axe. Damage, then subscript_sovereign_hazard_hit (Spikes or Stealth
// Rock on the foes' side).

_000:
    UpdateVar OPCODE_SET, BTLVAR_SIDE_EFFECT_FLAGS_INDIRECT, MOVE_SIDE_EFFECT_ON_HIT|MOVE_SUBSCRIPT_PTR_SOVEREIGN_HAZARD_HIT
    CalcCrit 
    CalcDamage 
    End 
