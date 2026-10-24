#include "macros/scrcmd.inc"
#include "res/text/bank/route_209_lost_tower_1f.h"


    ScriptEntry Route209LostTower1F_OnTransition
    ScriptEntry Route209LostTower1F_PokemonBreederF1
    ScriptEntry Route209LostTower1F_PokemonBreederF2
    ScriptEntry Route209LostTower1F_SovereignScientistF
    ScriptEntryEnd

Route209LostTower1F_OnTransition:
    SetFlag FLAG_FIRST_ARRIVAL_LOST_TOWER
    End

Route209LostTower1F_PokemonBreederF1:
    NPCMessage Route209LostTower1F_Text_ThisIsWhereSpiritsRest
    End

Route209LostTower1F_PokemonBreederF2:
    NPCMessage Route209LostTower1F_Text_ThisIsTheLostTower
    End

    .balign 4, 0

// Sovereign (E10): Renegade's Reaper Cloth scientist.
Route209LostTower1F_SovereignScientistF:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_LOST_TOWER_REAPER_CLOTH, Route209LostTower1F_SovereignScientistFAgain
    Message Route209LostTower1F_Text_SovereignScientistFGives
    SetVar VAR_0x8004, ITEM_REAPER_CLOTH
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_LOST_TOWER_REAPER_CLOTH
    Message Route209LostTower1F_Text_SovereignScientistFExplains
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower1F_SovereignScientistFAgain:
    Message Route209LostTower1F_Text_SovereignScientistFAgain
    WaitButton
    CloseMessage
    ReleaseAll
    End
