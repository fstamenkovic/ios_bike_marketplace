//
//  ViewListingViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class ViewListingViewController: UIViewController {

    // posting to be displayed
    var posting: Posting?
    
    @IBOutlet weak var posting_name: UILabel!
    
    @IBOutlet weak var price_label: UILabel!
    
    @IBOutlet weak var description_label: UILabel!
    
    @IBOutlet weak var category_label: UILabel!
    
    @IBOutlet weak var color_label: UILabel!
    
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func contactPressed() {
        // TODO: Enable Firebase to store the posting user
        let alert = UIAlertController(title: "Contact Info", message: "Mike, +15109271241", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
     
        self.present(alert, animated: true)
    }
    
    func enableUI(){
        view.isUserInteractionEnabled = true
        activity_indicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activity_indicator.isHidden = false
    }
    
    func initUI(){
        enableUI()
        
        guard let posting_unwrapped = posting else {
            print("posting was nil")
            return
        }
        
        posting_name.text = posting_unwrapped.title
        price_label.text = "$\(posting_unwrapped.price)"
        description_label.text = posting_unwrapped.description
        category_label.text = posting_unwrapped.bike_type
        color_label.text = posting_unwrapped.bike_color
    }
}
