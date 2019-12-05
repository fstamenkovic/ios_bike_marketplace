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
    
    var LoggedInUser: User? = nil
    
    
    @IBOutlet weak var posting_description: UITextView!
    
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var posting_title: UITextField!

    var reload_delegate: refreshMarkeplace?
    
    let description_implementation = descriptionTextFields()
    let title_implementation = titleTextFields()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextInput()
        // Do any additional setup after loading the view.
    }

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

    // proceed to add Images
    
    @IBAction func addImagesClicked() {
        guard let title = posting_title.text else {
            print("Could not unwrap the title.")
            return
        }
        
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
        
        if price == "" || Int(price) == nil{
            let alert = UIAlertController(title: "Invalid Input", message: "Invalid price field.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: {(action) -> Void in
                
            }))
            
            self.present(alert, animated: true)
            
            return
        }
        let phonenumkit = PhoneNumberKit()
        
        var user_phone = ""
        
        do{
            let phone_num = try phonenumkit.parse(LoggedInUser?.phone_number ?? "")
            
            user_phone = phonenumkit.format(phone_num, toType: .national)
        }
        catch{
            print("There was en error with parsing")
        }
        
        let new_posting = Posting(title: title, description: description, bike_color: "", bike_type: "", price: price, poster_number: user_phone)
        
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let newPostingVC = storyboard.instantiateViewController(identifier: "pickCategoryViewController") as! PickCategoryViewController

        newPostingVC.newPosting = new_posting
        newPostingVC.reload_delegate = reload_delegate
        newPostingVC.LoggedInUser = LoggedInUser
        newPostingVC.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(newPostingVC, animated: true)
    }
}



class descriptionTextFields: UITextView, UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 150    // 10 Limit Value
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description"
            textView.textColor = UIColor.lightGray
        }
    }
}

class titleTextFields: UITextField, UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 25
    }
}
