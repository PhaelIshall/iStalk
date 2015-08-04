//
//  Request.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 8/4/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

//import UIKit
//import Parse
//
//
//class RequestMeeting: PFObject, PFSubclassing {
//   
//    var location: PFGeoPoint!{
//        get{
//            return self["location"]! as! PFGeoPoint
//        }
//        set{
//            self["location"] = newValue
//        }
//    }
//    var fromUser: User {
//        get{
//            return self["fromUser"] as! User
//        }
//    }
//    var message: String {
//        get{
//            return self["message"] as! String
//        }
//    }
//    
//    var status: String {
//        get{
//            return self["request"] as! String
//        }
//        set{
//            self["request"] = newValue
//        }
//    }
//
//    override init () {
//        super.init()
//    }
//    
//    override class func initialize() {
//        var onceToken : dispatch_once_t = 0;
//        dispatch_once(&onceToken) {
//        self.registerSubclass()
//        }
//    }
//}
