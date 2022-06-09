//
//  VolunteerDetailsViewController.swift
//  Workshop
//
//  Created by Martina on 12/24/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class VolunteerDetailsViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var activityName: UILabel!
    @IBOutlet weak var activityDescription: UILabel!
    @IBOutlet weak var activityDate: UILabel!
    @IBOutlet weak var rateElderButton: UIButton!
    @IBOutlet weak var finishedLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var fromToLabel: UILabel!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
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

    var myRequests = [Dictionary<String, AnyObject>()]

    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        map.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(viewRegion, animated: false)
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        activityName.text = name
        activityDate.text = date
        activityDescription.text = details
        fromToLabel.text = from + " - " + to
        acceptButton.layer.cornerRadius = 15
        rejectButton.layer.cornerRadius = 15
        
        if status == "Registered volunteer" {
            rateElderButton.isHidden = true
            finishedLabel.isHidden = true
        }
        
        else if status == "Active request" {
            rateElderButton.isHidden = true
            finishedLabel.isHidden = true
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
            
        else if status == "Finished task" {
            rateElderButton.isHidden = true
            finishedLabel.isHidden = true
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
            
        else if status == "Scheduled task" {
            acceptButton.isHidden = true
            rejectButton.isHidden = true
        }
        
    }
    
    @IBAction func rateEdlerPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "rateElderSegue", sender: nil)
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        Database.database().reference().child("ActivityRequests/\(key)").observeSingleEvent(of: .value, with: { snapshot in
            snapshot.ref.updateChildValues(["status" : "Scheduled task"])
        })
        guard let currentUserEmail = Auth.auth().currentUser?.email else {
            return
        }
        DatabaseManager.shared.insertActivities(with: currentUserEmail, activity: name)
        acceptButton.isHidden = true
        rejectButton.isHidden = true
        rateElderButton.isHidden = false
        finishedLabel.isHidden = false
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
        Database.database().reference().child("ActivityRequests/\(key)").observeSingleEvent(of: .value, with: { snapshot in
            snapshot.ref.updateChildValues(["status" : "Active request"])
            snapshot.ref.updateChildValues(["volunteer" : ""])
            self.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RateElderViewController {
            vc.eEmail = self.eEmail
            vc.activityName = self.name
        }
    }
}
