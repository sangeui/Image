//
//  ViewerViewController.swift
//  Image
//
//  Created by 서상의 on 2021/11/15.
//

import UIKit

class ViewerViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        get {
            self.statusBarHidden
        }
    }
    
    private var statusBarHidden: Bool = false
    private let viewerView = ViewerView()
    private var imageURL: URL?
    private let model: ViewerModel
    
    init(model: ViewerModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func loadView() {
        self.view = self.viewerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = .black
        self.viewerView.primaryLabelText = self.model.source
        self.viewerView.secondaryLabelText = self.model.date
        self.viewerView.onViewTapped = { [weak self] in
            self?.statusBarHidden.toggle()
            self?.setNeedsStatusBarAppearanceUpdate()
        }
        
        self.viewerView.onButtonTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewerView.imageWidth = self.view.bounds.width
        self.load(image: self.model.url)
    }
}

private extension ViewerViewController {
    func load(image url: URL?) {
        guard let url = url else { return }
        self.viewerView.load(url: url)
    }
}
