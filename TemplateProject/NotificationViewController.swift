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
                
                for entry in req {
                    self.allRequests.append(entry)
                    self.requestFetched = entry
                    self.requestsArray.append("\(self.requestFetched!.toUser.username!) has replied to your request.")
                    self.users.append(self.requestFetched!.toUser)
                    var r = entry["read"] as! String
                    self.read.append(r)
                }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            }
        }
    }
    
    var read: [String] = []
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        allRequests = []
        requestsArray = []
        users = []
        getNotifications()
       self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)

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
                   
                    self.read.append(entry["read"] as! String)
               }
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
            }
            
        }
        getReplies()
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "openReq") {
            let RequestViewController = segue.destinationViewController as! ReqViewController
           RequestViewController.friend = friend
            RequestViewController.location = location
            RequestViewController.txt = msg
            println(msg)
            RequestViewController.meetingRequest = selectedReq
        }
    }
    var friend: User?
    var msg: String = ""
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        selectedReq = allRequests[indexPath.row]
        let cell: NotificationTableViewCell
        
        if selectedReq?.fromUser.objectId == User.currentUser()?.objectId{
             cell = tableView.dequeueReusableCellWithIdentifier("notifCell") as! NotificationTableViewCell
            //cell.backgroundColor = UIColor.grayColor()
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier("requestCell") as! NotificationTableViewCell

        }

        selectedReq = allRequests[indexPath.row]
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
        cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
        cell.Picture.clipsToBounds = true;
        
        println(cell.reuseIdentifier!)
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
      
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "notifCell" {
            let accept = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
                self.selectedReq!.setObject("Accepted", forKey: "request")
                self.selectedReq!.save()
                self.tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.blueColor()
            }
            accept.backgroundColor = UIColor.greenColor()
            
            let decline = UITableViewRowAction(style: .Normal, title: "Decline") { action, index in
                self.selectedReq!.setObject("Denied", forKey: "request")
                self.selectedReq!.save()
                var obj = PFObject(withoutDataWithClassName: "MeetingRequest", objectId: self.allRequests[indexPath.row].objectId)
                obj.deleteEventually()
                self.users.removeAtIndex(indexPath.row)
                self.allRequests.removeAtIndex(indexPath.row)
                self.requestsArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            decline.backgroundColor = UIColor.redColor()
            return [accept, decline]
        }
        else{
            return []
        }
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var user = users[indexPath.row]
        friend = user
        read[indexPath.row] = "true"
        self.tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.whiteColor()
        msg = allRequests[indexPath.row].message
        self.selectedRequest = requestsArray[indexPath.row]
        self.location = CLLocationCoordinate2DMake(allRequests[indexPath.row].location.latitude, allRequests[indexPath.row].location.longitude)
        self.performSegueWithIdentifier("openReq", sender: self)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(requestsArray.count)
        return requestsArray.count ?? 0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
}
