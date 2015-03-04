import UIKit

class LoginViewController: GAITrackedViewController, FBLoginViewDelegate, LoginWithEmailDelegate, SignUpWithEmailDelegate {
    
    @IBOutlet weak var loginView: FBLoginView!
    @IBOutlet weak var bgImage: UIImageView!
  
    enum SegueIdentifier: String {
        case PresentLoginWithEmail = "presentLoginWithEmail"
        case PresentSignUpWithEmail = "presentSignUpWithEmail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Login"
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self
        
//        TODO: Need launch images without logo. 
//              Now the bgImage is using login-background.png, which isn't exactly the same scale with launch images
//        if let image = launchImage() {
//            bgImage.image = image
//        }
    }

    override func viewWillDisappear(animated: Bool) {
      super.viewWillDisappear(animated)
    }

    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        NSLog("Facebook login successful");
        GAI.sharedInstance().defaultTracker
            .send(GAIDictionaryBuilder.createEventWithCategory("auth", action: "fb_login_success", label:"Facebook Login Successful", value:nil).build())

        User.currentUser.facebookName = user.objectForKey("name") as? String
        User.currentUser.facebookID = user.objectForKey("id") as? String
        User.currentUser.getFacebookProfilePicture { _ in}
        User.currentUser.didLoginWithFacebook = true
        
        var loginEmail: String;
        if let email = user.objectForKey("email") as? String {
            loginEmail = email;
        }
        else {
            loginEmail = "\(User.currentUser.facebookID!)@facebook.com"
        }

        var authToken = "\(FBSession.activeSession().accessTokenData)"

        FunSession.sharedSession.fbSignIn(loginEmail, authToken: authToken) {
            NSLog("API signin successful")
            dispatch_async(dispatch_get_main_queue()) {
                self.performSegueWithIdentifier("loggedIn", sender: self)
            }
        }
    }

    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        loginView.hidden = false
    }
    
    @IBAction func cancelLogin(unwindSegue: UIStoryboardSegue) {
        
    }
    
    func didLoginWithEmail() {
        println("API login successful")

        presentLoggedIn()
    }
    
    func didSignUpWithEmail() {
        println("API sign up successful")
        
        presentLoggedIn()
    }

    func presentLoggedIn() {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                self.performSegueWithIdentifier("loggedIn", sender: self)
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = SegueIdentifier(rawValue: segue.identifier!) {
            switch segueIdentifier {
            case .PresentLoginWithEmail:
                if let loginWithEmailViewController = segue.destinationViewController as? LoginWithEmailViewController {
                    loginWithEmailViewController.delegate = self
                }
            case .PresentSignUpWithEmail:
                if let signUpWithEmailViewController = segue.destinationViewController as? SignUpWithEmailViewController {
                    signUpWithEmailViewController.delegate = self
                }
            }
        }
    }
    
    func launchImage() -> UIImage? {
        func launchImageFileName() -> String {
            switch(UIScreen.mainScreen().bounds.size.height) {
            case 568:
                return "LaunchImage-700-568h@2x"
            case 667:
                return "LaunchImage-800-667h@2x"
            case 736:
                return "LaunchImage-800-Portrait-736h@3x"
            default:
                return "LaunchImage-700@2x"
            }
        }
        
        let fileName = launchImageFileName()
        if let file = NSBundle.mainBundle().pathForResource(fileName, ofType: "png") {
            return UIImage(contentsOfFile: file)!
        }
        return nil
    }
}
