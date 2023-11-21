//
//  ContentView.swift
//  WeatherDemo
//
//  Created by Miaomiao Shi on 13/11/2023.
//

import SwiftUI

struct ContentView: View {
    // initiate our location manager
    @StateObject var locationManager = LocationManager()
    
    // initiate the weather manager
    var weatherManager = WeatherManager()
    // @State is for simple data that when changed, should cause the view to update
    @State var weather: ResponseBody?
    
    var body: some View {
        VStack {
            // Check if there is a location available in locationManager
            if let location = locationManager.location {
                if let weather = weather {
                    WeatherView(weather: weather)
                } else {
                    LoadingView()
                        .task {
                            do {
                                weather = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude)
                            } catch {
                                print("Error getting weather: \(error)")
                            }
                        }
                }
            } else {
                if locationManager.isLoading {
                    LoadingView()
                } else {
                    // if locationManger is not loading and there's no location available.
                    WelcomeView()
                        .environmentObject(locationManager)
                }
            }
        }
        .background(Color(red: 0.886, green: 0.352, blue: 0.425))
//        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
