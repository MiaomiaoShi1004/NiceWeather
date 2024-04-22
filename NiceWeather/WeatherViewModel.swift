//
//  WeatherViewModel.swift
//  NiceWeather
//
//  Created by Miaomiao Shi on 22/04/2024.
//

import SwiftUI
import CoreLocation

@Observable class WeatherViewModel {
    var namedLocation: String = "Hawaii, HI, USA"
    { willSet { if newValue == "" { dataModel.clear() } } }
    
    // MARK: Model 
    
    private var dataModel = WeatherDataModel()

    // MARK: User intent
    
    func fetchData() {
        dataModel.clear()
        Task {
            await dataModel.fetch(for: namedLocation)
        }
    }
    
    // MARK: Public Properties

    enum GeoDataKey {
        case location
        case sunrise
        case sunset
        case sunriseLocal
        case sunsetLocal
        case timeOffset
    }
    var geoData: [GeoDataKey: String]? {
        var data = [GeoDataKey: String]()
        guard let weatherData = dataModel.weatherData else { return nil }
        
        data[.location] = weatherData.coord.clLocation.description
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:MM"
        let timeOffset = TimeInterval(weatherData.timezone) - Date.utcOffset
        if let sunrise = weatherData.sys.sunrise, let sunset = weatherData.sys.sunset {
            data[.sunrise] = formatter.string(from: Date(timeIntervalSince1970:  TimeInterval(sunrise)))
            data[.sunriseLocal] = formatter.string(from: Date(timeIntervalSince1970:  TimeInterval(sunrise)).addingTimeInterval(timeOffset))
            data[.sunset] = formatter.string(from: Date(timeIntervalSince1970:  TimeInterval(sunset)))
            data[.sunsetLocal] = formatter.string(from: Date(timeIntervalSince1970:  TimeInterval(sunset)).addingTimeInterval(timeOffset))
        }
        data[.timeOffset] = (timeOffset < 0 ? "-" : "+") + "\(Int(abs(timeOffset) / 3600))H"
        return data
    }
    
    enum WeatherDataKey {
        case description
        case minTemp
        case maxTemp
        case temp
        case feelslike
        case clouds
        case rain
        case snow
        case wind
        case humidity
        case pressure
    }
    var weatherData: [WeatherDataKey: String]? {
        var data = [WeatherDataKey: String]()
        guard let weatherData = dataModel.weatherData else { return nil }
        
        data[.description] = weatherData.weather.first?.description
        data[.temp] = weatherData.main.temp.tempString
        data[.feelslike] = weatherData.main.feelsLike.tempString
        data[.humidity] = "\(weatherData.main.humidity)%"
        data[.pressure] = "\(weatherData.main.pressure) hPa"
        if let maxTemp = dataModel.weatherForecastData?.maxTemp, let minTemp = dataModel.weatherForecastData?.minTemp {
            data[.minTemp] = min(minTemp, weatherData.main.tempMin).tempString
            data[.maxTemp] = max(maxTemp, weatherData.main.tempMax).tempString
        }
        if let snow = weatherData.snow {
            data[.snow] = if let h = snow.snow_1h {
                String(format: "%0.1f cm in next hour", h * 10)
            } else if let h = snow.snow_3h {
                String(format: "%0.2f cm in next 3 hours", h * 10)
            } else { "" }
        }
        if let rain = weatherData.rain {
            data[.rain] = if let h = rain.rain_1h {
                String(format: "%0.1f mm in next hour", h)
            } else if let h = rain.rain_3h {
                String(format: "%0.2f mm in next 3 hours", h)
            } else { "" }
        }
        if let clouds = weatherData.clouds {
            data[.clouds] = "\(clouds.all)% coverage"
        }
        if let wind = weatherData.wind {
            data[.wind] = String(format: "%0.1f km/h, dir: %d°", wind.speed * 3.6, wind.deg)
        }
        return data
    }
    
    enum PollutionDataKey {
        case description
        case components
    }
    var pollutionData: [PollutionDataKey: Any]? {
        guard let pollutionData = dataModel.pollutionData?.list.first else { return nil }
        
        var data = [PollutionDataKey: Any]()
        data[.description] = "Air Quality: " + pollutionData.main.description
        data[.components] = pollutionData.components.map { (key: Gas, value: Double) in
            ("\(key.description)", String(format: "%0.1f", value))
        }
        return data
    }
    
    var weatherForecastData: WeatherForecastData? { dataModel.weatherForecastData }
    var pollutionForecastData: PollutionForecastData? { dataModel.pollutionForecastData }
}


// MARK: - Misc Extension

// String interpolation for codable object using json encoder
extension String.StringInterpolation {
    mutating func appendInterpolation(encodable: Encodable) {
        guard
            let data = try? JSONEncoder().encode(encodable),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        else {
            appendInterpolation("Failed to encode with JSON")
            return
        }
        appendInterpolation("\n\(String(decoding: jsonData, as: UTF8.self))")
    }
}

