import UIKit
import GoogleMaps
import Parse

class PickerViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
    
    var message : String = ""
    var selectedLocation: CLLocationCoordinate2D?
    
    //Search controller related
    var searchController:UISearchController!
    @IBAction func showSearchBar(sender: AnyObject) {
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: searchController)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        // Present the view controller
        presentViewController(searchController, animated: true, completion: nil)
    }
//    var annotation:MKAnnotation!
//    var localSearchRequest:MKLocalSearchRequest!
//    var localSearch:MKLocalSearch!
//    var localSearchResponse:MKLocalSearchResponse!
//    var error:NSError!
//    var pointAnnotation:MKPointAnnotation!
//    var pinAnnotationView:MKPinAnnotationView!
    
    @IBOutlet weak var mapView: MKMapView!
    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar){
//        searchBar.resignFirstResponder()
//        dismissViewControllerAnimated(true, completion: nil)
//        if self.mapView.annotations.count != 0{
//            annotation = self.mapView.annotations[0] as! MKAnnotation
//            self.mapView.removeAnnotation(annotation)
//        }
//        localSearchRequest = MKLocalSearchRequest()
//        localSearchRequest.naturalLanguageQuery = searchBar.text
//        localSearch = MKLocalSearch(request: localSearchRequest)
//        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
//            
//            if localSearchResponse == nil{
//                var alert = UIAlertView(title: nil, message: "Place not found", delegate: self, cancelButtonTitle: "Try again")
//                alert.show()
//                return
//            }
//            self.pointAnnotation = MKPointAnnotation()
//            self.pointAnnotation.title = searchBar.text
//            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse.boundingRegion.center.latitude, longitude:     localSearchResponse.boundingRegion.center.longitude)
//            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
//            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
//            self.mapView.addAnnotation(self.pinAnnotationView.annotation)
       //}
    //}
    
    
    
    
    var selectedFriend : User?
    
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true;
        var zoomLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
        zoomLocation.latitude = User.currentUser()!.Coordinate.latitude
        zoomLocation.longitude = User.currentUser()!.Coordinate.longitude
        var viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true);
        mapView.delegate=self;

        
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
    
    func searchForPlace(searchtext: String){
        Business.searchWithTerm(nil,term: searchtext, sort: .Distance, categories: [], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
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
        searchForPlace(searchText)
    }
    
    
        func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
            
            let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet \(self.selectedFriend!.username!)?", preferredStyle: .Alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alertController.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Time of meeting and comments"
                
                NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                    self.message = textField.text
                }
            })
            
            let sendRequestActionHandler = { (action:UIAlertAction!) -> Void in
                   self.selectedLocation = view.annotation.coordinate
                       self.sendRequest(self.selectedFriend)
                let alertMessage = UIAlertController(title: "Request sent", message: "Meeting in \(view.annotation.subtitle!) and \(self.message)", preferredStyle: .Alert)
             
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
     
            let requestAction = UIAlertAction(title: "Send request", style: .Default, handler: sendRequestActionHandler)
            alertController.addAction(requestAction)
            self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func sendRequest(toUser: User?){
        let geoPoint = PFGeoPoint(latitude: selectedLocation!.latitude, longitude: selectedLocation!.longitude)
        let params = ["userId" : selectedFriend!.objectId!,  "location" : geoPoint, "message": message, "status": "pending", "read": "false"]
        PFCloud.callFunctionInBackground("sendRequest", withParameters: params) { (request, error) -> Void in
            
            if let error = error {
                //failed to send message to server
            }
           
        }
        var pushQuery = PFInstallation.query()
        pushQuery?.whereKey("user", equalTo: selectedFriend!)
        var push = PFPush()
        push.setQuery(pushQuery)
        push.setMessage("You have received a meeting request from \(User.currentUser()!.username!)")
        push.sendPushInBackground()
        
        
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        
        var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
        annotationView.canShowCallout = true
        let detailButton: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        annotationView.rightCalloutAccessoryView = detailButton
        
        return annotationView
    }
}


extension PickerViewController : UITextFieldDelegate {
    func textFieldDidChange(textField: UITextField) {
        message = textField.text
    }
}