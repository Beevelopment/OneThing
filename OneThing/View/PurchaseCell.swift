//
//  PurchaseCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-14.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

protocol PurchaseCellDelegate {
    func dismissIAPController(purchaseComplete: Bool)
}

class PurchaseCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var delegate: PurchaseCellDelegate?
    
    lazy var animations: Animations = {
        let ani = Animations()
        ani.purchaseCell = self
        
        return ani
    }()
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.purchaseCell = self
        
        return msg
    }()
    
    let title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        lbl.text = "Subscribe Now"
        lbl.textColor = .white
        
        return lbl
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        return cv
    }()
    
    let priceCellID = "priceCellID"
    
    let purchases: [InAppPurchaseModel] = {
        let inAppPurchases = PurchaseManager.instance.inAppPurchases.sorted(by: {$0.priceForIndex! > $1.priceForIndex! })
        
        let annually = InAppPurchaseModel(priceText: inAppPurchases[0].priceText, perMonth: inAppPurchases[0].perMonth, productID: inAppPurchases[0].productID)
        let helfYear = InAppPurchaseModel(priceText: inAppPurchases[1].priceText, perMonth: inAppPurchases[1].perMonth, productID: inAppPurchases[1].productID)
        let monthly = InAppPurchaseModel(priceText: inAppPurchases[2].priceText, perMonth: inAppPurchases[2].perMonth, productID: inAppPurchases[2].productID)
        
        let array = [annually, helfYear, monthly]
        
        return array
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.register(PriceCell.self, forCellWithReuseIdentifier: priceCellID)
        setupCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return purchases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let priceCell = purchases[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: priceCellID, for: indexPath) as? PriceCell {
            cell.setupCell(iap: priceCell)
            return cell
        }
        return PriceCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 80)
//        return CGSize(width: collectionView.frame.width / 3 - 8, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = purchases[indexPath.item]
        makePurchase(id: product.productID)
    }
    
    private func makePurchase(id: String) {
        animations.beginLoadingAnimation(animation: .loading)
        PurchaseManager.instance.subscribe(with: id) { (bool) in
            self.animations.finishLoadingAnimation(animation: .loading)
            if bool {
                if userUid == nil {
                    self.delegate?.dismissIAPController(purchaseComplete: true)
                } else {
                    self.delegate?.dismissIAPController(purchaseComplete: false)
                }
            } else {
                self.messagePopUp.errorMessage(message: "Something went wrong with your purchase. Please try again.", onCompletion: { (bool) in
                })
            }
        }
    }
    
    private func setupCell() {
        [title, collectionView].forEach { addSubview($0) }
        _ = title.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = collectionView.anchor(title.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 240)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
