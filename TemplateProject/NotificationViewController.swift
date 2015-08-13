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
        q1?.includeKey("fromUser")
        q1!.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            if let req = requests as? [MeetingRequest] {
                
                for entry in req {
                    self.allRequests.append(entry)
                    self.requestFetched = entry
                }
               self.tableView.reloadData()
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        allRequests = []
        getNotifications()
       self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)

        refreshControl.endRefreshing()
    }

    var selectedReq: MeetingRequest?

    var requestFetched: MeetingRequest?

    var allRequests: [MeetingRequest] = []
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
        query.includeKey("toUser")
        query.findObjectsInBackgroundWithBlock { (requests, error) -> Void in
            
            if let req = requests as? [MeetingRequest] {
                for entry in req {
                    self.requestFetched = entry
                    self.allRequests.append(entry)
                    println(entry)
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
            RequestViewController.txt = msg
            RequestViewController.meetingRequest = selectedReq
        }
    }
    var friend: User?
    var msg: String = ""
}

extension NotificationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let selectedReq = allRequests[indexPath.row]
        let cell: NotificationTableViewCell
       
        
        if selectedReq.fromUser.objectId == User.currentUser()?.objectId{
             cell = tableView.dequeueReusableCellWithIdentifier("notifCell") as! NotificationTableViewCell
            cell.request.text = "\(allRequests[indexPath.row].toUser.username!) has replied to your request!"
            if (allRequests[indexPath.row].message != "" ){
                cell.msg.text = "You said \(allRequests[indexPath.row].message)"
            }
            let userID = allRequests[indexPath.row].toUser.fbID
            let query = PFQuery(className: "Users")
            
            query.whereKey("FBID", equalTo: userID)
            
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
            
        }
        else{
            cell = tableView.dequeueReusableCellWithIdentifier("requestCell") as! NotificationTableViewCell
            cell.request.text = "\(allRequests[indexPath.row].fromUser.username!) wants to meet you!"
            if (allRequests[indexPath.row].message != "" ){
                cell.msg.text = "\(allRequests[indexPath.row].fromUser.username!) says \(allRequests[indexPath.row].message)"
            }
            let userID = allRequests[indexPath.row].fromUser.fbID
            let query = PFQuery(className: "Users")
            
            query.whereKey("FBID", equalTo: userID)
            
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
            
        }
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
                self.allRequests.removeAtIndex(indexPath.row)
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
        self.allRequests[indexPath.row].setObject("true", forKey: "read")
        self.allRequests[indexPath.row].save()
        allRequests[indexPath.row].read = "true"
        if(allRequests[indexPath.row].fromUser.objectId != User.currentUser()?.objectId){
            friend = allRequests[indexPath.row].fromUser
        }
        else{
            friend = allRequests[indexPath.row].toUser
        }
        self.tableView.cellForRowAtIndexPath(indexPath)?.backgroundColor = UIColor.whiteColor()
        msg = allRequests[indexPath.row].message
        self.selectedReq = allRequests[indexPath.row]
        self.location = CLLocationCoordinate2DMake(allRequests[indexPath.row].location.latitude, allRequests[indexPath.row].location.longitude)
        self.performSegueWithIdentifier("openReq", sender: self)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(allRequests.count)
        return allRequests.count ?? 0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    
}
