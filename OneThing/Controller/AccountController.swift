//
//  AccountController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-15.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn
import Lottie
import Firebase
import DeviceKit

class AccountController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, GIDSignInUIDelegate {
    
    let inAppPurchaseController = InAppPurchaseController()
    
    lazy var signInManager: SignInManager = {
        let sign = SignInManager()
        sign.accountController = self
        
        return sign
    }()
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.accountController = self
        
        return msg
    }()
    
    let laterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("I do it later", for: .normal)
        btn.setTitleColor(yellow, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 14)
        btn.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        
        return btn
    }()
    
    let viewHeaderLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 21)!
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = yellow
        lbl.text = "Sign in or sign up an account and sync your extraordinary results to all you iOS devices."
        
        return lbl
    }()
    
    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.text = "Continue with Email & password"
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.textColor = divider
        
        return lbl
    }()
    
    lazy var emailTextField: UITextField = {
        let emailTxt = UITextField()
        emailTxt.keyboardType = .emailAddress
        emailTxt.adjustsFontSizeToFitWidth = true
        emailTxt.font = UIFont(name: SansationRegular, size: 16)!
        emailTxt.attributedPlaceholder = NSAttributedString(string: "Your Email address", attributes: [NSAttributedString.Key.foregroundColor: divider])
        emailTxt.setBottomBorder()
        emailTxt.tag = 0
        emailTxt.setRightPaddingPoints(60)
        emailTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTxt.delegate = self
        
        return emailTxt
    }()
    
    let emailVerifiedAnimation: AnimationView = {
        let ani = AnimationView(name: "done")
        ani.alpha = 0
        
        return ani
    }()
    
    lazy var passwordTextField: UITextField = {
        let passwordTxt = UITextField()
        passwordTxt.isSecureTextEntry = true
        passwordTxt.adjustsFontSizeToFitWidth = true
        passwordTxt.font = UIFont(name: SansationRegular, size: 16)!
        passwordTxt.attributedPlaceholder = NSAttributedString(string: "Your password", attributes: [NSAttributedString.Key.foregroundColor: divider])
        passwordTxt.setBottomBorder()
        passwordTxt.tag = 1
        passwordTxt.setRightPaddingPoints(60)
        passwordTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTxt.delegate = self
        
        return passwordTxt
    }()
    
    let passwordVerifiedAnimation: AnimationView = {
        let ani = AnimationView(name: "done")
        ani.alpha = 0
        
        return ani
    }()
    
    let orLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.text = "or"
        lbl.textAlignment = .center
        lbl.textColor = divider
        
        return lbl
    }()
    
    lazy var socialCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        
        return cv
    }()
    
    let actionButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Continue", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.backgroundColor = divider
        btn.layer.cornerRadius = 20
        btn.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.15
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        btn.layer.shadowRadius = 5
        btn.isUserInteractionEnabled = false
        btn.addTarget(self, action: #selector(continueWithPasswordCredentials), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var dismissView: UIView = {
        let view = UIView()
        view.isHidden = true
        
        return view
    }()
    
    let imageName = ["google", "facebook", "twitter"]
    let socialCellID = "socialCellID"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        socialCollectionView.register(SocialCell.self, forCellWithReuseIdentifier: socialCellID)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(on:)))
        dismissView.addGestureRecognizer(gestureRecognizer)
        
        checkUserProvider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    private func checkUserProvider() {
        if let providerData = Auth.auth().currentUser?.providerData {
            for userInfo in providerData {
                switch userInfo.providerID {
                case ProviderID.facebook.rawValue:
                    messagePopUp.errorMessage(message: "You have already authenticated your account with Facebook.") { (true) in
                        self.dismissController()
                    }
                case ProviderID.google.rawValue:
                    messagePopUp.errorMessage(message: "You have already authenticated your account with Google.") { (true) in
                        self.dismissController()
                    }
                case ProviderID.twitter.rawValue:
                    messagePopUp.errorMessage(message: "You have already authenticated your account with Twitter.") { (true) in
                        self.dismissController()
                    }
                case ProviderID.password.rawValue:
                    messagePopUp.errorMessage(message: "You have already authenticated your account with email and password.") { (true) in
                        self.dismissController()
                    }
                default:
                    print("Carl: user is signed in with \(userInfo.providerID)")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let image = imageName[indexPath.item]
        if let cell = socialCollectionView.dequeueReusableCell(withReuseIdentifier: socialCellID, for: indexPath) as? SocialCell {
            cell.setupView(imageName: image)
            return cell
        } else {
            return SocialCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let provider = imageName[indexPath.item]
        if PurchaseManager.isRoyal {
            if provider == imageName[0] {
                GIDSignIn.sharedInstance().uiDelegate = self
                SignInManager.instance.googleSignIn()
            } else if provider == imageName[1] {
                SignInManager.instance.facebookSignIn { (bool) in
                    guard bool else {
                        print("Carl: show some error message")
                        return
                    }
                    self.dismissController()
                }
            } else if provider == imageName[2] {
                SignInManager.instance.twitterSingIn { (bool) in
                    guard bool else {
                        print("Carl: show some error message")
                        return
                    }
                    self.dismissController()
                }
            }
        } else {
            present(inAppPurchaseController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: 50)
    }
    
    @objc private func continueWithPasswordCredentials() {
        if PurchaseManager.isRoyal {
            SignInManager.instance.emailSingIn(email: emailTextField.text!, password: passwordTextField.text!) { (bool) in
                guard bool else {
                    print("Carl: show some error message")
                    return
                }
                self.dismissController()
            }
        } else {
            present(inAppPurchaseController, animated: true, completion: nil)
        }
    }
    
    private func playVerifiedAnimation(on animationView: AnimationView) {
        if animationView.alpha == 0 {
            UIView.animate(withDuration: 0.25) {
                animationView.alpha = 1
            }
            animationView.play()
        }
    }
    
    private func hideVerifiedAnimation(on animationView: AnimationView) {
        if animationView.alpha == 1 {
            UIView.animate(withDuration: 0.25) {
                animationView.alpha = 0
            }
        }
    }
    
    private func isValidtextFields() {
        if isValidEmail(string: emailTextField.text!) && isValidPassword(string: passwordTextField.text!) {
            actionButton.isUserInteractionEnabled = true
            actionButton.backgroundColor = yellow
        } else {
            actionButton.isUserInteractionEnabled = false
            actionButton.backgroundColor = divider
        }
    }
    
    @objc func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        emailTextField.backgroundColor = Theme.currentTheme.backgroundColor
        passwordTextField.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    private func setupView() {
        var margin: CGFloat = 0.0

        if Device.current.isOneOf(groupOfSmalliPhones) {
            margin = view.frame.width / 20
        } else {
            margin = view.frame.width / 10
        }
        
        [laterButton, viewHeaderLabel, descriptionLabel, emailTextField, emailVerifiedAnimation, passwordTextField, passwordVerifiedAnimation, orLabel, socialCollectionView, actionButton, dismissView].forEach { view.addSubview($0) }
        _ = laterButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = viewHeaderLabel.anchor(laterButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = descriptionLabel.anchor(viewHeaderLabel.bottomAnchor, left: viewHeaderLabel.leftAnchor, bottom: nil, right: viewHeaderLabel.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = emailTextField.anchor(descriptionLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        _ = emailVerifiedAnimation.anchor(emailTextField.topAnchor, left: nil, bottom: emailTextField.bottomAnchor, right: emailTextField.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = passwordTextField.anchor(emailTextField.bottomAnchor, left: emailTextField.leftAnchor, bottom: nil, right: emailTextField.rightAnchor, topConstant: margin / 2, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        _ = passwordVerifiedAnimation.anchor(passwordTextField.topAnchor, left: nil, bottom: passwordTextField.bottomAnchor, right: passwordTextField.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = orLabel.anchor(passwordTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = socialCollectionView.anchor(orLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: margin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 50)
        _ = actionButton.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        _ = dismissView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        if PurchaseManager.isRoyal {
            _ = actionButton.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        } else {
            _ = actionButton.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 60, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        }
    }
    
    private func isValidEmail(string: String) -> Bool {
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let email = NSPredicate(format:"SELF MATCHES %@", emailReg)
        return email.evaluate(with: string)
    }
    
    private func isValidPassword(string: String) -> Bool {
        let passwordReg = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        
        let password = NSPredicate(format:"SELF MATCHES %@", passwordReg)
        return password.evaluate(with: string)
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
            UIView.animate(withDuration: keyboardDuration) {
                self.view.frame = CGRect(x: 0, y: -keyboardHeight / 2.5, width: self.view.frame.width, height: self.view.frame.height)
            }
        }
        keyboardIsVisible = true
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: keyboardDuration) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
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

extension AccountController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        dismissView.isHidden = false
        setupKeyboardObserver(on: self)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissView.isHidden = true
        isValidtextFields()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.tag == 0 {
            if isValidEmail(string: textField.text!) {
                playVerifiedAnimation(on: emailVerifiedAnimation)
            } else {
                hideVerifiedAnimation(on: emailVerifiedAnimation)
            }
        } else if textField.tag == 1 {
            if isValidPassword(string: textField.text!) {
                playVerifiedAnimation(on: passwordVerifiedAnimation)
            } else {
                hideVerifiedAnimation(on: passwordVerifiedAnimation)
            }
        }
        isValidtextFields()
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = divider.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}
