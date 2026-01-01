//
//  ListRowStyle.swift
//  PrayerTracker
//
//  Created by Abdülhamit Oral on 16.12.25.
//

import SwiftUI

struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
            )
    }
}

extension View {
    func styledListRow() -> some View {
        modifier(ListRowStyle())
    }
}

#Preview {
    List {
        Text("Example Row 1")
            .styledListRow()
        Text("Example Row 2")
            .styledListRow()
    }
}
