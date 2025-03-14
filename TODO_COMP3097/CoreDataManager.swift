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
            list.id = generateUniqueID()
            let newId = list.id!
            
            do {
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
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", withId)
        
        do {
            let lists = try context.fetch(fetchRequest)
            return lists.first
        } catch {
            print("Failed to fetch list: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func updateList(id: String, newTitle: String?) -> Bool {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let listToUpdate = results.first {
                if let newTitle = newTitle {
                    listToUpdate.title = newTitle
                }
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
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let lists = try container.viewContext.fetch(fetchRequest)
            if let listToDelete = lists.first {
                container.viewContext.delete(listToDelete)
                try container.viewContext.save()
                print("List deleted successfully")
            }
        } catch {
            print("Failed to delete list: \(error.localizedDescription)")
        }
    }
    
    
    
    func generateUniqueID() -> String {
        return UUID().uuidString
    }
    
    
}
