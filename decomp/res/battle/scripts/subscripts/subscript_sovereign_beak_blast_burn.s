#include "macros/btlcmd.inc"

// Sovereign (item 11): a Pokemon heating up its beak (Beak Blast) burns the Pokemon whose contact move hit it. This is
// Burning Bulwark's burn: the beak's owner causes it, and neither Shield Dust nor a Substitute keeps it off.

_000:
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_BURNING_BULWARK
    Call BATTLE_SUBSCRIPT_SOVEREIGN_SHIELD_CONTACT
    UpdateVar OPCODE_SET, BTLVAR_SOVEREIGN_SHIELD_CONTACT, MOVE_NONE
    End
