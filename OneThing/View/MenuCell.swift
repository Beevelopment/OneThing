//
//  MenuCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-10.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import DeviceKit

class MenuCell: UICollectionViewCell {
    
    var menu: MenuModel? {
        didSet {
            menuLabel.text = menu?.titel
            if let imageName = menu?.image {
                imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
                _ = menuLabel.anchor(container.topAnchor, left: imageView.rightAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
            } else {
                imageView.image = UIImage()
                _ = menuLabel.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            }
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
    
    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.tintColor = yellow
        
        return imgView
    }()
    
    let menuLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.removeFromSuperview()
        menuLabel.removeFromSuperview()
    }
    
    private func setupColors() {
        backgroundColor = Theme.currentTheme.backgroundColor
        container.backgroundColor = Theme.currentTheme.backgroundColor
        container.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
        menuLabel.textColor = Theme.currentTheme.mainTextColor
    }
    
    func setupCell(menuModel: MenuModel) {
        setupColors()
        
        menuLabel.text = menuModel.titel
        if let imageName = menuModel.image {
            imageView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        }
        
        addSubview(container)
        [imageView, menuLabel].forEach { container.addSubview($0) }
        _ = container.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        if Device.current.isPad {
            _ = imageView.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width / 12, heightConstant: 0)
        } else {
            _ = imageView.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: nil, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width / 6, heightConstant: 0)
        }
    
        _ = menuLabel.anchor(container.topAnchor, left: imageView.rightAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        if menuModel.titel == Menu.cancel.rawValue {
            imageView.image = UIImage()
            _ = menuLabel.anchor(container.topAnchor, left: container.leftAnchor, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
