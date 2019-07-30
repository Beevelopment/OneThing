//
//  PurchaseManager.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-11.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import SwiftyStoreKit

class PurchaseManager: NSObject {
    static let instance = PurchaseManager()
    
    lazy var animation: Animations = {
        let ani = Animations()
        ani.purchaseManager = self
        
        return ani
    }()
    
    let sharedSecret = "cf881101241a418d9bb94dc68f8cc5ff"
    static var isRoyal = false
    
    let IAPs = ["com.hc.OneThing.FullAccess.MonthlySubscription", "com.hc.OneThing.FullAccess.HalfYearSubscription", "com.hc.OneThing.FullAccess.AnualSubscription"]
    var inAppPurchases = [InAppPurchaseModel]()
    
    func setRoyalUserToTrue() {
        PurchaseManager.isRoyal = true
        let name = Notification.Name(isRoyalNotificationName)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func setupIAP() {
        animation.beginLoadingAnimation(animation: .loading)
        completeTransactions()
        verifyAllProducts()
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
    }
    
    func retriveProductInfo() {
        for IAP in IAPs {
            SwiftyStoreKit.retrieveProductsInfo([IAP]) { result in
                if let product = result.retrievedProducts.first {
                    
                    let productIdentifier = product.productIdentifier
                    let priceString = product.localizedPrice!
                    let price = product.price
                    var perMonth = 0.0
                    
                    if productIdentifier == self.IAPs[0] {
                        let productInfo = InAppPurchaseModel(priceText: priceString, perMonth: "", productID: productIdentifier, priceForIndex: price.intValue)
                        self.inAppPurchases.append(productInfo)
                    } else if productIdentifier == self.IAPs[1] {
                        perMonth = Double(price.intValue / 6)
                        
                        let productInfo = InAppPurchaseModel(priceText: priceString, perMonth: numberFormatter(number: perMonth, style: .currency), productID: productIdentifier, priceForIndex: price.intValue)
                        self.inAppPurchases.append(productInfo)
                    } else if productIdentifier == self.IAPs[2] {
                        perMonth = Double(price.intValue / 12)
                        
                        let productInfo = InAppPurchaseModel(priceText: priceString, perMonth: numberFormatter(number: perMonth, style: .currency), productID: productIdentifier, priceForIndex: price.intValue)
                        self.inAppPurchases.append(productInfo)
                    }
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    print("Carl: Invalid product identifier: \(invalidProductId)")
                }
                else {
                    print("Carl: Error: \(String(describing: result.error))")
                }
            }
        }
    }
    
    func verifyAllProducts() {
        for IAP in IAPs {
            verifySubscriptions(with: IAP) { (true) in
            }
        }
    }
    
    func verifySubscriptions(with id: String, onCompletion: @escaping CompletionHandler) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = id
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    self.setRoyalUserToTrue()
                    onCompletion(true)
                    print("Carl: \(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("Carl: \(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("Carl: The user has never purchased \(productId)")
                }
            case .error(let error):
                print("Carl: Receipt verification failed: \(error)")
            }
            self.animation.finishLoadingAnimation(animation: .loading)
        }
    }
    
    func subscribe(with id: String, onCompletion: @escaping CompletionHandler) {
        SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                self.verifySubscriptions(with: id, onCompletion: { (bool) in
                    if bool {
                        onCompletion(bool)
                    } else {
                        onCompletion(bool)
                    }
                })
            } else {
                onCompletion(false)
            }
        }
    }
    
    func restorePurchases() {
        animation.beginLoadingAnimation(animation: .loading)
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Carl: Restore Failed: \(results.restoreFailedPurchases)")
                self.animation.finishLoadingAnimation(animation: .loading)
            }
            else if results.restoredPurchases.count > 0 {
                print("Carl: Restore Success: \(results.restoredPurchases)")
                self.animation.finishLoadingAnimation(animation: .loading)
            }
            else {
                print("Carl: Nothing to Restore")
                self.animation.finishLoadingAnimation(animation: .loading)
            }
        }
    }
}
