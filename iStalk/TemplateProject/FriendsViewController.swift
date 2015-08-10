//
//  FriendsViewController.swift
//  iStalk
//
//  Created by ALAA AL MUTAWA on 7/23/15.
//  Copyright (c) 2015 Make School. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController {
    
    @IBAction func IndexChanged(sender: UISegmentedControl) {
    
        
        // this view can be in two different states
        enum State {
            case DefaultMode
            case SearchMode
        }
        
        // whenever the state changes, perform one of the two queries and update the list
        var state: State = .DefaultMode {
            didSet {
                switch (state) {
                case .DefaultMode:
                    query = ParseHelper.allUsers(updateList)
                    
                case .SearchMode:
                    let searchText = searchBar?.text ?? ""
                    query = ParseHelper.searchUsers(searchText, completionBlock:updateList)
                }
            }
        }
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            firstContainer.hidden = false
            secondContainer.hidden = true
        case 1:
            firstContainer.hidden = true
            secondContainer.hidden = false
        default:
            break;
        }
    }
    @IBOutlet weak var firstContainer: UIView!
    
    @IBOutlet weak var secondContainer: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var selectedFriend: [String: String]?
    
    @IBOutlet weak var searchBar: UISearchBar!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
    extension FriendsViewController: UISearchBarDelegate {
        
        func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
            state = .SearchMode
        }
        
        func searchBarCancelButtonClicked(searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.text = ""
            searchBar.setShowsCancelButton(false, animated: true)
            state = .DefaultMode
        }
        
        func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
            ParseHelper.searchUsers(searchText, completionBlock:updateList)
        }
        
    }

