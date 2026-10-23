#include "macros/scrcmd.inc"
#include "res/text/bank/route_209_lost_tower_5f.h"
#include "res/field/events/events_route_209_lost_tower_5f.h"
#include "constants/sovereign_totem_trials.h"


    ScriptEntry Route209LostTower5F_OldWoman1
    ScriptEntry Route209LostTower5F_OldWoman2
    ScriptEntry Route209LostTower5F_OnTransition
    ScriptEntry Route209LostTower5F_TotemMarowak
    ScriptEntry Route209LostTower5F_OnLoad
    ScriptEntry Route209LostTower5F_LegendaryYveltal
    ScriptEntryEnd

@ Sovereign: Totem Alolan Marowak's trial opens once Fantina is beaten (the Relic Badge).
Route209LostTower5F_OnTransition:
    CallIfSet FLAG_SOVEREIGN_TOTEM_TRIAL_MAROWAK, Route209LostTower5F_HideTotemMarowak
    CheckBadgeAcquired BADGE_ID_RELIC, VAR_RESULT
    CallIfEq VAR_RESULT, FALSE, Route209LostTower5F_HideTotemMarowak
    Call Route209LostTower5F_SovereignSetYveltalVisibility
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Yveltal perches at the end of the top floor's east
@ corridor once the Kalos Chronicle is open (VAR_SOVEREIGN_CHRONICLE 2), until it's caught.
Route209LostTower5F_SovereignSetYveltalVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 2, Route209LostTower5F_SovereignSetYveltalVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_YVELTAL, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route209LostTower5F_SovereignSetYveltalVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route209LostTower5F_SovereignSetYveltalVisibilityEnd:
    Return

Route209LostTower5F_HideTotemMarowak:
    SetFlag FLAG_MAP_LOCAL_HIDE_TOTEM
    Return

Route209LostTower5F_OnLoad:
    GoToIfSet FLAG_MAP_LOCAL_REMOVE_OBJECT, Route209LostTower5F_RemoveTotemMarowak
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route209LostTower5F_RemoveLegendaryYveltal
    End

Route209LostTower5F_RemoveLegendaryYveltal:
    RemoveObject LOCALID_LEGENDARY_YVELTAL
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route209LostTower5F_LegendaryYveltal:
    SetVar VAR_0x8004, SPECIES_YVELTAL
    SetVar VAR_0x8005, 70
    Common_SovereignLegendaryEncounter
    End

Route209LostTower5F_RemoveTotemMarowak:
    RemoveObject LOCALID_TOTEM_MAROWAK
    ClearFlag FLAG_MAP_LOCAL_REMOVE_OBJECT
    End

@ Sovereign (decision 18): the Totem Alolan Marowak trial.
Route209LostTower5F_TotemMarowak:
    SetVar VAR_0x8004, TOTEM_TRIAL_MAROWAK
    Common_SovereignTotemTrial
    End

Route209LostTower5F_OldWoman1:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfUnset FLAG_USED_DEFOG_IN_ROUTE_209_LOST_TOWER_5F, Route209LostTower5F_ThisFogObscuresEverything
    GoToIfSet FLAG_RECEIVED_ROUTE_209_LOST_TOWER_5F_SPELL_TAG, Route209LostTower5F_FantinaIsARegularVisitor
    Message Route209LostTower5F_Text_DontBeShyTakeIt
    SetVar VAR_0x8004, ITEM_SPELL_TAG
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route209LostTower5F_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_209_LOST_TOWER_5F_SPELL_TAG
    GoTo Route209LostTower5F_FantinaIsARegularVisitor
    End

Route209LostTower5F_FantinaIsARegularVisitor:
    Message Route209LostTower5F_Text_FantinaIsARegularVisitor
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower5F_ThisFogObscuresEverything:
    Message Route209LostTower5F_Text_ThisFogObscuresEverything
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower5F_OldWoman2:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfUnset FLAG_USED_DEFOG_IN_ROUTE_209_LOST_TOWER_5F, Route209LostTower5F_ThisFogObscuresEverything2
    GoToIfSet FLAG_RECEIVED_ROUTE_209_LOST_TOWER_5F_CLEANSE_TAG, Route209LostTower5F_PokemonFindSolaceHere
    Message Route209LostTower5F_Text_TakeThis
    SetVar VAR_0x8004, ITEM_CLEANSE_TAG
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route209LostTower5F_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_209_LOST_TOWER_5F_CLEANSE_TAG
    GoTo Route209LostTower5F_PokemonFindSolaceHere
    End

Route209LostTower5F_PokemonFindSolaceHere:
    Message Route209LostTower5F_Text_PokemonFindSolaceHere
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route209LostTower5F_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route209LostTower5F_ThisFogObscuresEverything2:
    Message Route209LostTower5F_Text_ThisFogObscuresEverything2
    WaitButton
    CloseMessage
    ReleaseAll
    End
