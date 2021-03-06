//
//  SettingsViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class SettingsViewController: UIViewController {
    
    var LoggedInUser: User = User() // user currently logged in.
    //view with all the main UIElements
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var deleteAccountView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI(){
        mainView.isHidden = false
        mainView.isUserInteractionEnabled = true
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     * Propmpt the user for password and delete their account along with associated
     * postings.
     */
    @IBAction func deleteAccountClicked(_ sender: Any) {
    
        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete Account?", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {(textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter Password"
            textField.becomeFirstResponder()
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            let passwordTextField = alert.textFields![0] as UITextField
            passwordTextField.resignFirstResponder()
            self.disableUI()
            self.verifyPassword(textField: passwordTextField)
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            textField.resignFirstResponder()
        }))
        
        self.present(alert, animated: true)
    }
    
    /*
     * Checks that the password is correct. If so, delete user.
     */
    func verifyPassword(textField: UITextField) {
        
        guard let enteredPasword = textField.text else {
            print("error unwrapping entered password for authorizing account delete")
            return
        }
        
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: self.LoggedInUser.username + "@bikemarketplace.com", password: enteredPasword)

        user?.reauthenticate(with: credential) { (result, error) in
            if error != nil {
                print("wrongpassword")
                self.showWrongPasswordAlert()
                self.enableUI()
            } else {
                self.deleteUser()
            }
        }

    }
    
    /*
     * User put in a wrong password.
     */
    func showWrongPasswordAlert() {
        let alert = UIAlertController(title: "Unable to Delete Account", message: "You've entered the wrong password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    /*
     * Fetch user data, then delete related database entries.
     */
    func deleteUser() {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            print("error unwrapping uid while deleting user")
            return
        }
        
        self.deleteUserData(uid: uid)
    }
    
    /*
     * Deletes every posting (and its images) associated with the user and
     * then deletes the user's doc in users collection, returns to login view
     */
    func deleteUserData(uid: String) {
        
        let delete_group = DispatchGroup()
        let delete_queue = DispatchQueue(label: "user deletion queue")
        
        // put deletion to a separate thread.
        delete_queue.async {
            let db = Firestore.firestore()
            let storage = StorageReference()
            
            let user = db.collection("users").document(uid)

            user.getDocument { (document, error) in
                if let document = document, document.exists {
                    let user_postings = document.get("user_postings")
                    
                    // Delete all user's postings and images in each posting
                    for posting in user_postings as! [String] {
                        
                        // deletes all in a posting and posting itself
                        delete_group.enter()
                        self.deleteImagesAndPosting(delete_queue: delete_queue, delete_group: delete_group, db: db, storage: storage, postingID: posting)
                    }
                    
                    // delete user database document
                    delete_group.notify(queue: delete_queue) {
                        
                        delete_group.enter()
                        self.deleteDatabaseDoc(group: delete_group, db: db, collection: "users", docID: uid)
                    }
                    // Once all docs associated with the user are deleted, we can delete the user from Authentication
                    delete_group.notify(queue: delete_queue) {
                        self.deleteUserAuth()
                    }
                    
                } else {
                    print("User document does not exist")
                }
            }
        }
        
    }
    
    /*
     * Deletes Images from Firebase Storage in parallel.
     */
    func deleteImagesAndPosting(delete_queue: DispatchQueue, delete_group: DispatchGroup, db: Firestore, storage: StorageReference, postingID: String) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image_group = DispatchGroup()
            let image_queue = DispatchQueue(label: "image deletion queue")
            
            image_queue.async {
                let posting = db.collection("postings").document(postingID)
                
                posting.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let posting_images = document.get("image_ID")
                        
                        // Delete posting doc since we already got the image IDs
                        delete_group.enter()
                        self.deleteDatabaseDoc(group: delete_group, db: db, collection: "postings", docID: postingID)
                        
                        for imageID in posting_images as! [String] {
                            image_group.enter()
                            // Important to note that there is no directory in Storage, the name of the folder that the image is stored in is simply part of the image's name
                            // "postingID/imageID" is the name of the image file
                            self.deleteImage(group: image_group, storage: storage, imageID: postingID + "/" + imageID)
                        }
                        // After all images associated with the posting have been deleted, the posting doc is deleted from database
                        image_group.notify(queue: image_queue) {
                            delete_group.leave()
                        }
                    } else {
                        print("Posting document does not exist")
                        delete_group.leave()
                    }
                }
            }
        }
    }
    
    /*
     * Deletes a single images from Firebase Storage.
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
     * Deletes Firebase database refference to a single posting.
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
    
    /*
     * Deletes user by calling a Firebase Authentication function, transitions to login.
     */
    func deleteUserAuth() {
        let user = Auth.auth().currentUser
        user?.delete { error in
          if error != nil {
            print("Error while calling Firebase user.delete")
          } else {
            self.goToLogin()
            self.enableUI()
          }
        }
    }

    func enableUI(){
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.mainView.isUserInteractionEnabled = true
    }
    
    func disableUI(){
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.mainView.isUserInteractionEnabled = false
    }
    
    /*
     * Dismisses the marketplace navigation controller which takes user back to login.
     */
    func goToLogin() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func managePostingsClicke() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let ManagePostingsVC = storyboard.instantiateViewController(identifier: "postingsManagerViewController") as! PostingsManagerViewController
        
        ManagePostingsVC.current_user = LoggedInUser
        ManagePostingsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(ManagePostingsVC, animated: true)
    }
}
