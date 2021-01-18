//
//  CityTableViewCell.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    func setCell(name: String, icon: UIImage, tempeature: String) {
        nameLabel.text = name
        iconImageView.image = icon
        temperatureLabel.text = tempeature
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
