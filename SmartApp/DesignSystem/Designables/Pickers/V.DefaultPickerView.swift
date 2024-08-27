//
//  DatePickerPopover.swift
//  SmartApp
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
                Picker("", selection: $selectedOption) {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
            }
        } // .debugBackground()
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
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
