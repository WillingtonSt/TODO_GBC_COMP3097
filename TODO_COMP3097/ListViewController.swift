//
//  ListViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class ListViewController: UIViewController {
    var newList: List?
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var editButton: UIButton!
    
    var isEditingMode = false
    
    @IBAction func saveList(_ sender: UIButton) {
        //check if the list exists before continuing
        guard let listId = newList?.id else {
            showAlert("List not found.")
            return
        }
        //ensure title is not empty
        guard let newTitle = titleField.text, !newTitle.isEmpty else {
            showAlert("Title is required.")
            return
        }
        //save updated list to Core Data
        let update = CoreDataManager.shared.updateList(id: listId, newTitle: newTitle)
        //show success alert if successful and update field with current title of list
        if update {
            titleField.text = newTitle
            showAlert("List updated successfully")
        } else {
            showAlert("Failed to update the list")
        }
        
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        isEditingMode.toggle()
        
        titleField.isEnabled = isEditingMode
        
        let icon = UIImage(systemName: isEditingMode ? "checkmark" : "pencil")
        titleField.backgroundColor = isEditingMode ? UIColor.tertiarySystemGroupedBackground : UIColor.white
        editButton.setImage(icon, for: .normal)
    }
    
    
    @IBAction func addTaskButtonTapped(_ sender: UIButton) {
        guard let list = newList else {
            showAlert("List not found.")
            return
        }
        
        
       let newTask = CoreDataManager.shared.saveTask(title: "New Task", desc: "", priority: 0, list: newList!)
        
        showAlert("Task Created Successfully!") {
            self.performSegue(withIdentifier: "taskViewSegue", sender: newTask)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskViewSegue" {
            
            if let task = sender as? Task {
                if let destinationVC = segue.destination as? TaskViewController {
                    destinationVC.currentTask = task
                }
            }
            
        }
    }
    
    
    
    //pop back to home if back button is tapped
    @IBAction func onBackButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //helper function for generating generic pop up messages
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    
    
    //display current title of list when the view loads
    override func viewDidLoad() {
        titleField.text = newList?.title
        super.viewDidLoad()
    }
    
}

