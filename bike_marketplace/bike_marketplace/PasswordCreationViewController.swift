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
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var new_password_textField: UITextField!
    @IBOutlet weak var confirm_password_textField: UITextField!
    @IBOutlet weak var submit_button: UIButton!
    
    // I feel like passing the password between view controllers is a bad idea or having a global password variable in general
    var NewUser: User = User()
    var password: String = ""

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
            errorLabel.isHidden = true
            confirm_password_textField.isUserInteractionEnabled = true
        } else {
            submit_button.isUserInteractionEnabled = false
            confirm_password_textField.isUserInteractionEnabled = false
            errorLabel.text = "Please enter a password with a length 8-16 characters, including at least one number and one special character (@$!%*#?&)."
            errorLabel.isHidden = false
        }
    }
    
    @IBAction func confirmPasswordFieldChanged() {
        if (new_password_textField.text != confirm_password_textField.text) {
            errorLabel.text = "The passwords don't match."
            errorLabel.isHidden = false
            submit_button.isUserInteractionEnabled = false
        } else {
            errorLabel.isHidden = true
            submit_button.isUserInteractionEnabled = true
        }
        
    }
    @IBAction func submitButtonPressed(_ sender: Any) {
        errorLabel.isHidden = true
        disableUI()
        
        guard let enteredPassword = new_password_textField.text else {
            print("error unwrapping the entered password on password setup view")
            return
        }
        
        self.password = enteredPassword
        
        self.goToPhoneEntryView()
        self.enableUI()
    }
    
    func passwordIsValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,16}$")
        return passwordTest.evaluate(with: password)
    }
    
    func goToPhoneEntryView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "phoneEntryViewController") as! PhoneEntryViewController
        VC.modalPresentationStyle = .fullScreen
        VC.NewUser = self.NewUser
        VC.password = self.password
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
