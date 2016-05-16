//
//  WeatherForecastTableViewController.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 16/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit

class WeatherForecastTableViewController: UITableViewController {

    var city: CityWeather!
    private var forecast: [[String : AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if city == nil {
            fatalError("You must pass city object to this view controller with valid id")
        }
        navigationItem.title = city.name
        
        if let idx = city.id {
            view.showActivityViewWithLabel("Getting forecast")
            API.sharedInstance.executeEndpoint(Endpoints.GetWeatherForecast, withParameters: ["id" : idx, "unit" : "metric"]) { [weak self] (response, error) in
                self?.view.hideActivityView()
                if let responseObj = response as? [String : AnyObject], list = responseObj["list"] as? [[String : AnyObject]] where error == nil {
                    self?.forecast = list
                    self?.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Failed to load forecast :(", message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
                    self?.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return forecast.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ForecastWeatherTableViewCell", forIndexPath: indexPath) as! ForecastWeatherTableViewCell

        // Configure the cell...
        let weatherInfo = forecast[indexPath.row]
        let weatherArr = weatherInfo["weather"] as? [[String : AnyObject]]
        let main = weatherInfo["main"] as? [String : AnyObject]
        let wind = weatherInfo["wind"] as? [String : AnyObject]
        
        if let weather = weatherArr?.first, icon = weather["icon"] as? String, imageURL = NSURL(string: "http://openweathermap.org/img/w/\(icon).png") {
            cell.weatherImageView.hnk_setImageFromURL(imageURL)
        } else {
            cell.weatherImageView.image = nil
        }
        
        if let dt = weatherInfo["dt"] as? Int {
            cell.setDate(dt)
        } else {
            cell.dateLabel.text = nil
        }
        
        if let temp = main?["temp"] as? Double {
            cell.temperatureLabel.text = "\(Int(convertKelvinToCelsius(temp)))"
        } else {
            cell.temperatureLabel.text = nil
        }
        
        if let windSpeed = wind?["speed"] as? Double {
            let nf = NSNumberFormatter()
            nf.maximumFractionDigits = 2
            let text = nf.stringFromNumber(NSNumber(double: windSpeed))!
            cell.windSpeedLabel.text = "wind mps: \(text)"
        } else {
            cell.windSpeedLabel.text = nil
        }
        

        return cell
    }
    
    /**
     For some reason, forecast doesn't return metric parameters even if asked.
     
     - parameter temp: temperature in Kelvin
     
     - returns: Termperature in Celsius
     */
    func convertKelvinToCelsius(temp: Double) -> Double {
        return temp - 273.15
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
