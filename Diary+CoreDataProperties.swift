//
//  Diary+CoreDataProperties.swift
//  3week_WeatherDiary
//
//  Created by sumin on 2021/09/27.
//
//

import Foundation
import CoreData


extension Diary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Diary> {
        return NSFetchRequest<Diary>(entityName: "Diary")
    }

    @NSManaged public var id: NSNumber!
    @NSManaged public var title: String!
    @NSManaged public var contents: String!
    @NSManaged public var deletedDate: Date?
    @NSManaged public var image: Data?

}

extension Diary : Identifiable {

}
