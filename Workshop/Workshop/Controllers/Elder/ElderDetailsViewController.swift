//
//  ActivityDetailsViewController.swift
//  Workshop
//
//  Created by Martina on 12/10/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ElderDetailsViewController: UIViewController {
    
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityDescription: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityDate: UILabel!
    @IBOutlet weak var volunteerName: UILabel!
    @IBOutlet weak var volunteerPhone: UILabel!
    @IBOutlet weak var volunteerEmail: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var gradeButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var timeInterval: UILabel!
    
    var name = ""
    var details = ""
    var date = ""
    var location = ""
    var from = ""
    var to = ""
    var vName = ""
    var vPhone = ""
    var vEmail = ""
    var status = ""
    var key = ""
    var vRating:Double = 0
    var sum:Double = 0
    var Users = [Dictionary<String, AnyObject>()]
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        if status == "Scheduled task" {
            rating.text = String(format:"%.2f", vRating)
        }
            
        else if status == "Finished task" {
            rating.text = String(format:"%.2f", vRating)
        }
            
        else if status == "Registered volunteer" {
            rating.text = String(format:"%.2f", vRating)
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        activityName.text = name
        activityDescription.text = details
        activityDate.text = date
        timeInterval.text = from + " - " + to
                
        let elderEmail = Auth.auth().currentUser?.email
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: vEmail)
        
        Database.database().reference().child("Users/\(safeEmail)/comments").observe(.value, with: { snapshot in
            if let comments = snapshot.value as? [[String: Any]] {
                for i in 0..<comments.count {
                    if let comment = comments[i] as? [String: Any] {
                        if let activity_name = comment["activity_name"] as? String {
                            if let userEmail = comment["user"] as? String {
                                if (userEmail == elderEmail && activity_name == self.name) {
                                    self.gradeButton.isHidden = true
                                }
                            }
                        }
                    }
                }
            }
        })
        
        if status == "Active request" {
            volunteerName.isHidden = true
            nameLabel.isHidden = true
            volunteerEmail.isHidden = true
            volunteerPhone.isHidden = true
            line.isHidden = true
            gradeButton.isHidden = true
            ratingLabel.isHidden = true
            rating.isHidden = true
        }
            
        else if status == "Scheduled task" {
            volunteerName.text = vName
            volunteerEmail.text = vEmail
            volunteerPhone.text = vPhone
            gradeButton.isHidden = true
            cancelButton.isHidden = true
        }
            
        else if status == "Finished task" {
            volunteerName.text = vName
            volunteerEmail.text = vEmail
            volunteerPhone.text = vPhone
            cancelButton.isHidden = true
        }
            
        else if status == "Registered volunteer" {
            volunteerName.text = vName
            volunteerEmail.text = vEmail
            volunteerPhone.text = vPhone
            gradeButton.isHidden = true
            cancelButton.isHidden = true
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        Database.database().reference().child("ActivityRequests/\(key)").removeValue()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func gradeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "rateVolunteerSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RateVolunteerViewController {
            vc.vEmail = self.vEmail
            vc.name = self.vName
            vc.activityName = self.name
        }
    }
    
}


