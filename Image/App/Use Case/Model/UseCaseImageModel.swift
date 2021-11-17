//
//  UseCaseImageModel.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation

struct UseCaseImageModel: Decodable {
    var collection: String?
    var thumbnailUrl: URL?
    var imageUrl: URL?
    var displaySitename: String?
    var documentURL: URL?
    var datetime: String?
}
