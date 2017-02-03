//
//  ProfileVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/7/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var watchLiveButton: UIButton!
    
    let blackoutView = UIView()
    
    var user: BackendlessUser?
    var currentUserProfileSelected = true
    let currentUser = Backendless.sharedInstance().userService.currentUser
    var books = [Book]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !currentUserProfileSelected {
            
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentUserProfileSelected = true
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        blackoutView.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // if profile tab selected and user not logged in
        // isUserLoggedIn might take a lot of memory
        if currentUserProfileSelected && BackendlessManager.sharedInstance.isUserLoggedIn() == false {
            
            blackoutView.frame = view.frame
            blackoutView.center = view.center
            blackoutView.backgroundColor = UIColor.black
            view.addSubview(blackoutView)
            
            let alertController = UIAlertController(title: "Please log in", message: "You need an account to view your profile. Please log in!", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                // self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "profileToMain", sender: self)
            }
            
            alertController.addAction(cancelAction)
            
            let signupAction = UIAlertAction(title: "OK", style: .default) { action in
                self.performSegue(withIdentifier: "profileToStart", sender: self)
            }
            
            alertController.addAction(signupAction)
            
            self.present(alertController, animated: true) {
                print("Show alert with buttons")
            }
        }
        // if NOT current user selected
        else if currentUserProfileSelected == false {
            
            if user?.getProperty("isLive") as! Bool == true {
                watchLiveButton.isHidden = false
            }
            
            navigationItem.title = user?.name! as String?
            
            descriptionTextView.text = user?.getProperty("desc") as? String
        
            if let photoUrl = user?.getProperty("photoUrl") as? String {
                
                if Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString) != nil {
                        
                        profileImage.image = Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString)
                        
                    } else {
                    
                        Utility.sharedInstance.loadImageFromUrl(photoUrl: photoUrl ,
                             
                            completion: { data in
                    
                                if let image = UIImage(data: data) {
                        
                                    self.profileImage.image = image
                                    Utility.sharedInstance.imageCache.setObject(image, forKey: photoUrl as NSString)
                                }
                            },
                             
                            loadError: {
                        })
                    }
                }
                refresh(sender: self, user: user!)
            
            }
            // if profile tab selected and user is logged in
        else {
            
            navigationItem.title = currentUser?.name! as String?
            
            descriptionTextView.text = currentUser?.getProperty("desc") as! String?
            
            if let photoUrl = currentUser?.getProperty("photoUrl") as? String {
                if Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString) != nil {
                    profileImage.image = Utility.sharedInstance.imageCache.object(forKey: photoUrl as NSString)
                } else {
                    Utility.sharedInstance.loadImageFromUrl(photoUrl: photoUrl, completion: {data in
                        if let image = UIImage(data: data) {
                            self.profileImage.image = image
                            Utility.sharedInstance.imageCache.setObject(image, forKey: photoUrl as NSString)}
                        },
                        loadError: {})
                    }
                }
            
//        else {
//            self.profileImage.image = #imageLiteral(resourceName: "defaultPhoto")
//        }
        refresh(sender: self, user: currentUser!)
        }
    }
    
    func refresh(sender: AnyObject, user: BackendlessUser) {
    
        BackendlessManager.sharedInstance.loadBooks(user: user,
                                                    
            completion: { books in
                
                self.books = books
                self.tableView.reloadData()
            },
            error: {
                
                self.tableView.reloadData()
        })
        
    }
    
    // MARK: UITableViewDataSource
    
    // Req. From UITableViewDataSource protocol.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books.count
    }
    
    // Req. From UITableViewDataSource protocol.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileCell
        
        let book = books[(indexPath as NSIndexPath).row]
        
        cell.bookTitleLabel.text = book.bookTitle
        cell.bookAuthorLabel.text = book.bookAuthor
        cell.bookGenreLabel.text = book.bookGenre
        
        let bookImageUrl = book.bookImageUrl! as String
        
        if Utility.sharedInstance.imageCache.object(forKey: bookImageUrl as NSString) != nil {
            
            cell.cellImage.image = Utility.sharedInstance.imageCache.object(forKey: bookImageUrl as NSString)
        } else {
        
            Utility.sharedInstance.loadImageFromUrl(photoUrl: book.bookImageUrl!,
                             
                 completion: { data in
                    
                    if let bookImage = UIImage(data: data) {
                        
                        cell.cellImage.image = bookImage
                        
                        Utility.sharedInstance.imageCache.setObject(bookImage, forKey: bookImageUrl as NSString)
                    }
                },
                 loadError: {
                
                    Utility.showAlert(viewController: self, title: "Load Error", message: "Could not load book data, please check your internet connection and try again.")
            })
        }
//        else {
//            
//            cell.cellImage.image = #imageLiteral(resourceName: "defaultPhoto")
//        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "profileToVideoList" {
            
            var selectedUser: BackendlessUser!
            
            if currentUserProfileSelected == true {
                selectedUser = currentUser!
            } else {
                selectedUser = user!
            }
            
            let videoListVC = segue.destination as! VideoListVC
            
            videoListVC.user = selectedUser
            
            if let selectedPlaybackCell = sender as? ProfileCell {
                
                let indexPath = tableView.indexPath(for: selectedPlaybackCell)!
                let selectedVideo = books[(indexPath as NSIndexPath).row]
                videoListVC.book = selectedVideo
            }
        } else if segue.identifier == "goToLive" {
            
            let playBackVC = segue.destination as! PlaybackVC
            
            playBackVC.user = user!
            // playBackVC.broadcast =
        }
    }    
    
    
    @IBAction func onEdit(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "editProfile", sender: sender)
    }
    
}
