# WoWForeverWindfuryTimer

[![Tests](https://github.com/gn4rwhals/WoWForeverWindfuryTimer/actions/workflows/test.yml/badge.svg)](https://github.com/gn4rwhals/WoWForeverWindfuryTimer/actions/workflows/test.yml)

WoW Forever add-on for Enhancement Shamans. When Windfury procs, a movable red number counts down 1.5 seconds (`1.5`, `1.4`, ... `0.1`) so you know not to cast Stormstrike in that window. It is hidden the rest of the time.

## Install

Download `WoWForeverWindfuryTimer-<version>.zip` from [Releases](https://github.com/gn4rwhals/WoWForeverWindfuryTimer/releases) and unpack it into `World of Warcraft\_forever_\Interface\AddOns\`. Do not use the "Source code" zip.

From the repo instead: copy or link the `WoWForeverWindfuryTimer` folder into `World of Warcraft\_forever_\Interface\AddOns\`. For development, a junction keeps the game in sync with the repo:

```powershell
New-Item -ItemType Junction -Path "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\WoWForeverWindfuryTimer" -Target "C:\Repos\WoWForeverWindfuryTimer\WoWForeverWindfuryTimer"
```

## Commands

| Command | Effect |
|---|---|
| `/wft unlock` | Show the timer so it can be dragged |
| `/wft lock` | Fix it in place and hide it until a proc |
| `/wft reset` | Move the timer back to screen center |
| `/wft test` | Start a 1.5 second countdown now |
| `/wft match <text or spellID>` | What counts as a proc (default `Windfury`). No argument prints the current value |
| `/wft debug` | Toggle debug: prints listened/blocked events, every spell you cast, and each detected proc |

## How procs are detected

Forever may block the combat log for add-ons, so the add-on listens to every source that might report a Windfury proc and uses whichever the game allows:

1. Combat log (`COMBAT_LOG_EVENT_UNFILTERED`), your spells named like the match text
2. Your spell casts (`UNIT_SPELLCAST_SUCCEEDED`)
3. Old style combat chat events, if the client has them

A spell name or message containing `Windfury` counts as a proc. Casting Windfury Totem or Windfury Weapon yourself may also start the countdown. To stop that, turn on `/wft debug`, melee until a proc shows `proc via ...: <name> <spellID>`, then set `/wft match <spellID>`.

If debug shows no `proc via` line on a proc, none of the sources work on Forever. Please open an issue with the debug output.

## Development

- `WoWForeverWindfuryTimer/Timer.lua`: pure logic, unit tested.
- `Core.lua`, `Display.lua`, `Detect.lua`: WoW API glue.
- Tests: [busted](https://lunarmodules.github.io/busted/) on Lua 5.1, run from repo root: `busted spec`.
- Release: bump `## Version:` in the `.toc` on main, then push a matching tag (`git tag v0.2.0 && git push origin v0.2.0`). The Release workflow runs the tests, checks the tag against the TOC and publishes the zip.
