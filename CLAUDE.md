# Notes for Claude sessions

## Status file (owner rule, 2026-10-22)

At the end of every significant task, or whenever the owner says credits are running low, write a full summary of
the current state of development to `CLAUDE_STATUS.md` at the repo root. It must include:

1. What was just successfully implemented.
2. The exact files that were modified.
3. The immediate next 3 logical steps or bugs to fix.

Keep it current: replace stale content rather than appending forever.

## All forms (owner rule, 2026-10-22)

Every Pokémon form must exist in the game: regional, Mega/Primal, fusion, battle, item, Totem and cosmetic forms.
Never mark a form "out of scope". **The only exceptions:** no Dynamax/Gigantamax forms, and no unplayable forms (forms
a player can never use in battle: Eternamax Eternatus, Koraidon's Builds, Miraidon's Modes). Terapagos-Stellar is
shelved for now (no Terastallization). If a form seems impossible on the engine, find a way or
ask the owner how it should work. Don't drop it. See decision 16 in `docs/ProjectStatus.md` and milestone FM in
`docs/EngineRoadmap.md`.
