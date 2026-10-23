#include "macros/scrcmd.inc"
#include "res/text/bank/route_222.h"
#include "res/field/events/events_route_222.h"


    ScriptEntry Route222_Fisherman
    ScriptEntry Route222_RichBoy
    ScriptEntry Route222_ArrowSignpostHotelGrandLake
    ScriptEntry Route222_ArrowSignpostSunyshoreCity
    ScriptEntry Route222_SignboardPikachuFanClub
    ScriptEntry Route222_SignboardPokemonSizeContest
    ScriptEntry Route222_PolicemanThomas
    ScriptEntry Route222_OnTransition
    ScriptEntry Route222_OnLoad
    ScriptEntry Route222_LegendaryTapuKoko
    ScriptEntry Route222_LegendaryZeraora
    ScriptEntryEnd

Route222_OnTransition:
    Call Route222_SovereignSetZeraoraVisibility
    Call Route222_SovereignSetTapuKokoVisibility
    GetTimeOfDay VAR_MAP_LOCAL_0x00
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_MORNING, TIMEOFDAY_TWILIGHT, Route222_SetPolicemanThomasNoBattle
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_NIGHT, TIMEOFDAY_LATE_NIGHT, Route222_SetPolicemanThomasBattle
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Tapu Koko stands on the beach at the route's east end once
@ the Alola Chronicle is open (VAR_SOVEREIGN_CHRONICLE 3), until it's caught.
Route222_SovereignSetTapuKokoVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, Route222_SovereignSetTapuKokoVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_TAPU_KOKO, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route222_SovereignSetTapuKokoVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route222_SovereignSetTapuKokoVisibilityEnd:
    Return

Route222_OnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route222_RemoveLegendaryZeraora
    GoToIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route222_RemoveLegendaryTapuKoko
    End

Route222_RemoveLegendaryTapuKoko:
    RemoveObject LOCALID_LEGENDARY_TAPU_KOKO
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
    End

Route222_LegendaryTapuKoko:
    SetVar VAR_0x8004, SPECIES_TAPU_KOKO
    SetVar VAR_0x8005, 65
    Common_SovereignLegendaryEncounter
    End

Route222_SetPolicemanThomasNoBattle:
    ClearFlag FLAG_HIDE_ROUTE_222_POLICEMAN_THOMAS_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_222_POLICEMAN_THOMAS
    End

Route222_SetPolicemanThomasBattle:
    ClearFlag FLAG_HIDE_ROUTE_222_POLICEMAN_THOMAS
    SetFlag FLAG_HIDE_ROUTE_222_POLICEMAN_THOMAS_NO_BATTLE
    End

Route222_RichBoy:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_RECEIVED_ROUTE_222_TM56, Route222_ExplainFling
    Message Route222_Text_IGiveTMFling
    SetVar VAR_0x8004, ITEM_TM56
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, Route222_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_RECEIVED_ROUTE_222_TM56
    GoTo Route222_ExplainFling

Route222_ExplainFling:
    Message Route222_Text_ExplainFling
    WaitButton
    CloseMessage
    ReleaseAll
    End

Route222_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

Route222_Fisherman:
    NPCMessage Route222_Text_CatchingMadeMeHappy
    End

Route222_ArrowSignpostHotelGrandLake:
    ShowArrowSign Route222_Text_SignHotelGrandLake
    End

Route222_ArrowSignpostSunyshoreCity:
    ShowArrowSign Route222_Text_SignSunyshoreCity
    End

Route222_SignboardPikachuFanClub:
    ShowLandmarkSign Route222_Text_SignPikachuFanClub
    End

Route222_SignboardPokemonSizeContest:
    ShowLandmarkSign Route222_Text_SignPokemonSizeContest
    End

Route222_PolicemanThomas:
    NPCMessage Route222_Text_MoreAgitatedAtNight
    End

    .balign 4, 0

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zeraora prowls here at night (8 pm to 4 am) once the Alola
@ Chronicle is open, until it is caught. The check runs on entering the map.
Route222_SovereignSetZeraoraVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 3, Route222_SovereignSetZeraoraVisibilityEnd
    GetTimeOfDay VAR_RESULT
    GoToIfLt VAR_RESULT, TIMEOFDAY_NIGHT, Route222_SovereignSetZeraoraVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZERAORA, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route222_SovereignSetZeraoraVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY_2
Route222_SovereignSetZeraoraVisibilityEnd:
    Return

Route222_RemoveLegendaryZeraora:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZERAORA, Route222_RemoveLegendaryZeraoraEnd
    RemoveObject LOCALID_LEGENDARY_ZERAORA
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route222_RemoveLegendaryZeraoraEnd:
    Return

Route222_LegendaryZeraora:
    SetVar VAR_0x8004, SPECIES_ZERAORA
    SetVar VAR_0x8005, 50
    Common_SovereignLegendaryEncounter
    End
