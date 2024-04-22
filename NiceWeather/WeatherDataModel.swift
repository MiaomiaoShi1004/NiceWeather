//
//  WeatherDataModel.swift
//  NiceWeather
//
//  Created by Miaomiao Shi on 22/04/2024.
//

import Foundation
import CoreLocation

// MARK: - WeatherDataModel

struct WeatherDataModel {
    private(set) var geoLocationData: GeoLocationData?
    private(set) var weatherData: WeatherData?
    private(set) var pollutionData: PollutionData?
    private(set) var weatherForecastData: WeatherForecastData?
    private(set) var pollutionForecastData: PollutionForecastData?
    
    mutating func clear() {
        geoLocationData = nil
        weatherData = nil
        pollutionData = nil
        weatherForecastData = nil
        pollutionForecastData = nil
    }
    
    mutating func fetch(for location: String) async {
        clear()
        geoLocationData = await OpenWeatherMapAPI.geoLocation(for: location, countLimit: 1)
        guard let position = geoLocationData?.first?.location else { return }
        weatherData = await OpenWeatherMapAPI.weather(at: position)
        pollutionData = await OpenWeatherMapAPI.pollution(at: position)
        weatherForecastData = await OpenWeatherMapAPI.weatherForecast(at: position)
        pollutionForecastData = await OpenWeatherMapAPI.pollutionForecast(at: position)
    }
}


// MARK: - Partial support for OpenWeatherMap API 2.5 (free api access)

struct OpenWeatherMapAPI {
    private static let apiKey = "bf3d52072c114c1e19441b11c6995032"
    private static let baseURL = "https://api.openweathermap.org/"

    // Async fetch from OpenWeatherMap
    private static func fetch<T: Decodable>(from apiString: String, asType type: T.Type) async throws -> T {
        guard let url = URL(string: "\(Self.baseURL)\(apiString)&appid=\(Self.apiKey)") else { throw NSError(domain: "Bad URL", code: 0, userInfo: nil) }
        let (data, _) =  try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    // MARK: - Public API
    
    static func weather(at location: CLLocationCoordinate2D) async -> WeatherData? {
        let apiString = "data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
    }
    
    static func weather(at location: String) async -> WeatherData? {
        let apiString = "data/2.5/weather?q=\(location)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherData.self)
    }
    
    static func weatherForecast(at location: CLLocationCoordinate2D) async -> WeatherForecastData? {
        let apiString = "data/2.5/forecast?lat=\(location.latitude)&lon=\(location.longitude)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherForecastData.self)
    }

    static func weatherForecast(at location: String) async -> WeatherForecastData? {
        let apiString = "data/2.5/forecast?q=\(location)&units=metric"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: WeatherForecastData.self)
    }
    
    static func pollution(at location: CLLocationCoordinate2D) async -> PollutionData? {
        let apiString = "data/2.5/air_pollution?lat=\(location.latitude)&lon=\(location.longitude)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: PollutionData.self)
    }
    
    static func pollutionForecast(at location: CLLocationCoordinate2D) async -> PollutionForecastData? {
        let apiString = "data/2.5/air_pollution/forecast?lat=\(location.latitude)&lon=\(location.longitude)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: PollutionForecastData.self)
    }
    
    static func geoLocation(for location: String, countLimit count: Int) async -> GeoLocationData? {
        let apiString = "geo/1.0/direct?q=\(location)&limit=\(count)"
        return try? await OpenWeatherMapAPI.fetch(from: apiString, asType: GeoLocationData.self)
    }
}




// MARK: - ForecastData
struct WeatherForecastData: Codable {
    let cod: String // Internal parameter
    let message: Int // Internal parameter
    let cnt: Int // A number of timestamps returned in the API response
    var list: [Forecast] // List of timestamp forecasts
    let city: City // Forecast location
    
    var maxTemp: Double? {
        list.map({ (time: Date(timeIntervalSince1970: TimeInterval($0.dt)), temp: $0.main.tempMax) })
            .filter({ $0.time.timeIntervalSinceNow <= TimeInterval(86400) }).max(by: { $0.temp < $1.temp })?.temp
    }
    
    var minTemp: Double? {
        list.map({ (time: Date(timeIntervalSince1970: TimeInterval($0.dt)), temp: $0.main.tempMin) })
            .filter({ $0.time.timeIntervalSinceNow <= TimeInterval(86400) }).max(by: { $0.temp > $1.temp })?.temp
    }
            
    var fiveDayForecast: [DayForecast] {
        list.sorted(by: { $0.dt < $1.dt }).map({ $0.dayForecast }).orderedByDay
    }
}

extension Array where Element == DayForecast {
    var orderedByDay: [DayForecast] {
        let reordered = DayForecast.reorder(byDay: self)
        let (minT, maxT) = (reordered.minT, reordered.maxT)
        return reordered.map {
            var dayForecast = $0
            dayForecast.clip = (($0.minT - minT) / (maxT - minT), (maxT - $0.maxT) / (maxT - minT))
            return dayForecast
        }
    }
    var minT: Double { self.map({ $0.minT }).min() ?? .nan }
    var maxT: Double { self.map({ $0.maxT }).max() ?? .nan }
}


