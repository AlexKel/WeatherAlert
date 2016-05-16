//
//  WeatherTableViewController.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit
import CoreData
import RNActivityView
import Haneke


class WeatherTableViewController: UITableViewController, CitiesSearchTableViewControllerDelegate {

    let citiesSearchResultsController = CitiesSearchTableViewController()
    var searchController = UISearchController()
    var fetchedResultsController: NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citiesSearchResultsController.delegate = self
        searchController = UISearchController(searchResultsController: citiesSearchResultsController)
        searchController.searchResultsUpdater = citiesSearchResultsController
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.prompt = "Enter town or city"
        
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar
        
        setupFetchedResultsController()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "CityWeather")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "favourite == %@", true)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDM.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Root")
        fetchedResultsController?.delegate = self
        try! fetchedResultsController?.performFetch()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicWeatherCell", forIndexPath: indexPath) as! BasicWeatherTableViewCell
        
        if let weatherInfo = fetchedResultsController?.fetchedObjects?[indexPath.row] as? CityWeather {
            cell.cityNameLabel.text = weatherInfo.name
            if let icon = weatherInfo.weather?.icon, imageURL = NSURL(string: "http://openweathermap.org/img/w/\(icon).png") {
                cell.weatherImageView.hnk_setImageFromURL(imageURL)
            }
            if let temp = weatherInfo.temp {
                cell.degreesLabel.text = "\(temp.intValue)"
            }
            
            
        } else {
            cell.cityNameLabel.text = nil
            cell.weatherImageView.image = nil
        }
    
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let cityInfo = fetchedResultsController?.fetchedObjects?[indexPath.row] as? CityWeather {
                tableView.beginUpdates()
                
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                cityInfo.favourite = false
                CDM.sharedInstance.saveContext()
                
                tableView.endUpdates()
            }
        }
    }
    
    // MARK: - Cities search delegate
    func citiesSearchController(controller: CitiesSearchTableViewController, didSelectCity city: CityWeather) {
        searchController.active = false
        guard city.name != nil else {return}
        
        navigationController?.view.showActivityViewWithLabel("Loading", detailLabel: "Please wait")
        API.sharedInstance.executeEndpoint(Endpoints.GetCurrentWeather, withParameters: ["id" : city.id!, "units" : "metric"]) { [weak self] response, error in
            self?.navigationController?.view.hideActivityView()
            if let weatherObject = response as? [String : AnyObject] where error == nil {
            
                if let id = response?["id"] as? Int, cityWeather = CityWeather.fetch(id) as? CityWeather {
                    cityWeather.mapJSON(weatherObject)
                    cityWeather.favourite = true
                } else {
                    let cityWeather = CityWeather(jsonObject: weatherObject)
                    cityWeather?.favourite = true
                }
                
                CDM.sharedInstance.saveContext()
            } else {
                // TODO: Show error aler
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? WeatherForecastTableViewController, cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell), cityInfo = fetchedResultsController?.fetchedObjects?[indexPath.row] as? CityWeather {
            dest.city = cityInfo
        }
    }

}

extension WeatherTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case NSFetchedResultsChangeType.Insert:
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
        case NSFetchedResultsChangeType.Delete:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRowsAtIndexPaths([deleteIndexPath], withRowAnimation: .Fade)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

