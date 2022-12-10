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
        self.showManualInputDialog()
    }
    
    
    func showManualInputDialog(){
        let alert = UIAlertController(title: "Manual Input", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter zip code"
        }
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let text = textField?.text else { return }
            if text.isEmpty {
                return
            }
            self.hideKeyboard()
            self.performApiCall(zipcode: text)
            
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func performApiCall(zipcode:String){
        showHUD()
        let dict:[String:String] = ["zipcode": zipcode, "sorttype": getSortType()]
        ApiService.callPost(url: URL(string: "https://upsexecutivescanner.app/api/check.php")!, params: dict) { (message: String, data: Data?) in
            DispatchQueue.main.async {
                self.hideHUD()
            }
            
            do{
                let decodedData = try JSONDecoder().decode(CheckResponse.self, from: data ?? Data())
                if decodedData.code == "1000" {
                    // success
                    print("Success")
                } else {
                    // failed
                    print("Failed")
                }
            }catch let error{
                print(error)
                // failed
            }
        }
    }
    
    func getSortType() -> String {
        let st = sortSegmentedControl.selectedSegmentIndex
        if st == 0 {
            return "1"
        } else {
            return "2"
        }
    }
    
}

let hudView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
extension UIViewController {
    func showHUD() {
        hudView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
        hudView.backgroundColor = UIColor.darkGray
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        indicatorView.center = CGPoint(x: hudView.frame.size.width/2, y: hudView.frame.size.height/2)
        indicatorView.style = UIActivityIndicatorView.Style.white
        indicatorView.color = UIColor.white
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() {
        hudView.removeFromSuperview()
    }

}

extension UIViewController {
    func hideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


