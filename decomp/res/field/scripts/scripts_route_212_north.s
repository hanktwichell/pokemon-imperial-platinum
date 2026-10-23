#include "macros/scrcmd.inc"
#include "res/field/events/events_route_212_north.h"
#include "res/text/bank/route_212_north.h"


    ScriptEntry Route212North_Youngster
    ScriptEntry Route212North_ArrowSignpostHearthomeCity
    ScriptEntry Route212North_SignboardPokemonMansion
    ScriptEntry Route212North_TrainerTipsSignpost
    ScriptEntry Route212North_Collector
    ScriptEntry Route212North_PolicemanBobby
    ScriptEntry Route212North_PolicemanAlex
    ScriptEntry Route212North_PolicemanDylan
    ScriptEntry Route212North_PolicemanCaleb
    ScriptEntry Route212North_OnTransition
    ScriptEntry Route212North_SovereignOnLoad
    ScriptEntry Route212North_LegendaryWoChien
    ScriptEntry Route212North_SovereignStake1
    ScriptEntry Route212North_SovereignStake2
    ScriptEntryEnd

Route212North_OnTransition:
    Call Route212North_SovereignSetStake2Visibility
    Call Route212North_SovereignSetStake1Visibility
    Call Route212North_SovereignSetWoChienVisibility
    GetTimeOfDay VAR_MAP_LOCAL_0x00
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_MORNING, TIMEOFDAY_TWILIGHT, Route212North_SetPolicemenNoBattle
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_NIGHT, TIMEOFDAY_LATE_NIGHT, Route212North_SetPolicemenBattle
    End

Route212North_SetPolicemenNoBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN_NO_BATTLE
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB
    End

Route212North_SetPolicemenBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN
    ClearFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_BOBBY_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_ALEX_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_DYLAN_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_NORTH_POLICEMAN_CALEB_NO_BATTLE
    End

Route212North_Youngster:
    NPCMessage Route212North_Text_MrBacklotLikesVisitors
    End

Route212North_ArrowSignpostHearthomeCity:
    ShowArrowSign Route212North_Text_SignHearthomeCity
    End

Route212North_SignboardPokemonMansion:
    ShowLandmarkSign Route212North_Text_SignPokemonMansion
    End

Route212North_TrainerTipsSignpost:
    ShowScrollingSign Route212North_Text_TrainerTipsReorganizeItems
    End

Route212North_Collector:
    NPCMessage Route212North_Text_FindAttractiveTree
    End

Route212North_PolicemanBobby:
    NPCMessage Route212North_Text_SayHiToPolicemen
    End

Route212North_PolicemanAlex:
    NPCMessage Route212North_Text_PatrolsDayAndNight
    End

Route212North_PolicemanDylan:
    NPCMessage Route212North_Text_WorkingHard
    End

Route212North_PolicemanCaleb:
    NPCMessage Route212North_Text_PatrolTooMuch
    End

    .balign 4, 0

Route212North_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route212North_RemoveLegendaryWoChien
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): one of the Treasures of Ruin, unsealed once both its stakes
@ on this map are pulled out (FLAG_SOVEREIGN_PULLED_STAKE_1 and _2), until it is caught.
Route212North_SovereignSetWoChienVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetWoChienVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_1, Route212North_SovereignSetWoChienVisibilityEnd
    GoToIfUnset FLAG_SOVEREIGN_PULLED_STAKE_2, Route212North_SovereignSetWoChienVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_WO_CHIEN, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route212North_SovereignSetWoChienVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route212North_SovereignSetWoChienVisibilityEnd:
    Return

Route212North_RemoveLegendaryWoChien:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_WO_CHIEN, Route212North_RemoveLegendaryWoChienEnd
    RemoveObject LOCALID_LEGENDARY_WO_CHIEN
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route212North_RemoveLegendaryWoChienEnd:
    Return

Route212North_LegendaryWoChien:
    SetVar VAR_0x8004, SPECIES_WO_CHIEN
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 1 of the two that seal WoChien's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_1).
Route212North_SovereignSetStake1Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetStake1VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_1, Route212North_SovereignSetStake1VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route212North_SovereignSetStake1VisibilityEnd:
    Return

Route212North_SovereignStake1:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_1
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_1
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignStake1End
    Call Route212North_SovereignSetWoChienVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route212North_SovereignStake1End
    AddObject LOCALID_LEGENDARY_WO_CHIEN
Route212North_SovereignStake1End:
    End

@ Sovereign (the Chronicles, the Treasures of Ruin): stake 2 of the two that seal WoChien's shrine here, shown once the
@ Paldea Chronicle is open until it's pulled out (FLAG_SOVEREIGN_PULLED_STAKE_2).
Route212North_SovereignSetStake2Visibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 5, Route212North_SovereignSetStake2VisibilityEnd
    GoToIfSet FLAG_SOVEREIGN_PULLED_STAKE_2, Route212North_SovereignSetStake2VisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_3
Route212North_SovereignSetStake2VisibilityEnd:
    Return

Route212North_SovereignStake2:
    SetVar VAR_0x8004, FLAG_SOVEREIGN_PULLED_STAKE_2
    SetVar VAR_0x8005, LOCALID_SOVEREIGN_STAKE_2
    Common_SovereignStake
    GoToIfEq VAR_RESULT, FALSE, Route212North_SovereignStake2End
    Call Route212North_SovereignSetWoChienVisibility
    GoToIfSet FLAG_MAP_LOCAL_HIDE_LEGENDARY, Route212North_SovereignStake2End
    AddObject LOCALID_LEGENDARY_WO_CHIEN
Route212North_SovereignStake2End:
    End
