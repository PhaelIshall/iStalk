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
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        allRequests = []
        requestsArray = []
        users = []
        getNotifications()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    
    var selectedRequest : String?
    var requestFetched: MeetingRequest?
    var requestsArray: [String] = []
    var allRequests: [MeetingRequest] = []
    var users : [User?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            getNotifications()
        self.tableView.addSubview(self.refreshControl)
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
    }
    
    @IBOutlet var tableView : UITableView!{
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func getNotifications (){
        var query = MeetingRequest.query()!
        query.whereKey("toUser", equalTo: User.currentUser()!)
        query.includeKey("fromUser")
        query.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            
            if let req = requests as? [MeetingRequest] {
                
                for entry in req {
                    self.requestFetched = entry
                    self.allRequests.append(entry)
                    self.requestsArray.append("\(self.requestFetched!.fromUser.username!) wants to meet you!")
                    self.users.append(self.requestFetched!.fromUser)
               }
                self.tableView.reloadData()
            }
            
        }
        
    }
 
}
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notifCell") as! NotificationTableViewCell
        cell.request.text = requestsArray[indexPath.row]
        var user = users[indexPath.row]
        if (allRequests[indexPath.row].message != "" ){
            cell.msg.text = "\(user!.username!) says \(allRequests[indexPath.row].message)"
        }
        
        let userID = user!.fbID
        let query = PFQuery(className: "Users")
        
        query.whereKey("FBID", equalTo: userID)
        
        
        let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
        cell.Picture.sd_setImageWithURL(url, completed: nil)
       
       

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRequest = requestsArray[indexPath.row]
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsArray.count ?? 0
    }
}
