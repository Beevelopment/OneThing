//
//  BookController.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-06.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import SafariServices

class BookController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let buyNowButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Buy book", for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationBold, size: 18)!
        
        return btn
    }()
    
    let viewDetailTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Summary"
        lbl.font = UIFont(name: SansationLight, size: 14)!
        lbl.textColor = .lightGray
        
        return lbl
    }()
    
    let viewTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "The ONE Thing"
        lbl.font = UIFont(name: SansationBold, size: 36)!
        lbl.textColor = .black
        
        return lbl
    }()
    
    let viewSubtitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "The surprisingly simple truth behind extraordinary results"
        lbl.font = UIFont(name: SansationRegular, size: 16)!
        lbl.textColor = .lightGray
        lbl.numberOfLines = 0
        
        return lbl
    }()
    
    let detailText: UILabel = {
        let lbl = UILabel()
        lbl.text = "This app is inspired by the wonderful book The ONE Thing by Gary Keller with Jay Papasan. We want you to succeed in the best possible way and in doing so we believe that you need to understand the fundamentals of the book. Please read through each chapter summary to reach extraordinary results even easier. We do also recommend you to read the whole book. You can purchase through the link in the top right corner."
        lbl.font = UIFont(name: SansationLight, size: 12)!
        lbl.textColor = .lightGray
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    let showMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Show more", for: .normal)
        btn.setTitleColor(yellow, for: .normal)
        btn.titleLabel?.font = UIFont(name: SansationRegular, size: 12)!
        btn.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        return tv
    }()

    var isShowingMore = false
    let bookPartCellID = "bookPartCellID"
    var bookData = [BookModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.register(BookPartCell.self, forCellReuseIdentifier: bookPartCellID)
        downloadBookData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupColors()
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    private func downloadBookData() {
        database.collection("education").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Carl: error \(err.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents {
                    for document in documents {
                        let documentData = document.data()
                        let doc = BookModel(mainData: documentData)
                        self.bookData.append(doc)
                    }
                    self.bookData = self.bookData.sorted(by: { $0.index < $1.index })
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookPart = bookData[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: bookPartCellID, for: indexPath) as? BookPartCell {
            cell.setupView(bookModel: bookPart)
            return cell
        }
        return BookPartCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = bookData[indexPath.row]
        let readController = ReadController()
        
        readController.setupView(bookModel: cell)
        present(readController, animated: true, completion: nil)
    }
    
    @objc private func showMore() {
        if isShowingMore {
            detailText.numberOfLines = 2
            showMoreButton.setTitle("Show more", for: .normal)
            isShowingMore = false
        } else {
            detailText.numberOfLines = 0
            showMoreButton.setTitle("Show less", for: .normal)
            isShowingMore = true
        }
    }
    
    @objc private func buyBook() {
        guard let url = URL(string: "https://www.bookdepository.com/ONE-Thing-Gary-Keller/9781885167774/?a_aid=162128") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func setupColors() {
        view.backgroundColor = Theme.currentTheme.backgroundColor
        buyNowButton.setTitleColor(Theme.currentTheme.mainTextColor, for: .normal)
        viewDetailTitle.textColor = Theme.currentTheme.subTextColor
        viewTitle.textColor = Theme.currentTheme.mainTextColor
        viewSubtitle.textColor = Theme.currentTheme.subTextColor
        detailText.textColor = Theme.currentTheme.subTextColor
        tableView.backgroundColor = Theme.currentTheme.backgroundColor
        tableView.reloadData()
    }
    
    private func setupView() {
        setupNavBar()
        
        [viewDetailTitle, viewTitle, viewSubtitle, detailText, showMoreButton, tableView].forEach { view.addSubview($0) }
        
        _ = viewDetailTitle.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = viewTitle.anchor(viewDetailTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = viewSubtitle.anchor(viewTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = detailText.anchor(viewSubtitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        _ = showMoreButton.anchor(detailText.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: -2.5, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = tableView.anchor(showMoreButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    private func setupNavBar() {
        buyNowButton.addTarget(self, action: #selector(buyBook), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buyNowButton)
    }
}
