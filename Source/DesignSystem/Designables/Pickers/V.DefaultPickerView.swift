//
//  DatePickerPopover.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI

public struct DefaultPickerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedOption: String
    private let titleStyle: TextStyleTuple
    private let options: [String]
    private let title: String
    public init(
        title: String,
        options: [String],
        selectedOption: Binding<String>,
        titleStyle: TextStyleTuple = (.bodyBold, .labelPrimary)
    ) {
        self._selectedOption = selectedOption
        self.title = title
        self.options = options
        self.titleStyle = titleStyle
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .applyStyle(titleStyle)
                Spacer()
                let picker = Picker("", selection: $selectedOption) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                if #available(iOS 16.0, *) {
                    picker
                        .tint(ColorSemantic.primary.color)
                } else {
                    picker
                }
            }
        } // .debugBackground()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
@available(iOS 17, *)
#Preview {
    VStack {
        DefaultPickerView(
            title: "title",
            options: ["Option 1", "Option 2", "Option 3"],
            selectedOption: .constant("Option 2")
        )
    }
}
#endif
