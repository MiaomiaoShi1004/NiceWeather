//
//  Temp.swift
//  WeatherDemo
//
//  Created by Miaomiao Shi on 21/11/2023.
//

import SwiftUI

struct Temp: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Rounded Top Corners")
                .padding()
                .frame(width: 200, height: 100)
                .background(Color.blue)
                .foregroundColor(.white)
                // Apply rounded corners to top-left and top-right
                .cornerRadius(25, corners: .topLeft)

            Text("Rounded Bottom Corners")
                .padding()
                .frame(width: 200, height: 100)
                .background(Color.red)
                .foregroundColor(.white)
                // Apply rounded corners to bottom-left and bottom-right
                .cornerRadius(25, corners: [.bottomLeft, .bottomRight])
        }
    }
}

#Preview {
    Temp()
}
