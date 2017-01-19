//
//  HomeViewController.swift
//  LittleWorld
//
//  Created by Paul Bénéteau on 13/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import SwiftyJSON
import PermissionScope
import FBSDKCoreKit
import FBSDKLoginKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate {
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    
    var mainUser: MainUser!
    
    var users = Users()
    
    let pscope = PermissionScope()
    
    
    @IBOutlet weak var longituteLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var nearUsersTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pscope.addPermission(LocationAlwaysPermission(), message: "We use this to track\r\nwhere you live :)")
        
        showLocationPermission(scope: pscope)
        
        mainUser = MainUser()
        
        mainUser.loadInformations()
        
        mainUser.checkConnectionState()
    
        mainUser.loadFriendList()
        
        initLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disconnectAction(_ sender: Any) {
        ref.child("Users").child(user!.uid).child("Connections").child("Connected").setValue("false")
        try!FIRAuth.auth()?.signOut() // Logout
        FBSDKProfile.setCurrent(nil)

        FBSDKAccessToken.setCurrent(nil)

        transitionSegue.segue.switchToLoginview()
        print("user did logout")
    }
    
    
    func printLocationDetails() {
        self.cityLabel.text = "City: \(mainUser.getCity())"
        self.countryLabel.text = "Country: \(mainUser.getCountryCode())"
        self.longituteLabel.text = "Longitude: \(mainUser.getLong())"
        self.latitudeLabel.text = "Latitude: \(mainUser.getLat())"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.nearUsersTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        // (cell.viewWithTag(4) as! UILabel).text = (self.inCircleUsersTable[indexPath.row].user as User).name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "login" {
            let toViewController = segue.destination as UIViewController
            toViewController.transitioningDelegate = self
        }
    }
    
    func updateUserLocation(location: CLLocation) {
        // Get User's localization and informations
        self.mainUser.setLocation(location: location)
        self.printLocationDetails()
    }
    
    func updateNearbyUsers() {
        // Get nearby users every 10s
    }
    
    func initLocation() -> Void {
        
        var r = Location.getLocation(withAccuracy: .block, frequency: .continuous, timeout: nil, onSuccess: { (location) in
            
            if (FBSDKAccessToken.current() != nil) {
                self.updateUserLocation(location: location)
            }
            
        }) { (last, err) in
            print("err \(err)")
        }
        r.onAuthorizationDidChange = { newStatus in
            print("New status \(newStatus)")
        }
        
        var _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(updateNearbyUsers), userInfo: nil, repeats: true)
    }
    
}

