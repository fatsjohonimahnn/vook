//
//  PopUpVC.swift
//  Vook
//
//  Created by Jonathon Fishman on 10/21/16.
//  Copyright © 2016 VookClub. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    
    var books = [Book]()
    
    var outgoingBookData: Book?
    var selectedBook: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        self.showAnimate()
        
        refresh(sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh(sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender: AnyObject) {
        
        BackendlessManager.sharedInstance.loadBooks( user: BackendlessManager.sharedInstance.backendless.userService.currentUser!,
            
            completion: { books in
                
                self.books = books
                
                if books.count == 0 {
                    
                    let noBooksDisplay = "No books yet!"
                    
                    self.selectedBook?.bookTitle = noBooksDisplay

                } else {
                    self.selectedBook = books[0]
                }
                self.pickerView.reloadAllComponents()
            },
            
            error: {
                self.pickerView.reloadAllComponents()
        })

    }
    
    @IBAction func onSelectButton(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "unwindToVideoInfo", sender: self)
        
        self.removeAnimate()
    }

    @IBAction func onCancelButton(_ sender: UIButton) {
        
        self.removeAnimate()
    }
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    
    // From the UIPickerViewDataSource protocol.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    // From the UIPickerViewDataSource protocol.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if books.count == 0 {
            return 1
        }
        
        return books.count
    }
    
    // From the UIPickerViewDataSource protocol.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if books.count == 0 {
        
            return "New Book"
        } else {
        
            return books[row].bookTitle!
        }
    }
    
    // From the UIPickerViewDelegate protocol.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedBook = books[row]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        
        if segue.identifier == "unwindToVideoInfo" {
            
            outgoingBookData = selectedBook
            
            print("Book: \(outgoingBookData?.objectId!), bookTitle: \(outgoingBookData?.bookTitle!), bookAuthor: \(outgoingBookData?.bookAuthor!), bookGenre: \(outgoingBookData?.bookGenre!), bookImageUrl: \(outgoingBookData?.bookImageUrl)")
        }
    }
    
    
    
    
    // MARK: Animations
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
        
    }
    
    func removeAnimate() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            },
                       
                       completion: {(finished: Bool) in
                        if (finished) {
                            
                            self.view.removeFromSuperview()
                        }
        });
    }

}
