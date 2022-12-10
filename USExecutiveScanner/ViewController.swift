//
//  ViewController.swift
//  USExecutiveScanner
//
//  Created by Mortuza Hossain on 10/12/22.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var btnManualInput: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var history:[History] = [History]()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton        = true
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        sortSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        sortSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        
        makeRadiousBackground(btnScan)
        makeRadiousBackground(btnManualInput)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        tableView.layer.cornerRadius = 5
    }
    

    @IBAction func clickOnScan(_ sender: Any) {
        openQRScanner()
    }
    
    @IBAction func clickOnManualInput(_ sender: Any) {
        self.showManualInputDialog()
    }
    
    
}

// MARK: FOR SCAN LOG
extension ViewController : UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if history.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let sType:String
        if history[indexPath.row].sorttype == "1" {
            sType = "SortType: Night Sort"
        } else {
            sType = "SortType: Twilight Sort"
        }
        cell.textLabel?.text = sType
        
        let details:String = "PD: \(history[indexPath.row].pd ?? "")"
        cell.detailTextLabel?.text = details
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDeleteDialog(data: history[indexPath.row])
    }
    
    func showDeleteDialog(data:History){
       let ac = UIAlertController(title: "Delete", message: "Do you really want to delete?", preferredStyle: .actionSheet)
       ac.addAction(UIAlertAction(title: "Yes", style: .default,handler: { UIAlertAction in
//           self.deleteData(data: data)
           ac.dismiss(animated: true)
       }))
       ac.addAction(UIAlertAction(title: "No", style: .cancel,handler: { UIAlertAction in
           ac.dismiss(animated: true)
       }))
       self.present(ac, animated: true)
   }
       
}

// MARK: FOR BUISNESS LOGIC
extension ViewController{
    
    func goToDetailsPage(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Details") as! DetailsViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    func openQRScanner(){
        guard checkScanPermissions() else { return }
        readerVC.delegate = self
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            guard let text = result?.value else { return }
            self.performApiCall(zipcode: text)
        }

        readerVC.modalPresentationStyle = .fullScreen
        present(readerVC, animated: true, completion: nil)
    }
    
    func showManualInputDialog(){
        let alert = UIAlertController(title: "Manual Input", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Enter zip code"
//            textField.text = "42010508"
        }
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            guard let text = textField?.text else { return }
            if text.isEmpty {
                return
            }
            
            textField?.resignFirstResponder()
            self.performApiCall(zipcode: text)
            
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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

// MARK: FOR API CALL
extension ViewController{
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
                    DetailsViewController.data = decodedData.data
                    DispatchQueue.main.async {
                        self.goToDetailsPage()
                    }
                } else {
                    DispatchQueue.main.async {
                        Loaf(decodedData.msg, state: .error, location: .bottom, sender: self).show()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    Loaf("No Package found", state: .error, location: .bottom, sender: self).show()
                }
            }
        }
    }
}

// MARK: FOR QR SCANNER
extension ViewController:QRCodeReaderViewControllerDelegate{
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    private func checkScanPermissions() -> Bool {
       do {
         return try QRCodeReader.supportsMetadataObjectTypes()
       } catch let error as NSError {
         let alert: UIAlertController

         switch error.code {
         case -11852:
           alert = UIAlertController(title: "Error", message: "This app is not authorized to use Back Camera.", preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Setting", style: .default, handler: { (_) in
             DispatchQueue.main.async {
               if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                 UIApplication.shared.openURL(settingsURL)
               }
             }
           }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
         default:
           alert = UIAlertController(title: "Error", message: "Reader not supported by the current device", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
         }

         present(alert, animated: true, completion: nil)

         return false
       }
     }
}
