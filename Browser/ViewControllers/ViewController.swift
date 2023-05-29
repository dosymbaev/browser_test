//
//  ViewController.swift
//  Browser
//
//  Created by Dias Dossymbayev on 29.05.2023.
//

import UIKit
import SnapKit
import WebKit

final class ViewController: UIViewController {

    private lazy var textField: UITextField = {
        let view = UITextField()
        view.placeholder = "Введите ссылку"
        view.returnKeyType = .go
        view.delegate = self
        view.keyboardType = .URL
        view.autocorrectionType = .no
        view.clearButtonMode = .whileEditing
        view.clearsOnBeginEditing = true
        return view
    }()
    
    private lazy var historyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("История", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray.withAlphaComponent(0.3)
        return view
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.scrollView.delegate = self
        view.navigationDelegate = self
        return view
    }()
    
    private let loader = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        if let url = URL(string: "https://google.com") {
            webView.load(URLRequest(url: url))
        }
    }

    private func setupViews() {
        addSubviews()
        setupTextField()
        setupHistoryButton()
        setupDivider()
        setupWebView()
        setupLoader()
    }

    private func addSubviews() {
        [webView, textField, historyButton, dividerView, loader].forEach { view.addSubview($0) }
    }
    
    private func setupTextField() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(44)
        }
    }
    
    private func setupHistoryButton() {
        historyButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(textField)
            make.leading.equalTo(textField.snp.trailing).offset(15)
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(90)
        }
    }
    
    private func setupDivider() {
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func setupWebView() {
        webView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupLoader() {
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setLoader(isHidden: Bool) {
        isHidden ? loader.stopAnimating() : loader.startAnimating()
        loader.isHidden = isHidden
    }
    
    private func writeUrl(_ url: String) {
        var historyList = UserDefaults.standard.array(forKey: "historyUrlList")
        historyList?.append(url)
        UserDefaults.standard.set(historyList, forKey: "historyUrlList")
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textField.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let urlString = textField.text?.addProtocolIfNeeded(),
            let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        
        return true
    }
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        setLoader(isHidden: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        setLoader(isHidden: true)
        writeUrl(webView.url?.absoluteString ?? "")
    }
}

extension String {
    func addProtocolIfNeeded() -> String {
        if self.starts(with: "https://") {
            return self
        }
        
        return "https://\(self)"
    }
}
