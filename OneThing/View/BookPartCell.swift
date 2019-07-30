//
//  BookPartCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-08.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import DeviceKit

class BookPartCell: UITableViewCell {
    
    let container: UIView = {
        let con = UIView()
        con.backgroundColor = .white
        con.layer.cornerRadius = 15
        con.layer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        con.layer.shadowOpacity = 0.15
        con.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        con.layer.shadowRadius = 5
        
        return con
    }()
    
    let title: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        lbl.textColor = .black
        lbl.adjustsFontSizeToFitWidth = true
        
        return lbl
    }()
    
    let subtitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textColor = .lightGray
        lbl.adjustsFontSizeToFitWidth = true
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    let shapeLayerContainer = UIView()
    
    let progresShapeLayer = CAShapeLayer()
    let holdShapeLayer = CAShapeLayer()
    
    let indexData = ["introduction", "partOne", "partTwo", "partThree", "extra"]
    var completedLessons: CGFloat = 0.0
    var content = [ContentModel]()
    var uid: String!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addShapeLayer(shapeLayer: holdShapeLayer, strokColor: divider, trackLayer: true)
        addShapeLayer(shapeLayer: progresShapeLayer, strokColor: yellow, trackLayer: false)
    }
    
    private func getUserData(index: Int) {
        database.collection("users").document(uid).collection("education").document("\(indexData[index])").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                self.completedLessons = 0.0
                if let documentData = querySnapshot?.data() {
                    if let document = documentData["completed"] as? Dictionary<String, String> {
                        for doc in document {
                            if doc.value == "true" {
                                self.completedLessons += 1.0
                            }
                        }
                        self.updateProgressCircle()
                    }
                }
            }
        }
    }
    
    private func updateProgressCircle() {
        let keyPath = "strokeEnd"
        let basicAnimation = CABasicAnimation(keyPath: keyPath)
        
        let procent: CGFloat = completedLessons / CGFloat(content.count)
        
        basicAnimation.fromValue = 0
        basicAnimation.toValue = procent / 1.25
        basicAnimation.duration = 2.0
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        let basicKey = "basicKey"
        progresShapeLayer.add(basicAnimation, forKey: basicKey)
    }
    
    private func addShapeLayer(shapeLayer: CAShapeLayer, strokColor: UIColor, trackLayer: Bool) {
        let arcCenter = CGPoint(x: frame.width / 9, y: frame.height * 1.2)
        let radius = frame.height / 2
        let twelveAClock: CGFloat = -(.pi / 2)
        let circularPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: twelveAClock, endAngle: .pi * 2, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = strokColor.cgColor
        shapeLayer.lineWidth = radius / 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        
        if !trackLayer {
            shapeLayer.strokeEnd = 0
        }
        
        shapeLayerContainer.layer.addSublayer(shapeLayer)
    }
    
    private func setupColors() {
        backgroundColor = Theme.currentTheme.backgroundColor
        title.textColor = Theme.currentTheme.mainTextColor
        subtitle.textColor = Theme.currentTheme.subTextColor
        container.backgroundColor = Theme.currentTheme.backgroundColor
        container.layer.shadowColor = Theme.currentTheme.shadowColor.cgColor
    }
    
    func setupView(bookModel: BookModel) {
        setupColors()
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        getUserData(index: Int(bookModel.index)!)
        content = bookModel.content
        title.text = bookModel.maintitle
        subtitle.text = bookModel.subtitle
        
        addSubview(container)
        [title, subtitle, shapeLayerContainer].forEach { container.addSubview($0) }
        
        _ = container.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 10, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        
        if bookModel.subtitle == "" {
            _ = title.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: shapeLayerContainer.leftAnchor, topConstant: 31.5, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            _ = title.anchor(container.topAnchor, left: container.leftAnchor, bottom: nil, right: shapeLayerContainer.leftAnchor, topConstant: frame.height / 6, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        _ = subtitle.anchor(title.bottomAnchor, left: container.leftAnchor, bottom: nil, right: shapeLayerContainer.leftAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        if Device.current.isPad {
            _ = shapeLayerContainer.anchor(container.topAnchor, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width / 10, heightConstant: frame.height - 20)
        } else if Device.current.isOneOf(groupOfSmalliPhones) {
            _ = shapeLayerContainer.anchor(container.topAnchor, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width / 4.5, heightConstant: frame.height - 20)
        } else {
            _ = shapeLayerContainer.anchor(container.topAnchor, left: nil, bottom: container.bottomAnchor, right: container.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width / 5, heightConstant: frame.height - 20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
