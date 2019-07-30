//
//  Animation.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-02.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Lottie

class Animations: NSObject {
    
    var mainViewController: MainViewController?
    var categoryLauncer: CategoryLauncher?
    var mainCollectionViewCell: MainCollectionViewCell?
    var readController: ReadController?
    var purchaseManager: PurchaseManager?
    var purchaseCell: PurchaseCell?
    var feedbackLauncher: FeedbackLuncher?
    
    let loadingAnimation: AnimationView = {
        let ani = AnimationView(name: "loading")
        ani.loopMode = .loop
        ani.alpha = 0
        
        return ani
    }()
    
    let doneAnimation: AnimationView = {
        let ani = AnimationView(name: "done")
        ani.alpha = 0
        
        return ani
    }()
    
    let sccessAnimation: AnimationView = {
        let ani = AnimationView(name: "success")
        ani.alpha = 0
        
        return ani
    }()
    
    var animator: UIViewPropertyAnimator!
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    func beginLoadingAnimation(animation: AnimationName) {
        setupBlurVisual(animation: animation)
    }
    
    func finishLoadingAnimation(animation: AnimationName) {
        let ani = [loadingAnimation, doneAnimation, sccessAnimation]
        
        if ani[animation.rawValue].isAnimationPlaying {
            UIView.animate(withDuration: 0.5, animations: {
                ani[animation.rawValue].alpha = 0
            })
            
            if let window = UIApplication.shared.keyWindow {
                UIView.transition(with: window, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                    self.visualEffectView.removeFromSuperview()
                }, completion: nil)
            }
            
            ani[animation.rawValue].stop()
        }
    }
    
    func setupBlurVisual(animation: AnimationName) {
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: { [weak self] in
            if let window = UIApplication.shared.keyWindow {
                window.addSubview(self!.visualEffectView)
                _ = self!.visualEffectView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            }

        })
        animator.startAnimation()
        setupLoadingLottie(animation: animation)
    }
    
    func setupLoadingLottie(animation: AnimationName) {
        let ani = [loadingAnimation, doneAnimation, sccessAnimation]
        
        if let window = UIApplication.shared.keyWindow {
            let verticalMargin = window.frame.height / 10
            
            window.addSubview(ani[animation.rawValue])
            
            if animation == AnimationName.success {
                _ = ani[animation.rawValue].anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            } else {
                _ = ani[animation.rawValue].anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: verticalMargin * 4.5, leftConstant: 0, bottomConstant: verticalMargin * 4.5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            }
        }
        
        UIView.animate(withDuration: 1) {
            ani[animation.rawValue].alpha = 1
        }
        ani[animation.rawValue].play()
    }
}

