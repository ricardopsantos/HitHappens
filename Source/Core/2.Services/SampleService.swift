import Foundation
//
import Domain
import Common
import DevTools

public class SampleService {
    //    private let cacheManager = Common.CacheManagerForCodableUserDefaultsRepository.shared
    private let cacheManager = Common.CacheManagerForCodableCoreDataRepository.shared
    public let webAPI: NetworkManagerProtocol
    public init(webAPI: NetworkManagerProtocol) {
        self.webAPI = webAPI
    }
}

extension SampleService: SampleServiceProtocol {}
