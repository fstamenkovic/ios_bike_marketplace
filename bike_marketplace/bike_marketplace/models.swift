//
//  models.swift
//  bike_marketplace
//
//  Created by Filip Stamenkovic on 11/19/19.
//  Copyright © 2019 189e-tigers. All rights reserved.
//

// This file is to define our models

import Foundation


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
