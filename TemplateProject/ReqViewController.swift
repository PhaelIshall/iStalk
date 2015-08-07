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


class ReqViewController: UIViewController, UITableViewDelegate, MKMapViewDelegate{
    
    
    @IBOutlet weak var accept: UIButton?
    
    @IBOutlet weak var decline: UIButton?
    
    
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
            arrowImageView.image = UIImage(named: "Rightarrow.png")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.alpha = 0.5
        mapView.showsUserLocation = true;
        
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
    
}