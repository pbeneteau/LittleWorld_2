//
//  ProfileVC.swift
//  LittleWorld
//
//  Created by antoine beneteau on 2017-01-16.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase


class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var friendNumber: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    
    var user = FIRAuth.auth()?.currentUser
    
    var mainUser = MainUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser) != nil {
            initUserInformations()
            mainUser.loadFriendList()
            friendNumber.text = "Friend number: \(mainUser.getFriendList().count)"
            print(mainUser.compareFriendsLists(friendsList1: mainUser.getFriendList(), friendList2: mainUser.getFriendList()).count)

        }
    }
    
    
    func initUserInformations() {
        profileName.text = "Name: \(mainUser.getName())"
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.friendsTableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        (cell.viewWithTag(4) as! UILabel).text = ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
