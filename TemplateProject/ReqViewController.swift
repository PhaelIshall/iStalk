import UIKit
import CoreLocation
import Parse
import MapKit
import QuartzCore

class ReqViewController: UIViewController, UITableViewDelegate, MKMapViewDelegate{
    
    var meetingRequest: MeetingRequest?
    
    @IBOutlet weak var msg: UITextView!
    
    var txt: String?
    
    @IBOutlet weak var friendName: UITextView!
    
    @IBOutlet weak var accept: UIButton?
    
    @IBOutlet weak var decline: UIButton?
    
    var compass  = GeoPointCompass()
    
    @IBOutlet var arrowImageView: UIImageView! {
        didSet {
            arrowImageView.image = UIImage(named: "1.png")
        }
    }
    
    
    @IBAction func acceptPressed(sender: AnyObject){
        self.meetingRequest!.setObject("Accepted", forKey: "request")
        self.meetingRequest!.save()
        accept?.hidden
        decline?.hidden
    }
    
    
    @IBAction func declinePressed(sender: AnyObject){
        self.meetingRequest!.setObject("Denied", forKey: "request")
        self.meetingRequest!.save()
        accept?.hidden
        decline?.hidden
    }
    
    @IBOutlet weak var expand: UIBarButtonItem!
    
    @IBAction func showMenu(sender: AnyObject) {
        if (meetingRequest?.status != "pending"){
//            accept?.hidden
//            decline?.hidden
            accept?.removeFromSuperview()
            decline?.removeFromSuperview()
        }
      slide(menu)

    }
    
    var down: Bool = false
    
    func slide(view: UIView){
        if (!down){
            view.frame = CGRectMake( 0, toolBar.frame.minY - view.frame.height, view.frame.size.width , view.frame.size.height );
            down = true
            
            println(meetingRequest)
            println(meetingRequest?.status)
            if (meetingRequest?.status == "Accepted"){
                if meetingRequest?.toUser.objectId == User.currentUser()?.objectId{
                    var alert: UIAlertView = UIAlertView(title: "Details", message: "You have accepted the request", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                }
                else{
                    var alert: UIAlertView = UIAlertView(title: "Details", message: "\(meetingRequest!.toUser!.username!) has accepted the request", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                }
            }
            else if (meetingRequest?.status == "Denied"){

                println(meetingRequest?.message)
                if meetingRequest?.toUser.objectId == User.currentUser()?.objectId{
                    var alert: UIAlertView = UIAlertView(title: "Details", message: "You have declined the request", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                }
                else{
                    var alert: UIAlertView = UIAlertView(title: "Details", message: "\(meetingRequest!.toUser!.username!) has declined the request", delegate: nil, cancelButtonTitle: "OK");
                    alert.show()
                }

            }
           
        }
        else{
            view.frame = CGRectMake( toolBar.frame.maxY, toolBar.frame.maxX, view.frame.size.width , view.frame.size.height  );
            down = false
        }
    }
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var menu: UIView!
    
    var friend: User?
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var directions: UIBarButtonItem!
    @IBAction func direct(sender: AnyObject) {
        getDirection()
    }
    var user = PersonAnnotation()                      //PERSON ANNOTATION
    var location: CLLocationCoordinate2D?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if meetingRequest?.fromUser != User.currentUser(){
            friendName.text = "\(friend!.username!) said: "

        }
        else{
            friendName.text = "You said: "
        }
        msg.text = txt
        mapView.alpha = 1
        arrowImageView.removeFromSuperview()
        self.view.addSubview(arrowImageView)
        
        mapView.showsUserLocation = true;
        var point = MKPointAnnotation()
        point.title = friend!.username
        point.coordinate = CLLocationCoordinate2DMake(friend!.Coordinate.latitude, friend!.Coordinate.longitude)
        
        self.compass.arrowImageView = self.arrowImageView
        self.compass.latitudeOfTargetedPoint = self.friend!.Coordinate.latitude
        self.compass.longitudeOfTargetedPoint = self.friend!.Coordinate.longitude
        
        var selectedLocation = MKPointAnnotation()

        selectedLocation.title = "Your friend selected this location"
      
        selectedLocation.coordinate = self.location!
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: selectedLocation.coordinate.latitude, longitude: selectedLocation.coordinate.longitude)
        
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
            selectedLocation.subtitle = sub
        })

        self.mapView.addAnnotation(selectedLocation)
        self.mapView.addAnnotation(point)
        
        user.coordinate = CLLocationCoordinate2DMake(User.currentUser()!.Coordinate!.latitude, User.currentUser()!.Coordinate!.longitude)
        user.imageName = "man13-2.png"                                                          //PERSON ANNOTATION
        self.mapView.addAnnotation(user)
        mapView.showAnnotations(mapView.annotations, animated: true)
        mapView.selectAnnotation(point, animated: true)

        mapView.delegate = self;
        
        var place = PFGeoPoint()
        place.latitude = self.location!.latitude
        place.longitude = self.location!.longitude
        
        var dist = User.currentUser()!.Coordinate.distanceInKilometersTo(place);
        self.title = String(format:"%.1f", dist) + "km from destination"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
       
        if let annotation = annotation as? PersonAnnotation {
            annotation.imageName = "man13-2.png"
            var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
            annotationView.image = UIImage(named: "man13-2.png")
            //annotationView.canShowCallout = true
            return annotationView
        }
        if let annotation = annotation as? MKUserLocation {
            return nil
        }
        
        var annotationView : MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")
      
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