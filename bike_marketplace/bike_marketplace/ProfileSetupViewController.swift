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
        self.view.isUserInteractionEnabled = false
        self.errorLabel_textField.isHidden = true
        activity_indicator.isHidden = false
        
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
                    self.activity_indicator.isHidden = true
                    self.errorLabel_textField.isHidden = false
                    self.view.isUserInteractionEnabled = true
                    
                } else {
                    print("username does not exist - available for signup")
                    self.username = enteredUsername
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                        self.goToPasswordCreation()
                        self.activity_indicator.isHidden = true
                        self.view.isUserInteractionEnabled = true
                    })
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
        self.present(VC, animated: true, completion: nil)
    }
    
}
