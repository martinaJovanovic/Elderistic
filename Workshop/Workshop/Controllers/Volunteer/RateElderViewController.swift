//
//  RateElderViewController.swift
//  Workshop
//
//  Created by Martina on 12/24/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import DropDown
import FirebaseDatabase
import FirebaseAuth

class RateElderViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var DropDownView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var comment: UITextView!
    
    var eEmail = ""
    let dropDown = DropDown()
    let items = ["5", "4", "3", "2", "1"]
    var grade = ""
    var activityName = ""
    var volunteerName = ""
    
    let currentUserEmail = Auth.auth().currentUser?.email
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }
    
    @IBAction func gradeButtonPressed(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        DatabaseManager.shared.insertGrades(with: eEmail, grade: Int(self.grade)!)
        DatabaseManager.shared.insertRating(with: eEmail)
        DatabaseManager.shared.insertComments(with: eEmail, comment: self.comment.text, activityName: self.activityName, user: currentUserEmail!)
        self.navigationController?.popToRootViewController(animated: true)

        if language == "mk" {
            self.displayAlert(title: "", message: "Оцената е додадена!")
        }
        self.displayAlert(title: "", message: "Grade added")

        let query = Database.database().reference().child("ActivityRequests").queryOrdered(byChild: "activity_name").queryEqual(toValue: activityName)
        query.observeSingleEvent(of: .childAdded, with: { (snapshot) in
            snapshot.ref.updateChildValues(["status" : "Finished task"])
        })
    }
    
    func textViewDidBeginEditing (_ textView: UITextView) {
            textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            if language == "mk" {
                textView.text = "Коментар"
            }
            textView.text = "Comment"
        }
    }
    
    func design () {
        view.backgroundColor = .systemBackground
        saveButton.layer.cornerRadius = 15
        DropDownView.layer.cornerRadius = 5
        DropDownView.layer.borderWidth = 1
        DropDownView.layer.borderColor = UIColor.lightGray.cgColor
        DropDownView.backgroundColor = .systemBackground
        dropDown.anchorView = DropDownView
        dropDown.dataSource = items
        dropDown.direction = .bottom
        comment.layer.borderWidth = 1
        comment.layer.borderColor = UIColor.lightGray.cgColor
        comment.layer.cornerRadius = 5
        comment.text = "Comment"
        
        if language == "mk" {
            comment.text = "Коментар"
        }
        comment.textColor = UIColor.lightGray
        comment.delegate = self
        comment.returnKeyType = .done
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.grade = self.items[index]
            self.gradeLabel.text = self.items[index]
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
