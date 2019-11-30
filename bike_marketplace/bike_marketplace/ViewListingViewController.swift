//
//  ViewListingViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase

class ViewListingViewController: UIViewController {

    // posting to be displayed
    var posting: Posting?
    var images: [UIImage]? = nil
    
    @IBOutlet weak var posting_name: UILabel!
    @IBOutlet weak var price_label: UILabel!
    @IBOutlet weak var description_label: UILabel!
    @IBOutlet weak var category_label: UILabel!
    @IBOutlet weak var color_label: UILabel!
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet var swipe_right: UISwipeGestureRecognizer!
    @IBOutlet var swipe_left: UISwipeGestureRecognizer!
    
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
    
    @IBAction func prev(_ sender: UISwipeGestureRecognizer) {
        guard let image_arr = posting?.images else {
            print("No images")
            image.image = UIImage(named: "no photo")
            return
        } // There are no images for this post
        
        if image_arr.count == 0 {
            return
        } // The array is empty
       
       // Unwrap the image that is currently being shown
       guard let im = image.image else {
           return
       }
        
       // Find the displayed image in the image array
       // If the image does not exist in the array then set i to 0
       var i: Int = image_arr.firstIndex(of: im) ?? 0
       
       // Calculate index of the next image
       if i - 1 < 0 {
           i = image_arr.count - 1
       } else {
           i -= 1
       }
       
       // Display the next image
       image.image = image_arr[i]
    }
    
    // The sender is a swipe gesture recognizer
    @IBAction func next(_ sender: UISwipeGestureRecognizer) {
        guard let image_arr = posting?.images else {
            print("No images")
            image.image = UIImage(named: "no photo")
            return
        } // There are no images for this post
        
        if image_arr.count == 0 {
            return
        } // The array is empty
        
        // Unwrap the image that is currently being shown
        guard let im = image.image else {
            return
        }
        
        // Find the displayed image in the image array
        // If the image does not exist in the array then set i to 0
        var i: Int = image_arr.firstIndex(of: im) ?? 0

        // Calculate index of the next image
        if i + 1 >= image_arr.count {
            i = 0
        } else {
            i += 1
        }
        
        // Display the next image
        image.image = image_arr[i]
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
        
        self.swipe_left.direction = .left   // Enable swipe left function
        self.image.isUserInteractionEnabled = true  // Allow user to interact with UIImage
        
        if posting?.images.count == 0 {
            image.image = UIImage(named: "no photo")
        } else {
            image.image = posting?.images[0]
        }
    }
}
