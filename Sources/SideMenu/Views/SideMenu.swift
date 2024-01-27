//
//  SideMenu.swift
//  SideMenu
//
//  Created by Josh Robbins on 1/21/24.
//

import SwiftUI

/// Simple class for creating a vertical SideMenu
struct SideMenu<Content: View>: View {
  
  /// The sizing method of the SideMenu
  enum SideMenuSizingMethod {
    case fixed(CGFloat), percentageOfScreen(CGFloat)
  }
  
  /// The type of dimmed background
  enum SideMenuDimBackgroudType {
    case color(Color), blur, none
  }
  
  /// The state of the SideMenu
  enum SidemMenuState: String {
    case onOpen, onDismiss
  }
  
  /// The horizontal aligjnemt of the SideMenu
  enum Alignment {
    case left, right
  }
  
  /// The type of gestures to dismiss the SideMenu
  enum DismissType {
    case tap, drag, tapAndDrag
  }
  
  /// Whether to allow the use of OSLog for the SideMenu
  private var allowsDebug = true
  
  /// The alignment of the SideMenu in relation to the vertical screen edges
  var alignment: Alignment
  
  /// The width of the menu on relations to its's parent = UIScreen.main.bounds x menuScalar
  var sideMenuSizingMethod: SideMenuSizingMethod
  
  /// The backgroundColor of the SideMenu
  var backgroundColor: Color
  
  /// The dimBackgroundType of the SideMenu
  var dimBackgroundType: SideMenuDimBackgroudType
  
  /// The radius of the top and bottom extents of the SideMenu
  var cornerRadius: CGFloat
  
  /// The style of haptic feedback which the SideMenu plays on dismissal
  var dismissalHapticSyle: UIImpactFeedbackGenerator.FeedbackStyle?
  
  /// The backgroundColor of the toolBar
  var toolbarBackgroundColor: Color = .clear
  
  /// Binding to observe and trigger the showing of the SideMenu
  @Binding var shouldShowSideMenu: Bool
  
  /// The offset of the SideMenu used to postion it in relation the screen
  @State private var currentOffset: CGFloat = 0
  
  /// The threshold which must be met before dismissing the SIdeMenu
  @State private var dismissalThreshold: CGFloat = 0
  
  /// The actual width of the SideMenu
  @State private var sideMenuWidth: CGFloat = 0
  
  /// Prevents interaction of the gesture when animating the currentOfset
  @State private var sideMenuDisabled = false
  
  /// The size of the UIScreen
  @State var screenSize: CGSize = .zero
  
  /// The safeAreaInsets of the SideMenu
  @State var safeAreaInsets: EdgeInsets = .init(
    top: 0, leading: 0, bottom: 0, trailing: 0
  )
  
  /// The opacity of the dimmedBackground
  @State var backgroundOpacity: CGFloat = 1
  
  /// The main content of the SideMenu
  private var content: Content
  
  /// An optinal Toolbar for the SideMeny
  private var toolbar: AnyView?
  
  /// Closure to listen to changes in the SideMenu State
  var sideMenuCallback: ( (SidemMenuState) -> Void )?
  
  // MARK: - Initialization
  
  private init(
    alignment: SideMenu.Alignment = .left,
    sideMenuSizingMethod: SideMenuSizingMethod = .percentageOfScreen(0.5),
    backgroundColor: Color = .black,
    dimBackgroundType: SideMenuDimBackgroudType = .blur,
    cornerRadius: CGFloat = 20,
    dismissalHapticSyle: UIImpactFeedbackGenerator.FeedbackStyle? = .medium,
    shouldShowSideMenu: Binding<Bool>,
    @ViewBuilder content: () -> Content,
    toolbar: AnyView?,
    toolBarBackgroundColor: Color = .clear,
    sideMenuCallback: ( (SidemMenuState) -> Void )? = nil) {
      _shouldShowSideMenu = shouldShowSideMenu
      self.content = content()
      self.alignment = alignment
      self.sideMenuSizingMethod = sideMenuSizingMethod
      self.dimBackgroundType = dimBackgroundType
      self.backgroundColor = backgroundColor
      self.cornerRadius = cornerRadius
      self.dismissalHapticSyle = dismissalHapticSyle
      self.toolbar = toolbar
      self.toolbarBackgroundColor = toolBarBackgroundColor
      self.sideMenuCallback = sideMenuCallback
    }
  
