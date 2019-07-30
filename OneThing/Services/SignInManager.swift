//
//  SignInManager.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-15.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import TwitterKit

class SignInManager: NSObject {
    static let instance = SignInManager()
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.signInManager = self

        return msg
    }()
    
    var credentials: AuthCredential?
    var accountController: AccountController?
    
    func emailSingIn(email: String, password: String, onCompletion: @escaping CompletionHandler) {
        credentials = EmailAuthProvider.credential(withEmail: email, password: password)
        authenticateWithFirebase(onCompletion: onCompletion)
    }
    
    func googleSignIn() {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func facebookSignIn(onCompletion: @escaping CompletionHandler) {
        let readPremission: [Permission] = [.publicProfile, .email]
        let loginManager = LoginManager()
        loginManager.logIn(permissions: readPremission, viewController: AccountController()) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
                self.messagePopUp.errorMessage(message: "Something went wrong with your Facebook authentication. Please try again.", onCompletion: { (bool) in
                })
            case .cancelled:
                print("Carl: User cancelled login.")
            case .success( _, _, let accessToken):
                let tokenString = accessToken.tokenString
                self.credentials = FacebookAuthProvider.credential(withAccessToken: tokenString)
                self.authenticateWithFirebase(onCompletion: onCompletion)
            }
        }
    }
    
    func twitterSingIn(onCompletion: @escaping CompletionHandler) {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if let session = session {
                let accessToken = session.authToken
                let accessSecretToken = session.authTokenSecret
                self.credentials = TwitterAuthProvider.credential(withToken: accessToken, secret: accessSecretToken)
                self.authenticateWithFirebase(onCompletion: onCompletion)
            } else {
                if let error = error as? TWTRErrorCode {
                    print("Carl: tWTR error: \(error)")
                }
                print("Carl: error: \(error!.localizedDescription)")
                self.messagePopUp.errorMessage(message: "Something went wrong with your Twitter authentication. Please try again.", onCompletion: { (bool) in
                })
            }
        })
    }
    
    let defaultGroup = UserDefaults(suiteName: "group.com.hc.onethingwidget")!
    
    func authenticateWithFirebase(onCompletion: @escaping CompletionHandler) {
        guard let credential = credentials else { return }
        Auth.auth().currentUser?.link(with: credential, completion: { (authResult, error) in
            if let error = error {
                self.handleFirebaseError(error: error as NSError, onCompletion: onCompletion)
            } else {
//                guard let user = authResult?.user else { return }
                
//                user.getIDToken(completion: { (tokenString, err) in
//                    if let err = err {
//                        print("Carl: Error -> \(err.localizedDescription)")
//                    } else {
//                        if let token = tokenString {
//                            self.defaultGroup.set(token, forKey: "FirebaseAuthToken")
//                            self.defaultGroup.synchronize()
//                        }
//                    }
//                })
                
                print("Carl: Successfully linked")
                onCompletion(true)
            }
        })
    }
    
    private func signInUser(onCompletion: @escaping CompletionHandler) {
        guard let credential = credentials else { return }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Carl: error: \(error.localizedDescription)")
                self.messagePopUp.errorMessage(message: "Something went wrong with the sign in. Please try again.", onCompletion: { (bool) in
                })
            } else {
                print("Carl: Successfully signed in")
                guard let user = authResult?.user else { return }
                
//                user.getIDTokenResult(completion: { (tokenString, err) in
//                    if let err = err {
//                        print("Carl: Error -> \(err.localizedDescription)")
//                    } else {
//                        if let token = tokenString {
//                            self.defaultGroup.set(token, forKey: "FirebaseAuthToken")
//                            self.defaultGroup.synchronize()
//                        }
//                    }
//                })
                
//                user.getIDToken(completion: { (tokenString, err) in
//                    if let err = err {
//                        print("Carl: Error -> \(err.localizedDescription)")
//                    } else {
//                        if let token = tokenString {
//                            self.defaultGroup.set(token, forKey: "FirebaseAuthToken")
//                            self.defaultGroup.synchronize()
//                        }
//                    }
//                })
                
                let userUid = user.uid
                UserDefaults.standard.set(userUid, forKey: "uid")
                WalkthroughCell.newUser = userUid
                onCompletion(true)
            }
        }
    }
    
    private func handleFirebaseError(error: NSError, onCompletion: @escaping CompletionHandler) {
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            print("Carl: ErrorCode", errorCode)
            switch errorCode {
            case .credentialAlreadyInUse:
                print("Carl: credentialsAlreadyInUse")
                signInUser(onCompletion: onCompletion)
                break
            case .requiresRecentLogin:
                messagePopUp.errorMessage(message: "You need to verify yourself first by sign in using one of your previous authentication methods before you can add another one.", onCompletion: { (bool) in
                })
                print("Carl: requiresRecentLogin")
                break
            default:
                print("Carl: defalut error \(errorCode.rawValue)")
                messagePopUp.errorMessage(message: "Something went wrong with the authentication. Please try again.", onCompletion: { (bool) in
                })
            }
        }
    }
}
