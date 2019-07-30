//
//  TodayViewController.swift
//  Widget
//
//  Created by Carl Henningsson on 2019-07-19.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import NotificationCenter
import Firebase

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        
        return tv
    }()
    
    let tableViewCellID = "tableViewCellID"
        
    override func viewDidLoad() {
        super.viewDidLoad()
//        FirebaseApp.configure()
        // Do any additional setup after loading the view.
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
//        tableView.register(WidgetTableViewCell.self, forCellReuseIdentifier: tableViewCellID)
//        setupWidget()
        
//        let defaultGroup = UserDefaults(suiteName: "group.com.hc.onethingwidget")!
//        if let userToken = defaultGroup.object(forKey: "FirebaseAuthToken") as? String {
//            Auth.auth().signIn(with: <#T##AuthCredential#>, completion: <#T##AuthDataResultCallback?##AuthDataResultCallback?##(AuthDataResult?, Error?) -> Void#>)
//            
//            Auth.auth().signIn(withCustomToken: userToken) { (authResult, err) in
//                if err == nil {
//                    self.downloadFirebaseData()
//                } else {
//                    self.view.backgroundColor = .red
//                }
//                
//            }
//        }
        
        let label = UILabel()
        label.text = "Widget coming soon!"
        label.textAlignment = .center
        
        view.addSubview(label)
        _ = label.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func downloadFirebaseData() {
        view.backgroundColor = .blue
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 250)
        }
    }
    
    private func setupWidget() {
        
        [tableView].forEach { view.addSubview($0) }
        
        _ = tableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.width / 3, heightConstant: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellID, for: indexPath) as! WidgetTableViewCell
        cell.textLabel?.text = "Test 1"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
