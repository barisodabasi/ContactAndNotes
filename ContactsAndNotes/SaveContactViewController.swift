//
//  SaveContactViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 1.06.2021.
//

import UIKit
import Firebase

class SaveContactViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var surnameText: UITextField!
    @IBOutlet weak var phoneText: UITextField!
    
    var id = ""
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        let db = Firestore.firestore()
        let section = String((nameText.text?.prefix(1))!)
        //self.contactSectionTitles.append(index)
        
        if id != "" {
            db.collection("Contact").document(userId).collection("Contact").document(id).setData(["Name": self.nameText.text!, "Surname": self.surnameText.text!, "Number": phoneText.text!], merge: true)
            self.dismiss(animated: true, completion: nil)
        } else {
            db.collection("Contact").document(userId).collection("Contact").document().setData(["Name": self.nameText.text!, "Surname": self.surnameText.text!, "Number": phoneText.text!, "Section": section], merge: true) { (error) in
                if error != nil {
                    print("Save Button Error !!!!")
                }
                
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
}

