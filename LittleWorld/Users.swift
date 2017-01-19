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
    
    private let firebaseRef = FIRDatabase.database().reference()
    private var usersList = [String:User]()
    private var onlineUsersList = [String:User]()
    private var inCircleUsersList = [String:User]()
    
    func loadNearbyUsers(location: CLLocation, circle: Double, uid: String) {
        let usersRef = self.firebaseRef.child("Users")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let json = JSON(snapshot.value!)
            
            for (uid,informations) in json {
                var user = User()
                user.uid = uid
                user.status = informations["Connections"]["Connected"].boolValue
                user.lat = informations["Location"]["Lat"].doubleValue
                user.long = informations["Location"]["Long"].doubleValue
                user.name = informations["Name"].stringValue
                
                self.usersList[uid] = user
                
                if (user.status) {
                    self.onlineUsersList[uid] = user
                } else {
                    self.onlineUsersList.removeValue(forKey: uid)
                }
                
            }
        })
        
        inCircleUsersList.removeAll()
        for (_uid,user) in onlineUsersList {
            if _uid != uid {
                let location2 = CLLocation(latitude: user.lat, longitude: user.long)
                if distanceBetweenTwoLocations(source: location, destination: location2) < circle {
                    self.inCircleUsersList[uid] = user
                }
            }
        }
//        print("Total users count: \(self.usersList.count)")
//        print("Online users count: \(self.onlineUsersList.count)")
//        print("Online in Circle users count: \(self.inCircleUsersList.count)")
    }

    
    
    func getUsersList() -> [String:User] {
        return usersList
    }
    
    func getOnlineUsersList() -> [String:User] {
        return onlineUsersList
    }
    
    func getInCircleUsersList() -> [String:User] {
        return inCircleUsersList
    }
    
}






