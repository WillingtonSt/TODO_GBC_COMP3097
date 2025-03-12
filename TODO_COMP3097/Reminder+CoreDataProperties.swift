//
//  Reminder+CoreDataProperties.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var dueDate: Date?
    @NSManaged public var list: List?

}

extension Reminder : Identifiable {

}
