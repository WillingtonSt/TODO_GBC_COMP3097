//
//  User+CoreDataProperties.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var password: String?
    @NSManaged public var salt: String?

}

extension User : Identifiable {

}
