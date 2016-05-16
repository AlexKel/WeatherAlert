//
//  CityWeather+CoreDataProperties.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 16/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CityWeather {

    @NSManaged var dt: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var favourite: NSNumber?
    @NSManaged var country: String?
    @NSManaged var temp: NSNumber?
    @NSManaged var weather: Weather?
    @NSManaged var wind: Wind?

}
