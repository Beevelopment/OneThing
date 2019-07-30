//
//  MessagePopUp.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-06.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class MessagePopUp: NSObject {
    
    var mainViewController: MainViewController?
    var mainCollectionViewCell: MainCollectionViewCell?
    var readController: ReadController?
    var purchaseCell: PurchaseCell?
    var signInManager: SignInManager?
    var accountController: AccountController?
    var settingsController: SettingsController?
    
    let blackView: UIView = {
        let bv = UIView()
        bv.alpha = 0
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        return bv
    }()
    
    let container: UIView = {
        let c = UIView()
        c.layer.cornerRadius = 15
        
        return c
    }()
    
    let messageLabel: UILabel = {
        let msgLbl = UILabel()
        msgLbl.font = UIFont(name: SansationRegular, size: 21)!
        msgLbl.textAlignment = .center
        msgLbl.numberOfLines = 0
        
        return msgLbl
    }()
    
    let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.setTitle("No", for: .normal)
        
        return btn
    }()
    
    let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = yellow
        btn.layer.cornerRadius = 20
        btn.setTitle("Yes", for: .normal)
        
        return btn
    }()
    
    let dismissButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.setTitle("Ok", for: .normal)
        
        return btn
    }()
    
    var isInfo = false
    var horizontalData: MainCollectionViewModel?
    
    func showNotMarkedMessage(message: Message, oneThing: String) {
        isInfo = false
        setLabel(message: message, oneThing: oneThing)
        animate(out: false, message: message) { (bool) in
        }
    }
    
    func removeStreak() {
        isInfo = false
        animate(out: true, message: .notMarkedAsDone) { (bool) in
        }
    }
    
    func showGenericMessage(text: String) {
        isInfo = true
        setLabel(message: .cancel, oneThing: text)
        animate(out: false, message: .cancel) { (bool) in
        }
    }
    
    func errorMessage(message: String, onCompletion: @escaping CompletionHandler) {
        isInfo = true
        setLabel(message: .cancel, oneThing: message)
        animate(out: false, message: .cancel, onCompletion: onCompletion)
    }
    
    private func animate(out: Bool, message: Message, onCompletion: @escaping CompletionHandler) {
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 10
            var conteinerHeight: CGFloat = 110.0
            var font: UIFont!
            
            if isInfo {
                font = UIFont(name: SansationLight, size: 13)!
            } else {
                font = UIFont(name: SansationRegular, size: 21)!
            }
            
            if let messageHeight = messageLabel.text?.height(withConstrainedWidth: margin * 8, font: font) {
                conteinerHeight = conteinerHeight + messageHeight
            }
            
            if !out {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    self.blackView.alpha = 1
                    self.container.frame = CGRect(x: margin, y: window.frame.height / 2 - conteinerHeight / 2, width: margin * 8, height: conteinerHeight)
                })
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.blackView.alpha = 0
                    self.container.frame = CGRect(x: margin, y: -conteinerHeight, width: margin * 8, height: conteinerHeight)
                }) { (true) in
                    if message == .markedAsDone {
                        self.mainCollectionViewCell?.moveToArchive()
                    } else if message == .notMarkedAsDone {
                        guard let data = self.horizontalData else { return }
                        if data.text != self.mainCollectionViewCell?.genericText {
                            self.mainCollectionViewCell?.moveMainTextToArchive(horizontalData: data, completed: false)
                        } else {
                            self.mainCollectionViewCell?.updateMainText(horizontalData: data, completed: false)
                        }
                    }
                    onCompletion(true)
                    self.removeFromSuperView()
                }
            }
        }
    }
    
    private func setLabel(message: Message, oneThing: String) {
        actionButton.addTarget(self, action: #selector(markedAsDone), for: .touchUpInside)
        cancelButton.removeTarget(nil, action: nil, for: .allEvents)
        messageLabel.font = UIFont(name: SansationRegular, size: 21)!
        if message == .markedAsDone {
            messageLabel.text = "Are you sure that you want to mark \"\(oneThing)\" as done?"
            cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            actionButton.setTitle("Yes", for: .normal)
            dismissButton.setTitle("No", for: .normal)
            setupMessage()
        } else if message == .notMarkedAsDone {
            messageLabel.text = "You haven't marked\n\"\(oneThing)\"\nas done. Did you complete this OneThing?"
            cancelButton.addTarget(self, action: #selector(notMarkedAsDone), for: .touchUpInside)
            actionButton.setTitle("Yes", for: .normal)
            dismissButton.setTitle("No", for: .normal)
            setupMessage()
        } else if message == .reviweApp {
            messageLabel.text = oneThing
            actionButton.removeTarget(nil, action: nil, for: .allEvents)
            cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(reviewApplication), for: .touchUpInside)
            actionButton.setTitle("Review", for: .normal)
            cancelButton.setTitle("Close", for: .normal)
            setupMessage()
        } else {
            messageLabel.font = UIFont(name: SansationLight, size: 12)!
            messageLabel.text = oneThing
            setupInformationMessage()
        }
    }
    
     @objc private func reviewApplication() {
        let urlString = "https://apps.apple.com/us/app/onething-extraordinary-result/id1467908953"
        let url = URL(string: urlString)!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-review")
        ]
        
        guard let writeReviweUrl = components?.url else { return }
        UIApplication.shared.open(writeReviweUrl)
    }
    
    @objc private func markedAsDone() {
        animate(out: true, message: .markedAsDone) { (bool) in
        }
    }
    
    @objc private func cancel() {
        animate(out: true, message: .cancel) { (bool) in
        }
    }
    
    @objc private func notMarkedAsDone() {
        animate(out: true, message: .notMarkedAsDone) { (bool) in
        }
    }
    
    private func setupColors() {
        container.backgroundColor = Theme.currentTheme.backgroundColor
        messageLabel.textColor = Theme.currentTheme.mainTextColor
    }
    
    private func setupMessage() {
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 10
            var conteinerHeight: CGFloat = 110.0
            if let messageHeight = messageLabel.text?.height(withConstrainedWidth: margin * 8, font: UIFont(name: SansationRegular, size: 21)!) {
                conteinerHeight = conteinerHeight + messageHeight
            }
            
            setupColors()
            
            [blackView, container].forEach { window.addSubview($0) }
            [messageLabel, cancelButton, actionButton].forEach { container.addSubview($0) }
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            container.frame = CGRect(x: margin, y: -conteinerHeight, width: margin * 8, height: conteinerHeight)
            
            _ = messageLabel.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            _ = cancelButton.anchor(nil, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: margin / 2, widthConstant: container.frame.width / 2 - 30, heightConstant: 40)
            _ = actionButton.anchor(nil, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: margin / 2, bottomConstant: 20, rightConstant: 20, widthConstant: container.frame.width / 2 - 30, heightConstant: 40)
        }
    }
    
    private func setupInformationMessage() {
        setupColors()
        dismissButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        if let window = UIApplication.shared.keyWindow {
            let margin = window.frame.width / 10
            var conteinerHeight: CGFloat = 110.0
            if let messageHeight = messageLabel.text?.height(withConstrainedWidth: margin * 8, font: UIFont(name: SansationLight, size: 12)!) {
                conteinerHeight = conteinerHeight + messageHeight
            }
            
            [blackView, container].forEach { window.addSubview($0) }
            [messageLabel, dismissButton].forEach { container.addSubview($0) }
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            container.frame = CGRect(x: margin, y: -conteinerHeight, width: margin * 8, height: conteinerHeight)
            
            _ = messageLabel.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
            _ = dismissButton.anchor(nil, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: container.frame.width - 40, heightConstant: 40)
        }
    }
    
    private func removeFromSuperView() {
        container.removeFromSuperview()
        messageLabel.removeFromSuperview()
        cancelButton.removeFromSuperview()
        actionButton.removeFromSuperview()
        dismissButton.removeFromSuperview()
    }
}
