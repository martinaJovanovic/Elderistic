//
//  OrganiserTableViewController.swift
//  Workshop
//
//  Created by Martina on 2/18/22.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

class OrganiserTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var allRequests = [Dictionary<String, AnyObject>()]
    var Users = [Dictionary<String, AnyObject>()]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        allRequests.remove(at: 0)
        view.backgroundColor = .systemBackground
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        fetchData()
    }
    
    @objc func refresh(sender: AnyObject) {
        fetchData()
    }
    
    func fetchData() {
        if tableView.refreshControl?.isRefreshing == true {
            print("Refreshing data")
        }
        else {
            print("Fetching data")
        }
        
        allRequests.removeAll()
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                self.Users.append(RequestDictionary)
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childAdded) { (snapshot) in
            if var RequestDictionary = snapshot.value as? [String: AnyObject] {
                if let status = RequestDictionary["status"] as? String {
                    if status == "Active request" {
                        RequestDictionary["key"] = snapshot.key as AnyObject
                        self.allRequests.append(RequestDictionary)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childRemoved) { (snapshot) in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                if let email = RequestDictionary["email"] as? String {
                    for index in 0..<self.allRequests.count {
                        self.allRequests.remove(at: index)
                        self.tableView.reloadData()
                        break;
                    }
                }
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childChanged) { (snapshot) in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                if let key = snapshot.key as? String {
                    for index in 0..<self.allRequests.count {
                        if let keyreq = self.allRequests[index]["key"] as? String {
                            if key == keyreq {
                                self.allRequests[index] = RequestDictionary
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }

        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRequests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "organiserCell", for: indexPath)
        let RequestDictionary = allRequests[indexPath.row]
        if let activityName = RequestDictionary["activity_name"] as? String {
            cell.textLabel?.text = activityName
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let request = allRequests[indexPath.row]
        performSegue(withIdentifier: "activityDetailsSegue", sender: request)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ActivityDetailsViewController,
            let request = sender as? Dictionary<String, AnyObject>,
            let activityName = request["activity_name"] as? String,
            let activityDescription = request["description"] as? String,
            let date = request["date"] as? String,
            let from = request["from"] as? String,
            let to = request["to"] as? String,
            let latitude = request["latitude"] as? Double,
            let longitude = request["longitude"] as? Double,
            let eEmail = request["elder_email"] as? String,
            let status = request["status"] as? String,
            let key = request["key"] as? String else {
                return
        }
        vc.name = activityName
        vc.details = activityDescription
        vc.date = date
        vc.latitude = latitude
        vc.longitude = longitude
        vc.to = to
        vc.from = from
        vc.eEmail = eEmail
        vc.status = status
        vc.key = key
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
