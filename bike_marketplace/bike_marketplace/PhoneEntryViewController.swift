//
//  PhoneEntryViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/13/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit

class PhoneEntryViewController: UIViewController {

    @IBOutlet var areaCode_button: UIButton!
    @IBOutlet var phoneNumber_textField: PhoneNumberTextField!
    @IBOutlet var submit_button: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var activity_indicator: UIActivityIndicatorView!
    
    var NewUser: User = User()
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
     * Checks phone number validity, creates new account.
     */
    @IBAction func submitButtonPressed() {
        self.disableUI()
        errorLabel.isHidden = true
        
        guard let userInputPhoneNumber = phoneNumber_textField.text else {
            print("error unwrapping phone number input by user in phone entry screen")
            return
        }
        
        let phoneNumberKit = PhoneNumberKit()
        
        // Checks if phone number is valid. If so, create account.
        do {
            let parsedPhoneNumber = try phoneNumberKit.parse(userInputPhoneNumber)
            
            self.NewUser.phone_number = phoneNumberKit.format(parsedPhoneNumber, toType: .e164)
            
            createAccount(username: self.NewUser.username, password: self.password, phoneNumber: self.NewUser.phone_number)
        }
        catch {
            errorLabel.text = "Please enter a valid number."
            errorLabel.isHidden = false
            self.enableUI()
        }
    }
  
    /*
     * Creates account and takes user to the marketplace.
     */
    func createAccount(username: String, password: String, phoneNumber: String) {
        
        // Adds username and password to Authentication tab in Firebase, this function generates the uid
        Auth.auth().createUser(withEmail: username + "@bikemarketplace.com", password: password) { authResult, error in
            
            if (error != nil) {
                self.enableUI()
                print("error during firebase API createUser call")
            } else {
                guard let uid = authResult?.user.uid else {
                    print("error unwrapping uid returned from user creation firebase api call")
                    return
                }
                
                // initialize user info in database.
                self.initUser(uid: uid)
            }
        }
    }
    
    /*
     * Creates a document for the user in the Firebase Database.
     */
    func initUser(uid: String) {
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).setData([
            "username" : self.NewUser.username,
            "phone_number" : self.NewUser.phone_number,
            "user_postings": self.NewUser.user_postings,
            "fav_color": "",
            "fav_category": ""
        ]) { error in
            if error != nil {
                print("error adding document containing username and phonenumber to users collection")
            } else {
                print("User document initialized")
                self.goToBikeFeedView()
                self.enableUI()
            }
        }
    }
    
    /*
    * In this case we will present the Navigation Controller of the
    * "marketplace" storyboard, and we will specify the root View
    * Controller to be the BikeFeedViewController.
    */
    func goToBikeFeedView() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "bikeFeedViewController") as! BikeFeedViewController
        VC.LoggedInUser = self.NewUser
        let VC_nav = UINavigationController(rootViewController: VC)
        VC_nav.modalPresentationStyle = .fullScreen
        self.present(VC_nav, animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
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
