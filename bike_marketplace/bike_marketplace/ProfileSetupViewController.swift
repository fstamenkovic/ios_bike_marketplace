//
//  ProfileSetupViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/13/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileSetupViewController: UIViewController {

    @IBOutlet weak var errorLabel_textField: UITextField!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var new_username_textField: UITextField!
    @IBOutlet weak var lets_go_button: UIButton!
    
    var username: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func letsGoButtonPressed() {
        self.errorLabel_textField.isHidden = true
        disableUI()
        
        guard let enteredUsername = new_username_textField.text else {
            print("error unwrapping the entered username during profile setup")
            return
        }
        
        if usernameIsValid(enteredUsername) {
            let db = Firestore.firestore()
            let matchingUsername = db.collection("usernames").document(enteredUsername)
            
            matchingUsername.getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    print("username already exists")
                    self.errorLabel_textField.text = "This username is taken."
                    self.errorLabel_textField.isHidden = false
                    self.enableUI()
                    
                } else {
                    print("username does not exist - available for signup")
                    self.username = enteredUsername
                    self.goToPasswordCreation()
                    self.enableUI()
                }
            }
            
        } else {
            errorLabel_textField.text = "Invalid username. Please enter a username 4-12 characters in length containing only numbers and/or lowercase letters."
            self.activity_indicator.isHidden = true
            errorLabel_textField.isHidden = false
            self.view.isUserInteractionEnabled = true
        }
    }
    func usernameIsValid(_ username: String) -> Bool {
        
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^[a-z0-9]{4,12}$")
        
        return usernameTest.evaluate(with: username)
    }
    
    func goToPasswordCreation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "passwordCreationViewController") as! PasswordCreationViewController
        VC.modalPresentationStyle = .fullScreen
        VC.username = self.username
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func enableUI(){
        self.view.isUserInteractionEnabled = true
        self.activity_indicator.isHidden = true
    }
    
    func disableUI(){
        self.view.isUserInteractionEnabled = false
        self.activity_indicator.isHidden = false
    }
    
}
