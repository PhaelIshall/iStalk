//
//  NavigationController.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 7/27/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barStyle = UIBarStyle.Black
        self.navigationBar.translucent = true
       self.navigationBar.barTintColor = UIColor(red: 0.11, green: 0.27, blue: 0.53, alpha: 1.0)
        self.navigationBar.tintColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   }
