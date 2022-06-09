//
//  ElderViewController.swift
//  Workshop
//
//  Created by Martina on 12/5/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class ElderViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var activityNameTF: UITextField!
    @IBOutlet weak var activityDescriptionTF: UITextView!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var toTF: UITextField!
    @IBOutlet weak var fromTF: UITextField!
    @IBOutlet weak var addActivityButton: UIButton!
    @IBOutlet weak var chooseLocationButton: UIButton!
    
    let dateP = UIDatePicker()
    let fromP = UIDatePicker()
    let toP = UIDatePicker()
    var frequency = ""
    let locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    let email = Auth.auth().currentUser?.email
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
        createDatePicker()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "elderMapSegue" {
            let vc = segue.destination as! ElderMapViewController
            if let name = activityNameTF.text {
                if let description = activityDescriptionTF.text {
                    if let date = dateTF.text {
                        if let to = toTF.text {
                            if let from = fromTF.text {
                                vc.email = email!
                                vc.activityName = name
                                vc.activityDescription = description
                                vc.date = date
                                vc.to = to
                                vc.from = from
                                vc.frequency = frequency
                                vc.myLatitude = userLocation.latitude
                                vc.myLongitude = userLocation.longitude
                            }
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
        }
    }
    
    @IBAction func addActivityPressed(_ sender: Any) {
        let name = activityNameTF.text
        let description = activityDescriptionTF.text
        let date = dateTF.text
        let latitude = userLocation.latitude
        let longitude = userLocation.longitude
        let to = toTF.text
        let from = fromTF.text
        if (name != "" && date != "" && from != "" && to != "") {
            let activityDictionary = ["elder_email": email, "activity_name": name, "description": description, "date": date, "from": from, "to": to, "latitude": latitude, "longitude": longitude, "status": "Active request", "volunteer": ""] as [String : Any]
            Database.database().reference().child("ActivityRequests").childByAutoId().setValue(activityDictionary)
            DatabaseManager.shared.insertActivities(with: email!, activity: name!)
            
            if language == "mk" {
                self.displayAlert(title: "", message: "Барањето е додадено")
            }
            else {
                self.displayAlert(title: "", message: "Request added!")
            }
        }
        else {
            if language == "mk" {
                self.displayAlert(title: "", message: "Ве молиме пополнете ги сите полиња")
            }
            else {
                self.displayAlert(title: "", message: "Please fill all the blanks")
            }
        }
        self.activityNameTF.text = ""
        self.activityDescriptionTF.text = ""
        self.dateTF.text = ""
        self.toTF.text = ""
        self.fromTF.text = ""
        self.activityDescriptionTF.text = ""
        self.textViewDidEndEditing(activityDescriptionTF)
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description"
            if language == "mk" {
                textView.text = "Опис"
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        try? Auth.auth().signOut()
        tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    func design() {
        view.backgroundColor = .systemBackground
        activityDescriptionTF.layer.borderWidth = 1
        activityNameTF.layer.borderWidth = 1
        activityNameTF.returnKeyType = .continue
        activityNameTF.autocorrectionType = .no
        activityDescriptionTF.autocorrectionType = .no
        activityDescriptionTF.returnKeyType = .done
        dateTF.layer.borderWidth = 1
        fromTF.layer.borderWidth = 1
        toTF.layer.borderWidth = 1
        activityDescriptionTF.layer.cornerRadius = 5
        activityNameTF.layer.cornerRadius = 5
        fromTF.layer.cornerRadius = 5
        toTF.layer.cornerRadius = 5
        dateTF.layer.cornerRadius = 5
        activityDescriptionTF.layer.borderColor = UIColor.lightGray.cgColor
        activityNameTF.layer.borderColor = UIColor.lightGray.cgColor
        dateTF.layer.borderColor = UIColor.lightGray.cgColor
        toTF.layer.borderColor = UIColor.lightGray.cgColor
        fromTF.layer.borderColor = UIColor.lightGray.cgColor
        activityDescriptionTF.text = "Description"
        if language == "mk" {
            activityDescriptionTF.text = "Опис"
        }
        activityDescriptionTF.textColor = UIColor.lightGray
        activityDescriptionTF.delegate = self
        addActivityButton.layer.cornerRadius = 15
        chooseLocationButton.titleLabel?.font = (UIFont.boldSystemFont(ofSize: 15))
        addActivityButton.titleLabel?.font = (UIFont.boldSystemFont(ofSize: 15))
    }
    
    @IBAction func chooseLocationTapped(_ sender: Any) {
        performSegue(withIdentifier: "elderMapSegue", sender: nil)
    }
    
    func createDatePicker() {
        toP.datePickerMode = .time
        fromP.datePickerMode = .time
        dateP.datePickerMode = .date
        let dateToolbar = UIToolbar()
        dateToolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        dateToolbar.setItems([doneButton], animated: true)
        dateTF.inputAccessoryView = dateToolbar
        dateTF.inputView = dateP
        let fromToolbar = UIToolbar()
        fromToolbar.sizeToFit()
        let doneButtonFrom = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedFrom))
        fromToolbar.setItems([doneButtonFrom], animated: true)
        fromTF.inputAccessoryView = fromToolbar
        fromTF.inputView = fromP
        let toToolbar = UIToolbar()
        toToolbar.sizeToFit()
        let doneButtonTo = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedTo))
        toToolbar.setItems([doneButtonTo], animated: true)
        toTF.inputAccessoryView = toToolbar
        toTF.inputView = toP
    }
    
    @objc func donePressedFrom() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        fromTF.text = formatter.string(from: fromP.date)
        self.view.endEditing(true)
    }
    
    @objc func donePressedTo() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        toTF.text = formatter.string(from: toP.date)
        self.view.endEditing(true)
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        dateTF.text = formatter.string(from: dateP.date)
        self.view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
