//
//  WeatherDetail.swift
//  WeatherGift
//
//  Copyright © 2017 Teddy Burns. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class WeatherDetail: WeatherLocation {
    
    struct DailyForecast {
        var dailyMaxTemp = 0.0
        var dailyMinTemp = 0.0
        var dailySummary = ""
        var dailyDate = 0.0
        var dailyIcon = ""
    }
    
    struct HourlyForecast {
        var hourlyTime: Double
        var hourlyTemperature: Double
        var hourlyPrecipProb: Double
        var hourlyIcon: String
    }
    
    var currentTemperature = "--"
    var description = ""
    var currentIcon = ""
    var currentTime = 0.0
    var timeZone = ""
    
    var dailyForecastArray = [DailyForecast]()
    var hourlyForecastArray = [HourlyForecast]()
    
    func getWeather( completed: @escaping () -> ()) {
        let weatherURL = "\( apiBaseURL )/\( apiKey )/\( coordinates )"
        print(weatherURL)
        Alamofire.request(weatherURL).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let temperature = json["currently"]["temperature"].double {
                    self.currentTemperature = String(format: "%3.f°", temperature)
                } else {
                    print("Could not get temperature")
                }
                if let summary = json["hourly"]["summary"].string {
                    self.description = summary
                } else {
                    print("Count not get daily summary")
                }
                if let icon = json["currently"]["icon"].string {
                    self.currentIcon = icon
                } else {
                    print("Count not get current icon")
                }
                if let timeZone = json["timezone"].string {
                    self.timeZone = timeZone
                } else {
                    print("Count not get current timezone")
                }
                if let time = json["currently"]["time"].double {
                    self.currentTime = time
                } else {
                    print("Count not get current time")
                }
                let dailyDataArray = json["daily"]["data"]
                self.dailyForecastArray = [DailyForecast]()
                for dayIndex in 1...min(dailyDataArray.count-1, 7) {
                    let day = dailyDataArray[dayIndex]
                    let maxTemp = day["temperatureHigh"].doubleValue
                    let minTemp = day["temperatureLow"].doubleValue
                    let dateValue = day["time"].doubleValue
                    let icon = day["icon"].stringValue
                    let summary = day["summary"].stringValue
                    self.dailyForecastArray.append(DailyForecast(dailyMaxTemp: maxTemp, dailyMinTemp: minTemp, dailySummary: summary, dailyDate: dateValue, dailyIcon: icon))
                }
                
                let hourlyDataArray = json["hourly"]["data"]
                print(hourlyDataArray)
                self.hourlyForecastArray = [HourlyForecast]()
                for hourIndex in 1...min(hourlyDataArray.count-1, 24) {
                    let hour = hourlyDataArray[hourIndex]
                    let hourlyTime = hour["time"].doubleValue
                    let hourlyTemperature = hour["temperature"].doubleValue
                    let hourlyPrecipProb = hour["precipProbability"].doubleValue
                    let hourlyIcon = hour["icon"].stringValue
                    self.hourlyForecastArray.append(HourlyForecast(hourlyTime: hourlyTime, hourlyTemperature: hourlyTemperature, hourlyPrecipProb: hourlyPrecipProb, hourlyIcon: hourlyIcon))
                }
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
}
