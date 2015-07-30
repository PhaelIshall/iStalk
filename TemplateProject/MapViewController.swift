//import UIKit
//import GooglePlacesAutocomplete
//
//class MapViewController: UIViewController {
//    
//    var friend: User?
//    
//    let gpaViewController = GooglePlacesAutocomplete(
//        apiKey: "AIzaSyD_ylpRvrjZdLA-T0Hk5ymMNDX8X9iDlEI",
//        placeType: .Address
//    )
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        gpaViewController.placeDelegate = self
//        
//        presentViewController(gpaViewController, animated: true, completion: nil)
////        let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet\(friend?.username)?", preferredStyle: .Alert)
////        
////        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
////        self.presentViewController(alertController, animated: true, completion: nil)
//        
//
//    }
//    
//}
//extension MapViewController: GooglePlacesAutocompleteDelegate {
//    func placeSelected(place: Place) {
//        self.dismissViewControllerAnimated(true, completion: { () -> Void in
//            let alertController = UIAlertController(title: "Send request", message: "Would you like to send a request to meet?", preferredStyle: .Alert)
//            
//            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
//            self.presentViewController(alertController, animated: true, completion: nil)
//            
//            //            let alertController = UIAlertController(title: "Request to meet", message: "Are you sure you want to invite \(self.parseUser?.username) to meet?", preferredStyle: .Alert)
//            //
//            //            let defaultAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//            //            alertController.addAction(defaultAction)
//            //
//            //            let callActionHandler = { (action:UIAlertAction!) -> Void in
//            //                let alertMessage = UIAlertController(title: "Service Unavailable", message: "Sorry, the call feature is not available yet. Please retry later.", preferredStyle: .Alert)
//            //                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//            //                self.presentViewController(alertMessage, animated: true, completion: nil)
//            //            }
//            //            let callAction = UIAlertAction(title: "Call", style: .Default, handler: callActionHandler)
//            //            alertController.addAction(callAction)
//            //            presentViewController(alertController, animated: true, completion: nil)
//            //
//            
//            
//            self.presentViewController(alertController, animated: true, completion: nil)
//            
//            //println(place.description)
//            
//            //place.getDetails { details in
//            //  println(details)
//            //}
//
//        })
//    }
//    
//    func placeViewClosed() {
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//}
