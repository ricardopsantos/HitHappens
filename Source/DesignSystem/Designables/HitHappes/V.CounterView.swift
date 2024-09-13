//
//  PickerView.swift
//  HitHappens
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Common
import DevTools

public struct DigitTransitionView: View {
    @State private var imageName: String
    @State private var timer: Timer?
    @Binding private var digit: Int
    private let animated: Bool = Common_Utils.true
    private let onDigitTapGesture: () -> Void
    private var images: [String] {
        let number = $digit.wrappedValue
        return [
            "\(number)00",
            "\(number)25",
            "\(number)50",
            "\(number)75",
            "\(number + 1)00"
        ]
    }

    public init(digit: Binding<Int>, onDigitTapGesture: @escaping () -> Void) {
        self.onDigitTapGesture = onDigitTapGesture
        if animated {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        } else {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        }
    }

    public var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(
                minWidth: CounterView.minWidth,
                maxWidth: CounterView.maxWidth,
                minHeight: CounterView.minHeight,
                maxHeight: CounterView.maxHeight
            )
            .onChange(of: digit) { _ in
                if animated {
                    imageName = "\(digit - 1)00"
                    startAnimation()
                } else {
                    imageName = "\($digit.wrappedValue)00"
                }
            }.onTapGesture {
                onDigitTapGesture()
            }
    }

    func startAnimation() {
        var animationDuration: Double {
            (Common.Constants.defaultAnimationsTime * 2) / Double(images.count)
        }
        var currentIndex = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: animationDuration,
            repeats: true
        ) { _ in
            if currentIndex < images.count {
                imageName = images[currentIndex]
                currentIndex += 1
            } else {
                timer?.invalidate() // Stop the timer when animation is done
            }
        }
    }
}

public struct NumberTransitionView: View {
    @Binding private var digitIndex0: Int
    @Binding private var digitIndex1: Int
    @Binding private var digitIndex2: Int
    private let onDigitTapGesture: () -> Void
    public init(
        digitIndex0: Binding<Int>,
        digitIndex1: Binding<Int>,
        digitIndex2: Binding<Int>,
        onDigitTapGesture: @escaping () -> Void
    ) {
        self.onDigitTapGesture = onDigitTapGesture
        self._digitIndex0 = digitIndex0
        self._digitIndex1 = digitIndex1
        self._digitIndex2 = digitIndex2
    }

    public var body: some View {
        HStack(spacing: 0) {
            DigitTransitionView(digit: $digitIndex0, onDigitTapGesture: onDigitTapGesture)
            DigitTransitionView(digit: $digitIndex1, onDigitTapGesture: onDigitTapGesture)
            DigitTransitionView(digit: $digitIndex2, onDigitTapGesture: onDigitTapGesture)
        }
    }
}

public extension CounterView {
    static let maxWidth = screenWidth * 0.2
    static let maxHeight = screenWidth * 0.2
    static let minWidth = screenWidth * 0.15
    static let minHeight = screenWidth * 0.15
}

public struct CounterView: View {
    @State private var number: Int
    @State private var digitIndex0: Int
    @State private var digitIndex1: Int
    @State private var digitIndex2: Int
    private let onChange: (Int) -> Void
    private let onDigitTapGesture: () -> Void
    private let onInfoTapGesture: (Model.TrackedEntity) -> Void
    private let info: String
    private let name: String
    private let id: String
    private let minimalDisplay: Bool
    private let model: Model.TrackedEntity
    public init(
        model: Model.TrackedEntity,
        minimalDisplay: Bool,
        onChange: @escaping (Int) -> Void,
        onDigitTapGesture: @escaping () -> Void,
        onInfoTapGesture: @escaping (Model.TrackedEntity) -> Void
    ) {
        let counter = model.cascadeEvents?.count ?? 0
        self.model = model
        self.minimalDisplay = minimalDisplay
        self.id = model.id
        self.name = model.name
        self.info = model.info
        self._number = State(initialValue: counter)
        self.digitIndex0 = Self.digitsArray(number: counter)[0]
        self.digitIndex1 = Self.digitsArray(number: counter)[1]
        self.digitIndex2 = Self.digitsArray(number: counter)[2]
        self.onChange = onChange
        self.onDigitTapGesture = onDigitTapGesture
        self.onInfoTapGesture = onInfoTapGesture
    }

    public var body: some View {
        VStack(spacing: 0) {
            SwiftUIUtils.RenderedView(
                "\(Self.self).\(#function)",
                id: id,
                visible: DevTools.onSimulator && !DevTools.onTargetProduction
            )
            NumberTransitionView(
                digitIndex0: $digitIndex0,
                digitIndex1: $digitIndex1,
                digitIndex2: $digitIndex2,
                onDigitTapGesture: onDigitTapGesture
            )
            .onChange(of: number) { _ in
                digitIndex0 = Self.digitsArray(number: number)[0]
                digitIndex1 = Self.digitsArray(number: number)[1]
                digitIndex2 = Self.digitsArray(number: number)[2]
                onChange(number)
            }
            if !minimalDisplay, !name.isEmpty {
                Text(name)
                    .fontSemantic(.title2)
                    .textColor(ColorSemantic.labelPrimary.color)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        onInfoTapGesture(model)
                    }
            }
            if !minimalDisplay, !info.isEmpty {
                Text("(" + info + ")")
                    .fontSemantic(.footnote)
                    .textColor(ColorSemantic.labelSecondary.color)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        onInfoTapGesture(model)
                    }
            }
        }
    }

    static func digitsArray(number: Int) -> [Int] {
        String(format: "%03d", number).compactMap(\.wholeNumberValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CounterView(
                model: .random(cascadeEvents: [.random]),
                minimalDisplay: false,
                onChange: { number in
                    Common_Logs.debug(number)
                },
                onDigitTapGesture: {}, onInfoTapGesture: { _ in }
            )
            CounterView(
                model: .random(cascadeEvents: [.random, .random, .random]),
                minimalDisplay: true,
                onChange: { number in
                    Common_Logs.debug(number)
                },
                onDigitTapGesture: {}, onInfoTapGesture: { _ in }
            )
        }
    }
}
