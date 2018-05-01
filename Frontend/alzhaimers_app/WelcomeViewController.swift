//
//  WelcomeViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/27/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit


class WelcomeViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard;
    override func viewDidLoad() {
        super.viewDidLoad()
        islogged()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func islogged(){
        self.performSegue(withIdentifier: "login", sender: nil)
       /* if (userDefaults.object(forKey: "logged") != nil){
            let logged = userDefaults.object(forKey: "logged") as! Bool;
            let session = userDefaults.object(forKey: "sessionType") as! Int;
            if(logged){
                if (session == 1){
                    if (userDefaults.object(forKey: "Phone") == nil){
                        userDefaults.set("12345", forKey: "Phone")
                    }
                    self.performSegue(withIdentifier: "loggedPat", sender: nil)
                }
                else if (session == 2){
                    self.performSegue(withIdentifier: "loggedCare", sender: nil)
                }
            }
         self.performSegue(withIdentifier: "login", sender: nil)
        }
        else{
            self.performSegue(withIdentifier: "login", sender: nil)
        }*/
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
