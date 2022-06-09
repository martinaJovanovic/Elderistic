//
//  ProfileViewController.swift
//  Workshop
//
//  Created by Martina on 2/15/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import DropDown
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fromTF: UITextField!
    @IBOutlet weak var toTF: UITextField!
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    
    var freeHours = [Dictionary<String, AnyObject>()]
    
    var dateP = UIDatePicker()
    var fromP = UIDatePicker()
    var toP = UIDatePicker()
    let currentUserEmail = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
       super.viewDidLoad()
        createDatePicker()
        guard let email = Auth.auth().currentUser?.email else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        Database.database().reference().child("Users/\(safeEmail)/freeHours").observe(.childAdded) { (snapshot) in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                self.freeHours.append(RequestDictionary)
                self.tableView.reloadData()
            }
        }
        
        Database.database().reference().child("Users/\(safeEmail)/freeHours").observe(.childRemoved) { (snapshot) in
            for index in 0..<self.freeHours.count {
                self.freeHours.remove(at: index)
                self.tableView.reloadData()
                break;
            }
        }
    
    }
    
    @IBAction func locationtapped(_ sender: Any) {
        performSegue(withIdentifier: "locationSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let date = freeHours[indexPath.row]["date"] as? String
            let from = freeHours[indexPath.row]["from"] as? String
            let to = freeHours[indexPath.row]["to"] as? String
            guard let email = Auth.auth().currentUser?.email else {
                return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            tableView.beginUpdates()
            DatabaseManager.shared.deleteFreeHour(with: safeEmail, date: date!, from: from!, to: to!)
            self.freeHours.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        tableView.endUpdates()
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return freeHours.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "freeHoursCell", for: indexPath)
        if let date = freeHours[indexPath.row]["date"] as? String {
            if let from = freeHours[indexPath.row]["from"] as? String {
                if let to = freeHours[indexPath.row]["to"] as? String {
                    var freeHour = date + " "
                    freeHour = freeHour + from
                    freeHour = freeHour + " - " + to
                    cell.textLabel?.text = freeHour
                }
            }
        }
        return cell
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addtapped(_ sender: Any) {
        guard let date = dateTF.text,
            let from = fromTF.text,
            let to = toTF.text,
            let currentUserEmail = Auth.auth().currentUser?.email else {
                return
        }
        DatabaseManager.shared.insertFreeHours(with: currentUserEmail, date: date, from: from, to: to)
        dateTF.text = ""
        toTF.text = ""
        fromTF.text = ""
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
    
}
