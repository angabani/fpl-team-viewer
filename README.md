# FPL Team Viewer

A small UIKit app to browse Premier League teams and their squads, using the Fantasy Premier League API.

The exercise brief is in [docs/Requirements.md](docs/Requirements.md).

## Build and run

- Xcode 27 or later. iOS 17.0+ deployment target.
- Open `FPLTeamViewer.xcodeproj`, pick the `FPLTeamViewer` scheme and an iPhone or iPad simulator, press Run.
- Tests: `Cmd + U`, or
  ```
  xcodebuild test -project FPLTeamViewer.xcodeproj -scheme FPLTeamViewer -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
  ```
- No third party dependencies. No signing team is set, so pick your own to run on a device.

## What it does

- **Teams**: name, short name and player count. Sorted by name. Tap to open the squad.
- **Squad**: players grouped as Goalkeepers, Defenders, Midfielders, Forwards. Each shows name, position, price and total points. Sorted by points, then name.
- **Extra info** (beyond the brief, same API call):
  - Team card: squad value and top scorer, e.g. "£176.9m squad · Top: Saka 32 pts".
  - Player card: form and ownership, e.g. "Form 6.0 · 42.3% selected".
  - Player card: an orange line when a player is doubtful and a red line when injured, suspended or gone, using FPL's own news text.
- **Search**: filters the squad on every keystroke. Ignores case and accents ("martin" finds "Martín").
- **States**: loading, loaded, empty, error with Retry, pull to refresh on both screens. When saved data is on screen and fresh data is loading, a small spinner shows in the nav bar. If a refresh fails, the data stays and a small banner explains it.
- **Offline**: the last good response is saved to disk. On launch the app shows it right away, then refreshes from the API.
- **Adaptive layout**: one column with push navigation on narrow screens. Teams and squad side by side on wide screens (unfolded iPhone Duo, iPad). The card grid fits as many columns as the current width allows, with a minimum card width that grows with text size. No fixed device breakpoints.

## Architecture

MVVM with a coordinator and a repository.

```
SceneDelegate -> FPLAppCoordinator (UISplitViewController)
  FPLTeamsViewController <-> FPLTeamsViewModel --+
  FPLSquadViewController <-> FPLSquadViewModel --+-> IFPLRepository
                                                      |- IFPLAPIClient   (URLSession)
                                                      |- IFPLCacheStore  (JSON file)
                                                      |- FPLBootstrapMapper (DTO -> model)
```

Why:

- **MVVM**: view models hold all screen logic and state, with no UIKit. That makes the important behaviour easy to unit test. View controllers only render.
- **Coordinator**: screens do not push other screens. Navigation lives in one place, which also owns the split view. Adding a screen means a new folder and one coordinator method.
- **Repository**: the only place that knows about network and cache. View models just ask for teams.
- **Protocols for every dependency** (`I` prefix). Built once in `FPLAppDependencies` and passed down. Tests swap in mocks. No singletons.
- **Plain closures for binding** (`onStateChange`, `onRefreshError`). No Combine needed for two screens, and it is easy to follow.
- **One `FPLViewState` enum** per screen: `loading`, `loaded`, `empty`, `failed`. Refresh is kept out of it on purpose, so a refresh can never hide data that is already on screen.
- **Swift 6 language mode**. View models are `@MainActor`. Models are `Sendable` structs. Network, decoding and file IO run off the main thread.
- **Native UI pieces**: `UICollectionView` with compositional layout and diffable data source, `UIContentUnavailableConfiguration` for loading, empty and error states, `UISearchController`, `UIRefreshControl`, `UISplitViewController`.

Folders follow the same idea: `App`, `Navigation`, `Services`, `Cache`, `Repository`, `Models`, `UI/<Feature>`, `UI/Components`, `Constants`, `Utils`.

## Assumptions

- One API call (`bootstrap-static`) has everything needed. Squad data comes from it too, no extra call per team.
- Positions come from `element_type` 1 to 4. Any other value (e.g. the managers some seasons add) is skipped.
- Price is `now_cost / 10`, shown as "£6.1m".
- Short name (`web_name`) is the main label. Full name is shown under it and is also searchable.
- The raw response is cached as is. It is only saved after it decodes, so a bad response never replaces a good cache.

## Tests

Swift Testing, no live API. A trimmed fixture JSON and a `URLProtocol` stub stand in for the network.

- Decoding: fixture, unknown keys, missing fields, invalid JSON.
- Mapping: player count per team, grouping by position, sort order, price format, unknown position.
- Search: case, accents, partial and full name, spaces, no match.
- Errors: non-2xx, offline, timeout, user messages.
- Cache: save/load, overwrite, clear, path with spaces, corrupt file, failed fetch keeps old cache.
- View models: initial failure then retry, refresh failure keeps data, offline launch with cache, background refresh signal, empty states, search.
- Extra info: squad value, top player, status mapping, form and ownership.
- Grid: column count from width and text size.

### Coverage

85 tests. Line coverage from Xcode, measured on 29 Sep 2026:

| Layer | Coverage |
|---|---|
| View models + search | 98.3% |
| Repository + mapping | 98.2% |
| Cache | 96.2% |
| Networking | 93.1% |
| Models | 100% |
| Utils + constants | 73.8% |
| **Non-UI total** | **94.5%** |
| Views, cells, coordinator | 2.3% |
| Whole app | 34.7% |

Views and view controllers only render what the view models give them. They are not the target of unit tests, so the whole-app number is low by design. A UI test for the main flow is on the list below.

To see it yourself: Edit Scheme > Test > Options > Code Coverage, run `Cmd + U`, then open the Report navigator.

## Known limitations

- The iPhone Duo simulator needs Xcode 27.1 beta. I tested the same layouts on iPhone (narrow) and iPad (wide), which match the folded and unfolded sizes.
- Refreshing on the squad screen does not update the teams list until that list is refreshed too.
- No team badges. They would need image loading and an image cache.
- Strings use `String(localized:)` but there is only English.

## With more time

- A shared in-memory store so both screens update together after any refresh.
- Team badges and player photos with a small image cache.
- A player detail screen, and sort options on the squad (price, form, ownership).
- A UI test for the main flow, and snapshot tests for the cells.
- A "you are offline" indicator driven by `NWPathMonitor`.
