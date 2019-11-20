//
//  ImageAddViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase

class ImageAddViewController: UIViewController {
    
    // posting to be passed in from NewPostingViewController
    var newPosting: Posting? = nil
    
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func postClicked() {
        guard let posting = newPosting else {
            print("could not retreive the posting")
            return
        }
        
        let db = Firestore.firestore()
        
        let ref = db.collection("postings")
        
        ref.addDocument(data: [
            "category": posting.bike_type,
            "color": posting.bike_color,
            "description": posting.description,
            "title": posting.title,
            "price": posting.price]){error in
                if error != nil {
                    print("there was an error posting this")
                } else {
                    print("posted posting successfully!")
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }
    
}
