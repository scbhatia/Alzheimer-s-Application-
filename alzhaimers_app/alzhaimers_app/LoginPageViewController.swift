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
        self.title = "Login"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginBtn(_ sender: Any) {
    // let password = passwordField.text;
    // let phone = phoneField.text;
        
    }
    @IBAction func caregiverLoginBtn(_ sender: Any) {
    }
    
    //helper function to dispaly alert to user with corresponding message
    func displayAlert(userMessage:String ){
        let myAlert = UIAlertController(title:"ERROR", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated: true, completion: nil);
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "loginToPatient" {
            let password = passwordField.text;
            let phone = phoneField.text;
            
            
            if((password?.isEmpty)! || (phone?.isEmpty)!){
                displayAlert(userMessage: "Unable to login: All Fields Required");
                return false
            }
            else {
                return true
            }
        }
        else if identifier == "loginToCaregiver" {
            let password = passwordField.text;
            let phone = phoneField.text;
            
            
            if((password?.isEmpty)! || (phone?.isEmpty)!){
                displayAlert(userMessage: "Unable to login: All Fields Required");
                return false
            }
            else {
                return true
            }
            
        }
        // by default, transition
        return true
    }
    
    //Post request - send user data to data base to perform registaration
    func patientLogin(patPhone:String, password:String){
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "c79cd303-8785-6c87-1598-2a5e916741f1"
        ]
        
        let getUrl = "http://localhost:3000/users/pat" + patPhone + "&" + password
        
        let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL, cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })
        
        dataTask.resume()
    }
    
    func caregiverLogin(carePhone:String, password:String){
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "c79cd303-8785-6c87-1598-2a5e916741f1"
        ]
        
        let getUrl = "http://localhost:3000/users/care" + carePhone + "&" + password
        
        let request = NSMutableURLRequest(url: NSURL(string: getUrl)! as URL, cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
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
