//
//  ViewController.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    // MARK: - ViewModel
    private let viewModel: SearchViewModel
    
    // MARK: - Reactive
    private var subscriptions: Set<AnyCancellable> = .init()
    
    // MARK: - Life Cycle
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.openImageViewer
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] model in
                
                let viewController = ViewerViewController(model: model)
                viewController.modalTransitionStyle = .crossDissolve
                viewController.modalPresentationStyle = .overFullScreen
                self?.present(viewController, animated: true, completion: nil)
            }
            .store(in: &self.subscriptions)

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        self.view = SearchView(viewModel: self.viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
