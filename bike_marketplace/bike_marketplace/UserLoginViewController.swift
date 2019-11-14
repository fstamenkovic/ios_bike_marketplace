//
//  UserLoginViewController.swift
//  bike_marketplace
//
//  Created by Ryland Sepic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class UserLoginViewController: UIViewController {
    
    @IBOutlet weak var username_textField: UITextField!
    @IBOutlet weak var password_textField: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var signup_button: UIButton!
    @IBOutlet weak var errorLabel_textField: UITextField!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Init()
    }
    
    func Init() {
        errorLabel_textField.isHidden = true
    }
}
