//
//  HomeViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var newList: List?
    
    var lists: [List] = []
    
    @IBOutlet weak var listContainer: UITableView!
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
        
        if segue.identifier == "showListsSegue" {
            
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        let list = lists[indexPath.row]
        cell.textLabel?.text = list.title
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = lists[indexPath.row]
        print("Selected List: \(selectedList.title ?? "Unnamed List")")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let listToDelete = lists[indexPath.row]
            
            if let listId = listToDelete.id {
                CoreDataManager.shared.deleteList(withId: listId)
                lists.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    
    override func viewDidLoad() {
        guard let currEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            showAlert("Error finding User Email")
            return
        }
        
         lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: currEmail)
        
        listContainer.dataSource = self
        listContainer.delegate = self
        listContainer.reloadData()
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let currEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            showAlert("Error finding User Email")
            return
        }
        
         lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: currEmail)
        
        listContainer.dataSource = self
        listContainer.delegate = self
        listContainer.reloadData()
        
        super.viewWillAppear(animated)
    }
    
    
    
    }


    
    

