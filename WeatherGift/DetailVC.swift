//
//  DetailVC.swift
//  WeatherGift
//
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM dd, y"
    return formatter
}()

class DetailVC: UIViewController {

    //MARK: Instance Variables
    var currentPage = 0
    var locationsArray = [WeatherLocation]()
    var locationDetail: WeatherDetail!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    //MARK: IBOutlets
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Required Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        locationDetail = WeatherDetail(
            name: locationsArray[currentPage].name,
            coordinates: locationsArray[currentPage].coordinates
        )
        
        if currentPage != 0 {
            locationDetail.getWeather {
                self.updateUserInferface()
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentPage == 0 {
            getLocation()
        }
    }
    
    func updateUserInferface() {
        let location = locationDetail!
        locationLabel.text = location.name
        dateLabel.text = location.currentTime.format(timeZone: location.timeZone, dateFormatter: dateFormatter)
        temperatureLabel.text = location.currentTemperature
        summaryLabel.text = location.description
        currentImage.image = UIImage(named: location.currentIcon)
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    

}

extension DetailVC: CLLocationManagerDelegate {
    
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: status)
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch(status) {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied:
            showPrivacySettingsAlert(title: "User has not authorized location services", message: "Select settings to open privacy settings and enable location services for this app.")
        case .restricted:
            showAlert(title: "Location services deined", message: "Parental or corporate controls are likely blocking location services.")
        }
    }
    
    func showPrivacySettingsAlert(title: String, message: String) {
        
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("Could not get application settings url string")
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { value in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!
        let currentCoordinates = "\(currentLocation.coordinate.latitude),\(currentLocation.coordinate.longitude)"
        let geoCoder = CLGeocoder()
        var place = ""
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { placemarks, error in
            if placemarks != nil {
                let placemark = placemarks?.last
                place = (placemark?.name)!
            } else {
                print("Error retrieving place. Error code: \(error!)")
                place = "Unknown Weather Location"
            }
            self.locationsArray[0].name = place
            self.locationsArray[0].coordinates = currentCoordinates
            self.locationDetail = WeatherDetail(name: place, coordinates: currentCoordinates)
            self.locationDetail.getWeather {
                self.updateUserInferface()
            }
            self.updateUserInferface()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: Could not get user location")
    }
}

extension DetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationDetail.dailyForecastArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath) as! DayWeatherCell
        cell.update(with: locationDetail.dailyForecastArray[indexPath.row], timeZone: locationDetail.timeZone)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension DetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationDetail.hourlyForecastArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyCell", for: indexPath) as! HourlyCell
        cell.update(with: locationDetail.hourlyForecastArray[indexPath.row], timeZone: locationDetail.timeZone)
        return cell
    }
}