  // MARK: - Body
  
  var body: some View {
    
    ZStack {
      GeometryReader { proxy in
        ZStack {
          sideMenuContent
            .frame(width: sideMenuWidth)
            .onChange(of: proxy.size) { _ in
              runAnimationBlock { calculateSizeOfSideMenu(from: proxy) }
            }
        }.onAppear {
          calculateSizeOfSideMenu(from: proxy)
        }.onChange(of: currentOffset) { _ in setBackgroundOpacity() }
          .onChange(of: shouldShowSideMenu) { shouldShowSideMenu in
            handleVisibility(shouldShowSideMenu)
          }.frame(maxWidth: .infinity, alignment: alignment == .left ? .leading : .trailing)
          .offset(x: currentOffset)
          .tapAndDragGestureRecognition { handleGesture($0) }.disabled(sideMenuDisabled)
      } .background {
        dimBackground.opacity(backgroundOpacity).ignoresSafeArea()
      }
    }
  }
  
  // MARK: - Content
  
  @ViewBuilder
  private var backgroundContainer: some View {
    backgroundColor.ignoresSafeArea(.all)
      .roundedCornerStyle(
        topLeadingRadius: alignment == .left ? 0 : cornerRadius,
        bottomLeadingRadius: alignment == .left ? 0 : cornerRadius,
        bottomTrailingRadius: alignment == .left ? cornerRadius : 0,
        topTrailingRadius: alignment == .left ? cornerRadius : 0
      ).ignoresSafeArea(.all)
  }
  
  @ViewBuilder
  private var dimBackground: some View {
    switch dimBackgroundType {
    case .color(let backgroundColor):
      Rectangle().fill(backgroundColor)
    case .blur:
      Color.clear.background(.ultraThinMaterial)
    case .none:
      EmptyView()
    }
  }
  
