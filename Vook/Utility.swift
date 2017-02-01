//
//  Utility.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/27/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import Foundation

class Utility {
    
    // This gives access to the one and only instance.
    static let sharedInstance = Utility()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        
        imageCache.countLimit = 50 // sets cache limit to 50 images.
    }
    
    // Image Cache
    var imageCache = NSCache<NSString, UIImage>()
    
    // For live broadcasting and playback
    var isLive: Bool? = false
    
    // check if entered email is in the right format
    static func isValidEmail(emailAddress: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: emailAddress)
    }
    
    static func showAlert(viewController: UIViewController, title: String, message: String) {
        
        let alertController = UIAlertController(title: title,message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }
    
    
    func loadImageFromUrl(photoUrl: String, completion: @escaping (Data) -> (), loadError: @escaping () -> ()) {
        
        let url = URL(string: photoUrl)!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error == nil {
                
                do {
                    
                    let data = try Data(contentsOf: url, options: [])
                    
                    DispatchQueue.main.async {
                        
                        completion(data)
                    }
                    
                } catch {
                    print("NSData Error: \(error)")
                    
                    DispatchQueue.main.async {
                        loadError()
                    }
                }
                
            } else {
                print("NSURLSession Error: \(error)")
                
                DispatchQueue.main.async {
                    loadError()
                }
            }
        })
        
        task.resume()
    }
    
    // MARK: NSCoding
    
    func writeUserDataToArchiver(bookObjectId: String, bookData: Book, bookImage: UIImage) {
        
        let defaults = Foundation.UserDefaults.standard
        
        print("bookData.bookImage! = \(bookImage), bookData.bookTitle! = \(bookData.bookTitle), bookData.bookAuthor = \(bookData.bookAuthor), bookData.bookGenre = \(bookData.bookGenre), bookObjectId = \(bookObjectId)")
        
        let userBookDataToArchive = UserData(bookImage: bookImage, bookTitle: bookData.bookTitle!, bookAuthor: bookData.bookAuthor!, bookGenre: bookData.bookGenre!, bookObjectId: bookObjectId)
        
        let data = NSKeyedArchiver.archivedData(withRootObject: userBookDataToArchive)
        defaults.set(data, forKey: "USERDATA")
        
        defaults.synchronize()
    }
    
    func loadUserDataFromArchiver() -> (UserData?) {
    //func loadUserDataFromArchiver(completion: @escaping (UserData?) -> ()) {
        
        let defaults = Foundation.UserDefaults.standard
        
        if let data = defaults.object(forKey: "USERDATA") as? Data {
            
            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserData
            
//            bookImage.image = userData.bookImage!
//            bookImage.isUserInteractionEnabled = false
//            
//            bookTitleTextField.text = userData.bookTitle!
//            bookTitleTextField.isEnabled = false
//            
//            bookAuthorTextField.text = userData.bookAuthor!
//            bookAuthorTextField.isEnabled = false
//            
//            genreTextField.text = userData.bookGenre!
//            genreTextField.isEnabled = false
//            
//            self.bookId = userData.bookObjectId!
            return userData
        }
        return nil  
    }
    
    
    
    
}


extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd yyyy"
        return dateFormatter.string(from: self)
    }
}
