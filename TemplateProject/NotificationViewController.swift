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
    
    func getReplies(){
        var q1 = MeetingRequest.query()
        q1?.whereKey("request", notEqualTo: "pending")
        q1?.whereKey("fromUser", equalTo: User.currentUser()!)
        q1?.includeKey("toUser")
        q1!.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            
            if let req = requests as? [MeetingRequest] {
                println(req)
                for entry in req {
                    self.allRequests.append(entry)
                    self.requestFetched = entry
                    self.requestsArray.append("\(self.requestFetched!.toUser.username!) has replied to your request.")
                    self.users.append(self.requestFetched!.toUser)
                }
                self.tableView.reloadData()
            }
            
        }

    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        allRequests = []
        requestsArray = []
        users = []
        getNotifications()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    var selectedReq: MeetingRequest?
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
    
    override func  viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.tableView.setEditing(false, animated: true)
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
    
    var location: CLLocationCoordinate2D?
    
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
        getReplies()
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openReq") {
            let RequestViewController = segue.destinationViewController as! ReqViewController
           RequestViewController.friend = friend
            RequestViewController.location = location
        }
    }
    var friend: User?
 
}
extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notifCell") as! NotificationTableViewCell
        
        selectedReq = allRequests[indexPath.row]
        cell.request.text = requestsArray[indexPath.row]
        location = CLLocationCoordinate2DMake(allRequests[indexPath.row].location.latitude, allRequests[indexPath.row].location.longitude)
        var user = users[indexPath.row]
        friend = user
        
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            println("accept button tapped")
            self.selectedReq!.setObject("Accepted", forKey: "request")
            self.selectedReq!.save()
            
        }
        accept.backgroundColor = UIColor.greenColor()
        
        let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
            println("decline button tapped")
            
            self.selectedReq!.setObject("Denied", forKey: "request")
            self.selectedReq!.save()
        }
        decline.backgroundColor = UIColor.redColor()
        
        
        return [accept, decline]
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedRequest = requestsArray[indexPath.row]
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestsArray.count ?? 0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
    }
}
