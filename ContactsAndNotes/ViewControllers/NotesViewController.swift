//
//  NotesViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 5.06.2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class NotesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hiddenView: UIView!
    
    
    //MARK: - Properties
    var id = ""
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()
    
    var notesData = [NotesData]()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotesFromFirestore()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        
        
        if self.notesData.isEmpty {
            self.tableView.isHidden = true
            self.hiddenView.isHidden = false
        } else {
            self.tableView.isHidden = false
            self.hiddenView.isHidden = true
        }
        
    }
    //MARK: - Segue for edit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSaveNotes" {
            let selectedIndexPath = tableView.indexPathForSelectedRow
            let selectedNotes = notesData[selectedIndexPath!.row]
            let navigationController = segue.destination as! SaveNotesViewController
            navigationController.notesTitle = selectedNotes.notesTitle
            navigationController.notes = selectedNotes.notes
            navigationController.id = selectedNotes.documentID
        }
    }
 
    //MARK: - Functions
    func getNotesFromFirestore() {
        
        let db = Firestore.firestore()
        let docRef = db.collection("Notes").document(userId).collection("Notes")
        docRef.addSnapshotListener { (documents, error) in
            if error == nil {
            if documents?.isEmpty == false && documents != nil {
                    
                    self.notesData.removeAll()
            
            for doc in documents!.documents {
               
                self.notesData.append(NotesData(notesTitle: (doc.data()["notesTitle"]) as! String, notes: (doc.data()["notes"]) as! String, documentID: (doc.documentID) ))
                self.tableView.reloadData()
                if self.notesData.isEmpty {
                    self.tableView.isHidden = true
                    self.hiddenView.isHidden = false
                } else {
                    self.tableView.isHidden = false
                    self.hiddenView.isHidden = true
                }
            }
                self.tableView.reloadData()
        }
     }
  }
}
    //MARK: - TableView Delegate And Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notesCell", for: indexPath) as! NotesCell
        cell.noteName.text = notesData[indexPath.row].notesTitle
        cell.noteDescription.text = notesData[indexPath.row].notes
        cell.forwardImage.image = UIImage(named: "forward")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSaveNotes", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                let db = Firestore.firestore()
            db.collection("Notes").document(userId).collection("Notes").document(notesData[indexPath.row].documentID).delete { (error) in
                    if let error = error {
                        print("ERROR SİLME İSLEMİ: \(error)")
                    } else {
                        if self.notesData.isEmpty {
                            self.tableView.isHidden = true
                            self.hiddenView.isHidden = false
                        } else {
                            self.tableView.isHidden = false
                            self.hiddenView.isHidden = true
                        }
                    }
                }
            self.notesData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
         }
    }
    
    //MARK: - Actions
    @IBAction func editButtonTapped(_ sender: Any) {
        let tableViewEditingMode = tableView.isEditing
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
}
