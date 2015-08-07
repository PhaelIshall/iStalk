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
import MapKit


class CompassViewController: UIViewController, UITableViewDelegate, MKMapViewDelegate{
 @IBOutlet var textView: UITextView?
    
     @IBOutlet weak var mapView: MKMapView!
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
                
//                if (User.currentUser()?.Coordinate.distanceInKilometersTo(parseUser.Coordinate) < 0.01) {
//                    view.backgroundColor = UIColor.greenColor()
//                }
//                else if (User.currentUser()?.Coordinate.distanceInKilometersTo(parseUser.Coordinate) < 0.05) {
//                    view.backgroundColor = UIColor.orangeColor()
//                }
//                else {
//                    view.backgroundColor = UIColor.redColor()
//                }
                var point = MKPointAnnotation()
                point.title = parseUser.username
                
                point.coordinate = CLLocationCoordinate2DMake(parseUser.Coordinate.latitude, parseUser.Coordinate.longitude)
                self.mapView.addAnnotation(point)
                var viewRegion = MKCoordinateRegionMakeWithDistance(point.coordinate, 1900, 1900);
                var adjustedRegion = mapView.regionThatFits(viewRegion)
                
                
                mapView.setRegion(adjustedRegion, animated: true);
            }

        }
    }
    
    
    @IBOutlet weak var directions: UIBarButtonItem!
    @IBAction func direct(sender: AnyObject) {
        getDirection()
    }
    
    var compass  = GeoPointCompass()
   
    @IBOutlet var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = UIImage(named: "Rightarrow.png")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.alpha = 0.5
        mapView.showsUserLocation = true;

        var zoomLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
        zoomLocation.latitude = User.currentUser()!.Coordinate.latitude
        zoomLocation.longitude = User.currentUser()!.Coordinate.longitude
        
        
        mapView.delegate = self;
        
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    func getDirection(){
        var myDestination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(parseUser!.Coordinate.latitude, parseUser!.Coordinate.longitude), addressDictionary: nil)
        //var sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(User.currentUser()!.Coordinate.latitude, User.currentUser()!.Coordinate.longitude), addressDictionary: nil)
        //var source:MKMapItem?
        let destMKMap = MKMapItem(placemark: myDestination)!
        
        var directionRequest:MKDirectionsRequest = MKDirectionsRequest()
        directionRequest.setSource(MKMapItem.mapItemForCurrentLocation())
        directionRequest.setDestination(destMKMap)
        directionRequest.transportType = MKDirectionsTransportType.Walking
       
        
        let dir = MKDirections(request: directionRequest)
        dir.calculateDirectionsWithCompletionHandler() {
            (response:MKDirectionsResponse!, error:NSError!) in
            if response == nil {
                println(error)
                return
            }
            
            self.showRoute(response)
            let route = response.routes[0] as! MKRoute
            var msg: String = ""
            for step in route.steps {
                if (self.textView?.text == ""){
                    msg += "After \(step.distance) metres: \(step.instructions)"
                    
                }
                else {
                    msg += "\nAfter \(step.distance) metres: \(step.instructions)"
                }
            }
            let alertController = UIAlertController(title: "Get directions", message: msg, preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as! [MKRoute] {
            
          mapView.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
            
            for step in route.steps {
                println(step.instructions)
            }
        }
        let userLocation = mapView.userLocation
        let region = MKCoordinateRegionMakeWithDistance(
            userLocation.location.coordinate, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay
        overlay: MKOverlay!) -> MKOverlayRenderer! {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.strokeColor = UIColor.blueColor()
            renderer.lineWidth = 5.0
            return renderer
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
            
           
                    })
    }
    
    func placeViewClosed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

