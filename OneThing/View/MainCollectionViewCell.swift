//
//  MainCollectionViewCell.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-05-30.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox

protocol MainCollectionViewCellDelegate {
    func downloadMainCellData(cell: MainCollectionViewCell)
    func shareApplication(shareText: String, imageText: String)
    func presentIAPController(cell: MainCollectionViewCell)
}

class MainCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var delegate: MainCollectionViewCellDelegate?
    var cellData: MainCollectionViewModel?
    
    lazy var messagePopUp: MessagePopUp = {
        let msg = MessagePopUp()
        msg.mainCollectionViewCell = self
        
        return msg
    }()
    
    lazy var animation: Animations = {
        let ani = Animations()
        ani.mainCollectionViewCell = self
        
        return ani
    }()
    
    lazy var adsLauncher: AdsLauncher = {
        let ads = AdsLauncher()
        ads.mainCollectionViewCell = self
        
        return ads
    }()
    
//    Scroll View
    let scrollView = UIScrollView()
    let containerView = UIView()
    
//    The One Thing
    let timeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        
        return lbl
    }()
    
    let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Share", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.setTitleColor(yellow, for: .normal)
        
        return btn
    }()
    
    lazy var insetTextView: UITextView = {
        let txtView = UITextView()
        txtView.delegate = self
        txtView.font = UIFont(name: SansationRegular, size: 32)!
        txtView.textAlignment = .left
        txtView.adjustsFontForContentSizeCategory = true
        
        return txtView
    }()
    
    let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.setTitleColor(yellow, for: .normal)
        
        return btn
    }()
    
    let characterCountLabel: UILabel = {
        let countLbl = UILabel()
        countLbl.textColor = divider
        countLbl.textAlignment = .right
        countLbl.font = UIFont(name: SansationRegular, size: 16)!
        
        return countLbl
    }()
    
//    One Thing Streaks
    let streakLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        lbl.text = "Streak"
        
        return lbl
    }()
    
    let streakNumber: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 52)!
        lbl.text = "0"
        
        return lbl
    }()
    
    let markAsDoneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Mark as done", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 16)!
        btn.setTitleColor(yellow, for: .normal)
        
        return btn
    }()
    
//    divider
    let dividerView: UIView = {
        let div = UIView()
        div.backgroundColor = divider
        
        return div
    }()
    
