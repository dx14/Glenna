//
//  EventsListTableViewController.swift
//  Glenna
//
//  Created by dennis on 11/10/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

class EventsListTableViewController: UITableViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet var EventsList: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var posts = [[String]]()
    var postIDs = [Int]()
    var parameters = [AnyObject]()
    var mode = Int()
    
    override func loadView() {
        super.loadView()
        if mode == 0 {
            let location = parameters[0] as! String
            getData() { (result) -> Void in
                self.posts = result
                self.EventsList.reloadData()
            }
            titleLabel.title = location
        } else if mode == 1{
            titleLabel.title = MyVariables.username
            logoutButton.setTitle("Log Out", for: .normal)
            getData() { (result) -> Void in
                self.posts = result
                self.EventsList.reloadData()
            }
        } else if mode == 2 {
            let tag = parameters[0] as! String
            titleLabel.title = tag
            getData() { (result) -> Void in
                self.posts = result
                self.EventsList.reloadData()
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoutButton.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround() 
    }
    
    func buttonTapped(sender : UIButton) {
        if mode == 1 {
            self.performSegue(withIdentifier: "logoutToMainPage", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! TableViewCell
        
        cell.titleLabel.text = posts[indexPath.row][0]
        cell.bodyLabel.text = posts[indexPath.row][1]
        let str = posts[indexPath.row][2]
        let str2 = posts[indexPath.row][3]
        cell.dateLabel.text = str.substring(to: str.index(str.startIndex, offsetBy: 15)) + ",  " + str.substring(from: str.index(str.startIndex, offsetBy: 15)) + " - " + str2.substring(from: str2.index(str2.startIndex, offsetBy: 15))
        if mode != 1 {
            cell.posterLabel.text = posts[indexPath.row][4]
        }
        if posts[indexPath.row][5] != "" {
            cell.tag1.text = "#"+posts[indexPath.row][5]
        }
        if posts[indexPath.row][6] != "" {
            cell.tag1.text = "#"+posts[indexPath.row][6]
        }
        if posts[indexPath.row][7] != "" {
            cell.tag1.text = "#"+posts[indexPath.row][7]
        }
        if mode != 0 {
            cell.locationLabel.text = posts[indexPath.row][8]
        } 
        cell.reportButton.tag = indexPath.row;
        cell.reportButton.addTarget(self, action: #selector(EventsListTableViewController.reportDuplicate), for: UIControlEvents.touchUpInside)
        if mode == 1 {
            cell.reportButton.setTitle("Delete", for: .normal)
        }
        return cell
    }
    
    func reportDuplicate(sender: UIButton!) {
        sendHTTPRequest(id: postIDs[sender.tag])
    }
    
    func sendHTTPRequest(id: Int) {
        var requestURL: NSURL = NSURL(string: "")!
        if mode != 1 {
            requestURL = NSURL(string: "https://cs316-glenna.herokuapp.com/report")!
        } else {
            requestURL = NSURL(string: "https://cs316-glenna.herokuapp.com/delete")!
        }
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "POST"
        let postString = "post_id=\(id)"
        urlRequest.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if statusCode == 516 {
                let alert = UIAlertController(title: "Error", message: "An error occured. Post was not reported successfully.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    func getData(withCompletionHandler:@escaping (_ result:[[String]]) -> Void){
        
        var postData = [[String]]()
        var requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/")!
        
        if mode == 0 {
            let location = parameters[0] as! String
            let param = location.replacingOccurrences(of: " ", with: "+")
            requestURL = NSURL(string: "https://cs316-glenna.herokuapp.com/posts?location=" + param)!
        } else if mode == 1 {
            requestURL = NSURL(string: "https://cs316-glenna.herokuapp.com/posts/username?username=" + MyVariables.username)!
        } else if mode == 2 {
            let tag = parameters[0] as! String
            var param = tag.replacingOccurrences(of: " ", with: "+")
            if tag == "all" {
                param = ""
            }
            requestURL = NSURL(string: "https://cs316-glenna.herokuapp.com/posts/tags?tag=" + param)!
        }

        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
               // print("Everything is fine, file downloaded successfully.")
                
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [[String:AnyObject]]
                    for postInfo in json! {
                        
                        var post = [String]()
                        if let id = postInfo["id"] as? Int {
                            self.postIDs.append(id)
                        }
                        if let title = postInfo["title"] as? String {
                            post.append(title)
                        }
                        if let body = postInfo["body"] as? String {
                            post.append(body)
                        }
                        if let startTime = postInfo["start_time"] as? String {
                            post.append(startTime)
                        }
                        if let endTime = postInfo["end_time"] as? String {
                            post.append(endTime)
                        }
                        if let poster = postInfo["poster"] as? String {
                            post.append(poster)
                        }
                        if let tag1 = postInfo["tag_1"] as? String {
                                post.append(tag1)
                        }
                        if let tag2 = postInfo["tag_2"] as? String {
                                post.append(tag2)
                        }
                        if let tag3 = postInfo["tag_3"] as? String {
                                post.append(tag3)                            
                        }
                        if let location = postInfo["location"] as? String {
                            post.append(location)
                        }
                        postData.append(post)
                    }
                    withCompletionHandler(postData)
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }

}
