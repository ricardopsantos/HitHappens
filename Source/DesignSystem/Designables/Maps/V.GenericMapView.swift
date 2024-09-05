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
    @Binding var items: [ModelItem]
    @State var shouldDisplayUserLocation: Bool = true
    @State var shouldDisplayEventsLocation: Bool = false
    @StateObject var locationViewModel: Common.SharedLocationManagerViewModel = .shared
    private let onRegionChanged: (MKCoordinateRegion) -> Void
    public init(items: Binding<[ModelItem]>, onRegionChanged: @escaping (MKCoordinateRegion) -> Void) {
        self.onRegionChanged = onRegionChanged
        self._items = items
    }
    
    public var body: some View {
        content
            .onAppear {
                locationViewModel.start(sender: "\(Self.self)")
                shouldDisplayUserLocation = locationViewModel.locationIsAuthorized
                shouldDisplayEventsLocation = true
                Common_Utils.delay(1) {
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
                Common.ExecutionControlManager.debounce(0.3,
                                                        operationId: "\(Self.self).region.changed") {
                    onRegionChanged(new)
                }
            }
    }
    
    public var content: some View {
        ZStack {
            mapView
            actionBottonView
        }.cornerRadius2(SizeNames.cornerRadius)
    }
    
    @ViewBuilder
    public var mapView: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all, 
            showsUserLocation: true,
            annotationItems: items) { item in
            MapAnnotation(coordinate: item.coordinate) {
                annotationView(with: item, isUser: false)
            }
        }
        .gesture(TapGesture(count: 1)
            .onEnded { _ in
                userInteractedWithMap()
            })
        .simultaneousGesture(DragGesture().onChanged { value in
            userInteractedWithMap()
        })
        .simultaneousGesture(MagnificationGesture().onChanged { value in
            userInteractedWithMap()
        })
    }
    
    @ViewBuilder
    public var actionBottonView: some View {
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
                if locationViewModel.locationIsAuthorized {
                    userRegion
                }
            })
        }
    }
}

//
// MARK: - Auxiliar Views
//
public extension GenericMapView {
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
public extension GenericMapView {

    func updateRegionToFitCoordinates() {
        guard shouldDisplayUserLocation || shouldDisplayEventsLocation else {
            return
        }
        var meanFullCoordinates: [CLLocationCoordinate2D] = []
        let userLocation = locationViewModel.coordinates
        
        if shouldDisplayUserLocation, let userLocation = userLocation {
            meanFullCoordinates.append(.init(latitude: userLocation.latitude,
                                             longitude: userLocation.longitude))
        }
        if shouldDisplayEventsLocation {
            let validItems = items.map(\.coordinate)
                .filter { $0.latitude != 0 && $0.longitude != 0 }
            meanFullCoordinates.append(contentsOf: validItems)
        }
        
        if !meanFullCoordinates.isEmpty {
            region = meanFullCoordinates.regionToFitCoordinates()
        } else if let userLocation = userLocation {
            // No coordinates! Center on user...
            region = [.init(latitude: userLocation.latitude,
                            longitude: userLocation.longitude)].regionToFitCoordinates()
        }
    }
}

//
// MARK: - Private
//
private extension GenericMapView {
    func userInteractedWithMap() {
        if shouldDisplayUserLocation {
            shouldDisplayUserLocation = false
        }
        if shouldDisplayEventsLocation {
            shouldDisplayEventsLocation = false
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
        ]), onRegionChanged: { _ in })
        .frame(maxHeight: screenHeight / 3)
        Spacer()
    }
    .padding()
}
#endif
