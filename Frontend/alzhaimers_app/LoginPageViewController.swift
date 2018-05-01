//
//  LoginPageViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 3/18/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true 
        self.title = "Login"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "loginToRegister", sender: (Any).self )
    }
    
    @IBAction func loginBtn(_ sender: Any) {
     let password = passwordField.text;
     let patPhone = phoneField.text;
        if((password?.isEmpty)! || (patPhone?.isEmpty)!){
            displayAlert(userMessage: "Unable to login: All Fields Required");
        }
            
        else {
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache",
                "Postman-Token": "c79cd303-8785-6c87-1598-2a5e916741f1"
            ]
            
            let getUrl = "http://54.175.126.168:3000/users/pat/" + patPhone! + "&" + password!
            
            let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL, cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                //print(data!)
                if (error != nil) {
                    print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse as Any)
                    if (httpResponse?.statusCode == 200){
                        DispatchQueue.main.async { [weak self] in
                            let userDefaults = UserDefaults.standard;
                            userDefaults.set(1,forKey: "sessionType")
                            userDefaults.set(true,forKey: "logged")
                            userDefaults.set(self?.phoneField.text,forKey: "Phone")
                            userDefaults.synchronize()
                            self?.performSegue(withIdentifier: "loginToPatient", sender: (Any).self )
                        }
                    }
                    else if (httpResponse?.statusCode == 300){
                        DispatchQueue.main.async{
                            self.displayAlert(userMessage: "Invalid User Info. Please try again");
                        }
                    }
                    else if (httpResponse?.statusCode == 400){
                        DispatchQueue.main.async {
                            self.displayAlert(userMessage: "There was an error. Please try again");
                        }
                    }
                }
            })
            dataTask.resume()
        }
        
    }
    
    @IBAction func caregiverLoginBtn(_ sender: Any) {
        let password = passwordField.text;
        let phone = phoneField.text;
        
        if((password?.isEmpty)! || (phone?.isEmpty)!){
            displayAlert(userMessage: "Unable to login: All Fields Required");
        }
        else {
            let headers = [
                "Content-Type": "application/json",
                "Cache-Control": "no-cache",
                "Postman-Token": "c79cd303-8785-6c87-1598-2a5e916741f1"
            ]
            let getUrl = "http://54.175.126.168:3000/users/care/" + phone! + "&" + password!
            
            let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL, cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                //print(data!)
                if (error != nil) {
                    print(error!)
                } else {
                    let httpResponse = response as? HTTPURLResponse
                    print(httpResponse as Any)
                    if (httpResponse?.statusCode == 200){
                        DispatchQueue.main.async { [weak self] in
                            let userDefaults = UserDefaults.standard;
                            userDefaults.set(2,forKey: "sessionType")
                            userDefaults.set(true,forKey: "logged")
                            userDefaults.set(self?.phoneField.text,forKey: "Phone")
                            userDefaults.synchronize()
                            self?.performSegue(withIdentifier: "loginToCaregiver", sender: (Any).self )
                        }
                    }
                    else if (httpResponse?.statusCode == 300){
                        DispatchQueue.main.async{
                            self.displayAlert(userMessage: "Invalid User Info. Please try again");
                        }
                    }
                    else if (httpResponse?.statusCode == 400){
                        DispatchQueue.main.async {
                            self.displayAlert(userMessage: "There was an error. Please try again");
                        }
                    }
                }
            })
            dataTask.resume()
        }

    }
    
    //helper function to dispaly alert to user with corresponding message
    func displayAlert(userMessage:String ){
        let myAlert = UIAlertController(title:"ERROR", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated: true, completion: nil);
    }    

}
