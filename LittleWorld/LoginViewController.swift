//
//  LoginViewController.swift
//  Galères étudiantes
//
//  Created by Paul Bénéteau on 13/01/2017.
//  Copyright © 2017 Paul Bénéteau. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var ref = FIRDatabase.database().reference() // Database reference
    var user = FIRAuth.auth()?.currentUser
    
    let isFirstLaunch = UserDefaults.isFirstLaunch()
        
    @IBOutlet weak var loginAlert: UILabel!
    @IBOutlet weak var facebookButtonView: FBSDKLoginButton! // Facebook login button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookButtonView!.delegate = self
        facebookButtonView!.readPermissions = ["public_profile", "email", "user_friends"]

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook login
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!)
    {
        
        
        
        loginAlert.isHidden = false
        
        if error != nil {
            print(error.localizedDescription)
            return
        } else if (result.isCancelled){ // Canceled by user
            print("user canceled sign up")
            loginAlert.text = "Canceled"
        } else {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            let userRef = ref.child("Users").child("Infos")
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in // Sign in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                } else if error == nil {
                    print("user logged with facebook")
                    
                    userRef.child(user!.uid).child("Name").setValue(user?.displayName)
                    
                    if !self.isFirstLaunch {
                        transitionSegue.segue.switchToNavigationController()
                    } else {
                        transitionSegue.segue.switchToWalkThrough()
                    }
                }
            })
            
            print("user logged with facebook -> WalkThrough")
            
            loginAlert.text = "Successfuly logged in!"
            
            
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!)
    {
        try!FIRAuth.auth()?.signOut() // Logout
        print("user did logout of facebook")
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil) // Close current login view Controller
    }
    
    
}



