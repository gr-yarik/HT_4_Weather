//
//  CitiesTableViewController.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//

import UIKit
import CoreLocation

class CitiesTableViewController: DataLoadingTableVC {
    
    @IBOutlet weak var nameLabel:           UILabel!
    @IBOutlet weak var iconImageview:       UIImageView!
    @IBOutlet weak var temperatureLabel:    UILabel!
    
    var networkManager: NetworkManager!
    
    lazy var locationManager: CLLocationManager = {
        let locationManager             = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        return locationManager
    }()
    
    var storage: StorageProtocol!
    
    var cityNames: [String] {
            storage.getCities()
    }
    
    var weatherForStoredCities: [CurrentCityWeather] = [] {
        didSet {
            dismissLoadingView()
            weatherForStoredCities.sort { (c1, c2) -> Bool in
                c1.cityName < c2.cityName
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var weatherAtLiveLocation: CurrentCityWeather! {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var weatherAtSelectedCell: CurrentCityWeather!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager = NetworkManager()
        storage = Storage()
        setUpLocationManager()
        getWeatherForStoredCities()
    }
    
    
    func setUpLocationManager() {
        locationManager.delegate  = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
    }
    
    
    func getWeatherForStoredCities() {
        DispatchQueue.main.async {
            self.showLoadingView()
        }
        networkManager.fetchWeatherForCities(cityNames: cityNames) { [weak self] weatherForStoredCities in
            guard let self = self else { return }
            self.weatherForStoredCities = weatherForStoredCities
        }
    }
    
    
    @IBAction func addCityPressed(_ sender: Any) {
        // в кастомный алерт контроллер не стал выносить, хотя пытался, так как нужно пробрасывать в него и storage, и networkManager, такой вот trade-off
        let alertVC = UIAlertController(title: "Add City", message: "Enter city's name", preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let cityName = alertVC.textFields![0].text
            self.networkManager.checkIfValidCityName(cityName: cityName!) { isValid in
                if isValid {
                    self.storage.addCity(name: cityName!)
                    self.getWeatherForStoredCities()
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
            weatherAtSelectedCell = weatherAtLiveLocation
        case 1:
            weatherAtSelectedCell = weatherForStoredCities[indexPath.row]
        default:
            return
        }
        performSegue(withIdentifier: "details", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! DetailedWeatherViewController
        destVC.cityWeather = weatherAtSelectedCell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return weatherAtLiveLocation == nil ? 0 : 1
        case 1:
            return weatherForStoredCities.count
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
            cell.setCell(name: weatherAtLiveLocation.cityName, icon: UIImage(systemName: weatherAtLiveLocation.icon)!, tempeature: weatherAtLiveLocation.temperatureString)
        case 1:
            let weather = weatherForStoredCities[indexPath.row]
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
        networkManager.fetchWeatherForCityByCoordinates(longtitude: longtitude, latitude: latitude) { [weak self] weatherAtLiveLocation in
            guard let self = self else { return }
            self.weatherAtLiveLocation = weatherAtLiveLocation
        }
    }
}
