//
//  SegueControlViewController.swift
//  PetDetective
//
//  Created by 고석준 on 2022/04/17.
//

import UIKit

class SegueControlViewController: UIViewController {

    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var protectView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        protectView.alpha = 0
        // Do any additional setup after loading the view.
    }

    @IBAction func switchViews(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            reportView.alpha = 1.0
            protectView.alpha = 0
        } else if sender.selectedSegmentIndex == 1 {
            reportView.alpha = 0
            protectView.alpha = 1.0
        } else {
            
        }
        
    }
}
