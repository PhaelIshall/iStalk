//
//  CompassViewController.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 7/14/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import CoreLocation
import Parse


class CompassViewController: UIViewController, UITableViewDelegate {
    
    var d: Double? 
    var friend: [String: String]? {
        didSet {
            let query = User.query()! //because User is subclassing
            if let friend = friend {
                if let friendID = friend["id"] {
                    query.whereKey("FBID", equalTo: friendID)
                    query.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
                        if let results = results as? [User] {
                            self.parseUser = results[0]
                        }
                    })
                    
                }
            }
        }
    }
    
    @IBOutlet weak var distance: UILabel!{
        didSet{
            self.d = User.currentUser()?.Coordinate.distanceInKilometersTo(self.parseUser?.Coordinate!);            distance.text = String(format:"%.1f", d!) + "km away"
        }
    }
    var parseUser: User? {
        didSet {
            if let parseUser = self.parseUser {
                let updatedFriend = parseUser
                self.parseUser?.Coordinate = updatedFriend.Coordinate
                
                self.compass.arrowImageView = self.arrowImageView
                self.compass.latitudeOfTargetedPoint = self.parseUser!.Coordinate.latitude
                self.compass.longitudeOfTargetedPoint = self.parseUser!.Coordinate.longitude

                
                if (User.currentUser()?.Coordinate.distanceInKilometersTo(parseUser.Coordinate) < 0.01) {
                    view.backgroundColor = UIColor.greenColor()
                }
                else {
                    view.backgroundColor = UIColor.redColor()
                }
                
            }

        }
    }

    var compass  = GeoPointCompass()
    var popViewController: PopupViewController?
    

    @IBOutlet var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = UIImage(named: "Rightarrow.png")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "startGame") {
            let gameViewController = segue.destinationViewController as! GameViewController
        }
        if (segue.identifier == "openMessages") {
            let messageViewController = segue.destinationViewController as! MessageViewController
            messageViewController.friend = parseUser
        }
       if (segue.identifier == "openMap") {
           //et mapViewController = segue.destinationViewController as! MapViewController
//              self.popViewController = PopupViewController(nibName: "PopUpViewController", bundle: nil)
//            self.popViewController!.title = "This is a popup view"
//            self.popViewController!.showInView(self.view, withImage: UIImage(named: "typpzDemo"), withMessage: "You just triggered a great popup window", animated: true)
//            
      //  mapViewController.friend = parseUser
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("startGame", sender: self)
        self.performSegueWithIdentifier("openMessages", sender: self)
        self.performSegueWithIdentifier("openMap", sender: self)
    }

}
