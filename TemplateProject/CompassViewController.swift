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
      var user = PersonAnnotation()
    
    var parseUser: User? {
        didSet {
            if (!nearbySelected){
                if let parseUser = self.parseUser {
                    let updatedFriend = parseUser
                    self.parseUser?.Coordinate = updatedFriend.Coordinate
                    
                    self.compass.arrowImageView = self.arrowImageView
                    self.compass.latitudeOfTargetedPoint = self.parseUser!.Coordinate.latitude
                    self.compass.longitudeOfTargetedPoint = self.parseUser!.Coordinate.longitude
                    self.d = User.currentUser()?.Coordinate.distanceInKilometersTo(self.parseUser?.Coordinate!);
                    self.title = String(format:"%.1f", d!) + "km away"
                    
                    
                    println(parseUser.username)
                    point.title = parseUser.username
                    point.coordinate = CLLocationCoordinate2DMake(parseUser.Coordinate.latitude, parseUser.Coordinate.longitude)
                    self.mapView.addAnnotation(point)
                  mapView.selectAnnotation(point, animated: true)
                    user.coordinate = CLLocationCoordinate2DMake(User.currentUser()!.Coordinate!.latitude, User.currentUser()!.Coordinate!.longitude)
                    
                    self.mapView.addAnnotation(user)
                    mapView.showAnnotations(mapView.annotations, animated: true)
                    

                    mapView.showAnnotations(mapView.annotations, animated: true)
//                    
//                    var viewRegion = MKCoordinateRegionMakeWithDistance(point.coordinate, 1900, 1900);
//                    var adjustedRegion = mapView.regionThatFits(viewRegion)
//                    
//                    mapView.setRegion(adjustedRegion, animated: true);
                }
            }
        }
    }
    
    @IBAction func direct(sender: AnyObject) {
        getDirection()
    }
 
    
    @IBOutlet weak var directions: UIBarButtonItem!
    
    var compass  = GeoPointCompass()
   
    @IBOutlet var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = UIImage(named: "1.png")
        }
    }
    
    var nearbySelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.alpha = 1
        arrowImageView.removeFromSuperview()
        self.view.addSubview(arrowImageView)
        mapView.showsUserLocation = true;
//
//        var zoomLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
//        zoomLocation.latitude = User.currentUser()!.Coordinate.latitude
//        zoomLocation.longitude = User.currentUser()!.Coordinate.longitude
        
        mapView.delegate = self;
        var press: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        
        press.minimumPressDuration = 0.25
        mapView.addGestureRecognizer(press)
        if(nearbySelected){
            if let parseUser = self.parseUser {
                    let updatedFriend = parseUser
                    self.parseUser?.Coordinate = updatedFriend.Coordinate
                    
                    self.compass.arrowImageView = self.arrowImageView
                    self.compass.latitudeOfTargetedPoint = self.parseUser!.Coordinate.latitude
                    self.compass.longitudeOfTargetedPoint = self.parseUser!.Coordinate.longitude
                    self.d = User.currentUser()?.Coordinate.distanceInKilometersTo(self.parseUser?.Coordinate!);
                    self.title = String(format:"%.1f", d!) + "km away"
                    
                    point.title = parseUser.username
                    point.coordinate = CLLocationCoordinate2DMake(parseUser.Coordinate.latitude, parseUser.Coordinate.longitude)
                    point.imageName = "man13-2.png"
                    self.mapView.addAnnotation(point)
               
                user.coordinate = CLLocationCoordinate2DMake(User.currentUser()!.Coordinate!.latitude, User.currentUser()!.Coordinate!.longitude)
         
                self.mapView.addAnnotation(user)
                    mapView.showAnnotations(mapView.annotations, animated: true)
                
                //mapView.camera.altitude *= 1.4;

//                   var viewRegion = MKCoordinateRegionMakeWithDistance(point.coordinate, self.d!, self.d!);
//                    var adjustedRegion = mapView.regionThatFits(viewRegion)
//                
//                    mapView.setRegion(adjustedRegion, animated: true);
                 mapView.selectAnnotation(point, animated: true)
                }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     var point = PersonAnnotation()
    
    func action (rec: UILongPressGestureRecognizer){
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation && $0 !== self.point}
        mapView.removeAnnotations( annotationsToRemove )
        
        var touchPoint : CGPoint  =  rec.locationInView(mapView)
        var touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        var pa = MKPointAnnotation()
        pa.coordinate = touchMapCoordinate;
        var placemark = MKPlacemark(coordinate: pa.coordinate, addressDictionary: nil)
        pa.title = "Selected place";
        mapView.addAnnotation(pa)
        mapView.selectAnnotation(pa, animated: true)
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: pa.coordinate.latitude, longitude: pa.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as? [CLPlacemark]
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            var sub: String = ""
            if let locationName = placeMark.addressDictionary["Name"] as? String {
                sub += locationName
            }
            if let city = placeMark.addressDictionary["City"] as? String {
                sub += ", " + city
            }
            pa.subtitle = sub
        })
    }

    var selectedLocation: CLLocationCoordinate2D?
   
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet \(self.parseUser!.username!)?", preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Time of meeting and comments"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                self.message = textField.text
            }
        })
        
        let sendRequestActionHandler = { (action:UIAlertAction!) -> Void in
            self.selectedLocation = view.annotation.coordinate
            self.sendRequest(self.parseUser)
            let alertMessage = UIAlertController(title: "Request sent", message: "Meeting in \(view.annotation.subtitle!)", preferredStyle: .Alert)
            
            alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertMessage, animated: true, completion: nil)
        }
        
        let requestAction = UIAlertAction(title: "Send request", style: .Default, handler: sendRequestActionHandler)
        alertController.addAction(requestAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    var message: String?
    func sendRequest(toUser: User?){
        let geoPoint = PFGeoPoint(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude)
        let params = ["userId" : parseUser!.objectId!,  "location" : geoPoint, "message" : message!, "status": "pending", "read": "false"]
        PFCloud.callFunctionInBackground("sendRequest", withParameters: params) { (request, error) -> Void in
            
            if let error = error {
                //failed to send message to server
            }
            
        }
        
        var pushQuery = PFInstallation.query()
        pushQuery?.whereKey("user", equalTo: parseUser!)
        var push = PFPush()
        push.setQuery(pushQuery)
        push.setMessage("You have received a meeting request from \(User.currentUser()!.username!)")
        push.sendPushInBackground()
    
        
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        if let annotation = annotation as? PersonAnnotation {
            annotation.imageName = "man13-2.png"
            var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
            annotationView.image = UIImage(named: "man13-2.png")
              //annotationView.canShowCallout = true
            return annotationView
        }
       
        var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
        
        let detailButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        detailButton.tintColor = UIColor.blackColor()
        annotationView.rightCalloutAccessoryView = detailButton
       annotationView.canShowCallout = true
        
        return annotationView
    }

    func getDirection(){
        
        var alert: UIAlertView = UIAlertView(title: "Getting directions", message: "Please wait, this will take a few seconds...", delegate: nil, cancelButtonTitle: "Cancel");
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        var myDestination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(parseUser!.Coordinate.latitude, parseUser!.Coordinate.longitude), addressDictionary: nil)
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
            alert.dismissWithClickedButtonIndex(0, animated: true)
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("startGame", sender: self)
        self.performSegueWithIdentifier("openMessages", sender: self)
        self.performSegueWithIdentifier("openMap", sender: self)
    }
    
    

}
