//
//  AppDelegate.swift
//  Drop
//
//  Created by Camille Zhang on 10/18/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let multipeer = MultipeerManager()
    var people = [String]()
    var items = [[String]]()
    var myOwnName = ""
    var transactionDictionary = [String: [Transaction]]()
    
    var window: UIWindow?
    
    var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    var loginViewController: LoginViewController?
    var tabBarController: UITabBarController?
    var ref: DatabaseReference!
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("home clicked")
        self.people.removeAll()
        multipeer.delegate?.loseDevice(manager: multipeer, removedDevice: "anything")
        self.people.append(myOwnName)
    }
    
    /**
     Initializes app and set up AWS logger and AWS Cognito. Tells the delegate that the launch process is almost done and the app is almost ready to run.
     
     - Parameter application: A singleton app object.
     - Parameter launchOptions: A dictionary indicating the reason the app was launched.
     
     - Returns: false if the app cannot handle the URL resource or continue a user activity, otherwise return true. The return value is ignored if the app is launched as a result of a remote notification.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        ref = Database.database().reference()
        findAllRelatedTransactions()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     sourceApplication: String?, annotation: Any) -> Bool {
        return true
    }
    
    func findAllRelatedTransactions() {
        transactionDictionary = [String: [Transaction]]()
        
        let queryByBorrower = ref.child("transactions").queryOrdered(byChild: "borrower").queryEqual(toValue: myOwnName)
        
        let queryByLender = ref.child("transactions").queryOrdered(byChild: "lender").queryEqual(toValue: myOwnName)
        
        queryByBorrower.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                print("snapshot name: " + childSnapshot.key)
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "incomplete") {
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        if (!self.people.contains(transaction.lender)) {
                            self.people.append(transaction.lender)
                            self.transactionDictionary[transaction.lender] = [Transaction]()
                            self.transactionDictionary[transaction.lender]?.append(transaction)
                            print(self.transactionDictionary[transaction.lender]!)
                            print(self.people)
                        } else {
                            self.transactionDictionary[transaction.lender]?.append(transaction)
                        }
                        DispatchQueue.main.async {
                            self.people.sort(by: {$0 < $1})
                        }
                    }
                }
            }
        })
        
        queryByLender.observeSingleEvent(of: .value, with: { (snapshot) in
            for case let childSnapshot as DataSnapshot in snapshot.children {
                if let data = childSnapshot.value as? [String: Any] {
                    if (data["status"] as! String == "incomplete") {
                        let transaction = Transaction(transactionName: childSnapshot.key, amount: data["amount"]! as! Double, borrower: "\(data["borrower"]!)", lender: "\(data["lender"]!)", timestamp: data["timestamp"]! as! Int, status: "incomplete", itemName: data["itemName"] as! String)
                        print(transaction)
                        print("transactionName = " + childSnapshot.key)
                        print("amount = \(transaction.amount)")
                        print("borrower = \(transaction.borrower)")
                        print("lender = \(transaction.lender)")
                        print("timestamp = \(transaction.timestamp)")
                        print("itemName = " + transaction.itemName)
                        if (!self.people.contains(transaction.borrower)) {
                            self.people.append(transaction.borrower)
                            self.transactionDictionary[transaction.borrower] = [Transaction]()
                            self.transactionDictionary[transaction.borrower]?.append(transaction)
                            print(self.transactionDictionary[transaction.borrower]!)
                            print(self.people)
                        } else {
                            self.transactionDictionary[transaction.borrower]?.append(transaction)
                        }
                        DispatchQueue.main.async {
                            self.people.sort(by: {$0 < $1})
                        }
                    }
                }
            }
        })
    }
}
