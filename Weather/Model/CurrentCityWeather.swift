//
//  CityTableWeather.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 19.01.2021.
//

import Foundation

struct CurrentCityWeather {
    let temperature: Double
    var temperatureString: String {
        return "\(Int(round(temperature))) °C"
    }
    
    let feelsLikeTempereture: Double
    var feelsLikeTemperatureString: String {
        return "\(Int(round(feelsLikeTempereture))) °C"
    }
    
    let wind: Double
    var widString: String {
        return "Wind: \(Int(wind)) kph"
    }
    
    let cityName: String
    
    let id: Int
    var icon: String {
        switch id {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.heavyrain.fill"
        case 600...622: return "cloud.snow.fill"
        case 700...781: return "cloud.fog.fill"
        case 800: return "sun.max.fill"
        case 801...802: return "cloud.sun.fill"
        case 803...804: return "cloud.fill"
        default: return "circle.dashed"
        }
    }
    
    init(currentWeatherData: CurrentCityWeatherData){
        temperature = currentWeatherData.main.temperature
        feelsLikeTempereture = currentWeatherData.main.feelsLikeTemperature
        cityName = currentWeatherData.cityName
        wind = currentWeatherData.wind.speed
        id = currentWeatherData.weather.first?.id ?? 1110
    }
}
