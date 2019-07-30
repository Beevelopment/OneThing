//
//  DeveloperController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-20.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import AudioToolbox
import DeviceKit

class DeveloperController: UIViewController, UITextViewDelegate {
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        
        return scroll
    }()
    
    let contentView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "me")
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 100
        img.layer.borderColor = divider.cgColor
        img.layer.borderWidth = 1
        img.clipsToBounds = true
        
        return img
    }()
    
    let textLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 14)!
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.text = "Hi, Carl here! I’m the face behind Onething. I hope that you have seen some extraordinary results with help from this app and that you are still going strong!\n\nThe main driving force to create this app was that the majority of people, including me at one time, who takes courses, go to lectures or read a book never uses its content. This is a huge problem because we would have seen some amazing transformations and even more success stories if we used the principles and strategies that are presented to us. I got inspired by Gary Keller and his book The ONE Thing because the strategy that he presented was so simple and so powerful and I knew that if enough people use this strategy we would be much better of.\n\nI want to help the people that have dreams and goals to reach them by giving them a dedicated way to focus on OneThing and OneThing only. I want to give the people who read the book, but did nothing with it, a truly great chance to reach extraordinary results.\n\n\nWould you like to contact me please write your message below and sent it or contact me on LinkedIn. I would love to hear what extraordinary results you have gotten by focusing at OneThing at the time!"
        
        return lbl
    }()
    
    lazy var contactTextView: UITextView = {
        let txt = UITextView()
        txt.font = UIFont(name: SansationRegular, size: 16)!
        txt.layer.borderColor = divider.cgColor
        txt.layer.borderWidth = 1
        txt.layer.cornerRadius = 16
        txt.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        txt.textColor = divider
        txt.text = self.genericText
        txt.delegate = self
        
        return txt
    }()
    
    let sendButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Send", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.backgroundColor = yellow
        btn.layer.cornerRadius = 15
        btn.layer.shadowOpacity = 0.075
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btn.layer.shadowRadius = 5
        btn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        return btn
    }()
    
    let linkedInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "linkedIn"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(openLinkedIn), for: .touchUpInside)
        
        return btn
    }()
    
    let genericText = "Write your message here..."
    let peek = SystemSoundID(1519)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        textLabel.textColor = Theme.currentTheme.mainTextColor
        contactTextView.backgroundColor = Theme.currentTheme.backgroundColor
        sendButton.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
    }
    
    @objc private func sendMessage() {
        if contactTextView.text != nil && contactTextView.text != genericText {
            AudioServicesPlayAlertSound(peek)
            database.collection("contact").addDocument(data: ["message": contactTextView.text!]) { (err) in
                guard err == nil else { return }
                self.contactTextView.text = self.genericText
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func openLinkedIn() {
        guard let url = URL(string: "https://www.linkedin.com/in/carlhenningsson") else { return }
        UIApplication.shared.open(url)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupKeyboardObserver(on: self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == divider {
            textView.textColor = Theme.currentTheme.mainTextColor
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = genericText
            textView.textColor = divider
        }
    }
    
    private func setupView() {
        let imageMargin = (view.frame.width - 200) / 2
        
        view.addSubview(scrollView)
        if PurchaseManager.isRoyal {
            _ = scrollView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            _ = scrollView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 60, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        
        scrollView.addSubview(contentView)
        _ = contentView.anchor(scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width, heightConstant: 0)
        
        [imageView, textLabel, contactTextView, sendButton, linkedInButton].forEach { contentView.addSubview($0) }
        _ = imageView.anchor(contentView.safeAreaLayoutGuide.topAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: imageMargin, bottomConstant: 0, rightConstant: imageMargin, widthConstant: 200, heightConstant: 200)
        
        if Device.current.isPad {
            let margin = view.frame.width / 4
            
            _ = textLabel.anchor(imageView.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: 0)
            _ = contactTextView.anchor(textLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: 150)
        } else {
            _ = textLabel.anchor(imageView.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            _ = contactTextView.anchor(textLabel.bottomAnchor, left: contentView.leftAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 150)
        }

        _ = sendButton.anchor(nil, left: nil, bottom: contactTextView.bottomAnchor, right: contactTextView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 10, rightConstant: 10, widthConstant: 75, heightConstant: 30)
        _ = linkedInButton.anchor(contactTextView.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(on:)))
        contentView.addGestureRecognizer(tapGestureRecognizer)
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
        
        if !keyboardIsVisible {
            scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardHeight)
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
        keyboardIsVisible = true
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
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