  @ViewBuilder
  private var sideMenuContent: some View {
    VStack(spacing: 0) {
      if let toolbar = toolbar {
        VStack(spacing: 0) {
          toolbar.frame(height: 50)
            .ignoresSafeArea(.container, edges: .horizontal)
            .padding(.bottom, 8)
        }
      }
      content.roundedCornerStyle(
        topLeadingRadius: alignment == .left ? 0 : cornerRadius,
        bottomLeadingRadius: alignment == .left ? 0 : cornerRadius,
        bottomTrailingRadius: alignment == .left ? cornerRadius : 0,
        topTrailingRadius: alignment == .left ? cornerRadius : 0
      ).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment == .left ? .leading : .trailing)
        .ignoresSafeArea(.container, edges:  toolbar == nil ? [.horizontal, .bottom] : .all)
    }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      .background {
        backgroundContainer
      }.statusBar(hidden: true)
  }
  
  // MARK: - Sizing
  
  private func calculateSizeOfSideMenu(from proxy: GeometryProxy) {
    
    safeAreaInsets = proxy.safeAreaInsets
    
    switch sideMenuSizingMethod {
    case .fixed(let width):
      sideMenuWidth = width
    case .percentageOfScreen(let scalar):
      sideMenuWidth = ceil(proxy.size.width * scalar)
    }
    dismissalThreshold = -ceil((sideMenuWidth * 0.3))
    
    if shouldShowSideMenu {
      currentOffset = 0
    } else {
      calculateOffScreenOffset()
    }
    
    let debugInfo = """
      
      Width Of SideMenu \(sideMenuWidth)
      Expected Dismissal Threshold \(dismissalThreshold)
    """
    logMessage(debugInfo)
  }
  
  // MARK: - Opacity
  
  /// Animates the opacity of the background overlay on the parent
  private func setBackgroundOpacity() {
    let fullOffset = -(sideMenuWidth + safeAreaInsets.leading + safeAreaInsets.trailing)
    
    withAnimation(.easeInOut(duration: 0.2)) {
      backgroundOpacity = Double(1 - (abs(currentOffset) / abs(fullOffset)))
    }
  }
  
  // MARK: - Gesture Logic
  
  /// Handles the output returnes from the drag and tap gesture
  /// - Parameter output: TapAndDragOutput
  private func handleGesture(_ output: TapAndDragOutput) {
    
    switch output.gestureKind {
    case .drag:
      if output.gestureState == .cancelled, shouldShowSideMenu, currentOffset != 0 {
        animateToScreenEdge()
      }
      else if let translation = output.translation, output.gestureState == .started {
        handleGestureOutput(translation)
      } else {
        animateToScreenEdge()
      }
    case .tap:
      return
    }
  }
  
  /// Handles the translation of the gesture and adjusts the SideMenu as required,.
  /// - Parameter event: CGSize
  private func handleGestureOutput(_ event: CGSize) {
    
    let proposedOffset = ceil(event.width + currentOffset)
    var needsEdgePin = false
    
    if alignment == .left {
      needsEdgePin = proposedOffset > -5 || proposedOffset > 0
    }  else {
      needsEdgePin = proposedOffset < -5 || proposedOffset < 0
    }
    
    let isDismissalDirection = proposedOffset.sign == (alignment == .left ? .minus : .plus)
    let hasExceededDismissalThreshold = ceil(abs(currentOffset)) >= ceil(abs(dismissalThreshold))
    
    if needsEdgePin {
      animateToScreenEdge()
    } else if isDismissalDirection && hasExceededDismissalThreshold && !sideMenuDisabled {
      dismissSideMenu()
    } else {
      runAnimationBlock {
        currentOffset = ceil(event.width)
      }
    }
  }
  
  // MARK: - Callbacks
  
  /// Sets the visibility of the SideMenu based on observance of the shouldSho Biinding<Bool>
  /// - Parameter shouldShowSideMenu: Bool
  private func handleVisibility(_ shouldShowSideMenu: Bool) {
    guard shouldShowSideMenu else {
      dismissSideMenu()
      return
    }
    setSideMenuState(.onOpen)
    sideMenuDisabled = false
    animateToScreenEdge()
  }
  
  /// Calculates the offset of the Menu to ensire it is offScreen
  private func calculateOffScreenOffset() {
    let safeAreaInsetsHorizontal = ceil(safeAreaInsets.leading + safeAreaInsets.trailing)
    let endOffset = ceil(sideMenuWidth + safeAreaInsetsHorizontal)
    
    switch alignment {
    case .left:
      currentOffset = -endOffset
    case .right:
      currentOffset = endOffset
    }
    logMessage("End OffSet \(currentOffset)")
  }
  
  /// Animates the SideMenu to corresponding screen edge
  private func animateToScreenEdge() {
    runAnimationBlock {
      currentOffset = 0
    }
  }
  
  /// Dismisses the SideMenu
  private func dismissSideMenu() {
    runHapticFeedback()
    sideMenuDisabled = true
    shouldShowSideMenu = false
    runAnimationBlock(duration: 0.5) {
      calculateOffScreenOffset()
    }
    runHapticFeedback()
    setSideMenuState(.onDismiss)
  }
  
  /// Generates the haptic feedback if configured
  private func runHapticFeedback() {
    if let dismissalHapticSyle = dismissalHapticSyle, !sideMenuDisabled {
      let generator = UIImpactFeedbackGenerator(style: dismissalHapticSyle)
      generator.prepare()
      generator.impactOccurred()
    }
  }
  
  /// Set the state of the SideMenu based on its position
  /// - Parameter state: SidemMenuState
  private func setSideMenuState(_ state: SidemMenuState) {
    sideMenuCallback?(state)
    logMessage("Current Side Menu State \(state.rawValue)")
  }
  
  // MARK: - Animation
  
  /// Convenience function to run a block inside an animation closure
  /// - Parameters:
  ///   - duration: Double - defaults to 0.1
  ///   - block:  () -> Void
  private func runAnimationBlock(duration: Double = 0.3, _ block: ( () -> Void) ) {
    withAnimation(.spring(duration: duration)) {
      block()
    }
  }
  
  /// Log basic data from the SideMeny
  /// - Parameter message: String
  private func logMessage(_ message: String) {
    guard allowsDebug else { return }
    SideMenuLogger.sideMenu.log("\(message)")
  }
}

// MARK: - Convenience Initialization

extension SideMenu {
  
