import UIKit
import Parse
import JSQMessagesViewController

class Message: PFObject
{
    @NSManaged var author: User!
     @NSManaged var toUser: User!
    @NSManaged var message: String!
    
    var chatMessage: JSQMessage {
        get {
            return JSQMessage(senderId: self.author.objectId, senderDisplayName: self.author.username, date: self.createdAt ?? NSDate(), text: self.message)
        }
    }
    
    init(message: String, toUser: User) {
        super.init()
        self.author = User.currentUser()
        self.message = message
        self.toUser = toUser
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


extension Message: PFSubclassing {
    static func parseClassName() -> String {
        return "Message"
    }
}
