//
//  Storage.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//

import Foundation

protocol StorageProtocol {
    func getCities() -> [String]
    func addCity(name: String)
}

class Storage: StorageProtocol {
    
    var cities: [String] = []
    
    init() {
        if !UserDefaults.standard.bool(forKey: "firstLaunch") {
            UserDefaults.standard.set(true, forKey: "firstLaunch")
            let initialCities = ["Kyiv", "London"]
            UserDefaults.standard.set(initialCities, forKey: "cities")
            print("first launch")
        }
        
        cities = UserDefaults.standard.stringArray(forKey: "cities") ?? [String]()
    }
    
    
    func getCities() -> [String] {
        return cities
    }
    
    
    func addCity(name: String) {
        cities.append(name)
        UserDefaults.standard.set(cities, forKey: "cities")
    }
}
