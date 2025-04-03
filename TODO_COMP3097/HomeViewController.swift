//
//  HomeViewController.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var newList: List?
    
    var lists: [List] = []
    var filteredLists: [List] = []
    
    @IBOutlet weak var listContainer: UITableView!
    @IBOutlet weak var setReminderButton: UIButton!
    @IBOutlet weak var createListButton: UIButton!
    
    var searchController: UISearchController!
    
    @IBAction func createListButtonTapped(_ sender: UIButton) {
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail"){
            //Save List in CoreData with default name of "New List"
            let id = CoreDataManager.shared.saveList(title: "New List", email: email)
            //Fetch List after saving it
            if let savedList = CoreDataManager.shared.fetchList(withId: id) {
                newList = savedList
                
                showAlert("New List Created"){
                    self.performSegue(withIdentifier: "showListsSegue", sender: self)
                }
            }
            //Show an alert confirming List creation and then segue to ListView
            
        } else {
            //Popup of error if List creation fails
            showAlert("Error creating new list")
        }
            
    }
    
    //Run this before segue occurs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Ensure the correct segue is being performed
        if segue.identifier == "showListsSegue" {
            
            //Get destination view controller
            if let destinationVC = segue.destination as? ListViewController {
                destinationVC.newList = newList
            }
            
        }
    }
    
    //generic function to display pop up messages
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in completion?()}))
        present(alert, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: searchText)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredLists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let list = filteredLists[indexPath.row]
        cell.textLabel?.text = list.title
        
        return cell
    }
    
    func updateSearchResults(for searchText: String) {
         if searchText.isEmpty {
             filteredLists = lists
         } else {
             filteredLists = lists.filter {
                 list in return list.title?.lowercased().contains(searchText.lowercased()) ?? false
             }
         }
         
         listContainer.reloadData()
     }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedList = filteredLists[indexPath.row]
        newList = selectedList
        print("Selected List: \(selectedList.title ?? "Unnamed List")")
        performSegue(withIdentifier: "showListsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let listToDelete = filteredLists[indexPath.row]
            
            if let listId = listToDelete.id {
                //Delete the list from CoreData by ID
                CoreDataManager.shared.deleteList(withId: listId)
                //Remove list from local array as well as table view
                lists.removeAll {$0.id == listId}
                lists.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    
    override func viewDidLoad() {
        
       
        searchBar.delegate = self
        //attempt to fetch email of the current user
        guard let currEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            showAlert("Error finding User Email")
            return
        }
        //fetch all lists from user with matching email
        lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: currEmail)
        filteredLists = lists
        listContainer.dataSource = self
        listContainer.delegate = self
        listContainer.reloadData()
        
        super.viewDidLoad()
        
    }
    
    //reload the lists everytime this screen appears
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


    
    

