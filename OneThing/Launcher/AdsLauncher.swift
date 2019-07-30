//
//  AdsLauncher.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-21.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsLauncher: NSObject, GADBannerViewDelegate, GADInterstitialDelegate {
    
    var mainViewController: MainViewController?
    var inAppPurchaseController: InAppPurchaseController?
    var mainCollectionViewCell: MainCollectionViewCell?
    var readController: ReadController?
    
    var bannerView = GADBannerView()
    var bannerViewBackground = UIView()
    
    var interstitial = GADInterstitial()
    
    func shouldAdsShow() {
        print("Carl: shouldadsshow run")
        if PurchaseManager.isRoyal {
            bannerView.isHidden = true
            bannerViewBackground.isHidden = true
        }
    }
    
    func setupAds() {
        if let window = UIApplication.shared.keyWindow {
            if !PurchaseManager.isRoyal {
                bannerView.adSize = kGADAdSizeBanner
                bannerViewBackground.backgroundColor = Theme.currentTheme.backgroundColor
                [bannerViewBackground, bannerView].forEach { window.addSubview($0) }
                _ = bannerView.anchor(nil, left: window.leftAnchor, bottom: window.safeAreaLayoutGuide.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
                _ = bannerViewBackground.anchor(bannerView.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
                
                if let uid = userUid as? String {
                    if adminUid == uid {
                        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                    } else {
                        bannerView.adUnitID = "ca-app-pub-6662079405759550/4820499187"
                    }
                } else {
                    bannerView.adUnitID = "ca-app-pub-6662079405759550/4820499187"
                }
                
                bannerView.rootViewController = mainViewController
                bannerView.load(GADRequest())
                bannerView.delegate = self
            } else {
                shouldAdsShow()
            }
        }
    }
    
    func setupInterstitialAd() -> GADInterstitial {
        if let uid = userUid as? String {
            if adminUid == uid {
                interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            } else {
                interstitial = GADInterstitial(adUnitID: "ca-app-pub-6662079405759550/9282250697")
            }
        } else {
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-6662079405759550/9282250697")
        }
        
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func presentInterstitialAd() {
        interstitial = setupInterstitialAd()
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Carl: interstitialDidReceiveAd")
        if interstitial.isReady {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                interstitial.present(fromRootViewController: rootViewController)
            } else {
                print("Carl: Error with rootviewcontroller")
            }
        } else {
            print("Carl: Ad was not ready")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("Carl: interstitialDidDismissScreen")
        
    }
}
