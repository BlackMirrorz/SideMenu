//
//  TagAndDragViewModifier.swift
//  SideMenu
//
//  Created by Josh Robbins on 1/21/24.
//

import SwiftUI

// MARK: - TagAndDragViewModifier

typealias Callback = ( () -> Void )

struct TapAndDragViewModifier: ViewModifier {
  
  var action: TapAndDragViewClosure
  
  @GestureState private var isDragging: Bool = false
  
  @State private var gestureState: SideMenuGestureState = .idle
  
  func body(content: Content) -> some View {
    let dragGesture = DragGesture(minimumDistance: 20)
      .updating($isDragging) { _, isDragging, _ in
        isDragging = true
      }
      .onChanged(onDragChange(_:))
      .onEnded(onDragEnded(_:))
    
    let tapGesture = SpatialTapGesture()
      .onEnded { value in
        action((value.location, nil, .ended, .tap))
      }
    content.gesture(tapGesture.simultaneously(with: dragGesture))
      .onChange(of: isDragging) { value in
      if value, gestureState != .started {
        gestureState = .started
      } else if !value, gestureState != .ended {
        gestureState = .cancelled
      }
    }
  }
  
  func onDragChange(_ value: DragGesture.Value) {
    guard gestureState == .started || gestureState == .active else { return }
    action((
      location: value.location,
      translation: value.translation,
      gestureState: gestureState,
      gestureKind: .drag)
    )
  }
  
  func onDragEnded(_ value: DragGesture.Value) {
    gestureState = .ended
    action((
      location: value.location,
      translation: value.translation,
      gestureState: gestureState,
      gestureKind: .drag)
    )
  }
}

// MARK: - Convenience

extension View {
 
  func tapAndDragGestureRecognition(action: @escaping TapAndDragViewClosure) -> some View {
    modifier(TapAndDragViewModifier(action: action))
  }
}

enum GestureKind {
  case tap, drag
}
  
enum SideMenuGestureState: Equatable {
  case idle
  case started
  case active
  case ended
  case cancelled
}

typealias TapAndDragOutput = (
  location: CGPoint,
  translation: CGSize?,
  gestureState: SideMenuGestureState,
  gestureKind:  GestureKind
)

typealias TapAndDragViewClosure = (TapAndDragOutput) -> Void

/* 
 Taken & Modified from:
 http://tinyurl.com/5efmkc7k
 http://tinyurl.com/bd6mjr6e
 */
