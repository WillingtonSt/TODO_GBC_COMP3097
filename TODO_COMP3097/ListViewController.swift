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
    
    @IBAction func saveList(_ sender: UIButton) {
        guard let listId = newList?.id else {
            showAlert("List not found.")
            return
        }
        
        guard let newTitle = titleField.text, !newTitle.isEmpty else {
            showAlert("Title is required.")
            return
        }
        
        let update = CoreDataManager.shared.updateList(id: listId, newTitle: newTitle)
        
        if update {
            titleField.text = newTitle
            showAlert("List updated successfully")
        } else {
            showAlert("Failed to update the list")
        }
        
    }
    
    @IBAction func onBackButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        titleField.text = newList?.title
        super.viewDidLoad()
    }
    
}

