//
//  InAppPurchaseController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-11.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import SafariServices

class InAppPurchaseController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var accountController: AccountController?
    
    lazy var adsLauncher: AdsLauncher = {
        let ads = AdsLauncher()
        ads.inAppPurchaseController = self
        
        return ads
    }()
    
    let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "x-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        btn.tintColor = .white
        
        return btn
    }()
    
    let restoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Restore purchase", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationLight, size: 14)!
        btn.addTarget(self, action: #selector(restorePurchasesButton), for: .touchUpInside)
        btn.setTitleColor(.white, for: .normal)
        
        return btn
    }()
    
    let viewTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Become a Royal User"
        lbl.numberOfLines = 2
        lbl.font = UIFont(name: SansationBold, size: 36)!
        
        return lbl
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = false
        
        return cv
    }()
    
    let features: [FeaturesModel] = {
        let darkMode = FeaturesModel(imageName: "moon", title: "Unlock dark mode")
        let categories = FeaturesModel(imageName: "menu", title: "Unlock unlimited categories and create categories just for you.")
        let archive = FeaturesModel(imageName: "folder", title: "Unlock all your old OneThings within every category")
        let noAds = FeaturesModel(imageName: "ads", title: "Disable all advertising within the app")
        let sync = FeaturesModel(imageName: "smartphone", title: "Sync your OneThings to all your iOS devices by creating an account.")
//        let watch = FeaturesModel(imageName: "watch", title: "Unlock the Apple Watch app where you can see and edit your OneThings")
//        let widget = FeaturesModel(imageName: "checkmark", title: "Unlock the OneThing widget for a quick look and mark as done")
        let neaFeatures = FeaturesModel(imageName: "code", title: "Unlock every upcoming feature within app")
        let developer = FeaturesModel(imageName: "heart", title: "Support an indie developer and keep the servers running")
        
        var featursArray = [darkMode, categories, archive, noAds, sync, neaFeatures, developer]
        
        return featursArray
    }()

    let headerID = "headerID"
    let purchaseCellID = "purchaseCellID"
    let featureCellTitle = "featureCellTitle"
    let featureCellID = "featureCellID"
    let footerID = "footerID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors(size: CGSize(width: view.bounds.width, height: view.bounds.height))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            setupColors(size: size)
            print("Carl: Landscape")
        } else if UIDevice.current.orientation.isPortrait {
            print("Carl: Portrait")
        }
    }
    
    private func registerCells() {
        collectionView.register(InAppPurchaseHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView.register(InAppPurchaseHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerID)
        collectionView.register(PurchaseCell.self, forCellWithReuseIdentifier: purchaseCellID)
        collectionView.register(FeatureCellTitle.self, forCellWithReuseIdentifier: featureCellTitle)
        collectionView.register(FeatureCell.self, forCellWithReuseIdentifier: featureCellID)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerID, for: indexPath) as? InAppPurchaseHeader {
                header.setupHeader()
                return header
            }
        } else if kind == UICollectionView.elementKindSectionFooter {
            if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerID, for: indexPath) as? InAppPurchaseHeader {
                footer.setupFooter()
                footer.delegate = self
                return footer
            }
        }
        return InAppPurchaseHeader()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 290)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return features.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 || indexPath.item == features.count + 1 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: purchaseCellID, for: indexPath) as? PurchaseCell {
                cell.delegate = self
                return cell
            }
        } else if indexPath.item == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featureCellTitle, for: indexPath) as! FeatureCellTitle
            return cell
        } else {
            let featureCell = features[indexPath.item - 1]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: featureCellID, for: indexPath) as? FeatureCell {
                cell.feature = featureCell
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 || indexPath.item == features.count + 1 {
            return CGSize(width: collectionView.frame.width, height: 294)
        } else if indexPath.item == 1 {
            return CGSize(width: collectionView.frame.width, height: 40)
        } else {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
    }
    
    @objc private func restorePurchasesButton() {
        PurchaseManager.instance.restorePurchases()
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true) {
            if !PurchaseManager.isRoyal {
                self.adsLauncher.presentInterstitialAd()
            }
        }
    }
    
    private func showAccountController() {
        weak var pvc = self.presentingViewController
        dismiss(animated: true) {
            let accountController = AccountController()
            pvc?.present(accountController, animated: true, completion: nil)
        }
    }
    
    private func setupColors(size: CGSize) {
        if Theme.isDarkMode {
            gradientColor(colorOne: Theme.currentTheme.backgroundColor, colorTwo: .white, size: size)
        } else {
            gradientColor(colorOne: yellow, colorTwo: .white, size: size)
        }
        collectionView.reloadData()
    }
    
    private func setupView() {
        [collectionView, closeButton, restoreButton].forEach { view.addSubview($0) }
        _ = collectionView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = closeButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = restoreButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
    }
    
    func gradientColor(colorOne: UIColor, colorTwo: UIColor, size: CGSize) {
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.5)
        
        let backgroundView = UIView(frame: frame)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        collectionView.backgroundView = backgroundView
    }
    
    func openUrl(URL: URL) {
        let safariVC = SFSafariViewController(url: URL)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
}

extension InAppPurchaseController: PurchaseCellDelegate, InAppPurchaseFooterDelegate, SFSafariViewControllerDelegate {
    func dismissIAPController(purchaseComplete: Bool) {
        if !purchaseComplete {
            adsLauncher.shouldAdsShow()
            dismissViewController()
        } else {
            adsLauncher.shouldAdsShow()
            showAccountController()
        }
    }
    
    func openTerms(URL: URL) {
            openUrl(URL: URL)
    }
}
