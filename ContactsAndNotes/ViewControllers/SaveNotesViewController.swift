//
//  SaveNotesViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 5.06.2021.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SaveNotesViewController: UIViewController {
    
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesLabel: UILabel!
    
    //MARK: - Properties
    var notesTitle = ""
    var notes = ""
    var id = ""
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiView()
        
        if self.traitCollection.userInterfaceStyle == .dark {
            view.backgroundColor = .systemBackground
            notesTextField.backgroundColor = .darkGray
                }
 
    }
    //MARK: - Functions
    func uiView() {
        notesTextField.text? = notesTitle
        notesTextView.text? = notes
        if id != "" {
            notesLabel?.text = "Düzenle"
        }
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func saveNotesButton(_ sender: Any) {
        let db = Firestore.firestore()
       
        if id == "" {
            if notesTextField.text == "" {
                makeAlert(titleInput: "UYARI", messageInput: "Not başlığı boş bırakılamaz!")
            } else {
                let notesData = NotesData(notesTitle: notesTextField.text!, notes: notesTextView.text!)
                do {
                    try db.collection("Notes").document(userId).collection("Notes").document().setData(from: notesData)
                } catch let error {
                    print("Error writing city to Firestore: \(error)")
                }
                dismiss(animated: true, completion: nil)
            }
        } else {
            let notesData = NotesData(notesTitle: notesTextField.text!, notes: notesTextView.text!)
            do {
                try db.collection("Notes").document(userId).collection("Notes").document(id).setData(from: notesData)
            } catch let error {
                print("Error writing city to Firestore: \(error)")
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
