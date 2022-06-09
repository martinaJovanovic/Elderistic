//
//  SignUpVIewController.swift
//  Workshop
//
//  Created by Martina on 12/5/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import DropDown
import JGProgressHUD

class SignUpViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var viewDropDown: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let spinner = JGProgressHUD(style: .light)
    
    var role = ""
    let dropDown = DropDown()
    var items = ["Volunteer", "Elder", "Organiser"]
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    override func viewDidLoad() {
        super.viewDidLoad()
        design()
    }
    
    @IBAction func typeButtonPressed(_ sender: Any) {
        dropDown.show()
    }
    
    @IBAction func singUpButtonPressed(_ sender: Any) {
        if emailTF.text != "" && passwordTF.text != ""  && nameTF.text != "" && phoneTF.text != ""{
            if let email = emailTF.text {
                if let password = passwordTF.text {
                    let fullName = nameTF.text
                    let phoneNumber = phoneTF.text
                    spinner.show(in: view)
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        
                        DispatchQueue.main.async {
                           self.spinner.dismiss()
                        }
                        
                        if error == nil {
                            print("Sign Up Success!")
                                                        
                            let req = Auth.auth().currentUser?.createProfileChangeRequest()
                            req?.displayName = self.role
                            req?.commitChanges(completion: nil)
                            
                            DatabaseManager.shared.userExists(with: email, completion: { exists in
                                guard !exists else {
                                    return
                                }
                            })
                            
                            if (self.role == "Volunteer") {
                                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                                Database.database().reference().child("Users/\(safeEmail)").setValue([
                                    "fullName" : fullName!,
                                    "email" : email,
                                    "role" : self.role,
                                    "phoneNumber" : phoneNumber!,
                                    "grades" : [],
                                    "freeHours" : [],
                                    "latitude" : 0,
                                    "longitude" : 0,
                                    "rating" : 0
                                    ]
                                )
                            }
                            
                            else if (self.role == "Elder") {
                                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                                Database.database().reference().child("Users/\(safeEmail)").setValue([
                                    "fullName" : fullName!,
                                    "email" : email,
                                    "role" : self.role,
                                    "phoneNumber" : phoneNumber!,
                                    "grades" : [],
                                    "rating" : 0
                                    ]
                                )
                            }
                                
                            else {
                                let newUser = AppUser(fullName: fullName!, email: email, phoneNumber: phoneNumber!, role: self.role)
                                DatabaseManager.shared.insertUser(with: newUser, completion: { success in
                                    if success {
                                        print("User added to realtime database")
                                    }
                                })
                            }
                            self.nameTF.text = ""
                            self.emailTF.text = ""
                            self.passwordTF.text = ""
                            self.phoneTF.text = ""
                            self.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }
                            
                        else {
                            if self.language == "mk" {
                                self.displayAlert(title: "Грешка", message: error!.localizedDescription)
                            }
                            else {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
            
        else {
            if language == "en" {
                self.displayAlert(title: "", message: "Please fill all the blanks!")
            }
            else {
                self.displayAlert(title: "", message: "Пополнете ги сите полиња!")
            }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x != 0) {
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y), animated: false)
        }
        scrollView.isDirectionalLockEnabled = true
    }
    
    func design() {
        view.backgroundColor = .systemBackground
        scrollView.delegate = self
        emailTF.returnKeyType = .continue
        emailTF.autocorrectionType = .no
        nameTF.returnKeyType = .continue
        nameTF.autocorrectionType = .no
        phoneTF.returnKeyType = .continue
        passwordTF.returnKeyType = .done
        viewDropDown.backgroundColor = .systemBackground
        
        if language == "mk" {
            items = ["Волонтер", "Возрасно лице", "Организатор"]
        }
        
        viewDropDown.layer.cornerRadius = 5
        viewDropDown.layer.borderWidth = 1
        viewDropDown.layer.borderColor = UIColor.lightGray.cgColor
        signUpButton.layer.cornerRadius = 15
        dropDown.anchorView = viewDropDown
        dropDown.dataSource = items
        dropDown.direction = .top
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.label.text = self.items[index]
            if self.items[index] == "Волонтер" {
                self.role = "Volunteer"
            }
            else if self.items[index] == "Организатор" {
                self.role = "Organiser"
            }
            else if self.items[index] == "Возрасно лице" {
                self.role = "Elder"
            }
            else {
                self.role = self.items[index]
            }
            self.label.textColor = UIColor.black
        }
    }
}