  /// Creates a SideMenu using a default toolbar
  /// - Parameters:
  ///   - alignment: `SideMenu.Alignment` - The alignment of the SideMenu in relation to the vertical screen edges (either left or right).
  ///   - sideMenuSizingMethod: `SideMenuSizingMethod` - Whetther the SideMenu used a fixed or percentile based width
  ///   - backgroundColor: `Color` - The background color of the SideMenu.
  ///   - dimBackgroundType: `SideMenuDimBackgroudType` the type of dimmedBackground (color, blur, none).
  ///   - cornerRadius: `CGFloat` - The radius for rounding the corners of the SideMenu.
  ///   - dismissalHapticSyle: `UIImpactFeedbackGenerator.FeedbackStyle`? -The style of haptic feedback which the SideMenu plays on dismissal
  ///   - shouldShowSideMenu: `Binding<Bool>` - A binding to a Boolean that controls the visibility of the SideMenu.
  ///   - content: `ViewBuilder` - A closure that returns the main content to be displayed in the SideMenu.
  ///   - sideMenuCallback: `SidemMenuState` - Returns the state of the SideMenu
  public init(
    alignment: SideMenu.Alignment = .left,
    sideMenuSizingMethod: SideMenuSizingMethod = .percentageOfScreen(0.5),
    backgroundColor: Color = .black,
    dimBackgroundType: SideMenuDimBackgroudType = .blur,
    cornerRadius: CGFloat = 20,
    dismissalHapticSyle: UIImpactFeedbackGenerator.FeedbackStyle? = .medium,
    shouldShowSideMenu: Binding<Bool>,
    @ViewBuilder content: () -> Content,
    sideMenuCallback: ( (SidemMenuState) -> Void )? = nil) {
      self.init(
        alignment: alignment,
        sideMenuSizingMethod: sideMenuSizingMethod,
        backgroundColor: backgroundColor,
        dimBackgroundType: dimBackgroundType,
        cornerRadius: cornerRadius,
        dismissalHapticSyle: dismissalHapticSyle,
        shouldShowSideMenu: shouldShowSideMenu,
        content: content,
        toolbar: nil,
        sideMenuCallback: sideMenuCallback
      )
    }
  
  /// Creates a SideMenu with a custom toolbar
  /// - Parameters:
  ///   - alignment: `SideMenu.Alignment` - The alignment of the SideMenu in relation to the vertical screen edges (either left or right).
  ///   - sideMenuSizingMethod: `SideMenuSizingMethod` - Whetther the SideMenu used a fixed or percentile based width
  ///   - backgroundColor: `Color` - The background color of the SideMenu.
  ///   - dimBackgroundType: `SideMenuDimBackgroudType` the type of dimmedBackground (color, blur, none).
  ///   - cornerRadius: `CGFloat` - The radius for rounding the corners of the SideMenu.
  ///   - dismissalHapticSyle: `UIImpactFeedbackGenerator.FeedbackStyle`? -The style of haptic feedback which the SideMenu plays on dismissal
  ///   - shouldShowSideMenu: `Binding<Bool>` - A binding to a Boolean that controls the visibility of the SideMenu.
  ///   - content: `ViewBuilder` - A closure that returns the main content to be displayed in the SideMenu.
  ///   - toolbar: `ViewBuilder` - A closure that returns the toolbar content to be displayed in the SideMenu.
  ///   - toolbarBackgroundColor: `Color` - For best results ensure that this matches the backgroundColor of the toolBar itself
  ///   - sideMenuCallback: `SidemMenuState` - Returns the state of the SideMenu
  
  public init<T: View>(
    alignment: SideMenu.Alignment = .left,
    sideMenuSizingMethod: SideMenuSizingMethod = .percentageOfScreen(0.5),
    backgroundColor: Color = .black,
    dimBackgroundType: SideMenuDimBackgroudType = .blur,
    cornerRadius: CGFloat = 20,
    dismissalHapticSyle: UIImpactFeedbackGenerator.FeedbackStyle? = .medium,
    shouldShowSideMenu: Binding<Bool>,
    @ViewBuilder content: () -> Content,
    @ViewBuilder toolbar: () -> T,
    toolbarBackgroundColor: Color = .clear,
    sideMenuCallback: ( (SidemMenuState) -> Void )? = nil) {
      self.init(
        alignment: alignment,
        sideMenuSizingMethod: sideMenuSizingMethod,
        backgroundColor: backgroundColor,
        dimBackgroundType: dimBackgroundType,
        cornerRadius: cornerRadius,
        dismissalHapticSyle: dismissalHapticSyle,
        shouldShowSideMenu: shouldShowSideMenu,
        content: content,
        toolbar: AnyView(toolbar()),
        toolBarBackgroundColor: toolbarBackgroundColor,
        sideMenuCallback: sideMenuCallback
      )
    }
}
