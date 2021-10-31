//
//  SignUpViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 31.05.2021.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    //MARK: - UI Elements
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainText: UITextField!
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextIcon()
        mailTextFieldIcon()
        passwordTextFieldIcon()
        passwordAgainTextIcon()
        self.phoneTextField.delegate = self
}
    
    //MARK: - Functions
    func phoneTextIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        let image = UIImage(named: "telephone")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        phoneTextField.leftViewMode = UITextField.ViewMode.always
        phoneTextField.leftView = view
        phoneTextField.layer.cornerRadius = 20.0
        phoneTextField.layer.borderWidth = 1.0
        phoneTextField.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    func mailTextFieldIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        let image = UIImage(named: "letter")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        mailTextField.leftViewMode = UITextField.ViewMode.always
        mailTextField.leftView = view
        mailTextField.layer.cornerRadius = 20.0
        mailTextField.layer.borderWidth = 1.0
        mailTextField.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    func passwordTextFieldIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        let image = UIImage(named: "lock")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        passwordTextField.leftViewMode = UITextField.ViewMode.always
        passwordTextField.leftView = view
        passwordTextField.layer.cornerRadius = 20.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    func passwordAgainTextIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        let image = UIImage(named: "lock")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 40))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        passwordAgainText.leftViewMode = UITextField.ViewMode.always
        passwordAgainText.leftView = view
        passwordAgainText.layer.cornerRadius = 20.0
        passwordAgainText.layer.borderWidth = 1.0
        passwordAgainText.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    
    func makeAlert(titleInput: String, messageInput: String) {
        
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Actions
    @IBAction func signUpButton(_ sender: Any) {
        if mailTextField.text != nil && passwordTextField.text != nil && passwordTextField.text == passwordAgainText.text {
            Auth.auth().createUser(withEmail: mailTextField.text!, password: passwordTextField.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "HATA", messageInput: "-Mailin düzgün yazıldığına emin olun. -Şifre en az 6 haneli olmalıdır -Şifre girdiğiniz alanlar aynı olmalıdır ! ")
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
        } else {
            makeAlert(titleInput: "HATA", messageInput: "-Mailin düzgün yazıldığına emin olun. -Şifre en az 6 haneli olmalıdır -Şifre girdiğiniz alanlar aynı olmalıdır ! ")
    }
 }
    
    @IBAction func signInButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Text Field Delegate

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var fullString = phoneTextField.text ?? ""
      fullString.append(string)
      if range.length == 1 {
        phoneTextField.text = format(phoneNumber: fullString, shouldRemoveLastDigit: true)
      } else {
        phoneTextField.text = format(phoneNumber: fullString)
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
}

