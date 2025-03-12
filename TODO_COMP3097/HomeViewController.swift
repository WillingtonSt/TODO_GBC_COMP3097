//
//  HomeViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class HomeViewController: UIViewController {
    
    var newList: List?
    
    @IBOutlet weak var setReminderButton: UIButton!
    @IBOutlet weak var createListButton: UIButton!
    
    @IBAction func createListButtonTapped(_ sender: UIButton) {
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail"){
            let id = CoreDataManager.shared.saveList(title: "New List", email: email)
            newList = CoreDataManager.shared.fetchList(withId: id)!
            showAlert("New List Created"){
                self.performSegue(withIdentifier: "showListsSegue", sender: self)
            }
        } else {
            showAlert("Error creating new list")
        }
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("PREPARE ACTIVATED")
        if segue.identifier == "showListsSegue" {
            print("SEGUE IDENTIFIED")
            if let navController = segue.destination as? UINavigationController {
                if let destinationVC = navController.topViewController as? ListViewController {
                    destinationVC.newList = newList
                }
            }
        }
    }
    
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    }
    
    

