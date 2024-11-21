import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var currentWeather: WeatherModel?
    @Published var currentCity: City?
    @Published var savedCities: [City] = []
    @Published var searchResults: [City] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let weatherService: WeatherService
    private let cityService: CityService
    private let userDefaults: UserDefaults
    
    init(weatherService: WeatherService = WeatherService(),
         cityService: CityService = CityService(),
         userDefaults: UserDefaults = .standard) {
        self.weatherService = weatherService
        self.cityService = cityService
        self.userDefaults = userDefaults
        loadSavedCities()
        loadLastViewedCity()
    }
    
    func fetchWeather(for city: City) async {
        isLoading = true
        currentCity = city
        do {
            currentWeather = try await weatherService.fetchWeather(
                latitude: city.latitude,
                longitude: city.longitude
            )
            saveLastViewedCity(city)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    func searchCities(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try await cityService.searchCities(query: query)
        } catch {
            self.error = error
        }
    }
    
    private func loadSavedCities() {
        if let data = userDefaults.data(forKey: "savedCities"),
           let cities = try? JSONDecoder().decode([City].self, from: data) {
            savedCities = cities
        }
    }
    
    private func loadLastViewedCity() {
        if let data = userDefaults.data(forKey: "lastViewedCity"),
           let city = try? JSONDecoder().decode(City.self, from: data) {
            currentCity = city
            Task {
                await fetchWeather(for: city)
            }
        }
    }
    
    private func saveLastViewedCity(_ city: City) {
        userDefaults.set(try? JSONEncoder().encode(city), forKey: "lastViewedCity")
        
        if !savedCities.contains(city) {
            savedCities.append(city)
            userDefaults.set(try? JSONEncoder().encode(savedCities), forKey: "savedCities")
        }
    }
} 