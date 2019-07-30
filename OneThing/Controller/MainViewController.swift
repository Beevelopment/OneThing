//
//  MainViewController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-30.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import AudioToolbox
import Firebase
import SafariServices
import DeviceKit

class MainViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, SFSafariViewControllerDelegate {
    
    var walkthroughlan: WalkthroughLauncher?
    var purchaseManager: PurchaseManager?
    
    lazy var adsLauncher: AdsLauncher = {
        let ads = AdsLauncher()
        ads.mainViewController = self
        
        return ads
    }()
    
    lazy var categoryLauncher: CategoryLauncher = {
        let cl = CategoryLauncher()
        cl.mainViewController = self
        
        return cl
    }()
    
    lazy var menuLauncher: MenuLauncher = {
        let menu = MenuLauncher()
        menu.mainViewController = self
        
        return menu
    }()
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.mainViewController = self
        
        return msg
    }()
    
    lazy var animation: Animations = {
        let ani = Animations()
        ani.mainViewController = self
        
        return ani
    }()
    
    lazy var walkthroughLauncher: WalkthroughLauncher = {
        let walk = WalkthroughLauncher()
        walk.mainViewController = self

        return walk
    }()
    
//    NavigationBar Items
    let menuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "menu"), for: .normal)
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return btn
    }()
    
    let studyButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "book-open"), for: .normal)
        btn.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return btn
    }()
    
    lazy var pageController: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = divider
        pc.currentPageIndicatorTintColor = yellow
        pc.numberOfPages = self.horizontalTitel.count
        pc.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        return pc
    }()
    
//    Categories Carousel
    lazy var categoriesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = Theme.currentTheme.backgroundColor
        
        return cv
    }()
    
