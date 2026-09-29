# iOS Technical Exercise: FPL Team Viewer

## Overview

Build a small native iOS application that allows users to browse Premier League teams and their players using data from the Fantasy Premier League API.

The goal of this exercise is to demonstrate your ability to build a well-structured, responsive iOS application using native Swift and Apple's frameworks.

### Expected effort

**20 - 40 minutes. Use whatever tools you normally work with.**

We are not expecting a production-complete application or extensive visual polish. Prioritise correctness, code quality, native iOS implementation, and thoughtful handling of asynchronous state.

If you don't have time to complete everything, that's completely fine. Please leave a short note explaining what you would have done next and why you prioritised the work you completed.

## Discussion

As part of the technical interview, be prepared to walk through your implementation and explain your engineering decisions. You may need to change your code during the interview as a check.

## Data Source

Use the Fantasy Premier League API:

```
https://fantasy.premierleague.com/api/bootstrap-static/
```

Do not use another backend or proxy service.

The endpoint provides information about Premier League teams, players, positions, and related FPL data.

## Requirements

### 1. Teams

Create a screen displaying the Premier League teams returned by the API.

Each team should display at least:

- Team name
- Short name
- Number of players

You may add additional information or visual elements if you think they improve the experience.

Tapping a team should open its squad.

### 2. Team Squad

Create a screen showing the players belonging to the selected team.

Players should be grouped by position:

- Goalkeepers
- Defenders
- Midfielders
- Forwards

Each player should display at least:

- Name
- Position
- Price
- Total FPL points

Within each position, provide a sensible ordering. For example, players could be ordered by total FPL points.

### 3. Player Search

Allow the user to search for players within the selected team.

Search should update the displayed results as the user types.

### 4. Loading, Refresh and Errors

The application should handle the following states appropriately:

- Initial loading
- Successful loading
- Initial request failure
- Refreshing
- Refresh failure
- Empty results

The user should be able to retry after an initial failure.

The application should support pull-to-refresh.

If a refresh fails after data has already been loaded, **the existing data should remain visible**.

### 5. Offline Behaviour

Cache the last successfully loaded data locally.

If the application is subsequently launched without network connectivity, it should still be able to display the cached data.

You may choose the caching mechanism.

## Technical Requirements

The application must use:

- Swift
- UIKit
- URLSession
- Codable
- Swift Concurrency (`async` / `await`)
- Programmatic UI
- Unit tests

Do not use:

- SwiftUI
- Third-party networking libraries
- Third-party reactive frameworks
- Third-party UI frameworks

You may use Apple's standard frameworks as appropriate.

### Architecture

There is no prescribed architecture.

Choose an approach you believe is appropriate for the size and requirements of the application.

We are interested in the reasoning behind your decisions rather than adherence to a particular architectural pattern.

## Testing

Include unit tests for important non-UI behaviour.

At minimum, tests should cover relevant parts of:

- API/data decoding
- Team/player data transformation
- Player filtering/search
- Error handling
- Caching

Tests should not depend on the live FPL API.

## UX

The application does not need elaborate visual design.

We are looking for a clean, understandable and responsive experience.

Feel free to make reasonable UX or visual decisions beyond the requirements.

## Submission

Please provide:

1. The Xcode project/source code.
2. A short README containing:
   - How to build and run the application.
   - Any assumptions you made.
   - Architectural decisions you made and why.
   - Anything you would improve with more time.
   - Any known limitations.

Please do not spend significant time on the README. We are primarily interested in the implementation.
