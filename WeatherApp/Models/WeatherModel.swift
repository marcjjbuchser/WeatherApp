import Foundation

struct WeatherModel: Codable {
    let current: CurrentWeather
    let hourly: [HourlyForecast]
    
    struct CurrentWeather: Codable {
        let temp: Double
        let windSpeed: Double
        let weatherCode: Int
        let description: String
    }
    
    struct HourlyForecast: Codable, Identifiable {
        let id = UUID()
        let time: Date
        let temp: Double
        let windSpeed: Double
        let precipitation: Double
        let weatherCode: Int
    }
}

struct City: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
} 