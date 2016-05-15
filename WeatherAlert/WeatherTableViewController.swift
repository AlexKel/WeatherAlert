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
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: "CityWeather")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CDM.sharedInstance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
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
            
        } else {
            cell.cityNameLabel.text = nil
            cell.weatherImageView.image = nil
        }
    
        
        return cell
    }
    
    // MARK: - Cities search delegate
    func citiesSearchController(controller: CitiesSearchTableViewController, didSelectCity city: City) {
        searchController.active = false
        guard city.name != nil else {return}
        
        navigationController?.view.showActivityViewWithLabel("Loading", detailLabel: "Please wait")
        API.sharedInstance.executeEndpoint(Endpoints.GetCurrentWeather, withParameters: ["id" : city.name!]) { [weak self] response, error in
            if let weatherObject = response as? [String : AnyObject] where error == nil {
                CityWeather(jsonObject: weatherObject)
            } else {
                // TODO: Show error aler
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    
    }

}

extension WeatherTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.reloadData()
    }
}

