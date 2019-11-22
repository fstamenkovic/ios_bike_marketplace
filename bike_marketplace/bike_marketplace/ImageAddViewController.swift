//
//  ImageAddViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase

// make the bike feed implement this protocol. this protocol allows this
// this View Controller to reload all postings on the bike feed
protocol refreshMarkeplace{
    func reloadTable()
}

class ImageAddViewController: UIViewController {
    
    // posting to be passed in from NewPostingViewController
    var newPosting: Posting? = nil
    var reload_delegate :refreshMarkeplace?
    
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func postClicked() {
        guard let posting = newPosting else {
            print("could not retreive the posting")
            return
        }
        
        disableUI()
        
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
                    self.enableUI()
                } else {
                    print("posted posting successfully!")
                    // have the bike feed reload the table to contain this posting as well
                    self.reload_delegate?.reloadTable()
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }
    
    func enableUI(){
        view.isUserInteractionEnabled = true
        activity_indicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activity_indicator.isHidden = false
    }
    
}
