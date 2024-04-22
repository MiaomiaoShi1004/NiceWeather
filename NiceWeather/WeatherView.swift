//
//  ContentView.swift
//  NiceWeather
//
//  Created by Miaomiao Shi on 22/04/2024.
//

import SwiftUI
import Charts
import CoreLocation


// MARK: - Geo Section
struct GeoSection: View {
    let data: [WeatherViewModel.GeoDataKey: String]

    var body: some View {
        let iconWidth = CGFloat(30)
        
        Section {
            HStack {
                Image(systemName: "location").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.location]!)
            }
            HStack {
                Image(systemName: "sunrise").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.sunrise]!)
                Text("(" + data[.sunriseLocal]! + ")").foregroundStyle(.gray)
                
                Image(systemName: "sunset").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.sunset]!)
                Text("(" + data[.sunsetLocal]! + ")").foregroundStyle(.gray)
            }
            HStack {
                Image(systemName: "clock.arrow.2.circlepath").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.timeOffset]!)
            }
        } header: {
            Text("Geo info")
        }
    }
}


// MARK: - Current Weather Section (min, max retrieved from 5 day forecast)
struct CurrentWeatherSection: View {
    let data: [WeatherViewModel.WeatherDataKey: String]
    
    var body: some View {
        let iconWidth = CGFloat(30)
        
        Section {
            HStack {
                Image(systemName: "thermometer.medium").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.temp]!)
                if let low = data[.minTemp], let high = data[.maxTemp] {
                    Text("(L: " + low + " H: " + high + ")").foregroundStyle(.gray)
                }
                Image(systemName: "thermometer.variable.and.figure").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text("Feels \(data[.feelslike]!)")
            }
            if let clouds = data[.clouds] {
                HStack {
                    Image(systemName: "cloud").foregroundStyle(.tint).frame(minWidth: iconWidth)
                    Text(clouds)
                }
            }
            if let rain = data[.rain] {
                HStack {
                    Image(systemName: "cloud.rain").foregroundStyle(.tint).frame(minWidth: iconWidth)
                    Text(rain)
                }
            }
            if let snow = data[.snow] {
                HStack {
                    Image(systemName: "cloud.snow").foregroundStyle(.tint).frame(minWidth: iconWidth)
                    Text(snow)
                }
            }
            if let wind = data[.wind] {
                HStack {
                    Image(systemName: "wind").foregroundStyle(.tint).frame(minWidth: iconWidth)
                    Text(wind)
                }
            }
            HStack {
                Image(systemName: "humidity").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.humidity]!)
                
                Image(systemName: "gauge.with.dots.needle.bottom.50percent").foregroundStyle(.tint).frame(minWidth: iconWidth)
                Text(data[.pressure]!)
            }
        } header: {
            if let description = data[.description] {
                Text("Weather: " + description)
            }
        }
    }
}


// MARK: - Current Pollution Section
struct CurrentPollutionSection: View {
    let data: [WeatherViewModel.PollutionDataKey: Any]
    var vGridLayout = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if let components = data[.components] as? [(String, String)] {
            Section {
                VStack {
                    LazyVGrid(columns: vGridLayout, alignment: .center, spacing: 8) {
                        ForEach(components.indices, id: \.self) { index in
                            HStack {
                                Text(components[index].0)
                                    .foregroundStyle(.tint)
                                    .frame(width: 50, alignment: .trailing)
                                    .padding(0)
                                Text(components[index].1)
                                    .padding(0)
                                Spacer()
                            }
                            .padding(.bottom, 5)
                        }
                        .font(.callout)
                    }
                    HStack {
                        Spacer()
                        Text("(units: μg/m3)").font(.caption).foregroundStyle(.gray)
                    }
                }
            } header: {
                Text((data[.description] as? String) ?? "")
            }
        }
    }
}


// MARK: - Forecast Section
struct ForecastSection: View {
    let data: WeatherForecastData
    
    var body: some View {
        Section {
            let fiveDayForecast = data.fiveDayForecast
            ForEach(fiveDayForecast.indices, id: \.self) { index  in
                let forecast = fiveDayForecast[index]
                VStack(alignment: .leading) {
                    DayAndTemperatureRow(forecast: forecast)
                    DayWeatherIconRow(icons: forecast.icons)
                }
            }
        } header: {
            Text("5 day forecast")
        }
    }
}


struct DayAndTemperatureRow: View {
    let forecast: DayForecast

