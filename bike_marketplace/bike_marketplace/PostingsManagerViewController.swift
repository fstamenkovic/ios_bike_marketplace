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
import FirebaseStorage

class PostingsManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var user_postings: [Posting] = [] // an array of postings
    var posting_ids: [String] = [] // postings respective document ID's for Firebase
    var current_user: User? // user currently logged in
    
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
    
    /*
     * Gets all postings off Firebase. Loads the user_postings array
     * only with user's own postings.
     */
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
                self.posting_ids.removeAll()
                // fills in the postings array
                for document in documents{
                    let docID = document.documentID
                    
                    // only add to user_pustings if posting is user's own posting.
                    if current_user.user_postings.contains(docID) {
                        let posting = self.load_posting(data: document.data())
                        self.user_postings.append(posting)
                        self.posting_ids.append(docID)
                    }
                }
                
                self.enableUI()
                self.table.reloadData()
            }
        }
    }
    
    /*
     * Initializes one posting from dictionary.
     */
    func load_posting(data: [String : Any]) -> Posting {
        let color = data["color"] as? String ?? ""
        let category = data["category"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let price = data["price"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let poster_number = data["poster_number"] as? String ?? ""
            
        let posting = Posting(title: title, description: description, bike_color: color, bike_type: category, price: price, poster_number: poster_number)
            
        return posting
    }
    
    /*
     * Deletes a single posting and associated images.
     */
    func deletePostingAndImages(db: Firestore, storage: StorageReference, postingID: String) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image_group = DispatchGroup()
            let image_queue = DispatchQueue(label: "image deletion queue")
            
            image_queue.async {
                let posting = db.collection("postings").document(postingID)
                
                posting.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let posting_images = document.get("image_ID")
                        
                        // Delete posting doc since we already got the image IDs
                        image_group.enter()
                        self.deleteDatabaseDoc(group: image_group, db: db, collection: "postings", docID: postingID)
                        
                        for imageID in posting_images as! [String] {
                            image_group.enter()
                            // Important to note that there is no directory in Storage, the name of the folder that the image is stored in is simply part of the image's name
                            // "postingID/imageID" is the name of the image file
                            self.deleteImage(group: image_group, storage: storage, imageID: postingID + "/" + imageID)
                        }
                        // After all images associated with the posting have been deleted, the posting doc is deleted from database
                        image_group.notify(queue: image_queue) {
                            self.removeFromUser(db: db, postingID: postingID)
                        }
                    } else {
                        print("Posting document does not exist")
                        self.enableUI()
                    }
                }
            }
        }
    }
    
    /*
     * Removes posting id's from user document
     */
    func removeFromUser(db: Firestore, postingID: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("error getting uid while removing postingID from user_postings")
            return
        }
        let user = db.collection("users").document(uid)
        
        user.updateData([
            "user_postings" : FieldValue.arrayRemove(["\(postingID)"])
        ]) { error in
            if error != nil {
                print("error removing postingID from user_postings")
                self.enableUI()
            } else {
                print("successfully removed postingID from user_postings")
                self.loadPostings()
                
            }
        }
    }
    
    /*
     * Deletes a single image from FirebaseStorage
     */
    func deleteImage(group: DispatchGroup, storage: StorageReference, imageID: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageRef = storage.child(imageID)
            
            imageRef.delete { error in
                if error != nil {
                    print("error deleting image file from storage")
                } else {
                    print("image file deleted successfully")
                }
                group.leave()
            }
        }
    }
    
    /*
     * Deletes a document from Firebase.
     */
    func deleteDatabaseDoc(group: DispatchGroup, db: Firestore, collection: String, docID: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            db.collection(collection).document(docID).delete() { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                }
                group.leave()
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
            let postingID = self.posting_ids[indexPath.row]
            let db = Firestore.firestore()
            let storage = StorageReference()
                        
            self.deletePostingAndImages(db: db, storage: storage, postingID: postingID)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in
            self.enableUI()
        }))
        
        self.present(alert, animated: true)
    }

}