// MARK: - Forecast
struct Forecast: Codable {
    let dt: Int // Time of data forecasted, unix, UTC
    var date: Date { Date(timeIntervalSince1970: TimeInterval(dt)) }
    let weather: [Weather] // Weather Conditions
    let main: Main // Weather data
    let visibility: Int // Average visibility, metres. The maximum value of the visibility is 10km
    let wind: Wind? // Wind
    let clouds: Clouds? // Clouds
    let rain: Rain? // Rain
    let pop: Double // Probability of precipitation. The values of the parameter vary between 0 and 1, where 0 is equal to 0%, 1 is equal to 100%
    let snow: Snow? // Snow
    let sys: Sys // System
    let dtTxt: String // Time of data forecasted, ISO, UTC
    
    var dayForecast: DayForecast {
        var forecast = DayForecast(date: date, minT: main.temp, maxT: main.temp)
        forecast.icons.append((date, weather.first?.icon))
        if let timeStamp = sys.sunrise {
            forecast.sunrise = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        }
        return forecast
    }
}

struct DayForecast {
    var date: Date
    var minT: Double
    var maxT: Double
    var icons = [(date: Date?, img: String?)]()
    var sunrise: Date?
    var isToday: Bool { Calendar.current.isDateInToday(date) }
    var clip: (leading: Double, trailing: Double) = (0, 0)

    static func reorder(byDay sortedList: [Self]) -> [Self] {
        var output = [Self]()
        var date = Date(timeIntervalSince1970: 0)

        // fill array by day
        for data in sortedList {
            if !Calendar.current.isDate(date, inSameDayAs: data.date) {
                date = data.date
                output.append(data)
            } else {
                var lastDay = output.removeLast()
                lastDay.minT = lastDay.minT < data.minT ? lastDay.minT : data.minT
                lastDay.maxT = lastDay.maxT > data.maxT ? lastDay.maxT : data.maxT
                lastDay.icons.append(contentsOf: data.icons)
                output.append(lastDay)
            }
        }
        
        // pad first day
        if var item = output.first {
            let padCount = 8 - item.icons.count
            if padCount > 0 {
                var padding = [(Date?, String?)].init(repeating: (nil, nil), count: padCount)
                padding.append(contentsOf: item.icons)
                item.icons = padding
                output[0] = item
            }
        }
        
        // pad last day
        if var item = output.last {
            let padCount = 8 - item.icons.count
            if padCount > 0 {
                var padding = [(Date?, String?)].init(repeating: (nil, nil), count: padCount)
                padding.insert(contentsOf: item.icons, at: 0)
                item.icons = padding
                output.removeLast()
                output.append(item)
            }
        }

        return output
    }
 }


// MARK: - WeatherData

struct WeatherData: Codable {
    let coord: Coord // Geo location
    let weather: [Weather] // Weather Conditions
    let base: String // Internal parameter
    let main: Main // Weather data
    let visibility: Int // Average visibility, metres. The maximum value of the visibility is 10km
    let wind: Wind? // Wind
    let clouds: Clouds? // Clouds
    let rain: Rain? // Rain
    let snow: Snow? // Snow
    let dt: Int // Time of data calculation, unix, UTC
    let sys: Sys // System
    let timezone: Int // Shift in seconds from UTC
    let id: Int //  City ID. Please note that built-in geocoder functionality has been deprecated.
    let name: String // City name. Please note that built-in geocoder functionality has been deprecated.
    let cod: Int // Internal parameter
}


// MARK: - PollutionData
struct PollutionData: Codable {
    let coord: Coord // Geo location
    let list: [Pollution] // Pollution Conditions
}


// MARK: - PollutionForecastData
struct PollutionForecastData: Codable {
    let coord: Coord // Geo location
    let list: [Pollution] // Pollution Conditions
    
    var data: [(date: Date, aqi: AirQualityIndex)] {
        list.map { (Date(timeIntervalSince1970: TimeInterval($0.dt)), $0.main) }
    }
}


// MARK: - GeoLocationData
typealias GeoLocationData = [GeoLocation]
    


// MARK: - Clouds
struct Clouds: Codable {
    let all: Int // Cloudiness, %
}


// MARK: - Coord
struct Coord: Codable {
    let lat: Double // Geo location, longitude
    let lon: Double // Geo location, latitude
}


// MARK: - Main
struct Main: Codable {
    let temp: Double // Temperature. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    let feelsLike: Double // This temperature parameter accounts for the human perception of weather. Unit Default: Kelvin, Metric: Celsius, Imperial: Fahrenheit
    let pressure: Int // Atmospheric pressure on the sea level by default, hPa
    let humidity: Int // Humidity, %
    let tempMin: Double // Minimum temperature at the moment of calculation. This is minimal forecasted temperature (within large megalopolises and urban areas), use this parameter optionally.
    let tempMax: Double // Maximum temperature at the moment of calculation. This is maximal forecasted temperature (within large megalopolises and urban areas), use this parameter optionally.
    let seaLevel: Int? // Atmospheric pressure on the sea level, hPa
    let grndLevel: Int? // Atmospheric pressure on the ground level, hPa
    let tempKf: Double? // Internal parameter
}


