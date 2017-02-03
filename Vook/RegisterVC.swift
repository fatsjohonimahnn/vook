//
//  RegisterVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/27/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add events to textFields to know when they change
        emailTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    }
    
    func textFieldChanged(textField: UITextField) {
        
        if emailTextField.text == "" || passwordTextField.text == "" || passwordConfirmTextField.text == "" {
        
            registerBtn.isEnabled = false
        
        } else if emailTextField.text != "" && passwordConfirmTextField.text == passwordConfirmTextField.text {
        
            warningLabel.isHidden = true
            registerBtn.isEnabled = true
        }
    }
    
    // MARK: UITextFieldDelegate
    
    // UITextFieldDelegate, called when Return tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()

        } else if textField == passwordTextField {
            
            passwordConfirmTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            
            if passwordTextField.text != passwordConfirmTextField.text {
                
                registerBtn.isEnabled = false
                warningLabel.isHidden = false
            }
        }
        return true
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        let uuid = NSUUID().uuidString
        
        if passwordTextField.text != passwordConfirmTextField.text {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Password confirmation failed. Plase enter your password try again.")
            return
        }
        
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.showAlert(viewController: self, title: "Registration Error", message: "Please enter a valid email address.")
            return
        }
        
        Utility.sharedInstance.showActivityIndicator(view: self.view)
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let name = "User-\(uuid)"
        
        BackendlessManager.sharedInstance.registerUser(email: email, password: password, name: name,
            completion: {
                                                        
                BackendlessManager.sharedInstance.loginUser(email: email, password: password,
                    completion: {
                                                                        
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                                                                        
                        self.performSegue(withIdentifier: "registerToEditProfile", sender: sender)
                    },
                                                                    
                    error: { message in
                                                                        
                        Utility.sharedInstance.hideActivityIndicator(view: self.view)
                        
                        Utility.showAlert(viewController: self, title: "Login Error", message: message)
                    })
            },
                                                       
            error: { message in
                                                        
                Utility.sharedInstance.hideActivityIndicator(view: self.view)
                                                        
                Utility.showAlert(viewController: self, title: "Register Error", message: message)
            })
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        Utility.sharedInstance.hideActivityIndicator(view: self.view)
        
        performSegue(withIdentifier: "registerToStart", sender: sender)
    }
}
