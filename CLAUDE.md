# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Barmaid is a SwiftUI-based macOS menubar app boilerplate. It provides a foundation for building menubar applications with popover interfaces, right-click context menus, and about windows.

## Build and Development Commands

### Building the Project
```bash
xcodebuild -project Barmaid.xcodeproj -scheme Barmaid build
```

### Running the App
Open `Barmaid.xcodeproj` in Xcode and run the project (⌘R), or:
```bash
xcodebuild -project Barmaid.xcodeproj -scheme Barmaid -configuration Debug
```

### Cleaning Build Artifacts
```bash
xcodebuild -project Barmaid.xcodeproj -scheme Barmaid clean
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
   - Context menu actions (`openAbout()`, `quit()`, `doStuff()`)

3. **View Layer** - SwiftUI views hosted in NSHostingController:
   - `Main.swift` - Primary popover content with page-based navigation
   - `About.swift` - About window shown via `AboutWindowController.createWindow()`
   - Uses `PagerView` component for swipe-based page navigation

### Key Technical Patterns

**Invisible Window Positioning**: The app uses a transparent NSWindow (`invisibleWindow`) positioned at the status bar item's location to anchor the popover. This ensures the popover arrow points correctly to the menubar icon.

**Event Type Dispatch**: The status bar button's action uses `sendAction(on: [.leftMouseUp, .rightMouseUp])` to handle both click types. The `togglePopover()` method inspects `NSApp.currentEvent!.type` to route accordingly.

**SwiftUI-AppKit Bridge**: SwiftUI views are embedded via `NSHostingController`, allowing modern SwiftUI UI in a traditional AppKit menubar app.

**Page-Based Navigation**: The main popover uses `PagerView` (a custom ViewBuilder-based component) with `@Binding` for current page index, enabling swipe gestures and programmatic navigation between pages.

## Project Structure

```
Barmaid/
├── AppDelegate.swift              # Main app controller, status bar setup
├── AppDelegate+Functions.swift    # Click handling, menu actions
├── Views/
│   ├── Main.swift                # Primary popover view (page-based)
│   └── About.swift               # About window view + controller
├── Components/
│   └── PagerView.swift           # Reusable page navigation component
├── Assets.xcassets/              # Images including "menubar-icon"
└── Trunk/
    ├── Info.plist                # LSUIElement=true (no dock icon)
    └── Barmaid.entitlements      # App sandbox settings
```

## Important Configuration

- **LSUIElement**: Set to `true` in `Info.plist` - this makes the app menubar-only (no dock icon)
- **App Sandbox**: Enabled in entitlements with read-only file access
- **Popover Size**: Default 300x300, set in `AppDelegate.swift:27`
- **Status Bar Icon**: Configured in AppDelegate, supports both icon and text

## Development Notes

When modifying this boilerplate:
- The status bar button configuration (image, title, font) is in `AppDelegate.swift:35-43`
- Right-click menu items are defined in `AppDelegate+Functions.swift:54-59`
- To add new pages, increment `pageCount` in `Main.swift:17` and add view content
- The `doStuff()` function in `AppDelegate+Functions.swift:24` is a placeholder for custom actions
- About window content and version display is in `About.swift`
