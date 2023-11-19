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
    
    var body: some View {
        VStack {
            // Check if there is a location available in locationManager
            if let location = locationManager.location {
                Text("Your corordinates are:\(location.longitude),\(location.latitude)")
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
        .background(Color(hue: 0.656, saturation: 0.787, brightness: 0.354))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
