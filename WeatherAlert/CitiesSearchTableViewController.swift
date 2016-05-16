//
//  CitiesSearchTableViewController.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit

protocol CitiesSearchTableViewControllerDelegate : NSObjectProtocol {
    func citiesSearchController(controller: CitiesSearchTableViewController, didSelectCity city: CityWeather)
}

class CitiesSearchTableViewController: UITableViewController, UISearchResultsUpdating {

    private var cities: [CityWeather] = []
    weak var delegate: CitiesSearchTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        let cityInfo = cities[indexPath.row]
        var text = ""
        if let name = cityInfo.name {
            text += name
        }
        if let country = cityInfo.country {
            text += ", \(country)"
        }
        cell.textLabel?.text = text
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cityInfo = cities[indexPath.row]
        delegate?.citiesSearchController(self, didSelectCity: cityInfo)
    }
    
    
    
    // MARK: - Search results
    private var oldSearchText: String?
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let text = searchController.searchBar.text
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(CitiesSearchTableViewController.searchForCityName(_:)), object: oldSearchText)
        oldSearchText = text
        performSelector(#selector(CitiesSearchTableViewController.searchForCityName(_:)), withObject: text, afterDelay: 0.5)
    }
    
    func searchForCityName(text: String?) {
        guard text?.characters.count > 0 else {
            cities = []
            tableView.reloadData()
            return
        }
        view.showActivityView()
        CityList.sharedInstance.search(name: text!) { [weak self] cities in
            self?.cities = cities
            dispatch_async(dispatch_get_main_queue(), {
                self?.view.hideActivityView()
                self?.tableView.reloadData()
            })
        }

    }
}
