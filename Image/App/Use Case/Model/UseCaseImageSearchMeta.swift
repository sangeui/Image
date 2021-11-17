//
//  UseCaseImageSearchMeta.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation

struct UseCaseImageSearchMeta: Decodable {
    var totalCount: Int
    var pageableCount: Int
    var isEnd: Bool
}
