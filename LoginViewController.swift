//
//  LoginViewController.swift
//  Glenna
//
//  Created by dennis on 12/6/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

struct MyVariables {
    static var username = ""
}

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.addTarget(self, action: #selector(LoginViewController.submit), for: .touchDown)
        self.hideKeyboardWhenTappedAround()
        usernameField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func submit() {
        if (usernameField.text!.isEmpty || passwordField.text!.isEmpty) {
            let alert = UIAlertController(title: "Error", message: "No username or password specified", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            sendHTTPRequest()
        }
    }
    
    func sendHTTPRequest(){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/login?username=" + String(describing: self.usernameField.text!) + "&password=" + String(describing: self.passwordField.text!))!
            let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
            urlRequest.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: urlRequest as URLRequest) {
                (data, response, error) -> Void in

            
            DispatchQueue.main.async {
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if (statusCode == 516) {
                    let alert = UIAlertController(title: "Error", message: "Incorrect username/password", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if (statusCode == 200) {
                    //                self.performSegue(withIdentifier: "loginMap", sender: self)
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    MyVariables.username = self.usernameField.text!
                    self.present(next, animated: true, completion: nil)
                }
            }
            }
            task.resume()
        }
    }
}
