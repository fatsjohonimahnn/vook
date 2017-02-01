//
//  VideoInfoVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/17/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class VideoInfoVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var isDiscussionSegmentControl: UISegmentedControl!
    @IBOutlet weak var bookTitleTextField: UITextField!
    @IBOutlet weak var bookAuthorTextField: UITextField!
    @IBOutlet weak var broadcastNameTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var genrePicker: UIPickerView!
    @IBOutlet weak var myBooksButton: UIButton!
    @IBOutlet weak var browseBooksButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // For UserDefaults
    var bookId: String?
    
    let book = Book()
    let broadcast = Broadcast()
    
    var myBooksPressed = false
    
    weak var activeField: UITextField?
    
    var sentBroadcastUrl: String?
    var incomingBookData: Book?
    
    var isDiscussion = false
    var pickerGenres = ["Biography",
                        "Business",
                        "Food",
                        "Healthy Living",
                        "Fiction",
                        "Graphic Novels & Comics",
                        "History",
                        "Mystery & Crime",
                        "Other",
                        "Religion",
                        "Romance",
                        "Science Fiction & Fantasy",
                        "Self-Help & Relationships" ]
    var genre: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshVC(sender: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        activeField?.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if BackendlessManager.sharedInstance.isUserLoggedIn() == false {
            
            let alertController = UIAlertController(title: "Please log in",
                                                    message: "Going live is for members only. Please log in or sign up!",
                                                    preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                self.performSegue(withIdentifier: "videoInfoToMain", sender: self)
            }
            
            alertController.addAction(cancelAction)
            
            let signUpAction = UIAlertAction(title: "OK", style: .default) { action in
                self.performSegue(withIdentifier: "videoInfoToStart", sender: self)
            }
            
            alertController.addAction(signUpAction)
            
            self.present(alertController, animated: true) {
                print("Show the Alert with Buttons!")
            }
        }
        else {
            
            if let userData = Utility.sharedInstance.loadUserDataFromArchiver() {
                //Utility.sharedInstance.loadUserDataFromArchiver(completion: { userData in
                
                self.bookImage.image = userData.bookImage!
                self.bookImage.isUserInteractionEnabled = false
                self.bookTitleTextField.text = userData.bookTitle!
                self.bookTitleTextField.isEnabled = false
                self.bookAuthorTextField.text = userData.bookAuthor!
                self.bookAuthorTextField.isEnabled = false

                self.genreTextField.text = userData.bookGenre!
                self.genreTextField.isEnabled = false

                self.bookId = userData.bookObjectId!
                //loadUserDataFromArchiver()
                //print(bookId)
            
            
            }


            if bookTitleTextField.isEnabled {
                clearButton.isEnabled = false
            } else {
                clearButton.isEnabled = true
            }
            
            saveButton.isEnabled = false
            
            genrePicker.selectRow(8, inComponent: 0, animated: true)
            
            bookTitleTextField.addTarget(self, action: #selector(changeInInputs(textField:)), for: .editingChanged)
            bookAuthorTextField.addTarget(self, action: #selector(changeInInputs(textField:)), for: .editingChanged)
            broadcastNameTextField.addTarget(self, action: #selector(changeInInputs(textField:)), for: .editingChanged)

            NotificationCenter.default.addObserver(self, selector: #selector(VideoInfoVC.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(VideoInfoVC.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    deinit {
        
        // Remove observers if this view controller is being destroyed.
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeInInputs(textField: UITextField) {
        
        clearButton.isEnabled = true
        
        if bookTitleTextField.text == "" || bookAuthorTextField.text == "" || broadcastNameTextField.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }

    // MARK: Actions
    
    @IBAction func selectBookImage(_ sender: UITapGestureRecognizer) {
        
        activeField?.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil,
            message: "How would you like to add the book image?",
            preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "By Camera", style: .default) { action in
            print("Camera was selected!")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(cameraAction)

        let photoLibraryAction = UIAlertAction(title: "By Photo Library", style: .default) { action in
            print("Photo Library was selected!")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(photoLibraryAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel was selected!")
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            print("Show the Action Sheet!")
        }
    }
    
    @IBAction func onClearButton(_ sender: UIButton) {
        
        myBooksPressed = false
        activeField?.resignFirstResponder()
        
        bookImage.image = #imageLiteral(resourceName: "defaultPhoto")
        bookImage.isUserInteractionEnabled = true
        
        broadcastNameTextField.text = nil 
        
        bookTitleTextField.text = nil
        bookTitleTextField.isEnabled = true
        
        bookAuthorTextField.text = nil
        bookAuthorTextField.isEnabled = true
        
        genreTextField.text = nil
        genreTextField.isEnabled = true
        
        clearButton.isEnabled = false
        
    }
    
    @IBAction func onIsDiscussionSegment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            isDiscussion = false
        } else if sender.selectedSegmentIndex == 1 {
            isDiscussion = true
        }
    }
    
    @IBAction func onMyBooksButton(_ sender: UIButton) {
        
        myBooksPressed = true
        
        clearButton.isEnabled = true
        
        activeField?.resignFirstResponder()
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoPopUpMenu") as! PopUpVC

        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
    
    @IBAction func onBrowseBooksButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "videoInfoToBrowseBooks", sender: sender)
    }
    
    @IBAction func unwindFromPopUpVC(_ segue: UIStoryboardSegue) {
        
        if segue.source.isKind(of: PopUpVC.self) {
            
            let prevVC = segue.source as! PopUpVC
            
            incomingBookData = prevVC.outgoingBookData
            
            clearButton.isEnabled = true
            
            refreshVC(sender: self)
        }
    }
    
    func refreshVC(sender: Any) {
        
        if bookTitleTextField.isEnabled {
            //browseBooksButton.isEnabled = false
            clearButton.isEnabled = false
        } else {
            clearButton.isEnabled = true
        }
        
        if incomingBookData != nil {
            
            print("Book: \(incomingBookData?.objectId!), bookTitle: \(incomingBookData?.bookTitle!), bookAuthor: \(incomingBookData?.bookAuthor!), bookGenre: \(incomingBookData?.bookGenre!), bookImageUrl: \(incomingBookData?.bookImageUrl)")
            
            clearButton.isEnabled = true
            
            bookTitleTextField.isEnabled = false
            bookTitleTextField.text = incomingBookData?.bookTitle!
            
            bookAuthorTextField.isEnabled = false
            bookAuthorTextField.text = incomingBookData?.bookAuthor!
            
            genreTextField.isEnabled = false
            genreTextField.text = incomingBookData?.bookGenre!
            
            bookImage.isUserInteractionEnabled = false
            
            let bookImageUrl = (incomingBookData?.bookImageUrl)! as String
            
            if Utility.sharedInstance.imageCache.object(forKey: bookImageUrl as NSString) != nil {
                
                bookImage.image = Utility.sharedInstance.imageCache.object(forKey: bookImageUrl as NSString)
                
            } else {
                
                clearButton.isEnabled = false
                
//                Utility.sharedInstance.showActivityIndicator(uiView: self.view)
                
                Utility.sharedInstance.loadImageFromUrl(photoUrl:(incomingBookData?.bookImageUrl!)!,
                    
                    completion: { data in
                    
                        if let bookImage = UIImage(data: data) {
                        
                            self.bookImage.image = bookImage

                            // set new image to be cached
                            // since w went to the trouble of pulling down the image data and
                            // building a UIImage, lets cache the UIImage using the URL as the key
                        
                            Utility.sharedInstance.imageCache.setObject(bookImage, forKey: bookImageUrl as NSString)
                            
//                            Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                        }
                    },
                
                    loadError: {
                        
//                       Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    
                        Utility.showAlert(viewController: self, title: "Load Error", message: "Could not load book data, please check your internet connection and try again.")
                })
            }
        }
    }
    
    @IBAction func onSaveButton(_ sender: UIButton) {
        
        saveButton.isEnabled = false

//       Utility.sharedInstance.showActivityIndicator(uiView: self.view)
        
        book.bookTitle = bookTitleTextField.text!
        book.bookAuthor = bookAuthorTextField.text!
        book.bookGenre = genre
        
        let imageData = UIImageJPEGRepresentation(bookImage.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        //Saves Photo to camera roll
        //UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        
        broadcast.broadcastName = broadcastNameTextField.text!
        // save broadcastUrl
        let uuid = NSUUID().uuidString
        let name = "book_\(book.bookTitle!)_uuid_\(uuid)"
        broadcast.broadcastUrl = Utility.sharedInstance.removeSpecialCharsFromString(text: name)
        sentBroadcastUrl = broadcast.broadcastUrl!
        broadcast.liveBroadcast = true
        
        if bookTitleTextField.isEnabled == true {
        
            BackendlessManager.sharedInstance.saveBookAndBroadcastData(bookData: book, bookImage: compressedJPGImage!, broadcastData: broadcast,
                                                                        
                completion: { book in
                    
                    print(book.objectId!)
                    
                    Utility.sharedInstance.writeUserDataToArchiver(bookObjectId: book.objectId!, bookData: book, bookImage: compressedJPGImage!)
                    
                    //self.writeUserDataToArchiver(bookObjectId: book.objectId!)
                            
//                    Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "videoInfoToGoLive", sender: sender)
                    
                    self.saveButton.isEnabled = true 
                },
                
                error: {
                
//                    Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    Utility.showAlert(viewController: self, title: "Input Error", message: "Broadcast data failed to save. Please check your internet connection and try again.")
            })
        }
        else if myBooksPressed == true {
            
            BackendlessManager.sharedInstance.saveBroadcastData(broadcastData: broadcast, bookObjectID: incomingBookData!.objectId!,
                                                                
                completion: {
                    
                    self.myBooksPressed = false
                    
//                   Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "videoInfoToGoLive", sender: sender)
                },
                
                error: {
                    
//                    Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    Utility.showAlert(viewController: self, title: "Input Error", message: "Broadcast data failed to save. Please check your internet connection and try again.")
            })
        }
        else {
            
            BackendlessManager.sharedInstance.saveBroadcastData(broadcastData: broadcast, bookObjectID: bookId!,
                                                                
                completion: {
                                        
                    self.myBooksPressed = false
                    
//                    Utility.sharedInstance.hideActivityIndicator()
                    
                    self.performSegue(withIdentifier: "videoInfoToGoLive", sender: sender)
                },
                
                error: {
                    
//                    Utility.sharedInstance.hideActivityIndicator(uiView: self.view)
                    Utility.showAlert(viewController: self, title: "Input Error", message: "Broadcast data failed to save. Please check your internet connection and try again.")
            })
        }
    }
    
    
    
    // MARK: UIImagePickerControllerDelegate
    
    // From UIImagePickerControllerDelegate called when photo selected
    // opportunity to do something with image ex: display in UI
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Set photoImageView to display the selected image.
        bookImage.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "videoInfoToGoLive" {
            
            let nextVC = segue.destination as! GoLiveVC
        
            nextVC.bookTitle = bookTitleTextField.text!
            nextVC.broadcastName = broadcastNameTextField.text!
            nextVC.broadcastUrl = sentBroadcastUrl
        }
    }
    
    // MARK: UITextFieldDelegate
    
    // UITextFieldDelegate, called when Return tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if bookTitleTextField.isEnabled == false {
            textField.resignFirstResponder()
//            saveButton.
        }
        
         else if textField == broadcastNameTextField {
            bookTitleTextField.becomeFirstResponder()
        } else if textField == bookTitleTextField {
            bookAuthorTextField.becomeFirstResponder()
        } else if textField == bookAuthorTextField {
            
            textField.resignFirstResponder()
            
            genreTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // UITextFieldDelegate, called when editing session begins, or when keyboard displayed
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable Save button while editing.
        
//        saveButton.isEnabled = false
        self.activeField = textField
        
        if textField == genreTextField {
            
            saveButton.isHidden = true
            
            genrePicker.isHidden = false
            textField.endEditing(true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.activeField = nil
    }
    
    func keyboardDidShow(_ notification: Notification) {
        
        // Check if the activeField is non-nil and whether or not we can get access to the keyboard's size info.
        if let activeField = self.activeField, let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            // Use the keyboard's height to create new insets for our UIScrollView.
            // The insets add padding around the edges of the scroll view content.
            // This is typically done at the top and bottom so controllers and toolbars
            // don’t interfere with the content.
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            
            // Next, we'll get access to the frame of the root view and calculate what
            // its height would be if it was reduced or shortened by the keyboard's height.
            var shortenedViewFrame = self.view.frame
            shortenedViewFrame.size.height -= keyboardSize.size.height
            
            // Lastly, if the shortened view frame does not contain the UITextField that
            // is currently active, the active UITextField is NOT visible and we will
            // need to scroll the UIScrollView up till the UITextField does become visible.
            if !shortenedViewFrame.contains(activeField.frame.origin) {
                
                // This call will scroll so rect is just visible (based on nearest edges).
                // Nothing will happen if rect completely visible.
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
        
        // Move the UIScrollView back to its normal position.
        let contentInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }

    
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    // From the UIPickerViewDataSource protocol.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    // From the UIPickerViewDataSource protocol.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerGenres.count
    }
    
    // From the UIPickerViewDataSource protocol.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return pickerGenres[row]
    }
    
    // From the UIPickerViewDelegate protocol.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.genreTextField.text = self.pickerGenres[row]
        self.genrePicker.isHidden = true
        genre = pickerGenres[row]
        
        saveButton.isHidden = false

    }
    
//    // MARK: NSCoding
//    
//    func writeUserDataToArchiver(bookObjectId: String) {
//        
//        let defaults = Foundation.UserDefaults.standard
//        
////        print(bookObjectId)
//        
//        let userData = UserData(bookImage: bookImage.image!, bookTitle: bookTitleTextField.text!, bookAuthor: bookAuthorTextField.text!, bookGenre: genreTextField.text!, bookObjectId: bookObjectId)
//        
//        let data = NSKeyedArchiver.archivedData(withRootObject: userData)
//        defaults.set(data, forKey: "USERDATA")
//        
//        defaults.synchronize()
//    }
//    
//    func loadUserDataFromArchiver() {
//        
//        let defaults = Foundation.UserDefaults.standard
//        
//        if let data = defaults.object(forKey: "USERDATA") as? Data {
//            
//            let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as! UserData
//            
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
//        }
//    }

}