// MARK: - Rain
struct Rain: Codable {
    private enum CodingKeys : String, CodingKey {
        case rain_1h = "1h"
        case rain_3h = "3h"
    }
    let rain_1h: Double? // Rain volume for last hour, mm. Please note that only mm as units of measurement are available for this parameter
    let rain_3h: Double? // Rain volume for last 3 hours, mm. Please note that only mm as units of measurement are available for this parameter
}


// MARK: - Snow
struct Snow: Codable {
    private enum CodingKeys : String, CodingKey {
        case snow_1h = "1h"
        case snow_3h = "3h"
    }
    let snow_1h: Double? // Snow volume for last hour. Please note that only mm as units of measurement are available for this parameter
    let snow_3h: Double? // Snow volume for last 3 hours. Please note that only mm as units of measurement are available for this parameter
}


// MARK: - Sys
struct Sys: Codable {
    let type, id: Int? // Internal parameter
    let country: String? // Country code (GB, JP etc.)
    let sunrise, sunset: Int? //  Sunrise and sunset time, unix, UTC
    let pod: String? // Part of the day (n - night, d - day)
}


// MARK: - Wind
struct Wind: Codable {
    let speed: Double // Wind speed. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour
    let deg: Int //  Wind direction, degrees (meteorological)
    let gust: Double? // Wind gust. Unit Default: meter/sec, Metric: meter/sec, Imperial: miles/hour
}


// MARK: - Weather
struct Weather: Codable {
    let id: Int // Weather condition id
    let main: String // Group of weather parameters (Rain, Snow, Clouds etc.)
    let description: String // Weather condition within the group
    let icon: String // Weather icon id
}


// MARK: - City
struct City: Codable {
    let id: Int // City ID. Please note that built-in geocoder functionality has been deprecated.
    let name: String // City name. Please note that built-in geocoder functionality has been deprecated.
    let coord: Coord // Geo location
    let country: String // Country code (GB, JP etc.). Please note that built-in geocoder functionality has been deprecated.
    let population: Int // City population
    let timezone: Int //  Shift in seconds from UTC
    let sunrise: Int // Sunrise time, Unix, UTC
    let sunset: Int // Sunset time, Unix, UTC
}


// MARK: - List
struct Pollution: Codable {
    let dt: Int // Date and time, Unix, UTC
    let main: AirQualityIndex // Air Quality Index
    let components: [Gas: Double] // Pollution components and concentration
}


// MARK: - Gas
enum Gas: String, Codable, CustomStringConvertible {
    case co = "co" // Сoncentration of CO (Carbon monoxide), μg/m3
    case no = "no" // Сoncentration of NO (Nitrogen monoxide), μg/m3
    case no2 = "no2" // Сoncentration of NO2 (Nitrogen dioxide), μg/m3
    case o3 = "o3" // Сoncentration of O3 (Ozone), μg/m3
    case so2 = "so2" // Сoncentration of SO2 (Sulphur dioxide), μg/m3
    case pm2_5 = "pm2_5" // Сoncentration of PM2.5 (Fine particles matter), μg/m3
    case pm10 = "pm10" // Сoncentration of PM10 (Coarse particulate matter), μg/m3
    case nh3 = "nh3" // Сoncentration of NH3 (Ammonia), μg/m3
    
    var description: String {
        self.rawValue.uppercased().replacingOccurrences(of: "_", with: ".")
    }
}


// MARK: - Main
struct AirQualityIndex: Codable, CustomStringConvertible {
    let aqi: Int // Air Quality Index. Possible values: 1, 2, 3, 4, 5. Where 1 = Good, 2 = Fair, 3 = Moderate, 4 = Poor, 5 = Very Poor.
    
    var description: String {
        switch aqi {
        case 1: "Good"
        case 2: "Fair"
        case 3: "Moderate"
        case 4: "Poor"
        case 5: "Very Poor"
        default: "Quality: \(aqi) (the lower, the better)"
        }
    }
}


// MARK: - GeoLocation
struct GeoLocation: Codable {
    let name: String // Name of the found location
    let localNames: [String: String]? // Name of the found location in different languages. The list of names can be different for different locations
    let lat, lon: Double // Geographical coordinates of the found location (latitude, longitude)
    let country: String // Country of the found location
    let state: String? // (where available) State of the found location
    
    var location: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: lat, longitude: lon) }
}


// MARK: - Misc. Extensions

internal extension KeyedDecodingContainer  {
    func decode(_ type: [Gas: Double].Type, forKey key: Key) throws -> [Gas: Double] {
        let stringDictionary = try self.decode([String: Double].self, forKey: key)
        var dictionary = [Gas: Double]()

        for (key, value) in stringDictionary {
            guard let gas = Gas(rawValue: key) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse json key to Gas object")
                throw DecodingError.dataCorrupted(context)
            }
            dictionary[gas] = value
        }

        return dictionary
    }
}


internal extension Double {
    var tempString: String { "\(Int(self.rounded()))°" }
}

