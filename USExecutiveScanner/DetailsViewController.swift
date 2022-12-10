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
    override func viewDidLoad() {
        super.viewDidLoad()
        makeCardView(containerCard)
    }
    
    
    func makeCardView(_ cardView:UIView){
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shadowOpacity = 0.7
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
