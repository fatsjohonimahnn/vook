//
//  StartVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 9/22/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class StartVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//TODO: Add action sheets for login or sign up
    @IBAction func emailBtn(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil,
                                                message: "Use an Email Account",
                                                preferredStyle: .actionSheet)
        
        let signUpAction = UIAlertAction(title: "Sign Up", style: .default) { action in
            print("Sign Up was selected!")
            
            self.performSegue(withIdentifier: "startToRegister", sender: sender)
        }
        
        alertController.addAction(signUpAction)
        
        let logInAction = UIAlertAction(title: "Log In", style: .default) { action in
            print("Log In was selected!")
            
            self.performSegue(withIdentifier: "startToLogin", sender: sender)
        }
        
        alertController.addAction(logInAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel was selected!")
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            print("Show the Action Sheet!")
        }
    }


    @IBAction func skipBtn(_ sender: UIButton) {
        
        performSegue(withIdentifier: "skipToMain", sender: sender)

    }
}

