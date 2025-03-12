//
//  SignInViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "ShowSignupScreenSegue", sender: self)
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please enter your email and password")
            return
        }
        
        
        if let user = CoreDataManager.shared.fetchUser(withEmail: email) {
            let encodedSalt = user.salt
            let salt = decodeSalt(from: encodedSalt)
            if salt.isEmpty {
                showAlert( "Something went wrong!")
                return
            }
          
            let hashedInput = hashPassword(password, salt: salt)
            
            
            if user.password == hashedInput {
                UserDefaults.standard.set(user.email, forKey: "currentUserEmail")
                showAlert("Login Successful") {
                    self.performSegue(withIdentifier: "ShowHomeScreenSegue", sender: self)
                }
            } else {
                showAlert("Incorrect Password")
            }
        } else {
            showAlert("No user found with this email")
        }
    }
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    
    func decodeSalt(from encodedSalt: String?) -> Data {
        if let unwrappedSalt = encodedSalt {
            if let saltData = Data(base64Encoded: unwrappedSalt){
                return saltData
            } else {
                print("Failed to convert salt to data")
                return Data()
            }
        } else {
            print("Salt is nil")
            return Data()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
