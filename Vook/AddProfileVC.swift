//
//  AddProfileVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/28/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class AddProfileVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var photoSpinner: UIActivityIndicatorView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var warningLbl: UILabel!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameSpinner: UIActivityIndicatorView!
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var userDescriptionTextView: UITextView!
    
    var replaceName: Bool = false
    var replacePhoto: Bool = false
    
    let backendless = Backendless.sharedInstance()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveBtn.isEnabled = false
        
        nameTextField.addTarget(self, action: #selector(changeInTextField(textField:)), for: UIControlEvents.editingChanged)
    }
    
    func changeInTextField(textField: UITextField) {
        
        if nameTextField.text == ""  {
            saveBtn.isEnabled = false
        } else {
            warningLbl.isHidden = true
        }
    }

    
    // MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        replaceName = true
        saveBtn.isEnabled = true
        
        changeInTextField(textField: nameTextField)
        
        //print("Replace name: \(replaceName), Replace photo: \(replacePhoto)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            userDescriptionTextView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        warningLbl.isHidden = true
    }
    
    
    
    // MARK: UITextViewDelegate methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Tell us about yourself or your favorite book genres..." {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        replaceName = true 
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n") {
            view.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about yourself or your favorite book genres..."
            textView.textColor = UIColor.lightGray
        }
    }

    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        replacePhoto = true
        
        //print("Replace name: \(replaceName), Replace photo: \(replacePhoto)")

        profileImageView.image = selectedPhoto
        
        dismiss(animated: true, completion: nil)
        
        if replacePhoto == true && nameTextField.text != "" {
            saveBtn.isEnabled = true
        }
    }
    
    // MARK: Navigation
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        
        self.saveBtn.isEnabled = false
        
        let user = backendless.userService.currentUser
        let photoUrl = BackendlessManager.sharedInstance.photoUrl
        let name = nameTextField.text!
        let photo = profileImageView.image!
        var desc = userDescriptionTextView.text!
//Check if user is live currently
        let isLive = false
        
        if replaceName == true {
            
            self.nameSpinner.startAnimating()
            
            if desc == "Tell us about yourself or your favorite book genres..." {
                desc = ""
            }
      
            BackendlessManager.sharedInstance.isValidUserName(name: name,
                
                completion: { isValid in
                    
                    if isValid {
                        print("old name: \(user!.name!), NEW name: \(name) is valid, lets update them, Desc: \"\(desc)\"")
                    
                        BackendlessManager.sharedInstance.updateUser(name: name, desc: desc, isLive: isLive,
                                                                 
                            completion: {
                                self.replaceName = false
                                self.nameSpinner.stopAnimating()
                                
                                print("name: \(name), photoUrl: \(photoUrl), replaceName: \(self.replaceName), replacePhoto: \(self.replacePhoto)")
                                
                                if self.replaceName == false && self.replacePhoto == false {
                                    self.performSegue(withIdentifier: "editProfileToMain", sender: sender)
                                }
                            },
                        
                            error: { message in
                        })
                        
                    } else {
                        print("Not Valid!!!!!!!")
                        self.nameSpinner.stopAnimating()
                        self.saveBtn.isEnabled = false
                        self.warningLbl.isHidden = false
                        self.replaceName = true
                    }
                },
                error: {
                    
            })
        }
        
        if replacePhoto == true {
            
            self.photoSpinner.startAnimating()
            
            BackendlessManager.sharedInstance.saveProfilePhoto(photo: photo,
                                                               
                completion: {
                    self.photoSpinner.stopAnimating()
                    self.replacePhoto = false
                    
                    print("name: \(name), photoUrl: \(photoUrl), replaceName: \(self.replaceName), replacePhoto: \(self.replacePhoto)")
                    
                    if self.replaceName == false && self.replacePhoto == false {
                        self.performSegue(withIdentifier: "editProfileToMain", sender: sender)
                    }
                },
                error: {
                    
            })
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }

}
