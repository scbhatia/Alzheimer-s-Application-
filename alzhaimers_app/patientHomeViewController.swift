//
//  PatientHomeViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 3/26/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit

class PatientHomeViewController: UIViewController {

    @IBOutlet weak var patientNameField: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }
    @IBAction func logoutButton(_ sender: Any) {
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
