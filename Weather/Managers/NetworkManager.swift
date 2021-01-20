//
//  NetworkManager.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//


import Foundation
import CoreLocation

protocol NetworkManagerDelegate {
    func updateUI(_ : NetworkManager, withWeather currentWeather: CityTableWeather)
}

class NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    var onCompletion: ((CityTableWeather?, [CityTableWeather]?, [FourDayForecast]?, ResponceType) -> Void)?
    
    enum RequestType {
        case byCityName(cityName: String)
        case byCityNames(cityNames: [String])
        case byCoordinates(longtitude: CLLocationDegrees, latitude: CLLocationDegrees)
    }
    
    enum ResponceType {
        case forLiveLocation
        case forStoredCity
        case forStoredCities
        case forFourDays
    }
    
    
    func fetchCurrentWeather(searchBy requestType: RequestType) {
        switch requestType {
        case .byCityName(let name):
            let cityName = name.split(separator: " ").joined(separator: "%20")
            let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&apikey=\(apiKey)&units=metric"
            guard let url = URL(string: urlString) else { return }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responce, error) in
//                print(responce as! HTTPURLResponse)
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let currentWeatherData = try decoder.decode(FourDayForecastData.self, from: data)
                        var fourDayForecast: [FourDayForecast] = []
                        for forecast in currentWeatherData.weatherData {
                            if forecast.date.hasSuffix("12:00:00") {
                                let formatted = FourDayForecast(oneDayForecast: forecast)
                                fourDayForecast.append(formatted)
                            }
                        }
                        fourDayForecast.removeLast()
                        self.onCompletion?(nil, nil, fourDayForecast, .forFourDays)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
//                        completion(currentWeather)
                    
                }
            }
            task.resume()
            
            APICall(urlString: urlString) { weather in
                self.onCompletion?(weather, nil, nil, .forStoredCity)
            }
            
        case .byCoordinates(let longtitude, let latitude):
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(apiKey)&units=metric"
            APICall(urlString: urlString) { weather in
                self.onCompletion?(weather, nil, nil, .forLiveLocation)
            }
            
        case .byCityNames(let names):
            var weathers: [CityTableWeather] = []
            let myGroup = DispatchGroup()
            for cityName in names {
                myGroup.enter()
                let name = cityName.split(separator: " ").joined(separator: "%20")
                let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(name)&apikey=\(apiKey)&units=metric"
                APICall(urlString: urlString) { weather in
                    weathers.append(weather)
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.onCompletion?(nil, weathers, nil, .forStoredCities)
               }
        }
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
    
//    
    fileprivate func APICall (urlString: String, completion: @escaping (CityTableWeather) -> ()){
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
    
    fileprivate func JSONParse(withData data: Data) -> CityTableWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            let currentWeather = CityTableWeather(currentWeatherData: currentWeatherData)
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}

