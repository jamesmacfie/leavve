# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Leavve is a SwiftUI-based macOS menubar application that integrates with the Runn API to track employee time-off and leave schedules. The app provides an at-a-glance view of who's on leave today and detailed time-off information for all team members.

**Key Features:**
- Menubar-only app (no dock icon) for quick access
- Real-time sync with Runn API
- Three-page interface: Today's Leave, Employee Details, and Settings
- Automatic daily refresh at configurable time (default 7:00 AM)
- Light and dark mode support
- Persistent storage of settings and cached data

## Build and Development Commands

### Building the Project
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve build
```

### Running the App
Open `Leavve.xcodeproj` in Xcode and run (⌘R), or build via command line:
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve -configuration Debug
```

### Cleaning Build Artifacts
```bash
xcodebuild -project Leavve.xcodeproj -scheme Leavve clean
```

### Testing
The app currently has no automated tests. Manual testing should cover:
- API authentication with Runn API
- Data fetching and pagination
- Auto-refresh timer functionality
- Popover positioning and menu interactions
- Settings persistence

## Architecture

### Core Architecture Pattern

The app uses an **AppDelegate-centric architecture** with SwiftUI views, following a traditional macOS menubar app pattern enhanced with modern SwiftUI:

#### 1. AppDelegate (`AppDelegate.swift`)

Main application controller that:
- Creates and manages the `NSStatusItem` in the system menubar
- Hosts a `NSPopover` containing SwiftUI views via `NSHostingController`
- Uses an invisible `NSWindow` trick to position the popover correctly below the menubar icon
- Handles both left-click (show popover) and right-click (context menu) interactions
- Initializes the popover with 300x300 size and transient behavior

**Key Implementation Details:**
- `invisibleWindow`: A borderless transparent window used as popover anchor
- `popover`: NSPopover instance hosting the SwiftUI `Main` view
- `statusBarItem`: The menubar item with custom icon

#### 2. AppDelegate+Functions (`AppDelegate+Functions.swift`)

Extension containing click handling and menu actions:

- `togglePopover(_ sender: AnyObject?)`: Dispatches left/right clicks
  - Left-click: Shows/hides popover using invisible window positioning
  - Right-click: Displays NSMenu with app actions
- `showPopover()`: Positions invisible window and shows popover relative to status bar
- `closePopover()`: Hides the popover
- `openAbout()`: Creates and displays About window
- `quit()`: Terminates the application

**Event Handling:**
- Button configured with `.sendAction(on: [.leftMouseUp, .rightMouseUp])`
- `togglePopover` inspects `NSApp.currentEvent!.type` to route click events

#### 3. View Layer

SwiftUI views hosted in `NSHostingController`:

- **Main.swift**: Primary popover content with 3-page navigation using `PagerView`
  - Page 0: `HomeView` - Today's leave and employee list
  - Page 1: `EmployeeDetailView` - Selected employee's time-offs
  - Page 2: `SettingsView` - API configuration and preferences

- **HomeView.swift**:
  - Displays employees currently on leave today
  - Shows full employee list with leave indicators
  - Handles data refresh and loading states
  - Navigates to detail view on employee selection

- **EmployeeDetailView.swift**:
  - Shows selected employee's upcoming time-offs
  - Displays time-off cards with dates and types
  - Back navigation to home view

- **SettingsView.swift**:
  - Runn API key configuration
  - Auto-refresh time scheduling
  - Manual refresh trigger
  - Settings persistence

- **About.swift**:
  - Contains `AboutView` (SwiftUI) and `AboutWindowController` (AppKit)
  - Creates standalone window for app information
  - Accessed via right-click context menu

#### 4. State Management

**AppState** (`State/AppState.swift`):
- Central `ObservableObject` managing all app data
- Published properties: `people`, `timeOffs`, `isLoading`, `errorMessage`, `selectedPerson`, `currentPage`
- Integrates with `RunnAPIService` for data fetching
- Manages auto-refresh timer based on user settings
- Provides computed properties for filtered data (e.g., people on leave today)

