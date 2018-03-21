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
        let password = passwordField.text;
        let phone = phoneField.text;
        
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
        // by default, transition
        return true
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
