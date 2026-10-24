#include "macros/scrcmd.inc"
#include "res/text/bank/pokemon_day_care.h"


    ScriptEntry PokemonDayCare_OnTransition
    ScriptEntry PokemonDayCare_GymGuide
    ScriptEntry PokemonDayCare_BgSign
    ScriptEntry PokemonDayCare_SovereignTraynee
    ScriptEntry PokemonDayCare_SovereignRancher
    ScriptEntryEnd

PokemonDayCare_OnTransition:
    CallIfSet FLAG_STORED_POKEMON_AT_DAY_CARE, PokemonDayCare_ShowGymGuide
    End

PokemonDayCare_ShowGymGuide:
    ClearFlag FLAG_HIDE_DAY_CARE_GYM_GUIDE
    Return

PokemonDayCare_GymGuide:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    CheckPoketchAppRegistered POKETCH_APPID_DAYCARECHECKER, VAR_RESULT
    GoToIfEq VAR_RESULT, TRUE, PokemonDayCare_CheckOnDayCarePokemon
    Message PokemonDayCare_Text_SharePoketchApp
    SetVar VAR_0x8004, POKETCH_APPID_DAYCARECHECKER
    Common_GivePoketchApp
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_CheckOnDayCarePokemon:
    Message PokemonDayCare_Text_CheckOnDayCarePokemon
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_BgSign:
    EventMessage PokemonDayCare_Text_PokemonGrowsWithYou
    End


// Sovereign (E10): Renegade Platinum's training NPCs. Traynee battles teams that give EXP (Healing Wish Chansey and
// Blissey at the level picked, unlocked as the story goes on) or one stat's EVs (Lv. 10 teams worth 1, 2 or 3 EVs
// each). The rancher sells 15 of each EV-reducing Berry for $5,000.
PokemonDayCare_SovereignTraynee:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    BufferPlayerName 0
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_TRAYNEE_POWER_ITEMS, PokemonDayCare_SovereignTrayneeMenu
    Message PokemonDayCare_Text_SovereignTrayneeIntro
    SetVar VAR_0x8005, 1
    SetVar VAR_0x8004, ITEM_POWER_WEIGHT
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_POWER_BRACER
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_POWER_BELT
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_POWER_LENS
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_POWER_BAND
    Common_GiveItemQuantity
    SetVar VAR_0x8004, ITEM_POWER_ANKLET
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_TRAYNEE_POWER_ITEMS
    Message PokemonDayCare_Text_SovereignTrayneeAllDone
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignTrayneeMenu:
    Message PokemonDayCare_Text_SovereignTrayneeWhatToTrain
    InitLocalTextMenu 31, 1, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuExperience, 0
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuHP, 1
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuAttack, 2
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuDefense, 3
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuSpAttack, 4
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuSpDefense, 5
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuSpeed, 6
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuCancel, 7
    ShowMenu
    SetVar VAR_0x8001, VAR_RESULT
    GoToIfEq VAR_0x8001, 0, PokemonDayCare_SovereignTrayneeExpMenu
    GoToIfEq VAR_0x8001, 7, PokemonDayCare_SovereignTrayneeNotToday
    GoToIfLe VAR_0x8001, 6, PokemonDayCare_SovereignTrayneeStatMenu
PokemonDayCare_SovereignTrayneeNotToday:
    Message PokemonDayCare_Text_SovereignTrayneeNotToday
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignTrayneeStatMenu:
    Message PokemonDayCare_Text_SovereignTrayneeWhatLevel
    InitLocalTextMenu 31, 9, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLow, 0
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuMedium, 1
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuHigh, 2
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuCancel, 7
    ShowMenu
    SetVar VAR_0x8002, VAR_RESULT
    GoToIfGt VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeNotToday
    GoToIfEq VAR_0x8001, 1, PokemonDayCare_SovereignTrayneeStat1
    GoToIfEq VAR_0x8001, 2, PokemonDayCare_SovereignTrayneeStat2
    GoToIfEq VAR_0x8001, 3, PokemonDayCare_SovereignTrayneeStat3
    GoToIfEq VAR_0x8001, 4, PokemonDayCare_SovereignTrayneeStat4
    GoToIfEq VAR_0x8001, 5, PokemonDayCare_SovereignTrayneeStat5
    GoToIfEq VAR_0x8001, 6, PokemonDayCare_SovereignTrayneeStat6
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat1:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_HP_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_HP_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_HP_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat2:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_ATTACK_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_ATTACK_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_ATTACK_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat3:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_DEFENSE_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_DEFENSE_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_DEFENSE_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat4:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_ATTACK_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_ATTACK_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_ATTACK_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat5:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_DEFENSE_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_DEFENSE_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SP_DEFENSE_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeStat6:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SPEED_LOW
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SPEED_MEDIUM
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeBattle
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_SPEED_HIGH
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeBattle
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeExpMenu:
    Message PokemonDayCare_Text_SovereignTrayneeWhatExpLevel
    InitLocalTextMenu 31, 1, 0, VAR_RESULT
    SetMenuXOriginToRight
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv25, 0
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv35, 1
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv45, 2
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv55, 3
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv65, 4
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv75, 5
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuLv85, 6
    AddMenuEntryImm PokemonDayCare_Text_SovereignMenuCancel, 7
    ShowMenu
    SetVar VAR_0x8002, VAR_RESULT
    GoToIfEq VAR_0x8002, 0, PokemonDayCare_SovereignTrayneeExp25
    GoToIfEq VAR_0x8002, 1, PokemonDayCare_SovereignTrayneeExp35
    GoToIfEq VAR_0x8002, 2, PokemonDayCare_SovereignTrayneeExp45
    GoToIfEq VAR_0x8002, 3, PokemonDayCare_SovereignTrayneeExp55
    GoToIfEq VAR_0x8002, 4, PokemonDayCare_SovereignTrayneeExp65
    GoToIfEq VAR_0x8002, 5, PokemonDayCare_SovereignTrayneeExp75
    GoToIfEq VAR_0x8002, 6, PokemonDayCare_SovereignTrayneeExp85
    GoTo PokemonDayCare_SovereignTrayneeNotToday

