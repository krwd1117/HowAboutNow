import Foundation
import Alamofire

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: URLRequestConvertible) async throws -> T
}

public final class NetworkService: NetworkServiceProtocol {
    private let session: Session
    
    public init(session: Session = .default) {
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: URLRequestConvertible) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            session.request(endpoint)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
