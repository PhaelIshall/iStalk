import Foundation
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import Bond
import ConvenienceKit


class User : PFUser, PFSubclassing {
    var image: Dynamic<UIImage?> = Dynamic(nil)
    var Coordinate: PFGeoPoint!{
        get{
            return self["Coordinate"]! as! PFGeoPoint
        }
        set{
           self["Coordinate"] = newValue
        }
    }
    var fbID: String? {
        get{
            return self["FBID"] as? String
        }
        set{
            self["FBID"] = newValue
        }
    }


        override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    override class func currentUser() -> User? {
        return super.currentUser() as! User?
    }
    
    func getFriends(completionBlock: PFArrayResultBlock) {
      var fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            fbRequest.startWithCompletionHandler{ (_, result, error) in
                let result = result as! [String : AnyObject]
                let data = result["data"] as! [AnyObject]
                completionBlock(data, error)
            }
        }
    }
    
    func addFriend(friend: User ){
        let add = PFObject(className: "Friends")
        add.setObject(User.currentUser()!, forKey: "fromUser")
        add.setObject(friend, forKey: "toUser")
        add.save()
    }
    
    func updateCoordinate(latitude: CLLocationDegrees , longitude: CLLocationDegrees){
        self.Coordinate = PFGeoPoint(latitude: latitude, longitude: longitude)
        self.saveInBackground()
    }

    
    func getProfilePicture() -> UIImage? {
        var img : UIImage = UIImage()
            let url = NSURL(string: "http://graph.facebook.com/\(fbID)/picture")
            let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            dispatch_async(queue) {
        
            let data = NSData(contentsOfURL: url!)
    
            if let data = data {
                self.image.value = UIImage(data: data)
                img = self.image.value!
            }
        }
        return img

    }
    
    func friendNearMe(){
        let query = User.query()
        query!.whereKey("Coordinate", nearGeoPoint: User.currentUser()!.Coordinate!, withinKilometers: 1)
        query?.findObjectsInBackground()
            
        }
    
}