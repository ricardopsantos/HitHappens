//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine
import MapKit
import CoreLocation
//
import Common
import Domain

// https://medium.com/@davidhu-sg/mapkit-in-swiftui-79bcea6b76fc

public extension GenericMapView {
    struct ModelItem: Identifiable, Equatable {
        public static func == (lhs: GenericMapView.ModelItem, rhs: GenericMapView.ModelItem) -> Bool {
            lhs.id == rhs.id &&
                lhs.name == rhs.name &&
                lhs.coordinate.latitude == rhs.coordinate.latitude &&
                lhs.coordinate.longitude == rhs.coordinate.longitude &&
                lhs.image.systemName == rhs.image.systemName &&
                lhs.image.backColor == rhs.image.backColor &&
                lhs.image.imageColor == rhs.image.imageColor
        }

        public let id: String
        public let name: String
        public let coordinate: CLLocationCoordinate2D
        public let onTap: () -> Void
        public let image: (
            systemName: String,
            backColor: Color,
            imageColor: Color
        )

        public init(
            id: String,
            name: String,
            coordinate: CLLocationCoordinate2D,
            onTap: @escaping () -> Void,
            image: (systemName: String, backColor: Color, imageColor: Color)
        ) {
            self.id = id
            self.name = name
            self.coordinate = coordinate
            self.onTap = onTap
            self.image = image
        }
    }
}

public struct GenericMapView: View {
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
    )
    @State private var cancelBag = CancelBag()
    @State var shouldDisplayUserLocation: Bool = true
    @State var shouldDisplayEventsLocation: Bool = false

    @Binding var displayGrid: Bool
    @Binding var items: [ModelItem]
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    private let onRegionChanged: (MKCoordinateRegion) -> Void
    public init(
        items: Binding<[ModelItem]>,

        displayGrid: Binding<Bool>,
        onRegionChanged: @escaping (MKCoordinateRegion) -> Void
    ) {
        self.onRegionChanged = onRegionChanged
        self._items = items
        self._displayGrid = displayGrid
    }

    public var body: some View {
        content
            .onAppear {
                locationViewModel.start(sender: "\(Self.self)")
                shouldDisplayUserLocation = locationViewModel.locationIsAuthorized
                shouldDisplayEventsLocation = true
                Common_Utils.delay {
                    // Delay so that view model gets user location
                    updateRegionToFitCoordinates()
                }
            }.onDisappear {
                locationViewModel.stop(sender: "\(Self.self)")
            }
            .onChange(of: items) { _ in
                if shouldDisplayEventsLocation, items.isEmpty {
                    // No items, so no need on this being on
                    shouldDisplayEventsLocation = false
                }
            }
            .onChange(of: region) { new in
                // Ignore fast changes (swiping, etc)
                let operationId = "\(Self.self).region.changed"
                Common.ExecutionControlManager.dropFirst(n: 2, operationId: operationId, block: {
                    Common.ExecutionControlManager.debounce(
                        0.3,
                        operationId: operationId
                    ) {
                        onRegionChanged(new)
                    }
                })
            }
    }

    public var content: some View {
        ZStack {
            mapView

            actionBottonView
        }.cornerRadius2(SizeNames.cornerRadius)
    }
}

