//
//  WeatherView.swift
//  WeatherDemo
//
//  Created by Miaomiao Shi on 20/11/2023.
//

import SwiftUI

struct WeatherView: View {
    var weather: ResponseBody
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(weather.name)
                        .bold().font(.title)
                    
                    Text("Today,\(Date().formatted(.dateTime.month().month().day().hour().minute()))").fontWeight(.light)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
//                .border(Color.black, width: 1)
                
                Spacer()
                
                VStack() {
                    HStack {
                        
                        VStack(spacing: 20) {
                            Image(systemName: "sun.max")
                                .font(.system(size: 40))
                            
                            Text(weather.weather[0].main)
                        }
                        .frame(width: 150, alignment: .leading)
                        
                        Spacer()
                        
                        Text(weather.main.feelsLike.roundDouble() + "°")
                            .font(.system(size: 100))
                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .padding()
                    }
                    
                    Spacer().frame(height: 70)
                    
                    AsyncImage(url: URL(string: "https://cdn.dribbble.com/users/156832/screenshots/1860645/media/af86cffcc5ce07fc9440da3e1b2e90aa.png")) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 350)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
//                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack() {
                Spacer()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Weather now").bold().padding(.bottom)
                    
                    HStack() {
                        WeatherRow(logo: "thermometer.low", name: "Min temp", value: (weather.main.tempMin.roundDouble() + "°"))
                        
                        Spacer()
                        
                        WeatherRow(logo: "thermometer.high", name: "Max temp ", value: (weather.main.tempMax.roundDouble() + "°"))
                    }
                    
                    HStack() {
                        WeatherRow(logo: "wind",
                                   name: "Wind speed",
                                   value: (weather.wind.speed.roundDouble() + "m/s"))
                        
                        Spacer()
                        
                        WeatherRow(logo: "humidity.fill", name: "Humidity", value: (weather.main.humidity.roundDouble() + "%"))
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.bottom, 20)
                .foregroundColor(Color(red: 0.263, green: 0.263, blue: 0.301))
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(red: 0.263, green: 0.263, blue: 0.301))
        .preferredColorScheme(.dark)
//        .border(Color.black, width: 1)
        
    }
}

#Preview {
    WeatherView(weather: previewWeather)
}
