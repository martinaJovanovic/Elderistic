//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Martina on 1/14/22.
//  Copyright © 2022 Martina. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

extension DatabaseManager {
    
    public func userExists(with email : String, completion: @escaping ((Bool) -> Void)) {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func insertUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        database.child("Users/\(user.safeEmail)").setValue([
            "fullName" : user.fullName,
            "email" : user.email,
            "role" : user.role,
            "phoneNumber" : user.phoneNumber,
            ], withCompletionBlock: {error, _ in
                guard error == nil else {
                    print("Failed to write to database")
                    completion(false)
                    return
                }
        })
    }
    
    public func insertFreeHours(with email: String, date: String, from: String, to: String) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let newFreeHour: [String: Any] = [
            "date": date,
            "from": from,
            "to": to
        ]
        
        database.child("Users/\(safeEmail)/freeHours").observeSingleEvent(of: .value, with: { snapshot in
            if var freeHours = snapshot.value as? [[String: Any]] {
                freeHours.append(newFreeHour)
                self.database.child("Users/\(safeEmail)/freeHours").setValue(freeHours)
            }
       
            else {
                self.database.child("Users/\(safeEmail)/freeHours").setValue([newFreeHour])
            }
            
        })
    }
    
    public func insertGrades(with email: String, grade: Int) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
         
         let newGrade: [String: Any] = [
             "grade": grade
         ]
         
         database.child("Users/\(safeEmail)/grades").observeSingleEvent(of: .value, with: { snapshot in
             if var grades = snapshot.value as? [[String: Any]] {
                 grades.append(newGrade)
                 self.database.child("Users/\(safeEmail)/grades").setValue(grades)
             }
        
             else {
                 self.database.child("Users/\(safeEmail)/grades").setValue([newGrade])
             }
             
         })
    }
    
    public func insertActivities(with email: String, activity: String) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
         
        let newActivity: [String: Any] = [
            "activity": activity
        ]
         
         database.child("Users/\(safeEmail)/activities").observeSingleEvent(of: .value, with: { snapshot in
             if var activities = snapshot.value as? [[String: Any]] {
                 activities.append(newActivity)
                 self.database.child("Users/\(safeEmail)/activities").setValue(activities)
             }
        
             else {
                 self.database.child("Users/\(safeEmail)/activities").setValue([newActivity])
             }
             
         })
    }

    public func insertComments(with email: String, comment: String, activityName: String, user: String) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        let newComment: [String: Any] = [
            "comment": comment,
            "activity_name": activityName,
            "user": user
        ]
        
        database.child("Users/\(safeEmail)/comments").observeSingleEvent(of: .value, with: { snapshot in
            if var comments = snapshot.value as? [[String: Any]] {
                comments.append(newComment)
                self.database.child("Users/\(safeEmail)/comments").setValue(comments)
            }
                
            else {
                self.database.child("Users/\(safeEmail)/comments").setValue([newComment])
            }
            
        })
    }
    
    public func deleteFreeHour(with email: String, date: String, from: String, to: String) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
         
         database.child("Users/\(safeEmail)/freeHours").observeSingleEvent(of: .value, with: { snapshot in
            if var freeHours = snapshot.value as? [[String: Any]] {
                for i in 0..<freeHours.count {
                    guard let Date = freeHours[i]["date"] as? String,
                        let From = freeHours[i]["from"] as? String,
                        let To = freeHours[i]["to"] as? String else {
                            return
                    }
                    
                    if Date == date {
                        if From == from {
                            if To == to {
                                freeHours.remove(at: i)
                                self.database.child("Users/\(safeEmail)/freeHours").setValue(freeHours)
                                break;
                            }
                        }
                    }
                }
             }
         })
    }
    
    public func insertRating(with email: String) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        var rating:Double = 0
        var sum:Double = 0
        var count:Double = 0
        database.child("Users/\(safeEmail)/grades").observe(.value, with: { snapshot in
            if let grades = snapshot.value as? [[String: Any]] {
                for i in 0..<grades.count {
                    guard let grade = grades[i]["grade"] as? Int else {
                        return
                    }
                    sum = sum + Double(grade)
                    count = count + 1
                }
                rating = sum/count
                self.database.child("Users/\(safeEmail)/rating").setValue(rating)
            }
        })
    }
    
    public func insertLocation(with email: String, latitude: Double, longitude: Double) {
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        database.child("Users/\(safeEmail)/latitude").observeSingleEvent(of: .value, with: { snapshot in
            self.database.child("Users/\(safeEmail)/latitude").setValue(latitude)
        })
        database.child("Users/\(safeEmail)/longitude").observeSingleEvent(of: .value, with: { snapshot in
            self.database.child("Users/\(safeEmail)/longitude").setValue(longitude)
        })
    }
    
    public func getName(with email: String) -> String {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        var name:String = ""
        Database.database().reference().child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any],
            let fullName = value["fullName"] as? String else {
                return
            }
            name = fullName
        })
        return name
    }
    
    public func getRating(with email: String) -> Double {
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        var rating:Double = 0
        Database.database().reference().child("Users/\(safeEmail)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any],
            let userRating = value["rating"] as? Double else {
                return
            }
            rating = userRating
        })
        return rating
    }
    
}

struct AppUser {
    let fullName : String
    let email : String
    let phoneNumber : String
    let role : String
    var safeEmail : String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