//
// MARK: - Auxiliar Views
//
fileprivate extension GenericMapView {
    @ViewBuilder
    var mapView: some View {
        Group {
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: items
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    annotationView(with: item, isUser: false)
                }
            }
            .gesture(
                TapGesture(count: 1)
                    .onEnded { _ in
                        userInteractedWithMap()
                    }
            )
            .simultaneousGesture(DragGesture().onChanged { _ in
                userInteractedWithMap()
            })
            .simultaneousGesture(MagnificationGesture().onChanged { _ in
                userInteractedWithMap()
            })
        }.doIf(displayGrid, transform: {
            $0.overlay(
                GeometryReader { geometry in
                    gridOverlay(for: geometry.size)
                }
            )
        })
    }

    @ViewBuilder
    var actionBottonView: some View {
        let allEventsRegion = Button(action: {
            shouldDisplayEventsLocation.toggle()
            withAnimation {
                updateRegionToFitCoordinates()
            }
        }) {
            Image(systemName: "list.bullet")
                .frame(SizeNames.defaultMargin)
                .padding(SizeNames.size_3.cgFloat)
                .doIf(shouldDisplayEventsLocation, transform: {
                    $0.background(ColorSemantic.primary.color.opacity(1))
                })
                .doIf(!shouldDisplayEventsLocation, transform: {
                    $0.background(ColorSemantic.backgroundTertiary.color.opacity(0.66))
                })
                .clipShape(Circle())
                .foregroundColor(.white)
                .shadow(radius: SizeNames.shadowRadiusRegular)
        }
        .userInteractionEnabled(!items.isEmpty)
        .paddingBottom(SizeNames.defaultMargin)
        .paddingRight(SizeNames.defaultMargin)
        let userRegion = Button(action: {
            shouldDisplayUserLocation.toggle()
            withAnimation {
                updateRegionToFitCoordinates()
            }
        }) {
            Image(systemName: "location.fill")
                .frame(SizeNames.defaultMargin)
                .padding(SizeNames.size_3.cgFloat)
                .doIf(shouldDisplayUserLocation, transform: {
                    $0.background(ColorSemantic.primary.color.opacity(1))
                })
                .doIf(!shouldDisplayUserLocation, transform: {
                    $0.background(ColorSemantic.backgroundTertiary.color.opacity(0.66))
                })
                .clipShape(Circle())
                .foregroundColor(.white)
                .shadow(radius: SizeNames.shadowRadiusRegular)
        }
        .userInteractionEnabled(locationViewModel.locationIsAuthorized)
        .paddingRight(SizeNames.defaultMargin)
        .paddingBottom(SizeNames.defaultMargin)
        HStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0, content: {
                Spacer()
                allEventsRegion
                    .doIf(items.isEmpty, transform: {
                        $0.hidden()
                    })

                if locationViewModel.locationIsAuthorized {
                    userRegion
                }
            })
        }
    }

    @ViewBuilder
    func annotationView(with item: ModelItem, isUser: Bool) -> some View {
        let margin: CGFloat = SizeNames.size_3.cgFloat
        let size: CGFloat = SizeNames.defaultMargin + margin
        Button(action: {
            item.onTap()
        }) {
            ListItemView.buildAccessoryImage(
                systemImage: item.image.systemName,
                imageColor: item.image.imageColor,
                margin: margin
            )
            .background(item.image.backColor.opacity(0.75))
        }
        .background(Color.clear)
        .cornerRadius2(size / 2)
        .frame(maxWidth: size, maxHeight: size)
        .id(item.id)
    }
}

//
// MARK: - Auxiliar
//
fileprivate extension GenericMapView {
    private func gridOverlay(for size: CGSize) -> some View {
        let gridSpacingX: CGFloat = size.width / 10
        let gridSpacingY: CGFloat = size.width / 10
        let color: Color = ColorSemantic.primary.color
        let opacity: CGFloat = 0.5
        let lineWidth: CGFloat = 0.75
        return ZStack {
            ForEach(0..<Int(size.width / gridSpacingX), id: \.self) { i in
                Path { path in
                    let x = CGFloat(i) * gridSpacingX
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                }
                .stroke(color.opacity(opacity), lineWidth: lineWidth)
            }
            ForEach(0..<Int(size.height / gridSpacingY), id: \.self) { i in
                Path { path in
                    let y = CGFloat(i) * gridSpacingY
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(color.opacity(opacity), lineWidth: lineWidth)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Circle()
                        .stroke(.white, lineWidth: 2)
                        .background(Circle().foregroundColor(color.opacity(0.5)))
                        .frame(min(gridSpacingY, gridSpacingX) * 0.5)
                    Spacer()
                }
                Spacer()
            }
        }
    }

    func userInteractedWithMap() {
        if shouldDisplayUserLocation {
            shouldDisplayUserLocation = false
        }
        if shouldDisplayEventsLocation {
            shouldDisplayEventsLocation = false
        }
    }

    func updateRegionToFitCoordinates() {
        guard shouldDisplayUserLocation || shouldDisplayEventsLocation else {
            return
        }
        var meanFullCoordinates: [CLLocationCoordinate2D] = []
        let userLocation = locationViewModel.coordinates

        if shouldDisplayUserLocation, let userLocation = userLocation {
            meanFullCoordinates.append(.init(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude
            ))
        }
        if shouldDisplayEventsLocation {
            let validItems = items.map(\.coordinate)
                .filter { $0.latitude != 0 && $0.longitude != 0 }
            meanFullCoordinates.append(contentsOf: validItems)
        }

        if !meanFullCoordinates.isEmpty {
            if meanFullCoordinates.count == 1, let first = meanFullCoordinates.first {
                region.center = .init(
                    latitude: first.latitude,
                    longitude: first.longitude
                )
            } else {
                region = meanFullCoordinates.regionToFitCoordinates()
            }
        } else if let userLocation = userLocation {
            // No coordinates! Center on user...
            region = [.init(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude
            )].regionToFitCoordinates()
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
        GenericMapView(items: .constant([
            .init(
                id: "1",
                name: "1",
                coordinate: .random,
                onTap: {},
                image: ("heart", .random, .random)
            ),
            .init(
                id: "2",
                name: "2",
                coordinate: .random,
                onTap: {},
                image: ("heart", .random, .random)
            ),
            .init(
                id: "3",
                name: "3",
                coordinate: .random,
                onTap: {},
                image: ("heart", .random, .random)
            )
        ]), displayGrid: .constant(true), onRegionChanged: { _ in })
            .frame(maxHeight: screenHeight / 3)
        Spacer()
    }
    .padding()
}
#endif
