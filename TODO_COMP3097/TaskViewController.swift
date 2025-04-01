//
//  TaskViewController.swift
//  TODO_COMP3097
//
//  Created by Will Steep on 2025-03-31.
//

import UIKit

class TaskViewController: UIViewController {
    
    
    
    var currentTask: Task?
    
    var isEditingMode = false //boolean to track whether edit mode is active or not
   
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var descField: UITextView!
    
    @IBOutlet weak var priorityPicker: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let task = currentTask {
            titleField.text = task.title
            descField.text = task.desc
            priorityPicker.selectedSegmentIndex = Int(task.priority)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        
        isEditingMode.toggle()
        
        titleField.isEnabled = isEditingMode
        descField.isEditable = isEditingMode
        priorityPicker.isEnabled = isEditingMode
        
        editButton.setTitle(isEditingMode ? "Done" : "Edit", for: .normal)
        
        
    }
    
    @IBAction func saveTaskButtonTapped(_ sender: UIButton) {
        guard let title = titleField.text, !title.isEmpty else {
            showAlert("Title is required")
            return
        }
        
        let desc = descField.text
        
        let priorityIndex = priorityPicker.selectedSegmentIndex
        let priority: Int
        
        switch priorityIndex {
        case 0:
            priority = 0
        case 1:
            priority = 1
        case 2:
            priority = 2
        default:
            priority = 0
        }
        guard let list = currentTask?.list else {
            showAlert("Error finding associated list")
            return
        }
        
        guard let taskId = currentTask?.id else {
            showAlert("Error finding ID for current task")
            return
        }
        
        
        let taskUpdateStatus = CoreDataManager.shared.updateTask(id: taskId, newTitle: title, newDesc: desc, newPriority: priority, newStatus: false)
        if (taskUpdateStatus) {
            showAlert("Task saved successfully"){
                self.navigationController?.popViewController(animated: true)
            }
            
            
        } else {
            showAlert("Failed to update")
        }
        
    }
    
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    
    
    
}
