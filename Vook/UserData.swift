//
//  UserData.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/25/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import Foundation

class UserData: NSObject, NSCoding {
    
    var bookImage: UIImage?
    var bookTitle: String?
    var bookAuthor: String?
    var bookGenre: String?
    
    var bookObjectId: String?
    
//    static var DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendPathComponent("userData")
    
    init/*?*/(bookImage: UIImage, bookTitle: String, bookAuthor: String, bookGenre: String, bookObjectId: String) {
        
        self.bookImage = bookImage
        self.bookTitle = bookTitle
        self.bookAuthor = bookAuthor
        self.bookGenre = bookGenre
        self.bookObjectId = bookObjectId
        
//        if bookTitle.isEmpty {
//            
//            return nil
//        }
    }
    
    required convenience init?(coder decoder: NSCoder) {
        
        guard let bookImage = decoder.decodeObject(forKey: "bookImage") as? UIImage,
            let bookTitle = decoder.decodeObject(forKey: "bookTitle") as? String,
            let bookAuthor = decoder.decodeObject(forKey: "bookAuthor") as? String,
            let bookGenre = decoder.decodeObject(forKey: "bookGenre") as? String,
            let bookObjectId = decoder.decodeObject(forKey: "bookObjectId") as? String
            else { return nil }
        
        self.init(
            bookImage: bookImage,
            bookTitle: bookTitle,
            bookAuthor: bookAuthor,
            bookGenre: bookGenre,
            bookObjectId: bookObjectId
        )
    }
    
    func encode(with coder: NSCoder) {
        
        coder.encode(bookImage, forKey: "bookImage")
        coder.encode(bookTitle, forKey: "bookTitle")
        coder.encode(bookAuthor, forKey: "bookAuthor")
        coder.encode(bookGenre, forKey: "bookGenre")
        coder.encode(bookObjectId, forKey: "bookObjectId")
    }
    
}
