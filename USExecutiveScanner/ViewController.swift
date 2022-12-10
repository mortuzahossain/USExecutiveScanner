//
//  ViewController.swift
//  USExecutiveScanner
//
//  Created by Mortuza Hossain on 10/12/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnManualInput: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sortSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        sortSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        makeRadiousBackground(btnScan)
        makeRadiousBackground(btnManualInput)
        
    }
    
    func makeRadiousBackground(_ btn:UIButton){
        btn.layer.cornerRadius = 8
    }

    @IBAction func clickOnScan(_ sender: Any) {
    }
    
    @IBAction func clickOnManualInput(_ sender: Any) {
    }
    
}

