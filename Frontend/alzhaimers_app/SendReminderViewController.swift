//
//  SendReminderViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/9/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class SendReminderViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var timePick: UIDatePicker!
    @IBOutlet weak var photoImageView: UIImageView!
  
    var newPic: Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
     //   if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.photoImageView.image = image
            
            if newPic == true {
                UIImageWriteToSavedPhotosAlbum(image,self, #selector(imageError), nil )
            }
       // }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageError(_ image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save Failed", message: "Failed to save image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func doneBtn(_ sender: Any) {
        let userDefaults = UserDefaults.standard;
        let patPhone = userDefaults.object(forKey: "patientNumber") as! String;
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YYYY hh:mm"
        let strDate = dateFormatter.string(from: timePick.date)
        let title = titleField.text as! String;
        let description = descriptionField.text as! String;
        sendReminder(phone: patPhone, date: strDate, title: title, description: description, image: "photoImageView.image!")
        print("done")
    }
    
    func sendReminder(phone:String, date:String, title : String, description:String, image: String){
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "17873c6d-360e-7b01-2f95-413491c34c92"
        ]
        let parameters = [
            "phone": phone,
            "picture": image,
            "title": title,
            "description":
            description,
            "timeZone": "EST",
            "time": date
            ] as [String : Any]

        print("parameters")
        print(parameters)
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://54.175.126.168:3000/reminders")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                print("reminder sent response")
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                DispatchQueue.main.async { [weak self] in
                    self?.performSegue(withIdentifier: "doneSendReminder", sender: Any?.self)
                }
            }
        })
        
        dataTask.resume()
        
    }
    
}
