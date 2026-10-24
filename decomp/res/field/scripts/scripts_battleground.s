#include "macros/scrcmd.inc"
#include "res/text/bank/battleground.h"
#include "res/field/events/events_battleground.h"

@ Sovereign (E10, Renegade): the Battleground as Renegade has it. Vanilla's four daily trainer slots are gone: the eight
@ Gym Leaders, Cheryl, Mira, Riley, Marley, Buck and Barry stand here for good, each ready for a battle any time. A nurse
@ heals the party, the Gym Guide runs the Battle Marathon (24 battles in a row, a heal after every third, a Master Ball
@ for each clear), and the counterpart waits here once beaten on Route 224 (Renegade's trainers 1054-1059).

    ScriptEntry Battleground_ExpertM
    ScriptEntry Battleground_Roark
    ScriptEntry Battleground_OnFrame_Welcome
    ScriptEntry Battleground_OnTransition
    ScriptEntry Battleground_Gardenia
    ScriptEntry Battleground_Fantina
    ScriptEntry Battleground_Maylene
    ScriptEntry Battleground_Wake
    ScriptEntry Battleground_Byron
    ScriptEntry Battleground_Candice
    ScriptEntry Battleground_Volkner
    ScriptEntry Battleground_Cheryl
    ScriptEntry Battleground_Mira
    ScriptEntry Battleground_Riley
    ScriptEntry Battleground_Marley
    ScriptEntry Battleground_Buck
    ScriptEntry Battleground_Barry
    ScriptEntry Battleground_SovereignNurse
    ScriptEntry Battleground_SovereignMarathon
    ScriptEntry Battleground_SovereignCounterpart
    ScriptEntryEnd

Battleground_OnTransition:
    SetFlag FLAG_VISITED_BATTLEGROUND
    GetPlayerGender VAR_RESULT
    CallIfEq VAR_RESULT, GENDER_MALE, Battleground_SovereignSetCounterpartDawn
    CallIfEq VAR_RESULT, GENDER_FEMALE, Battleground_SovereignSetCounterpartLucas
    SetFlag FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_CHIMCHAR, Battleground_SovereignShowCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_PIPLUP, Battleground_SovereignShowCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_DAWN_ROUTE_224_TURTWIG, Battleground_SovereignShowCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_CHIMCHAR, Battleground_SovereignShowCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_PIPLUP, Battleground_SovereignShowCounterpart
    GoToIfDefeated TRAINER_SOVEREIGN_LUCAS_ROUTE_224_TURTWIG, Battleground_SovereignShowCounterpart
    End

Battleground_SovereignShowCounterpart:
    ClearFlag FLAG_MAP_LOCAL_HIDE_SOVEREIGN_NPC
    End

Battleground_SovereignSetCounterpartDawn:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_F
    Return

Battleground_SovereignSetCounterpartLucas:
    SetVar VAR_OBJ_GFX_ID_0, OBJ_EVENT_GFX_PLAYER_M
    Return

Battleground_ExpertM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_BATTLED_STARK_MOUNTAIN_ROOM_3_HEATRAN, Battleground_MakeYourselfAtHome
    Message Battleground_Text_TalkAboutStarkMountain
    WaitButton
    CloseMessage
    ReleaseAll
    End

Battleground_MakeYourselfAtHome:
    Message Battleground_Text_MakeYourselfAtHome
    WaitButton
    CloseMessage
    ReleaseAll
    End

@ Buck no longer waits here to introduce the place (he battles here instead), so the welcome sets what talking to him
@ did: Heatran's room opens, and he's off to the Battle Tower's salon.
Battleground_OnFrame_Welcome:
    LockAll
    SetVar VAR_BATTLEGROUND_STATE, 1
    ApplyMovement LOCALID_EXPERT_M, Battleground_Movement_ExpertFExclamationMark
    WaitMovement
    ApplyMovement LOCALID_PLAYER, Battleground_Movement_PlayerWalkToExpertF
    WaitMovement
    Message Battleground_Text_WelcomeToBattleground
    WaitButton
    CloseMessage
    SetFlag FLAG_TALKED_TO_BATTLEGROUND_BUCK
    SetFlag FLAG_BUCK_LEFT_BATTLEGROUND
    SetFlag FLAG_HIDE_BATTLEGROUND_BUCK
    ReleaseAll
    End

    .balign 4, 0
Battleground_Movement_ExpertFExclamationMark:
    EmoteExclamationMark
    EndMovement

    .balign 4, 0
Battleground_Movement_PlayerWalkToExpertF:
    WalkNormalNorth 2
    WalkNormalEast 4
    EndMovement

Battleground_DoBattle:
    IncrementGameRecord RECORD_TIMES_BATTLED_AT_BATTLEGROUND
    StartTrainerBattle VAR_MAP_LOCAL_0x01
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Battleground_LostBattle
    Return

Battleground_LostBattle:
    BlackOutFromBattle
    ReleaseAll
    End

Battleground_TrainerEnd:
    WaitButton
    CloseMessage
    ReleaseAll
    End

Battleground_Roark:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_RoarkAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_RoarkDeclined
    Message Battleground_Text_RoarkIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_ROARK_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_RoarkDefeatByronPresent
    GoTo Battleground_TrainerEnd

Battleground_RoarkDeclined:
    Message Battleground_Text_RoarkDeclinedBattle2
    GoTo Battleground_TrainerEnd

Battleground_Gardenia:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_GardeniaAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_GardeniaDeclined
    Message Battleground_Text_GardeniaIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_GARDENIA_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_GardeniaDefeat2
    GoTo Battleground_TrainerEnd

Battleground_GardeniaDeclined:
    Message Battleground_Text_GardeniaDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Fantina:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_FantinaAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_FantinaDeclined
    Message Battleground_Text_FantinaIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_FANTINA_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_FantinaDefeat
    GoTo Battleground_TrainerEnd

Battleground_FantinaDeclined:
    Message Battleground_Text_FantinaDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Maylene:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_MayleneAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_MayleneDeclined
    Message Battleground_Text_MayleneIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_MAYLENE_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_MayleneDefeat2
    GoTo Battleground_TrainerEnd

Battleground_MayleneDeclined:
    Message Battleground_Text_MayleneDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Wake:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_WakeAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_WakeDeclined
    Message Battleground_Text_WakeIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_WAKE_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_WakeDefeat2
    GoTo Battleground_TrainerEnd

Battleground_WakeDeclined:
    Message Battleground_Text_WakeDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Byron:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_ByronAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_ByronDeclined
    Message Battleground_Text_ByronIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_BYRON_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_ByronDefeat2
    GoTo Battleground_TrainerEnd

Battleground_ByronDeclined:
    Message Battleground_Text_ByronDeclinedBattle2
    GoTo Battleground_TrainerEnd

Battleground_Candice:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_CandiceAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_CandiceDeclined
    Message Battleground_Text_CandiceIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_CANDICE_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_CandiceDefeat2
    GoTo Battleground_TrainerEnd

Battleground_CandiceDeclined:
    Message Battleground_Text_CandiceDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Volkner:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_VolknerAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_VolknerDeclined
    Message Battleground_Text_VolknerIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_VOLKNER_REMATCH
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_VolknerDefeat2
    GoTo Battleground_TrainerEnd

Battleground_VolknerDeclined:
    Message Battleground_Text_VolknerDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Cheryl:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_CherylAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_CherylDeclined
    Message Battleground_Text_CherylIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_CHERYL_BATTLEGROUND
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_CherylDefeat
    GoTo Battleground_TrainerEnd

Battleground_CherylDeclined:
    Message Battleground_Text_CherylDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Mira:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_MiraAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_MiraDeclined
    Message Battleground_Text_MiraIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_MIRA_BATTLEGROUND
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_MiraDefeat2
    GoTo Battleground_TrainerEnd

Battleground_MiraDeclined:
    Message Battleground_Text_MiraDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Riley:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_RileyAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_RileyDeclined
    Message Battleground_Text_RileyIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_RILEY_BATTLEGROUND
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_RileyDefeat2
    GoTo Battleground_TrainerEnd

Battleground_RileyDeclined:
    Message Battleground_Text_RileyDeclinedBattle2
    GoTo Battleground_TrainerEnd

Battleground_Marley:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_MarleyAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_MarleyDeclined
    Message Battleground_Text_MarleyIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_MARLEY_BATTLEGROUND
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_MarleyDefeat2
    GoTo Battleground_TrainerEnd

Battleground_MarleyDeclined:
    Message Battleground_Text_MarleyDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Buck:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    Message Battleground_Text_BuckAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_BuckDeclined
    Message Battleground_Text_BuckIntro
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_BUCK_BATTLEGROUND
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_BuckDefeat2
    GoTo Battleground_TrainerEnd

Battleground_BuckDeclined:
    Message Battleground_Text_BuckDeclinedBattle
    GoTo Battleground_TrainerEnd

Battleground_Barry:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferRivalName 0
    BufferPlayerName 1
    Message Battleground_Text_SovereignBarryAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_BarryDeclined
    Message Battleground_Text_SovereignBarryLetsGo
    CloseMessage
    Call Battleground_SovereignSetRivalTrainer
    Call Battleground_DoBattle
    BufferRivalName 0
    BufferPlayerName 1
    Message Battleground_Text_SovereignBarryDefeat
    GoTo Battleground_TrainerEnd

Battleground_BarryDeclined:
    Message Battleground_Text_SovereignBarryDeclined
    GoTo Battleground_TrainerEnd

Battleground_SovereignSetRivalTrainer:
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_RIVAL_SURVIVAL_AREA_2_TURTWIG
    CallIfEq VAR_RESULT, SPECIES_CHIMCHAR, Battleground_SovereignSetRivalChimchar
    CallIfEq VAR_RESULT, SPECIES_PIPLUP, Battleground_SovereignSetRivalPiplup
    Return

Battleground_SovereignSetRivalChimchar:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_RIVAL_SURVIVAL_AREA_2_CHIMCHAR
    Return

Battleground_SovereignSetRivalPiplup:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_RIVAL_SURVIVAL_AREA_2_PIPLUP
    Return

Battleground_SovereignCounterpart:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GetPlayerGender VAR_RESULT
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Battleground_SovereignCounterpartLucas
    Message Battleground_Text_SovereignDawnAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_SovereignCounterpartDawnDeclined
    Message Battleground_Text_SovereignDawnGoodAnswer
    CloseMessage
    Call Battleground_SovereignSetCounterpartTrainer
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_SovereignDawnDefeat
    GoTo Battleground_TrainerEnd

Battleground_SovereignCounterpartDawnDeclined:
    Message Battleground_Text_SovereignDawnDeclined
    GoTo Battleground_TrainerEnd

Battleground_SovereignCounterpartLucas:
    Message Battleground_Text_SovereignLucasAskBattle
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_SovereignCounterpartLucasDeclined
    Message Battleground_Text_SovereignLucasGoodAnswer
    CloseMessage
    Call Battleground_SovereignSetCounterpartTrainer
    Call Battleground_DoBattle
    BufferPlayerName 0
    Message Battleground_Text_SovereignLucasDefeat
    GoTo Battleground_TrainerEnd

Battleground_SovereignCounterpartLucasDeclined:
    Message Battleground_Text_SovereignLucasDeclined
    GoTo Battleground_TrainerEnd

@ Dawn for a boy, Lucas for a girl, by the player's starter (as on Route 224).
Battleground_SovereignSetCounterpartTrainer:
    GetPlayerGender VAR_RESULT
    GoToIfEq VAR_RESULT, GENDER_FEMALE, Battleground_SovereignSetLucasTrainer
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_BATTLEGROUND_TURTWIG
    CallIfEq VAR_RESULT, SPECIES_CHIMCHAR, Battleground_SovereignSetDawnChimchar
    CallIfEq VAR_RESULT, SPECIES_PIPLUP, Battleground_SovereignSetDawnPiplup
    Return

Battleground_SovereignSetDawnChimchar:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_BATTLEGROUND_CHIMCHAR
    Return

Battleground_SovereignSetDawnPiplup:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_DAWN_BATTLEGROUND_PIPLUP
    Return

Battleground_SovereignSetLucasTrainer:
    GetPlayerStarterSpecies VAR_RESULT
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_BATTLEGROUND_TURTWIG
    CallIfEq VAR_RESULT, SPECIES_CHIMCHAR, Battleground_SovereignSetLucasChimchar
    CallIfEq VAR_RESULT, SPECIES_PIPLUP, Battleground_SovereignSetLucasPiplup
    Return

Battleground_SovereignSetLucasChimchar:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_BATTLEGROUND_CHIMCHAR
    Return

Battleground_SovereignSetLucasPiplup:
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_LUCAS_BATTLEGROUND_PIPLUP
    Return

Battleground_SovereignNurse:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Battleground_Text_SovereignNurseHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Message Battleground_Text_SovereignNurseHappyToHelp
    GoTo Battleground_TrainerEnd

@ The Battle Marathon. A loss ends it without a blackout: back to the field, healed.
Battleground_SovereignMarathon:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message Battleground_Text_SovereignMarathonIntro
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, Battleground_SovereignMarathonDeclined
    Message Battleground_Text_SovereignMarathonStart
    CloseMessage
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_ROARK_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_CHERYL_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_GARDENIA_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_MARS_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_FANTINA_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_MIRA_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_MAYLENE_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_JUPITER_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_WAKE_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_RILEY_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_BYRON_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_SATURN_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_CANDICE_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_MARLEY_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_LEADER_VOLKNER_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_BUCK_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    Call Battleground_SovereignSetCounterpartTrainer
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_SOVEREIGN_CYRUS_BATTLEGROUND
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    Call Battleground_SovereignSetRivalTrainer
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_ELITE_FOUR_AARON_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_ELITE_FOUR_BERTHA_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonHeal
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_ELITE_FOUR_FLINT_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_ELITE_FOUR_LUCIAN_REMATCH
    Call Battleground_SovereignMarathonBattle
    Call Battleground_SovereignMarathonNext
    SetVar VAR_MAP_LOCAL_0x01, TRAINER_CHAMPION_CYNTHIA_REMATCH
    Call Battleground_SovereignMarathonBattle
    HealParty
    Message Battleground_Text_SovereignMarathonWon
    SetVar VAR_0x8004, ITEM_MASTER_BALL
    SetVar VAR_0x8005, 1
    Common_GiveItemQuantity
    Message Battleground_Text_SovereignMarathonAgain
    GoTo Battleground_TrainerEnd

Battleground_SovereignMarathonDeclined:
    Message Battleground_Text_SovereignMarathonDeclined
    GoTo Battleground_TrainerEnd

Battleground_SovereignMarathonBattle:
    IncrementGameRecord RECORD_TIMES_BATTLED_AT_BATTLEGROUND
    StartTrainerBattle VAR_MAP_LOCAL_0x01
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, Battleground_SovereignMarathonLost
    Return

Battleground_SovereignMarathonLost:
    ReturnToField
    FadeScreenIn
    WaitFadeScreen
    HealParty
    Message Battleground_Text_SovereignMarathonLost
    GoTo Battleground_TrainerEnd

Battleground_SovereignMarathonNext:
    Message Battleground_Text_SovereignMarathonNext
    CloseMessage
    Return

Battleground_SovereignMarathonHeal:
    Message Battleground_Text_SovereignMarathonHeal
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    PlayFanfare SEQ_ASA_sseq
    WaitFanfare
    HealParty
    FadeScreenIn
    WaitFadeScreen
    Call Battleground_SovereignMarathonNext
    Return

    .balign 4, 0