//    Archive
    let archiveLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont(name: SansationBold, size: 32)!
        lbl.text = "Archive"
        
        return lbl
    }()
    
    lazy var archiveTableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.allowsSelection = true
        
        return tv
    }()
    
    var dateSince1970 = Date().timeIntervalSince1970
    let peek = SystemSoundID(1519)
    var selectedCategory: String?
    let archiveTableViewCellID = "archiveTableViewCellID"
    let genericText = "Write your OneThing here..."
    var uid: String!
    
    let horizontalTitel = ["Today", "This Week", "This Month", "This Quarter", "This Year"]
    var mainData = [MainCollectionViewModel]()
    var archiveData = [ArchiveModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        archiveTableView.register(ArchiveTableViewCell.self, forCellReuseIdentifier: archiveTableViewCellID)
        setupActions()
        
        if !WalkthroughCell.newUser.isEmpty {
            uid = WalkthroughCell.newUser
        } else if let userUid = userUid as? String {
            uid = userUid
        }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveOneThing), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        markAsDoneButton.addTarget(self, action: #selector(markedAsDoneAction), for: .touchUpInside)
    }
    
    @objc private func saveOneThing() {
        AudioServicesPlaySystemSound(peek)
        dismissKeyboard(on: self)
        
        if insetTextView.text.count < 61 && insetTextView.text != genericText {
            saveOneThingText()
        } else if mainData[0].text != genericText && insetTextView.text == genericText {
            saveOneThingText()
        } else {
            vibrateFunction()
        }
    }
    
    private func saveOneThingText() {
        dateSince1970 = Date().timeIntervalSince1970
        if let category = selectedCategory {
            if let horizontalIndex = horizontalTitel.firstIndex(where: { $0 == timeLabel.text! }) {
                let updatedData = [
                    "\(horizontalIndex)": [
                        "text": insetTextView.text!,
                        "timestamp": "\(dateSince1970)"
                    ]
                ]
                
                database.collection("users").document(uid).collection("categories").document(category).setData(updatedData, merge: true) { (err) in
                    if let err = err {
                        print("Carl: error \(err.localizedDescription)")
                    } else {
                        self.delegate?.downloadMainCellData(cell: self)
                    }
                }
            }
        } else {
            print("Carl: category else")
        }
    }
    
    @objc private func markedAsDoneAction() {
        if let data = cellData, data.text != genericText {
            AudioServicesPlaySystemSound(peek)
            messagePopUp.showNotMarkedMessage(message: .markedAsDone, oneThing: data.text)
        }
    }
    
    func moveToArchive() {
        if let data = cellData {
            moveMainTextToArchive(horizontalData: data, completed: true)
            animation.beginLoadingAnimation(animation: .success)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.66) {
                self.animation.finishLoadingAnimation(animation: .success)
                if !PurchaseManager.isRoyal {
                    self.adsLauncher.presentInterstitialAd()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archiveData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let archiveCell = archiveData[row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: archiveTableViewCellID, for: indexPath) as? ArchiveTableViewCell {
            
            if !PurchaseManager.isRoyal {
                if row > 2 {
                    cell.setupCell(archiveData: archiveCell, shouldBeBlur: true)
                    return cell
                }
            }
            
            cell.setupCell(archiveData: archiveCell, shouldBeBlur: false)
            return cell
        } else {
            return ArchiveTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = archiveData[indexPath.row]
        let textHeight = cell.text.height(withConstrainedWidth: archiveTableView.frame.width - 40, font: UIFont(name: SansationRegular, size: 16)!)
        let cellHeight = textHeight + 32
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !PurchaseManager.isRoyal {
            delegate?.presentIAPController(cell: self)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupKeyboardObserver(on: self)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if insetTextView.textColor == divider {
            insetTextView.textColor = Theme.currentTheme.mainTextColor
            insetTextView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let currentCount = insetTextView.text.count
        characterCountLabel.text = "\(currentCount)/60"
        
        if currentCount > 60 {
            characterCountLabel.textColor = red
        } else {
            characterCountLabel.textColor = divider
        }
        
        if textView.contentOffset.y + textView.bounds.height < textView.contentSize.height {
            insetTextView.font = UIFont(name: SansationRegular, size: insetTextView.font!.pointSize - 4)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if insetTextView.text.isEmpty {
            insetTextView.text = genericText
            insetTextView.textColor = divider
        }
    }
    
    private func checkIfMainTextDate(horizontalData: MainCollectionViewModel) {
        let key = horizontalData.key
        
        if key == "0" {
            checkDateAginstData(component: .day, horizontalData: horizontalData)
        } else if key == "1" {
            checkDateAginstData(component: .weekOfYear, horizontalData: horizontalData)
        } else if key == "2" {
            checkDateAginstData(component: .month, horizontalData: horizontalData)
        } else if key == "3" {
            checkDateAginstData(component: .month, horizontalData: horizontalData)
        } else if key == "4" {
            checkDateAginstData(component: .year, horizontalData: horizontalData)
        }
    }
    
    private func checkDateAginstData(component: Calendar.Component, horizontalData: MainCollectionViewModel) {
        let calendar = Calendar.current
        var currentDate = calendar.component(component, from: Date())
        var cellDate = calendar.component(component, from: Date(timeIntervalSince1970: Double(horizontalData.timestamp)!))
        
        let dateDiffrence = currentDate - cellDate
        
        if horizontalData.key == "3" {
            if currentDate < 4 {
                currentDate = 1
            } else if currentDate < 7 {
                currentDate = 2
            } else if currentDate < 10 {
                currentDate = 3
            } else {
                currentDate = 4
            }

            if cellDate < 4 {
                cellDate = 1
            } else if cellDate < 7 {
                cellDate = 2
            } else if cellDate < 10 {
                cellDate = 3
            } else {
                cellDate = 4
            }
        }
        
        if horizontalData.text != genericText {
            if cellDate < currentDate || cellDate > currentDate {
                messagePopUp.horizontalData = horizontalData
                messagePopUp.showNotMarkedMessage(message: .notMarkedAsDone, oneThing: horizontalData.text)
            } else {
                activeOneThing(horizontalData: horizontalData)
            }
        } else {
            if dateDiffrence > 1 || dateDiffrence < 0 {
                updateMainText(horizontalData: horizontalData, completed: false)
            } else {
                activeOneThing(horizontalData: horizontalData)
            }
        }
    }
    
    private func activeOneThing(horizontalData: MainCollectionViewModel) {
        if horizontalData.text != genericText {
            setupCellContent(isOld: false, horizontalData: horizontalData)
        } else {
            setupCellContent(isOld: true, horizontalData: horizontalData)
        }
    }
    
    func moveMainTextToArchive(horizontalData: MainCollectionViewModel, completed: Bool) {
        let randomArchiveID = randomString(length: 25)
        var complete = ""
        
        if completed {
            complete = "true"
        } else {
            complete = "false"
        }
        
        let documentData = [
            horizontalData.key: [
                "archive": [
                    randomArchiveID: [
                        "completed": complete,
                        "text": horizontalData.text,
                        "timestamp": horizontalData.timestamp
                    ]
                ]
            ]
        ]
        
        database.collection("users").document(uid).collection("categories").document(selectedCategory!).setData(documentData, merge: true) { (err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                self.updateMainText(horizontalData: horizontalData, completed: Bool(complete)!)
            }
        }
    }
    
    func updateMainText(horizontalData: MainCollectionViewModel, completed: Bool) {
        var newStreak = ""
        dateSince1970 = Date().timeIntervalSince1970
        
        if completed {
            let currentStreak = Int(horizontalData.streak)!
            newStreak = "\(currentStreak + 1)"
        } else {
            newStreak = "0"
        }
        
        let documentData = [
            horizontalData.key: [
                "text": genericText,
                "streak": newStreak,
                "timestamp": "\(dateSince1970)"
            ]
        ]
        
        database.collection("users").document(uid).collection("categories").document(selectedCategory!).setData(documentData, merge: true) { (err) in
            if let err = err {
                print("Carl: Err \(err.localizedDescription)")
            } else {
                self.delegate?.downloadMainCellData(cell: self)
            }
        }
    }
    
    private func setupCellContent(isOld: Bool, horizontalData: MainCollectionViewModel) {
        if isOld {
            insetTextView.textColor = divider
            characterCountLabel.text = "0/60"
        } else {
            insetTextView.textColor = Theme.currentTheme.mainTextColor
            characterCountLabel.text = "\(horizontalData.text.count)/60"
        }
        
        insetTextView.text = horizontalData.text
        streakNumber.text = horizontalData.streak
        archiveData = horizontalData.archive.sorted(by: { $0.timestamp > $1.timestamp })
        archiveTableView.reloadData()
    }
    
    @objc private func shareApp() {
        if insetTextView.text != genericText {
            delegate?.shareApplication(shareText: "My OneThing today is \(insetTextView.text!) This will make everything much simpler or unnecessary for me to reach my goals!", imageText: "My OneThing today is:\n\(insetTextView.text!)")
        }
    }
    
    private func setupColors() {
        timeLabel.textColor = Theme.currentTheme.mainTextColor
        insetTextView.textColor = Theme.currentTheme.mainTextColor
        insetTextView.backgroundColor = Theme.currentTheme.backgroundColor
        streakLabel.textColor = Theme.currentTheme.mainTextColor
        streakNumber.textColor = Theme.currentTheme.mainTextColor
        archiveLabel.textColor = Theme.currentTheme.mainTextColor
        backgroundColor = Theme.currentTheme.backgroundColor
        archiveTableView.backgroundColor = Theme.currentTheme.backgroundColor
    }
    
    func setupCell(horizontalData: MainCollectionViewModel, category: String? = nil) {
        setupColors()
        
        mainData = []
        mainData.append(horizontalData)
        
        let margin = frame.width / 20
        
        selectedCategory = category ?? "General"
        cellData = horizontalData
        checkIfMainTextDate(horizontalData: horizontalData)
        
        addSubview(scrollView)
        _ = scrollView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        scrollView.addSubview(containerView)
        _ = containerView.anchor(scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: frame.width, heightConstant: 0)
        
        [timeLabel, shareButton, insetTextView, saveButton, characterCountLabel, streakLabel, streakNumber, markAsDoneButton, dividerView, archiveLabel, archiveTableView].forEach { containerView.addSubview($0) }
        
        _ = timeLabel.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = shareButton.anchor(containerView.topAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 36, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = insetTextView.anchor(timeLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 160)
        _ = saveButton.anchor(insetTextView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = characterCountLabel.anchor(insetTextView.bottomAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 30)
        _ = streakLabel.anchor(saveButton.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = streakNumber.anchor(streakLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = markAsDoneButton.anchor(streakLabel.bottomAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 28, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = dividerView.anchor(streakNumber.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 1)
        _ = archiveLabel.anchor(dividerView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, topConstant: margin, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = archiveTableView.anchor(archiveLabel.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: margin, leftConstant: 20, bottomConstant: margin, rightConstant: 20, widthConstant: 0, heightConstant: 360)
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(dismissKeyboardGesture)
    }
    
    func setupKeyboardObserver(on object: NSObject) {
        NotificationCenter.default.addObserver(object, selector: #selector(handelKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(object, selector: #selector(handelKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver(on object: NSObject) {
        NotificationCenter.default.removeObserver(object)
    }
    
    var keyboardIsVisible = false
    
    @objc func handelKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeight = keyboardFrame.height
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if !keyboardIsVisible {
            scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: scrollView.frame.height - keyboardHeight - 10)
            UIView.animate(withDuration: keyboardDuration) {
                self.layoutIfNeeded()
            }
        }
        keyboardIsVisible = true
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        scrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        UIView.animate(withDuration: keyboardDuration) {
            self.layoutIfNeeded()
        }
        keyboardIsVisible = false
    }
    
    @objc func dismissKeyboard(on object: NSObject) {
        if let window = UIApplication.shared.keyWindow {
            window.endEditing(true)
            removeKeyboardObserver(on: object)
        }
    }
    
    private func vibrateFunction() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: characterCountLabel.center.x - 5, y: characterCountLabel.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: characterCountLabel.center.x + 5, y: characterCountLabel.center.y))
        
        characterCountLabel.layer.add(animation, forKey: "position")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
