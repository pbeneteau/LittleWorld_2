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
    private var facebookID: String!
    private var name: String!
    private var city: String!
    private var postalCode: String!
    private var countryCode: String!
    private var status: Bool!
    private var location: CLLocation!
    
    
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
            self.updateToFirebase()
        }) { error in
            print("Error: \(error)")
        }
    }
    
    func updateToFirebase() {
        firebaseRef.child("Users").child(uid).child("Location").child("Lat").setValue("\(location.coordinate.latitude)")
        firebaseRef.child("Users").child(uid).child("Location").child("Long").setValue("\(location.coordinate.longitude)")
        
        firebaseRef.child("Users").child(uid).child("Location").child("City").setValue("\(city!)")
        firebaseRef.child("Users").child(uid).child("Location").child("PostalCode").setValue("\(postalCode!)")
        firebaseRef.child("Users").child(uid).child("Location").child("isoCountryCode").setValue("\(countryCode!)")
    }
    
    func checkConnectionState() {
        
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = FIRDatabase.database().reference(withPath: "Users/\(uid)/Connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = FIRDatabase.database().reference(withPath: "Users/\(uid)/Connections/LastOnline")
        
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
        })
    }
    func disconnect() {
        
        try!FIRAuth.auth()?.signOut() // Logout
        transitionSegue.segue.switchToLoginview()
        print("user did logout")
    }
    
    func loadInformations() {
        let usersRef = self.firebaseRef.child("Users/\(uid)")
        
        usersRef.observeSingleEvent(of: .value, with: { (snapshot) -> Void in
            let json = JSON(snapshot.value!)
            self.name = json["Name"].stringValue
        })
    }
    
    func loadFriendList() {
        FBSDKGraphRequest(graphPath:"/me/taggable_friends?limit=5000", parameters: ["fields": "id, first_name, last_name, picture "]).start(completionHandler: { (connection, result, error) -> Void in
            
            if error == nil
            {
                let json = JSON(result!)
                print(json)
            }
            else
            {
                print("Error Getting Friends \(error!)")
            }
        })
    }
    
    // Get
    func getUid() -> String {
        return self.uid
    }
    func getFacebookID() -> String {
        return facebookID
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

    init() {
        uid = user!.uid
        location = CLLocation(latitude: 0.0, longitude: 0.0)
        name = ""
        city = ""
        postalCode = ""
        countryCode = ""
    }
    
}
