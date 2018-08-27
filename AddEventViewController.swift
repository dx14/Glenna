//
//  AddEventViewController.swift
//  Glenna
//
//  Created by dennis on 11/10/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descField: UITextField!
    @IBOutlet weak var addEventView: UIScrollView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var tagsArr = [String]()
    var tagsSelected = [String]()
    var locationsArr = [String]()
    
    override func loadView() {
        super.loadView()
        getData() { (result) -> Void in
            self.tagsArr = result
            self.collectionView.reloadData()
        }
        submitButton.addTarget(self, action: #selector(CreateAccountViewController.submit), for: .touchDown)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.locationPicker.delegate = self
        self.locationPicker.dataSource = self
        self.hideKeyboardWhenTappedAround()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.collectionView.allowsMultipleSelection = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if Int((collectionView.indexPathsForSelectedItems?.count)!) > 2 {
            let alert = UIAlertController(title: "Error", message: "Cannot select more than 3 tags", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tagsSelected.append(self.tagsArr[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let s = self.tagsArr[indexPath.row]
        if let i = tagsSelected.index(where: { $0 == s }) {
                tagsSelected.remove(at: i)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath as IndexPath) as! CollectionViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red:0.26, green:0.71, blue:0.90, alpha:1.0)
        cell.selectedBackgroundView = backgroundView
        
        cell.tagLabel.text = self.tagsArr[indexPath.item]
        cell.backgroundColor = UIColor(red:0.26, green:0.71, blue:0.90, alpha:0.1)
        cell.layer.cornerRadius = 8
        
        return cell
    }

    // The number of columns of data
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return locationsArr.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return locationsArr[row]
    }
    
    func getData(withCompletionHandler:@escaping (_ result:[String]) -> Void){
        
        var tags = [String]()
        
        let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/tags")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [[String:AnyObject]]
                    for postInfo in json! {
                        if let title = postInfo["title"] as? String {
                            tags.append(title)
                        }
                    }
                    withCompletionHandler(tags)
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    
    
    func submit() {
        if (titleField.text!.isEmpty){
            let alert = UIAlertController(title: "Error", message: "No title specified", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (descField.text!.isEmpty){
            let alert = UIAlertController(title: "Error", message: "No description specified", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (startDatePicker.date.timeIntervalSinceNow < 0){
            let alert = UIAlertController(title: "Error", message: "Event begins before current date/time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (endDatePicker.date.timeIntervalSinceNow < 0){
            let alert = UIAlertController(title: "Error", message: "Event ends before current date/time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if (endDatePicker.date.timeIntervalSince(startDatePicker.date) < 0) {
            let alert = UIAlertController(title: "Error", message: "Event ends before specified start date/time", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
          sendHTTPRequest()
        }
    }
    
    
    func sendHTTPRequest() {
        var tag1 = ""
        var tag2 = ""
        var tag3 = ""
        if tagsSelected.count == 3 {
            tag1 = tagsSelected[0]
            tag2 = tagsSelected[1]
            tag3 = tagsSelected[2]
        } else if tagsSelected.count == 2 {
            tag1 = tagsSelected[0]
            tag2 = tagsSelected[1]
        } else if tagsSelected.count == 1{
            tag1 = tagsSelected[0]
        }
        
        let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/new_post")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "POST"
        let postString = "title=\(String(describing: titleField.text!))&description=\(String(describing: descField.text!))&location=\(locationsArr[locationPicker.selectedRow(inComponent: 0)])&start_time=\(startDatePicker.date.description)&end_time=\(endDatePicker.date.description)&username=\(MyVariables.username)&tag1=\(tag1)&tag2=\(tag2)&tag3=\(tag3)"
        urlRequest.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if statusCode == 516 {
                let alert = UIAlertController(title: "Error", message: "Error submitting, try again later", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if statusCode == 200 {
                self.performSegue(withIdentifier: "AddEventSubmitToMap", sender: self)
            }
        }
        task.resume()
    }


}
