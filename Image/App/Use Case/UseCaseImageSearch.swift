//
//  UseCaseImageSearch.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation

enum TestError: Error {
    case reachedEndPage
}

class UseCaseImageSearch {
    private let provider: UseCaseImageSearchProtocol
    private var metadata: UseCaseImageSearchMeta? = nil
    private var paging = Paging()
    private var query: String = ""
    private var size: Int = 0
    private var page: Int = 0
    
    // MARK: - Image Search Result Manager
    private let manager: ImageSearchResultManager = .init()
    
    private var delayTask: Task<Void, Never>? = nil
    private var initializeTask: Task<[UseCaseImageModel], Error>? = nil
    private var updateTask: Task<[UseCaseImageModel], Never>? = nil
    
    init(provider: UseCaseImageSearchProtocol) {
        self.provider = provider
    }
    
    func initialize(query: String, size: Int) async throws -> [UseCaseImageModel] {
        self.reset()
        self.initializeTask = Task {
            await Task.sleep(1000000000)
            if Task.isCancelled {
                throw InternalError.isCanceled
            } else {
                let response = await self.provider.search(query: query, page: 1, size: size)
                self.manager.update(metadata: response.metadata)
                self.manager.save(query: query, size: size)
                
                return response.documents
            }
        }
        
        do {
            let value = try await self.initializeTask?.value
            
            return value ?? []
        } catch {
            throw InternalError.isCanceled
        }
    }
    
    func update() async throws -> [UseCaseImageModel] {
        guard try self.manager.isAbleToRequestNextPage() else {
            throw InternalError.isReachedEndPage
        }
        
        let query = self.manager.query
        let size = self.manager.pagesize
        let nextPage = self.manager.nextPage()
        
        self.updateTask = Task {
            let response = await self.provider.search(query: query, page: nextPage, size: size)
            self.manager.updatePage()
            self.manager.update(metadata: response.metadata)
            return response.documents
        }
        
        let documents = await self.updateTask?.value ?? []
        
        return documents
    }
}

private extension UseCaseImageSearch {
    func reset() {
        self.initializeTask?.cancel()
        self.updateTask?.cancel()
    }
}

extension UseCaseImageSearch {
    enum InternalError: Error {
        case isReachedEndPage
        case isCanceled
    }
}

struct Paging {
    var query: String = ""
    var size: Int = 0
    var page: Int = 0
    var totalCount: Int = 0
    
    func next() -> Int {
        return page + 1
    }
}

extension Paging: CustomStringConvertible {
    var description: String {
        return """
전체 페이지 \(totalCount) 중, \(page)번째 페이지를 불러왔습니다.
각 페이지의 사이즈는 \(size)입니다.
"""
    }
}
