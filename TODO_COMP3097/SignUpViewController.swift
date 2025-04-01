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
        //ensure no fields are empty when submitting
        if let name = nameTextField.text, !name.isEmpty,
           let email = emailTextField.text, !email.isEmpty,
           let password = passwordTextField.text, !password.isEmpty,
           let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty {
            
            //passwords need to match
            guard password == confirmPassword else {
                showAlert("Passwords do not match")
                return
            }
            //check if email follows valid format
            guard isValidEmail(email) else {
                showAlert("Please enter a valid email address.")
                return
            }
            
            //check if user in DB has same email
            if let existingUser = CoreDataManager.shared.fetchUser(withEmail: email) {
                showAlert("User with this email already exists.")
            } else {
                
                let salt = generateSalt() //generate unique salt to hash password with
                let hashedPassword = hashPassword(password, salt: salt) //has with new salt
                //save user to Core Data
                CoreDataManager.shared.saveUser(name: name, email: email, password: hashedPassword, salt: salt.base64EncodedString()) //salt is stored as a string
                showAlert("Account created successfully") {
                    self.navigateToSignIn() //navigate to sign in page if account is created successfully
                }
            }
        }
    }
        
        
        func isValidEmail(_ email: String) -> Bool {
            let emailLower = email.lowercased()
            
            let emailRegEx = "[A-Za-z0-9a._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            //return true or false depending on if email matches appropriate email format
            return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: emailLower)
        }
        
        
        //helper function that generates generic pop up messages
        func showAlert(_ message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
            present(alert, animated: true)
        }
        
        //pop back to SignIn page
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


