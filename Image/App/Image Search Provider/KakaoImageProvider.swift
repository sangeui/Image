//
//  KakaoImageProvider.swift
//  Image
//
//  Created by 서상의 on 2021/11/16.
//

import Foundation

class KakaoImageProvider: UseCaseImageSearchProtocol {
    private let host = "dapi.kakao.com"
    private let path = "/v2/search/image"
    
    private let decoder: JSONDecoder = .init()
    private var request: URLSessionDataTask? = nil
    private let session: URLSession = .shared
    
    init() {
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func search(query: String, page: Int, size: Int) async -> UseCaseImageSearchResponseModel {
        self.request?.cancel()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = self.host
        urlComponents.path = self.path
        urlComponents.queryItems = [
            .init(name: "query", value: query),
            .init(name: "page", value: "\(page)"),
            .init(name: "size", value: "\(size)")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.addValue("KakaoAK \(String.APIKEY)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await self.session.data(for: request)
            return try self.decoder.decode(UseCaseImageSearchResponseModel.self, from: data)
        } catch {
            print(error)
        }
        
        return .init(metadata: .init(totalCount: 0, pageableCount: 0, isEnd: true), documents: [])
    }
}

private extension String {
    static let APIKEY = <#Kakao API Key#>
}
