//
//  CategoriesCarouselCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-30.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class CategoriesCarouselCell: UICollectionViewCell {
    
    var category: CategoriesCarouselModel? {
        didSet {
            guard let category = category else { return }
            categoryLabel.text = category.category
            containerView.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
            setupBlur()
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Theme.currentTheme.backgroundColor
        view.layer.cornerRadius = 20
        view.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
        view.layer.shadowOpacity = 0.075
        view.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        view.layer.shadowRadius = 5
        
        return view
    }()
    
    let categoryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 21)!
        lbl.textColor = yellow
        lbl.textAlignment = .center
        
        return lbl
    }()
    
    let deleteButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "x-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .lightGray
        btn.isHidden = true
        
        return btn
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let vision = UIVisualEffectView()
        vision.effect = UIBlurEffect(style: .regular)
        vision.alpha = 0.8
        vision.layer.cornerRadius = 20
        vision.clipsToBounds = true
        
        return vision
    }()
    
    let lockImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)
        img.tintColor = yellow
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    override var isSelected: Bool {
        didSet {
            containerView.backgroundColor = isSelected ? yellow : Theme.currentTheme.backgroundColor
            categoryLabel.textColor = isSelected ? .white : yellow
            if PurchaseManager.isRoyal {
                visualEffectView.isHidden = isSelected ? true : true
                lockImage.isHidden = isSelected ? true : true
            } else {
                visualEffectView.isHidden = isSelected ? true : false
                lockImage.isHidden = isSelected ? true : false
            }
        }
    }
    
    func isWiggling(isWiggling: Bool) {
        if !isWiggling {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
        }
    }
    
    private func setupBlur() {
        if !isSelected {
            if PurchaseManager.isRoyal {
                visualEffectView.isHidden = true
                lockImage.isHidden = true
            } else {
                visualEffectView.isHidden = false
                lockImage.isHidden = false
            }
        }
    }
    
    func setupCell() {
        addSubview(containerView)
        _ = containerView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        [categoryLabel, deleteButton, visualEffectView, lockImage].forEach { containerView.addSubview($0) }
        _ = categoryLabel.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = deleteButton.anchor(containerView.topAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: -5, leftConstant: 0, bottomConstant: 0, rightConstant: -5, widthConstant: 20, heightConstant: 20)
        _ = visualEffectView.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)
        _ = lockImage.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 35, heightConstant: 35)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
