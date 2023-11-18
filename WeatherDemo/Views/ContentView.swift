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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
