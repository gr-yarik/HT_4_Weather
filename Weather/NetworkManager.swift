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
//    var respondFor: ResponseType!
    
    var onCompletion: ((CityTableWeather, [CityTableWeather], ResponceType) -> Void)?
    
    enum RequestType {
        case byCityName(cityName: String)
        case byCityNames(cityNames: [String])
        case byCoordinates(longtitude: CLLocationDegrees, latitude: CLLocationDegrees)
    }
    
    enum ResponseType {
        case forLocation
        case forStoredCity
    }
    
    
    func fetchCurrentWeather(searchBy requestType: RequestType) {
//        var url = ""
        switch requestType {
        case .byCityName(let cityName):
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&apikey=\(apiKey)&units=metric"
            guard let url = URL(string: urlString) else { return }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, responce, error) in
                if let data = data {
                    if let currentWeather = self.JSONParse(withData: data) {
                        self.onCompletion?(currentWeather)
                    }
                }
            }
            task.resume()
            
        case .byCoordinates(let longtitude, let latitude):
            let url = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longtitude)&appid=\(apiKey)&units=metric"
        }
//        APICall(urlString: url)
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
    
    
    fileprivate func APICall (urlString: String){
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, responce, error) in
            if let data = data {
                if let currentWeather = self.JSONParse(withData: data) {
                    self.onCompletion?(currentWeather)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func JSONParse(withData data: Data) -> CityTableWeather? {
        let decoder = JSONDecoder()
        do {
            let currentWeatherData = try decoder.decode(CityTableWeatherData.self, from: data)
            let currentWeather = CityTableWeather(currentWeatherData: currentWeatherData)
            return currentWeather
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}

