import UIKit
import CoreLocation
import Parse
import ConvenienceKit
import Bond
import SDWebImage

class FriendPickerViewController: UIViewController, CLLocationManagerDelegate  {
    var selectedLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
        }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        checkUsers()
        
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
        refreshControl.endRefreshing()
    }
    
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
    var state: State = .DefaultMode {
        didSet {
            switch (state) {
            case .DefaultMode:
                checkUsers()
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                self.searchTextUpdated(searchText)
            }
        }
    }
    var userArray: [[String: String]] = []
    
    var userSearchArray: [[String: String]] = []
    
    var selectedFriend: [String: String]?
    var selectedFriendUser: User?
    
    var nearbyFriends: [User] = []
    
    var nearbySelected: Bool = false {
        didSet {
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var friendIDs: [String] = []
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            nearbySelected = false
            friendIDs = []
        case 1:
            nearbySelected = true
        default:
            break;
        }
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        state = .DefaultMode
        checkUsers()
        self.tableView.addSubview(self.refreshControl)
    }
    
    func checkUsers(){
        let user = User.currentUser()! as User
        user.getFriends({ (friends, error) -> Void in
            if let error = error {
                println(error)
                return
            }
            
            if let friendships = friends as? [[String: String]]{
                self.userArray = friendships
                //self.tableView.reloadData()
                
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
    
    var nearSearchArray : [User] = []
    
    //Search filtred array for nearby friends
    func searchTextUpdated(searchText: String)
    {
        if searchText ==  "" {
            if (nearbySelected == false){
                self.userSearchArray = userArray
                return
            }
            else{
                self.nearSearchArray = nearbyFriends
                return
            }
        }
        
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            userSearchArray = userArray.filter({ (user) -> Bool in
                var name = user["name"]!.lowercaseString
                if (name.rangeOfString(searchText.lowercaseString) != nil){
                    return true
                }
                return false
            })
        case 1:
            nearSearchArray = nearbyFriends.filter({ (user) -> Bool in
                var name = user.username
                if (name!.rangeOfString(searchText) != nil){
                    return true
                }
                return false
            })
        default:
            userSearchArray = userArray.filter({ (user) -> Bool in
                var name = user["name"]!
                if (name.rangeOfString(searchText) != nil){
                    return true
                }
                return false
            })
            
        }
        
    }
    
}

// MARK: TableView Data Source


extension FriendPickerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if nearbySelected == true{
            if (state == .SearchMode){
                return self.nearSearchArray.count ?? 0
            }
            else{
                return self.nearbyFriends.count ?? 0
            }
        }
        else{
            if (state == .SearchMode){
                return self.userSearchArray.count ?? 0
            }
            else{
                return self.userArray.count ?? 0
                
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendFinderTableViewCell
        if (nearbySelected == false){
            var users: [[String: String]]
            if (state == .SearchMode){
                users = self.userSearchArray
            }
            else{
                users = self.userArray
                
            }
            let user = users[indexPath.row]
            let userID = user["id"]
            let query = PFQuery(className: "Users")
            query.whereKey("FBID", equalTo: user["id"]!)
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID!)/picture")
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
            cell.usernameLabel?.text = users[indexPath.row]["name"]
        }
        else{
            var users: [User] = []
            if (state == .SearchMode)
            {
                users = self.nearSearchArray
                
            }
            else {
                users = self.nearbyFriends
                
            }
            
            let user = users[indexPath.row]
            let userID = user.fbID
            let query = PFQuery(className: "Users")
            
            query.whereKey("FBID", equalTo: userID)
            
            
            let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
            cell.Picture.sd_setImageWithURL(url, completed: nil)
            cell.Picture.layer.cornerRadius = cell.Picture.frame.size.width / 2;
            cell.Picture.clipsToBounds = true;
            cell.usernameLabel?.text = users[indexPath.row].username
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if (!nearbySelected){
//            self.selectedFriend = userArray[indexPath.row]
//        }
//        else{
//            self.selectedFriendUser = nearbyFriends[indexPath.row]
//        }
        self.performSegueWithIdentifier("showFirst", sender: self)
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showFirst") {
            let s = segue.destinationViewController as! FirstViewController
            s.touchMapCoordinate = selectedLocation
        }
        if (segue.identifier == "sendRequest") {
            let friendReq = segue.destinationViewController as! SendRequestViewController
            friendReq.selectedLocation = selectedLocation
            if (!nearbySelected){
                friendReq.friend = self.selectedFriend
                friendReq.nearbySelected = false
            }
            else{
                friendReq.nearbySelected = true
                friendReq.parseUser = self.selectedFriendUser
        
            }
        }
    }
}

// MARK: Searchbar Delegate

extension FriendPickerViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchTextUpdated(searchText)
    }
}
