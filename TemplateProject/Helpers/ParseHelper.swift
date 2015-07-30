//
//  ParseHelper.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 7/9/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Parse

class ParseHelper: NSObject {
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    
    static func getMessagesforUser(user: User, completionBlock: PFArrayResultBlock)
    {
        let query1 = PFQuery(className: "Message")
        query1.whereKey("toUser", equalTo: user)
        query1.whereKey("author", equalTo: User.currentUser()!)
        let query2 = PFQuery(className: "Message")
        query2.whereKey("author", equalTo: user)
        query2.whereKey("toUser", equalTo: User.currentUser()!)
 
        var query = PFQuery.orQueryWithSubqueries([query1, query2])
        
        query.includeKey("toUser")
        query.includeKey("author")
     
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    static func nearbyUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = User.query()
        query!.whereKey("Coordinate", nearGeoPoint: User.currentUser()!.Coordinate, withinKilometers: 0.5)
        query!.orderByAscending(ParseHelper.ParseUserUsername)
        query!.limit = 20
        
        query!.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query!
    }
    
    static func allUsers(completionBlock: PFArrayResultBlock) -> PFQuery {
        let query = User.query()!
        // exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername,
            notEqualTo: User.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
        return query
    }
   

    static func searchUsers(searchText: String, completionBlock: PFArrayResultBlock)
        -> PFQuery {
            let query = User.query()!.whereKey(ParseHelper.ParseUserUsername,
                matchesRegex: searchText, modifiers: "i")
            
            query.whereKey(ParseHelper.ParseUserUsername,
                notEqualTo: User.currentUser()!.username!)
            
            query.orderByAscending(ParseHelper.ParseUserUsername)
            query.limit = 20
            
            query.findObjectsInBackgroundWithBlock(completionBlock)
            
            return query
    }
}
