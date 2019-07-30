//
//  InAppPurchaseHeader.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-14.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

protocol InAppPurchaseFooterDelegate {
    func openTerms(URL: URL)
}

class InAppPurchaseHeader: UICollectionReusableView, UITextViewDelegate {
    
    var delegate: InAppPurchaseFooterDelegate?
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 36)!
        lbl.numberOfLines = 2
        lbl.text = "Become a\nRoyal User"
        lbl.textColor = .white
        
        return lbl
    }()
    
    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    lazy var termsTextView: UITextView = {
        let terms = UITextView()
        terms.text = "For mor information, please visit our\nPrivacy Policy and Terms & Conditions."
        terms.font = UIFont(name: SansationLight, size: 12)!
        terms.textColor = .darkGray
        terms.textAlignment = .center
        terms.isEditable = false
        terms.delegate = self
        terms.backgroundColor = .clear
        
        return terms
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.openTerms(URL: URL)
        return false
    }
    
    func setupHeader() {
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont(name: SansationRegular, size: 16)!
        descriptionLabel.text = "As a Royal User, you will unlock the whole app and all features as of this moment and all features to come. Scroll down to see all features you’ll unlock. *Scroll down to the bottom to see purchasing detail"
        
        [titleLabel, descriptionLabel].forEach { addSubview($0) }
        _ = titleLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 80, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = descriptionLabel.anchor(titleLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    
    func setupFooter() {
        descriptionLabel.textColor = .darkGray
        descriptionLabel.font = UIFont(name: SansationLight, size: 16)!
        descriptionLabel.text = "*You can subscribe and pay through your iTunes account. Your subscription will automatically renew unless canceled at least 24 hours before the end of the current period. Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user’s Account Settings after purchase."
        
        let linkedText = NSMutableAttributedString(attributedString: termsTextView.attributedText)
        let privacylinked = linkedText.setAsLink(textToFind: "Privacy Policy", linkURL: PRIVACY_POLICY)
        let termsLinked = linkedText.setAsLink(textToFind: "Terms & Conditions", linkURL: TERMS_CONDITIONS)
        
        if privacylinked && termsLinked {
            termsTextView.attributedText = NSAttributedString(attributedString: linkedText)
        }
        
        addSubview(descriptionLabel)
        addSubview(termsTextView)
        _ = descriptionLabel.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = termsTextView.anchor(descriptionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 35)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
