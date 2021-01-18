//
//  CityTableWeatherData.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 19.01.2021.
//

import Foundation

struct CityTableWeatherData: Codable {
    let weather: [Weather]
    let main: Main
    let cityName: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case main
        case cityName = "name"
    }
}

struct Main: Codable {
    let temperature: Double
    let feelsLikeTemperature: Double
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLikeTemperature = "feels_like"
    }
}

struct Weather: Codable {
    let id: Int
}
