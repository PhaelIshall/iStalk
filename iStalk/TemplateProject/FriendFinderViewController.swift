//
//  FriendFinderViewController.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 7/8/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import ConvenienceKit
import Bond
import SDWebImage

class FriendFinderViewController: UIViewController, CLLocationManagerDelegate  {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // the current parse query
    var query: PFQuery? {
        didSet {
            // whenever we assign a new query, cancel any previous requests
            oldValue?.cancel()
        }
    }
    
    // this view can be in two different states
    enum State {
        case DefaultMode
        case SearchMode
    }
    
    // whenever the state changes, perform one of the two queries and update the list
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                println(state)
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
            }
        }
    }
    var userArray: [[String: String]] = []
    
    var nearbyFriends: [User] = []
    
    var nearbySelected: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var selectedFriend: [String: String]?
    var selectedFriendUser: User?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    

    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            nearbySelected = false
        case 1:
            nearbySelected = true
            
        default:
            break;
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let user = User.currentUser()! as User
            user.getFriends({ (friends, error) -> Void in
                if let error = error {
                    println(error)
                    return
                }
                if let friendships = friends as? [[String: String]]{
                    self.userArray = friendships
                    self.tableView.reloadData()
                }
            })
        
        var query = User.query()
        query!.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: User.currentUser()!.username!)
        query!.whereKey("Coordinate", nearGeoPoint: User.currentUser()!.Coordinate, withinKilometers: 10000)
        query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
           if let result = results as? [User]{
                for entry in result {
                   if (entry.fbID != nil){
                        if (self.checkIfFriend(entry.fbID!)){
                            self.nearbyFriends.append(entry)
                            println(entry)
                        }
                    }
                }
            }
        })

    }
    
    
    func updateList(results: [AnyObject]?, error: NSError?) {
        
        var users = results as? [User] ?? []
        self.tableView.reloadData()
        
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
    }
    
    func checkIfFriend(id: String) -> Bool{
        
       
        for entry in userArray{
            println(entry["id"])
            if (entry["id"] == id){
                return true
            }
        }
           return false
    }
   
    
}

// MARK: TableView Data Source


extension FriendFinderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if nearbySelected == true{
            return self.nearbyFriends.count ?? 0
        }
        else{
            return self.userArray.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendFinderTableViewCell
        if (nearbySelected == false){
            var users = self.userArray
            let user = users[indexPath.row]
            let userID = user["id"]
            let query = PFQuery(className: "Users")
            query.whereKey("FBID", equalTo: user["id"]!)
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID!)/picture")
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .LowPriority, progress: nil) { (image, error, _, _, _) -> Void in
                let cellIndexPath = self.tableView.indexPathForCell(cell)
                if indexPath == cellIndexPath {
                    cell.Picture.image = image
                    cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
                    cell.Picture.clipsToBounds = true;
                }
            }
        cell.usernameLabel?.text = userArray[indexPath.row]["name"]
        }
        else{
            var users = self.nearbyFriends
            let user = users[indexPath.row]
            let userID = user["id"] as? String
            let query = PFQuery(className: "Users")
            query.whereKey("FBID", equalTo: user["id"]!)
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID!)/picture")
            SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .LowPriority, progress: nil) { (image, error, _, _, _) -> Void in
                let cellIndexPath = self.tableView.indexPathForCell(cell)
                if indexPath == cellIndexPath {
                    cell.Picture.image = image
                    cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
                    cell.Picture.clipsToBounds = true;
                }
            }
            cell.usernameLabel?.text = nearbyFriends[indexPath.row].username

        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (!nearbySelected){
            self.selectedFriend = userArray[indexPath.row]
        }
        else{
            self.selectedFriendUser = nearbyFriends[indexPath.row]
        }
        self.performSegueWithIdentifier("ShowCompass", sender: self)
       
    }

  
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowCompass") {
            let compassViewController = segue.destinationViewController as! CompassViewController
           if (!nearbySelected){
            compassViewController.friend = self.selectedFriend
            }
           else{
            compassViewController.parseUser = self.selectedFriendUser

            }
        }
    }
}

// MARK: Searchbar Delegate

extension FriendFinderViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        ParseHelper.searchUsers(searchText, completionBlock:updateList)
    }
    
}
