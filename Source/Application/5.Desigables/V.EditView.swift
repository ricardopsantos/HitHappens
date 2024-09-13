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
import Common

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
            if onEdit {
                HStack(spacing: 0) {
                    saveEditionChangesView
                    SwiftUIUtils.FixedHorizontalSpacer(width: SizeNames.defaultMarginSmall)
                    doEditionView
                }
            } else {
                doEditionView
            }
        }
    }

    @ViewBuilder
    var doEditionView: some View {
        let text = onEdit ? "Cancel".localizedMissing : "Edit".localizedMissing
        let background: ColorSemantic = onEdit ? ColorSemantic.primary : ColorSemantic.primary
        let style: TextButton.Style = onEdit ? .secondary : .primary
        TextButton(
            onClick: {
                onEdit.toggle()
                onCancelEdit()
            },
            text: text,
            style: style,
            background: background,
            accessibility: .editButton)
    }

    @ViewBuilder
    var saveEditionChangesView: some View {
        Group {
            if onEdit {
                TextButton(onClick: {
                    onEdit.toggle()
                    onConfirmEdit()
                }, text: "Confirm".localizedMissing,
                           style: .primary,
                           accessibility: .confirmButton)
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
