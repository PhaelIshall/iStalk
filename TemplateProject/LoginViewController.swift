
import UIKit
import ParseUI
import Parse

class LoginViewController: PFLogInViewController {

    override func viewDidLoad() {
      super.viewDidLoad()
        self.logInView?.logo = nil
        var imgView : UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)
        imgView.image = UIImage(named: "IMG_2819 copy.jpg")
        self.logInView?.addSubview(imgView)
        self.logInView?.sendSubviewToBack(imgView)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
