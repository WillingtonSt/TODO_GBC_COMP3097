import UIKit

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var upcomingReminderLabel: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var listContainer: UITableView!
    @IBOutlet weak var setReminderButton: UIButton!
    @IBOutlet weak var createListButton: UIButton!
    @IBOutlet weak var reminderContainerView: UIView!
    
    
    var searchController: UISearchController!
    
    
    var newList: List?
    var reminderTimer: Timer?
    var lists: [List] = []
    var filteredLists: [List] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        listContainer.dataSource = self
        listContainer.delegate = self
        clockImageView.image = UIImage(systemName: "clock.fill")?.withRenderingMode(.alwaysTemplate)
        clockImageView.tintColor = .systemGreen // default
        reminderContainerView.layer.cornerRadius = 12
        reminderContainerView.layer.borderWidth = 1
        reminderContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        reminderContainerView.layer.masksToBounds = true
        
        
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: email)
            filteredLists = lists
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            lists = CoreDataManager.shared.fetchListsForCurrentUser(withEmail: email)
            filteredLists = lists
            listContainer.reloadData()
        }
        
        reminderTimer?.invalidate()
        reminderTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            self?.displayNextUpcomingReminder()
        }
        
        displayNextUpcomingReminder()
    }
    
    func displayNextUpcomingReminder() {
        guard let currEmail = UserDefaults.standard.string(forKey: "currentUserEmail") else {
            upcomingReminderLabel.text = "No user email found"
            return
        }
        
        let reminders = CoreDataManager.shared.fetchUserReminders(withEmail: currEmail).filter {
            $0.dueDate ?? Date.distantPast > Date()
        }
        
        if let next = reminders.sorted(by: { $0.dueDate ?? Date() < $1.dueDate ?? Date() }).first,
           let due = next.dueDate {
            
            let timeRemaining = due.timeIntervalSinceNow
            let hours = Int(timeRemaining / 3600)
            let minutes = Int((timeRemaining.truncatingRemainder(dividingBy: 3600)) / 60)
            
            upcomingReminderLabel.text = "\(next.list?.title ?? "Reminder") in \(hours)h \(minutes)m"
            
            
            // Set tint color
            switch timeRemaining {
            case ..<3600:
                clockImageView.tintColor = .systemRed
            case ..<86400:
                clockImageView.tintColor = .systemOrange
            default:
                clockImageView.tintColor = .systemGreen
            }
            
        } else {
            upcomingReminderLabel.text = "No upcoming reminders"
        }
    }
    
  
    @IBAction func createListButtonTapped(_ sender: UIButton) {
        if let email = UserDefaults.standard.string(forKey: "currentUserEmail") {
            let id = CoreDataManager.shared.saveList(title: "New List", email: email)
            if let savedList = CoreDataManager.shared.fetchList(withId: id) {
                newList = savedList
                showAlert("New List Created") {
                    self.performSegue(withIdentifier: "showListsSegue", sender: self)
                }
            }
        }
    }
    
    @IBAction func addReminderButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showReminderSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showListsSegue",
           let destinationVC = segue.destination as? ListViewController {
            destinationVC.newList = newList
        }
    }
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completion?() }))
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
 
        newList = filteredLists[indexPath.row]
        
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
                
                let list = filteredLists[indexPath.row]
                if let id = list.id {
                    CoreDataManager.shared.deleteList(withId: id)
                    lists.removeAll { $0.id == id }
                    filteredLists.remove(at: indexPath.row)
                    
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
}
