//
//  NewPostingViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class NewPostingViewController: UIViewController {
    
    @IBOutlet weak var category_picker: UIPickerView!
    @IBOutlet weak var color_picker: UIPickerView!
    
    @IBOutlet weak var posting_title: UITextField!
    
    @IBOutlet weak var posting_description: UITextField!
    
    @IBOutlet weak var price: UITextField!
    
    
    // classes that implement picker functionality
    let categoryPickerImplementation = categoryPicker()
    let colorPickerImplementation = colorPicker()
    
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
        guard let description = posting_description.text else {
            print("Could not unwrap description.")
            return
        }
        
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
        
        let new_posting = Posting(title: title, description: description, bike_color: bike_color, bike_type: bike_category, price: price)
        
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        print("print")
        let newPostingVC = storyboard.instantiateViewController(identifier: "imageAddViewController") as! ImageAddViewController

        newPostingVC.newPosting = new_posting
        newPostingVC.modalPresentationStyle = .fullScreen
        
        print("print2")
        self.present(newPostingVC, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
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
