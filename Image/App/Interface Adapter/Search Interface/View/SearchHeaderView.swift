//
//  SearchHeaderView.swift
//  Image
//
//  Created by 서상의 on 2021/11/14.
//

import UIKit

class SearchHeaderView: UIView {
    var title: String {
        get { return self.headerLabel.text ?? "" }
        set { self.headerLabel.text = newValue }
    }
    
    var onTextChanged: ((String) -> Void)? = nil
    
    private let containerStackView: UIStackView = .init()
    private let commentLabel: UILabel = .init()
    
    private let headerStackView: UIStackView = .init()
    private let headerLabel: UILabel = .init()
    private let textFieldContainer: UIView = .init()
    private let textField: UITextField = .init()
    
    private let testView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: effect)
        
        return view
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.setup()
        
        self.textField.addTarget(self, action: #selector(self.textFieldDidChanged), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension SearchHeaderView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Selector
private extension SearchHeaderView {
    @objc func textFieldDidChanged() {
        self.onTextChanged?(self.textField.text ?? "")
    }
}

private extension SearchHeaderView {
    func setup() {
        self.setupStackView(self.containerStackView)
        self.setupCommentLabel(self.commentLabel)
        self.setupHeaderStackView(self.headerStackView)
        self.setupLabel(self.headerLabel)
        self.setupTextFieldContaienr(self.textFieldContainer)
        self.setupTextField(self.textField)
    }
    
    func setupHeaderStackView(_ stackView: UIStackView) {
        self.containerStackView.addArrangedSubview(self.headerStackView)
        stackView.distribution = .equalCentering
    }
    
    func setupStackView(_ stackView: UIStackView) {
        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.axis = .vertical
        stackView.spacing = 20
    }
    
    func setupCommentLabel(_ label: UILabel) {
        self.containerStackView.addArrangedSubview(label)
        
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemGray
        label.text = "다음 이미지 검색 결과를 보여줍니다"
        
        self.containerStackView.setCustomSpacing(0, after: label)
    }
    
    func setupLabel(_ label: UILabel) {
        self.headerStackView.addArrangedSubview(label)
        
        label.font = .systemFont(ofSize: 30, weight: .heavy)
    }
    
    func setupTextFieldContaienr(_ view: UIView) {
        self.containerStackView.addArrangedSubview(view)
        
        view.layer.cornerRadius = 10
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = .init(width: 0, height: 0)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
    }
    
    func setupTextField(_ textField: UITextField) {
        self.textFieldContainer.addSubview(textField)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        textField.leadingAnchor.constraint(equalTo: self.textFieldContainer.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.textFieldContainer.trailingAnchor, constant: -20).isActive = true
        textField.topAnchor.constraint(equalTo: self.textFieldContainer.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.textFieldContainer.bottomAnchor).isActive = true
        
        let imageView = UIImageView(frame: .init(x: 0, y: 11, width: 18, height: 18))
        let image = UIImage(systemName: "magnifyingglass")
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        let leftView = UIView(frame: .init(x: 0, y: 0, width: 25, height: 40))
        leftView.addSubview(imageView)
        
        textField.font = .systemFont(ofSize: 15)
        textField.tintColor = .label
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.placeholder = "검색"
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
    }
}
