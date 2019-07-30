//
//  ArchiveTableViewCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-30.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class ArchiveTableViewCell: UITableViewCell {
    
    let dateLable: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 12)!
        
        return lbl
    }()
    
    let insetTextView: UITextView = {
        let txtView = UITextView()
        txtView.font = UIFont(name: SansationRegular, size: 16)!
        txtView.isEditable = false
        
        return txtView
    }()
    
    let doneImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        img.tintColor = yellow
        img.contentMode = .scaleAspectFit
        
        return img
    }()
    
    let visualEffectView: UIVisualEffectView = {
        let vision = UIVisualEffectView()
        vision.effect = UIBlurEffect(style: .light)
        vision.layer.cornerRadius = 8
        vision.clipsToBounds = true
        vision.isHidden = true
        
        return vision
    }()
    
    let lockImage: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)
        img.tintColor = yellow
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        
        return img
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    private func setupColors() {
        backgroundColor = Theme.currentTheme.backgroundColor
        insetTextView.backgroundColor = Theme.currentTheme.backgroundColor
        insetTextView.textColor = Theme.currentTheme.mainTextColor
        dateLable.textColor = Theme.currentTheme.subTextColor
    }
    
    func setupCell(archiveData: ArchiveModel, shouldBeBlur: Bool) {
        setupColors()
        insetTextView.text = archiveData.text
        
        if let timestampDouble = Double(archiveData.timestamp) {
            let date = Date(timeIntervalSince1970: timestampDouble)
            dateLable.text = timestampToReadableData(date: date)
        }
        
        if archiveData.completed == "true" {
            doneImage.tintColor = yellow
        } else {
            doneImage.tintColor = divider
        }
        
        if shouldBeBlur {
            visualEffectView.isHidden = false
            lockImage.isHidden = false
        } else {
            visualEffectView.isHidden = true
            lockImage.isHidden = true
        }
        
        [dateLable, insetTextView, doneImage, visualEffectView, lockImage].forEach { addSubview($0) }
        _ = dateLable.anchor(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 5, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 14)
        _ = insetTextView.anchor(dateLable.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: doneImage.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: insetTextView.text.height(withConstrainedWidth: frame.width - 40, font: UIFont(name: SansationRegular, size: 16)!))
        _ = doneImage.anchor(topAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = visualEffectView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 5, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = lockImage.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 10, leftConstant: 0, bottomConstant: 15, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
