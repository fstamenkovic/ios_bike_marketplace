//
//  PickCategoryViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 12/4/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class PickCategoryViewController: UIViewController {
    
    var LoggedInUser: User? = nil
    var reload_delegate: refreshMarkeplace?
    var newPosting: Posting?
    
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

    /*
     * Segue to Add images.
     */
    @IBAction func addImagesPressed() {
        
        guard let bike_category = categoryPickerImplementation.getCategory() else{
            print("could not unwrap bike category")
            return
        }
        
        guard let bike_color = colorPickerImplementation.getColor() else {
            print("could not unwrap bike color")
            return
        }
        
        newPosting?.bike_color = bike_color
        newPosting?.bike_type = bike_category
        
        let storyboard = UIStoryboard(name: "marketplace", bundle: nil)
        let addImagesVC = storyboard.instantiateViewController(identifier: "imageAddViewController") as! ImageAddViewController

        addImagesVC.newPosting = newPosting
        addImagesVC.reload_delegate = reload_delegate
        addImagesVC.LoggedInUser = LoggedInUser
        addImagesVC.modalPresentationStyle = .fullScreen
        
        self.navigationController?.pushViewController(addImagesVC, animated: true)
    }

}

/*
 * Implements the delegates for the category picker.
 */
class categoryPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let categories = ["Road", "Mountain", "Super cruiser", "Racing", "Unicycle"]
    var current_selection = 0
    
    // getter method
    func getCategory() -> String? {
        return categories[current_selection]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
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

/*
 * Implements the delegates for the color picker.
 */
class colorPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let colors = ["Blue", "Red", "Yellow", "Orange", "Green", "Black", "White", "Pink", "Purple", "Brown"]
    var selection = 0
    
    func getColor() -> String?{
        return colors[selection]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
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
