//
//  ForgotPasswordViewController.swift
//  ContactsAndNotes
//
//  Created by BarisOdabasi on 18.06.2021.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var mailTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mailTextField.layer.cornerRadius = 20.0
        mailTextField.layer.borderWidth = 1.0
        mailTextField.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    @IBAction func sentButton(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: mailTextField.text!, completion: { (error) in
           
            DispatchQueue.main.async {
                if let error = error {
                    let resetFailedAlert = UIAlertController(title: "Mail Bulunamadı", message: error.localizedDescription, preferredStyle: .alert)
                    resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(resetFailedAlert, animated: true, completion: nil)
                } else {
                    let resetEmailSentAlert = UIAlertController(title: "Şifre değişikliği maili başarıyla gönderildi.", message: "Lütfen mail adresinizi kontrol edin.", preferredStyle: .alert)
                    resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIalertAction) in
                        self.dismiss(animated: true, completion: nil)
                     
                    }))
                    self.present(resetEmailSentAlert, animated: true, completion: nil)
                    
                }
            }
        })
    }
    

    @IBAction func cancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
