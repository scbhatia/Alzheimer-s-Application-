//
//  PatientHomeViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 3/26/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import Foundation

class PatientHomeViewController: UIViewController {

    @IBOutlet weak var patientNameField: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let userDefaults = UserDefaults.standard;
        //let carePhoneVal = userDefaults.object(forKey: "Phone") as! String;
        //patientNameField.text = carePhoneVal;
        loadInfo()
        //userDefaults.set("6177757350",forKey: "caregiverNumber")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeButton(_ sender: Any) {
    }
    
    @IBAction func reminderButton(_ sender: Any) {
    }
    
    
    @IBAction func memoriesButton(_ sender: Any) {
    }
    
    @IBAction func gamesButton(_ sender: Any) {
    }
    @IBAction func emergencyButton(_ sender: Any) {
        let userDefaults = UserDefaults.standard;
        let caregiverPhoneVal = userDefaults.object(forKey: "caregiverNumber") as! String;
        let url:NSURL = NSURL(string: "tel://\(caregiverPhoneVal)")!
        print("tel://\(caregiverPhoneVal)");
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL , options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
        
    }
    @IBAction func logoutButton(_ sender: Any) {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "patientLogout", sender: (Any).self )
    }
    
    func loadInfo(){
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "7af25023-25b3-4989-1cf1-99d8a2e2b293"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/pat/67890")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                guard let data = data else { return }
                do{
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let JSON = json as? [String: Any]{
                        print(JSON)
                        if let nestedArray = JSON["message"] as? NSArray {
                            
                            print("nested \(nestedArray)")
                            //getting nested temp from payload
                            let newDoc = nestedArray[0] as? [String:Any]
                            
                            print("nested \(newDoc)")
                            // access nested dictionary values by key
                            
                            let name = newDoc?["pat_name"] as! String
                            let phone = newDoc?["pat_phone"] as! String
                            let carePhone = newDoc?["care_phone"] as! String
                            let homeAddress = newDoc?["address"] as! String
                            
                            DispatchQueue.main.async { [weak self] in
                                let userDefaults = UserDefaults.standard;
                                userDefaults.set(name,forKey: "patientName")
                                userDefaults.set(phone,forKey: "patientNumber")
                                userDefaults.set(carePhone,forKey: "caregiverNumber")
                                self?.patientNameField.text = name as String;
                            }
  
                        }
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }
        })
        
        dataTask.resume()
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
