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

    fileprivate struct Constants {
        fileprivate static let loginSegueIdentifier = "LoginSegue"
        fileprivate static let defaultStatusLabelText = "Press Login to access your account"
        fileprivate static let initFailure = "Initialisation failure"
        fileprivate static let authFailure = "Authorisation failure"
        fileprivate static let serverURLPath = "http://192.168.0.148:5000/"
        fileprivate static let approovTokenHeader = "ApproovToken"
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        /* update the view controller state */
        self.statusLabel.text = Constants.defaultStatusLabelText
        self.activityIndicatorView.stopAnimating()
        self.loginButton.isEnabled = true
        
        /* pre-fetch Approov token just before the view appears so it's ready before the user logs in */
        if let attestee = ApproovAttestee.shared() {
            attestee.fetchApproovToken({ (result: ApproovTokenFetchResult, approovToken: String) in
                self.handleApproovTokenUpdate(result, approovToken: approovToken)
            })
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        /* unregister ourselves as an observer to Approov token fetch notifications */
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func handleLoginButtonTapped(_ sender: UIButton) {
        
        /* update the view controller state */
        self.loginButton.isEnabled = false
        self.activityIndicatorView.startAnimating()
        self.isLoggingIn = true
        
        /* ensure we have an up-to-date Approov token for the log in operation */
        if let attestee = ApproovAttestee.shared() {
            attestee.fetchApproovToken({ (result: ApproovTokenFetchResult, approovToken: String) in
                self.handleApproovTokenUpdate(result, approovToken: approovToken)
            })
        }
        else {
            displayFailure(Constants.initFailure)
        }
    }
    
    func handleApproovTokenUpdate(_ result: ApproovTokenFetchResult, approovToken: String) {
        
        /* check to see if we are in the process of logging in - if not, we don't need to do anything further */
        if !self.isLoggingIn {
            return
        }
        
        switch result {
            case .successful:
                /* if successful, we construct and perform the login request with the Approov token for our server to retrieve a random shape name */
                let request = NSMutableURLRequest(url: URL(string: Constants.serverURLPath)!)
                request.addValue(approovToken, forHTTPHeaderField: Constants.approovTokenHeader)
                performLoginRequest(request as URLRequest)
            case .failed:
                /* if failed, we display an authorisation error message to the user */
                displayFailure(Constants.authFailure)
        }
    }
    
    fileprivate func performLoginRequest(_ request: URLRequest) {
        
        /* create and initiate a data task for the login request */
        let session = URLSession.shared
        let loginTask = session.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: NSError?) in
            
            /* check for errors */
            if error != nil {
                self.displayFailure(Constants.authFailure)
                return
            }
            
            /* check for an HTTP response */
            if let httpResponse = response as? HTTPURLResponse, let responseData = data {
                if httpResponse.statusCode == 200 {
                    
                    /* if we get a successful response then extract the shape name from the response body and perform the login segue */
                    let shapeName = NSString(data: responseData, encoding: String.Encoding.ascii.rawValue)
                    self.performSegue(withIdentifier: Constants.loginSegueIdentifier, sender: shapeName)
                }
                else {
                    
                    /* if we have failed attestation then our server will reject us based on an invalid Approov token */
                    self.displayFailure(Constants.authFailure)
                }
            }
            else {
                self.displayFailure(Constants.authFailure)
            }
        } as! (Data?, URLResponse?, Error?) -> Void) 
        loginTask.resume()
    }
    
    fileprivate func displayFailure(_ reason: String) {
        
        DispatchQueue.main.async(execute: {
            self.activityIndicatorView.stopAnimating()
            self.statusLabel.text = reason
            self.loginButton.isEnabled = true
            self.isLoggingIn = false
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        /* initialise the shape view controller's shape name so we can display appropriate text and image */
        if let navController = segue.destination as? UINavigationController, let shapeName = sender as? String {
            if let shapeViewController = navController.viewControllers.first as? ShapeViewController {
                shapeViewController.shapeName = shapeName
            }
        }
    }
    
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        
        /* unwinding will trigger viewWillAppear() and reset this view controller */
    }
}
