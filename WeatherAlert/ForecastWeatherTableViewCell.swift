//
//  ForecastWeatherTableViewCell.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 16/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit

class ForecastWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    
    func setDate(dt: Int) {
        let df = NSDateFormatter()
        df.dateFormat = "dd MMM, HH:mm"
        df.locale = NSLocale(localeIdentifier: "en_US")
        let date = NSDate(timeIntervalSince1970: Double(dt))
        let text = df.stringFromDate(date)
        dateLabel.text = text
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
