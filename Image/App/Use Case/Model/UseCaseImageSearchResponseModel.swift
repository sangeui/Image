//
//  UseCaseImageSearchResponseModel.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation

struct UseCaseImageSearchResponseModel: Decodable {
    var metadata: UseCaseImageSearchMeta
    var documents: [UseCaseImageModel]
}

extension UseCaseImageSearchResponseModel {
    enum CodingKeys: String, CodingKey {
        case metadata = "meta", documents
    }
}
