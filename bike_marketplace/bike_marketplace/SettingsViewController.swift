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
    

    func deleteUserThenTransition() {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            print("error unwrapping uid while deleting user")
            return
        }
        self.deleteUserData(uid: uid)
    }
    
    // Deletes every posting associated with the user and then deletes the user's doc in users collection, returns to login view
    func deleteUserData(uid: String) {
        let db = Firestore.firestore()
        
        let user = db.collection("users").document(uid)

        user.getDocument { (document, error) in
            if let document = document, document.exists {
                let user_postings = document.get("user_postings")
                // Deleting all postings associated with user
                for posting in user_postings as! [String] {
                    self.deleteDatabaseDoc(db: db, collection: "postings", docID: posting)
                }
                self.deleteDatabaseDoc(db: db, collection: "users", docID: uid)
                // When a user is deleted, we lose permission to access database, this call must be performed AFTER all the docs have been deleted. I have a feeling that for a large number of postings, some of them will fail to delete because the above loop will not complete in time before deleteUser() is called. Will probably have to use some DispatchQueues to prevent this.
                self.deleteUser()
                
            } else {
                print("User document does not exist")
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
    
    
    func verifyPassword(textField: UITextField) {
        
        guard let enteredPasword = textField.text else {
            print("error unwrapping entered password for authorizing account delete")
            return
        }
        
        Auth.auth().signIn(withEmail: LoggedInUser.username + "@bikemarketplace.com", password: enteredPasword) { authResult, error in
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
    
    func deleteDatabaseDoc(db: Firestore, collection: String, docID: String) {
        db.collection(collection).document(docID).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }

    func enableUI(){
        self.mainView.isUserInteractionEnabled = true
        //activityIndicator.isHidden = true
    }
    
    func disableUI(){
        self.mainView.isUserInteractionEnabled = false
        //activityIndicator.isHidden = false
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
    
    func goToLogin() {
       
        self.navigationController?.dismiss(animated: true, completion: nil) //self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
