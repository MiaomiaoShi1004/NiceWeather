//
//  Temp.swift
//  WeatherDemo
//
//  Created by Miaomiao Shi on 21/11/2023.
//

import SwiftUI

struct Temp: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Color.gray.edgesIgnoringSafeArea(.all) // Background color for visibility

            VStack(alignment: .center, spacing: 10) {
                Text("First Item")
                    .font(.system(size: 22))
                Text("Second Item")
                Text("Third Item")
            }
            .font(.system(size: 28))
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

#Preview {
    Temp()
}
