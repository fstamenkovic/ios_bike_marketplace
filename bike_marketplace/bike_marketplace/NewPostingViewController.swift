//
//  NewPostingViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import PhoneNumberKit

class NewPostingViewController: UIViewController {
    
    var LoggedInUser: User? = nil // current user
    
    @IBOutlet weak var posting_description: UITextView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var posting_title: UITextField!

    var reload_delegate: refreshMarkeplace?
    
    // Delegate implementations for text input fields.
    let description_implementation = descriptionTextFields()
    let title_implementation = titleTextFields()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextInput()
        // Do any additional setup after loading the view.
    }

    /*
     * Sets up the text fields for title and description.
     * posting_description is a UITextView, need to configure it to be consistent
     * with UITextField.
     */
    func setupTextInput(){
        posting_description.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        posting_description.layer.borderWidth = 0.5
        posting_description.layer.cornerRadius = 5
        posting_description.delegate = description_implementation
        posting_description.text = "Enter description"
        posting_description.textColor = UIColor.lightGray
        
        posting_title.delegate = title_implementation
        price.keyboardType = UIKeyboardType.decimalPad
    }
    
    
    @IBAction func screenTapped(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func addImagesClicked() {
        guard let title = posting_title.text else {
            print("Could not unwrap the title.")
            return
        }
        
        // check if title is empty, present an error if so.
        if title == ""{
            let alert = UIAlertController(title: "Invalid Input", message: "Your posting title is empty.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: {(action) -> Void in
                
            }))
            
            self.present(alert, animated: true)
            
            return
        }
        
        guard let description = posting_description.text else {
            print("Could not unwrap description.")
            return
        }
        
        // check if description is empty, present error if so.
        if description == ""{
            let alert = UIAlertController(title: "Invalid Input", message: "Your posting description is empty.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: {(action) -> Void in
                
            }))
            
            self.present(alert, animated: true)
            
            return
        }
        
        guard let price = price.text else {
            print("Could not get the price")
            return
        }
        
        // check if price is empty or somehow not an Int. If so, present error.
        if price == "" || Int(price) == nil{
            let alert = UIAlertController(title: "Invalid Input", message: "Invalid price field.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: {(action) -> Void in
                
            }))
            
            self.present(alert, animated: true)
            
            return
        }
        let phonenumkit = PhoneNumberKit()
        
        var user_phone = ""
        
        // convert phone number from .e164 to national since it looks better.
        do{
            let phone_num = try phonenumkit.parse(LoggedInUser?.phone_number ?? "")
            
            user_phone = phonenumkit.format(phone_num, toType: .national)
        }
        catch{
            print("There was en error with parsing")
        }
        
        // create a Posting class instance with initializers.
        let new_posting = Posting(title: title, description: description, bike_color: "", bike_type: "", price: price, poster_number: user_phone)
        
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let pickCategoryVC = storyboard.instantiateViewController(identifier: "pickCategoryViewController") as! PickCategoryViewController

        pickCategoryVC.newPosting = new_posting
        pickCategoryVC.reload_delegate = reload_delegate
        pickCategoryVC.LoggedInUser = LoggedInUser
        pickCategoryVC.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(pickCategoryVC, animated: true)
    }
}


/*
 * Delegate implementation for the description TextView.
 */
class descriptionTextFields: UITextView, UITextViewDelegate{
    
    // Limit number of characters to 150.
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 150    // 10 Limit Value
    }
    
    // Delete placeholder text if there is text in the field.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    // Enter placeholder if textView empty.
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description"
            textView.textColor = UIColor.lightGray
        }
    }
}

/*
 * Delegate implementation for the title textField.
 */
class titleTextFields: UITextField, UITextFieldDelegate{
    
    // limit number of characters to 20.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 25
    }
}
