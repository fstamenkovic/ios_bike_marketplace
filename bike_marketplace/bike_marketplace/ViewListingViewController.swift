//
//  ViewListingViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class ViewListingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func contactPressed() {
        let alert = UIAlertController(title: "Contact Info", message: "Mike, +15109271241", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dimiss", style: .default, handler: nil))
     
        self.present(alert, animated: true)
    }
    
}
