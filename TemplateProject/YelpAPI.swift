
//import UIKit
//import Foundation
//
//
//// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
//let yelpConsumerKey = "DKiwwRZDQrbW0K99fPT9og"
//let yelpConsumerSecret = "Rp5UnFlEssBVSUKRXyVkcSvo1tQ"
//let yelpToken = "_ol0fJZVEnc2uAxnaIYfN3OLhDAzVGBL"
//let yelpTokenSecret = "h9EvHg7QqZ9zYumBX_9x1uZoObY"
//
//enum YelpSortMode: Int {
//    case BestMatched = 0, Distance, HighestRated
//}
//
//class YelpAPI: BDBOAuth1RequestOperationManager {
//    var accessToken: String!
//    var accessSecret: String!
//    
//    class var sharedInstance : YelpAPI {
//        struct Static {
//            static var token : dispatch_once_t = 0
//            static var instance : YelpAPI? = nil
//        }
//        
//        dispatch_once(&Static.token) {
//            Static.instance = YelpAPI(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
//        }
//        return Static.instance!
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
//        self.accessToken = accessToken
//        self.accessSecret = accessSecret
//        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
//        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
//        
//        var token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
//        self.requestSerializer.saveAccessToken(token)
//    }
//    
//    func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
//        return searchWithTerm(term, sort: nil, categories: nil, deals: nil, completion: completion)
//    }
//    
//    func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
//        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
//        
//        // Default the location to San Francisco
//        var parameters: [String : AnyObject] = ["term": term, "ll": "\(User.currentUser()?.Coordinate.latitude),\(User.currentUser()?.Coordinate.longitude)"]
//        
//        if sort != nil {
//            parameters["sort"] = sort!.rawValue
//        }
//        
//        if categories != nil && categories!.count > 0 {
//            parameters["category_filter"] = ",".join(categories!)
//        }
//        
//        if deals != nil {
//            parameters["deals_filter"] = deals!
//        }
//        
//        println(parameters)
//        
//        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            var dictionaries = response["businesses"] as? [NSDictionary]
//            if dictionaries != nil {
//                completion(Business.businesses(array: dictionaries!), nil)
//            }
//            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
//                completion(nil, error)
//        })
//    }
//}
