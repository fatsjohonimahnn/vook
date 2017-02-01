//
//  BrowseBooksViewController.swift
//  Vook
//
//  Created by Jonathon Fishman on 1/17/17.
//  Copyright © 2017 VookClub. All rights reserved.
//

import UIKit
import Alamofire

class BrowseBooksViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewFooter: UIView!
    
    struct BookData {
        
        var thumbnailImageUrl: String
        var thumbnailImage: UIImage
        var title: String
        var author: String
        var webReaderLink: String
    }
    
    var bookDataArray = [BookData]()
    
    var searchBarUsed = false
    var searchURL = String()
    var keywords = String()
    var usableKeywords = String()
    var canFetchMoreResults = true
    
    typealias JSONFormat = [String : AnyObject]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewFooter.isHidden = true
        
        loadJSONData(url: "https://www.googleapis.com/books/v1/users/101089241479878209791/bookshelves/0/volumes?&startIndex=0&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8")
        
        // free ebooks and return 20 with start index at 0
        // "https://www.googleapis.com/books/v1/volumes?q=\(testSearch)&filter=free-ebooks&startIndex=0&maxResults=20&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        // works key, free ebooks
        //"https://www.googleapis.com/books/v1/volumes?q=\(testSearch)&filter=free-ebooks&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        // &filter=free-ebooks (samples included)
        // &filter=full (all text is viewable)
        // "https://www.googleapis.com/books/v1/volumes?q=\(testSearch)&filter=free-ebooks&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        //works with key
        // "https://www.googleapis.com/books/v1/volumes?q=\(testSearch)&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        
        // &uid=101089241479878209791
        // &key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8
        
        // "https://www.googleapis.com/books/v1/volumes?q=alice+in+wonderland"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        canFetchMoreResults = true
        
        searchBarUsed = true
        
        keywords = searchBar.text!
        usableKeywords = keywords.replacingOccurrences(of: " ", with: "+")
        let startIndex = 0
        
        bookDataArray = []
        
        searchURL = "https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords)&filter=free-ebooks&startIndex=\(startIndex)&maxResults=10&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        
        //"https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords!)"
        
        //print("-----------------------------------------------searchURL = \(searchURL)")
        
        loadJSONData(url: searchURL)
        
        self.view.endEditing(true)
    }
    
    func loadJSONData(url: String) {
        
        Alamofire.request(url).responseJSON(completionHandler: { response in
            
            self.parseData(JSONData: response.data!)
            
            self.tableView.reloadData()
        })
    }
    
    func parseData(JSONData: Data) {
        
        do {
            // serialize incoming JSON Data
            var readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONFormat
            print(readableJSON)
            
            if let items = readableJSON["items"] as? [JSONFormat] {
                
                for i in 0..<items.count {
                    
                    let item = items[i]
                    //print("item = \(item)")
                    
                    if let volumeInfo = item["volumeInfo"] as? JSONFormat {
                        
                        let title = volumeInfo["title"] as! String
                        let authors = volumeInfo["authors"] as? NSArray ?? ["Unavailable"]
                        let author = authors[0]
                        
                        if let imageLinks = volumeInfo["imageLinks"] as? JSONFormat {
                            
                            let thumbnailJSONData = imageLinks["thumbnail"] as! String
                            let thumbnailURL = URL(string: thumbnailJSONData)
                            let thumbnailData = NSData(contentsOf: thumbnailURL!)
                            let thumbnailImage = UIImage(data: thumbnailData as! Data) ?? #imageLiteral(resourceName: "defaultPhoto")
                            
                            if let accessInfo = item["accessInfo"] as? JSONFormat {
                                
                                let webReaderLink = accessInfo["webReaderLink"] as! String
                                
                                self.bookDataArray.append(BookData(thumbnailImageUrl: thumbnailJSONData, thumbnailImage: thumbnailImage, title: title, author: author as! String, webReaderLink: webReaderLink))
                                
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
        catch{
            print("error = \(error)")
        }
    }
    
    func loadSegment(keywords: String, startIndex: Int) {
        
        //print("-------------------------------------------------------------searchBarUsed = \(searchBarUsed)")
        
        if searchBarUsed {
            
            searchURL = "https://www.googleapis.com/books/v1/volumes?q=\(usableKeywords)&filter=free-ebooks&startIndex=\(startIndex)&maxResults=10&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
            
        } else {
            
            searchURL = "https://www.googleapis.com/books/v1/users/101089241479878209791/bookshelves/0/volumes?&startIndex=\(startIndex)&maxResults=10&key=AIzaSyB1hSCoyaC086Y0VvlYxxHiH89oS3Dg9V8"
        }
        
        //print("---------------------------------------------------------nextSegmentURL = \(searchURL)")
        
        if canFetchMoreResults {
            
            self.loadJSONData(url: self.searchURL)
            
            self.canFetchMoreResults = !(self.bookDataArray.count > 40)
            //print("canFetchMoreResults = \(self.canFetchMoreResults)")
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        self.tableViewFooter?.isHidden = true
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        print("------------------------------------------------------------------deltaOffset = \(maximumOffset - currentOffset)")
        
        if maximumOffset - currentOffset < -100 && canFetchMoreResults {
            
            self.tableViewFooter?.isHidden = false
            
            loadSegment(keywords: keywords, startIndex: bookDataArray.count)
            
        }
        else {
            
            self.tableViewFooter?.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        self.tableViewFooter?.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return bookDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookTableViewCell", for: indexPath) as! BookTableViewCell
        
        cell.bookCoverImage.image = bookDataArray[indexPath.row].thumbnailImage
        cell.bookTitleLabel.text = bookDataArray[indexPath.row].title
        cell.bookAuthorLabel.text! = bookDataArray[indexPath.row].author
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = self.tableView.indexPathForSelectedRow?.row
        
        let destinationViewController = segue.destination as! ReaderViewController
        destinationViewController.webReaderLink = bookDataArray[indexPath!].webReaderLink
        destinationViewController.bookTitle = bookDataArray[indexPath!].title
        destinationViewController.bookAuthor = bookDataArray[indexPath!].author
        destinationViewController.bookImageUrl = bookDataArray[indexPath!].thumbnailImageUrl
    }
}
