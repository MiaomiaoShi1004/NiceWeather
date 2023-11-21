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
                    
                    Spacer().frame(height: 80)
                    
                    AsyncImage(url: URL(string: "https://cdn.dribbble.com/users/296515/screenshots/2003229/media/d7a1340b6464c25175689836230ffaf1.png")) { image in image.resizable().aspectRatio(contentMode: .fit).frame(width: 350)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
 
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color(red: 0.832, green: 0.896, blue: 0.747))
        .preferredColorScheme(.dark)
//        .border(Color.black, width: 1)
        
    }
}

#Preview {
    WeatherView(weather: previewWeather)
}
