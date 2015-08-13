import UIKit
import Foundation
import JSQMessagesViewController
import SDWebImage
import Parse



class MessageViewController: JSQMessagesViewController {
    var friend: User? {
        didSet {
            if let friend = self.friend {
                ParseHelper.getMessagesforUser(friend) { (messages, error) -> Void in
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                        return
                    }
                    self.messages = messages as! [Message]
                }
            }
        }
    }

    var placeholder: UIImage = UIImage(named: "Icon-60@3x.png")!
    var messages = [Message](){
        didSet {
            if self.isViewLoaded() {
                scrollToBottomAnimated(false)
                self.collectionView.reloadData()
            }
        }

    }
    var avatars = Dictionary<String, UIImage>()
    var createdAt : NSDate?
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Back"
        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        
         self.automaticallyScrollsToMostRecentMessage = true
        senderDisplayName = User.currentUser()!.username
        senderId = User.currentUser()!.objectId
    }
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        var viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1900, 1900);
        var adjustedRegion = mapView.regionThatFits(viewRegion)
        mapView.setRegion(adjustedRegion, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func didPressSendButton(button: UIButton!, withMessageText text: String, senderId: String!, senderDisplayName: String!, date: NSDate!)
    {
        let message = Message(message: text, toUser: friend!)
        self.messages.append(message)
        
        let params = ["userId" : friend!.objectId!, "message" : text]
        PFCloud.callFunctionInBackground("sendMessage", withParameters: params) { (message, error) -> Void in
            self.messages.removeLast()
            if let error = error {
                //failed to send message to server
            }
            
            self.messages.append(message as! Message)
            self.finishSendingMessageAnimated(true)
        }
        
        var pushQuery = PFInstallation.query()
        pushQuery?.whereKey("user", equalTo: friend!)
        
        
        var push = PFPush()
        push.setQuery(pushQuery)
        push.setMessage("New message from \(User.currentUser()!.username!)")
        push.sendPushInBackground()
        
    
    
    }    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData!
    {
        return self.messages[indexPath.row].chatMessage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        let message = self.messages[indexPath.row]
        if message.author.objectId == User.currentUser()!.objectId {
            return self.outgoingBubbleImageView
        }
        else {
            return self.incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        let avatar = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: placeholder)
    
        let userID = User.currentUser()!.fbID
        let query = User.query()
        query!.whereKey("FBID", equalTo: userID)
        
        let url = NSURL(string: "http://graph.facebook.com/\(userID)/picture")
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: .LowPriority, progress: nil) { (image, error, _, _, _) -> Void in
                avatar.avatarImage = image
            }
        return avatar
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString!
    {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.row]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.createdAt)
        }
        return nil
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.row]
        
        
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.height / 2
        cell.avatarImageView.layer.masksToBounds = true
        cell.avatarImageView.layer.borderWidth = 0
        
        if message.author == User.currentUser()! {
            cell.textView.textColor = UIColor.whiteColor()
        }
        else {
            cell.textView.textColor = UIColor.blackColor()
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!)
    {
        self.showLoadEarlierMessagesHeader = true
    }
    

    
}
