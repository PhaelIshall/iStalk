import UIKit
import GoogleMaps
import Parse

class PickerViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {
    
    var message : String = ""
    var selectedLocation: CLLocationCoordinate2D?
    
    var searchController:UISearchController!
    @IBAction func showSearchBar(sender: AnyObject) {
        // Create the search controller and make it perform the results updating.
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        // Present the view controller
        presentViewController(searchController, animated: true, completion: nil)
    }

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedFriend : User?
    
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//                Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
//                    self.businesses = businesses
//        
//                    for business in businesses {
//                        println(business.name!)
//                        println(business.address!)
//                    }
//                })
        
        
                mapView.showsUserLocation = true;

        var zoomLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
        zoomLocation.latitude = User.currentUser()!.Coordinate.latitude
        zoomLocation.longitude = User.currentUser()!.Coordinate.longitude
        
        var viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        
        
         mapView.setRegion(adjustedRegion, animated: true);
        
        mapView.delegate=self;
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
//                println(business.name!)
//                println(business.address!)
                var point = MKPointAnnotation()
                point.title = business.name
                point.subtitle = business.address
                point.coordinate = business.coordinate
                self.mapView.addAnnotation(point)
            }
        }
        

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
        let params = ["userId" : selectedFriend!.objectId!,  "location" : geoPoint, "message": message]
        PFCloud.callFunctionInBackground("sendRequest", withParameters: params) { (request, error) -> Void in
            
            if let error = error {
                //failed to send message to server
            }
           
        }
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