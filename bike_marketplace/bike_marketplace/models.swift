//
//  models.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/19/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

// This file is to define our models

import Foundation

// Firebase already has a class name User, we may need to change the name of this to avoid confusion
class User {
    var username: String
    var phone_number: String
    var user_postings: [String]
    
    init() {
        self.username = ""
        self.phone_number = ""
        self.user_postings = [String]()
    }
    
    init(username: String, phone_number: String, user_postings: [String]) {
        self.username = username
        self.phone_number = phone_number
        self.user_postings = user_postings
    }
}

class Posting {
    var title: String = ""
    var description: String = ""
    var bike_color: String = ""
    var bike_type: String = ""
    var price: String = ""
    
    init(title: String, description:String, bike_color:String, bike_type:String, price: String){
        self.title = title
        self.description = description
        self.bike_color = bike_color
        self.bike_type = bike_type
        self.price = price
    }
}
