//
//  UserLoginViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var username_textField: UITextField!
    @IBOutlet weak var password_textField: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var errorLabel_textField: UITextField!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Init()
    }
    
    
    @IBAction func loginButtonPressed() {
        
        disableUI()
        
        guard let username = username_textField.text else {
            print("error while unwrapping the username entered in username_textField")
            return
        }
        
        guard let passwd = password_textField.text else {
            print("error while unwrapping the username entered in password_textField")
            return
        }
        
        // greatly simplify the login process.
        Auth.auth().signIn(withEmail: username + "@bikemarketplace.com", password: passwd) { authResult, error in
            
            if error != nil {
                self.enableUI()
                self.errorLabel_textField.text = error?.localizedDescription
                self.errorLabel_textField.isHidden = false
            } else {
                self.username_textField.text = ""
                self.password_textField.text = ""
                self.errorLabel_textField.isHidden = true
                self.enableUI()
                self.goToBikeFeedView(username: username)
            }
        }
        
        /*
        Auth.auth().signIn(withEmail: username + "@bikemarketplace.com", password: passwd) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            strongSelf.activity_indicator.isHidden = false;
            
            if (error != nil) {
                print(error.debugDescription)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    strongSelf.activity_indicator.isHidden = true
                    strongSelf.errorLabel_textField.text = error?.localizedDescription
                    strongSelf.errorLabel_textField.isHidden = false
                    strongSelf.view.isUserInteractionEnabled = true
                })
                
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1 , execute: {
                    strongSelf.goToBikeFeedView(username: username)
                    strongSelf.activity_indicator.isHidden = true
                    strongSelf.view.isUserInteractionEnabled = true
                })
            }
        } */
    }
    
    
    @IBAction func signUpPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "profileSetupViewController") as! ProfileSetupViewController
        VC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func Init() {
        errorLabel_textField.isHidden = true
        self.activity_indicator.isHidden = true
    }
    
    func enableUI(){
        self.view.isUserInteractionEnabled = true
        self.activity_indicator.isHidden = true
    }
    
    func disableUI(){
        self.view.isUserInteractionEnabled = false
        self.activity_indicator.isHidden = false
    }
    
    /* In this case we will present the Navigation Controller of the
     * "marketplace" storyboard, and we will specify the root View
     * Controller to be the BikeFeedViewController.
     */
    func goToBikeFeedView(username: String) {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "bikeFeedViewController") as! BikeFeedViewController
        VC.username = username
        let VC_nav = UINavigationController(rootViewController: VC)
        VC_nav.modalPresentationStyle = .fullScreen
        self.present(VC_nav, animated: true, completion: nil)
    }
    
}
