//
//  OnBoardingViewModel.swift
//  HitHappens
//
//  Created by Ricardo Santos on 20/05/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

public struct OnboardingModel: Equatable, Hashable, Identifiable, Sendable {
    public var id: String { order.description }
    let text: String
    let image: UIImage
    let order: Int
    public init(text: String = "", image: UIImage = UIImage(), order: Int = 0) {
        self.text = text
        self.image = image
        self.order = order
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension OnboardingViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case fetchConfig
    }

    struct Dependencies {
        let model: OnboardingModel
        let onCompletion: (String) -> Void
        let appConfigService: AppConfigServiceProtocol
    }
}

class OnboardingViewModel: BaseViewModel {
    // MARK: - Usage/Auxiliar Attributes
    @Published private(set) var onboardingModel: [OnboardingModel] = []
    @Published private(set) var pages: Int = -1
    @Published private(set) var loaded: Bool = false
    private let appConfigService: AppConfigServiceProtocol?
    public init(dependencies: Dependencies) {
        self.appConfigService = dependencies.appConfigService
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            Task { [weak self] in
                guard let self = self else { return }
                loadingModel = .loading(message: "")
                do {
                    if let appConfigService = try await appConfigService?.requestAppConfig(
                        .init(),
                        cachePolicy: .load
                    ) {
                        handle(config: appConfigService)
                    }
                } catch {
                    handle(error: error, sender: "\(action)")
                }
                loadingModel = .notLoading
            }
        case .didDisappear: ()
        case .fetchConfig: () // Do something
        }
    }
}

//
// MARK: - Auxiliar
//

fileprivate extension OnboardingViewModel {
    func handle(config: ModelDto.AppConfigResponse) {
        let intro = config.hitHappens.onboarding.intro
        let pages = config.hitHappens.onboarding.pages.count
        let imagesLightURL = config.hitHappens.onboarding.pages
            .sorted(by: { $0.order > $1.order })
            .map(\.imageLight)
        var onboardingModelAcc: [OnboardingModel] = []
        imagesLightURL.forEach { url in
            CommonNetworking.ImageUtils.imageFrom(
                url: URL(string: url),
                caching: .hotElseCold,
                downsample: .zero
            ) { [weak self] image, url in
                if let image = image,
                   let text = config.hitHappens.onboarding.pages
                   .filter({ $0.imageLight == url })
                   .first?.text,
                   let order = config.hitHappens.onboarding.pages
                   .filter({ $0.imageLight == url })
                   .first?.order {
                    let model = OnboardingModel(text: text, image: image, order: order)
                    onboardingModelAcc.append(model)
                    if onboardingModelAcc.count == pages {
                        self?.onboardingModel = [.init(text: intro,
                                                       image: UIImage(named: "logo")!)
                        ] + onboardingModelAcc.sorted(by: { $0.order > $1.order })
                        self?.loadingModel = .notLoading
                       // self?.loaded = true
                    }
                }
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
    OnboardingViewCoordinator(haveNavigationStack: true, model: .init(), onCompletion: { _ in })
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
