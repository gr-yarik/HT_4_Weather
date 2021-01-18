//
//  NetworkManager.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//


import Foundation
import CoreLocation

protocol NetworkManagerDelegate {
    func updateUI(_ : NetworkManager, withWeather currentWeather: [CityTableWeather])
}

class NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    enum RequestType {
        case byCityNames(cityNames: [String])
        case byCityName(cityName: String)
        case byCoordinates(longtitude: CLLocationDegrees, latitude: CLLocationDegrees)
    }
    
    func fetchCurrentWeather(searchBy requestType: RequestType, completion: ([CityTableWeather]) -> ()) {
        var url = ""
        switch requestType {
        case .byCityNames(let cityNames):
            var weathers: [CityTableWeather] = []
            for name in cityNames {
                url = "https://api.openweathermap.org/data/2.5/weather?q=\(name)&apikey=\(apiKey)&units=metric"
                APICall(urlString: url) { (weather) in
                    print(weather)
                    weathers.append(weather)
                }
            }
            print(weathers)
            completion(weathers)
        case .byCityName(let cityName):
            url = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&apikey=\(apiKey)&units=metric"
            
        case .byCoordinates(let longtitude, let latitude):
            url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(apiKey)&units=metric"
            
        }
//        APICall(urlString: url)
    }
    
    fileprivate func APICall (urlString: String, completion: @escaping (CityTableWeather) -> ()) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, responce, error) in
//            print(data)
            if let data = data {
                let weather = self.JSONParse(withData: data)
                print(weather)
                completion(weather)
            }
        }
        task.resume()
    }
    
    fileprivate func JSONParse(withData data: Data) -> CityTableWeather {
        print(data)
        let decoder = JSONDecoder()
        var currentWeather: CityTableWeather!
        do {
            let currentWeatherData = try decoder.decode(CityTableWeatherData.self, from: data)
            currentWeather = CityTableWeather(currentWeatherData: currentWeatherData)
            return currentWeather
//            delegate?.updateUI(self, withWeather: currentWeather)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return currentWeather
    }
}

