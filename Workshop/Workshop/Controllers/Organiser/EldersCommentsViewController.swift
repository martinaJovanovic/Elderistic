//
//  ElderDetailsViewController.swift
//  Workshop
//
//  Created by Martina on 2/22/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import UIKit
import FirebaseDatabase

class EldersCommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fullName: UILabel!
    
    var name = ""
    var email = ""
    var volunteerName = ""
    
    var Comments = [Dictionary<String, Any>()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullName?.text = name
        Comments.remove(at: 0)
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        Database.database().reference().child("Users/\(safeEmail)/comments").observe(.value, with: { snapshot in
            if let comments = snapshot.value as? [[String: Any]] {
                for i in 0..<comments.count {
                    if let comment = comments[i] as? [String: Any] {
                        self.Comments.append(comment)
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Comments.count == 0 {
            tableView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Comments.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eldCommentsCell", for: indexPath) as! EldersCommentsTableViewCell
        let comment = Comments[indexPath.row]
        if let activity = comment["activity_name"] as? String {
            if let user = comment["user"] as? String {
                if let comment = comment["comment"] as? String {
                    let safeEmail = DatabaseManager.safeEmail(emailAddress: user)
                    Database.database().reference().child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
                        if let value = snapshot.value as? [String: Any] {
                            if let fullName = value["fullName"] as? String {
                                cell.name.text = fullName
                            }
                        }
                    })
                    cell.activityName?.text = activity
                    cell.comment.text = comment
                }
            }
        }
        return cell
    }
    
}
