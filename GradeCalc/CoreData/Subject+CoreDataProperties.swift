//
//  Subject+CoreDataProperties.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//
//

import Foundation
import CoreData


extension Subject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subject> {
        return NSFetchRequest<Subject>(entityName: "Subject")
    }

    @NSManaged public var title: String?
    @NSManaged public var weight: Float
    @NSManaged public var exams: NSSet?
    @NSManaged public var semester: Semester?

}

// MARK: Generated accessors for exams
extension Subject {

    @objc(addExamsObject:)
    @NSManaged public func addToExams(_ value: Exam)

    @objc(removeExamsObject:)
    @NSManaged public func removeFromExams(_ value: Exam)

    @objc(addExams:)
    @NSManaged public func addToExams(_ values: NSSet)

    @objc(removeExams:)
    @NSManaged public func removeFromExams(_ values: NSSet)

}
