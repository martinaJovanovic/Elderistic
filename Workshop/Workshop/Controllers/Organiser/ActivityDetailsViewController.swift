//
//  ActivityDetailsViewController.swift
//  Workshop
//
//  Created by Martina on 2/22/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation

class ActivityDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var detailsL: UILabel!
    @IBOutlet weak var dateFromTo: UILabel!
    @IBOutlet weak var elder: UILabel!
    @IBOutlet weak var volunteer: UILabel!
    
    var name = ""
    var details = ""
    var date = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var status = ""
    var from = ""
    var to = ""
    var eEmail = ""
    var key = ""
    
    var freeUsers = [Dictionary<String,Any>()]
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        freeUsers.remove(at: 0)
        activityName.text = name
        detailsL.text = details
        dateFromTo.text = date + " " + from + " - " + to
        elder.text = eEmail
            
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let user = snapshot.value as? [String: Any] {
                if let freeHours = user["freeHours"] as? [[String: Any]] {
                    for i in 0..<freeHours.count {
                        let freeHour = freeHours[i]
                        let From = freeHour["from"] as? String
                        let To = freeHour["to"] as? String
                        let Date = freeHour["date"] as? String
                        if From == self.from {
                            if To == self.to {
                                if Date == self.date {
                                    self.freeUsers.append(user)
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return freeUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = freeUsers[indexPath.row]
        if let email = user["email"] as? String {
            let query = Database.database().reference().child("ActivityRequests").queryOrdered(byChild: "activity_name").queryEqual(toValue: name)
            query.observeSingleEvent(of: .childAdded, with: { (snapshot) in
                snapshot.ref.updateChildValues(["status" : "Registered volunteer"])
                snapshot.ref.updateChildValues(["volunteer" : email])
            })
            if language == "mk" {
                self.volunteer?.text = "Assigned volunteer: \(email)"
            }
            self.volunteer?.text = "Доделен волонтер: \(email)"
        }
        self.tableView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "freeVolunteersCell", for: indexPath) as! FreeVolunteerTableViewCell
        let volunteer = freeUsers[indexPath.row]
        if let fullName = volunteer["fullName"] as? String {
            if let alatitude = volunteer["latitude"] as? Double {
                if let alongitude = volunteer["longitude"] as? Double {
                    let activityLocation = CLLocation(latitude: alatitude, longitude: alongitude)
                    let volunteerLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = activityLocation.distance(from: volunteerLocation)/1000
                    let roundedDistance = round(distance*100)/100
                    print(roundedDistance)
                    cell.name?.text = fullName
                    cell.distance?.text = "\(roundedDistance)km away"
                    if language == "mk" {
                        cell.distance?.text = "\(roundedDistance)km далеку"
                    }
                }
            }
        }
        return cell
    }
}
