//
//  PriceCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-11.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class PriceCell: UICollectionViewCell {
    
    var iap: InAppPurchaseModel? {
        didSet {
            priceLabel.text = iap?.priceText
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
    
    let priceLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 21)!
        lbl.textAlignment = .center
        lbl.textColor = yellow
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
//    let perMonthLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.font = UIFont(name: SansationRegular, size: 14)!
//        lbl.textAlignment = .center
//        lbl.textColor = yellow
//        lbl.text = "per month"
//
//        return lbl
//    }()
    
    let billingLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 12)!
        lbl.textAlignment = .center
        lbl.textColor = .black

        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    private func setupColors() {
        container.backgroundColor = Theme.currentTheme.backgroundColor
        container.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
    }
    
    func setupCell(iap: InAppPurchaseModel) {
        setupColors()
        
        if iap.productID == PurchaseManager.instance.IAPs[0] {
            priceLabel.text = iap.priceText + " / Month"
            billingLabel.text = ""
        } else if iap.productID == PurchaseManager.instance.IAPs[1] {
            priceLabel.text = iap.priceText + " / 6 Month"
            billingLabel.text = "(6 months at \(iap.perMonth)/mo. Save 25%"
        } else if iap.productID == PurchaseManager.instance.IAPs[2] {
            priceLabel.text = iap.priceText + " / Year"
            billingLabel.text = "(12 months at \(iap.perMonth)/mo. Save 50%"
        }
        
        addSubview(container)
        container.addSubview(priceLabel)
        addSubview(billingLabel)
        
        _ = container.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
        _ = priceLabel.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 21)
        _ = billingLabel.anchor(container.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
