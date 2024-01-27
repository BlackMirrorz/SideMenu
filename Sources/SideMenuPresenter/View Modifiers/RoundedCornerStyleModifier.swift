//
//  SideMenu+Modifiers.swift
//  SideMenu
//
//  Created by Josh Robbins on 1/21/24.
//

import Foundation
import SwiftUI

// MARK: - RounderCornerModifier

struct RoundedCornerStyleModifier: ViewModifier {
  var topLeadingRadius = 20.0
  var bottomLeadingRadius = 20.0
  var bottomTrailingRadius = 20.0
  var topTrailingRadius = 20.0
  
  func body(content: Content) -> some View {
    content
      .clipShape(
        .rect(
          topLeadingRadius: topLeadingRadius,
          bottomLeadingRadius: bottomLeadingRadius,
          bottomTrailingRadius: bottomTrailingRadius,
          topTrailingRadius: topTrailingRadius
        )
      )
  }
}

extension View {
  /// Returns the view clipped to a rectangular shape with the rounded corners specified. Defaults to 20
  /// - Parameters:
  ///   - topLeadingRadius: CGFloat (top left corner)
  ///   - bottomLeadingRadius: CGFloat (bottom left corner)
  ///   - bottomTrailingRadius: CGFloat (bottom right corner)
  ///   - topTrailingRadius: CGFloat (top right corner)
  /// - Returns: RoundecCornerViewModifier
  func roundedCornerStyle(
    topLeadingRadius: CGFloat = 20,
    bottomLeadingRadius: CGFloat = 20,
    bottomTrailingRadius: CGFloat = 20,
    topTrailingRadius: CGFloat = 20
  ) -> some View {
    modifier(
      RoundedCornerStyleModifier(
        topLeadingRadius: topLeadingRadius,
        bottomLeadingRadius: bottomLeadingRadius,
        bottomTrailingRadius: bottomTrailingRadius,
        topTrailingRadius: topTrailingRadius
      )
    )
  }
}
