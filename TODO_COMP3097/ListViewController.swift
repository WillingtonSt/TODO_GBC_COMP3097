//
//  ListViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var newList: List?
    var tasks: [Task] = []
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var taskTable: UITableView!
    
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
    
    
    func fetchTasksForList(){
        guard let list = newList else {return}
        
        tasks = CoreDataManager.shared.fetchTasks(forListId: list.id!)
        
        tasks.sort { (task1, task2) -> Bool in
            return task1.priority > task2.priority
        }
        
        taskTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTask = tasks[indexPath.row]
        
        self.performSegue(withIdentifier: "taskViewSegue", sender: selectedTask)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            
            
            CoreDataManager.shared.deleteTask(withId: task.id!)
            
            tasks.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = tasks[indexPath.row]
        
        // Clear previous content from cell
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // Set task title
        let titleLabel = UILabel()
        titleLabel.text = task.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(titleLabel)
        
        switch task.priority {
        case 0:
            titleLabel.textColor = UIColor.systemGreen
        case 1:
            titleLabel.textColor = UIColor.systemOrange
        case 2:
            titleLabel.textColor = UIColor.systemRed
        default:
            titleLabel.textColor = UIColor.black //default colour
        }
        
        if task.status {
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: task.title ?? "")
            attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributeString.length))
            titleLabel.attributedText = attributeString
        }
        
        // Create checkbox button
        let checkboxButton = UIButton(type: .custom)
        checkboxButton.tag = indexPath.row
        
        // Set checkbox image based on task status
        let checkboxImage = task.status ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        checkboxButton.setImage(checkboxImage, for: .normal)
        
        // Add target for button tap
        checkboxButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
        
        // Add checkbox to content view
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(checkboxButton)
        
        // Auto Layout Constraints for checkbox
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
            checkboxButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 50),
            checkboxButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Auto Layout Constraints for title label (align it to the right)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        return cell
    }

    @objc func checkboxTapped(_ sender: UIButton) {
        let task = tasks[sender.tag]
        task.status.toggle()
        CoreDataManager.shared.updateTask(id: task.id!, newTitle: nil, newDesc: nil, newPriority: nil, newStatus: task.status)
        
        taskTable.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
    }
    
    
    //display current title of list when the view loads
    override func viewDidLoad() {
        titleField.text = newList?.title
        super.viewDidLoad()
        fetchTasksForList()
        taskTable.delegate = self
        taskTable.dataSource = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTasksForList()
    }
    
}

