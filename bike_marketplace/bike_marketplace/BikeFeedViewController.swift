//
//  BikeFeedViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class BikeFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, refreshMarkeplace{

    var LoggedInUser: User = User()
    //let tableControlImplementation = tableControl()
    var all_postings: [Posting] = []
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //table.dataSource = tableControlImplementation
        loadBikes()
        setupUI()
        table.delegate = self
        table.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func logoutClicked() {
        self.signOutUser()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func newPostingClicked() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let newPostingVC = storyboard.instantiateViewController(identifier: "newPostingViewController") as! NewPostingViewController

        newPostingVC.reload_delegate = self
        newPostingVC.LoggedInUser = LoggedInUser
        self.navigationController?.pushViewController(newPostingVC, animated: true)
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(identifier: "settingsViewController") as! SettingsViewController
        settingsVC.modalPresentationStyle = .fullScreen
        
        settingsVC.LoggedInUser = self.LoggedInUser
        
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func checkPreferences(){
        let fav_color = LoggedInUser.fav_color
        let fav_category = LoggedInUser.fav_category
        
        for posting in all_postings{
            if posting.bike_color == fav_color && posting.bike_type == fav_category{
                // skip postings that the user likely already saw.
                if posting.time_created < LoggedInUser.last_load {
                    continue
                }
                
                let alert = UIAlertController(title: "We found a bike you might like!", message: "Would you like to view it?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "No, thanks.", style: .cancel, handler: {(action) -> Void in
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Sure!", style: .default, handler: {(action) -> Void in
                    
                    // instantiate a ViewPostingViewController, pass information and display
                    let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
                    let ViewPostingVC = storyboard.instantiateViewController(identifier: "viewListingViewController") as! ViewListingViewController
                    
                    ViewPostingVC.modalPresentationStyle = .fullScreen
                    ViewPostingVC.posting = posting
                    
                    self.navigationController?.pushViewController(ViewPostingVC, animated: true)
                }))
                
                self.present(alert, animated: true)
            }
        }
    }
    
    func loadBikes(){
        disableUI()
        
        //print(Int64(NSDate().timeIntervalSince1970 * 1000))
        
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
                
                self.all_postings.removeAll()
                
                // fills in the postings array
                for document in documents{
                    let docID = document.documentID
                    
                    // do not show user's own postings on the feed.
                    if self.LoggedInUser.user_postings.contains(docID) {
                        continue
                    }
                    
                    let posting = self.load_posting(data: document.data(), docID)
                    self.all_postings.append(posting)
                }
                
                self.table.reloadData()
                self.sortPostings()
                self.enableUI()
                self.checkPreferences()
                self.updateUserTimestamp()
            }
        }
    }
    
    func updateUserTimestamp(){
        guard let current_user = Auth.auth().currentUser else {
            print("Could not get current user")
            return
        }
        
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(current_user.uid)
        let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        userDoc.updateData([
            "last_load" : timestamp
        ])
    }
    
    // arranges the postings according to user preferences
    func sortPostings(){
        var sorted_arr: [Posting] = []
        
        let fav_color = LoggedInUser.fav_color
        let fav_category = LoggedInUser.fav_category
        var top_index = 0
        
        for posting in all_postings {
            if posting.bike_color == fav_color && posting.bike_type == fav_category{
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else if posting.bike_type == fav_category{
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else if posting.bike_color == fav_color{
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else {
                sorted_arr.append(posting)
            }
        }
        
        all_postings = sorted_arr
    }
    
    // Initializes one Posting
    func load_posting(data: [String : Any], _ doc_id: String) -> Posting {
        let color = data["color"] as? String ?? ""
        let category = data["category"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let price = data["price"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let image_ids = data["image_ID"] as? [String]? ?? nil
        let time_created = data["time_created"] as? Int64 ?? 0
        let poster_number = data["poster_number"] as? String ?? ""
        
        let posting = Posting(title: title, description: description, bike_color: color, bike_type: category, price: price, poster_number: poster_number, doc_id: doc_id, image_ids: image_ids, time_created: time_created)

        return posting
    }
    
    func signOutUser() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        }
        catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }

    // initializes the current user from database
    func loadUser(group: DispatchGroup){
        
        guard let current_user = Auth.auth().currentUser else {
            print("Could not get current user")
            return
        }
        
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(current_user.uid)
                
        DispatchQueue.global(qos: .userInitiated).async{
            userDoc.getDocument { (document, error) in
                if let document = document {
                    let username = document.get("username") as? String ?? ""
                    let phone_number = document.get("phone_number") as? String ?? ""
                    let user_postings = document.get("user_postings") as? Array ?? [""]
                    let fav_color = document.get("fav_color") as? String ?? ""
                    let fav_category = document.get("fav_color") as? String ?? ""
                    let last_load = document.get("last_load") as? Int64 ?? 0
                    
                    DispatchQueue.main.async{
                        self.LoggedInUser = User(username: username, phone_number: phone_number, user_postings: user_postings, fav_color: fav_color, fav_category: fav_category, last_load: last_load)
                    }
                    print("left")
                    group.leave()
                }
            }
        }
    }
    
    func setupUI(){
        enableUI()
        // hardcoded
        // TODO find a way to do dinamically
        table.rowHeight = 150
        // Sets navigation bar to UCD gold color
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.85, green:0.67, blue:0.00, alpha:1.0)
    }
    
    func enableUI(){
        view.isUserInteractionEnabled = true
        activityIndicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
    }
    
    // number of cells in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all_postings.count
    }
    
    // tells us how to populate a cell at index "indexPath"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellTableViewCell
        
        let current_posting = all_postings[indexPath.row]
        
        cell.title_label.text = current_posting.title
        cell.color_label.text = "Color: \(current_posting.bike_color)"
        cell.category_label.text = "Category: \(current_posting.bike_type)"
        cell.price_label.text = "$ \(current_posting.price)"
        
        return cell
    }
    
    // delegate function to recognize row selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // error check to prevent a crash
        if indexPath.row > all_postings.count {
            print("Selected tableCellView outside of postings array bounds")
            return
        }
        
        // instantiate a ViewPostingViewController, pass information and display
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let ViewPostingVC = storyboard.instantiateViewController(identifier: "viewListingViewController") as! ViewListingViewController
        
        ViewPostingVC.modalPresentationStyle = .fullScreen
        ViewPostingVC.posting = all_postings[indexPath.row]
        
        self.navigationController?.pushViewController(ViewPostingVC, animated: true)
    }
    
    func reloadTable() {
        let group = DispatchGroup()
        let dispatch_queue = DispatchQueue(label: "user dispatch queue")
        
        // synchronize the two async calls to make sure user updated before
        // postings array updated
        dispatch_queue.async {
            group.enter()
            self.loadUser(group: group)
            group.wait()
            DispatchQueue.main.async{
                self.loadBikes()
            }
        }
    }
}
