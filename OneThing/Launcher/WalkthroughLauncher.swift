//
//  WalkthroughLauncher.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-12.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase
import SafariServices

class WalkthroughLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var mainViewController: MainViewController?
    var walkthroughCell: WalkthroughCell?
    var purchaseManager: PurchaseManager?
    
    lazy var mainController: MainViewController = {
        let main = MainViewController()
        main.walkthroughlan = self
        
        return main
    }()
    
    let blackView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bv.alpha = 1
        
        return bv
    }()
    
    lazy var walkthroughCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    lazy var walkthroughPageController: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = divider
        pc.currentPageIndicatorTintColor = yellow
        pc.numberOfPages = self.walkthroughs.count
        pc.alpha = 0
        
        return pc
    }()
    
    let walkthroughs: [WalktroughModel] = {
        let theApp = WalktroughModel(illustration: "bukal", text: "Reaching extraordinary results is simpler than you could imagine. It all starts and ends with OneThing and OneThing only. Just as the domino brick can overturn a brick that is up to 50% larger than itself, we can, by focusing on OneThing, create extraordinary results. This app exists to help you put the OneThing in practice and reach extraordinary results.", bool: true)
        let book = WalktroughModel(illustration: "Book", text: "To get the most out of the OneThing you should be familiar with The ONE Thing strategy. That’s why I have included a book summary. I do however recommend that you read the complete book.", bool: false)
        let category = WalktroughModel(illustration: "CategoryLight", text: "You can personalize the app by adding and deleting categories. You delete categories by long pressing on a category.", bool: false)
        let timeFrames = WalktroughModel(illustration: "TimeFrame", text: "With the OneThing strategy, you should focus on OneThing that will make everything else much simpler or unnecessary to reach your longterm goal. Swipe on the home screen to see your longterm goals.", bool: false)
        let notification = WalktroughModel(illustration: "noti", text: "Wake up notifications so you never miss to complete your OneThing, lose a streak or miss exciting updates!", bool: true)
        
        let array = [theApp, book, category, timeFrames, notification]
        
        return array
    }()
    
    let walkthroughCellID = "walkthroughCellID"
    
    func dismissWalkthroughLauncher() {
        walkthroughAnimateOut(showIAP: false)
    }
    
    private func walkthroughAnimateIn() {
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.walkthroughCollectionView.frame = CGRect(x: 0, y: window.frame.height * 0.1, width: window.frame.width, height: window.frame.height * 0.8 - window.frame.width * 0.1)
                self.blackView.alpha = 1
                self.walkthroughPageController.alpha = 1
            }, completion: nil)
        }
    }
    private func walkthroughAnimateOut(showIAP: Bool) {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.keyWindow {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.walkthroughCollectionView.frame = CGRect(x: 0, y: -self.walkthroughCollectionView.frame.height, width: window.frame.width, height: window.frame.height * 0.8 - window.frame.width * 0.1)
                    self.blackView.alpha = 0
                    self.walkthroughPageController.alpha = 0
                }, completion: { (true) in
                    self.walkthroughCollectionView.removeFromSuperview()
                    self.blackView.removeFromSuperview()
                    self.walkthroughPageController.removeFromSuperview()
                    if showIAP {
                        self.mainViewController?.showIAPController()
                    }
                })
            }
        }
    }
    
    func setupBasicUI(index: Int) {
        registerCell()
        
        walkthroughCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
        walkthroughPageController.currentPage = index
        
        if let window = UIApplication.shared.keyWindow {
            [blackView, walkthroughCollectionView, walkthroughPageController].forEach { window.addSubview($0) }
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            walkthroughCollectionView.frame = CGRect(x: 0, y: -window.frame.height * 0.8 - window.frame.width * 0.1, width: window.frame.width, height: window.frame.height * 0.8 - window.frame.width * 0.1)
            _ = walkthroughPageController.anchor(nil, left: walkthroughCollectionView.leftAnchor, bottom: walkthroughCollectionView.bottomAnchor, right: walkthroughCollectionView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        walkthroughAnimateIn()
        
        if index == walkthroughs.count - 1 {
            walkthroughPageController.alpha = 0
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee.x
        let collectionViewWidth = scrollView.frame.width
        let currentPage = Int(offset / collectionViewWidth)
        
        walkthroughPageController.currentPage = currentPage
        
        if Int(currentPage) == walkthroughs.count - 1 {
            UIView.animate(withDuration: 0.1) {
                self.walkthroughPageController.alpha = 0
            }
        } else if walkthroughPageController.alpha == 0 {
            UIView.animate(withDuration: 0.25) {
                self.walkthroughPageController.alpha = 1
            }
        }
    }
    
    private func registerCell() {
        walkthroughCollectionView.register(WalkthroughCell.self, forCellWithReuseIdentifier: walkthroughCellID)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return walkthroughs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let walkthroughCell = walkthroughs[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: walkthroughCellID, for: indexPath) as? WalkthroughCell {
            cell.walkthrough = walkthroughCell
            cell.delegate = self
            return cell
        } else {
            return WalkthroughCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}

extension WalkthroughLauncher: WalkthroughCellDelegate, SFSafariViewControllerDelegate {
    func walkthroughDone(cell: WalkthroughCell, dismiss: Bool) {
        if dismiss {
            walkthroughAnimateOut(showIAP: false)
        } else {
            walkthroughAnimateOut(showIAP: true)
        }
    }
    
    func openTerms(URL: URL) {
        walkthroughAnimateOut(showIAP: false)
        mainViewController?.openUrl(URL: URL)
    }
}
