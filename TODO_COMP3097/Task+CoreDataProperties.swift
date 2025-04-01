//
//  Task+CoreDataProperties.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var priority: Int16
    @NSManaged public var id: String?
    @NSManaged public var list: List?
    @NSManaged public var status: Bool

}

extension Task : Identifiable {

}
