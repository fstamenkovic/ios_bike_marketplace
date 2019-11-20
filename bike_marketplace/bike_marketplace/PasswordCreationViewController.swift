//
//  PasswordCreationViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/13/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class PasswordCreationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel_textField: UITextField!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var new_password_textField: UITextField!
    @IBOutlet weak var confirm_password_textField: UITextField!
    @IBOutlet weak var submit_button: UIButton!
    
    var username: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        Init()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func passwordFieldChanged() {
        
        guard let enteredPassword = new_password_textField.text else {
            print("error unwrapping the entered password on password setup view")
            return
        }
        
        if passwordIsValid(enteredPassword) {
            errorLabel_textField.isHidden = true
            submit_button.isUserInteractionEnabled = true
        } else {
            submit_button.isUserInteractionEnabled = false
            errorLabel_textField.text = "Please enter a password with a length 8-16 characters, including at least one number and one special character (@$!%*#?&)."
            errorLabel_textField.isHidden = false
        }
    }
    
    @IBAction func confirmPasswordFieldChanged() {
        if (new_password_textField.text != confirm_password_textField.text) {
            errorLabel_textField.text = "The passwords don't match."
            errorLabel_textField.isHidden = false
            submit_button.isUserInteractionEnabled = false
        } else {
            errorLabel_textField.isHidden = true
            submit_button.isUserInteractionEnabled = true
        }
        
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        errorLabel_textField.isHidden = true
        disableUI()
        
        let db = Firestore.firestore()
        
        guard let enteredPassword = new_password_textField.text else {
            print("error unwrapping the entered password on password setup view")
            return
        }
        
        Auth.auth().createUser(withEmail: username + "@bikemarketplace.com", password: enteredPassword) { authResult, error in
            
            if (error != nil) {
                self.enableUI()
            } else {
                guard let uid = authResult?.user.uid else {
                print("error unwrapping uid returned from user creation firebase api call")
                    return
                }
                db.collection("usernames").document(self.username).setData([ "uid":uid]){ (error) in
                    if (error != nil) {
                        print("error adding user to usernames collection")
                    }
                }
                
                self.goToPhoneEntryView()
                self.enableUI()
            }
            
        }
    }
    
    func passwordIsValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,16}$")
        return passwordTest.evaluate(with: password)
    }
    
    func goToPhoneEntryView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "phoneEntryViewController") as! PhoneEntryViewController
        VC.modalPresentationStyle = .fullScreen
        VC.username = username
        self.navigationController?.pushViewController(VC, animated: true)
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    func Init() {
        submit_button.isUserInteractionEnabled = false
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
