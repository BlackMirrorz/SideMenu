# SideMenu Swift Package Guide

## Overview
The `SideMenu` Swift package provides a customizable, vertical side menu for SwiftUI applications, featuring various configurations for sizing, background types, alignment, and more.

## Features
- **Sizing Methods**: Choose between fixed width or percentage of screen width.
- **Background Types**: Options include color, blur, or no background.
- **Menu State Tracking**: Supports `onOpen` and `onDismiss` states.
- **Alignment**: Position the menu on the left or right side of the screen.
- **Dismissal Gestures**: Configurable to dismiss via tap, drag, or both.
- **Customization**: Customize background color, corner radius, toolbar style, etc.

## Usage

### Importing the Package

```swift
import SideMenu
```

### Initializing SideMenu Without A Toolbar
Instantiate the `SideMenu` as follows:

```swift
@State var shouldShowMenu: Bool = false

var body: some View {
    SideMenu(
        alignment: .left,
        sideMenuSizingMethod: .percentageOfScreen(0.5),
        backgroundColor: .black,
        dimBackgroundType: .blur,
        cornerRadius: 20,
        dismissalHapticSyle: .medium,
        shouldShowSideMenu: $shouldShowMenu,
        content: {
            YourContentView()
        },
        sideMenuCallback: { state in
            switch state {
            case .onOpen:
               return
            case .onDismiss:
               return
            }
        }
    )
}

```

### Initializing SideMenu With A Toolbar
Instantiate the `SideMenu` as follows:

```swift
@State var shouldShowMenu: Bool = false

var body: some View {
    SideMenu(
        alignment: .left,
        sideMenuSizingMethod: .percentageOfScreen(0.5),
        backgroundColor: .black,
        dimBackgroundType: .blur,
        cornerRadius: 20,
        dismissalHapticSyle: .medium,
        shouldShowSideMenu: $shouldShowMenu,
        content: {
            YourContentView()
        },
        toolbar: {
            ToolbarView()
        },
        toolbarBackgroundColor: .clear,
        sideMenuCallback: { state in
            switch state {
            case .onOpen:
                return
            case .onDismiss:
                return
            }
        }
    )
}

```
### Initialization Parameters for SideMenu

The `SideMenu` can be initialized with the following parameters:

- `alignment`: Determines the horizontal alignment of the SideMenu.
  - default: `SideMenu.Alignment = .left`
  - options: `.left`, `.right`

- `sideMenuSizingMethod`: Defines the sizing method for the SideMenu.
  - default: `SideMenuSizingMethod = .percentageOfScreen(0.5)`
  - options: `.fixed(CGFloat)`, `.percentageOfScreen(CGFloat)`

- `backgroundColor`: Sets the background color of the SideMenu.
  - default: `Color = .black`

- `dimBackgroundType`: Specifies the type of dimmed background.
  - default: `SideMenuDimBackgroudType = .blur`
  - options: `.color(Color)`, `.blur`, `.none`

- `cornerRadius`: The radius for rounding the corners of the SideMenu.
  - default: `CGFloat = 20`

- `dismissalHapticSyle`: The style of haptic feedback which the SideMenu plays on dismissal.
  - default: `UIImpactFeedbackGenerator.FeedbackStyle? = .medium`
  - options: Any `UIImpactFeedbackGenerator.FeedbackStyle`, `nil` for no feedback

- `shouldShowSideMenu`: A binding to a Boolean that controls the visibility of the SideMenu.
  - type: `Binding<Bool>`

- `content`: A closure that returns the main content to be displayed in the SideMenu.
  - type: `@ViewBuilder () -> Content`

- `toolbar`: An optional toolbar for the SideMenu.
  - type: `AnyView?`
  - default: `nil`

- `toolBarBackgroundColor`: The background color of the toolbar.
  - default: `Color = .clear`

- `sideMenuCallback`: A closure that is called when there is a change in the SideMenu's state.
  - type: `((SidemMenuState) -> Void)?`
  - default: `nil`
  - states: `onOpen`, `onDismiss`
