//
//  EditView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 08/09/2024.
//

import Foundation
import SwiftUI
//
import DesignSystem

public struct EditView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var onEdit: Bool
    private let onConfirmEdit: () -> Void
    private let onCancelEdit: () -> Void
    public init(
        onEdit: Binding<Bool>,
        onConfirmEdit: @escaping () -> Void,
        onCancelEdit: @escaping () -> Void) {
        self._onEdit = onEdit
        self.onConfirmEdit = onConfirmEdit
        self.onCancelEdit = onCancelEdit
    }

    public var body: some View {
        Group {
            Divider()
            if onEdit {
                HStack(spacing: 0) {
                    saveEditionChangesView
                    Spacer()
                    doEditionView
                }
            } else {
                doEditionView
            }
            Divider()
        }
    }

    var doEditionView: some View {
        TextButton(
            onClick: {
                onEdit.toggle()
                onCancelEdit()
            },
            text: !onEdit ? "Edit".localizedMissing : "Cancel".localizedMissing,
            style: .textOnly,
            accessibility: .editButton)
    }

    @ViewBuilder
    var saveEditionChangesView: some View {
        Group {
            if onEdit {
                TextButton(onClick: {
                    onEdit.toggle()
                    onConfirmEdit()
                }, text: "Confirm changes", style: .textOnly, accessibility: .editButton)
            } else {
                EmptyView()
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack {
        Spacer()
        EditView(onEdit: .constant(false), onConfirmEdit: {}, onCancelEdit: {})
        Divider()
        EditView(onEdit: .constant(true), onConfirmEdit: {}, onCancelEdit: {})
        Spacer()
    }
}
#endif
