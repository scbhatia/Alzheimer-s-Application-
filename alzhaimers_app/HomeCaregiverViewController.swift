//
//  HomeCaregiverViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 3/28/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import Foundation

struct UserInfo: Codable {
    let care_name: String
    let care_phone: String
    let pat_phone: String
}

class HomeCaregiverViewController: UIViewController {
    
    var userInfo: UserInfo?
    
    @IBOutlet weak var caregiverNameField: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo();
        //userDefaults.set("6177757350",forKey: "patientNumber")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func trackBtn(_ sender: Any) {
    }
    @IBAction func remindersBtn(_ sender: Any) {
    }
    @IBAction func memoriesBtn(_ sender: Any) {
    }
    @IBAction func copingBtn(_ sender: Any) {
    }
    @IBAction func cognitiveBtn(_ sender: Any) {
    }
    @IBAction func emergencyBtn(_ sender: Any) {
        let userDefaults = UserDefaults.standard;
        let patientPhoneVal = userDefaults.object(forKey: "patientNumber") as! String;
        let url:NSURL = NSURL(string: "tel://\(patientPhoneVal)")!
        print("tel://\(patientPhoneVal)");
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url as URL , options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url as URL)
        }
    }
    @IBAction func logoutBtn(_ sender: Any) {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "caregiverLogout", sender: Any?.self)
    }
    
    func loadInfo(){
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "f0611d0a-d405-b432-83eb-1619c0f5475e"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/care/67890")! as URL,
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
                            if let nestedArray = JSON["message"] as? NSArray {
                                
                                print("nested \(nestedArray)")
                                //getting nested temp from payload
                                let newDoc = nestedArray[0] as? [String:Any]
                                
                                print("nested \(newDoc)")
                                // access nested dictionary values by key
                                
                                let name = newDoc?["care_name"] as! String
                                let phone = newDoc?["care_phone"] as! String
                                let patPhone = newDoc?["pat_phone"] as! String
                                
                                DispatchQueue.main.async { [weak self] in
                                    let userDefaults = UserDefaults.standard;
                                    userDefaults.set(name,forKey: "caregiverName")
                                    userDefaults.set(phone,forKey: "caregiverNumber")
                                    userDefaults.set(patPhone,forKey: "patientNumber")
                                    self?.caregiverNameField.text = name as String;
                                }

                            
                        }
                    }
                  /* let userInfoData = try JSONDecoder().decode(UserInfo.self, from: data)
                    DispatchQueue.main.async {
                        print(userInfoData)
                        self.userInfo = userInfoData
                    }*/
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
