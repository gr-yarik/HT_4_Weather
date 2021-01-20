//
//  FourDayForecastData.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 20.01.2021.
//

import Foundation

struct FourDayForecastData: Codable {
    let weatherData: [OneDayForecast]
    
    enum CodingKeys: String, CodingKey {
        case weatherData = "list"
    }
}

struct OneDayForecast: Codable {
    let weather: [Weather]
    let main: Main
//    let cityName: String
    let date: String
    let dateSince1970: Int
    
    enum CodingKeys: String, CodingKey {
        case weather
        case main
//        case cityName = "name"
        case date = "dt_txt"
        case dateSince1970 = "dt"
    }
}
