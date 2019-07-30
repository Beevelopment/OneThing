//
//  FeedbackController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-18.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase
import DeviceKit

class FeedbackController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    lazy var feedbackLuncher: FeedbackLuncher = {
        let feed = FeedbackLuncher()
        feed.feedbackController = self
        
        return feed
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Describe the bug"
        lbl.font = UIFont(name: SansationBold, size: 36)!
        lbl.textColor = .black
        
        return lbl
    }()
    
    lazy var textView: UITextView = {
        let txtView = UITextView()
        txtView.delegate = self
        txtView.layer.borderColor = divider.cgColor
        txtView.layer.borderWidth = 1
        txtView.layer.cornerRadius = 16
        txtView.text = self.genericText
        txtView.textColor = Theme.currentTheme.mainTextColor
        txtView.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        txtView.font = UIFont(name: SansationRegular, size: 16)!
        
        return txtView
    }()
    
    let addImageButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Add image", for: .normal)
        btn.setTitleColor(yellow, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.addTarget(self, action: #selector(handelImagePicker), for: .touchUpInside)
        
        return btn
    }()
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "image")?.withRenderingMode(.alwaysTemplate)
        imgView.tintColor = UIColor(white: 1, alpha: 0.75)
        imgView.backgroundColor = divider
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = 8
        imgView.layer.borderColor = divider.cgColor
        imgView.layer.borderWidth = 1
        imgView.layer.masksToBounds = true
        
        return imgView
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
    
    let genericText = "Have you found a bug or is the design a little off? No worries I’ll fix it! As you might understand nothing is perfect but I do continuously work to deliver a great app for you. Sometimes a bug founds its way into the code and in those rare cases, I would love it if you could tell me. Thanks!"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    @objc private func submitButtonPressed() {
        guard textView.text != genericText else { return }
        feedbackLuncher.handelFeedbackLauncher()
        navigationController?.popViewController(animated: true)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupKeyboardObserver(on: self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == genericText {
            textView.text = ""
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
        }
    }
    
    @objc private func handelImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return dismiss(animated: true, completion: nil)
        }
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        titleLabel.textColor = Theme.currentTheme.mainTextColor
        textView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    private func setupView() {
        view.backgroundColor = .white
        [titleLabel, textView, addImageButton, imageView, submitButton].forEach { view.addSubview($0) }
        _ = titleLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = textView.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: view.frame.height * 0.40)
        _ = addImageButton.anchor(textView.bottomAnchor, left: textView.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        _ = imageView.anchor(textView.bottomAnchor, left: nil, bottom: nil, right: textView.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
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
                view.frame = CGRect(x: 0, y: -(keyboardHeight / 4) + navigationBarHeight! + topPadding!, width: view.frame.width, height: view.frame.height)
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
