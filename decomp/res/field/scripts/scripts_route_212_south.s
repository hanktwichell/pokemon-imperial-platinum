#include "macros/scrcmd.inc"
#include "res/field/events/events_route_212_south.h"
#include "res/text/bank/route_212_south.h"


    ScriptEntry Route212South_SchoolKidM
    ScriptEntry Route212South_Lady
    ScriptEntry Route212South_Collector
    ScriptEntry Route212South_ArrowSignpostPastoriaCity
    ScriptEntry Route212South_SignboardShardsWanted
    ScriptEntry Route212South_PolicemanDanny
    ScriptEntry Route212South_OnTransition
    ScriptEntry Route212South_TrainerTipsSignpost
    ScriptEntry Route212South_SovereignOnLoad
    ScriptEntry Route212South_LegendaryZarude
    ScriptEntryEnd

Route212South_OnTransition:
    Call Route212South_SovereignSetZarudeVisibility
    GetTimeOfDay VAR_MAP_LOCAL_0x00
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_MORNING, TIMEOFDAY_TWILIGHT, Route212South_SetPolicemanNoBattle
    GoToIfInRange VAR_MAP_LOCAL_0x00, TIMEOFDAY_NIGHT, TIMEOFDAY_LATE_NIGHT, Route212South_SetPolicemanBattle
    End

Route212South_SetPolicemanNoBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_SOUTH_POLICEMAN_DANNY_NO_BATTLE
    SetFlag FLAG_HIDE_ROUTE_212_SOUTH_POLICEMAN_DANNY
    End

Route212South_SetPolicemanBattle:
    ClearFlag FLAG_HIDE_ROUTE_212_SOUTH_POLICEMAN_DANNY
    SetFlag FLAG_HIDE_ROUTE_212_SOUTH_POLICEMAN_DANNY_NO_BATTLE
    End

Route212South_SchoolKidM:
    NPCMessage Route212South_Text_CrossLogsOnBike
    End

Route212South_Lady:
    NPCMessage Route212South_Text_ImNotStuck
    End

Route212South_Collector:
    NPCMessage Route212South_Text_HowAboutPokemonMansion
    End

Route212South_ArrowSignpostPastoriaCity:
    ShowArrowSign Route212South_Text_SignPastoriaCity
    End

Route212South_SignboardShardsWanted:
    ShowLandmarkSign Route212South_Text_SignShardsWanted
    End

Route212South_TrainerTipsSignpost:
    ShowScrollingSign Route212South_Text_TrainerTipsBog
    End

Route212South_PolicemanDanny:
    NPCMessage Route212South_Text_ConstantPatrol
    End

Route212South_SovereignOnLoad:
    CallIfSet FLAG_SOVEREIGN_REMOVE_LEGENDARY, Route212South_RemoveLegendaryZarude
    End

@ Sovereign (the Chronicles, docs/PostgameLegendaries.md): Zarude roams the marshy grass once the Galar Chronicle is
@ open, until it is caught.
Route212South_SovereignSetZarudeVisibility:
    SetFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
    GoToIfLt VAR_SOVEREIGN_CHRONICLE, 4, Route212South_SovereignSetZarudeVisibilityEnd
    SovereignCheckSpeciesCaught SPECIES_ZARUDE, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, Route212South_SovereignSetZarudeVisibilityEnd
    ClearFlag FLAG_MAP_LOCAL_HIDE_LEGENDARY
Route212South_SovereignSetZarudeVisibilityEnd:
    Return

Route212South_RemoveLegendaryZarude:
    GoToIfNe VAR_SOVEREIGN_LEGENDARY_SPECIES, SPECIES_ZARUDE, Route212South_RemoveLegendaryZarudeEnd
    RemoveObject LOCALID_LEGENDARY_ZARUDE
    ClearFlag FLAG_SOVEREIGN_REMOVE_LEGENDARY
Route212South_RemoveLegendaryZarudeEnd:
    Return

Route212South_LegendaryZarude:
    SetVar VAR_0x8004, SPECIES_ZARUDE
    SetVar VAR_0x8005, 60
    Common_SovereignLegendaryEncounter
    End
