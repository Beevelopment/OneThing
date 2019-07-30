//
//  WalkthroughCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-12.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Lottie
import Firebase
import SafariServices

protocol WalkthroughCellDelegate {
    func walkthroughDone(cell: WalkthroughCell, dismiss: Bool)
    func openTerms(URL: URL)
}

class WalkthroughCell: UICollectionViewCell, UITextViewDelegate {
    
    var delegate: WalkthroughCellDelegate?
    
    lazy var walkthroughLauncher: WalkthroughLauncher = {
        let walk = WalkthroughLauncher()
        walk.walkthroughCell = self
        
        return walk
    }()
    
    var walkthrough: WalktroughModel? {
        didSet {
            setAlpha()
            isAnimation = walkthrough!.bool
            textView.text = walkthrough?.text
            if walkthrough!.bool {
                animationView.alpha = 1
                animationView.animation = Animation.named(walkthrough!.illustration)
                if walkthrough!.illustration == "noti" {
                    animationView.loopMode = .loop
                    termsTextView.alpha = 1
                    leftButton.alpha = 1
                    rightButton.alpha = 1
                } else {
                    animationView.loopMode = .playOnce
                }
                animationView.play()
            } else {
                imageView.alpha = 1
                imageView.image = UIImage(named: walkthrough!.illustration)
            }
            setupColors()
        }
    }
    
    let container: UIView = {
        let con = UIView()
        con.layer.cornerRadius = 16
        con.layer.shadowOpacity = 0.15
        con.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        con.layer.shadowRadius = 5
        
        return con
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "crown")
        img.contentMode = .scaleAspectFit
        img.alpha = 0
        
        return img
    }()
    
    let animationView: AnimationView = {
        let ani = AnimationView(name: "noti")
        ani.alpha = 0
        
        return ani
    }()
    
    let textView: UILabel = {
        let txt = UILabel()
        txt.font = UIFont(name: SansationRegular, size: 18)!
        txt.text = "Test test"
        txt.textAlignment = .center
        txt.numberOfLines = 0
        txt.adjustsFontSizeToFitWidth = true
        
        return txt
    }()
    
    lazy var termsTextView: UITextView = {
        let terms = UITextView()
        terms.text = "By continuing you are agreeing to our\nPrivacy Policy and Terms & Conditions."
        terms.font = UIFont(name: SansationRegular, size: 10)!
        terms.textColor = divider
        terms.textAlignment = .center
        terms.alpha = 0
        terms.isEditable = false
        terms.delegate = self
        
        return terms
    }()
    
    let leftButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Later", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.075
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btn.layer.shadowRadius = 5
        btn.alpha = 0
        
        return btn
    }()
    
    let rightButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Wake Up!", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.backgroundColor = yellow
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.075
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btn.layer.shadowRadius = 5
        btn.alpha = 0
        
        return btn
    }()
    
    var isAnimation = false
    static var newUser = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.openTerms(URL: URL)
        return false
    }
    
    @objc private func enableNotifications() {
        UserNotifications.instance.showNotificationAlert { (granted) in
            self.buttonAction()
        }
    }
    
    @objc private func createAnonymousUser() {
        Auth.auth().signInAnonymously { (authResult, err) in
            guard let result = authResult else {
                print("Carl: Something went wrong. Error: \(err!.localizedDescription)")
                print("Carl: Something went wrong. Error: \(err!)")
                return
            }
            
            let user = result.user
            let userUid = user.uid
            
            WalkthroughCell.newUser = userUid
            UserDefaults.standard.set(userUid, forKey: "uid")
            
            print("Carl: User created")
            self.setupUserData(uid: userUid)
        }
    }
    
    private func setupUserData(uid: String) {
        let categoriesToAdd = ["General", "Family", "Friends", "Work", "Physical Health", "Community"]
        var categoryData: [String: Any] = [:]
        var i = 0
        let date = Date().timeIntervalSince1970
        
        let uploadGroup = DispatchGroup()
        
        for category in categoriesToAdd {
            categoryData = [:]
            i = 0
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
            
            uploadGroup.enter()
                database.collection("users").document(uid).collection("categories").document(category).setData(categoryData, merge: true) { (error) in
                    guard error == nil else {
                        print("Carl: error \(error!.localizedDescription)")
                        uploadGroup.leave()
                        return
                    }
                    print("Carl: Done")
                    uploadGroup.leave()
                }
        }
        
        uploadGroup.notify(queue: DispatchQueue.main) {
            self.addNotificationsToFirebase(uid: uid)
        }
    }
    
    private func addNotificationsToFirebase(uid: String) {
        var notification: [String: String] = [:]
        for topic in UserNotifications.instance.topics {
            notification[topic.rawValue] = "\(true)"
        }
        database.collection("users").document(uid).setData(["notifications": notification]) { (error) in
            guard error == nil else {
                self.walkthroughFinished()
                return
            }
            self.walkthroughFinished()
        }
    }
    
    @objc private func walkthroughFinished() {
        if userUid != nil {
            delegate?.walkthroughDone(cell: self, dismiss: true)
        } else {
            delegate?.walkthroughDone(cell: self, dismiss: false)
        }
    }
    
    @objc private func buttonAction() {
        if userUid != nil {
            if PurchaseManager.isRoyal {
                self.delegate?.walkthroughDone(cell: self, dismiss: true)
            } else {
                self.delegate?.walkthroughDone(cell: self, dismiss: false)
            }
        } else {
            createAnonymousUser()
        }
    }
    
    private func setupActions() {
        leftButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(enableNotifications), for: .touchUpInside)
    }
    
    private func setAlpha() {
        let alpaOnObjects = [termsTextView, leftButton, rightButton, imageView, animationView]
        alpaOnObjects.forEach {$0.alpha = 0}
    }
    
    private func setupColors() {
        container.backgroundColor = Theme.currentTheme.backgroundColor
        container.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
        textView.textColor = Theme.currentTheme.mainTextColor
        termsTextView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    private func setupCell() {
        let marign = frame.width / 20
        
        let linkedText = NSMutableAttributedString(attributedString: termsTextView.attributedText)
        let privacylinked = linkedText.setAsLink(textToFind: "Privacy Policy", linkURL: PRIVACY_POLICY)
        let termsLinked = linkedText.setAsLink(textToFind: "Terms & Conditions", linkURL: TERMS_CONDITIONS)
        
        if privacylinked && termsLinked {
            termsTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        addSubview(container)
        [imageView, animationView, textView, termsTextView, leftButton, rightButton].forEach { container.addSubview($0) }
        _ = container.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: marign, bottomConstant: 0, rightConstant: marign, widthConstant: 0, heightConstant: 0)
        _ = imageView.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.height / 2 - 20)
        _ = animationView.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: frame.height / 2)
        _ = textView.anchor(animationView.bottomAnchor, left: container.leftAnchor, bottom: leftButton.topAnchor, right: container.rightAnchor, topConstant: marign, leftConstant: marign, bottomConstant: marign, rightConstant: marign, widthConstant: 0, heightConstant: 0)
        _ = termsTextView.anchor(nil, left: leftButton.leftAnchor, bottom: leftButton.topAnchor, right: rightButton.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 30)
        _ = leftButton.anchor(nil, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, topConstant: 0, leftConstant: marign, bottomConstant: marign, rightConstant: 0, widthConstant: frame.width / 2 - marign * 2.5, heightConstant: 40)
        _ = rightButton.anchor(nil, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: marign, rightConstant: marign, widthConstant: frame.width / 2 - marign * 2.5, heightConstant: 40)
        
        setupActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
