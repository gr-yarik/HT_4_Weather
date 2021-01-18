//
//  CitiesTableViewController.swift
//  Weather
//
//  Created by Yaroslav Hrytsun on 18.01.2021.
//

import UIKit

class CitiesTableViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel:           UILabel!
    @IBOutlet weak var iconImageview:       UIImageView!
    @IBOutlet weak var temperatureLabel:    UILabel!
    
    var networkManager = NetworkManager()
    
    var storage: Storage!
    var cityNames: [String] {
        get {
            storage.getCities()
        }
        set {
            storage.addCity(name: newValue.last!)
            tableView.reloadData()
        }
    }
    
    var citiesWeather: [CityTableWeather] = [] {
        didSet {
            isLoading = false
            tableView.reloadData()
        }
    }
    
    var isLoading: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = Storage()
        networkManager.delegate = self
        networkManager.fetchCurrentWeather(searchBy: .byCityNames(cityNames: cityNames)) { weathers in
            print(weathers)
            citiesWeather = weathers
        }
    }
    
    
    @IBAction func addCityPressed(_ sender: Any) {
        let alertVC = UIAlertController(title: "Add City", message: "Enter city's name", preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let cityName = alertVC.textFields![0].text
            self.cityNames.append(cityName!)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(addAction)
        present(alertVC, animated: true, completion: nil)
        print(citiesWeather)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isLoading ? cityNames.count : citiesWeather.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CityTableViewCell
        if isLoading {
            cell.setCell(name: cityNames[indexPath.row], icon: UIImage(), tempeature: "-2")
        } else {
            let weather = citiesWeather[indexPath.row]
            cell.setCell(name: weather.cityName, icon: UIImage(systemName: weather.icon)!, tempeature: weather.temperatureString)
        }
        return cell
    }
}

extension CitiesTableViewController: NetworkManagerDelegate {
    func updateUI(_: NetworkManager, withWeather currentWeather: [CityTableWeather]) {
        print(currentWeather)
        citiesWeather = currentWeather
    }
}
