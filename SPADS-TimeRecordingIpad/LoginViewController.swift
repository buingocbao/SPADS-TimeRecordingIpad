//
//  LoginViewController.swift
//  SPADS-TimeRecordingIpad
//
//  Created by BBaoBao on 7/13/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var tfEmail: MKTextField!
    @IBOutlet weak var tfPassword: MKTextField!
    @IBOutlet weak var btLogin: MKButton!
    @IBOutlet weak var indicatorActivity: UIActivityIndicatorView!
    
    override func viewDidAppear(animated: Bool) {
        indicatorActivity.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.delegate = self

        //Get device size
        let bounds: CGRect = UIScreen.mainScreen().bounds
        let dvWidth:CGFloat = bounds.size.width
        let dvHeight:CGFloat = bounds.size.height
        
        //Motion Background
        // Make Motion background
        let backgroundImage:UIImageView = UIImageView(frame: CGRect(x: -50, y: -50, width: dvWidth+100, height: dvHeight+100))
        backgroundImage.image = UIImage(named: "Background.jpg")
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
        
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -50
        horizontalMotionEffect.maximumRelativeValue = 50
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -50
        verticalMotionEffect.maximumRelativeValue = 50
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        backgroundImage.addMotionEffect(motionEffectGroup)
        
        // Email textfield
        self.tfEmail.delegate = self
        tfEmail.layer.borderColor = UIColor.clearColor().CGColor
        tfEmail.floatingPlaceholderEnabled = true
        tfEmail.placeholder = "Email Account"
        //tfAccount.circleLayerColor = UIColor.MKColor.LightGreen
        tfEmail.tintColor = UIColor.MKColor.Green
        tfEmail.backgroundColor = UIColor(hex: 0xE0E0E0)
        self.view.bringSubviewToFront(tfEmail)
        
        // Password Textfield
        self.tfPassword.delegate = self
        tfPassword.layer.borderColor = UIColor.clearColor().CGColor
        tfPassword.floatingPlaceholderEnabled = true
        tfPassword.placeholder = "Password"
        //tfPassword.circleLayerColor = UIColor.MKColor.LightGreen
        tfPassword.tintColor = UIColor.MKColor.Green
        tfPassword.backgroundColor = UIColor(hex: 0xE0E0E0)
        self.view.bringSubviewToFront(tfPassword)
        
        // Login Button
        btLogin.cornerRadius = 40.0
        btLogin.backgroundLayerCornerRadius = 40.0
        btLogin.maskEnabled = false
        btLogin.ripplePercent = 1.75
        btLogin.rippleLocation = .Center
        
        btLogin.layer.shadowOpacity = 0.75
        btLogin.layer.shadowRadius = 3.5
        btLogin.layer.shadowColor = UIColor.blackColor().CGColor
        btLogin.layer.shadowOffset = CGSize(width: 1.0, height: 5.5)

        // Progress icon for logging
        self.view.bringSubviewToFront(indicatorActivity)
        indicatorActivity.hidden = true
        indicatorActivity.hidesWhenStopped = true
        
        //Check current user
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            indicatorActivity.hidden = false
            indicatorActivity.startAnimating()
            if let user = currentUser {
                if user["Group"] != nil {
                    if let userGroup = user["Group"] as? String {
                        switch userGroup {
                        case "Admin" :
                            // Perform Admin login
                            self.performSegueWithIdentifier("AdminLoginSegue", sender: false)
                        case "Manager" :
                            // Perform Manager login
                            self.performSegueWithIdentifier("ManagerLoginSegue", sender: false)
                        default: break
                            
                        }
                    }
                    
                }

            }
        }
    }

    func textFieldShouldReturn(userText: UITextField) -> Bool {
        checkLogin()
        return true;
    }
    
    func checkLogin() {
        // Start activity indicator
        indicatorActivity.hidden = false
        indicatorActivity.startAnimating()
        // The textfields are not completed
        if (self.tfEmail.text == "") || (self.tfPassword.text == "") {
            var alert = UIAlertController(title: "Login Failed", message: "Please fill your email and password", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        PFUser.logInWithUsernameInBackground(tfEmail.text, password:tfPassword.text) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicatorActivity.stopAnimating()
                    if let userObject = PFUser.currentUser() {
                        if userObject["Group"] as! String == "Manager" {
                            print("Manager found")
                            self.performSegueWithIdentifier("ManagerLoginSegue", sender: false)
                        } else if userObject["Group"] as! String == "Admin" {
                            print("Admin found")
                            self.performSegueWithIdentifier("AdminLoginSegue", sender: false)
                        } else {
                            PFUser.logOut()
                            var alert = UIAlertController(title: "Login Failed", message: "You are not Administrator or Manager for logging to this session.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
                self.tfEmail.text = ""
                self.tfPassword.text = ""
            } else {
                // The login failed. Check error to see why.
                var alert = UIAlertController(title: "Login Failed", message: "Please check your email or password", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.indicatorActivity.stopAnimating()
            }
        }
        tfEmail.placeholder = "Email Account"
        catchLoginEvent()
    }
    
    func catchLoginEvent() {
        btLogin.addTarget(self, action: "btLogin:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Check validate email
    func validate(value: String) -> Bool {
        let emailRule = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", emailRule)
        return phoneTest.evaluateWithObject(value)
    }

    @IBAction func btLogin(sender: AnyObject) {
        checkLogin()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        tfEmail.textColor = UIColor.blackColor()
        tfEmail.placeholder = "Email Account"
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        return viewController != tabBarController.selectedViewController
    }
    
    // Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ManagerLoginSegue") || (segue.identifier == "AdminLoginSegue") {
            let managerView:ManagerViewController = segue.destinationViewController as! ManagerViewController
            managerView.navigationItem.backBarButtonItem = nil
            managerView.navigationItem.hidesBackButton = true
            managerView.navigationItem.leftBarButtonItem = nil
        }
    }
    

}
