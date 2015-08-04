
//  BusinessesViewController.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 7/30/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController {
    
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                Business.searchWithTerm("Thai", completion: { (businesses: [Business]!, error: NSError!) -> Void in
                    self.businesses = businesses
        
                    for business in businesses {
                        println(business.name!)
                        println(business.address!)
                    }
                })
        
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                println(business.name!)
                println(business.address!)
            }
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}