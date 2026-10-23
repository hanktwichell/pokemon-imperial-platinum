#include "macros/btlcmd.inc"

// Sovereign (item 11): Toxic Debris. A physical hit on the holder scatters a layer of Toxic Spikes on the attacker's
// side (BattleSystem_TriggerAbilityOnHit adds the layer first).

_000:
    // Poison spikes were scattered all around your team’s feet!
    PrintMessage BattleStrings_Text_PoisonSpikesWereScatteredAllAroundYourTeamsFeet, TAG_NONE_SIDE_CONSCIOUS, BTLSCR_ATTACKER
    Wait 
    WaitButtonABTime 30
    End 
