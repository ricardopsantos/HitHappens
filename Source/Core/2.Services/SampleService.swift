import Foundation
//
import Domain
import Common
import DevTools

public class SampleService {
    private init() {}
    public static let shared = SampleService()

    //    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
    private let webAPI: NetworkManager = .shared
}

extension SampleService: SampleServiceProtocol {}
