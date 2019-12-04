//
//  models.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/19/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

// This file is to define our models

import Foundation
import UIKit    // Support UIImage

// Firebase already has a class name User, we may need to change the name of this to avoid confusion
class User {
    var username: String
    var phone_number: String
    var user_postings: [String]
    var fav_color: String
    var fav_category: String
    var last_load: Int64
    
    init() {
        self.username = ""
        self.phone_number = ""
        self.user_postings = [String]()
        self.fav_category = ""
        self.fav_color = ""
        self.last_load = 0
    }
    
    init(username: String, phone_number: String, user_postings: [String], fav_color: String, fav_category: String, last_load: Int64) {
        self.username = username
        self.phone_number = phone_number
        self.user_postings = user_postings
        self.fav_color = fav_color
        self.fav_category = fav_category
        self.last_load = last_load
    }
}

class Posting {
    var title: String = ""
    var description: String = ""
    var bike_color: String = ""
    var bike_type: String = ""
    var price: String = ""
    
    // Metadata
    var doc_id: String = "" // Holds the directory title of the images (same as the post ID)
    var image_ids: [String]? = nil   // Holds the unique name of the image
    var images: [UIImage] = []  // Holds the individual image files themselves
    var time_created: Int64
    
    init(title: String, description:String, bike_color:String, bike_type:String, price: String){
        self.title = title
        self.description = description
        self.bike_color = bike_color
        self.bike_type = bike_type
        self.price = price
        self.time_created = 0
    }
    
    init(title: String, description:String, bike_color:String, bike_type:String, price: String, doc_id: String, image_ids: [String]?, time_created: Int64){
        self.title = title
        self.description = description
        self.bike_color = bike_color
        self.bike_type = bike_type
        self.price = price
        self.doc_id = doc_id
        self.image_ids = image_ids
        self.time_created = time_created
    }
}
