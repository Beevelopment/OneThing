//
//  CategoryLauncher.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-02.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

class CategoryLauncher: NSObject, UITextFieldDelegate {
    
    var mainViewController: MainViewController?
    
    lazy var animation: Animations = {
        let ani = Animations()
        ani.categoryLauncer = self
        
        return ani
    }()
    
    let blackView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bv.alpha = 0
        
        return bv
    }()
    
    let container: UIView = {
        let c = UIView()
        c.backgroundColor = .white
        c.layer.cornerRadius = 15
        
        return c
    }()
    
    let textField: UITextField = {
        let txtView = UITextField()
        txtView.textColor = .black
        txtView.font = UIFont(name: SansationRegular, size: 16)!
        txtView.textAlignment = .left
        txtView.placeholder = "Add new category..."
        txtView.layer.cornerRadius = 20
        txtView.layer.borderWidth = 1
        txtView.layer.borderColor = divider.cgColor
        txtView.setLeftPaddingPoints(20)
        txtView.setRightPaddingPoints(20)
        
        return txtView
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        
        return btn
    }()
    
    let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = yellow
        btn.layer.cornerRadius = 20
        
        return btn
    }()
    
    var categoryToDelete: String?
    var uid: String!
    
    func addCategoryPressed(bool: Bool) {
        textField.text = ""
        cancelButton.setTitle("Cancel", for: .normal)
        actionButton.setTitle("Save", for: .normal)
        
        setupView()
        animateIn()
        setupActions(bool: bool)
    }
    
    func deleteCategoryPressed(category: String, bool: Bool) {
        textField.text = "Delete category: \(category)?"
        cancelButton.setTitle("No", for: .normal)
        actionButton.setTitle("Yes", for: .normal)
        
        categoryToDelete = category
        
        setupView()
        animateIn()
        setupActions(bool: bool)
    }
    
    @objc private func addNewCategory() {
        if let textFieldText = textField.text, !textFieldText.isEmpty {
            let newCategory = textFieldText.capitalized
            var categoryData: [String: Any] = [:]
            var i = 0
            let date = Date().timeIntervalSince1970
            
            while i < 5 {
                let zero: [String: Any] = [
                    "archive": [
                        "des": [
                            "completed": "true",
                            "text": "This is where your previous OneThings will show.",
                            "timestamp": "\(date)"
                        ]
                    ],
                    "text": "Write your OneThing here...",
                    "streak": "0",
                    "timestamp": "\(date)"
                ]
                
                categoryData["\(i)"] = zero
                i += 1
            }
            database.collection("users").document(uid).collection("categories").document(newCategory).setData(categoryData) { (err) in
                if let err = err {
                    print("Carl: error \(err.localizedDescription)")
                } else {
                    self.mainViewController?.downloadCategories(playAnimation: true)
                    self.animateOut()
                }
            }
        }
    }
    
    @objc private func deleteCategory() {
        if let category = categoryToDelete {
            database.collection("users").document(uid).collection("categories").document(category).delete { (err) in
                if let err = err {
                    print("Carl: error \(err.localizedDescription)")
                } else {
                    self.mainViewController?.downloadCategories(playAnimation: true)
                    self.mainViewController?.stopWiggle()
                    self.animateOut()
                }
            }
        }
    }
    
    private func setupActions(bool: Bool) {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        blackView.addGestureRecognizer(tapGestureRecognizer)
        cancelButton.addTarget(self, action: #selector(animateOut), for: .touchUpInside)
        if bool {
            actionButton.removeTarget(self, action: #selector(deleteCategory), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        } else {
            actionButton.removeTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(deleteCategory), for: .touchUpInside)
        }
    }
    
    private func animateIn() {
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 20
            let navBarSize = mainViewController?.navigationController?.navigationBar.bounds.size
            let containerHeight = margin * 3 + 100 + navBarSize!.height
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 1
                self.container.frame = CGRect(x: 0, y: -20, width: window.frame.width, height: containerHeight)
            }, completion: nil)
        }
    }
    
     @objc private func animateOut() {
        dismissKeyboard()
        
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 20
            let navBarSize = mainViewController?.navigationController?.navigationBar.bounds.size
            let containerHeight = margin * 3 + 100 + navBarSize!.height
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 0
                self.container.frame = CGRect(x: 0, y: -containerHeight, width: window.frame.width, height: containerHeight)
            }, completion: nil)
        }
    }
    
    private func setupView() {
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        if let window = UIApplication.shared.keyWindow {
            
            let margin = window.frame.width / 20
            let navBarSize = mainViewController?.navigationController?.navigationBar.bounds.size
            let containerHeight = margin * 3 + 100 + navBarSize!.height
            
            [blackView, container].forEach { window.addSubview($0) }
            [textField, cancelButton, actionButton].forEach { container.addSubview($0) }
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            container.frame = CGRect(x: 0, y: -containerHeight - 20, width: window.frame.width, height: containerHeight)
            
            _ = textField.anchor(container.safeAreaLayoutGuide.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: margin + 20, leftConstant: margin, bottomConstant: 0, rightConstant: margin, widthConstant: 0, heightConstant: 40)
            _ = cancelButton.anchor(textField.bottomAnchor, left: container.leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: margin, bottomConstant: 0, rightConstant: margin / 2, widthConstant: window.frame.width / 2 - margin * 1.5, heightConstant: 40)
            _ = actionButton.anchor(textField.bottomAnchor, left: nil, bottom: nil, right: container.rightAnchor, topConstant: margin, leftConstant: margin / 2, bottomConstant: 0, rightConstant: margin, widthConstant: window.frame.width / 2 - margin * 1.5, heightConstant: 40)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        setupKeyboardObserver()
        return true
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handelKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeight = keyboardFrame.height
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if let window = UIApplication.shared.keyWindow {
            window.frame = CGRect(x: 0, y: -keyboardHeight + window.safeAreaInsets.bottom - 10, width: window.frame.width, height: window.frame.height)
            UIView.animate(withDuration: keyboardDuration) {
                window.layoutIfNeeded()
            }
        }
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if let window = UIApplication.shared.keyWindow {
            window.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height)
            UIView.animate(withDuration: keyboardDuration) {
                window.layoutIfNeeded()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
            removeKeyboardObserver()
        }
    }
}
