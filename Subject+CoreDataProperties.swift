//
//  Subject+CoreDataProperties.swift
//  GradeCalc
//
//  Created by Marlon Lückert on 10.03.20.
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
    @NSManaged public var grade: Float
    @NSManaged public var active: Bool
    @NSManaged public var simulation: Bool
    @NSManaged public var simMin: Float
    @NSManaged public var simMax: Float
    @NSManaged public var semester: Semester?

}
