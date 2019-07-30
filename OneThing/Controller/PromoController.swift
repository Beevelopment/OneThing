//
//  PromoController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-07-16.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

class PromoController: UIViewController, UITextFieldDelegate {
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter Promo Code"
        lbl.font = UIFont(name: SansationBold, size: 36)!
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .left
        
        return lbl
    }()
    
    lazy var textField: UITextField = {
        let txtField = UITextField()
        txtField.delegate = self
        txtField.placeholder = "Enter promo code..."
        txtField.font = UIFont(name: SansationRegular, size: 16)!
        txtField.layer.borderWidth = 1
        txtField.layer.borderColor = divider.cgColor
        txtField.layer.cornerRadius = 16
        txtField.setLeftPaddingPoints(16)
        txtField.setRightPaddingPoints(16)
        txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        return txtField
    }()
    
    let submitButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Submit", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.isUserInteractionEnabled = false
        btn.addTarget(self, action: #selector(submitCode), for: .touchUpInside)
        
        return btn
    }()
    
    let messageLabel: UILabel = {
        let msgLbl = UILabel()
        msgLbl.font = UIFont(name: SansationRegular, size: 16)!
        msgLbl.textColor = .lightGray
        msgLbl.textAlignment = .center
        msgLbl.numberOfLines = 0
        
        return msgLbl
    }()
    
    var promoCodes = [PromoCodeModel]()
    var activeCodeUser = [ActiveCodeUserModel]()
    var usedCodesUser = [UsedCodeUserModel]()
    let promotionCodes = "promotionCodes"
    var UID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        if let uid = userUid as? String {
            UID = uid
        } else {
            UID = WalkthroughCell.newUser
        }
        
        downloadPromoCodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    @objc private func submitCode() {
        do {
            try checkCode()
            messageLabel.text = ""
            uploadPromoCodeUser()
        } catch PromoError.codeAlreadyUsed {
            messageLabel.text = "You have already used this code. Please try another code or purchase Royal User."
        } catch PromoError.codeDoesNotExist {
            messageLabel.text = "The code that you're trying to use doesn’t exist. Please try another code or purchase Royal User."
        } catch PromoError.codeIsActive {
            messageLabel.text = "You already have a code activated. You can only register one code at the time."
        } catch {
            messageLabel.text = "Something went wrong. Please check your spelling and try again."
        }
    }
    
    private func checkCode() throws {
        if promoCodes.first(where: { $0.promoCode == textField.text! }) == nil {
            throw PromoError.codeDoesNotExist
        } else if !activeCodeUser.isEmpty {
            throw PromoError.codeIsActive
        } else if usedCodesUser.first(where: { $0.code == textField.text! }) != nil {
            throw PromoError.codeAlreadyUsed
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text!.count > 0 {
            submitButton.backgroundColor = yellow
            submitButton.isUserInteractionEnabled = true
        } else {
            submitButton.backgroundColor = divider
            submitButton.isUserInteractionEnabled = false
        }
    }
    
    private func uploadPromoCodeUser() {
        let documentData = [
            "activatedDate": "\(Date().timeIntervalSince1970)",
            "code": textField.text!
        ]
        
        database.collection("users").document(UID).collection(promotionCodes).document("activeCode").setData(documentData) { (err) in
            self.updateNumberOfTimesUsed()
        }
    }
    
    private func updateNumberOfTimesUsed() {
        if let code = promoCodes.first(where: { $0.promoCode == textField.text! }) {
            let numberUsed = Int(code.used)!
            let newNumber = numberUsed + 1
            let key = code.key
            let documentData = [
                "used": "\(newNumber)"
            ]
            
            database.collection(promotionCodes).document(key).setData(documentData, merge: true) { err in
                PurchaseManager.instance.setRoyalUserToTrue()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func downloadPromoCodes() {
        database.collection(promotionCodes).getDocuments { (querySnapshot, err) in
            guard err == nil else { return }
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let key = doc.documentID
                    let documentData = doc.data()
                    let data = PromoCodeModel(documentData: documentData, key: key)
                    self.promoCodes.append(data)
                }
                self.downloadActiveCodeUser()
                self.downloadUsedCodesUser()
            }
        }
    }
    
    private func downloadActiveCodeUser() {
        database.collection("users").document(UID).collection(promotionCodes).document("activeCode").getDocument { (documentSnapshot, err) in
            guard err == nil else { return }
            if let document = documentSnapshot?.data() {
                let activeCode = ActiveCodeUserModel(documetData: document)
                self.activeCodeUser.append(activeCode)
            }
        }
    }
    
    private func downloadUsedCodesUser() {
        database.collection("users").document(UID).collection(promotionCodes).document("usedCodes").getDocument { (documentSnapshot, err) in
            guard err == nil else { return }
            if let document = documentSnapshot?.data() {
                for doc in document {
                    if let code = doc.value as? String {
                        let usedCode = UsedCodeUserModel(code: code)
                        self.usedCodesUser.append(usedCode)
                    }
                }
            }
        }
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        titleLabel.textColor = Theme.currentTheme.mainTextColor
        textField.backgroundColor = Theme.currentTheme.backgroundColor
        textField.textColor = Theme.currentTheme.mainTextColor
    }
    
    private func setupView() {
        view.backgroundColor = .white
        [titleLabel, textField, submitButton, messageLabel].forEach { view.addSubview($0) }
        _ = titleLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = textField.anchor(titleLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        _ = submitButton.anchor(textField.bottomAnchor, left: textField.leftAnchor, bottom: nil, right: textField.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        _ = messageLabel.anchor(submitButton.bottomAnchor, left: submitButton.leftAnchor, bottom: nil, right: submitButton.rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
}
