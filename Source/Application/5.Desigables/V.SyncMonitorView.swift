//
//  SyncMonitorView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 08/09/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem
import Common
import CloudKitSyncMonitor

public struct SyncMonitorView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var syncMonitor = SyncMonitor.shared
    private let font: FontSemantic = .caption
    private let opacity: CGFloat = 0.3
    public var body: some View {
        VStack(alignment: .center, spacing: SizeNames.size_2.cgFloat) {
            if syncMonitor.syncStateSummary.isBroken {
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                Text("Sync Broken")
                    .multilineTextAlignment(.center)
                    .fontSemantic(font)
                    .opacity(opacity)
            } else if syncMonitor.syncStateSummary.inProgress {
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                Text("Sync In progress")
                    .multilineTextAlignment(.center)
                    .fontSemantic(font)
                    .opacity(opacity)
            } else {
                Image(systemName: syncMonitor.syncStateSummary.symbolName)
                    .foregroundColor(syncMonitor.syncStateSummary.symbolColor)
                Text(syncMonitor.syncStateSummary.description)
                    .multilineTextAlignment(.center)
                    .fontSemantic(font)
                    .opacity(opacity)
            }
        }
        .animation(.default, value: syncMonitor.syncStateSummary.description)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG

#Preview {
    VStack {
        Spacer()
        SyncMonitorView()
        Spacer()
    }
}
#endif
