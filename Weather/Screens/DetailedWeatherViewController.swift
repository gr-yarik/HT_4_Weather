//
//  DetailedWeatherViewController.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 20.01.2021.
//

import UIKit

class DetailedWeatherViewController: UIViewController {
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var botomView: UIView!
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeTemperatureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    var forecasts: [FourDayForecast] = []
    
    var cityWeather: CityTableWeather!
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        topView.layer.cornerRadius = 20
        botomView.layer.cornerRadius = 20
        networkManager.onCompletion = { [weak self] weather, _, forecast, responceType in
            guard let self = self else { return }
            switch responceType {
            case .forLiveLocation:
                break
            case .forStoredCity:
                break
            case .forStoredCities:
                break
            case .forFourDays:
                //                print(forecast!.count)
                self.forecasts = forecast!
                
            }
            DispatchQueue.main.async {
                self.presentForecast()
            }
        }
        presentCityWeather()
        //        print(cityName)
        //        networkManager.fetchCurrentWeather(searchBy: .byCityName(cityName: cityName!))
        networkManager.fetchCurrentWeather(searchBy: .byCityName(cityName: cityWeather.cityName))
        super.viewDidLoad()
    }
    
    
    func presentForecast() {
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
    
    
    func presentCityWeather() {
        cityNameLabel.text = cityWeather.cityName
        temperatureLabel.text = cityWeather.temperatureString
        feelsLikeTemperatureLabel.text = cityWeather.feelsLikeTemperatureString
        windLabel.text = cityWeather.widString
        weatherImageView.image = UIImage(systemName: cityWeather.icon)
    }
}
