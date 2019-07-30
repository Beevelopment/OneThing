//
//  StoryController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-07-12.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import DeviceKit

class StoryController: UIViewController, UITextViewDelegate {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Tell Your Story"
        lbl.font = UIFont(name: SansationBold, size: 36)!
        
        return lbl
    }()
    
    let subTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "By focusing on OneThing we can and will reach extraordinary results. Some of the stories that I have heard and read are amazing. I and the other users would love to hear your story of The ONE Thing. We may share the story on social media and inside the app."
        lbl.font = UIFont(name: SansationRegular, size: 12)!
        lbl.numberOfLines = 0
        lbl.textColor = Theme.currentTheme.subTextColor
        
        return lbl
    }()
    
    lazy var textView: UITextView = {
        let txtView = UITextView()
        txtView.delegate = self
        txtView.layer.borderColor = divider.cgColor
        txtView.layer.borderWidth = 1
        txtView.layer.cornerRadius = 16
        txtView.text = self.genericText
        txtView.textColor = Theme.currentTheme.subTextColor
        txtView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        txtView.font = UIFont(name: SansationRegular, size: 16)!
        
        return txtView
    }()
    
    let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        
        return btn
    }()
    
    let genericText = "Write your story here..."

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    private func uploadToFirebase(onCompletion: @escaping CompletionHandler) {
        var uid: String!
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        let story: [String: String] = ["story": textView.text]
        
        database.collection("stories").addDocument(data: story) { (err) in
            guard err == nil else { return }
            database.collection("users").document(uid).collection("story").addDocument(data: story)
            self.textView.text = self.genericText
            self.textView.textColor = Theme.currentTheme.subTextColor
            onCompletion(true)
        }
    }
    
    @objc private func submitButtonPressed() {
        guard textView.text != genericText else { return }
        uploadToFirebase { (bool) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupKeyboardObserver(on: self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == genericText {
            textView.text = ""
            textView.textColor = Theme.currentTheme.mainTextColor
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            submitButton.backgroundColor = yellow
        } else {
            submitButton.backgroundColor = divider
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = genericText
            textView.textColor = Theme.currentTheme.subTextColor
        }
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        titleLabel.textColor = Theme.currentTheme.mainTextColor
        subTitle.textColor = Theme.currentTheme.subTextColor
        textView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    private func setupView() {
        view.backgroundColor = .white
        [titleLabel, subTitle, textView, submitButton].forEach { view.addSubview($0) }
        _ = titleLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = subTitle.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = textView.anchor(subTitle.bottomAnchor, left: view.leftAnchor, bottom: submitButton.topAnchor, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        
        if PurchaseManager.isRoyal {
            _ = submitButton.anchor(nil, left: textView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: textView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 20, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        } else {
            _ = submitButton.anchor(nil, left: textView.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: textView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 60, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func viewTapped() {
        if keyboardIsVisible {
            dismissKeyboard(on: self)
        }
    }
    
    func setupKeyboardObserver(on object: NSObject) {
        NotificationCenter.default.addObserver(object, selector: #selector(handelKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(object, selector: #selector(handelKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver(on object: NSObject) {
        NotificationCenter.default.removeObserver(object)
    }
    
    var keyboardIsVisible = false
    
    @objc func handelKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeight = keyboardFrame.height
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let navigationBarHeight = navigationController?.navigationBar.bounds.size.height
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        
        if !Device.current.isPad {
            if !keyboardIsVisible {
                view.frame = CGRect(x: 0, y: -(keyboardHeight / 2) + navigationBarHeight! + topPadding!, width: view.frame.width, height: view.frame.height)
                UIView.animate(withDuration: keyboardDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        keyboardIsVisible = true
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let navigationBarHeight = navigationController?.navigationBar.bounds.size.height
        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top
        
        view.frame = CGRect(x: 0, y: navigationBarHeight! + topPadding!, width: view.frame.width, height: view.frame.height)
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        keyboardIsVisible = false
    }
    
    @objc func dismissKeyboard(on object: NSObject) {
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
            removeKeyboardObserver(on: object)
        }
    }
}
