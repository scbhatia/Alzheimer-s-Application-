//
//  MemoriesViewController.swift
//  alzhaimers_app
//
//  Created by Dana Szapiro on 4/30/18.
//  Copyright © 2018 Dana Szapiro. All rights reserved.
//

import UIKit
import Foundation

struct Memories{
    var title: String
    var desc: String
    //var image: String
    
    init(title: String, desc: String){
        self.title = title
        self.desc = desc
        //self.image = image
    }
}

class MemoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var memoriesTable: UITableView!
    
    var memoriesArray : [Memories] = [];
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard;
        let phone = userDefaults.object(forKey: "Phone") as! String;
        getMemories(phone: phone)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoriesArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = memoriesArray[indexPath.row].title
        cell.detailTextLabel?.text = memoriesArray[indexPath.row].desc
        return cell
    }
    //get memories from backend and populate tableView
    func getMemories(phone : String){
        
        let headers = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "a608eec8-5d59-eb38-9b79-1cd9cedf0236"
        ]
        let urlStr = "http://54.175.126.168:3000/memories/" + phone
        let request = NSMutableURLRequest(url: NSURL(string: urlStr)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
                guard let data = data else { return }
                do{
                    print(data)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let memories = json["message"] as? [[String: Any]]{
                        print(json)
                        for memory in memories{
                            if let titleVar = (memory["title"] as? String),
                                let descVar = (memory["message"] as? String){
                                DispatchQueue.main.async { [weak self] in
                                    self?.memoriesArray.append(Memories.init(title: titleVar, desc: descVar))
                                }
                                print(titleVar)
                                print(descVar)
                            }
                        }
                        DispatchQueue.main.async { [weak self] in
                            self?.memoriesTable.reloadData()
                        }
                    
                    }
                } catch let jsonError {
                    print(jsonError)
                }
            }
        })
        
        dataTask.resume()
    }


}
