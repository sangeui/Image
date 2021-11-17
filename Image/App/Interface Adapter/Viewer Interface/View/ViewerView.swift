//
//  ViewerView.swift
//  Image
//
//  Created by 서상의 on 2021/11/17.
//

import UIKit

class ViewerView: UIView {
    var onViewTapped: (() -> Void)? = nil
    var onButtonTapped: (() -> Void)? = nil
    var imageWidth: CGFloat = .zero
    
    var primaryLabelText: String? {
        get { self.primaryLabel.text }
        set { self.primaryLabel.text = newValue }
    }
    var secondaryLabelText: String? {
        get { self.secondaryLabel.text }
        set { self.secondaryLabel.text = newValue }
    }
    
    // MARK: - UI — Header
    private let headerView: UIView = .init()
    
    // MARK: - UI — Viewer
    private let scrollView: UIScrollView = .init()
    private let imageView: UIImageView = .init()
    
    // MARK: - UI — Footer
    private let footerView: UIView = .init()
    private let stackView: UIStackView = .init()
    private let primaryLabel: UILabel = .init()
    private let secondaryLabel: UILabel = .init()
    
    private var scrollViewWidthAnchor: NSLayoutConstraint? = nil
    
    init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func load(url: URL) {
        guard self.imageWidth > 0 else { return }
        guard let data = try? Data(contentsOf: url) else { return }
        guard let image = UIImage(data: data) else { return }
        self.imageView.image = self.imageWithImage(sourceImage: image, scaledToWidth: self.imageWidth)
    }
}

// MARK: - Selector
private extension ViewerView {
    @objc func viewDidTapped() {
        self.headerView.isHidden.toggle()
        self.footerView.isHidden = self.headerView.isHidden
        self.onViewTapped?()
    }
    
    @objc func buttonDidTapped() {
        self.onButtonTapped?()
    }
}

private extension ViewerView {
    func createVisualEffectView(into view: UIView) {
        let effectView: UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .extraLight))
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        effectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

private extension ViewerView {
    func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.viewDidTapped))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
        self.setupScrollView(self.scrollView)
        self.setupImageView(self.imageView)
        
        self.setupHeaderView(self.headerView)
        self.setupFooterView(self.footerView)
        self.setupStackView(self.stackView)
        self.setupPrimaryLabel(self.primaryLabel)
        self.setupSecondaryLabel(self.secondaryLabel)
    }
    
    func setupHeaderView(_ view: UIView) {
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        
        self.createVisualEffectView(into: view)
        
        let button = UIButton()
        let image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        button.setImage(image, for: .normal)
        button.configuration = .bordered()
        button.tintColor = .label
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        button.addTarget(self, action: #selector(self.buttonDidTapped), for: .touchUpInside)
    }
    
    func setupFooterView(_ view: UIView) {
        self.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.createVisualEffectView(into: view)
    }
    
    func setupScrollView(_ scrollView: UIScrollView) {
        self.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor).isActive = true
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    func setupImageView(_ imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFill
        
        self.scrollView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true
        let height = imageView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        height.priority = .defaultLow
        height.isActive = true
    }
    
    func setupStackView(_ stackView: UIStackView) {
        self.footerView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.footerView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.footerView.trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: self.footerView.topAnchor, constant: 10).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.footerView.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        
        stackView.axis = .vertical
    }
    
    func setupPrimaryLabel(_ label: UILabel) {
        self.stackView.addArrangedSubview(label)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
    }
    
    func setupSecondaryLabel(_ label: UILabel) {
        self.stackView.addArrangedSubview(label)
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textAlignment = .center
    }
}
