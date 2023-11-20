//
//  ModelData.swift
//  WeatherDemo
//
//  Created by Miaomiao Shi on 20/11/2023.
//

// loading local JSON data an decoding it into a Swift data structure. -> Provide sample data for previews or tesing in a Swift project.
import Foundation

var previewWeather: ResponseBody = load("weatherData.json")

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    // finding Json file
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else { fatalError("Couldn't find \(filename) in main bundle.") }
    
    // Loading Json file
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle: \n\(error)")
    }
    
    // decoding Json file
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
