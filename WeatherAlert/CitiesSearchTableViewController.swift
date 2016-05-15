//
//  CitiesSearchTableViewController.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit

class CitiesSearchTableViewController: UITableViewController, UISearchResultsUpdating {

    private var cities: [City] = []
    
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
        cell.textLabel?.text = cityInfo.name! + ", " + cityInfo.country!
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cityInfo = cities[indexPath.row]
        print("cityInfo")
    }
    
    // MARK: - Search results
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard searchController.searchBar.text?.characters.count > 0 else {
            cities = []
            tableView.reloadData()
            return
        }
        
        CityList.sharedInstance.search(name: searchController.searchBar.text!) { [weak self] cities in
            self?.cities = cities
            self?.tableView.reloadData()
        }
    }
}
