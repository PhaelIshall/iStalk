//
//  FriendFinderTableViewCell.swift
//  TemplateProject
//
//  Created by ALAA AL MUTAWA on 7/8/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit
import Bond

class FriendFinderTableViewCell: UITableViewCell {

    @IBOutlet weak var Picture: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.username
            
            if let user = user {
                user.image ->> self.Picture
            }
        }
    }
    
    

}
