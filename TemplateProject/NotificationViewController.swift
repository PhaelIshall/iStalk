//
//  NotificationViewController.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 8/3/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class NotificationViewController: UIViewController{

    var requestsArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            getNotifications()
                   println(requestsArray.count)
           }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func getNotifications (){
        var query = PFQuery(className: "MeetingRequest")
        query.whereKey("toUser", equalTo: User.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            
            if let req = requests as? [MeetingRequest] {
                println("r  is ", req)
                for entry in req{
                    self.requestsArray.append("You have received a request from\(entry.fromUser)")
               }
            }
        }

    }
 
}
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notCell") as! NotificationTableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
