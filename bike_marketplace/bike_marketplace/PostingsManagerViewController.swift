//
//  PostingsManagerViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/30/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PostingsManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user_postings: [Posting] = []
    var posting_uids: [String] = []
    var current_user: User?
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 150
        loadPostings()
        activity_indicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    func loadPostings(){
        let db = Firestore.firestore()
        
        // get a reference to the collection
        let ref = db.collection("postings")
        
        ref.getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.enableUI()
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("Failed to unwrap documents")
                    return
                }
                
                guard let current_user = self.current_user else {
                    print("Could not unwrap current user")
                    return
                }
                
                self.user_postings.removeAll()
                self.posting_uids.removeAll()
                // fills in the postings array
                for document in documents{
                    let docID = document.documentID
                    
                    // do not show user's own postings on the feed.
                    if current_user.user_postings.contains(docID) {
                        let posting = self.load_posting(data: document.data())
                        self.user_postings.append(posting)
                        self.posting_uids.append(docID)
                    }
                }
                
                self.enableUI()
                self.table.reloadData()
            }
        }
    }
    
    // Initializes one Posting
    func load_posting(data: [String : Any]) -> Posting {
        let color = data["color"] as? String ?? ""
        let category = data["category"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let price = data["price"] as? String ?? ""
        let description = data["description"] as? String ?? ""
            
        let posting = Posting(title: title, description: description, bike_color: color, bike_type: category, price: price)
            
        return posting
    }
    
    func enableUI(){
        view.isUserInteractionEnabled = true
        activity_indicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activity_indicator.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user_postings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellTableViewCell
        
        let current_posting = user_postings[indexPath.row]
        
        cell.title_label.text = current_posting.title
        cell.color_label.text = "Color: \(current_posting.bike_color)"
        cell.category_label.text = "Category: \(current_posting.bike_type)"
        cell.price_label.text = "$ \(current_posting.price)"
        
        return cell
    }
    
    // delegate function to recognize row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        disableUI()
        // error check to prevent a crash
        if indexPath.row > user_postings.count {
            print("Selected tableCellView outside of postings array bounds")
            return
        }
     
        let alert = UIAlertController(title: "Delete Posting", message: "Are you sure you want to delete this posting?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {(action) -> Void in
            self.user_postings.remove(at: indexPath.row)
            let uid = self.posting_uids[indexPath.row]
             let db = Firestore.firestore()
             
             // get a reference to the collection
            let ref = db.collection("postings").document("\(uid)")
            
            ref.delete() {error in
                if error != nil {
                    print("\(error.debugDescription)")
                    self.enableUI()
                } else {
                    let curr_User = Auth.auth().currentUser
                    guard let user = curr_User else {
                        print("could not unwrap user")
                        return
                    }
                    
                    let user_ref = db.collection("users").document("\(user.uid)")
                
                    user_ref.updateData([
                        "user_postings" : FieldValue.arrayRemove(["\(uid)"])
                    ])
                    
                    self.loadPostings()
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in
            self.enableUI()
        }))
        
        self.present(alert, animated: true)
    }

}
