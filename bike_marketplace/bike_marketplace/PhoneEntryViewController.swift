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
    @IBOutlet var errorLabel_textField: UITextField!
    @IBOutlet var activity_indicator: UIActivityIndicatorView!
    
    var username: String = ""
    var userDocID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitButtonPressed() {
        self.view.isUserInteractionEnabled = false
        errorLabel_textField.isHidden = true
        activity_indicator.isHidden = false
        
        guard let userInputPhoneNumber = phoneNumber_textField.text else {
            print("error unwrapping phone number input by user in phone entry screen")
            return
        }
        
        let phoneNumberKit = PhoneNumberKit()
        
        do {
            let parsedPhoneNumber = try phoneNumberKit.parse(userInputPhoneNumber)
            
            let phoneNumber = phoneNumberKit.format(parsedPhoneNumber, toType: .national)
            
            initializeUserInfoInDatabase(username: self.username, phoneNumber: phoneNumber)
            activity_indicator.isHidden = true
            goToBikeFeedView()
            self.view.isUserInteractionEnabled = true
        }
        catch {
            print("error parsing user input phone number with PhoneNumberKit")
            
            activity_indicator.isHidden = true
            errorLabel_textField.text = "Please enter a valid number."
            errorLabel_textField.isHidden = false
            self.view.isUserInteractionEnabled = true
        }
    }
  /*  func phoneNumberNotAlreadyInUse(phoneNumber: String) -> Bool {
        
        var notAlreadyInUse = false
        
        let db = Firestore.firestore()
        
        let users = db.collection("users")
        
        let userWithSamePhoneNumber = users.whereField("phonenumber", isEqualTo: phoneNumber).getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error searching for users with same phone number: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                    }

                   print("phone number is already in use, enter a different number")
                    self.errorLabel_textField.text = "This phone number is already in use."
                    self.errorLabel_textField.isHidden = false
                    notAlreadyInUse = true
                }
        }
        
        return notAlreadyInUse
    } */
    func initializeUserInfoInDatabase(username: String, phoneNumber: String) {
        let db = Firestore.firestore()
        
        let docRef = db.collection("usernames").document(username)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                guard let uid = document.get("uid") else {
                    print("error unwrapping uid read from usernames collection in firebase")
                    return
                }
                
                let users = db.collection("users")
                
                var newuser: DocumentReference? = nil
                
                newuser = users.addDocument(data: [
                    "uid" : uid,
                    "username" : username,
                    "phonenumber" : phoneNumber
                ]) { error in
                    if let error = error {
                        print("error adding document containing uid, username, and phonenumber to users collection")
                    } else {
                        print("Document added with ID: \(newuser!.documentID)")

                    }
                }
            } else {
                print("no document exists in usernames collection for given username")
            }
        }
    }
    
    func goToBikeFeedView() {
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        //let VC = storyboard.instantiateViewController(identifier: "bikeFeedViewController") as! BikeFeedViewController
        let VC = storyboard.instantiateViewController(identifier: "nav2") as! UINavigationController
        VC.modalPresentationStyle = .fullScreen
        //VC.username = username
        self.present(VC, animated: true, completion: nil)
    }
    
}
