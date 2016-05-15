//
//  BasicWeatherTableViewCell.swift
//  WeatherAlert
//
//  Created by Aleksandr Kelbas on 15/05/2016.
//  Copyright © 2016 Motionly Ltd. All rights reserved.
//

import UIKit

class BasicWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degreesLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