#### 5. Data Layer

**Models** (`Models/`):
- `Person`: Employee data with Codable conformance for API deserialization
- `TimeOff`: Leave/time-off records with date ranges and types
- `HolidayGroup`: Holiday group classifications
- `AppSettings`: User preferences (API key, refresh time)
- `RunnAPIResponse<T>`: Generic wrapper for paginated API responses

**Services** (`Services/`):
- `RunnAPIService`: Handles all Runn API communication
  - Async/await pattern for network calls
  - Bearer token authentication
  - Pagination support for large datasets
  - Error handling and response parsing

- `StorageService`: UserDefaults wrapper for persistence
  - API key storage
  - Settings persistence
  - Cached data storage

#### 6. Components

Reusable SwiftUI components (`Components/`):
- `PagerView`: Custom ViewBuilder-based page navigation with swipe gestures
- `EmployeeRow`: List item showing employee info and leave status
- `TimeOffCard`: Card display for time-off entries
- `LoadingOverlay`: Full-screen loading indicator

### Key Technical Patterns

**Invisible Window Positioning**: The app uses a transparent `NSWindow` (`invisibleWindow`) positioned at the status bar item's frame to anchor the popover. This ensures the popover's arrow points correctly to the menubar icon, avoiding positioning issues.

**Event Type Dispatch**: The status bar button uses `sendAction(on: [.leftMouseUp, .rightMouseUp])` to handle both click types. The `togglePopover()` method inspects `NSApp.currentEvent!.type` to differentiate and route accordingly.

**SwiftUI-AppKit Bridge**: SwiftUI views are embedded via `NSHostingController`, allowing modern declarative UI in a traditional AppKit menubar app. The bridge enables @StateObject and @EnvironmentObject propagation.

**Page-Based Navigation**: The main popover uses `PagerView` (custom component) with `@Binding` for current page index, enabling swipe gestures and programmatic navigation. State flows through bindings rather than NavigationView.

**Async/Await Networking**: `RunnAPIService` uses Swift's async/await for clean asynchronous API calls with structured concurrency.

**Auto-Refresh Timer**: Timer-based scheduled refresh using `Timer.publish()` and Combine, triggered at user-configured time (default 7:00 AM daily).

## Project Structure

```
Leavve/
├── AppDelegate.swift              # Main app controller, status bar setup
├── AppDelegate+Functions.swift    # Click handling, popover/menu actions
├── Models/
│   ├── Person.swift              # Employee data model (Codable)
│   ├── TimeOff.swift             # Time-off data model (Codable)
│   ├── HolidayGroup.swift        # Holiday group data model
│   ├── AppSettings.swift         # App settings model
│   └── RunnAPIResponse.swift     # Generic API response wrapper
├── Services/
│   ├── StorageService.swift      # UserDefaults persistence layer
│   └── RunnAPIService.swift      # Runn API client (async/await)
├── State/
│   └── AppState.swift            # Central ObservableObject state
├── Views/
│   ├── Main.swift                # Primary popover view (3-page navigation)
│   ├── HomeView.swift            # Home page: today's leave + employee list
│   ├── EmployeeDetailView.swift  # Employee detail page: time-offs
│   ├── SettingsView.swift        # Settings page: API key, auto-refresh
│   └── About.swift               # About window view + controller
├── Components/
│   ├── PagerView.swift           # Reusable page navigation component
│   ├── EmployeeRow.swift         # Employee list item component
│   ├── TimeOffCard.swift         # Time-off card display component
│   └── LoadingOverlay.swift      # Loading indicator overlay
├── Assets.xcassets/              # Images, icons (menubar-icon)
│   └── menubar-icon.imageset/    # Template icon for light/dark mode
├── Trunk/
│   ├── Info.plist                # App configuration (LSUIElement=true)
│   ├── Leavve.entitlements       # Sandbox entitlements
│   └── Base.lproj/Main.storyboard # Empty storyboard (legacy requirement)
├── LICENSE                        # MIT License
└── README.md                      # User-facing documentation
```

