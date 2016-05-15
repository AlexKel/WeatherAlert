//
//  CityWeather+CoreDataProperties.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CityWeather {

    @NSManaged var name: String?
    @NSManaged var id: NSNumber?
    @NSManaged var dt: NSNumber?
    @NSManaged var weather: NSSet?
    @NSManaged var wind: Wind?

}
