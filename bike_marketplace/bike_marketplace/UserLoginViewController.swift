//
//  UserLoginViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var username_textField: UITextField!
    @IBOutlet weak var password_textField: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    var ExistingUser: User = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func loginButtonPressed() {
        
        disableUI()
        self.errorLabel.isHidden = true
        
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
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.isHidden = false
            } else {
                self.grabUserInfoThenTransition()
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
        self.disableUI()
        self.goToProfileSetupView()
        self.errorLabel.isHidden = true
        self.clearTextFields()
        self.enableUI()
    }
    
    func Init() {
        errorLabel.isHidden = true
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
    
    func grabUserInfoThenTransition() {
        
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else {
            print("error unwrapping uid from Firebase currentUser.uid")
            return
        }
        
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(uid)
        
        userDoc.getDocument { (document, error) in
            if let document = document {
                let username = document.get("username") as? String ?? ""
                let phone_number = document.get("phone_number") as? String ?? ""
                let user_postings = document.get("user_postings") as? Array ?? [""]
                let fav_color = document.get("fav_color") as? String ?? ""
                let fav_category = document.get("fav_category") as? String ?? ""
                let last_load = document.get("last_load") as? Int64 ?? 0
                
                self.ExistingUser = User(username: username, phone_number: phone_number, user_postings: user_postings, fav_color: fav_color, fav_category: fav_category, last_load: last_load)
                
                self.goToBikeFeedView()
                self.clearTextFields()
                self.enableUI()
            }
        }
    }
    
    func clearTextFields() {
        self.username_textField.text = ""
        self.password_textField.text = ""
    }
    
    /* In this case we will present the Navigation Controller of the
     * "marketplace" storyboard, and we will specify the root View
     * Controller to be the BikeFeedViewController.
     */
    func goToBikeFeedView() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "bikeFeedViewController") as! BikeFeedViewController
        VC.LoggedInUser = ExistingUser
        let VC_nav = UINavigationController(rootViewController: VC)
        VC_nav.modalPresentationStyle = .fullScreen
        self.present(VC_nav, animated: true, completion: nil)
    }
    
    func goToProfileSetupView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "profileSetupViewController") as! ProfileSetupViewController
        VC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(VC, animated: true)
    }
}
