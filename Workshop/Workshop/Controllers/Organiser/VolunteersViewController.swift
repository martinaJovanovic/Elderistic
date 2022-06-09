//
//  VolunteersViewController.swift
//  Workshop
//
//  Created by Martina on 2/18/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class VolunteersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var Users = [Dictionary<String, Any>()]
    var filteredUsers = [Dictionary<String, Any>()]
    
    let searchController = UISearchController()
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    override func viewDidLoad() {
        super.viewDidLoad()
        Users.remove(at: 0)
        initSearchController()

        Database.database().reference().child("Users").observe(.childAdded) { snapshot in
            if let RequestDictionary = snapshot.value as? [String: Any] {
                if let role = RequestDictionary["role"] as? String {
                    if role == "Volunteer" {
                        self.Users.append(RequestDictionary)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        Database.database().reference().child("Users").observe(.childRemoved) { snapshot in
            if let myRequestDictionary = snapshot.value as? [String: Any] {
                if let role = myRequestDictionary["role"] as? String {
                    for index in 0..<self.Users.count {
                        if role == "Volunteer" {
                            self.Users.remove(at: index)
                            self.tableView.reloadData()
                            break;
                        }
                    }
                }
            }
        }
        
        Database.database().reference().child("Users").observe(.childChanged) { snapshot in
            if let myRequestDictionary = snapshot.value as? [String: Any] {
                if let role = myRequestDictionary["role"] as? String {
                    if role == "Volunteer" {
                        for index in 0..<self.Users.count {
                            self.Users[index] = myRequestDictionary
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.delegate = self
        if language == "mk" {
            searchController.searchBar.placeholder = "Пребарувај"
            searchController.searchBar.setValue("Откажи", forKey: "cancelButtonText")
        }
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredUsers.count
        }
        return Users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "volunteersCell", for: indexPath) as! VolunteersTableViewCell

        var user = Dictionary<String, Any>()
        
        if searchController.isActive {
            user = filteredUsers[indexPath.row]
        }
        else {
            user = Users[indexPath.row]
        }
        var counter: Int = 0
        if let name = user["fullName"] as? String {
            if let rating = user["rating"] as? Double {
                if let email = user["email"] as? String {
                    let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                    Database.database().reference().child("Users/\(safeEmail)/activities").observeSingleEvent(of: .value, with: { snapshot in
                        if let activities = snapshot.value as? [[String: Any]] {                            cell.number.text = String(activities.count)
                        }
                        else {
                            cell.number.text = "0"
                        }
                    })
                    cell.name?.text = name
                    cell.rating?.text = String(format:"%.2f", rating)
                }
            }
        }
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        filterForSearchText(searchText: searchText)
    }
    
    func filterForSearchText(searchText: String) {
        filteredUsers = Users.filter( { user in
            let fullName = user["fullName"] as? String
            let firstName = fullName?.split(separator: " ")[0]
            let lastName = fullName?.split(separator: " ")[1]
            let searchTextMatch = (firstName!.lowercased().hasPrefix(searchText.lowercased()) || lastName!.lowercased().hasPrefix(searchText.lowercased()))
            return searchTextMatch
        })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var request = Dictionary<String, Any>()
        
        if searchController.isActive {
            request = filteredUsers[indexPath.row]
        }
        else {
            request = Users[indexPath.row]
        }
        performSegue(withIdentifier: "volunteerCommentsSegue", sender: request)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? VolunteersCommentsViewController,
            let request = sender as? Dictionary<String, AnyObject>,
            let email = request["email"] as? String,
            let fullName = request["fullName"] as? String else {
                return
        }
        vc.email = email
        vc.name = fullName
    }
    
}
