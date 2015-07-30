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
   
    var selectedFriend: [String: String]?
    var selectedFriendUser: User?

    var nearbyFriends: [User] = []
    
    var nearbySelected: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friendIDs: [String] = []

    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            nearbySelected = false
            //nearbyFriends = []
            friendIDs = []
            

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
                    
                    for entry in self.userArray{
                        self.friendIDs.append(entry["id"]!)
                    }

                    var query = User.query()
            
                    query!.whereKey("FBID", containedIn: self.friendIDs)
                    query!.whereKey("Coordinate", nearGeoPoint: User.currentUser()!.Coordinate, withinKilometers: 2)
                    query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                        if let result = results as? [User]{
                            self.nearbyFriends = []
                            for entry in result {
                                if (self.checkIfFriend(entry.fbID)){
                                    self.nearbyFriends.append(entry)
                                    println(entry)
                                }
                            }
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        
        
    }
    
    func checkIfFriend(id: String) -> Bool{
        for entry in userArray{
            if (entry["id"] == id){
                return true
            }
        }
        return false
    }

    
    func updateList(results: [AnyObject]?, error: NSError?) {
        
        var users = results as? [User] ?? []
        self.tableView.reloadData()
        
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
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
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
            cell.usernameLabel?.text = userArray[indexPath.row]["name"]
        }
        else{
            var users = self.nearbyFriends
            println(nearbyFriends.count)
            let user = users[indexPath.row]
            let userID = user.fbID 
            let query = PFQuery(className: "Users")
            
            query.whereKey("FBID", equalTo: userID)
            
           
            let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
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
