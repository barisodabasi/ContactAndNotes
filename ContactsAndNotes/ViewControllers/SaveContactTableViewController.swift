//
//  SaveContactTableViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 2.06.2021.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage
import IQKeyboardManagerSwift



class SaveContactTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITextFieldDelegate{
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameSurnameText: UITextField!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var workNameText: UITextField!
    @IBOutlet weak var urlText: UITextField!
    @IBOutlet weak var socialProfileText: UITextField!
    
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    
    @IBOutlet weak var bloodGroupPicker: UIPickerView!
    @IBOutlet weak var bloodGroupTextField: UITextField!
    
    
    //MARK: - Properties
   let user = Auth.auth().currentUser
    lazy var userId:String = {
        return self.user!.uid
    }()

    var id = ""
    var contact: ContactData?
    
    var spinner: UIActivityIndicatorView?
    var spinnerContainer: UIView?
    
    let birthDayLabelCell = IndexPath(row: 0, section: 2)
    var birthdayPickerCellIndexPath = IndexPath(row: 1, section: 2)
    
    let bloodGroupPickerCellIndexPath = IndexPath(row: 1, section: 3)
    let bloodGroupLabelCell = IndexPath(row: 0, section: 3)
    
    
    let imageCellIndexPath = IndexPath(row: 0, section: 0)
    let nameDataCellIndexPath = IndexPath(row: 1, section: 0)
    

    var isBirthdayPickerShown: Bool = false {
        didSet {
            birthdayPicker.isHidden = !isBirthdayPickerShown
            IQKeyboardManager.shared.enable = false
        }
       
    }
    
    var isBloodGroupPickerShown: Bool = false {
        didSet {
            bloodGroupPicker.isHidden = !isBloodGroupPickerShown
            IQKeyboardManager.shared.enable = false
        }
    }
    let bloodGroupData = ["0 Rh(+)", "0 Rh(-)", "A Rh(+)", "A Rh(-)", "B Rh(+)", "B Rh(-)", "AB Rh(+)", "AB Rh(-)"]
 
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiView()
        self.phoneNumberText.delegate = self
        bloodGroupPicker.dataSource = self
        bloodGroupPicker.delegate = self
        birthdayPicker.removeFromSuperview()
        bloodGroupPicker.removeFromSuperview()
        bloodGroupTextField.inputView = bloodGroupPicker
        birthdayTextField.inputView = birthdayPicker
        
        if self.traitCollection.userInterfaceStyle == .dark {
            tableView.backgroundColor = .systemBackground
                }
        
}
    
    //MARK: - Functions
    func uiView() {
        if id != "" {
            emailText.text? = contact!.email!
            nameSurnameText.text? = contact!.nameSurname!
            phoneNumberText.text? = contact!.phoneNumber!
            workNameText.text? = contact!.workName!
            birthdayTextField.text? = contact!.birthDay!
            bloodGroupTextField.text? = contact!.bloodGroup!
            urlText.text? = contact!.url!
            socialProfileText.text? = contact!.socialProfile!
            titleLabel?.text = "Düzenle"
        }
 }
    
    func updateDateViews() {
        let loc = Locale(identifier: "Turkish")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = loc
        birthdayTextField.text = dateFormatter.string(from: birthdayPicker.date)
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
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
    
    //MARK: - Text Field Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var fullString = phoneNumberText.text ?? ""
      fullString.append(string)
      if range.length == 1 {
          phoneNumberText.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
      } else {
          phoneNumberText.text = format(phoneNumber: fullString)
      }
      return false
  }
    
    func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }
        return number
    }
    
   // MARK: - TableView Delegate And DataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 6
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case birthdayPickerCellIndexPath:
            if isBirthdayPickerShown {
                return 0 //162
            } else {
                return 0
            }
            
        case bloodGroupPickerCellIndexPath:
            if isBloodGroupPickerShown {
                return 0 //150
            } else {
                return 0
            }
        case imageCellIndexPath:
            return 233
        case nameDataCellIndexPath:
            return 139
        default:
            return 50
    }
}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case birthDayLabelCell:
            if isBirthdayPickerShown {
                isBirthdayPickerShown = false
                
            } else {
                isBirthdayPickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        case bloodGroupLabelCell:
            if isBloodGroupPickerShown {
                isBloodGroupPickerShown = false
                
            } else {
                isBloodGroupPickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
       
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
             let storage = Storage.storage().reference()
            let uuid = UUID().uuidString
            let ref = storage.child("Contact").child(userId).child(uuid).child("png")
            showIndicator()
            ref.putData(data, metadata: nil) { (_, error) in
                
                guard error == nil else {
                    print("Failed to upload")
                    return
                }
                ref.downloadURL { [self] (url, error) in
                    guard let url = url, error == nil else {return}
                    let urlString = url.absoluteString
                    print("DownloadURL: \(urlString)")
                    
                    
                    let db = Firestore.firestore()
                    if nameSurnameText.text != "" && phoneNumberText.text != "" && imageView.image != nil {
                        if id == "" {
                            
                            let contactData = ContactData(email: emailText.text!, nameSurname: nameSurnameText.text!, phoneNumber: phoneNumberText.text!, workName: workNameText.text!, birthDay: birthdayTextField.text!, bloodGroup: bloodGroupTextField.text!, url: urlText.text!, socialProfile: socialProfileText.text!, section: String((nameSurnameText.text!.uppercased().prefix(1))), imageURL: urlString)
                            do {
                                try db.collection("Contact").document(userId).collection("Contact").document().setData(from: contactData)
                                self.hideIndicator()
                            } catch let error {
                                print("Error writing city to Firestore: \(error)")
                            }
                            dismiss(animated: true, completion: nil)
                            
                        } else {
                            let contactData = ContactData(email: emailText.text!, nameSurname: nameSurnameText.text!, phoneNumber: phoneNumberText.text!, workName: workNameText.text!, birthDay: birthdayTextField.text!, bloodGroup: bloodGroupTextField.text!, url: urlText.text!, socialProfile: socialProfileText.text!, section: String((nameSurnameText.text!.uppercased().prefix(1))), imageURL: urlString)

                            do {
                                try db.collection("Contact").document(userId).collection("Contact").document(id).setData(from: contactData)
                            } catch let error {
                                print("Error writing city to Firestore: \(error)")
                            }
                            dismiss(animated: true, completion: nil)
                        }
                        
                        tableView.reloadData()
                    } else {
                        makeAlert(titleInput: "UYARI", messageInput: "İsim soyisim, telefon numarası, fotoğraf boş olamaz!")
                        hideIndicator()
                    }
                }
            }
        }
    }
    
    @IBAction func addImageButton(_ button: UIButton) {
        showIndicator()
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
        hideIndicator()
        
    }
    
    @IBAction func datePickerValueChange(_ sender: UIDatePicker) {
        updateDateViews()
}
    
    //MARK: - İmagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        showIndicator()
        imageView.image = (info[.originalImage] as? UIImage)
        hideIndicator()
            self.dismiss(animated: true, completion: nil)
        
 }

   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
 
}

extension SaveContactTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        bloodGroupData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return bloodGroupData[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        bloodGroupTextField.text = bloodGroupData[row]
        bloodGroupTextField.resignFirstResponder()
    }
}
