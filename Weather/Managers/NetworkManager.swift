//
//  NetworkManager.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//


import Foundation
import CoreLocation


class NetworkManager {

    func fetchWeatherForCities(cityNames: [String], completion: @escaping ([CurrentCityWeather]) -> ()) {
        var weathers: [CurrentCityWeather] = []
        let myGroup = DispatchGroup()
        for cityName in cityNames {
            myGroup.enter()
            let name = cityName.split(separator: " ").joined(separator: "%20")
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(name)&apikey=\(apiKey)&units=metric"
            APICall(urlString: urlString) { weather in
                weathers.append(weather)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            completion(weathers)
        }
    }
    
    
    func fetchWeatherForCityByCoordinates(longtitude: CLLocationDegrees, latitude: CLLocationDegrees, completion: @escaping (CurrentCityWeather) -> ()) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(apiKey)&units=metric"
        APICall(urlString: urlString, completion: completion)
    }
    
    
    func fetchWeatherForecastForCity(name: String, completion: @escaping ([ShortCityWeather]) -> ()) {
        let cityName = name.split(separator: " ").joined(separator: "%20")
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&apikey=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, responce, error) in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let currentWeatherData = try decoder.decode(ShortCityWeatherData.self, from: data)
                    var fourDayForecast: [ShortCityWeather] = []
                    for forecast in currentWeatherData.weatherData {
                        if forecast.date.hasSuffix("12:00:00") {
                            let formatted = ShortCityWeather(oneDayForecast: forecast)
                            fourDayForecast.append(formatted)
                        }
                    }
                    fourDayForecast.removeLast()
                    completion(fourDayForecast)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
        task.resume()
    }
    
    
    func checkIfValidCityName(cityName: String, completion: @escaping (Bool) -> ()) {
        let name = cityName.split(separator: " ").joined(separator: "%20")
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(name)&apikey=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, responce, error) in
            completion((responce as! HTTPURLResponse).statusCode == 200 ? true : false)
        }
        task.resume()
    }
    

    fileprivate func APICall(urlString: String, completion: @escaping (CurrentCityWeather) -> ()){
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, responce, error) in
            if let data = data {
                if let currentWeather = self.JSONParse(withData: data) {
                    completion(currentWeather)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func JSONParse(withData data: Data) -> CurrentCityWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CurrentCityWeatherData.self, from: data)
            let currentWeather = CurrentCityWeather(currentWeatherData: currentWeatherData)
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}

