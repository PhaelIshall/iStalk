
import UIKit
import GoogleMaps
import MapKit
import ParseUI
import CoreLocation

class SendRequestViewController: UIViewController, UISearchBarDelegate, MKMapViewDelegate {
    var selectedLocation: CLLocationCoordinate2D?
    var searchController:UISearchController!
    var selectedFriend: User?
    var nearbySelected: Bool = false
    
    @IBAction func showSearchBar(sender: AnyObject) {
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: searchController)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        // Present the view controller
        presentViewController(searchController, animated: true, completion: nil)
    }
    var businesses: [Business]!
    func searchForPlace(searchtext: String, userLocation: MKUserLocation!){
        Business.searchWithTerm(userLocation, term: searchtext, sort: .Distance, categories: [], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                var point = MKPointAnnotation()
                point.title = business.name
                point.subtitle = business.address
                point.coordinate = business.coordinate
                self.mapView.addAnnotation(point)
            }
        }
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        searchForPlace(searchText, userLocation: mapView.userLocation)
    }
    
    
    var address: String?
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
    var point = MKPointAnnotation()
    var user = PersonAnnotation()
    var parseUser: User? {
        didSet {
            if (!nearbySelected){
                if let parseUser = self.parseUser {
                    let updatedFriend = parseUser
                    self.parseUser?.Coordinate = updatedFriend.Coordinate
                    
                   
                    point.title = parseUser.username
                    point.coordinate = CLLocationCoordinate2DMake(parseUser.Coordinate.latitude, parseUser.Coordinate.longitude)
                    self.mapView.addAnnotation(point)
                    mapView.selectAnnotation(point, animated: true)
                    user.coordinate = CLLocationCoordinate2DMake(User.currentUser()!.Coordinate!.latitude, User.currentUser()!.Coordinate!.longitude)
                    
                    self.mapView.addAnnotation(user)
                    mapView.showAnnotations(mapView.annotations, animated: true)
                    
                    
                    mapView.showAnnotations(mapView.annotations, animated: true)

                }
            }
        }
    }

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true;
        mapView.delegate = self;
        let alertController = UIAlertController()
        if (!nearbySelected){
            let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet\(parseUser?.username!) in \(address!)", preferredStyle: .Alert)
        }
        else{
            let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet in \(address!)", preferredStyle: .Alert)

        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        let sendRequestActionHandler = { (action:UIAlertAction!) -> Void in
            //SEND REQUEST HERE
        }
        let requestAction = UIAlertAction(title: "Send request", style: .Default, handler: sendRequestActionHandler)
        alertController.addAction(requestAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        var press: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "action:")
        press.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(press)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        var viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true);
    }
    
    var touchMapCoordinate: CLLocationCoordinate2D?

    func action (rec: UILongPressGestureRecognizer){
        let annotationsToRemove = mapView.annotations.filter { $0 !== self.mapView.userLocation }
        mapView.removeAnnotations( annotationsToRemove )
        var touchPoint : CGPoint  =  rec.locationInView(mapView)
        touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        var pa = MKPointAnnotation()
        pa.coordinate = touchMapCoordinate!;
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
        mapView.selectAnnotation(pa, animated: true)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        
        var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}