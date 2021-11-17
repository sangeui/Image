//
//  ImageSearchResultManager.swift
//  Image
//
//  Created by 서상의 on 2021/11/15.
//

import Foundation

class ImageSearchResultManager {
    private(set) var pagesize: Int = 0
    private(set) var query: String = ""
    
    private var metadata: UseCaseImageSearchMeta? = nil {
        didSet { self.metadataDidAllocated() }
    }
    
    private var page: Int = 1
    
    func update(metadata: UseCaseImageSearchMeta) {
        self.metadata = metadata
    }
    
    func save(query: String, size: Int) {
        self.query = query
        self.pagesize = size
        self.page = 1
    }
    
    func isAbleToRequestNextPage() throws -> Bool {
        guard let metadata = metadata else {
            throw InternalError.metadataNotInitialized
        }

        return metadata.isEnd == false
    }
    
    func nextPage() -> Int {
        return self.page + 1
    }
    
    func updatePage() {
        self.page += 1
    }
}

private extension ImageSearchResultManager {
    func metadataDidAllocated() {
        guard self.metadata != nil else { return }
    }
}

extension ImageSearchResultManager {
    enum InternalError: Error {
        case metadataNotInitialized
    }
}
