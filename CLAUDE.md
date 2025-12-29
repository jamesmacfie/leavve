# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Leavve is a SwiftUI-based macOS menubar app for tracking employee leave from the Runn API. It displays who's on leave today, provides employee-specific time-off details, and allows configuration of sync settings.

## Build and Development Commands

### Building the Project
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve build
```

### Running the App
Open `Leavve.xcodeproj` in Xcode and run the project (⌘R), or:
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve -configuration Debug
```

### Cleaning Build Artifacts
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve clean
```

## Architecture

### Core Architecture Pattern

The app uses an **AppDelegate-centric architecture** with SwiftUI views:

1. **AppDelegate** (`AppDelegate.swift`) - Main application controller that:
   - Creates and manages the status bar item
   - Hosts the popover containing SwiftUI views
   - Uses an invisible window trick to position the popover correctly below the menubar icon
   - Handles both left-click (popover) and right-click (context menu) interactions

2. **AppDelegate+Functions** (`AppDelegate+Functions.swift`) - Extension containing:
   - `togglePopover()` - Handles left/right click detection and routing
   - Left-click: Shows/hides the popover using invisible window positioning
   - Right-click: Displays NSMenu with app actions (About, Quit, etc.)
   - Context menu actions (`openAbout()`, `quit()`)

3. **View Layer** - SwiftUI views hosted in NSHostingController:
   - `Main.swift` - Primary popover content with 3-page navigation
   - `HomeView.swift` - Shows who's on leave today and all employees
   - `EmployeeDetailView.swift` - Shows upcoming time-offs for selected employee
   - `SettingsView.swift` - API configuration and auto-refresh settings
   - `About.swift` - About window shown via `AboutWindowController.createWindow()`
   - Uses `PagerView` component for swipe-based page navigation

### Key Technical Patterns

**Invisible Window Positioning**: The app uses a transparent NSWindow (`invisibleWindow`) positioned at the status bar item's location to anchor the popover. This ensures the popover arrow points correctly to the menubar icon.

**Event Type Dispatch**: The status bar button's action uses `sendAction(on: [.leftMouseUp, .rightMouseUp])` to handle both click types. The `togglePopover()` method inspects `NSApp.currentEvent!.type` to route accordingly.

**SwiftUI-AppKit Bridge**: SwiftUI views are embedded via `NSHostingController`, allowing modern SwiftUI UI in a traditional AppKit menubar app.

**Page-Based Navigation**: The main popover uses `PagerView` (a custom ViewBuilder-based component) with `@Binding` for current page index, enabling swipe gestures and programmatic navigation between pages.

**State Management**: Single `AppState` observable object manages all app data (people, time-offs, settings) with `@Published` properties.

**API Integration**: `RunnAPIService` handles Runn API communication with async/await, pagination support, and Bearer authentication.

**Auto-Refresh**: Timer-based scheduled refresh at user-configured time (default 7:00 AM).

## Project Structure

```
Leavve/
├── AppDelegate.swift              # Main app controller, status bar setup
├── AppDelegate+Functions.swift    # Click handling, menu actions
├── Models/
│   ├── Person.swift              # Employee data model
│   ├── TimeOff.swift             # Time-off data model
│   ├── HolidayGroup.swift        # Holiday group data model
│   ├── AppSettings.swift         # App settings model
│   └── RunnAPIResponse.swift     # API response wrapper
├── Services/
│   ├── StorageService.swift      # UserDefaults persistence
│   └── RunnAPIService.swift      # Runn API client
├── State/
│   └── AppState.swift            # Central observable state
├── Views/
│   ├── Main.swift                # Primary popover view (3 pages)
│   ├── HomeView.swift            # Home page with leave list
│   ├── EmployeeDetailView.swift  # Employee detail page
│   ├── SettingsView.swift        # Settings page
│   └── About.swift               # About window view + controller
├── Components/
│   ├── PagerView.swift           # Reusable page navigation component
│   ├── EmployeeRow.swift         # Employee list item
│   ├── TimeOffCard.swift         # Time-off card display
│   └── LoadingOverlay.swift      # Loading indicator
├── Assets.xcassets/              # Images including "menubar-icon"
└── Trunk/
    ├── Info.plist                # LSUIElement=true (no dock icon)
    └── Leavve.entitlements       # App sandbox settings (network access)
```

## Important Configuration

- **LSUIElement**: Set to `true` in `Info.plist` - this makes the app menubar-only (no dock icon)
- **App Sandbox**: Enabled in entitlements with network client access for API calls
- **Popover Size**: Default 300x300, set in `AppDelegate.swift`
- **Status Bar Icon**: Configured in AppDelegate with light/dark mode support
- **Auto-Refresh**: Enabled by default at 7:00 AM, configurable in Settings

## Development Notes

When modifying this app:
- The status bar button configuration (icon, template mode) is in `AppDelegate.swift`
- Right-click menu items are defined in `AppDelegate+Functions.swift`
- API configuration is in `RunnAPIService.swift` with Runn API endpoints
- All data models are Codable for JSON serialization
- Auto-refresh timer setup is in `AppState.swift`
- Settings are persisted in UserDefaults via `StorageService.swift`
