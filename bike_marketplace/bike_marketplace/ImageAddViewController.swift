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
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions

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
    
    
    @IBOutlet weak var browse_button: UIButton!
    
    @IBOutlet weak var swipe_label: UILabel!
    
    
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
        swipe_label.isHidden = true
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
    
    // This puts in the post data from the NewPostingViewController
    @IBAction func postClicked() {
       // Makes sure that there is post data passed in from NewPostingViewController
        guard let posting = newPosting else {
            print("could not retreive the posting")
            return
        }
        
        let functions = Functions.functions()
        
        functions.httpsCallable("update_user").call(["bike_type": posting.bike_type, "bike_color": posting.bike_color], completion: {(data, err) -> Void in
            
        })
        
        posting.time_created = Int64(NSDate().timeIntervalSince1970 * 1000)
        
        disableUI() // Prevent user interaction
        
        // Create unique names for images
        var image_name: [String] = []
        for _ in image_arr {
            image_name.append(UUID().uuidString)
        }
        let db = Firestore.firestore()
        let ref = db.collection("postings")
        
        var document_ref: DocumentReference? = nil
        
        document_ref = ref.addDocument(data: [
            "category": posting.bike_type,
            "color": posting.bike_color,
            "description": posting.description,
            "title": posting.title,
            "price": posting.price,
            "image_ID": FieldValue.arrayUnion(image_name),
            "time_created": posting.time_created ]){error in
                if error != nil {
                    print("there was an error posting this")
                    self.enableUI()
                    
                } else {
                    print("posted posting successfully!")
                    
                    let user = Auth.auth().currentUser
                    guard let user_uid = user?.uid else {
                        print("Could not unwrap user id")
                        return
                    }
                    
                    guard let doc_ref = document_ref?.documentID else {
                        print("Error: Document reference does not exist")
                        return
                    }   // Unwrap the ID number of the post
                    
                    let directory_ref = Storage.storage().reference().child(doc_ref) // Create reference for directory with the user ID
                    
                    self.uploadPics(image_names: image_name, ref: directory_ref)    // Load photos onto Firebase storage
                    
                    let ref_user = db.collection("users").document("\(user_uid)")
                    ref_user.updateData([
                        "user_postings" : FieldValue.arrayUnion(["\(document_ref!.documentID)"])
                    ])
                    
                    // have the bike feed reload the table to contain this posting as well
                    self.reload_delegate?.reloadTable()
                    self.navigationController?.popToRootViewController(animated: true)
                }
        }
        
    }
    
    
    func uploadPics(image_names: [String], ref: StorageReference) {
        // Iterate through all of the photos in the image_arr array
        for i in 0 ..< self.image_arr.count {
            // Convert the photo into a jpeg
            guard let data = self.image_arr[i].jpegData(compressionQuality: 1.0) else {
                print("Error in getting image data")
                return
            }
            
            let storage_ref = ref.child(image_names[i]) // Storage reference is the unique name of the image, which is in the directory that is named after the post
            
            // Uploads the data to storage
            storage_ref.putData(data, metadata: nil) {(metadata, err) in
                if let err = err {
                    print("Error: \(err.localizedDescription)")
                    return
                }
            }
        } // For
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
                self.swipe_label.isHidden = false
            }
            
            if(self.image_arr.count != 0){
                self.browse_button.setTitle("Add more images", for: .normal)
            }
        }
    }
}
