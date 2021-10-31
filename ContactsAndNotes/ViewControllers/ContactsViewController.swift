//
//  ContactsViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 1.06.2021.
//
import UIKit
import Firebase
import FirebaseFirestoreSwift
import Kingfisher
import OneSignal

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: - UI Elements
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hiddenView: UIView!
    
    //MARK: - Properties
    let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()

    var contactSectionArray = [String]()
    var contactDataArray = [ContactData]()
    var filteredDataArray = [ContactData]()
    var letters: [Character] = []
    
    var spinner: UIActivityIndicatorView?
    var spinnerContainer: UIView?
    
       //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromFirestore()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
       // OneSignal.postNotification(["contents": ["Test Message"], "include_player_ids": ["0757d78c-1828-46fe-b10c-bd22e2220f71"]])
       if let status = OneSignal.getDeviceState() {
        let userId = status.userId
        let pushToken = status.pushToken
        let subscribed = status.isSubscribed
        print("UserId: \(userId)")
        print("pushToken: \(pushToken)")
        print("subscribed: \(subscribed)")
        }
}
    override func viewWillAppear(_ animated: Bool) {
        if self.traitCollection.userInterfaceStyle == .dark {
            searchBar.barTintColor = .systemBackground
                }
    }
    
        //MARK: - Functions
    func getDataFromFirestore() {
        
        let db = Firestore.firestore()
        let docRef = db.collection("Contact").document(userId).collection("Contact")
        showIndicator()
        docRef.addSnapshotListener { (documents, error) in
            self.hideIndicator()
            if error == nil {
            if documents?.isEmpty == false && documents != nil {
                    
                    self.contactDataArray.removeAll()
                    self.letters.removeAll()
                    self.contactSectionArray.removeAll()
                    self.filteredDataArray.removeAll()
                    
              for doc in documents!.documents {
                self.contactDataArray.append(ContactData(email: (doc.data()["email"]) as? String, nameSurname: (doc.data()["nameSurname"]) as? String, phoneNumber: (doc.data()["phoneNumber"] as? String), workName: (doc.data()["workName"] as? String), birthDay: (doc.data()["birthDay"] as? String), bloodGroup: (doc.data()["bloodGroup"] as? String), url: (doc.data()["url"] as? String), socialProfile: (doc.data()["socialProfile"] as? String), section: (doc.data()["section"] as? String), imageURL: (doc.data()["imageURL"] as? String), documentID: (doc.documentID)))
                
                self.tableView.reloadData()
            }
                
                self.letters.removeAll(keepingCapacity: false)
                self.letters = self.contactDataArray.map({ (contact) in
                    return (contact.nameSurname?.uppercased().first)!
                })
                self.letters = self.letters.sorted()
                self.letters = self.letters.reduce([], { (list, name) -> [Character] in
                    if !list.contains(name) {
                        return list + [name]
                    }
                    
                    return list
                })
                self.filteredDataArray = self.contactDataArray
                self.tableView.reloadData()
              
            } else {
                self.contactDataArray.removeAll(keepingCapacity: false)
                self.filteredDataArray.removeAll(keepingCapacity: false)
                self.tableView.reloadData()
            }
        }
            if documents?.isEmpty != false {
                self.tableView.isHidden = true
                self.hiddenView.isHidden = false
            } else {
                self.tableView.isHidden = false
                self.hiddenView.isHidden = true
        }
    }
}
    
    func showIndicator(){
        spinnerContainer = UIView.init(frame: self.view.frame)
        spinnerContainer!.center = self.view.center
        spinnerContainer!.backgroundColor = .init(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        self.view.addSubview(spinnerContainer!)
        
        spinner = UIActivityIndicatorView.init(style: .large)
        spinner!.center = spinnerContainer!.center
        spinner?.color = .white
        spinnerContainer!.addSubview(spinner!)
        
        spinner!.startAnimating()
    }
    
    func hideIndicator(){
        spinner?.removeFromSuperview()
        spinnerContainer?.removeFromSuperview()
    }

    
    //MARK: - TableView Delegate And Datasource
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        for contact in filteredDataArray {
            contactSectionArray.append(contact.section!)
        }
        var sorted = Array(Set(contactSectionArray))
        sorted = sorted.sorted()
        return sorted
}
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return letters.count
}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return filteredDataArray.count
 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell

            if letters[indexPath.section] == filteredDataArray[indexPath.row].nameSurname?.uppercased().first {
                let url = URL(string: filteredDataArray[indexPath.row].imageURL! )
                cell.contactImageView.kf.setImage(with: URL?(url!))
                cell.contactLabel.text = filteredDataArray[indexPath.row].nameSurname
             }

       return cell
 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     
            if letters[indexPath.section] == filteredDataArray[indexPath.row].nameSurname?.uppercased().first {
                return 50
            } else {
                return 0.0
    }
}
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

            return letters[section].description
}
   
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.systemBackground
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "SaveContactTableViewController") as! SaveContactTableViewController
       
            vc.contact = filteredDataArray[indexPath.row]
            vc.id = filteredDataArray[indexPath.row].documentID!
            present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                let db = Firestore.firestore()
            db.collection("Contact").document(userId).collection("Contact").document(filteredDataArray[indexPath.row].documentID!).delete { (error) in
                    if let error = error {
                        print("ERROR SİLME İSLEMİ: \(error)")
                    } else {
                        self.getDataFromFirestore()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Actions
    @IBAction func editingButton(_ sender: Any) {
        let tableViewEditingMode = tableView.isEditing
        tableView.setEditing(!tableViewEditingMode, animated: true)
}
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        do{
            try Auth.auth().signOut()
            let board = UIStoryboard(name: "Main", bundle: nil)
            let vc = board.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        } catch {
            print("catch error!")
    }
}
    
    //MARK: - Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchText == "" {
             getDataFromFirestore()
        } else {
            filteredDataArray = self.contactDataArray.filter({($0.nameSurname!.localizedCaseInsensitiveContains(searchText))})
               
                self.letters.removeAll(keepingCapacity: false)
                self.letters = self.filteredDataArray.map({ (contact) in
                    return (contact.nameSurname?.uppercased().first)!
                })
                self.letters = self.letters.sorted()
                self.letters = self.letters.reduce([], { (list, name) -> [Character] in
                    if !list.contains(name) {
                        return list + [name]
                    }
                    
                    return list
                })
            tableView.reloadData()
            
        }
    }
}
