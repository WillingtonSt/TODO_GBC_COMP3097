

import Foundation
import CoreData
import UIKit

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    let container = NSPersistentContainer(name: "Storage")

    var context: NSManagedObjectContext {
        return container.viewContext
    }

    init() {
        container.loadPersistentStores { description, error in
            if let e = error {
                print("CoreData failed to load: \(e.localizedDescription)")
            }
        }
    }

    
    func saveUser(name: String, email: String, password: String, salt: String) {
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
            return try context.fetch(fetchRequest).first
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

    
    func saveList(title: String, email: String) -> String {
        guard let user = fetchUser(withEmail: email) else { return "" }

        let list = List(context: context)
        list.title = title
        list.email = user
        list.id = generateUniqueID()

        do {
            try context.save()
            return list.id ?? ""
        } catch {
            print("Failed to save list: \(error.localizedDescription)")
            return ""
        }
    }

    func fetchList(withId: String) -> List? {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", withId)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Failed to fetch list: \(error.localizedDescription)")
            return nil
        }
    }

    func updateList(id: String, newTitle: String?) -> Bool {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let list = try context.fetch(fetchRequest).first {
                if let newTitle = newTitle {
                    list.title = newTitle
                }
                try context.save()
                return true
            }
        } catch {
            print("Failed to update list: \(error.localizedDescription)")
        }
        return false
    }

    func fetchListsForCurrentUser(withEmail email: String) -> [List] {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email.email == %@", email)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch lists: \(error.localizedDescription)")
            return []
        }
    }

    func deleteList(withId id: String) {
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let list = try context.fetch(fetchRequest).first {
                context.delete(list)
                try context.save()
            }
        } catch {
            print("Failed to delete list: \(error.localizedDescription)")
        }
    }

    
    func deleteTask(withId id: String) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let task = try context.fetch(fetchRequest).first {
                context.delete(task)
                try context.save()
            }
        } catch {
            print("Failed to delete task: \(error.localizedDescription)")
        }
    }

    func saveTask(title: String, desc: String?, priority: Int, list: List) -> Task? {
        let task = Task(context: context)
        task.id = generateUniqueID()
        task.title = title
        task.desc = desc
        task.priority = Int16(priority)
        task.list = list
        task.status = false

        do {
            try context.save()
            return task
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
            return nil
        }
    }

    func updateTask(id: String, newTitle: String?, newDesc: String?, newPriority: Int?, newStatus: Bool?) -> Bool {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            if let task = try context.fetch(fetchRequest).first {
                if let newTitle = newTitle { task.title = newTitle }
                if let newDesc = newDesc { task.desc = newDesc }
                if let newPriority = newPriority { task.priority = Int16(newPriority) }
                if let newStatus = newStatus { task.status = newStatus }
                try context.save()
                return true
            }
        } catch {
            print("Failed to update task: \(error.localizedDescription)")
        }
        return false
    }

    func fetchTasks(forListId listId: String) -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "list.id == %@", listId)

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
            return []
        }
    }

    
    func saveReminder(dueDate: Date, list: List) {
            let reminder = Reminder(context: context)
            reminder.dueDate = dueDate
            reminder.list = list

            do {
                try context.save()
            } catch {
                print("Failed to save reminder: \(error.localizedDescription)")
            }
        }

    func fetchUserReminders(withEmail email: String) -> [Reminder] {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        request.predicate = NSPredicate(format: "list.email.email == %@", email)

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch reminders: \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Utility
    func generateUniqueID() -> String {
        return UUID().uuidString
    }
}
