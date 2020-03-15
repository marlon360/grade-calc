//
//  Semester+CoreDataProperties.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 10.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//
//

import Foundation
import CoreData


extension Semester {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Semester> {
        return NSFetchRequest<Semester>(entityName: "Semester")
    }

    @NSManaged public var title: String?
    @NSManaged public var subjects: NSSet?
    
    public var subjectsArray: [Subject] {
        let set = subjects as? Set<Subject> ?? []
        return set.sorted {
            $0.title! < $1.title!
        }
    }

}

// MARK: Generated accessors for subjects
extension Semester {

    @objc(addSubjectsObject:)
    @NSManaged public func addToSubjects(_ value: Subject)

    @objc(removeSubjectsObject:)
    @NSManaged public func removeFromSubjects(_ value: Subject)

    @objc(addSubjects:)
    @NSManaged public func addToSubjects(_ values: NSSet)

    @objc(removeSubjects:)
    @NSManaged public func removeFromSubjects(_ values: NSSet)

}
