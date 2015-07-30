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
