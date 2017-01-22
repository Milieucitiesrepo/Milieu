//
//  UserTableViewController.swift
//  Milieu
//
//  Created by Xiaoxi Pang on 2016-11-15.
//  Copyright © 2016 Atelier Ruderal. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class UserTableViewController: UITableViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    let accountMgr = AccountManager.sharedInstance
    var token: ApiToken!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if hasLogIn() {
            
            syncToken()
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "email, name"]).start(completionHandler: {
                connection, result, error in
                guard error == nil else {
                    AR5Logger.debug(error as! String)
                    return
                }
                
                if (result != nil) {
                    AR5Logger.debug(result.debugDescription)
                    self.userNameLabel.text = (result as! [String:Any])["name"] as? String
                }
            })
        }else{
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func hasLogIn() -> Bool{
        // Check if fbToken exists
        guard FBSDKAccessToken.current() != nil else{
            return false
        }
        // Check JWT token in keychain
        token = accountMgr.fetchToken()
        return  token != nil
    }
    
    /**
     Check if need to update JWT token.
     Silently update token if needed.
    */
    func syncToken(){
        if token.isExpire(){
            
            accountMgr.updateToken(fbToken: FBSDKAccessToken.current().tokenString){
                token, error in
                guard error == nil else{
                    return
                }
                
                guard token != nil else{
                    return
                }
                
                // Save token into keychain
                guard self.accountMgr.saveToken(token: token!) else{
                    return
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            FBSDKLoginManager().logOut()
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }

}
