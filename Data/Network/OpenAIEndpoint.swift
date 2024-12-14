import Foundation
import Alamofire

struct OpenAIEndpoint: URLRequestConvertible {
    let url: String
    let method: HTTPMethod
    let parameters: [String: Any]
    let headers: [String: String]

    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.method = method
        request = try JSONEncoding.default.encode(request, with: parameters)
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
