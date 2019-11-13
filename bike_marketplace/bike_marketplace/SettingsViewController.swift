//
//  SettingsViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
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
            textField.placeholder = "Enter Password"
            textField.becomeFirstResponder()
        })
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            textField.resignFirstResponder()
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
    
    
    
}
