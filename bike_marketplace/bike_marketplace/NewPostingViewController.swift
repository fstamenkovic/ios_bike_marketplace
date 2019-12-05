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
    
    @IBOutlet weak var category_picker: UIPickerView!
    @IBOutlet weak var color_picker: UIPickerView!
    @IBOutlet weak var posting_description: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var posting_title: UITextField!
    
    
    
    // classes that implement picker functionality
    let categoryPickerImplementation = categoryPicker()
    let colorPickerImplementation = colorPicker()

    var reload_delegate: refreshMarkeplace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        color_picker.dataSource = colorPickerImplementation
        category_picker.dataSource = categoryPickerImplementation
        color_picker.delegate = colorPickerImplementation
        category_picker.delegate = categoryPickerImplementation
        
        // Do any additional setup after loading the view.
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
        
        print(description)
        print(title)
        
        guard let bike_category = categoryPickerImplementation.getCategory() else{
            print("could not unwrap bike category")
            return
        }
        
        guard let bike_color = colorPickerImplementation.getColor() else {
            print("could not unwrap bike color")
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
        
        let new_posting = Posting(title: title, description: description, bike_color: bike_color, bike_type: bike_category, price: price, poster_number: user_phone)
        
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        print("print")
        let newPostingVC = storyboard.instantiateViewController(identifier: "imageAddViewController") as! ImageAddViewController

        newPostingVC.newPosting = new_posting
        newPostingVC.reload_delegate = reload_delegate
        newPostingVC.LoggedInUser = LoggedInUser
        newPostingVC.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(newPostingVC, animated: true)
    }
}

class categoryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let categories = ["Road", "Mountain", "Super cruiser"]
    var current_selection = 0
    
    // getter method
    func getCategory() -> String? {
        return categories[current_selection]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    // tell pickerView the name of account at "row" index
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    // update the pickerView selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        current_selection = row
    }
    
}

class colorPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let colors = ["Blue", "Red", "Yellow"]
    var selection = 0
    
    func getColor() -> String?{
        return colors[selection]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    // tell pickerView the name of account at "row" index
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colors[row]
    }
    
    // update the pickerView selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selection = row
    }
    
}