//    MainCarouselCollectionView
    lazy var mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        
        return cv
    }()
    
    let coverView = UIView()
    
    let horizontalTitel = ["Today", "This Week", "This Month", "This Quarter", "This Year"]
    let filterArray = ["Add +", "General"]
    
    let categoriesCollectionViewCellID = "categoriesCollectionViewCellID"
    let mainCollectionViewCellID = "mainCollectionViewCellID"
    
    var uid: String?
    var firstLoad = true
    var isWiggling = false
    
    let reachability = Reachability()!
    
    var categories = [CategoriesCarouselModel]()
    var horizontalData = [MainCollectionViewModel]()
    
    var selectedCatagory: String?
    let peek = SystemSoundID(1519)
    
    var activeCodeUser = [ActiveCodeUserModel]()
    let promotionCodes = "promotionCodes"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupIsRoyalNotificatonObserver()
        setupNetworkNotification()
        
        registerCells()
        setupView()
        setupColor()
        
        if userUid == nil && WalkthroughCell.newUser.isEmpty {
            walkthroughLauncher.setupBasicUI(index: 0)
        }
        
        adsLauncher.setupAds()
        
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//            UserDefaults.standard.removeObject(forKey: "uid")
//        } catch let signOutError as NSError {
//            print ("Error signing out: %@", signOutError)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pageController.alpha = 1
        downloadCategories(playAnimation: true)
    }
    
    private func setupIsRoyalNotificatonObserver() {
        let name = Notification.Name(isRoyalNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAds), name: name, object: nil)
    }
    
    @objc private func updateAds(notification: NSNotification) {
        adsLauncher.shouldAdsShow()
        orderArray()
    }
    
    func downloadCategories(playAnimation: Bool) {
        if playAnimation {
            animation.beginLoadingAnimation(animation: .loading)
        }
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
        
        guard let uid = uid else {
            animation.finishLoadingAnimation(animation: .loading)
            return
        }
        
        downloadActiveCodeUser()
        
        database.collection("users").document(uid).collection("categories").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents {
                    self.categories = []
                    for doc in documents {
                        let categoryID = doc.documentID
                        let category = CategoriesCarouselModel(category: categoryID)
                        self.categories.append(category)
                    }
                    self.orderArray()
                    self.downloadHorizontalData(selectedCategory: "General", uid: uid)
                }
            }
        }
    }
    
    private func downloadHorizontalData(selectedCategory: String, uid: String) {
        database.collection("users").document(uid).collection("categories").document(selectedCategory).getDocument { (querySnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                if let documentData = querySnapshot?.data() {
                    self.horizontalData = []
                    for document in documentData {
                        if let values = document.value as? Dictionary<String, AnyObject> {
                            let key = document.key
                            let doc = MainCollectionViewModel(mainData: values, key: key)
                            self.horizontalData.append(doc)
                        }
                    }
                    self.mainCollectionView.reloadData()
                    self.animation.finishLoadingAnimation(animation: .loading)
                } else {
                    print("Carl: No data")
                }
            }
        }
    }
    
    private func orderArray() {
        if let generalIndex = categories.firstIndex(where: {$0.category == "General"}) {
            categories = rearrange(array: categories, fromIndex: generalIndex, toIndex: 0)
            let addItem = CategoriesCarouselModel(category: "Add +")
            categories.insert(addItem, at: categories.count)
            
            self.categoriesCollectionView.reloadData()
            
            let indexPath = IndexPath(item: 0, section: 0)
            self.categoriesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        }
    }
    
    @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
            if PurchaseManager.isRoyal {
                if !isWiggling {
                    startWiggle()
                }
            } else {
                showIAPController()
            }
        }
    }
    
    func startWiggle() {
        AudioServicesPlaySystemSound(peek)
        isWiggling = true
        coverView.isHidden = false
        for cell in categoriesCollectionView.visibleCells as! [CategoriesCarouselCell] {
            if !filterArray.contains(cell.categoryLabel.text!) {
                addWiggleAnimationTo(cell)
                cell.isWiggling(isWiggling: isWiggling)
            }
        }
    }
    
    @objc func stopWiggle() {
        isWiggling = false
        coverView.isHidden = true
        for cell in categoriesCollectionView.visibleCells as! [CategoriesCarouselCell] {
            cell.layer.removeAllAnimations()
            cell.isWiggling(isWiggling: isWiggling)
        }
    }
    
    func addWiggleAnimationTo(_ cell: UICollectionViewCell) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        cell.layer.add(rotationAnimation(), forKey: "rotation")
        CATransaction.commit()
    }
    
    private func rotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let angle = CGFloat(0.04)
        let duration = TimeInterval(0.1)
        animation.values = [angle, -angle]
        animation.autoreverses = true
        animation.duration = duration
        animation.repeatCount = .infinity
        return animation
    }
    
    private func registerCells() {
        categoriesCollectionView.register(CategoriesCarouselCell.self, forCellWithReuseIdentifier: categoriesCollectionViewCellID)
        mainCollectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: mainCollectionViewCellID)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return categories.count
        } else if collectionView == mainCollectionView {
            return horizontalData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            let category = categories[indexPath.item]
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: categoriesCollectionViewCellID, for: indexPath) as? CategoriesCarouselCell {
                if !filterArray.contains(category.category) {
                    cell.isWiggling(isWiggling: isWiggling)
                    if isWiggling {
                        startWiggle()
                    } else {
                        stopWiggle()
                    }
                } else {
                    cell.isWiggling(isWiggling: false)
                }

                cell.category = category
                return cell
            } else {
                return CategoriesCarouselCell()
            }
        } else if collectionView == mainCollectionView {
            let horizontalSortedCells = horizontalData.sorted(by: { $0.key < $1.key })
            let horizontalCell = horizontalSortedCells[indexPath.item]
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: mainCollectionViewCellID, for: indexPath) as? MainCollectionViewCell {
                cell.timeLabel.text = horizontalTitel[indexPath.item]
                cell.setupCell(horizontalData: horizontalCell, category: selectedCatagory)
                cell.delegate = self
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            AudioServicesPlaySystemSound(peek)
            let selectedCell = categories[indexPath.item]
            guard let uid = uid else { return }
    
            if indexPath.item > 0 {
                if !PurchaseManager.isRoyal {
                    showIAPController()
                    return
                }
            }
            
            if !isWiggling {
                if indexPath.item == categories.count - 1 {
                    categoryLauncher.addCategoryPressed(bool: true)
                } else {
                    selectedCatagory = selectedCell.category
                    downloadHorizontalData(selectedCategory: selectedCell.category, uid: uid)
                }
            } else {
                if indexPath.item != categories.count - 1 && indexPath.item != 0 {
                    categoryLauncher.deleteCategoryPressed(category: selectedCell.category, bool: false)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCollectionView {
            let staticHeight: CGFloat = 40.0
            
            let categoryCell = categories[indexPath.item]
            let categoryText = categoryCell.category
            let stringWidth = categoryText.width(withConstrainedHeight: staticHeight, font: UIFont(name: SansationRegular, size: 21)!)
            let cellWidth = stringWidth + 40
            
            return CGSize(width: cellWidth + 10, height: staticHeight)
        } else if collectionView == mainCollectionView {
            return CGSize(width: view.frame.width, height: view.frame.height - categoriesCollectionView.frame.height * 2)
        }
        
        return CGSize(width: 100, height: 100)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = targetContentOffset.pointee.x
        let collectionViewWidth = scrollView.frame.width
        let currentPage = Int(offset / collectionViewWidth)
        
        pageController.currentPage = currentPage
    }
    
    @objc private func showMenu() {
        menuLauncher.showMenu()
    }
    
    func handelMenuButtons(selectedCell: Menu) {
        if selectedCell == Menu.walkThrough {
            walkthroughLauncher.setupBasicUI(index: 0)
        } else if selectedCell == Menu.royalUser {
            showIAPController()
        } else if selectedCell == Menu.shareApp {
            shareApp(shareText: "I'm getting extraordinary results by focusing on OneThing. Download the app today and follow the simple strategy to reach extraordinary results!", imageText: "I'm getting extraordinary results by focusing on OneThing!")
        } else if selectedCell == Menu.darkMode {
            enableDarkMode()
        } else if selectedCell == Menu.setting {
            let settingsController = SettingsController()
            navigationController?.pushViewController(settingsController, animated: true)
            pageController.alpha = 0
        }
    }
    
    private func enableDarkMode() {
        if PurchaseManager.isRoyal {
            isDarkModeChanged()
        } else {
            showIAPController()
        }
    }
    
    private func isDarkModeChanged() {
        if Theme.isDarkMode {
            Theme.isDarkMode = false
            UserDefaults.standard.set(false, forKey: "isDarkMode")
            Theme.currentTheme = LightTheme()
        } else {
            Theme.isDarkMode = true
            UserDefaults.standard.set(true, forKey: "isDarkMode")
            Theme.currentTheme = DarkTheme()
        }
        setupColor()
    }
    
    private func setupColor() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        setupNavBar()
        categoriesCollectionView.backgroundColor = Theme.currentTheme.backgroundColor
        orderArray()
        mainCollectionView.reloadData()
    }
    
    func showIAPController() {
        let inAppPurchaseController = InAppPurchaseController()
        present(inAppPurchaseController, animated: true, completion: nil)
    }
    
    func openUrl(URL: URL) {
        let safariVC = SFSafariViewController(url: URL)
        safariVC.delegate = self
        present(safariVC, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        walkthroughLauncher.setupBasicUI(index: 4)
    }
    
    private func shareApp(shareText: String, imageText: String) {
        let shareText = shareText
        let shareUrl = URL(string: "https://apple.co/2JCO0S3")!
        let image = textToImage(drawText: imageText, inImage: UIImage(named: "shareImgLight")!, atPoint: CGPoint(x: 650, y: 200))
        let activityController = UIActivityViewController(activityItems: [shareText, shareUrl, image], applicationActivities: [])
        
        if Device.current.isPad {
            activityController.popoverPresentationController?.sourceView = super.view
            present(activityController, animated: true, completion: nil)
        } else {
            present(activityController, animated: true, completion: nil)
        }
    }
    
    @objc private func pressentBookView() {
        let bookController = BookController()
        navigationController?.pushViewController(bookController, animated: true)
        pageController.alpha = 0
    }
    
    private func downloadActiveCodeUser() {
        database.collection("users").document(uid!).collection(promotionCodes).document("activeCode").getDocument { (documentSnapshot, err) in
            guard err == nil else { return }
            if let document = documentSnapshot?.data() {
                let activeCode = ActiveCodeUserModel(documetData: document)
                self.activeCodeUser.append(activeCode)
                
                self.handelActivePromoCode()
            }
        }
    }
    
    private func handelActivePromoCode() {
        let userPromoModel = activeCodeUser[0]
        let todaysDate = Date()
        let activatedDate = Double(userPromoModel.activatedDate)!
        
        if let diffDays = Calendar.current.dateComponents([.day], from: Date(timeIntervalSince1970: activatedDate), to: todaysDate).day {
            if let numberInCode = Int(userPromoModel.code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                if diffDays < numberInCode {
                    PurchaseManager.instance.setRoyalUserToTrue()
                } else {
                    moveActiveCodeToUsed()
                }
            }
        }
    }
    
    private func moveActiveCodeToUsed() {
        let documentData = [randomString(length: 20): activeCodeUser[0].code]
        database.collection("users").document(uid!).collection(promotionCodes).document("usedCodes").setData(documentData, merge: true) { err in
            if let err = err {
                print("Carl: Error with updating -> \(err)")
            } else {
                database.collection("users").document(self.uid!).collection(self.promotionCodes).document("activeCode").delete(completion: { err in
                    if let err = err {
                        print("Carl: Error with deleting -> \(err)")
                    } else {
                        self.messagePopUp.showGenericMessage(text: "Your promo code has expired. Please purchase Royal User if you enjoyed the experience.")
                    }
                })
            }
        }
    }

    private func setupView() {
        setupNavBar()
        coverView.isHidden = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopWiggle))
        coverView.addGestureRecognizer(tapGestureRecognizer)
        
        [categoriesCollectionView, mainCollectionView, coverView].forEach {( view.addSubview($0) )}
        _ = categoriesCollectionView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        _ = mainCollectionView.anchor(categoriesCollectionView.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = coverView.anchor(mainCollectionView.topAnchor, left: mainCollectionView.leftAnchor, bottom: mainCollectionView.bottomAnchor, right: mainCollectionView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        categoriesCollectionView.addGestureRecognizer(longPressGestureRecognizer)
        
        PurchaseManager.instance.retriveProductInfo()
    }
    
    private func setupNavBar() {
        extendedLayoutIncludesOpaqueBars = true
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = Theme.currentTheme.backgroundColor
        navigationController?.navigationBar.tintColor = Theme.currentTheme.mainTextColor
        
        menuButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        studyButton.addTarget(self, action: #selector(pressentBookView), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: studyButton)
        
        if let navBarsize = navigationController?.navigationBar.bounds.size {
            let origin = CGPoint(x: navBarsize.width / 2 - 50, y: navBarsize.height / 2 - 25)
            pageController.frame = CGRect(x: origin.x, y: origin.y, width: 100, height: 50)
            navigationController?.navigationBar.addSubview(pageController)
        }
    }
}

extension MainViewController: MainCollectionViewCellDelegate {
    func downloadMainCellData(cell: MainCollectionViewCell) {
        if let category = cell.selectedCategory {
            guard let uid = uid else { return }
            downloadHorizontalData(selectedCategory: category, uid: uid)
        }
    }
    
    func shareApplication(shareText: String, imageText: String) {
        shareApp(shareText: shareText, imageText: imageText)
    }
    
    func presentIAPController(cell: MainCollectionViewCell) {
        showIAPController()
    }
}

extension MainViewController {
    private func setupNetworkNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("Carl: could not start reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            print("Carl: Reachable via WiFi")
        case .cellular:
            print("Carl: Reachable via Cellular")
        case .none:
            print("Carl: Network not reachable")
            messagePopUp.showGenericMessage(text: "No Network. Please connect to a network and continue.")
        }
    }
}
