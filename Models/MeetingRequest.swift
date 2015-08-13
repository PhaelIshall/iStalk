//
//  MeetingRequest.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 8/2/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class MeetingRequest:  PFObject, PFSubclassing {
    
    @NSManaged var fromUser: User!
    @NSManaged var toUser: User!
    var location: PFGeoPoint!{
                get{
                    return self["location"]! as! PFGeoPoint
                }
                set{
                    self["location"] = newValue
                }
            }
            
            var message: String {
                get{
                    return self["message"] as! String
                }
            }
        
            var status: String {
                get{
                    return self["request"] as! String
                }
                set{
                    self["request"] = newValue
                }
            }
    var read: String {
        get{
            return self["read"] as! String
        }
        set{
            self["read"] = newValue
        }
    }

    

    override init() {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
}



extension MeetingRequest: PFSubclassing {
    static func parseClassName() -> String {
        return "MeetingRequest"
    }
}

