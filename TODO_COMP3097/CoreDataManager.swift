//
//  CoreDataManager.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
import Foundation
import CoreData
import UIKit

class CoreDataManager: ObservableObject{
    static let shared = CoreDataManager()
    
    let container = NSPersistentContainer(name: "Storage")
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container.loadPersistentStores{description, error in if let e = error{
            print("CoreData failed to load: \(e.localizedDescription)")
        }
        }
    }
    
    
    
    
    func saveUser(name: String, email: String, password: String, salt: String){
        let user = User(context: context)
        user.name = name
        user.email = email
        user.password = password
        user.salt = salt
        
        do {
            try context.save()
        } catch {
            print("Failed to save user: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(withEmail email: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Failed to fetch user: \(error.localizedDescription)")
            return nil
        }
    }
    
   
    
    func fetchAllUsers() -> [User] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch all users: \(error.localizedDescription)")
            return []
        }
    }
    
    func saveList(title: String, email: String) -> String{
        if let user = fetchUser(withEmail: email) {
            let list = List(context: context)
            list.title = title
            list.email = user
            list.id = generateUniqueID() //assign unique id to list
            let newId = list.id!
            
            do {
                //try to save new list to Core Data and return the id of the new list 
                try context.save()
                return newId
                
            } catch {
                print("Failed to save list: \(error.localizedDescription)")
                return String()
            }
        }
        return String()
    }
    
    func fetchList(withId: String) -> List? {
        //create fetch request for list with matching id
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", withId)
        
        do {
            //fetch list from Core Data and return first list found
            let lists = try context.fetch(fetchRequest)
            return lists.first
        } catch {
            print("Failed to fetch list: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func updateList(id: String, newTitle: String?) -> Bool {
        //create fetch request for list with matching id
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            //fetch list using fetch request
            let results = try context.fetch(fetchRequest)
            //update the first list found
            if let listToUpdate = results.first {
                if let newTitle = newTitle {
                    listToUpdate.title = newTitle
                }
                //try to save changes
                try context.save()
                print("List updated successfully")
                return true
            } else {
                print("List not found")
                return false
            }
        } catch {
            print("Failed to update list: \(error)")
            return false
        }
    }
    
    func fetchListsForCurrentUser(withEmail: String) -> [List] {
       
        
        
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email.email == %@", withEmail)
        
        do {
            let lists = try container.viewContext.fetch(fetchRequest)
            return lists
            
        } catch {
            print("Failed to fetch lists for user with email \(withEmail): \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteList(withId id: String) {
        //create fetch request for list with matching id
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            //delete first list found
            let lists = try container.viewContext.fetch(fetchRequest)
            //attempt to delete first list found
            if let listToDelete = lists.first {
                container.viewContext.delete(listToDelete)
                //try to save changes
                try container.viewContext.save()
                print("List deleted successfully")
            }
        } catch {
            print("Failed to delete list: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(withId id: String) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let task = try container.viewContext.fetch(fetchRequest)
            if let taskToDelete = task.first {
                container.viewContext.delete(taskToDelete)
                try container.viewContext.save()
                print("Task deleted successfully")
            }
        } catch {
            print("Failed to delete task: \(error.localizedDescription)")
        }
    }
    
    
    func saveTask(title: String, desc: String?, priority: Int, list: List) -> Task? {
        let task = Task(context: context)
        task.id = generateUniqueID() //assing unique id
        task.title = title
        task.desc = desc
        task.priority = Int16(priority)
        task.list = list //link task to specified list
        task.status = false
        
        do {
            try context.save()
            print("Task saved successfully")
            return task
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func updateTask(id: String, newTitle: String?, newDesc: String?, newPriority: Int?, newStatus: Bool?) -> Bool {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do{
            let tasks = try context.fetch(fetchRequest)
            
            if let taskToUpdate = tasks.first {
                if let newTitle = newTitle {
                    taskToUpdate.title = newTitle
                }
                if let newDesc = newDesc {
                    taskToUpdate.desc = newDesc
                }
                if let newPriority = newPriority {
                    taskToUpdate.priority = Int16(newPriority)
                }
                if let newStatus = newStatus {
                    taskToUpdate.status = newStatus
                }
                try context.save()
                print("Task updated successfully")
                return true
            } else {
                print("Task not found")
                return false
            }
        } catch {
            print("Failed to update task: \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchTasks(forListId listId: String) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "list.id == %@", listId)
        
        do{
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch {
            print("Failed to fetch tasks for list with id \(listId): \(error.localizedDescription)")
            return []
        }
    }
    
    //create unique UUID string
    func generateUniqueID() -> String {
        return UUID().uuidString
    }
    
    
 
    
    
}
