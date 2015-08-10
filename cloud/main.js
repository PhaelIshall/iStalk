Parse.Cloud.define('sendMessage', function(request, response) {
    var userId = request.params.userId;
    var message = request.params.message

    var User = Parse.Object.extend('_User'),
        user = new User({ objectId: userId });

    var currentUser = request.user;

    var Message = Parse.Object.extend('Message'),
   	 messageObject = new Message();
    messageObject.set("message", message);
    messageObject.set("toUser", user);
    messageObject.set("author", currentUser);

    Parse.Cloud.useMasterKey();
    messageObject.save().then(function(m) {
        response.success(m);
    }, function(error) {
        response.error(error)
    });
});

Parse.Cloud.define("sendRequest", function(request, response) {
                   Parse.Cloud.useMasterKey();
                   var userId = request.params.userId;
                   var location = request.params.location;
                   var message = request.params.message; 
                   var status = request.params.status;
                   var read = request.params.read;
                   
                   
                   var User = Parse.Object.extend('_User'),
                   user = new User({ objectId: userId });
                   
                   var currentUser = request.user;
                   
                   var Request = Parse.Object.extend('MeetingRequest'),
                   requests = new Request();
                   requests.set("request", status)
                    requests.set("location", location);
                   requests.set("message", message)
                   requests.set("toUser", user);
                   requests.set("read", read)
                   requests.set("fromUser", currentUser);
                
                   requests.save();

                   response.success();
});