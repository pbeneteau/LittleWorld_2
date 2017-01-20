//
//  Users.swift
//  LittleWorld
//
//  Created by antoine beneteau on 2017-01-16.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import CoreLocation
import MapKit

struct User {
    var uid: String
    var lat: Double
    var long: Double
    var name: String
    var status: Bool
    
    init() {
        uid = "1"
        lat = 0.0
        long = 0.0
        name = "John Doe"
        status = false
    }
}

struct UserTable {
    
    var uid : String!
    var user : User!
}

class Users {
    

}






