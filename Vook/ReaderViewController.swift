//
//  ReaderViewController.swift
//  Vook
//
//  Created by Jonathon Fishman on 1/17/17.
//  Copyright © 2017 VookClub. All rights reserved.
//

import UIKit

class ReaderViewController: UIViewController {
    
    @IBOutlet weak var bookReaderView: UIWebView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    
    let book = Book()
    let broadcast = Broadcast()
    
    var webReaderLink: String?
    var bookTitle: String?
    var bookAuthor: String?
    var bookGenre: String?
    var bookImageUrl: String?
    var bookImage: UIImage?
    
    var sentBroadcastUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton.isEnabled = true
        
        let url = URL (string: webReaderLink!)
        let requestObj = URLRequest(url: url!)
        bookReaderView.loadRequest(requestObj)
        
        navigationItem.title = bookTitle!
        navigationController!.navigationBar.topItem!.title = "Back"
    }
    
    @IBAction func onRecordButton(_ sender: UIBarButtonItem) {
        
        recordButton.isEnabled = false
        
        book.bookTitle = bookTitle!
        book.bookAuthor = bookAuthor!
        book.bookGenre = "Other"
    
        book.bookImageUrl = bookImageUrl!
        print("book.bookImageUrl = \(book.bookImageUrl)")
        let thumbnailURL = URL(string: book.bookImageUrl!)
        let thumbnailData = NSData(contentsOf: thumbnailURL!)
        bookImage = UIImage(data: thumbnailData as! Data) ?? #imageLiteral(resourceName: "defaultPhoto")
        
        broadcast.broadcastName = "New Chapeter \(Date().toString())"
        // save broadcastUrl
        let uuid = NSUUID().uuidString
        let name = "book_\(book.bookTitle!)_uuid_\(uuid)"
        broadcast.broadcastUrl = Utility.sharedInstance.removeSpecialCharsFromString(text: name)
        sentBroadcastUrl = broadcast.broadcastUrl!
        broadcast.liveBroadcast = true
        
        print("--------------------------------------------------\(book), \(bookImage), \(broadcast)")
        
        BackendlessManager.sharedInstance.saveBookAndBroadcastData(bookData: book, bookImage: bookImage!, broadcastData: broadcast,
                    
            completion: { book in
                                                                    
                print(book.objectId!)
                
                Utility.sharedInstance.writeUserDataToArchiver(bookObjectId: book.objectId!, bookData: book, bookImage: self.bookImage!)
                                                                    
                self.performSegue(withIdentifier: "readerToLive", sender: sender)
                
                self.recordButton.isEnabled = true 
        }, error: {
            
            Utility.showAlert(viewController: self, title: "Input Error", message: "Broadcast data failed to save. Please check your internet connection and try again.")
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "readerToLive" {
            
            let destinationViewController = segue.destination as! GoLiveVC
            destinationViewController.bookTitle = bookTitle!
            destinationViewController.broadcastName = broadcast.broadcastName!
            destinationViewController.broadcastUrl = sentBroadcastUrl
            destinationViewController.webReader = webReaderLink!
        }
    }
    
}
