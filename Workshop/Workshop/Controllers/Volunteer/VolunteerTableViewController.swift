//
//  VolunteersTableViewController.swift
//  Workshop
//
//  Created by Martina on 12/24/21.
//  Copyright © 2021 Martina. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class VolunteerTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    var myRequests = [Dictionary<String, AnyObject>()]
    var filteredRequests = [Dictionary<String, AnyObject>()]
    var Users = [Dictionary<String, AnyObject>()]
    var eName = ""
    var ePhone = ""
    var eGrades = ""
    var myLatitude:Double = 0
    var myLongitude:Double = 0
    
    let searchController = UISearchController()

    let language = UserDefaults.standard.string(forKey: "selectedLanguage")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        initSearchController()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        myRequests.remove(at: 0)
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
        
        Database.database().reference().child("ActivityRequests").observe(.childAdded) { (snapshot) in
            if var myRequestDictionary = snapshot.value as? [String: AnyObject] {
                if let email = myRequestDictionary["volunteer"] as? String {
                    if email == Auth.auth().currentUser?.email {
                        myRequestDictionary["key"] = snapshot.key as AnyObject
                        self.myRequests.append(myRequestDictionary)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        Database.database().reference().child("ActivityRequests").observe(.childRemoved) { (snapshot) in
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
        searchController.searchBar.scopeButtonTitles = ["Scheduled", "Finished", "Assigned"]
        searchController.searchBar.delegate = self

        if language == "mk" {
            searchController.searchBar.scopeButtonTitles = ["Закажани", "Завршени", "Доделени"]
            searchController.searchBar.placeholder = "Пребарувај"
            searchController.searchBar.setValue("Откажи", forKey: "cancelButtonText")
        }
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredRequests.count
        }
        return myRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "volunteerCell", for: indexPath) as! VolunteerTableViewCell
        var RequestDictionary = Dictionary<String, AnyObject>()
        
        if searchController.isActive {
            RequestDictionary = filteredRequests[indexPath.row]
        }
        else {
            RequestDictionary = myRequests[indexPath.row]
        }
        if let activityName = RequestDictionary["activity_name"] as? String {
            if let date = RequestDictionary["date"] as? String {
                if let elderEmail = RequestDictionary["elder_email"] as? String {
                    let safeEmail = DatabaseManager.safeEmail(emailAddress: elderEmail)
                    Database.database().reference().child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            if let fullName = value["fullName"] as? String  {
                                if let rating = value["rating"] as? Double {
                                    cell.elderName.text = "\(fullName)"
                                    cell.elderRating.text = String(format:"%.2f", rating)
                                    cell.activityName.text = "\(activityName)"
                                    cell.date.text = "\(date)"
                                }
                            }
                        }
                    })
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
        performSegue(withIdentifier: "volunteerDetailsSegue", sender: myRequest)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? VolunteerDetailsViewController,
            let myRequest = sender as? Dictionary<String, AnyObject>,
            let activityName = myRequest["activity_name"] as? String,
            let activityDescription = myRequest["description"] as? String,
            let date = myRequest["date"] as? String,
            let from = myRequest["from"] as? String,
            let to = myRequest["to"] as? String,
            let latitude = myRequest["latitude"] as? Double,
            let longitude = myRequest["longitude"] as? Double,
            let eEmail = myRequest["elder_email"] as? String,
            let status = myRequest["status"] as? String,
            let key = myRequest["key"] as? String else {
                return
        }
        vc.name = activityName
        vc.details = activityDescription
        vc.date = date
        vc.latitude = latitude
        vc.longitude = longitude
        vc.to = to
        vc.from = from
        vc.eEmail = eEmail
        vc.status = status
        vc.key = key
    }

}

struct SearchResult {
    let name: String
    let status: String
    let date: String
    let from: String
    let to: String
    let description: String
    let latitude: Double
    let longitude: Double
    let elder_email: String
    let volunteer: String
}
