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

    @IBOutlet weak var picture: UIImageView!
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
     //   image_delegate.allowsEditing = true  // Editing view shows up
        
        // Make sure device allows application to access the photo library
        if (!UIImagePickerController.isSourceTypeAvailable(image_delegate.sourceType)) {
            print("Source type is not availabe on the device")
            return
        }
        
        present(image_delegate, animated: true, completion: nil)
        return
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
        activity_indicator.isHidden = true
    }
    
    func disableUI(){
        view.isUserInteractionEnabled = false
        activity_indicator.isHidden = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let pic = info[.originalImage] as? UIImage else {
            print("Image not loaded")
            return
        }

        picture.image = pic
        dismiss(animated: true, completion: nil)
    }
}
