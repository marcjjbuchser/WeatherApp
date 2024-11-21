//
//  ContentView.swift
//  WeatherApp
//
//  Created by Marc Buchser on 2024-11-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingCitySearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.5), .blue.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if let weather = viewModel.currentWeather {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Weather animation view
                            WeatherAnimationView(weatherCode: weather.current.weatherCode)
                                .frame(height: 200)
                            
                            // Current weather info
                            CurrentWeatherView(weather: weather.current)
                            
                            // Hourly forecast
                            HourlyForecastView(forecasts: weather.hourly)
                        }
                        .padding()
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(viewModel.currentCity?.name ?? "Weather")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCitySearch = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCitySearch) {
                CitySearchView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
