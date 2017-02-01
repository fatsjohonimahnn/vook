//
//  LoginVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/27/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.addTarget(self, action: #selector(LoginVC.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginVC.textFieldChanged(textField:)), for: UIControlEvents.editingChanged)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldChanged(textField: UITextField) {
        
        if emailTextField.text == "" || passwordTextField.text == "" {
            loginBtn.isEnabled = false
        } else {
            loginBtn.isEnabled = true
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        if !Utility.isValidEmail(emailAddress: emailTextField.text!) {
            Utility.showAlert(viewController: self, title: "Login Error", message: "Please enter a valid email address.")
            return
        }
        
        spinner.startAnimating()
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        BackendlessManager.sharedInstance.loginUser(email: email, password: password,
            completion: {
                                                        
                self.spinner.stopAnimating()
            
                self.performSegue(withIdentifier: "loginToMain", sender: sender)
            },
                                                    
            error: { message in
                                                        
                self.spinner.stopAnimating()
                                                        
                Utility.showAlert(viewController: self, title: "Login Error", message: message)
        })
    }
    
    @IBAction func createAccountBtn(_ sender: UIButton) {
        
        performSegue(withIdentifier: "loginToRegister", sender: sender)
    }


}
