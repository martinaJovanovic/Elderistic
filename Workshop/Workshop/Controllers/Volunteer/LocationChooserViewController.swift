//
//  LocationChooserViewController.swift
//  Workshop
//
//  Created by Martina on 2/17/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase

class LocationChooserViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var userLocation = CLLocationCoordinate2D()
    let locationManager = CLLocationManager()
    var myLatitude:Double = 0
    var myLongitude:Double = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(LocationChooserViewController.longpress(gestureRecognizer:)))
        map.addGestureRecognizer(gesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let coordinate = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        map.setRegion(viewRegion, animated: false)
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        Database.database().reference().child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
            guard let RequestDictionary = snapshot.value as? [String: AnyObject],
            let latitude = RequestDictionary["latitude"] as? Double,
            let longitude = RequestDictionary["longitude"] as? Double else {
                return
            }
            let annotation = MKPointAnnotation()
            let newCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = newCoordinate
            self.map.addAnnotation(annotation)
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            myLatitude = userLocation.latitude
            myLongitude = userLocation.longitude
        }
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
                let annotation = MKPointAnnotation()
                annotation.coordinate = newCoordinate
                annotation.title = title
                self.map.addAnnotation(annotation)
                
                guard let email = Auth.auth().currentUser?.email else {
                    return
                }
            
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.insertLocation(with: safeEmail, latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            }
        }
    }
    
}
