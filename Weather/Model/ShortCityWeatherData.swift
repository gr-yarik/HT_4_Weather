//
//  FourDayForecastData.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 20.01.2021.
//

import Foundation

struct ShortCityWeatherData: Codable {
    let weatherData: [OneDayForecast]
    
    enum CodingKeys: String, CodingKey {
        case weatherData = "list"
    }
}

struct OneDayForecast: Codable {
    let weather: [Weather]
    let main: Main
    let date: String
    let dateSince1970: Int
    
    enum CodingKeys: String, CodingKey {
        case weather
        case main
        case date = "dt_txt"
        case dateSince1970 = "dt"
    }
}
