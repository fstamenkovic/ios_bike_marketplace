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
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var new_username_textField: UITextField!
    @IBOutlet weak var lets_go_button: UIButton!
    
    var NewUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func letsGoButtonPressed() {
        self.errorLabel.isHidden = true
        disableUI()
        
        guard let enteredUsername = new_username_textField.text else {
            print("error unwrapping the entered username during profile setup")
            return
        }
        
        if usernameIsValid(enteredUsername) {
            checkIfUsernameTaken(enteredUsername)
            
        } else {
            errorLabel.text = "Invalid username. Please enter a username 4-12 characters in length containing only numbers and/or lowercase letters."
            
            errorLabel.isHidden = false
            self.enableUI()
        }
    }
    func usernameIsValid(_ username: String) -> Bool {
        
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", "^[a-z0-9]{4,12}$")
        
        return usernameTest.evaluate(with: username)
    }
    func checkIfUsernameTaken(_ username: String) {
        Auth.auth().fetchSignInMethods(forEmail: username + "@bikemarketplace.com") { (signInMethods, error) in
            
            if (error != nil) {
                print("error in Firebase fetchSignInMethods call")
            } else {
                if (signInMethods != nil) {
                    print("username is already in use")
                    self.errorLabel.text = "Username is taken."
                    self.errorLabel.isHidden = false
                    self.enableUI()
                } else {
                    print("username is available")
                    self.NewUser.username = username
                    self.goToPasswordCreation()
                    self.enableUI()
                }
            }
        }
    }
    
    func goToPasswordCreation() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "passwordCreationViewController") as! PasswordCreationViewController
        VC.modalPresentationStyle = .fullScreen
        VC.NewUser = self.NewUser
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
