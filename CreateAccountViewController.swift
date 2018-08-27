//
//  CreateAccountViewController.swift
//  Glenna
//
//  Created by dennis on 12/6/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.addTarget(self, action: #selector(CreateAccountViewController.submit), for: .touchDown)
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
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
        } else if (passwordField.text!.characters.count < 8){
            let alert = UIAlertController(title: "Error", message: "Password must be 8+ characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            sendHTTPRequest()
        }
    }
    
    func sendHTTPRequest() {
        let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/new_user")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "POST"
        let postString = "username=\(String(describing: usernameField.text!))&password=\(String(describing: passwordField.text!))"
        urlRequest.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode == 516 {
                let alert = UIAlertController(title: "Error", message: "Account with this username already exists", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if statusCode == 200 {
                DispatchQueue.main.async {
                    MyVariables.username = self.usernameField.text!
                    self.performSegue(withIdentifier: "CreateAccountToMap", sender: self)
                }
            }
        }
        task.resume()
    }
}
