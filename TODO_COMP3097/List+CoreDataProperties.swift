//
//  List+CoreDataProperties.swift
//  TODO_COMP3097
//
//  Created by Will on 2025-03-11.
//
//

import Foundation
import CoreData


extension List {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<List> {
        return NSFetchRequest<List>(entityName: "List")
    }

    @NSManaged public var title: String?
    @NSManaged public var id: String?
    @NSManaged public var email: User?

}

extension List : Identifiable {

}
