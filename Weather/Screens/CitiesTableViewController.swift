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
            dismissLoadingView()
            citiesWeather.sort { (c1, c2) -> Bool in
                c1.cityName < c2.cityName
            }
        }
    }
    
    var localWeather: CityTableWeather! {
        didSet {
//            print("local weather = ", localWeather!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var currentWeather: CityTableWeather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        storage = Storage()
        networkManager.onCompletion = { [weak self] weather, weathers, forecast, responceType in
            guard let self = self else { return }
            switch responceType {
            case .forLiveLocation:
                self.localWeather = weather
            case .forStoredCity:
                break
            case .forStoredCities:
                self.citiesWeather = weathers!
            case .forFourDays:
                break
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        presentWeather()
        
    }
    
    
    func presentWeather() {
        DispatchQueue.main.async {
            self.showLoadingView()
        }
        networkManager.fetchCurrentWeather(searchBy: .byCityNames(cityNames: cityNames))
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            currentWeather = localWeather
        case 1:
            currentWeather = citiesWeather[indexPath.row]
        default:
            return
        }
        performSegue(withIdentifier: "details", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! DetailedWeatherViewController
        destVC.cityWeather = currentWeather
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