//
//  Weather+CoreDataProperties.swift
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

extension Weather {

    @NSManaged var id: NSNumber?
    @NSManaged var main: String?
    @NSManaged var desc: String?
    @NSManaged var icon: String?
    @NSManaged var cityWeather: CityWeather?

}
