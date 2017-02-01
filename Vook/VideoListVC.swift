//
//  VideoListVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/21/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class VideoListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookGenreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var book: Book?
    var user: BackendlessUser?
    var broadcasts = [Broadcast]()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = user?.name! as String?
        
        print(user?.getProperty("isLive") as! Bool)
        
        bookTitleLabel.text = book?.bookTitle!
        bookAuthorLabel.text = book?.bookAuthor!
        bookGenreLabel.text = book?.bookGenre!
        
        if let bookImage = book?.bookImageUrl! {
            bookImageView.image = UIImage(named: bookImage)
        } else {
            bookImageView.image = #imageLiteral(resourceName: "defaultPhoto")
        }
        
        refresh(sender: self)
        
        Utility.sharedInstance.loadImageFromUrl(photoUrl: (book?.bookImageUrl!)!,
                                                
            completion: { data in
            
                if let image = UIImage(data: data) {
            
                    self.bookImageView.image = image
                }
            },
    
            loadError: {
        })
    }

    func refresh(sender: AnyObject) {
    
        BackendlessManager.sharedInstance.loadBroadcasts(bookId: (book?.objectId!)!,
                                                         
            completion: { broadcasts in
                
                self.broadcasts = broadcasts
                self.tableView.reloadData()
            },
            error: {
                
                self.tableView.reloadData()
        })
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return broadcasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoListCell", for: indexPath) as! VideoListCell
        
        let broadcast = broadcasts[(indexPath as NSIndexPath).row]
        
        cell.broadcastNameLabel.text = broadcast.broadcastName
        
        if user?.getProperty("isLive") as? Bool == true {
            
            print("Need to add a live label")
        }
        
        if user?.getProperty("photoUrl") as? NSString != nil {
            
            let photoUrl = user?.getProperty("photoUrl") as! String
            print("\(photoUrl)")
        
//        if user?.getProperty("photoUrl") != nil  {
            
            Utility.sharedInstance.loadImageFromUrl(photoUrl: photoUrl,
                                                    
                completion: { data in
                    
                    if let userImage = UIImage(data: data) {
                        
                        cell.broadcasterImageView.image = userImage
                        
                    }
                
                },
                loadError: {
                    
                    Utility.showAlert(viewController: self, title: "Load Error", message: "Could not load book data, please check your internet connection and try again.")
            })
        } else {
            
            cell.broadcasterImageView.image = #imageLiteral(resourceName: "defaultPhoto")
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let playbackDetailViewController = segue.destination as! PlaybackVC
        
        playbackDetailViewController.user = user!
        
        if let selectedBroadcastCell = sender as? VideoListCell {
            
            let indexPath = tableView.indexPath(for: selectedBroadcastCell)!
            let selectedBroadcast = broadcasts[(indexPath as NSIndexPath).row]
            
            playbackDetailViewController.broadcast = selectedBroadcast
        }
    }

}