    var body: some View {
        HStack {
            Text(forecast.isToday ? "Today" : forecast.date.dayStr).foregroundStyle(.tint)
            Image(systemName: "thermometer").foregroundStyle(.gray)
            Text("(L: \(forecast.minT.tempString) H: \(forecast.maxT.tempString))").foregroundStyle(.gray)
        }
    }
}

struct DayWeatherIconRow: View {
    let icons: [(date: Date?, img: String?)]

    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { index in
                let icon = icons[index]
                let label = icon.date?.hourStr ?? ""
                VStack(spacing: 0) {
                    Text(label).font(.footnote)
                    if let img = icon.img {
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(img)@2x.png")) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }.background(RoundedRectangle(cornerRadius: 5).foregroundStyle(Color.init(white: 0.8, opacity: 0.5))).aspectRatio(1, contentMode: .fit)
                    } else {
                        Color.clear
                    }
                }
            }
        }
    }
}


// MARK: - Pollution Forecast Chart

struct PollutionChartView: View {
    let data: [(date: Date, aqi: AirQualityIndex)]
    
    var body: some View {
        Section {
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Date", data[index].date),
                        y: .value("API", data[index].aqi.aqi)
                    )
                    .foregroundStyle(.tint)
                }
            }
            .frame(height: 180)
            .padding()
            .chartXAxis {
                AxisMarks(values: .stride(by: .hour, count: 24)) { date in
                    AxisValueLabel(format: .dateTime.weekday(.short))
                }
            }
            .chartYScale(domain: 1...5)
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 1))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            let aqi = AirQualityIndex(aqi: intValue)
                            Text("\(aqi.description)")
                        }
                    }
                }
            }.padding([.leading, .trailing], -20)
        } header: {
            Text("Air Pollution Index Forecast")
        }
    }
}



// MARK: - Main View

struct WeatherView: View {
    @Bindable var weatherViewModel: WeatherViewModel
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Form {
            Section {
                VStack {
                    TextField(text: $weatherViewModel.namedLocation) {
                        Text("Enter location e.g. Dublin, IE")
                    }
                    .disableAutocorrection(true)
                    .focused($isFocused, equals: true)
                    .onSubmit { weatherViewModel.fetchData() }
                    .onChange(of: isFocused, initial: true) { oldValue, newValue in
                        if newValue {
                            weatherViewModel.namedLocation = ""
                        }
                    }
                    .padding([.leading, .trailing])
                }
            } header:
            {
                Text("Search").foregroundStyle(.tint)
            } footer: {
                if weatherViewModel.weatherData != nil {
                    VStack {
                        Spacer()
                        Divider()
                    }
                }
            }
            if let data = weatherViewModel.geoData {
                GeoSection(data: data)
            }
            if let data = weatherViewModel.weatherData {
                CurrentWeatherSection(data: data)
            }
            if let data = weatherViewModel.pollutionData {
                CurrentPollutionSection(data: data)
            }
            if let data = weatherViewModel.weatherForecastData {
                ForecastSection(data: data)
            }
            if let data = weatherViewModel.pollutionForecastData?.data {
                PollutionChartView(data: data)
            }
        }.onAppear { isFocused = true }
    }
}












// MARK: - Extentions

extension Date {
    private static var formatter = DateFormatter()
    var hourStr: String {
        let formatter = Self.formatter
        Self.formatter.dateFormat = "H'H'"
        return formatter.string(from: self)
    }
    
    var dayStr: String {
        let formatter = Self.formatter
        Self.formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    static var utcOffset: TimeInterval {
        Double(TimeZone.current.secondsFromGMT(for: Date()))
    }
}


extension CLLocationCoordinate2D {
    var description: String {
        let latString = latitude.dmsString + " " + (latitude >= 0 ? "N" : "S")
        let lonString = longitude.dmsString + " " + (longitude >= 0 ? "E" : "W")
        return "\(latString), \(lonString)"
    }
}


extension Coord {
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

extension Double {
    var dmsString: String {
        let absoluteLatitude = abs(self)
        let d = Int(absoluteLatitude)
        let remainingMinutes = (absoluteLatitude - Double(d)) * 60
        let m = Int(remainingMinutes)
        let s = Int((remainingMinutes - Double(m)) * 60)
        return String(format: "%d°%d'%d\"", d, m, s)
    }
}


// MARK: - Preview


#Preview {
    WeatherView(weatherViewModel: WeatherViewModel())
}

