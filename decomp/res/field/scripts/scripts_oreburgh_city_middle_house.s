#include "constants/moves.h"
#include "macros/scrcmd.inc"
#include "res/text/bank/oreburgh_city_middle_house.h"


    ScriptEntry OreburghCityMiddleHouse_MoveDeleter
    ScriptEntryEnd

// Sovereign (E10): as in Renegade, the Move Deleter lives here, beside the Pokémon Center (he was in Canalave City).
OreburghCityMiddleHouse_MoveDeleter:
    PlaySE SE_CONFIRM_sseq_3
    LockAll
    FacePlayer
    GoToIfSet FLAG_MAP_LOCAL_0x01, OreburghCityMiddleHouse_AskForgetSomeMoves
    Message OreburghCityMiddleHouse_Text_ImTheMoveDeleter
    SetFlag FLAG_MAP_LOCAL_0x01
    GoTo OreburghCityMiddleHouse_AskForgetSomeMoves

OreburghCityMiddleHouse_AskForgetSomeMoves:
    Message OreburghCityMiddleHouse_Text_ForgetSomeMoves
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, OreburghCityMiddleHouse_WhichPokemon
    GoToIfEq VAR_RESULT, MENU_NO, OreburghCityMiddleHouse_RememberMe
    End

OreburghCityMiddleHouse_WhichPokemon:
    Message OreburghCityMiddleHouse_Text_WhichPokemon
    CloseMessage
    GoTo OreburghCityMiddleHouse_TryForgetMove

OreburghCityMiddleHouse_TryForgetMove:
    FadeScreenOut
    WaitFadeScreen
    SelectMoveTutorPokemon
    GetSelectedPartySlot VAR_0x8002
    ReturnToField
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_0x8002, PARTY_SLOT_NONE, OreburghCityMiddleHouse_RememberMe
    GetPartyMonSpecies VAR_0x8002, VAR_0x8001
    GoToIfEq VAR_0x8001, SPECIES_NONE, OreburghCityMiddleHouse_NoEggKnowsMoves
    GetPartyMonMoveCount VAR_RESULT, VAR_0x8002
    GoToIfEq VAR_RESULT, 1, OreburghCityMiddleHouse_KnowsOnlyOneMove
    Message OreburghCityMiddleHouse_Text_WhichMove
    CloseMessage
    FadeScreenOut
    WaitFadeScreen
    SelectPartyMonMove VAR_0x8002
    GetSelectedPartyMonMove VAR_0x8001
    ReturnToField
    FadeScreenIn
    WaitFadeScreen
    GoToIfEq VAR_0x8001, MOVE_NOT_SELECTED, OreburghCityMiddleHouse_WhichPokemon
    BufferPartyMoveName 0, VAR_0x8002, VAR_0x8001
    Message OreburghCityMiddleHouse_Text_ShouldMoveBeForgotten
    ShowYesNoMenu VAR_RESULT
    GoToIfEq VAR_RESULT, MENU_YES, OreburghCityMiddleHouse_ForgotMoveCompletely
    GoToIfEq VAR_RESULT, MENU_NO, OreburghCityMiddleHouse_WhichPokemon
    End

OreburghCityMiddleHouse_ForgotMoveCompletely:
    ClearPartyMonMoveSlot VAR_0x8002, VAR_0x8001
    Message OreburghCityMiddleHouse_Text_ForgotMoveCompletely
    PlayFanfare SEQ_WASURE_sseq
    WaitFanfare
    WaitButton
    CloseMessage
    End

OreburghCityMiddleHouse_NoEggKnowsMoves:
    Message OreburghCityMiddleHouse_Text_NoEggKnowsMoves
    CloseMessage
    GoTo OreburghCityMiddleHouse_TryForgetMove

OreburghCityMiddleHouse_KnowsOnlyOneMove:
    Message OreburghCityMiddleHouse_Text_KnowsOnlyOneMove
    CloseMessage
    GoTo OreburghCityMiddleHouse_TryForgetMove

OreburghCityMiddleHouse_RememberMe:
    Message OreburghCityMiddleHouse_Text_RememberMe
    WaitButton
    CloseMessage
    ReleaseAll
    End

    .balign 4, 0
