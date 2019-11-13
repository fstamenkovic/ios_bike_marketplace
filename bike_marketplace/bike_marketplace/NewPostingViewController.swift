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

    // proceed to add Images
    
    @IBAction func addImagesClicked() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        print("print")
        let newPostingVC = storyboard.instantiateViewController(identifier: "imageAddViewController") as! ImageAddViewController
        // pass the information to AccountViewController
        newPostingVC.modalPresentationStyle = .fullScreen
        
        print("print2")
        self.present(newPostingVC, animated: true, completion: nil)
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
