//
//  SignUpViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        if let name = nameTextField.text, !name.isEmpty,
           let email = emailTextField.text, !email.isEmpty,
           let password = passwordTextField.text, !password.isEmpty,
           let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty {
            
            guard password == confirmPassword else {
                showAlert("Passwords do not match")
                return
            }
            
            guard isValidEmail(email) else {
                showAlert("Please enter a valid email address.")
                return
            }
            
            
            if let existingUser = CoreDataManager.shared.fetchUser(withEmail: email) {
                showAlert("User with this email already exists.")
            } else {
                
                let salt = generateSalt()
                let hashedPassword = hashPassword(password, salt: salt)
                
                CoreDataManager.shared.saveUser(name: name, email: email, password: hashedPassword, salt: salt.base64EncodedString())
                showAlert("Account created successfully") {
                    self.navigateToSignIn()
                }
            }
        }
    }
        
        
        func isValidEmail(_ email: String) -> Bool {
            let emailLower = email.lowercased()
            
            let emailRegEx = "[A-Za-z0-9a._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: emailLower)
        }
        
        
        
        func showAlert(_ message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
            present(alert, animated: true)
        }
        
        
        func navigateToSignIn() {
            self.navigationController?.popViewController(animated: true)
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


