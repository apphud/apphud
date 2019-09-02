//
//  ApphudFeedbackController.swift
//  apphud
//
//  Created by Renat on 02/09/2019.
//  Copyright © 2019 softeam. All rights reserved.
//

import UIKit

internal class ApphudPlaceholderTextView: UITextView {
        
    fileprivate lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1)
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    class func initialize(placeholderText: String) -> ApphudPlaceholderTextView{
        let textview = ApphudPlaceholderTextView()
        textview.textContainerInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        textview.textContainer.lineFragmentPadding = 0
        textview.label.text = placeholderText
        textview.setup()
        return textview
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        self.label.preferredMaxLayoutWidth = textContainer.size.width
        self.label.sizeToFit()
        self.label.frame = CGRect(x: textContainerInset.left, y: textContainerInset.top, width: self.label.frame.size.width, height: self.label.frame.size.height)
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChange() {
        self.label.isHidden = !text.isEmpty
    }
}

class ApphudFeedbackController: UIViewController {

    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 54),
            ])
        return label
    }()
    
    private lazy var textView : ApphudPlaceholderTextView = {
        let textView = ApphudPlaceholderTextView.initialize(placeholderText: "Please type an answer here")
        self.view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 17)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            textView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),
            ])
        textView.backgroundColor = UIColor.red
        textView.inputAccessoryView = self.accessoryView
        return textView
    }()
    
    private lazy var accessoryView : UIView = {
        let accView = UIView()
        accView.autoresizingMask = .flexibleWidth
        accView.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.size.width), height: 60)
        accView.backgroundColor = UIColor(displayP3Red: 0, green: 1.0, blue: 0, alpha: 0.3)
        
        let button = ApphudInquiryButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.setTitleColor(UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1), for: .normal)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        accView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.backgroundColor = UIColor(red: 0.95, green: 0.94, blue: 0.97, alpha: 1).cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.leadingAnchor.constraint(equalTo: accView.leadingAnchor, constant: 10).isActive = true
        button.trailingAnchor.constraint(equalTo: accView.trailingAnchor, constant: -10).isActive = true
        
        return accView
    }()
    
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.titleLabel.text = "How can we improve the app?"
        
        self.textViewBottomConstraint = self.textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.textViewBottomConstraint.isActive = true
        // Do any additional setup after loading the view.
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        self.textView.becomeFirstResponder()
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setTitleColor(UIColor(red: 0.04, green: 0.52, blue: 1, alpha: 1), for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        dismissButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        dismissButton.setTitle("Cancel", for: .normal)
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            dismissButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15)
            ])
    }

    @objc func keyboardWillShow(notification: NSNotification) {  
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            self.textViewBottomConstraint.constant = -keyboardSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func cancelTapped(){
        self.textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func buttonTapped(sender: ApphudInquiryButton){
        apphudLog("send text: \(self.textView.text)")
    }
}
