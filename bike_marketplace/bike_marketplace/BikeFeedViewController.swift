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

    var LoggedInUser: User = User() // current user.
    var all_postings: [Posting] = [] // stores all postings.
    
    @IBOutlet weak var table: UITableView! // table that shows all posting.
    
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
    
    /*
     * Checks if any of the postings might match user preferences and prompts the user
     * to go to a posting of interest if found.
     */
    func checkPreferences(){
        let fav_color = LoggedInUser.fav_color
        let fav_category = LoggedInUser.fav_category
        
        for posting in all_postings{
            
            // check if posting matches preferences.
            if posting.bike_color == fav_color && posting.bike_type == fav_category{
                
                // skip postings that the user likely already saw.
                if posting.time_created < LoggedInUser.last_load {
                    continue
                }
                
                let alert = UIAlertController(title: "We found a bike you might like!", message: "Would you like to view it?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "No, thanks.", style: .cancel, handler: {(action) -> Void in
                    
                }))
                
                // Segue to  the posting.
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
    
    /*
     * This function loads postings from the database into the all_postings array.
     */
    func loadBikes(){
        disableUI()
                
        let db = Firestore.firestore()
        
        // get a reference to the collection
        let ref = db.collection("postings")
        
        // retreive all postings from Firestore.
        ref.getDocuments(){ (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
                self.enableUI()
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("Failed to unwrap documents")
                    return
                }
                
                // remove all postings from the array
                self.all_postings.removeAll()
                
                // fills in the postings array
                for document in documents{
                    let docID = document.documentID
                    
                    // do not show user's own postings on the feed.
                    if self.LoggedInUser.user_postings.contains(docID) {
                        continue
                    }
                    
                    // inititalize the Posting data structure.
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
    
    /*
     * Updates user's Firestore document last login time with current time.
     */
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
    /*
     * Sorts the postings array in the order of user preferences.
     */
    func sortPostings(){
        var sorted_arr: [Posting] = []
        
        let fav_color = LoggedInUser.fav_color
        let fav_category = LoggedInUser.fav_category
        var top_index = 0
        
        for posting in all_postings {
            
            // show perfect matches first
            if posting.bike_color == fav_color && posting.bike_type == fav_category{
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else if posting.bike_type == fav_category{ //show category matches second
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else if posting.bike_color == fav_color{ // show color matches third
                sorted_arr.insert(posting, at: top_index)
                top_index += 1
            } else { // show all other postings
                sorted_arr.append(posting)
            }
        }
        
        all_postings = sorted_arr
    }
    
    /*
     * Initializes the Posting data structure from the data dictionary.
     */
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
    
    /*
     * Signs a user out.
     */
    func signOutUser() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        }
        catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }

    /*
     * Initializes current current user.
     */
    func loadUser(group: DispatchGroup){
        
        guard let current_user = Auth.auth().currentUser else {
            print("Could not get current user")
            return
        }
        
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(current_user.uid)
        
        // fetch latest information from Firebase about the current user.
        DispatchQueue.global(qos: .userInitiated).async{
            userDoc.getDocument { (document, error) in
                if let document = document {
                    let username = document.get("username") as? String ?? ""
                    let phone_number = document.get("phone_number") as? String ?? ""
                    let user_postings = document.get("user_postings") as? Array ?? [""]
                    let fav_color = document.get("fav_color") as? String ?? ""
                    let fav_category = document.get("fav_color") as? String ?? ""
                    let last_load = document.get("last_load") as? Int64 ?? 0
                    
                    // post to main thread to update LoggedInUser
                    DispatchQueue.main.async{
                        self.LoggedInUser = User(username: username, phone_number: phone_number, user_postings: user_postings, fav_color: fav_color, fav_category: fav_category, last_load: last_load)
                    }
                    
                    // signal that the current user info has been loaded
                    group.leave()
                }
            }
        }
    }
    
    /*
     * Reloads user information first, and then loads the postings.
     */
    func reloadTable() {
        let group = DispatchGroup()
        let dispatch_queue = DispatchQueue(label: "Reload Queue")
        
        //put loading the table in a separate thread.
        dispatch_queue.async {
            group.enter()
            self.loadUser(group: group)
            
            // wait for loadUser to finish because loadBikes() uses user info.
            group.wait()
            
            // update the all_postings array on the main thread.
            DispatchQueue.main.async{
                self.loadBikes()
            }
        }
    }
    
    /*
     * UI Setup.
     */
    func setupUI(){
        enableUI()
        table.rowHeight = 150
    }
    
    func enableUI(){
        view.isUserInteractionEnabled = true
        activityIndicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activityIndicator.isHidden = false
    }
    
    /*
     * Returns the number of cells in a section, which is the number of postings.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return all_postings.count
    }
    
    /*
     * tells us how to populate a cell at index "indexPath". Returns a custom cell.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellTableViewCell
        
        let current_posting = all_postings[indexPath.row]
        
        cell.title_label.text = current_posting.title
        cell.color_label.text = "Color: \(current_posting.bike_color)"
        cell.category_label.text = "Category: \(current_posting.bike_type)"
        cell.price_label.text = "$ \(current_posting.price)"
        
        return cell
    }
    
    /*
     * Delegate function to recognize row selection. Segues to selected posting.
     */
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
}
