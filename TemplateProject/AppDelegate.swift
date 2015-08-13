//
//  AppDelegate.swift
//  Template Project
//
//  Created by Benjamin Encz on 5/15/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse
import CoreLocation
import FBSDKCoreKit
import ParseUI
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate  {
    
    struct Constants {
        static let DidReceiveNotificationForChannel = "Did Receive Notification For Channel"
        
        static let DidLoginNotification = "Did Login Notification"
        static let DidLogoutNotification = "Did Logout Notification"
    }
    
    var parseLoginHelper: ParseLoginHelper!
    var window: UIWindow?
    var pushNotificationController:PushNotificationController?
    var locationManager: CLLocationManager!
    var lastLocation : CLLocation?
    
    override init() {
        super.init()
        
        parseLoginHelper = ParseLoginHelper {[unowned self] user, error in
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            } else  if let user = user {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewControllerWithIdentifier("InitialVC") as! UIViewController
               
                self.window?.rootViewController!.presentViewController(tabBarController, animated: true, completion: nil)
                self.pushNotificationController = PushNotificationController()
                
                
                let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
                
                UIApplication.sharedApplication().registerUserNotificationSettings(settings)
                UIApplication.sharedApplication().registerForRemoteNotifications()
                self.initLocationManager()
            }
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        User.registerSubclass()
    Parse.setApplicationId("WN6bWYA5G0Nnsm5FF4HMNMmjmDaG39261z0lsnZt", clientKey: "9TSZM0QV3TKKqQMXjr2vu9S22RdkilPyPLWHY7bH")
    GMSServices.provideAPIKey("AIzaSyD_ylpRvrjZdLA-T0Hk5ymMNDX8X9iDlEI")

        let user = User.currentUser()
        let startViewController: UIViewController;
        if (user != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            startViewController = storyboard.instantiateViewControllerWithIdentifier("InitialVC") as! UIViewController
        } else {
            // 4
            // Otherwise set the LoginViewController to be the first
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewControllerWithIdentifier("InitialVC") as! UIViewController
            
            startViewController = loginViewController

            }
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = startViewController;
            self.window?.makeKeyAndVisible()
        initLocationManager()
//        if User.currentUser() != nil {
//            initLocationManager()
//        }
        
     
        
//        let push = PFPush()
//        push.setChannel("News")
//        push.setMessage("You have received a new message!")
//        push.sendPushInBackground()
        
        
//        let pushQuery = MeetingRequest.query()
//        pushQuery!.whereKey("toUser", equalTo: User.currentUser()!)
//        pushQuery?.whereKey("read", equalTo: "false")
        
//        // Send push notification to query
//        let push = PFPush()
//        push.setQuery(pushQuery) // Set our Installation query
//        push.setMessage("You have a new request!")
//        push.sendPushInBackground()
//        
        
      PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)  
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("didRegisterForRemoteNotificationsWithDeviceToken")
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.addUniqueObject("News", forKey: "channels")
        currentInstallation["user"] = User.currentUser()
        
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("failed to register for remote notifications:  (error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("didReceiveRemoteNotification")
        PFPush.handlePush(userInfo)
    }
    
    func initLocationManager(){
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.last as? CLLocation {
            if let lastLocation = self.lastLocation {
                let region = CLCircularRegion(center: lastLocation.coordinate, radius: 1.0, identifier: "region")
                if !region.containsCoordinate(location.coordinate) { //user moved more than 1 meter
                    updateLocationOnServer(location)
                }
            }
            else { //first time this function is getting called
                updateLocationOnServer(location)
            }
        }
    }
    
    func updateLocationOnServer(location: CLLocation) {
        User.currentUser()?.updateCoordinate(location.coordinate.latitude, longitude: location.coordinate.longitude)
        self.lastLocation = location
    }
    
    func beginUpdatingLocation()
    {
        locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            beginUpdatingLocation()
            
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Getting user's location failed!" , error)
    }
    
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    //MARK: Facebook Integration
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}



