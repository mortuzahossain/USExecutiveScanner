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

        
    }
    
    func makeRadiousBackground(_ btn:UIButton){
        btn.layer.cornerRadius = 8
    }
    

    @IBAction func clickOnScan(_ sender: Any) {
        openQRScanner()
    }
    
    @IBAction func clickOnManualInput(_ sender: Any) {
        self.showManualInputDialog()
    }
    
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
            self.hideKeyboard()
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
