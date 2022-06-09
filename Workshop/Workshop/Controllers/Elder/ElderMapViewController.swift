//
//  ElderMapViewController.swift
//  Workshop
//
//  Created by Martina on 12/10/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class ElderMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var addActivityButton: UIButton!
    
    var email = ""
    var activityName = ""
    var activityDescription = ""
    var frequency = ""
    var date = ""
    var from = ""
    var to = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var myLatitude:CLLocationDegrees = 0
    var myLongitude:CLLocationDegrees = 0
    
    let annotation = MKPointAnnotation()
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addActivityButton.layer.cornerRadius = 15
        map.delegate = self
        let coordinate = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        map.setRegion(viewRegion, animated: false)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(ElderMapViewController.longpress(gestureRecognizer:)))
        map.addGestureRecognizer(gesture)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title = ""
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                if error != nil {
                    print(error!)
                }
                else {
                    if let placemark = placemarks?[0] {
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                            
                        }
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare!
                        }
                    }
                }
                if title == "" {
                    title = "Added \(NSDate())"
                }
                let annotation1 = MKPointAnnotation()
                annotation1.coordinate = newCoordinate
                annotation1.title = title
                self.map.addAnnotation(annotation1)
                self.map.removeAnnotation(self.annotation)
                self.latitude = newCoordinate.latitude
                self.longitude = newCoordinate.longitude
            }
        }
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let activityDictionary = ["elder_email": email, "activity_name": activityName, "description": activityDescription, "date": date, "from": from, "to": to, "latitude": latitude, "longitude": longitude, "status": "Active request", "volunteer": ""] as [String : Any]
        Database.database().reference().child("ActivityRequests").childByAutoId().setValue(activityDictionary)
        if language == "mk" {
            self.displayAlert(title: "", message: "Барањето е додадено!")
        }
        else {
            self.displayAlert(title: "", message: "Request added!")
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
