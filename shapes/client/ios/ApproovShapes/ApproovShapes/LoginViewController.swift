/*****************************************************************************
 * Project:     ApproovShapes
 * File:        LoginViewController.swift
 * Original:    Created on 26 Sept 2016 by Simon Rigg
 * Copyright(c) 2002 - 2016 by CriticalBlue Ltd.
 *
 * The Login view controller class.
 ****************************************************************************/

import UIKit
import Approov

class LoginViewController: UIViewController {

    private struct Constants {
        private static let loginSegueIdentifier = "LoginSegue"
        private static let defaultStatusLabelText = "Press Login to access your account"
        private static let initFailure = "Initialisation failure"
        private static let authFailure = "Authorisation failure"
        private static let serverURLPath = "http://192.168.0.148:5000/"
        private static let approovTokenHeader = "ApproovToken"
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.text = Constants.defaultStatusLabelText
        }
    }
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    /* The flag for whether we are logging in */
    var isLoggingIn = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        /* try to register ourselves as an observer to Approov token fetch notifications */
        if let attestee = ApproovAttestee.sharedAttestee() {
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(handleApproovTokenUpdate(_:)),
                                                             name: FetchApproovTokenNotificationName,
                                                             object: attestee)
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        /* update the view controller state */
        self.statusLabel.text = Constants.defaultStatusLabelText
        self.activityIndicatorView.stopAnimating()
        self.loginButton.enabled = true
        
        /* pre-fetch Approov token just before the view appears so it's ready before the user logs in */
        if let attestee = ApproovAttestee.sharedAttestee() {
            attestee.fetchApproovToken()
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        /* unregister ourselves as an observer to Approov token fetch notifications */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func handleLoginButtonTapped(sender: UIButton) {
        
        /* update the view controller state */
        self.loginButton.enabled = false
        self.activityIndicatorView.startAnimating()
        self.isLoggingIn = true
        
        /* ensure we have an up-to-date Approov token for the log in operation */
        if let attestee = ApproovAttestee.sharedAttestee() {
            attestee.fetchApproovToken()
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    func handleApproovTokenUpdate(notification: NSNotification) {
        
        /* check to see if we are in the process of logging in - if not, we don't need to do anything further */
        if !self.isLoggingIn {
            return
        }
        
        /* extract the Approov token fetch result from the notification's user info */
        if let userInfo = notification.userInfo {
            if let result = ApproovTokenFetchResult(rawValue: userInfo[FetchApproovTokenNotificationResultKey] as! UInt) {
                switch result {
                    
                case .Successful:
                    /* if successful, we extract the Approov token from the notification's user info */
                    if let approovToken = userInfo[FetchApproovTokenNotificationTokenKey] as? String {
                        
                        /* construct and perform the login request for our server to retrieve a random shape name */
                        let request = NSMutableURLRequest(URL: NSURL(string: Constants.serverURLPath)!)
                        request.addValue(approovToken, forHTTPHeaderField: Constants.approovTokenHeader)
                        performLoginRequest(request)
                    }
                    
                case .Failed:
                    /* if failed, we display an authorisation error message to the user */
                    displayFailure(Constants.authFailure)
                }
            }
            else {
                displayFailure(Constants.initFailure)
            }
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    private func performLoginRequest(request: NSURLRequest) {
        
        /* create and initiate a data task for the login request */
        let session = NSURLSession.sharedSession()
        let loginTask = session.dataTaskWithRequest(request) {(data: NSData?, response: NSURLResponse?, error: NSError?) in
            
            /* check for errors */
            if error != nil {
                self.displayFailure(Constants.authFailure)
                return
            }
            
            /* check for an HTTP response */
            if let httpResponse = response as? NSHTTPURLResponse, responseData = data {
                if httpResponse.statusCode == 200 {
                    
                    /* if we get a successful response then extract the shape name from the response body and perform the login segue */
                    let shapeName = NSString(data: responseData, encoding: NSASCIIStringEncoding)
                    self.performSegueWithIdentifier(Constants.loginSegueIdentifier, sender: shapeName)
                }
                else {
                    
                    /* if we have failed attestation then our server will reject us based on an invalid Approov token */
                    self.displayFailure(Constants.authFailure)
                }
            }
            else {
                self.displayFailure(Constants.authFailure)
            }
        }
        loginTask.resume()
    }
    
    private func displayFailure(reason: String) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityIndicatorView.stopAnimating()
            self.statusLabel.text = reason
            self.loginButton.enabled = true
            self.isLoggingIn = false
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        /* initialise the shape view controller's shape name so we can display appropriate text and image */
        if let navController = segue.destinationViewController as? UINavigationController, shapeName = sender as? String {
            if let shapeViewController = navController.viewControllers.first as? ShapeViewController {
                shapeViewController.shapeName = shapeName
            }
        }
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
        /* unwinding will trigger viewWillAppear() and reset this view controller */
    }
}
