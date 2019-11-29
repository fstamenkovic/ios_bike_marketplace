//
//  ImageAddViewController.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/12/19.
//  Ryland Sepic worked on this too
//  Copyright © 2019 189e-tigers. All rights reserved.
//

import UIKit
import Firebase

// make the bike feed implement this protocol. this protocol allows this
// this View Controller to reload all postings on the bike feed
protocol refreshMarkeplace{
    func reloadTable()
}

// Import: UIImagePickerControllerDelegate to support pictures
class ImageAddViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // posting to be passed in from NewPostingViewController
    var newPosting: Posting? = nil
    var image_delegate = UIImagePickerController()
    
    // Image support
    @IBOutlet weak var picture: UIImageView!
    var image_arr: [UIImage] = []
    @IBOutlet weak var remove_button: UIButton!
    @IBOutlet var swipe_right: UISwipeGestureRecognizer!
    @IBOutlet var swipe_left: UISwipeGestureRecognizer!

    var reload_delegate :refreshMarkeplace?
    @IBOutlet weak var activity_indicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        enableUI()
        // Do any additional setup after loading the view.
    }

    
    @IBAction func choose_image(_ sender: Any) {
        // Delegate source type (camera, photo library, or saved photos album)
        image_delegate.sourceType = UIImagePickerController.SourceType.photoLibrary
        image_delegate.delegate = self
     
        // Make sure device allows application to access the photo library
        if (!UIImagePickerController.isSourceTypeAvailable(image_delegate.sourceType)) {
            print("Source type is not availabe on the device")
            return
        }
            
        activity_indicator.startAnimating()
        activity_indicator.isHidden = false
        present(image_delegate, animated: true) {
            self.activity_indicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
        }
        
        return
    }
    
    @IBAction func prev(_ sender: UISwipeGestureRecognizer) {
        if image_arr.count == 0 {
           return
       } // Array is emtpy
       
       // Unwrap the image that is currently being shown
       guard let im = picture.image else {
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
       picture.image = image_arr[i]
    }
    
    // The sender is a swipe gesture recognizer
    @IBAction func next(_ sender: UISwipeGestureRecognizer) {
        if image_arr.count == 0 {
            return
        } // Array is emtpy
        
        // Unwrap the image that is currently being shown
        guard let im = picture.image else {
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
        picture.image = image_arr[i]
    }
    
    
    @IBAction func remove_image(_ sender: Any) {
        // Unwrap the image that is currently being shown
        guard let im = picture.image else {
            return
        }
        
        // Find the displayed image in the image array
        // If the image does not exist in the array then set i to 0
        var i: Int = image_arr.firstIndex(of: im) ?? 0
        image_arr.remove(at: i)
        
        if image_arr.count == 0 {
            enableUI()  // Reset the UI
            return
        }
        
        // Calculate index of the next image
        if i + 1 >= image_arr.count {
            i = 0
        } else {
            i += 1
        }
        
        // Display the next image
        picture.image = image_arr[i]
    }
    
    @IBAction func postClicked() {
        guard let posting = newPosting else {
            print("could not retreive the posting")
            return
        }
        
        disableUI()
        
        let db = Firestore.firestore()
        
        let ref = db.collection("postings")
        
        ref.addDocument(data: [
            "category": posting.bike_type,
            "color": posting.bike_color,
            "description": posting.description,
            "title": posting.title,
            "price": posting.price]){error in
                if error != nil {
                    print("there was an error posting this")
                    self.enableUI()
                } else {
                    print("posted posting successfully!")
                    // have the bike feed reload the table to contain this posting as well
                    self.reload_delegate?.reloadTable()
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }

    func enableUI(){
        view.isUserInteractionEnabled = true
        activity_indicator.hidesWhenStopped = true
        remove_button.isHidden = true
        picture.isUserInteractionEnabled = true // Allows the user to interact with the picture
        swipe_left.direction = .left
        picture.image = UIImage(named: "Picture File")
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
    }
    
    // This is a delegate function for selecting images
    // It is invoked when the user selects on a photo in the photo album
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Unwrap the original image from teh photo library
        guard let pic = info[.originalImage] as? UIImage else {
            print("Image not loaded")
            return
        }

        picture.image = pic // Display image
        image_arr.append(pic)   // Push the selected image into the image array
        
        dismiss(animated: true) { // Dismiss the photo library
            if self.image_arr.count > 0 {
                self.remove_button.isHidden = false
            }
        }
    }
}