PokemonDayCare_SovereignTrayneeExp25:
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_25
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp35:
    CheckBadgeAcquired BADGE_ID_COBBLE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_35
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp45:
    GoToIfUnset FLAG_FIRST_ARRIVAL_CELESTIC_TOWN, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_45
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp55:
    CheckBadgeAcquired BADGE_ID_ICICLE, VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_55
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp65:
    GoToIfUnset FLAG_FIRST_ARRIVAL_POKEMON_LEAGUE, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_65
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp75:
    GoToIfUnset FLAG_GAME_COMPLETED, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_75
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeExp85:
    GoToIfUnset FLAG_ARRESTED_CHARON_STARK_MOUNTAIN, PokemonDayCare_SovereignTrayneeNotStrongEnough
    SetVar VAR_0x8004, TRAINER_SOVEREIGN_TRAYNEE_EXP_85
    GoTo PokemonDayCare_SovereignTrayneeBattle

PokemonDayCare_SovereignTrayneeNotStrongEnough:
    Message PokemonDayCare_Text_SovereignTrayneeNotStrongEnough
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignTrayneeBattle:
    Message PokemonDayCare_Text_SovereignTrayneeLetsStart
    CloseMessage
    StartTrainerBattle VAR_0x8004
    CheckWonBattle VAR_RESULT
    GoToIfEq VAR_RESULT, FALSE, PokemonDayCare_SovereignTrayneeLost
    HealParty
    Message PokemonDayCare_Text_SovereignTrayneeFantastic
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignTrayneeLost:
    ReturnToField
    FadeScreenIn FADE_SCREEN_SPEED_MEDIUM
    WaitFadeScreen
    HealParty
    Message PokemonDayCare_Text_SovereignTrayneeTooRough
    WaitButton
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignRancher:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    Message PokemonDayCare_Text_SovereignRancherSellBerries
    ShowMoney 20, 2
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_NO, PokemonDayCare_SovereignRancherNo
    GoToIfNotEnoughMoney 5000, PokemonDayCare_SovereignRancherNotEnoughMoney
    GoToIfCannotFitItem ITEM_POMEG_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    GoToIfCannotFitItem ITEM_KELPSY_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    GoToIfCannotFitItem ITEM_QUALOT_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    GoToIfCannotFitItem ITEM_HONDEW_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    GoToIfCannotFitItem ITEM_GREPA_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    GoToIfCannotFitItem ITEM_TAMATO_BERRY, 15, VAR_RESULT, PokemonDayCare_SovereignRancherBagFull
    SetVar VAR_0x8006, 5000
    RemoveMoney2 VAR_0x8006
    UpdateMoneyDisplay
    PlaySE SEQ_SE_DP_REGI_sseq
    WaitSE SEQ_SE_DP_REGI_sseq
    AddItem ITEM_POMEG_BERRY, 15, VAR_RESULT
    AddItem ITEM_KELPSY_BERRY, 15, VAR_RESULT
    AddItem ITEM_QUALOT_BERRY, 15, VAR_RESULT
    AddItem ITEM_HONDEW_BERRY, 15, VAR_RESULT
    AddItem ITEM_GREPA_BERRY, 15, VAR_RESULT
    AddItem ITEM_TAMATO_BERRY, 15, VAR_RESULT
    Message PokemonDayCare_Text_SovereignRancherHereYouGo
    WaitButton
    HideMoney
    CloseMessage
    ReleaseAll
    End

PokemonDayCare_SovereignRancherNo:
    Message PokemonDayCare_Text_SovereignRancherDontWant
    GoTo PokemonDayCare_SovereignRancherEnd

PokemonDayCare_SovereignRancherNotEnoughMoney:
    Message PokemonDayCare_Text_SovereignRancherNotEnoughMoney
    GoTo PokemonDayCare_SovereignRancherEnd

PokemonDayCare_SovereignRancherBagFull:
    Message PokemonDayCare_Text_SovereignRancherBagFull
PokemonDayCare_SovereignRancherEnd:
    WaitButton
    HideMoney
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
