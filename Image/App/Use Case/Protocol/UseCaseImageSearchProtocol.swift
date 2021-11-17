//
//  ImageSearchProtocol.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation

protocol UseCaseImageSearchProtocol {
    func search(query: String, page: Int, size: Int) async -> UseCaseImageSearchResponseModel
}
