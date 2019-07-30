//
//  MenuLauncher.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-10.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class MenuLauncher: NSObject, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var mainViewController: MainViewController?
    
    let blackView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bv.alpha = 0
        
        return bv
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8)
        cv.layer.cornerRadius = 16
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    let menuSelection: [MenuModel] = {
        let walkThrough = MenuModel(image: "book-open", titel: "Walkthrough")
        let royalUser = MenuModel(image: "award", titel: "Royal User")
        let shareApp = MenuModel(image: "heart", titel: "Share App")
        let darkMode = MenuModel(image: "moon", titel: "Dark Mode")
        let setting = MenuModel(image: "settings", titel: "Settings")
        let cancel = MenuModel(titel: "Cancel")
        
        let menus = [walkThrough, royalUser, shareApp, darkMode, setting, cancel]
        return menus
    }()
    
    let menuCellID = "menuCellID"
    
    func showMenu() {
        setupLauncher()
        animateIn()
    }
    
    private func animateIn() {
        let height = Int(menuSelection.count / 2) * 60 + 90
        
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 1
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height - CGFloat(height), width: window.frame.width, height: CGFloat(height))
            }, completion: nil)
        }
    }
    
    func animateOut() {
        let height = Int(menuSelection.count / 2) * 60 + 90
        
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackView.alpha = 0
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: CGFloat(height))
            }) { (true) in
                self.removeFromSuperView()
            }
        }
    }
    
    private func removeFromSuperView() {
        collectionView.removeFromSuperview()
        blackView.removeFromSuperview()
    }
    
    private func setupColors() {
        collectionView.backgroundColor = Theme.currentTheme.backgroundColor
        collectionView.reloadData()
    }
    
    private func setupLauncher() {
        setupColors()
        if let window = UIApplication.shared.keyWindow {
            let height = Int(menuSelection.count / 2) * 60 + 90
            
            collectionView.register(MenuCell.self, forCellWithReuseIdentifier: menuCellID)
            [blackView, collectionView].forEach { window.addSubview($0) }
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: CGFloat(height))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = menuSelection[indexPath.item]
        Menu.allCases.forEach {
            if $0.rawValue == selectedCell.titel {
                animateOut()
                mainViewController?.handelMenuButtons(selectedCell: $0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuSelection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuChoice = menuSelection[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuCellID, for: indexPath) as? MenuCell {
            cell.setupCell(menuModel: menuChoice)
            return cell
        } else {
            return MenuCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - 16, height: 60)
    }
}