## Important Configuration

### Info.plist Settings

- **LSUIElement**: `true` - Makes app menubar-only (no dock icon, no menu bar)
- **CFBundleDisplayName**: "Leavve"
- **CFBundleIdentifier**: Should match your development team

### Entitlements

**Leavve.entitlements**:
- App Sandbox: Enabled
- Network Client: `true` (required for Runn API calls)
- No other special permissions required

### App Defaults

- **Popover Size**: 300x300 (set in `AppDelegate.swift:23`)
- **Auto-Refresh Time**: 7:00 AM (configurable in Settings)
- **API Endpoint**: `https://api.runn.io/` (in `RunnAPIService.swift`)
- **Status Bar Icon**: Template icon with automatic light/dark mode

## Development Notes

### Code Organization Principles

- **Separation of Concerns**: AppKit (AppDelegate) and SwiftUI (Views) are cleanly separated
- **Single Source of Truth**: `AppState` is the only source for app data
- **Persistence**: All settings saved via `StorageService` to UserDefaults
- **Error Handling**: Network errors surface in UI via `AppState.errorMessage`

### Common Modification Points

**To change the status bar icon:**
- Replace images in `Assets.xcassets/menubar-icon.imageset/`
- Ensure `isTemplate = true` is set for automatic tinting (AppDelegate.swift:34)

**To modify right-click menu:**
- Edit `AppDelegate+Functions.swift`, method `togglePopover(_ sender:)`
- Add menu items in the rightClick handling block

**To add new API endpoints:**
- Extend `RunnAPIService.swift` with new async methods
- Add corresponding models in `Models/` if needed
- Update `AppState` to call new endpoints

**To change auto-refresh behavior:**
- Modify timer logic in `AppState.swift`
- Update settings UI in `SettingsView.swift`

**To add new pages:**
- Add view to `Views/`
- Update `Main.swift` PagerView with new page
- Adjust page count and navigation logic

### API Integration

**Runn API Details:**
- Base URL: `https://api.runn.io/`
- Authentication: Bearer token (API key from settings)
- Endpoints used:
  - `/people` - Fetch all employees
  - `/timeoffs` - Fetch time-off records
- Pagination: Uses `offset` and `limit` query parameters

**Data Flow:**
1. User configures API key in Settings
2. `AppState` calls `RunnAPIService.fetchPeople()` and `fetchTimeOffs()`
3. Service makes async API calls with Bearer auth
4. Responses deserialized into `Person` and `TimeOff` models
5. AppState publishes changes, triggering UI updates
6. Data cached locally via `StorageService`

### Debugging Tips

**Popover not showing:**
- Check `invisibleWindow` positioning in `AppDelegate+Functions.swift`
- Verify status bar item exists: `print(statusBarItem.button?.frame)`

**API calls failing:**
- Check API key in Settings
- Verify network entitlements in `.entitlements`
- Add logging in `RunnAPIService.swift`

**Auto-refresh not working:**
- Check timer setup in `AppState.swift`
- Verify app remains running (menubar apps can be suspended)

**Icon not displaying:**
- Ensure `menubar-icon` asset exists in `Assets.xcassets`
- Check `isTemplate = true` for proper tinting

### SwiftUI Previews

Most SwiftUI views require `AppState` environment object. For previews:
```swift
#Preview {
    HomeView()
        .environmentObject(AppState())
}
```

### Memory Management

- Popover and status bar item are strong references in AppDelegate
- AppState is shared via `@StateObject` in Main view
- Views use `@EnvironmentObject` to access shared state
- No manual memory management required; ARC handles cleanup
