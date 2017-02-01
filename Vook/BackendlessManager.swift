//
//  BackendlessManager.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/22/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import Foundation

// The BackendlessManager class below is using the Singleton pattern.
// A singleton class is a class which can be instantiated only once.
// In other words, only one instance of this class can ever exist.
// The benefit of a Singleton is that its state and functionality are
// easily accessible to any other object in the project.

class BackendlessManager {
    
    // This gives access to the one and only instance.
    static let sharedInstance = BackendlessManager()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}
    
    
    let backendless = Backendless.sharedInstance()!
    
    let VERSION_NUM = "v1"
    let APP_ID = "6FE87D2C-6FD7-04CF-FF06-5BD01C27C400"
    let SECRET_KEY = "9910A11A-B9B6-A8EB-FFED-B51DBE033200"
    
    var name: String?
    var photoUrl: String?
    
    
    func initApp() {
        
        backendless.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        backendless.userService.setStayLoggedIn(true)

        backendless.setThrowException(false)
        backendless.hostURL = "https://api.backendless.com"
        backendless.mediaService = MediaService()
    }
    
    // MARK: User Registration
    
    func isUserLoggedIn() -> Bool {
        
        let isValidUser = backendless.userService.isValidUserToken()
        
        if isValidUser != nil && isValidUser != 0 {
            return true
        } else {
            return false
        }
    }
    
    func registerUser(email: String, password: String, name: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        let user: BackendlessUser = BackendlessUser()
        user.email = email as NSString!
        user.password = password as NSString!
        user.name = name as NSString!
        
        backendless.userService.registering( user,
                                             
             response: { (user: BackendlessUser?) -> Void in
                
                print("User was registered: \((user?.objectId!)!)")
                completion()
            },
                                             
             error: { (fault: Fault?) -> Void in
                print("User failed to register: \(fault)")
                error((fault?.message)!)
            }
        )
    }
    
    func loginUser(email: String, password: String, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        backendless.userService.login( email, password: password,
                                       
               response: { (user: BackendlessUser?) -> Void in
                print("User logged in: \(user!.objectId!)")
                completion()
            },
                                       
               error: { (fault: Fault?) -> Void in
                print("User failed to login: \(fault)")
                error((fault?.message)!)
        })
    }
    
    func logoutUser(completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        // First, check if the user is actually logged in.
        if isUserLoggedIn() {
            
            // If they are currently logged in - go ahead and log them out!
            backendless.userService.logout( { (user: Any!) -> Void in
                print("User logged out!")
                completion()
                },
                                            
                error: { (fault: Fault?) -> Void in
                    print("User failed to log out: \(fault)")
                    error((fault?.message)!)
            })
            
        } else {
            
            print("User is already logged out!");
            completion()
        }
    }
    
    // check DB to see if userName already taken, the completion when called returns a Bool, the error returns a String
    func isValidUserName(name: String, completion: @escaping (Bool) -> (), error: @escaping () -> ()) {
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        // limit query to just BackendlessUser names
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "name = '\(name)'"
        
        // Find all BackendlessUsers where the name is greater than 0, that means its already used!
        dataStore?.find( dataQuery,
                         
            response: { (users : BackendlessCollection?) -> () in
                
                print("Number of Users found with name: \(name) = \((users?.data.count)!)")

                if (users?.data.count)! > 0 {
                    completion(false)
                } else {
                    completion(true)
                }
            },
            error: { (fault : Fault?) -> () in
                print("Server reported an error (ASYNC): \(fault)")
                error()
            }
        )
    }
    
    
    // save user data from profile, only saves name
    func updateUser(name: String, desc: String, isLive: Bool, completion: @escaping () -> (), error: @escaping (String) -> ()) {
        
        if let currentUser = backendless.userService.currentUser {
            
            currentUser.setProperty("name", object: name);
            currentUser.setProperty("desc", object: desc);
            currentUser.setProperty("isLive", object: isLive);
            
            backendless.userService.update( currentUser,
                                          
                response: { (user: BackendlessUser?) -> Void in

                    print("User has been updated: ObjectId: \((user?.objectId)!), name: \((user?.name)!), email: \((user?.email)!), desc: \(user?.getProperty("desc"))")
                    completion()
            
                },
                
                error: { ( fault: Fault?) -> Void in
                    print("Failed to update user: \(fault)")
                    error((fault!.message)!)
              })
        }
    }
    
    func updateLiveStatus(isLive: Bool, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        if let currentUser = backendless.userService.currentUser {
            
            currentUser.setProperty("isLive", object: isLive);
            
            backendless.userService.update( currentUser,
               
                response: { (user: BackendlessUser?) -> Void in
                                                
                    print("User is now live: \(user?.getProperty("isLive"))")
                    completion()
                                                
                },
                                            
                error: { ( fault: Fault?) -> Void in
                    print("Failed to update user: \(fault)")
                    error()
            })
        }
    }
    
    // shrink and upload profile photo
    func saveProfilePhoto(photo: UIImage, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        let uuid = NSUUID().uuidString
        //print("\(uuid)")

// Need better way to Create the thumbnail with CROPPING
        let size = photo.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.1

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        photo.draw(in: CGRect(origin: CGPoint.zero, size: size))

        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0);

        backendless.fileService.upload(
            "photos/\(backendless.userService.currentUser.objectId!)/thumb_\(uuid).jpg",
            content: thumbnailData,
            overwrite: true,

            // response closure for success in BE
            response: { (uploadedFile: BackendlessFile?) -> Void in
                print("Thmbnail image uploaded: \((uploadedFile?.fileURL!)!)")
                
                // Update User with url.
                
                if let currentUser = self.backendless.userService.currentUser {
                
                    // add properties to BackendlessUser class:
                    currentUser.setProperty("photoUrl", object: uploadedFile?.fileURL!)

                    self.backendless.userService.update( currentUser,
                                                  
                        response: { (user: BackendlessUser?) -> Void in

                            print("User has been updated: ObjectId: \((user?.objectId)!), name: \((user?.name)!), email: \((user?.email)!)")
                            completion()
                        },
                        
                        error: { ( fault: Fault?) -> Void in
                            print("Failed to update user: \(fault)")
                            error()
                      })
                }
                
                completion()
            },

            error: { (fault: Fault?) -> Void in
                print("Failed to save thumbnail: \(fault)")
                error()
        })
    }
    
    func removePhoto(photoUrl: String, completion: @escaping () -> (), error: @escaping () -> ()) {
            
        // Get just the file name which is everything after "/files/".
        // In BE, we can't remove files by its full URL name, need to do it this way
        let photoFile = photoUrl.components(separatedBy: "/files/").last
        
        // talking to file service not the other one
        backendless.fileService.remove( photoFile,
                                        
            response: { (result: Any!) -> () in
                print("Photo has been removed: result = \(result)")
                completion()
            },
                                            
            error: { (fault : Fault?) -> () in
                print("Failed to remove photo: \(fault)")
                error()
            }
        )
    }
    
    // shrink and upload profile photo
    func saveBookImage(bookToSave: Book, photo: UIImage, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        let uuid = NSUUID().uuidString
        //print("\(uuid)")

//TODO: Need better way to Create the thumbnail with CROPPING
        let size = photo.size.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        let hasAlpha = false
        let scale: CGFloat = 0.1

        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        photo.draw(in: CGRect(origin: CGPoint.zero, size: size))

        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let thumbnailData = UIImageJPEGRepresentation(thumbnailImage!, 1.0);

        backendless.fileService.upload(
            "bookImages/\(backendless.userService.currentUser.objectId!)/thumb_\(uuid).jpg",
            content: thumbnailData,
            overwrite: true,

            // response closure for success in BE
            response: { (uploadedFile: BackendlessFile?) -> Void in
                print("Thmbnail image uploaded: \((uploadedFile?.fileURL!)!)")
                
                // Update Video class with url.
                
                bookToSave.bookImageUrl = uploadedFile?.fileURL!
                
                completion()
            },
                        
            error: { ( fault: Fault?) -> Void in
                print("Failed to update video: \(fault)")
                error()
        })
    }
    
    
    func saveBookAndBroadcastData(bookData: Book, bookImage: UIImage, broadcastData: Broadcast, completion: @escaping (Book) -> (), error: @escaping () -> ()) {
        
        let bookToSave = Book()
        bookToSave.bookTitle = bookData.bookTitle
        bookToSave.bookAuthor = bookData.bookAuthor
        bookToSave.bookGenre = bookData.bookGenre
        
        let broadcastToSave = Broadcast()
        
        broadcastToSave.broadcastName = broadcastData.broadcastName
        broadcastToSave.broadcastUrl = broadcastData.broadcastUrl!
        broadcastToSave.isDiscussion = broadcastData.isDiscussion
        broadcastToSave.liveBroadcast = broadcastData.liveBroadcast 
        
        saveBookImage(bookToSave: bookToSave, photo: bookImage,
                      
            completion: {
        
                self.backendless.data.save ( bookToSave,
                                
                    response: { (entity: Any?) -> Void in
                                    
                        let book = entity as! Book
                                    
                        print("Book was saved: \(book.objectId), bookTitle: \(book.bookTitle), bookAuthor: \(book.bookAuthor), bookGenre: \(book.bookGenre)")
                        
                        bookData.bookImageUrl = book.bookImageUrl
                        print("photoUrl: \(book.bookImageUrl!)")
                        
                        broadcastToSave.bookId = book.objectId!
                        
                        self.backendless.data.save ( broadcastToSave,
                                
                            response: { (entity: Any?) -> Void in
                                    
                                let broadcastData = entity as! Broadcast
                                    
                                print("broadcastData was saved: \(broadcastData.objectId), broadcastName: \(broadcastData.broadcastName), broadcastUrl: \(broadcastData.broadcastUrl), isDiscussion: \(broadcastData.isDiscussion), bookId: \(broadcastData.bookId)")
                
                                completion(book)
                            },
                                
                            error: { (fault: Fault?) -> Void in
                                    
                                print("BroadcastData failed to save: \(fault)")
                                error()
                        })
                    },
                                
                    error: { (fault: Fault?) -> Void in
                                    
                        print("BookData failed to save: \(fault)")
                        error()
                })
            },
            error: { ()
                                
        })
    }

    // On VideoInfoVC when a user saves a broadcast to an already made book
    func saveBroadcastData(broadcastData: Broadcast, bookObjectID: String, completion: @escaping () -> (), error: @escaping () -> () ) {

        broadcastData.bookId = bookObjectID 

        backendless.data.save ( broadcastData,

            response: { (entity: Any?) -> Void in

                let broadcastData = entity as! Broadcast

                print("bookId: \(broadcastData.bookId!)")

                completion()
            },

            error: { (fault: Fault?) -> Void in

                print("BroadcastData failed to save: \(fault)")
                error()
        })
    }
    

    func updateBroadcastInfo(broadcastUrl: String, completion: @escaping () -> (), error: @escaping () -> ()) {
        
        let dataStore = self.backendless.data.of(Broadcast.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "broadcastUrl = '\(broadcastUrl)'"
        
        dataStore?.find( dataQuery,
        
            response: { (broadcasts: BackendlessCollection?) -> Void in
                
                print("Number of broadcasts found = \((broadcasts?.data.count)!)")
                
                if (broadcasts?.data.count)! > 0 {
                    
                    for broadcast in (broadcasts?.data)! {
                        
                        let broadcast = broadcast as! Broadcast
                        
                        print("Broadcast: \(broadcast.objectId), liveBroadcast: \"\(broadcast.liveBroadcast)\"")
                        
                        // Update or change the data for each broadcast we found.
                        broadcast.liveBroadcast = false
                        
                        self.backendless.data.save( broadcast,
                                                    
                            response: { (entity: Any?) -> Void in
                                
                                let broadcast = entity as! Broadcast
                                
                                print("Broadcast: \(broadcast.objectId), liveBroadcast: \"\(broadcast.liveBroadcast)\"")
                            },
                            
                            error: { (fault: Fault?) -> Void in
                                print("Broadcast failed to save: \(fault)")
                            }
                        )
                    }
                    
                } else {
                    print("No Broadcasts were fetched using the whereClause '\(dataQuery.whereClause)'")
                }
            },
         
            error: { ( fault: Fault?) -> Void in
                print("Broadcasts were not fetched: \(fault)")
            }
        )

        
    
    
    }



    
    func loadBroadcasts(bookId: String, completion: @escaping([Broadcast]) -> (), error: @escaping () -> ()) {
        
        let dataStore = backendless.persistenceService.of(Broadcast.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "bookId = '\(bookId)'"
        
        dataStore?.find( dataQuery,
            
            response: { (broadcasts: BackendlessCollection?) -> Void in
                
                print("Find attempt on all Videos has completed without error!")
                print("Number of Videos found = \((broadcasts?.data.count)!)")
                
                var broadcastData = [Broadcast]()
                
                for broadcast in (broadcasts?.data)! {
                    
                    let broadcast = broadcast as! Broadcast
                    
                    print("ID: \(broadcast.objectId!), broadcastName: \(broadcast.broadcastName!), broadcastUrl: \"\(broadcast.broadcastUrl!)\"")
                    
                   // let newVideoData = Video(videoName: video.videoName!, videoUrl: video.videoUrl!)
                    
                    broadcastData.append(broadcast)
                    
                }
                completion(broadcastData)
            },
            
            error: { (fault: Fault?) -> Void in
                print("Videos were not fetched: \(fault)")
                error()
            }
        )
    }
    
    func loadUsers(completion: @escaping([BackendlessUser]) -> (), error: @escaping () -> ()) {
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore?.find(
            
            { (users: BackendlessCollection?) -> Void in
                
                print("Find attempt on all Users has completed without error!")
                print("Number of Users found = \((users?.data.count)!)")
                
                var userData = [BackendlessUser]()
                                
                for user in (users?.data)! {
                    
                    // checks every user, to collect every instance of a user in BE, we create the user, photo set to nil for now
                    
                    let user = user as! BackendlessUser
                    
                    print("User: \(user.objectId!), user name: \(user.name!), profileUrl: \"\(user.getProperty(("photoUrl")))")
                    
                    userData.append(user)
                }
                
                completion(userData)
            },
            
            error: { (fault: Fault?) -> Void in
                print("Users were not fetched: \(fault)")
                
                error()
            }
        )
    }
    
    // Found on PopUpVC and BroadcasterProfileVC and ProfileVC
    func loadBooks(user: BackendlessUser, completion: @escaping ([Book]) -> (), error: @escaping () -> ()) {
        
        let selectedUser = user.objectId
        
        let dataStore = backendless.persistenceService.of(Book.ofClass())
        
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = "ownerId = '\(selectedUser!)'"
        
        dataStore?.find( dataQuery,

            response: { (books: BackendlessCollection?) -> Void in
            
            print("Find attempt on ALL Books has completed without error!")
            print("Number of Books found = \((books?.data.count)!)")
            
            var bookData = [Book]()
            
            for book in (books?.data)! {
                
                let book = book as! Book
                                
                print("Book: \(book.objectId!), bookTitle: \(book.bookTitle!), bookAuthor: \(book.bookAuthor!), bookGenre: \(book.bookGenre!)")
                print("bookImageUrl: \(book.bookImageUrl)")
                
                bookData.append(book)
            }
            
            completion(bookData)
        },
                         
        error: { (fault: Fault?) -> Void in
            print("Failed to find Meal: \(fault)")
        })
    }
}
    
//    func saveBookData(bookTitle: String, bookAuthor: String, bookGenre: String, completion: @escaping () -> (), error: @escaping () -> ()) {
//
//        let bookData = Book()
//        bookData.bookTitle = bookTitle
//        bookData.bookAuthor = bookAuthor
//        bookData.bookGenre = bookGenre
//
//        backendless.data.save ( bookData,
//
//            response: { (entity: Any?) -> Void in
//
//                let bookData = entity as! Book
//
//                print("Book was saved: \(bookData.objectId!), bookTitle: \(bookData.bookTitle!), bookAuthor: \(bookData.bookAuthor!), bookGenre: \(bookData.bookGenre!)")
//
//                completion()
//            },
//
//            error: { (fault: Fault?) -> Void in
//
//                print("BookData failed to save: \(fault)")
//                error()
//        })
//    }
//


    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

