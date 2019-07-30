//
//  FeedbackLauncher.swift
//  OneThing
//
//  Created by Carl Henningsson on 2019-06-18.
//  Copyright © 2019 Carl Henningsson. All rights reserved.
//

import UIKit
import Firebase

class FeedbackLuncher: NSObject {
    
    var feedbackController: FeedbackController?
    
    let storage = Storage.storage()
    var feedbackString: String?
    
    func handelFeedbackLauncher() {
        uploadImageToFirebaseStorage()
    }
    
    private func uploadImageToFirebaseStorage() {
        feedbackString = randomString(length: 20)
        if feedbackController?.imageView.image != UIImage(named: "image") {
            if let uploadData = feedbackController?.imageView.image?.jpegData(compressionQuality: 0.25) {
                let imageRef = storage.reference().child("feedback/" + feedbackString! + ".png")
                
                imageRef.putData(uploadData, metadata: nil) { (metaData, err) in
                    guard metaData != nil else {
                        print("Carl: error with upload \(err!.localizedDescription)")
                        return
                    }
                    
                    imageRef.downloadURL(completion: { (url, err) in
                        guard let downloadUrl = url else {
                            print("Carl: error with url \(err!.localizedDescription)")
                            return
                        }
                        self.uploadFeedbackToFirebase(url: downloadUrl.absoluteString)
                    })
                }
            }
        } else {
            uploadFeedbackToFirebase()
        }
    }
    
    private func uploadFeedbackToFirebase(url: String? = nil) {
        let imageUrl: String
        
        if let url = url {
            imageUrl = url
        } else {
            imageUrl = ""
        }
        
        let documentData: [String: Any] = [
            "timestamp": "\(Date().timeIntervalSince1970)",
            "text": feedbackController?.textView.text! as Any,
            "image": imageUrl
        ]
        
        database.collection("feedback").document(feedbackString!).setData(documentData) { (err) in
            if let err = err {
                print("Carl: eror \(err.localizedDescription)")
            }
            print("Carl: done")
        }
    }
}
