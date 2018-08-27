//
//  ViewController.swift
//  Glenna
//
//  Created by dennis on 11/9/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit
import GoogleMaps

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController, GMSMapViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var addEventButton: UIBarButtonItem!
    var locations = [[String]]()
    var locationNames = [String]()
    
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.

        
        let camera = GMSCameraPosition.camera(withLatitude: 36.001636, longitude: -78.9387, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view = mapView
        
        getData() { (result) -> Void in
            self.locations = result
            for location in self.locations {
                self.locationNames.append(location[0])
            }
            DispatchQueue.main.sync {
                // Creates markers
                for location in self.locations {
                    self.createMarker(latitude: Double(location[1])!, longitude: Double(location[2])!, title: location[0], mapView: mapView)
                }
            }
        }
        

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createMarker(latitude: Double, longitude: Double, title: String, mapView: GMSMapView) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        marker.title = title
        marker.map = mapView
    }
    
    func mapView(_ didTapmapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) -> Bool {
        // add code to display popup list of events
        var location = marker.title
        var parameter = [AnyObject]()
        parameter.append(location as AnyObject)
        self.performSegue(withIdentifier: "toEventPage", sender: parameter)
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toEventPage") {
            let secondViewController = segue.destination as! EventsListTableViewController
//            let location = sender as! String
            let parameter = sender as! [AnyObject]
            secondViewController.mode = 0
            secondViewController.parameters = parameter
        }
        if (segue.identifier == "toAddEvent"){
            let secondViewController = segue.destination as! AddEventViewController
            secondViewController.locationsArr = locationNames
        }
        if (segue.identifier == "toUserEventPage"){
            let secondViewController = segue.destination as! EventsListTableViewController
            secondViewController.mode = 1
        }
    }
    
    func getData(withCompletionHandler:@escaping (_ result:[[String]]) -> Void){
        
        var listofLocations = [[String]]()
        
        let requestURL: NSURL = NSURL(string: "https://cs316-glenna.herokuapp.com/locations")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                //print("Everything is fine, file downloaded successfully.")
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [[String:AnyObject]]
                    for postInfo in json {
                        var location = [String]()
                        if let name = postInfo["name"] {
                            location.append(name as! String)
                        }
                        if let x = postInfo["x"] {
                            let xString = String(describing: x)
                            location.append(xString)
                        }
                        if let y = postInfo["y"] {
                            let yString = String(describing: y)
                            location.append(yString)
                        }
                        listofLocations.append(location)
                    }
                    withCompletionHandler(listofLocations)
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }

    }
