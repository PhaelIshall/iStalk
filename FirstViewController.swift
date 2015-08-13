//
//  FirstViewController.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 8/10/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit


class FirstViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    
    var searchController:UISearchController!
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: searchController)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        // Present the view controller
        presentViewController(searchController, animated: true, completion: nil)
    }
    
      @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true;
        var zoomLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
        zoomLocation.latitude = 40.74783393329642
        zoomLocation.longitude = -74.00075651576213
        var viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true);
        mapView.delegate = self;
        
        
        var press: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        
        press.minimumPressDuration = 0.25
        mapView.addGestureRecognizer(press)
    }
    
    func action (rec: UILongPressGestureRecognizer){
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        
        var touchPoint : CGPoint  =  rec.locationInView(mapView)
        var touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        var pa = MKPointAnnotation()
        pa.coordinate = touchMapCoordinate;
        var placemark = MKPlacemark(coordinate: pa.coordinate, addressDictionary: nil)
        pa.title = "Selected place";
        mapView.addAnnotation(pa)
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: pa.coordinate.latitude, longitude: pa.coordinate.longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            let placeArray = placemarks as? [CLPlacemark]
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            var sub: String = ""
            // Address dictionary
            
            // Location name
            if let locationName = placeMark.addressDictionary["Name"] as? String {
                sub += locationName
            }
            if let city = placeMark.addressDictionary["City"] as? String {
                sub += ", " + city
            }
            pa.subtitle = sub
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
