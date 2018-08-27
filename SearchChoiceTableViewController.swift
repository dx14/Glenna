//
//  SearchChoiceTableViewController.swift
//  Glenna
//
//  Created by dennis on 12/10/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

class SearchChoiceTableViewController: UITableViewController {
    
    var tags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        getData() { (result) -> Void in
            self.tags = result
//            self.collectionView.reloadData()
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func getData(withCompletionHandler:@escaping (_ result:[String]) -> Void){
        
        let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/tags")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            var tagArr = [String]()
            tagArr.append("all")
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                //print("Everything is fine, file downloaded successfully.")
                do{
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [[String:AnyObject]]
                    for postInfo in json! {
                        if let title = postInfo["title"] as? String {
                            tagArr.append(title)
                        }
                    }
                    
                    withCompletionHandler(tagArr)
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagViewCell", for: indexPath) as! TagViewCell
        cell.tagLabel.text = tags[indexPath.row]
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        var parameter = [AnyObject]()
        parameter.append(tag as AnyObject)
        self.performSegue(withIdentifier: "toTagEventPage", sender: parameter)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toTagEventPage") {
            let secondViewController = segue.destination as! EventsListTableViewController
            let parameter = sender as! [AnyObject]
            secondViewController.mode = 2
            secondViewController.parameters = parameter
        }
    }

}
