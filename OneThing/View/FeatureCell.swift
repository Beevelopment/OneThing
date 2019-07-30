//
//  FeatureCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-12.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class FeatureCell: UICollectionViewCell {
    
    var feature: FeaturesModel? {
        didSet {
            title.text = feature?.title
            if let imgName = feature?.imageName {
                imageV.image = UIImage(named: imgName)?.withRenderingMode(.alwaysTemplate)
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
    
    let imageV: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "bell")?.withRenderingMode(.alwaysTemplate)
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = yellow
        
        return imgView
    }()
    
    let title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textColor = yellow
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.text = "Personolized Notifications"
        
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    private func setupColors() {
        container.backgroundColor = Theme.currentTheme.backgroundColor
        container.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
    }
    
    func setupCell() {
        addSubview(container)
        [imageV, title].forEach { container.addSubview($0) }
        _ = container.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 20, bottomConstant: 8, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = imageV.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, topConstant: 25, leftConstant: 10, bottomConstant: 25, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = title.anchor(container.topAnchor, left: imageV.rightAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
