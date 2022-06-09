//
//  ViewController.swift
//  Workshop
//
//  Created by Martina on 12/4/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseAuth
import DropDown
import LanguageManager_iOS
import JGProgressHUD
import Localize_Swift

class LoginViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var flagButton: UIButton!
    
    let spinner = JGProgressHUD(style: .light)
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")
    
    let menu: DropDown = {
        let menu = DropDown()
        let images = ["macedonia", "uk"]
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu.customCellConfiguration = { index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(named: images[index])
        }
        return menu
    }()
    
    @IBAction func flagTapped(_ sender: Any) {
        menu.show()
    }
    
    @IBAction func onClickSwitch(_ sender: UISwitch) {
        let appDelegate = UIApplication.shared.windows.first
        if sender.isOn {
            appDelegate?.overrideUserInterfaceStyle = .dark
            return
        }
        else {
            appDelegate?.overrideUserInterfaceStyle = .light
            return
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTF.text {
            if let password = passwordTF.text {
                spinner.show(in: view)
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    
                    DispatchQueue.main.async {
                       self.spinner.dismiss()
                    }
                    
                    if error == nil {
                        print ("Login successful")
                        if user?.user.displayName == "Volunteer" {
                            print("Volunteer logged in")
                            self.performSegue(withIdentifier: "volunteerSegue", sender: nil)
                        }
                        else if user?.user.displayName == "Elder"{
                            print("Elder logged in")
                            self.performSegue(withIdentifier: "elderSegue", sender: nil)
                        }
                        else {
                            print("Organiser logged in")
                            self.performSegue(withIdentifier: "organiserSegue", sender: nil)
                        }
                    }
                        
                    else {
                        self.displayAlert(title: "Error", message: error!.localizedDescription)
                    }
                    
                    self.emailTF.text = ""
                    self.passwordTF.text = ""
                }
            }
        }
    }
    
    override func viewDidLoad() {
        design()
        super.viewDidLoad()
    }
    
    @IBAction func singUpButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signUpSegue", sender: nil)
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
        scrollView.delegate = self
        view.backgroundColor = .systemBackground
        emailTF.returnKeyType = .continue
        emailTF.autocorrectionType = .no
        passwordTF.returnKeyType = .done
        passwordTF.autocorrectionType = .no
        
        if language == "mk" {
            flagButton.setImage(UIImage(named: "macedonia"), for: .normal)
            menu.dataSource = ["Македонски", "Англиски"]
        }
        else {
            flagButton.setImage(UIImage(named: "uk"), for: .normal)
            menu.dataSource = ["Macedonian", "English"]
        }
        signUpButton.layer.cornerRadius = 15
        loginButton.layer.cornerRadius = 15
        menu.anchorView = dropDownView
        menu.selectionAction = { index, title in
            if index == 1 {
                Bundle.setLanguage("en")
                UserDefaults.standard.set("en", forKey: "selectedLanguage")
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
            }
            else {
                Bundle.setLanguage("mk")
                UserDefaults.standard.set("mk", forKey: "selectedLanguage")
                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateInitialViewController()
            }
        }
        let emailImage = UIImage(named: "email")!
        emailTF.setleftIcon(emailImage)
        let passwordImage = UIImage(named: "lock")!
        passwordTF.setleftIcon(passwordImage)
        emailTF.attributedPlaceholder = NSAttributedString (
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
        passwordTF.attributedPlaceholder = NSAttributedString (
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
        )
    }
}

extension UITextField {
    func setleftIcon (_ image: UIImage) {
        let iconView = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let containerView : UIView = UIView(frame: CGRect(x: 20, y: 0, width: 30, height: 30))
        containerView.addSubview(iconView)
        leftView = containerView
        leftViewMode = .always
    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        var onceToken: Int = 0
        
        if (onceToken == 0) {
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        onceToken = 1
        objc_setAssociatedObject(Bundle.main, &associatedLanguageBundle, (language != nil) ? Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj") ?? "") : nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
private var associatedLanguageBundle:Character = "0"

class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle: Bundle? = objc_getAssociatedObject(self, &associatedLanguageBundle) as? Bundle
        return (bundle != nil) ? (bundle!.localizedString(forKey: key, value: value, table: tableName)) : (super.localizedString(forKey: key, value: value, table: tableName))
    }
}
