#include "macros/scrcmd.inc"
#include "constants/npc_trades.h"
#include "res/text/bank/floaroma_town_middle_house.h"

// Sovereign (E10): Renegade Platinum's house. An old swordsman gives TM40 (Aerial Ace) and a Beauty trades her
// SKORUPI for a CHERUBI (NPC_TRADE_GASPAR_HAUNTER, Mindy's trade in Snowpoint City in Platinum). Platinum's Pokémon
// Breeder, Twin (TM88, which was Pluck) and Clefairy are gone, as in Renegade.

    ScriptEntry FloaromaTownMiddleHouse_ExpertM
    ScriptEntry FloaromaTownMiddleHouse_Beauty
    ScriptEntryEnd

FloaromaTownMiddleHouse_ExpertM:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_SOVEREIGN_RECEIVED_FLOAROMA_TM40, FloaromaTownMiddleHouse_IMissTheSword
    Message FloaromaTownMiddleHouse_Text_SovereignTakeThisTM
    SetVar VAR_0x8004, ITEM_TM40
    SetVar VAR_0x8005, 1
    GoToIfCannotFitItem VAR_0x8004, VAR_0x8005, VAR_RESULT, FloaromaTownMiddleHouse_BagIsFull
    Common_GiveItemQuantity
    SetFlag FLAG_SOVEREIGN_RECEIVED_FLOAROMA_TM40
    Message FloaromaTownMiddleHouse_Text_SovereignTM40IsAerialAce
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_IMissTheSword:
    Message FloaromaTownMiddleHouse_Text_SovereignIMissTheSword
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_BagIsFull:
    Common_MessageBagIsFull
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_Beauty:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_TRADED_FOR_GASPAR_HAUNTER, FloaromaTownMiddleHouse_WeGotToBeFriends
    Message FloaromaTownMiddleHouse_Text_SovereignAskTradeCherubiForSkorupi
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, FloaromaTownMiddleHouse_TryTrade
    GoTo FloaromaTownMiddleHouse_OKIfYouDontWant

FloaromaTownMiddleHouse_TryTrade:
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SelectPokemonToTrade
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_RESULT, PARTY_SLOT_NONE, FloaromaTownMiddleHouse_OKIfYouDontWant
    InitNPCTrade NPC_TRADE_GASPAR_HAUNTER
    SetVar VAR_0x8004, VAR_RESULT
    GetPartyMonSpecies VAR_0x8004, VAR_0x8005
    GetNPCTradeRequestedSpecies VAR_RESULT
    GoToIfNe VAR_0x8005, VAR_RESULT, FloaromaTownMiddleHouse_IAskedForCherubi
    StartNPCTrade VAR_0x8004
    FinishNPCTrade
    SetFlag FLAG_TRADED_FOR_GASPAR_HAUNTER
    Message FloaromaTownMiddleHouse_Text_SovereignTreatMySkorupiNicely
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_IAskedForCherubi:
    FinishNPCTrade
    Message FloaromaTownMiddleHouse_Text_SovereignIAskedForCherubi
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_OKIfYouDontWant:
    Message FloaromaTownMiddleHouse_Text_SovereignOKIfYouDontWant
    WaitButton
    CloseMessage
    ReleaseAll
    End

FloaromaTownMiddleHouse_WeGotToBeFriends:
    Message FloaromaTownMiddleHouse_Text_SovereignWeGotToBeFriends
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
