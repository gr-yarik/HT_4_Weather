//
//  FourDayForecast.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 20.01.2021.
//

import Foundation

struct ShortCityWeather {
    let temperature: Double
    var temperatureString: String {
        return "\(Int(round(temperature))) °C"
    }

    let date: String
    var dateConverted: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "DD.MM"
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(dateSince1970)))
        
    }
    
    let dateSince1970: Int
    
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
    
    init(oneDayForecast: OneDayForecast){
        temperature = oneDayForecast.main.temperature
        date = oneDayForecast.date
        id = oneDayForecast.weather.first?.id ?? 110
        dateSince1970 = oneDayForecast.dateSince1970
    }
}
