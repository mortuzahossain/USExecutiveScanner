//
//  DetailsViewController.swift
//  USExecutiveScanner
//
//  Created by Mortuza Hossain on 10/12/22.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var pdLabel: UILabel!
    @IBOutlet weak var containerCard: UIView!
    @IBOutlet weak var bayLabel: UILabel!
    
    static var data:DataClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCardView(containerCard)
        pdLabel.text = DetailsViewController.data?.pd
        var bays:String = DetailsViewController.data?.bay ?? ""
        bays = bays.replacingOccurrences(of: ".|.", with: "")
        bayLabel.text = bays
    }
    
    
    func makeCardView(_ cardView:UIView){
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shadowOpacity = 0.7
    }
    
}
