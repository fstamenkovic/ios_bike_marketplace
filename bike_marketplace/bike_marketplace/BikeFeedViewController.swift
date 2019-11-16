//
//  BikeFeedViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit

class BikeFeedViewController: UIViewController {
    
    var username: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutClicked() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let VC = storyboard.instantiateViewController(identifier: "view") as! ViewController
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
    }
    
    
    @IBAction func newPostingClicked() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newPostingVC = storyboard.instantiateViewController(identifier: "newPostingViewController") as! NewPostingViewController
        newPostingVC.modalPresentationStyle = .fullScreen
        
        self.present(newPostingVC, animated: true, completion: nil)
    }
    
    @IBAction func settingsPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(identifier: "settingsViewController") as! SettingsViewController
        settingsVC.modalPresentationStyle = .fullScreen
        
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    
}
