//
//  RegisterPageViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 3/18/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import Foundation

class RegisterPageViewController: UIViewController {

    
    @IBOutlet weak var patientNameField: UITextField!
    @IBOutlet weak var patientPhoneField: UITextField!

    @IBOutlet weak var caregiverNameField: UITextField!
    @IBOutlet weak var caregiverPhoneField: UITextField!
    @IBOutlet weak var homeField: UITextField!
    @IBOutlet weak var passwordField: UITextField!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func registerBtn(_ sender: AnyObject) {
        let patientName = patientNameField.text;
        let patientPhone = patientPhoneField.text;
        let caregiverName = caregiverNameField.text;
        let caregiverPhone = caregiverPhoneField.text;
        let home = homeField.text;
        let password = passwordField.text;
        
        if ((patientName?.isEmpty)! || (patientPhone?.isEmpty)! || (caregiverName?.isEmpty)! || (caregiverPhone?.isEmpty)! || (home?.isEmpty)! || (password?.isEmpty)! ){
            
            //display error message
            displayAlert(userMessage: "All fields are required");
            return;
        }
        
        //send data to database
        registerUser(patPhone:patientPhone!, patName:patientName!, carePhone:caregiverPhone!, careName:caregiverName!, password:password!, address:home!);
        
        //show success
        let myAlert = UIAlertController(title:"SUCCESS", message:"You Have Been Registrated", preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default){ action in
            self.dismiss(animated: true, completion:nil);
        }
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
        
    }
    
    
    @IBAction func alreadyRegisteredBtn(_ sender: Any) {
        self.performSegue(withIdentifier: "alreadyRegistered", sender: (Any).self )
    }
    
    //helper function to dispaly alert to user with corresponding message
    func displayAlert(userMessage:String ){
        let myAlert = UIAlertController(title:"ERROR", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title:"OK", style:UIAlertActionStyle.default, handler:nil);
        myAlert.addAction(okAction);
        
        self.present(myAlert, animated: true, completion: nil);
    }
    
    //Post request - send user data to data base to perform registaration
    func registerUser(patPhone:String, patName:String, carePhone:String, careName:String, password:String, address:String){
        
       let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "f5bd6b03-1214-c1fe-67eb-6920f7bc59d2"
        ]
        let parameters = [
            "pat_phone": patPhone,
            "pat_name": patName,
            "care_phone": carePhone,
            "care_name": careName,
            "password": password,
            "address": address
            ] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/users/")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
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
