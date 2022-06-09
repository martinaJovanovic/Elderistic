//
//  ElderTableViewController.swift
//  Workshop
//
//  Created by Martina on 12/8/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ElderTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var myRequests = [Dictionary<String, AnyObject>()]
    var filteredRequests = [Dictionary<String, AnyObject>()]
    var Users = [Dictionary<String, AnyObject>()]
    var activityStatus = ""
    var vName = ""
    var vPhone = ""
    var vGrades = ""
    
    var searchController = UISearchController()
    
    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    @IBAction func backPressed(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        view.backgroundColor = .systemBackground
        myRequests.remove(at: 0)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        fetchData()
    }
    
    @objc func refresh(sender: AnyObject) {
        fetchData()
    }
    
    func fetchData() {
        if tableView.refreshControl?.isRefreshing == true {
            print("Refreshing data")
        }
        else {
            print("Fetching data")
        }
        
        myRequests.removeAll()
        Database.database().reference().child("Users").observe(.childAdded) { (snapshot) in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                self.Users.append(RequestDictionary)
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childChanged) { snapshot in
            if let RequestDictionary = snapshot.value as? [String: AnyObject] {
                if let key = snapshot.key as? String {
                    for index in 0..<self.myRequests.count {
                        if let keyreq = self.myRequests[index]["key"] as? String {
                            if key == keyreq {
                                self.myRequests[index] = RequestDictionary
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childAdded) { snapshot in
            if var myRequestDictionary = snapshot.value as? [String: AnyObject] {
                if let email = myRequestDictionary["elder_email"] as? String {
                    if email == Auth.auth().currentUser?.email {
                        myRequestDictionary["key"] = snapshot.key as AnyObject
                        self.myRequests.append(myRequestDictionary)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childRemoved) { snapshot in
            if let key = snapshot.key as? String {
                for index in 0..<self.myRequests.count {
                    if let keyreq = self.myRequests[index]["key"] as? String {
                        if keyreq == key {
                            self.myRequests.remove(at: index)
                            self.tableView.reloadData()
                            break;
                        }
                    }
                }
            }
        }
    
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func initSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .done
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.scopeButtonTitles = ["Active", "Scheduled", "Finished", "Assigned volunteer"]
        if language == "mk" {
            searchController.searchBar.scopeButtonTitles = ["Активни", "Закажани", "Завршени", "Доделен волонтер"]
            searchController.searchBar.placeholder = "Пребарувај"
            searchController.searchBar.setValue("Откажи", forKey: "cancelButtonText")
        }
        searchController.searchBar.delegate = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {if searchController.isActive {
            return filteredRequests.count
        }
        return myRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        var RequestDictionary = Dictionary<String, AnyObject>()
        
        if searchController.isActive {
            RequestDictionary = filteredRequests[indexPath.row]
        }
        else {
            RequestDictionary = myRequests[indexPath.row]
        }

        if let email = RequestDictionary["elder_email"] as? String {
            if let activityName = RequestDictionary["activity_name"] as? String {
                if email == Auth.auth().currentUser?.email {
                    cell.textLabel?.text = "\(activityName)"
                }
            }
        }
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scopeButton = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        let searchText = searchBar.text!
        filterForSearchTextAndScopeButton(searchText: searchText, scopeButton: scopeButton)
    }
    
    func filterForSearchTextAndScopeButton(searchText: String, scopeButton : String) {
        var status = ""
        filteredRequests = myRequests.filter( { request in
            if (scopeButton == "Scheduled" || scopeButton == "Закажани") {
                status = "Scheduled task"
            }
            else if (scopeButton == "Active" || scopeButton == "Активни") {
                status = "Active request"
            }
            else if (scopeButton == "Finished" || scopeButton == "Завршени") {
                status = "Finished task"
            }
            else {
                status = "Registered volunteer"
            }
            
            let scopeMatch = (scopeButton == "All" || request["status"] as? String == status)
            
            if (searchController.searchBar.text != "") {
                let activityName = request["activity_name"] as? String
                let searchTextMatch = activityName!.lowercased().hasPrefix(searchText.lowercased())
                return searchTextMatch
            }
            else {
                return scopeMatch
            }
        })
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var myRequest = Dictionary<String, AnyObject>()
        
        if searchController.isActive {
            myRequest = filteredRequests[indexPath.row]
        }
        else {
            myRequest = myRequests[indexPath.row]
        }
        performSegue(withIdentifier: "activityDetailsSegue", sender: myRequest)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ElderDetailsViewController,
            let myRequest = sender as? Dictionary<String, AnyObject>,
            let activityName = myRequest["activity_name"] as? String,
            let activityDescription = myRequest["description"] as? String,
            let date = myRequest["date"] as? String,
            let to = myRequest["to"] as? String,
            let from = myRequest["from"] as? String,
            let latitude = myRequest["latitude"] as? Double,
            let longitude = myRequest["longitude"] as? Double,
            let vEmail = myRequest["volunteer"] as? String,
            let status = myRequest["status"] as? String,
            let key = myRequest["key"] as? String else {
                return
        }
        for i in 0..<Users.count {
            if let userEmail = Users[i]["email"] as? String {
                if userEmail == vEmail {
                    guard let userName = Users[i]["fullName"] as? String,
                        let phone = Users[i]["phoneNumber"] as? String,
                        let rating = Users[i]["rating"] as? Double else {
                            return
                    }
                    vc.vName = userName
                    vc.vPhone = phone
                    vc.vRating = rating
                }
                vc.name = activityName
                vc.details = activityDescription
                vc.date = date
                vc.location = String(latitude) + "," + String(longitude)
                vc.from = from
                vc.to = to
                vc.vEmail = vEmail
                vc.status = status
                vc.key = key
            }
        }
    }
}

