//
//  Exam+CoreDataProperties.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 08.03.20.
//  Copyright © 2020 Marlon Lückert. All rights reserved.
//
//

import Foundation
import CoreData


extension Exam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exam> {
        return NSFetchRequest<Exam>(entityName: "Exam")
    }

    @NSManaged public var title: String?
    @NSManaged public var grade: Float
    @NSManaged public var createdAt: Date?
    @NSManaged public var weight: Float
    @NSManaged public var subject: Subject?

}
