//
//  NiceWeatherApp.swift
//  NiceWeather
//
//  Created by Miaomiao Shi on 22/04/2024.
//

import SwiftUI

@main
struct NiceWeatherApp: App {
    let weatherViewModel = WeatherViewModel()
    var body: some Scene {
        WindowGroup {
            WeatherView(weatherViewModel: weatherViewModel)
        }
    }
}
