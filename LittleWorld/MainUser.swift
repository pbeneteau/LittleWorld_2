//
//  MainUser.swift
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
import FBSDKLoginKit
import FBSDKCoreKit


class MainUser {
    
    private let firebaseRef = FIRDatabase.database().reference()
    private var user = FIRAuth.auth()?.currentUser
    private var uid: String = ""
    private var facebookID: String = ""
    private var name: String!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var status: Bool!
    private var location: CLLocation!
    private var friendList = [String:String]()
    private var inCircleUsers = [String]()
    private var inCircleUsersWithMutuals = [String]()
    
    
    // Location
    func setLocation(location: CLLocation) {
        self.location = location
        self.getLocationDetails(location: location)
    }
    
    // Get current user City, PostalCode and Country code
    func getLocationDetails(location: CLLocation) {
        _ = Location.reverse(coordinates: location.coordinate, onSuccess: { foundPlacemark in
            self.city = foundPlacemark.locality
            self.countryCode = foundPlacemark.isoCountryCode
            self.postalCode = foundPlacemark.postalCode
        }) { error in
            print("Error: \(error)")
        }
    }
    
    func loadFacebookID() {
        print("\nGet user's Facebook ID\n")
        FBSDKGraphRequest(graphPath:"me", parameters: ["fields": "id,name"]).start(completionHandler: { (connection, result, error) -> Void in
            
            if error == nil
            {
                let json = JSON(result!)
                let id: String = json["id"].stringValue
                self.facebookID = id
            }
            else
            {
                print("Error Getting Friends \(error)")
            }
        })
    }
    
    
    func checkConnectionState() {
        print("\nCheck user's connection state\n")
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = FIRDatabase.database().reference(withPath: "Users/Infos/\(uid)/Connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = FIRDatabase.database().reference(withPath: "Users/Infos/\(uid)/Connections/LastOnline")
        
        let connectedRef = FIRDatabase.database().reference(withPath: ".info/connected")
        
        
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else {
                return
            }
            // add this device to my connections list
            // this value could contain info about the device or a timestamp instead of just true
            let con = myConnectionsRef.child("Connected")
            con.setValue("true")
            
            // when this device disconnects, remove it
            con.onDisconnectSetValue("false")
            // when I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnectSetValue(FIRServerValue.timestamp())
            if self.countryCode! != "" && self.city! != "" {
                FIRDatabase.database().reference(withPath: "Users/Location/\(self.countryCode!)/\(self.city!)/\(self.uid)").onDisconnectRemoveValue()
            }
        })
    }
    
    
    func loadInformations() {
        print("\nGet user's infos\n")
        let usersRef = self.firebaseRef.child("Users/Infos/\(uid)")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let json = JSON(snapshot.value!)
            self.name = json["Name"].stringValue
        })
    }
    
    func loadFriendList() {
        print("\nGet user's Facebook friend list\n")
        FBSDKGraphRequest(graphPath:"/me/friends?limit=5000", parameters: ["fields": "id,name"]).start(completionHandler: { (connection, result, error) -> Void in
            
            if error == nil
            {
                let array = (result as! NSDictionary).object(forKey: "data") as! NSArray
                for i in 0  ..< array.count {
                    let dict : NSDictionary = array.object(at: i) as! NSDictionary
                    let id: String = dict.object(forKey: "id") as! String
                    let name: String = dict.object(forKey: "name") as! String
                    self.friendList[id] = name
                }
                self.uploadFriendsToFirebase()
            }
            else
            {
                print("Error Getting Friends \(error)")
            }
        })
    }
    
    func uploadFriendsToFirebase() {
        print("\nUser's Facebook friends list upload to Firebase\n")
        for (id,name) in self.friendList {
            self.firebaseRef.child("Users/Infos/\(self.uid)/FriendList").child(id).setValue(name)
        }
    }
    
    func goOnline() {
        if countryCode! != "" && city! != "" {
            let ref = FIRDatabase.database().reference(withPath: "Users/Location/\(countryCode!)/\(city!)/\(uid)")
            ref.child("Lat").setValue(location.coordinate.latitude)
            ref.child("Long").setValue(location.coordinate.longitude)
        }
    }
    
    func goOffline() {
        print("\nGo offline -> deleted from Location\n")
        if countryCode! != "" && city! != "" {
            FIRDatabase.database().reference(withPath: "Users/Location/\(countryCode!)/\(city!)/\(uid)").removeValue()
        }
    }
    
    func loadInCircleUsers(circle: Double) {
        let usersRef = FIRDatabase.database().reference(withPath: "Users/Location/\(countryCode!)/\(city!)")
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            self.inCircleUsers.removeAll()
            let json = JSON(snapshot.value!)
            for (id,loc) in json {
                if (id != self.uid) {
                    let location2 = CLLocation(latitude: loc["Lat"].doubleValue, longitude: loc["Long"].doubleValue)
                    if (distanceBetweenTwoLocations(source: self.location, destination: location2) < circle) {
                        self.inCircleUsers.append(id)
                    }
                }
            }
        })
    }
    
    func loadInCircleUsersWithMutuals() {
        for user in inCircleUsers {
            //1724201050939032?fields=context.fields(mutual_friends)
        }
    }
    
    
    func compareFriendsLists(friendsList1: [String:String], friendList2: [String:String]) -> [String:String] {
        var mutualFriends = [String:String]()
        for friend1 in friendsList1 {
            for friend2 in friendList2 {
                if friend1.key == friend2.key {
                    mutualFriends[friend1.key] = friend1.value
                }
            }
        }
        return mutualFriends
    }
    
    // Get
    func getUid() -> String {
        return self.uid
    }
    func getFacebookID() -> String {
        return self.facebookID
    }
    func getName() -> String {
        return self.name
    }
    func getCity() -> String {
        return self.city
    }
    func getPostalCode() -> String {
        return self.postalCode
    }
    func getCountryCode() -> String {
        return self.countryCode
    }
    func getStatus() -> Bool {
        return self.status
    }
    func getLocation() -> CLLocation {
        return location
    }
    func getLat() -> CLLocationDegrees {
        return location.coordinate.latitude
    }
    func getLong() -> CLLocationDegrees{
        return location.coordinate.longitude
    }
    func getFriendList() -> [String:String] {
        return friendList
    }
    func getInCircleUsers() -> [String] {
        return inCircleUsers
    }
    func getInCircleUsersWithMutuals() -> [String] {
        return inCircleUsersWithMutuals
    }
    
    init() {
        uid = user!.uid
        facebookID = ""
        location = CLLocation(latitude: 0.0, longitude: 0.0)
        name = ""
        city = ""
        postalCode = ""
        countryCode = ""
    }
    
}
