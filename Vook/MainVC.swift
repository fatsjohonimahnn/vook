//
//  MainVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/27/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users = [BackendlessUser]()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.addSubview(self.refreshControl)
        
        refresh(sender: self)
    }
    
    func refresh(sender: AnyObject) {
        
        BackendlessManager.sharedInstance.loadUsers(
            
            completion: { userData in
                
                self.users = userData
                print("\(self.users.count)")
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            },
            
            error: {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Req. From UITableViewDataSource protocol.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    // Req. From UITableViewDataSource protocol.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "broadcasterCell", for: indexPath) as! BroadcasterCell
        
        let user = users[(indexPath as NSIndexPath).row]
        
        cell.userNickName.text = user.name as String?
        cell.userDescription.text = user.getProperty("desc") as! String?
        
        if user.getProperty("isLive") as? Bool! == true {
            
            cell.isLiveLabel.isHidden = false 
        }
        
        //print("User name is: \"\(user.name!)\" User photoUrl is: \"\(user.getProperty("photoUrl")!)\"")
        
        if user.getProperty("photoUrl") as? NSString != nil {
            
            let photoUrl = user.getProperty("photoUrl") as! String
            print("photoUrl was found")
            
// ImageCache 1/3
            if Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString) != nil {
                
// ImageCache 2/3
                cell.profileImage.image = Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString)
                
            } else {
                
                cell.spinner.startAnimating()
                
                Utility.sharedInstance.loadImageFromUrl(photoUrl: photoUrl ,
                                                        
                    completion: { data in
                                                            
                        if let image = UIImage(data: data) {
                                                                
                            cell.profileImage.image = image
// ImageCache 3/3
                            Utility.sharedInstance.imageCache.setObject(image, forKey: photoUrl as NSString)
                        }
                                                            
                        cell.spinner.stopAnimating()
                    },
                                                        
                    loadError: {
                        cell.spinner.stopAnimating()
                })
            }

        } else {
            cell.profileImage.image = #imageLiteral(resourceName: "defaultPhoto")
        }
       
        return cell
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let broadcasterDetailViewController = segue.destination as! ProfileVC
        
        if let selectedBroadcasterCell = sender as? BroadcasterCell {
            
            let indexPath = tableView.indexPath(for: selectedBroadcasterCell)!
            let selectedBroadcaster = users[(indexPath as NSIndexPath).row]
            
            broadcasterDetailViewController.user = selectedBroadcaster
            broadcasterDetailViewController.currentUserProfileSelected = false 
        }
    }



}
