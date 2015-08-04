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


class CompassViewController: UIViewController, UITableViewDelegate{
    
    let gpaViewController = GooglePlacesAutocomplete(
        apiKey: "AIzaSyD_ylpRvrjZdLA-T0Hk5ymMNDX8X9iDlEI",
        placeType: .Address
    )

    var friend: [String: String]? {
        didSet {
            let query = User.query()! //because User is subclassing
            if let friend = friend {
                if let friendID = friend["id"] {
                    //println("THE ID IS : ", friendID)
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
    @IBOutlet weak var picker: UIBarButtonItem!
    
   
    var d: Double?
    @IBOutlet weak var meet: UIBarButtonItem!
    
    @IBAction func map(sender: AnyObject) {
        gpaViewController.placeDelegate = self
        presentViewController(gpaViewController, animated: true, completion: nil)

    }
    
    var parseUser: User? {
        didSet {
            if let parseUser = self.parseUser {
                let updatedFriend = parseUser
                self.parseUser?.Coordinate = updatedFriend.Coordinate
                
                self.compass.arrowImageView = self.arrowImageView
                self.compass.latitudeOfTargetedPoint = self.parseUser!.Coordinate.latitude
                self.compass.longitudeOfTargetedPoint = self.parseUser!.Coordinate.longitude
                
                self.d = User.currentUser()?.Coordinate.distanceInKilometersTo(self.parseUser?.Coordinate!);
                self.title = String(format:"%.1f", d!) + "km away"
                
                if (User.currentUser()?.Coordinate.distanceInKilometersTo(parseUser.Coordinate) < 0.01) {
                    view.backgroundColor = UIColor.greenColor()
                }
                else if (User.currentUser()?.Coordinate.distanceInKilometersTo(parseUser.Coordinate) < 0.05) {
                    view.backgroundColor = UIColor.orangeColor()
                }
                else {
                    view.backgroundColor = UIColor.redColor()
                }
                
            }

        }
    }

    var compass  = GeoPointCompass()

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
        
        if (segue.identifier == "openMessages") {
            let messageViewController = segue.destinationViewController as! MessageViewController
            messageViewController.friend = parseUser
        }
        if (segue.identifier == "openMap") {
            let pickerViewController = segue.destinationViewController as! PickerViewController
            pickerViewController.selectedFriend = parseUser
            
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("startGame", sender: self)
        self.performSegueWithIdentifier("openMessages", sender: self)
        self.performSegueWithIdentifier("openMap", sender: self)
    }

}
extension CompassViewController: GooglePlacesAutocompleteDelegate {
    func placeSelected(place: Place) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet \(self.parseUser!.username!)?", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Time of meeting"
               
            })
            
            
            let sendRequestActionHandler = { (action:UIAlertAction!) -> Void in
                let alertMessage = UIAlertController(title: "Request sent", message: "Meeting in \(place.description)", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
            let requestAction = UIAlertAction(title: "Send request", style: .Default, handler: sendRequestActionHandler)
            alertController.addAction(requestAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
           
            
                        

            //println(place.description)
            
            //place.getDetails { details in
            //  println(details)
            //}
            
        })
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

