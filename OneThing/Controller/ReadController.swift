//
//  ReadController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-08.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit

class ReadController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    lazy var animation: Animations = {
        let ani = Animations()
        ani.readController = self
        
        return ani
    }()
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.readController = self
        
        return msg
    }()
    
    lazy var adsLauncher: AdsLauncher = {
        let ads = AdsLauncher()
        ads.readController = self
        
        return ads
    }()
    
    let closeButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "x-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        return btn
    }()
    
    let pageController: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textColor = .lightGray
        
        return lbl
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    let button: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Mark as Done", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 16)!
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = yellow
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        return btn
    }()
    
    let disclaimerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "help-circle")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = divider
        btn.addTarget(self, action: #selector(showDisclaimer), for: .touchUpInside)
        
        return btn
    }()
    
    let readCellID = "readCellID"
    let indexData = ["introduction", "partOne", "partTwo", "partThree"]
    var content = [ContentModel]()
    var cell: BookModel?
    var partName: String?
    var key: String?
    var currentIndex: Int = 0
    var lessons: [String: String] = [:]
    var uid: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ReadCell.self, forCellWithReuseIdentifier: readCellID)
    }
    
    @objc private func buttonAction() {
        var bool: String!
        
        if button.backgroundColor == yellow {
            bool = "true"
        } else {
            bool = "false"
        }
        
        let documentData = [
            "completed": [
                "\(currentIndex)": bool
            ]
        ]
        
        guard let index = Int(cell!.index) else { return }
        database.collection("users").document(uid).collection("education").document(indexData[index]).setData(documentData, merge: true) { (err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                self.lessons["\(self.currentIndex)"] = bool
                if self.currentIndex + 1 < self.content.count {
                    self.scrollWithButton()
                } else {
                    self.chapterDone()
                }
            }
        }
    }
    
    private func scrollWithButton() {
        currentIndex += 1
        pageController.text = "\(self.currentIndex + 1)/\(self.content.count)"
        collectionView.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    private func chapterDone() {
        if lessons.count == content.count && !lessons.values.contains("false") {
            animation.beginLoadingAnimation(animation: .success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.66) {
                self.animation.finishLoadingAnimation(animation: .success)
                self.dismissViewController()
            }
        } else {
            dismissViewController()
        }
    }
    
    private func isLessonDone() {
        guard let index = Int(cell!.index) else { return }
        database.collection("users").document(uid).collection("education").document(indexData[index]).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                if let documentData = querySnapshot?.data() {
                    if let document = documentData["completed"] as? Dictionary<String, String> {
                        self.lessons = document
                    }
                    self.checkIfLessenIsDone()
                }
            }
        }
    }
    
    private func checkIfLessenIsDone() {
        if lessons["\(currentIndex)"] == "true" {
            button.backgroundColor = divider
            button.setTitle("Mark as Undone", for: .normal)
        } else {
            button.backgroundColor = yellow
            button.setTitle("Mark as Done", for: .normal)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee.x
        let viewWidth = view.frame.width
        let currentPage: Int = Int(offset / viewWidth)
        currentIndex = currentPage
        
        checkIfLessenIsDone()
        pageController.text = "\(currentIndex + 1)/\(content.count)"
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contet = content[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: readCellID, for: indexPath) as? ReadCell {
            guard let part = partName else { return ReadCell() }
            cell.setupCell(contentModel: contet, part: part)
            return cell
        }
        return ReadCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    @objc private func showDisclaimer() {
        messagePopUp.showGenericMessage(text: "FAIR-USE COPYRIGHT DISCLAIMER\n* Copyright Disclaimer Under Section 107 of the Copyright Act 1976, allowance is made for \"fair use\" for purposes such as criticism, commenting, news reporting, teaching, scholarship, and research. Fair use is a use permitted by copyright statute that might otherwise be infringing. Non-profit, educational or personal use tips the balance in favor of fair use.\n\n1)This text has no negative impact on the original works\n2)This text is also for teaching and inspirational purposes.\n3)It is not transformative in nature.\n\nOneThing: Extraordinary Results does not own the rights to these text files. They have, in accordance with fair use, been repurposed with the intent of educating and motivate others. However, if any content owners would like their text removed, please contact us by email at support@beevelopment.com")
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true) {
            if !PurchaseManager.isRoyal {
                self.adsLauncher.presentInterstitialAd()
            }
        }
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        closeButton.tintColor = Theme.currentTheme.mainTextColor
        collectionView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    func setupView(bookModel: BookModel) {
        setupColors()
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        partName = bookModel.maintitle
        content = bookModel.content
        cell = bookModel
        
        [collectionView, closeButton, pageController, button, disclaimerButton].forEach { view.addSubview($0) }
        if PurchaseManager.isRoyal {
            _ = button.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 20, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        } else {
            _ = button.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 60, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        }
        _ = collectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: button.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = closeButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        _ = pageController.anchor(closeButton.topAnchor, left: nil, bottom: closeButton.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
        _ = disclaimerButton.anchor(nil, left: button.leftAnchor, bottom: button.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 15, heightConstant: 15)
        
        pageController.text = "1/\(content.count)"
        isLessonDone()
    }
}
