//
//  ViewModel.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import Foundation
import Combine

class SearchViewModel {
    // MARK: - Reactive
    @Published private(set) var thumbnails: [URL?] = []
    private(set) var onEmptySearchResult: PassthroughSubject<Bool, Never> = .init()
    private(set) var onSuccessSearch: PassthroughSubject<Void, Never> = .init()
    private(set) var openImageViewer: PassthroughSubject<ViewerModel, Never> = .init()
    
    private var imageSearchUseCase: UseCaseImageSearch
    private var imageSearchResult: [UseCaseImageModel] = []
    
    init(imageSearchUseCase: UseCaseImageSearch) {
        self.imageSearchUseCase = imageSearchUseCase
    }
    
    /// 파라미터 `index`가 주어졌을 때, 이에 해당하는 인덱스의 썸네일 URL을 반환
    /// - Parameter index: 반환할 썸네일의 인덱스
    /// - Returns: 썸네일 URL을 `Optional<URL>`을, 올바르지 않은 인덱스의 경우 `nil` 반환.
    func thumbnail(for index: Int) -> URL? {
        guard index < self.thumbnails.count else { return nil }
        
        return self.thumbnails[index]
    }
    
    /// 검색 결과의 개수를 반환
    /// - Returns: 사용자가 입력한 쿼리에 대한 검색 결과 개수
    func numberOfSearchResults() -> Int {
        return self.thumbnails.count
    }
    
    /// 파라미터로 전달된 `String`으로 새로운 검색을 시도
    /// - Parameter query: 검색 쿼리
    func userDidUpdatedQuery(_ query: String) {
        Task {
            do {
                let result = try await self.imageSearchUseCase.initialize(query: query, size: .size)
                self.onSuccessSearch.send()
                self.imageSearchResult = result
                self.thumbnails = resuXlt.map({ $0.thumbnailUrl })
                
                self.onEmptySearchResult.send(self.thumbnails.isEmpty && query.isEmpty == false)
            } catch {
                
            }
        }
    }
    
    /// 다음 페이지 요청
    func userDidUpdatedPage() {
        Task {
            do {
                let result = try await self.imageSearchUseCase.update()
                self.imageSearchResult.append(contentsOf: result)
                self.thumbnails.append(contentsOf: result.map({ $0.thumbnailUrl }))
            } catch UseCaseImageSearch.InternalError.isReachedEndPage {
                
            }
        }
    }
    
    func userDidTouchedThumbnail(index: Int) {
        let model = self.imageSearchResult[index].convert()
        self.openImageViewer.send(model)
    }
}

private extension UseCaseImageModel {
    var formattedDateString: String? {
        guard let dateString = self.datetime else {
            return nil
        }
        
        let formatter: DateFormatter = .dateFormatter

        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "yyyy년 MM월 dd일 HH시"
            let string = formatter.string(from: date)
            
            return string
        }
        
        return nil
    }
    
    func convert() -> ViewerModel {
        return .init(url: self.imageUrl, source: self.displaySitename, date: self.formattedDateString)
    }
}

private extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .calendar
        formatter.locale = .locale
        formatter.dateFormat = .dateFormat
        formatter.timeZone = .timeZone
        
        return formatter
    } ()
}

private extension Calendar {
    static let calendar: Self = .init(identifier: .iso8601)
}

private extension Locale {
    static let locale: Self = .init(identifier: "en_US_POSIX")
}

private extension String {
    static let dateFormat: Self = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
}

private extension TimeZone {
    static let timeZone: TimeZone? = .init(secondsFromGMT: .zero)
}

private extension Int {
    static let size = 30
}
