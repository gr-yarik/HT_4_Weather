//
//  DetailedWeatherViewController.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 20.01.2021.
//

import UIKit

class DetailedWeatherViewController: DataLoadingVC {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var botomView: UIView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var cityWeather: CurrentCityWeather!
    var networkManager: NetworkManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager = NetworkManager()
        setUpView()
        getForecast()
        presentPassedCityWeather()
    }
    
    
    func setUpView() {
        topView.layer.cornerRadius = 20
        botomView.layer.cornerRadius = 20
    }
    
    
    func getForecast() {
        showLoadingView()
        networkManager.fetchWeatherForecastForCity(name: cityWeather.cityName) { [weak self] forecasts in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.dismissLoadingView()
                self.presentForecast(with: forecasts)
            }
        }
    }
    
    
    func presentPassedCityWeather() {
        cityNameLabel.text = cityWeather.cityName
        temperatureLabel.text = cityWeather.temperatureString
        feelsLikeTemperatureLabel.text = cityWeather.feelsLikeTemperatureString
        windLabel.text = cityWeather.widString
        weatherImageView.image = UIImage(systemName: cityWeather.icon)
    }
    
    
    func presentForecast(with forecasts: [ShortCityWeather]) {
        var i = 1
        for forecast in forecasts {
            for _ in 0...2 {
                switch i % 3 {
                case 1:
                    let dateLabel = view.viewWithTag(i) as! UILabel
                    dateLabel.text = forecast.dateConverted
                case 2:
                    let iconImageView = view.viewWithTag(i) as! UIImageView
                    iconImageView.image = UIImage(systemName: forecast.icon)
                case 0:
                    let tempLabel = view.viewWithTag(i) as! UILabel
                    tempLabel.text = forecast.temperatureString
                default:
                    return
                }
                i += 1
            }
        }
    }
}
