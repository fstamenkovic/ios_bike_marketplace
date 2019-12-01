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
    
    var LoggedInUser: User = User()

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
    
    func disableUserInteraction(){
        
    }
    
    func enableUserInteraction(){
        
    }
    
    @IBAction func dismissClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountClicked(_ sender: Any) {
        //deleteAccountView.isHidden = false
        //deleteAccountView.isUserInteractionEnabled = true
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
    
    
    @IBAction func changePasswordClicked() {
        let alert = UIAlertController(title: "Change Password", message: "Confirm Current Password?", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Confirm Old Password"
            textField.keyboardType = UIKeyboardType.default
            textField.becomeFirstResponder()
        })
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Enter New Password."
            textField.keyboardType = UIKeyboardType.default
        })
        
        alert.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Confirm New Password."
            textField.keyboardType = UIKeyboardType.default
        })
        
        alert.addAction(UIAlertAction(title: "Change Password", style: .default, handler: { (action) -> Void in
            let old_password = alert.textFields![0] as UITextField
            let new_password = alert.textFields![1] as UITextField
            let confirm_password = alert.textFields![2] as UITextField
            
            //Guard statements for test purposes
            guard let one = old_password.text else {
                return
            }
            
            print(one)
            
            guard let two = new_password.text else {
                return
            }
            
            print(two)
            
            guard let three = confirm_password.text else {
                return
            }
            
            print(three)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
    @IBAction func changeUsernameClicked() {
        let alert = UIAlertController(title: "Change Username", message: "Confirm Current Password?", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Enter new username."
            textField.keyboardType = UIKeyboardType.default
        })
        
        alert.addTextField(configurationHandler: {(textField) in
            textField.placeholder = "Confirm Password."
            textField.keyboardType = UIKeyboardType.default
        })
        
        alert.addAction(UIAlertAction(title: "Change Username", style: .default, handler: { (action) -> Void in
            let new_username = alert.textFields![0] as UITextField
            let password = alert.textFields![1] as UITextField
            
            guard let one = new_username.text else {
                return
            }
            
            print(one)
            
            guard let two = password.text else {
                return
            }
            
            print(two)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
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
                self.deleteUserThenTransition()
            }
        }

    }
    
    func showWrongPasswordAlert() {
        let alert = UIAlertController(title: "Unable to Delete Account", message: "You've entered the wrong password.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func deleteUserThenTransition() {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            print("error unwrapping uid while deleting user")
            return
        }
        self.deleteUserData(uid: uid)
    }
    
    // Deletes every posting (and its images) associated with the user and then deletes the user's doc in users collection, returns to login view
    func deleteUserData(uid: String) {
        
        let delete_group = DispatchGroup()
        let delete_queue = DispatchQueue(label: "user deletion queue")
        
        delete_queue.async {
            let db = Firestore.firestore()
            let storage = StorageReference()
            
            let user = db.collection("users").document(uid)

            user.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Delete all user's postings and image in each posting
                    let user_postings = document.get("user_postings")
                    
                    for posting in user_postings as! [String] {
                        delete_group.enter()
                        self.deleteImagesAndPosting(delete_queue: delete_queue, delete_group: delete_group, db: db, storage: storage, postingID: posting)
                    }
                    delete_group.notify(queue: delete_queue) {
                        delete_group.enter()
                        self.deleteDatabaseDoc(group: delete_group, db: db, collection: "users", docID: uid)
                    }
                    // Once all docs associated with the user are deleted, we can delete the user from Authentication
                    delete_group.notify(queue: delete_queue) {
                        self.deleteUser()
                    }
                    
                } else {
                    print("User document does not exist")
                }
            }
        }
        
    }
    
    @IBAction func managePostingsClicke() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let UserPostingsVC = storyboard.instantiateViewController(identifier: "postingsManagerViewController") as! PostingsManagerViewController
        
        UserPostingsVC.current_user = LoggedInUser
        UserPostingsVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(UserPostingsVC, animated: true)
    }
    
    // Images for each posting are deleted in parallel.
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
    
    func deleteImage(group: DispatchGroup, storage: StorageReference, imageID: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let imageRef = storage.child(imageID)
            
            imageRef.delete { error in
                if let error = error {
                    print("error deleting image file from storage")
                } else {
                    print("image file deleted successfully")
                }
                group.leave()
            }
        }
    }
    
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
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        user?.delete { error in
          if let error = error {
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
        //activityIndicator.isHidden = true
    }
    
    func disableUI(){
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        self.mainView.isUserInteractionEnabled = false
        //activityIndicator.isHidden = false
    }
    
    func goToLogin() {
       
        self.navigationController?.dismiss(animated: true, completion: nil) //self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
