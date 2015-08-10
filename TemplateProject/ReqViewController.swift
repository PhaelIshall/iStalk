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
import QuartzCore

class ReqViewController: UIViewController, UITableViewDelegate, MKMapViewDelegate{
    
    @IBOutlet weak var msg: UITextView?
    
    var txt: String?
    
    @IBOutlet weak var friendName: UITextView!
    
    @IBOutlet weak var accept: UIButton?
    
    @IBOutlet weak var decline: UIButton?
    
    @IBOutlet weak var expand: UIBarButtonItem!
    
    @IBAction func showMenu(sender: AnyObject) {
        slide(menu)
    }
    
    var down: Bool = false
    
    func slide(view: UIView){
//        var transition = CATransition()
//        transition.duration = 10
        if (!down){
            view.frame = CGRectMake( 0, 380, view.frame.size.width , view.frame.size.height );
            down = true
        }
        else{
            view.frame = CGRectMake( 500, 380, view.frame.size.width , view.frame.size.height  );
            down = false
        }
//        transition.type = kCATransitionPush;
//        transition.subtype = kCATransitionFromTop ;
        //view.layer.addAnimation(transition, forKey: nil)
        //transition.delegate = self;
    }
    
    @IBOutlet weak var menu: UIView!
    
    var friend: User?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var directions: UIBarButtonItem!
    @IBAction func direct(sender: AnyObject) {
        getDirection()
    }
    
    var location: CLLocationCoordinate2D?
    var compass  = GeoPointCompass()
    
    @IBOutlet var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = UIImage(named: "Icon-60@3x.png")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendName.text = "\(friend!.username!) said: "
        mapView.alpha = 1
        mapView.showsUserLocation = true;
      
        msg?.text = txt
        var point = MKPointAnnotation()
        point.title = friend!.username
        point.coordinate = CLLocationCoordinate2DMake(friend!.Coordinate.latitude, friend!.Coordinate.longitude)
        
        var selectedLocation = MKPointAnnotation()
        selectedLocation.title = "Suggested location"
        selectedLocation.subtitle = "Your friend selected this location"
      
        selectedLocation.coordinate = location!
        
        self.mapView.addAnnotation(selectedLocation)
        self.mapView.addAnnotation(point)
        
        var viewRegion = MKCoordinateRegionMakeWithDistance(selectedLocation.coordinate, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true);
        mapView.delegate = self;
        
        var place = PFGeoPoint()
        place.latitude = location!.latitude
        place.longitude = location!.longitude
        
        var dist = friend!.Coordinate.distanceInKilometersTo(place);
        self.title = "Your friend is " + String(format:"%.1f", dist) + "km from the destination"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        

        var myDestination = MKPlacemark(coordinate: location!, addressDictionary: nil)
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
                if (msg == ""){
                    msg += "After \(step.distance) metres: \(step.instructions)"
                    
                }
                else {
                    msg += "\nAfter \(step.distance) metres: \(step.instructions)"
                }
            }
            let alertController = UIAlertController(title: "Get directions", message: msg, preferredStyle: .Alert)
            alert.dismissWithClickedButtonIndex(0, animated: true)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openMessages") {
        let messageViewController = segue.destinationViewController as! MessageViewController
        messageViewController.friend = friend
        }
    }
    
    func showRoute(response: MKDirectionsResponse) {
        for route in response.routes as! [MKRoute] {
            
            mapView.addOverlay(route.polyline,
                level: MKOverlayLevel.AboveRoads)
            
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
    
}