//
//  LoginViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 31.05.2021.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkBox: UIButton!
    
    //MARK: - Properties
    let currentUser = Auth.auth().currentUser
    let userDefaults = UserDefaults.standard
    var buttonOn = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTextFieldIcon()
        passwordTextFieldIcon()
        
        buttonOn = userDefaults.bool(forKey: "isSelectedButton")
        print(buttonOn)
        if buttonOn == true {
            mailTextField.text! = (currentUser?.email) ?? ""
            checkBox.imageView?.image = UIImage(named: "checkbox")
      }
    
     }
    
    //MARK: - Functions
    func mailTextFieldIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 45))
        let image = UIImage(named: "person")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 45))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        mailTextField.leftViewMode = UITextField.ViewMode.always
        mailTextField.leftView = view
        mailTextField.layer.cornerRadius = 24.0
        mailTextField.layer.borderWidth = 1.0
        mailTextField.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    func passwordTextFieldIcon() {
        let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 45))
        let image = UIImage(named: "lock")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = UIColor.systemBackground

        let view = UIView(frame: CGRect(x: 5, y: 0, width: 20, height: 45))
        view.addSubview(imageView)
        view.backgroundColor = .systemBackground
        passwordTextField.leftViewMode = UITextField.ViewMode.always
        passwordTextField.leftView = view
        passwordTextField.layer.cornerRadius = 24.0
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func makeAlert(titleInput: String, messageInput: String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Tamam", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func signInButton(_ sender: Any) {
        if mailTextField.text != nil && passwordTextField.text != nil {
            Auth.auth().signIn(withEmail: mailTextField.text!, password: passwordTextField.text!) { (authdata, error) in
                if error != nil {
                    self.makeAlert(titleInput: "HATA", messageInput: "Kullanıcı adı veya şifre hatalı!")
                } else {
                    self.performSegue(withIdentifier: "toTabbar", sender: nil)
                }
            }
        } else {
            makeAlert(titleInput: "HATA", messageInput: "Kullanıcı adı veya şifre hatalı!")
        }
        
    }
    
    @IBAction func checkBox(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if buttonOn {
            buttonOn = true
            checkBox.imageView?.image = UIImage(named: "checkbox")
            userDefaults.set(buttonOn, forKey: "isSelectedButton")
            userDefaults.synchronize()
            
        } else {
            buttonOn = false
            checkBox.imageView?.image = UIImage(named: "checkbox2")
            userDefaults.set(buttonOn, forKey: "isSelectedButton")
            userDefaults.synchronize()
        }
        buttonOn.toggle()
    }
}
