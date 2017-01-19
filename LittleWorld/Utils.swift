//
//  Utils.swift
//  LittleWorld
//
//  Created by Paul Bénéteau on 15/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import PermissionScope


// Distance between current user and other user
func distanceBetweenTwoLocations(source:CLLocation,destination:CLLocation) -> Double {
    
    let distanceMeters = source.distance(from: destination)
    return distanceMeters
    
}


func showLocationPermission(scope: PermissionScope!) {
    scope.show(
        { finished, results in
            print("got results \(results)")
    },
        cancelled: { results in
            print("thing was cancelled")
    }
    )
}

func checkLocationPermission() -> Bool {
    switch PermissionScope().statusLocationAlways() {
    case .unknown:
        // ask
        PermissionScope().requestLocationAlways()
    case .unauthorized, .disabled:
        // bummer
        return false
    case .authorized:
        // thanks!
        return true
    }
    return true
}

func convertUserDictionaryToTable(dictionary: [String:User]) -> [UserTable] {
    var table = [UserTable]()
    table.removeAll()
    for (uid,user) in dictionary {
        var userTable = UserTable()
        userTable.uid = uid
        userTable.user = user
        table.append(userTable)
    }
    return table
}


extension UserDefaults {
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    static func isFirstLaunch() -> Bool {
        let firstLaunchFlag = "FirstLaunchFlag"
        let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
        if (isFirstLaunch) {
            UserDefaults.standard.set("false", forKey: firstLaunchFlag)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}




