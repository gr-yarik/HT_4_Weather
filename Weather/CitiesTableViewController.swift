//
//  CitiesTableViewController.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//

import UIKit
import CoreLocation

class CitiesTableViewController: DataLoadingVC {
    
    @IBOutlet weak var nameLabel:           UILabel!
    @IBOutlet weak var iconImageview:       UIImageView!
    @IBOutlet weak var temperatureLabel:    UILabel!
    
    var networkManager = NetworkManager()
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        return locationManager
    }()
    
    var storage: Storage!
    var cityNames: [String] {
        get {
            storage.getCities()
        }
    }
    
    var citiesWeather: [CityTableWeather] = [] {
        didSet {
            print("citiesWeather.count = ", citiesWeather.count)
//            if citiesWeather.count == cityNames.count {
//            citiesWeather.sort { (c1, c2) -> Bool in
//                c1.cityName < c2.cityName
//            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
//        }
        }
    }
    
    var localWeather: CityTableWeather! {
        didSet {
            print("local weather = ", localWeather!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        networkManager.delegate = self
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        storage = Storage()
        networkManager.onCompletion = { [weak self] currentWeather, type in
            guard let self = self else { return }
            switch type {
            case .forLocation:
                self.localWeather = currentWeather
            case .forStoredCity:
                self.citiesWeather.append(currentWeather)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        presentWeather()
        
    }
    
    
    func presentWeather() {
        print(citiesWeather)
//        citiesWeather = []
        for name in cityNames {
            let cityName = name.split(separator: " ").joined(separator: "%20")
            networkManager.fetchCurrentWeather(searchBy: .byCityName(cityName: cityName))
        }
    }
    
    
    @IBAction func addCityPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Add City", message: "Enter city's name", preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let cityName = alertVC.textFields![0].text
            self.networkManager.checkIfValidCityName(cityName: cityName!) { isValid in
                if isValid {
                    self.storage.addCity(name: cityName!)
                    self.presentWeather()
                } else {
                    DispatchQueue.main.async {
                    let alertVC = UIAlertController(title: "Error", message: "This city doesn't exist. Please try again", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(addAction)
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
//            print(localWeather)
            return localWeather == nil ? 0 : 1
        case 1:
            return citiesWeather.count
        default:
            return 0
        }
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Based on your current location"
        case 1:
            return "Stored Cities"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CityTableViewCell
        switch indexPath.section {
        case 0:
            cell.setCell(name: localWeather.cityName, icon: UIImage(systemName: localWeather.icon)!, tempeature: localWeather.temperatureString)
        case 1:
            let weather = citiesWeather[indexPath.row]
            cell.setCell(name: weather.cityName, icon: UIImage(systemName: weather.icon)!, tempeature: weather.temperatureString)
        default:
            return UITableViewCell()
        }
        return cell
    }
}

extension CitiesTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let longtitude = locations.last?.coordinate.longitude, let latitude = locations.last?.coordinate.latitude else { return }
        networkManager.fetchCurrentWeather(searchBy: .byCoordinates(longtitude: longtitude, latitude: latitude))
        
    }
}
