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
        updateFavorites()
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
        activity_indicator.startAnimating()
        disableUI()
        
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
        
        disableUI()
        loadImages()
    }
    
    // blocking function that loads images
    func loadImages(){
        guard let local_posting = posting else {
            print("could not unwrap posting")
            return
        }
        
        
        // Get the unique image names ID's
        // If the user did not add images then this will return
        guard let image_names = local_posting.image_ids else {
            print("loadUpImages (ERROR): unable to unwrap image ID's")
            return
        }
        
        print("img_names \(image_names)")
        
        // This is the refernece for the directory which contains all of the images assosciated with the post (AKA the post's id)
        let ref = Storage.storage().reference().child(local_posting.doc_id)
        
        let image_queue = DispatchQueue(label: "image_queue")
        let group = DispatchGroup()
        
        image_queue.async {
            
            var loadingImages: [UIImage] = []
            
            for i in 0 ..< image_names.count {
                // Get the reference for the actual image file (if it exists)
                // Then obtain the data from that image file
                let reference = ref.child(image_names[i])
                
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    reference.getData(maxSize: 5096 * 1024 * 2){ (data, error) in
                        // The error will be invoked if the users picture is deleted from the database
                        if let err = error {
                            print("loadImages(error): \(err.localizedDescription)")
                            return
                        }
                        
                        // Get image data, then convert the compressed data into a UIImage object
                        guard let d = data, let p = UIImage(data: d) else {
                            print("ERROR: image data unable to be unwrapped")
                            return
                        }
                        
                        print("appended")
                        loadingImages.append(p)
                        group.leave()
                    } // reference.getData()
                } // global thread
            } // for
            
            group.wait()
            
            DispatchQueue.main.async{
                print("must happen after")
                self.posting?.images = loadingImages
                
                if self.posting?.images.count == 0 {
                    self.image.image = UIImage(named: "no photo")
                } else {
                    self.image.image = self.posting?.images[0]
                }
                
                self.enableUI()
                self.image.setNeedsDisplay()
                print("all set up, \(self.posting?.images.count)")
            }
        }
    }
    
    func updateFavorites(){
        let user = Auth.auth().currentUser
        
        guard let user_unwrapped = user else{
            print("Could not unwrap user")
            return
        }
        
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(user_unwrapped.uid)
        
        let new_fav_color = posting?.bike_color ?? ""
        let new_fav_category = posting?.bike_type ?? ""
        
        // do not update if categories wrong
        if new_fav_color == "" || new_fav_category == "" {
            return
        }
        
        userDoc.updateData(["fav_color" : new_fav_color ])
        userDoc.updateData(["fav_category": new_fav_category])
    }
}
