//
//  NavigationController.swift
//  Glenna
//
//  Created by dennis on 11/10/16.
//  Copyright © 2016 Dennis Xu, Vanessa Wu, William Yang. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var username = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.popViewController(animated: true)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
