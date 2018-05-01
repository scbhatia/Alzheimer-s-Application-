//
//  SendMemoryViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/11/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class SendMemoryViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    var newPic: Bool?
    var imageStr : String?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func doneButton(_ sender: Any) {
        print("done")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY hh:mm"
        let strDate = dateFormatter.string(from: datePicker.date)
        print(strDate)
        let title = titleField.text;
        let description = descriptionField.text
        let userDefaults = UserDefaults.standard;
        let patPhone = userDefaults.object(forKey: "patientNumber") as! String;
        sendMemory(phone: patPhone, picture: "imageStr!", date: strDate, title: title!, description: description!)
    }
    
    //send memory info to database
    func sendMemory(phone: String, picture: String, date: String, title:String, description:String){
        print("post request")
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            //"Postman-Token": "13e78322-2e34-3369-9a8c-30f006c53454"
            "Postman-Token":"17873c6d-360e-7b01-2f95-413491c34c92"
        ]
        let parameters = [
            "phone": phone,
            "picture": picture,
            "message": description,
            "title":title,
            "timeZone": "EST",
            "time": date
            ] as [String : Any]

        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/memories")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        print("sending memories------")
        print(postData)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                DispatchQueue.main.async {
                    print("sending memories before segue------")
                    print(postData)
                    self.performSegue(withIdentifier: "sendMemory", sender: Any?.self)
                }
            }
        })
        
        dataTask.resume()
    }

    //MARK: Actions
    
    @IBAction func addImage(_ sender: Any) {
        let myAlert = UIAlertController(title: "Select Image From", message: "", preferredStyle: .actionSheet)
        let camaraAction = UIAlertAction(title: "Camara", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = true
            }
        }
        
        let camaraRollAction = UIAlertAction(title: "Camara Roll", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = false
            }
        }
        myAlert.addAction(camaraAction)
        myAlert.addAction(camaraRollAction)
        self.present(myAlert, animated: true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info [UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.photoImageView.image = image
            
            if newPic == true {
                UIImageWriteToSavedPhotosAlbum(image,self, #selector(imageError), nil )
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageError(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    

}
