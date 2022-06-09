//
//  RateVolunteerViewController.swift
//  Workshop
//
//  Created by Martina on 12/21/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import DropDown
import FirebaseAuth

class RateVolunteerViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    var vEmail = ""
    var name = ""
    var vRating:Double = 0
    var sum:Double = 0
    let dropDown = DropDown()
    let items = ["5", "4", "3", "2", "1"]
    var grade = ""
    var activityName = ""
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    let currentUserEmail = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }
    
    @IBAction func gradeButtonPressed(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        DatabaseManager.shared.insertGrades(with: vEmail, grade: Int(self.grade)!)
        DatabaseManager.shared.insertRating(with: vEmail)
        DatabaseManager.shared.insertComments(with: self.vEmail, comment: self.comment.text, activityName: self.activityName, user: currentUserEmail!)
        self.navigationController?.popToRootViewController(animated: true)

        if language == "mk" {
            self.displayAlert(title: "", message: "Оцената е додадена!")
        }
        self.displayAlert(title: "", message: "Grade added!")
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
        dropDownView.layer.cornerRadius = 5
        dropDownView.layer.borderWidth = 1
        dropDownView.layer.borderColor = UIColor.lightGray.cgColor
        dropDownView.backgroundColor = .systemBackground
        dropDown.anchorView = dropDownView
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
