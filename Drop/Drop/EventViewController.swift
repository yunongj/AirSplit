//
//  EventViewController.swift
//  Drop
//
//  Created by Camille Zhang on 10/22/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    let itemCellIdentifier = "ItemCell"
    let participantPopIdentifier = "ParticipantPopCell"
    var people = [String]()
    
    @IBOutlet weak var PeopleCollectionView: UICollectionView!
    @IBOutlet weak var ItemCollectionView: UICollectionView!
    
    private var appDelegate : AppDelegate
    private var multipeer : MultipeerManager
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.multipeer = appDelegate.multipeer
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.people.removeAll()
        self.multipeer.delegate = self
        self.multipeer.startBrowsing()
        print("will load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.people.removeAll()
        self.performSegue(withIdentifier: "unwindToHome", sender: self)
    }
}

//related to Collection view
extension EventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.PeopleCollectionView {
            return self.people.count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.PeopleCollectionView {
            print("create cell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: participantPopIdentifier, for: indexPath) as! PeopleCollectionViewCell
            if indexPath.row < self.people.count {
                cell.accountImageView.image = #imageLiteral(resourceName: "icons8-User Male-48")
                cell.accountName.text = self.people[indexPath.row]
            }
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: participantPopIdentifier, for: indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension EventViewController : MultipeerManagerDelegate {
    func deviceDetection(manager : MultipeerManager, detectedDevice: String) {
        if self.people.contains(detectedDevice) {
            return
        }
        self.people.append(detectedDevice)
        self.PeopleCollectionView.reloadData()
    }
    
    func loseDevice(manager : MultipeerManager, removedDevice: String) {
        if let index = self.people.index(of: removedDevice) {
            self.people.remove(at: index)
        }
        self.PeopleCollectionView.reloadData()
    }
}
