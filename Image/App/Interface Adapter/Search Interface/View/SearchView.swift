//
//  SearchView.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import UIKit
import Combine

class SearchView: UIView {
    // MARK: - Internal API
    var numberOfItemsPerPage: Int {
        let collectionViewBounds = self.collectionView.bounds
        let collectionViewItemWidth = collectionViewBounds.width / self.numberOfColumns
        let numberOfRows = (collectionViewBounds.height / collectionViewItemWidth).rounded(.up)
        let numberOfItems = numberOfRows * self.numberOfColumns
        return Int(numberOfItems)
    }
    
    // MARK: - ViewModel
    private let viewModel: SearchViewModel
    
    // MARK: - UI Components
    private let headerView = SearchHeaderView()
    private let collectionView = ImageCollectionView()
    
    private let messageLabel: UILabel = .init()
    
    // MARK: - Reactive
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Other Properties
    private let spacing: CGFloat = 1
    private let numberOfColumns: CGFloat = 3
    
    // MARK: Initializer
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        self.setup()
        self.observe(thumbnails: self.viewModel.$thumbnails.eraseToAnyPublisher())
        
        self.headerView.onTextChanged = { [weak self] text in
            self?.viewModel.userDidUpdatedQuery(text)
        }
        
        self.viewModel.onSuccessSearch
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.collectionView.setContentOffset(.zero, animated: false)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            .store(in: &self.subscriptions)
        
        self.viewModel.onEmptySearchResult
            .receive(on: DispatchQueue.main)
            .sink { isEmpty in
                self.messageLabel.isHidden = isEmpty == false
                self.endEditing(isEmpty == false)
            }
            .store(in: &self.subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

// MARK: - UICollectionViewDelegate
extension SearchView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.userDidTouchedThumbnail(index: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.spacing
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isReachedAtBottom {
            self.viewModel.userDidUpdatedPage()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SearchView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfSearchResults()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? SearchPreviewCell
        let thumbnail = self.viewModel.thumbnail(for: indexPath.row)
        
        cell?.load(url: thumbnail)
        
        return cell ?? .init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .sizeForCollectionViewCell(spacing: 1, column: 3, collectionView: collectionView)
    }
}

// MARK: - Reactive Binding
private extension SearchView {
    func observe(thumbnails: AnyPublisher<[URL?], Never>) {
        thumbnails
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &self.subscriptions)
    }
}

// MARK: - UI Setup
private extension SearchView {
    func setup() {
        self.setupSelfView()
        self.setupHeaderView(self.headerView)
        self.setupImageCollectionView(self.collectionView)
        self.setupMessageLabel(self.messageLabel)
        self.setupTapGestureRecognizer()
        
        self.headerView.title = "Image Search"
    }
    
    func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.viewDidTapped))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupSelfView() {
        self.backgroundColor = .systemBackground
    }
    
    func setupHeaderView(_ view: UIView) {
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        view.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        view.backgroundColor = .systemBackground
    }
    
    func setupImageCollectionView(_ collectionView: UICollectionView) {
        self.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        collectionView.layer.cornerRadius = 10
        collectionView.clipsToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(SearchPreviewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func setupMessageLabel(_ label: UILabel) {
        self.collectionView.backgroundView = label
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemGray
        label.text = "표시할 결과가 없습니다"
        label.textAlignment = .center
        label.isHidden = true
    }
}

// MARK: - Selector
private extension SearchView {
    @objc func viewDidTapped(_ recognizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
}

class ImageCollectionView: UICollectionView {
    init() {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

private extension UIScrollView {
    var isReachedAtBottom: Bool {
        return (self.contentOffset.y >= (self.contentSize.height - self.frame.size.height))
    }
}

private extension CGSize {
    static func sizeForCollectionViewCell(spacing: CGFloat, column: CGFloat, collectionView: UICollectionView) -> Self {
        let totalSpacing = spacing * (column - 1)
        let totalWidth = collectionView.bounds.width - totalSpacing
        let widthPerCell = totalWidth / column
        
        return .init(width: widthPerCell, height: widthPerCell)
    }
}
