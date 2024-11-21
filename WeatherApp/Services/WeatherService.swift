import Foundation

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case noResults
    case decodingError(Error)
    case networkError(Error)
}

class WeatherService {
    private let session: URLSessionProtocol
    private let dateFormatter: DateFormatter
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        self.dateFormatter.timeZone = TimeZone(identifier: "UTC")
    }
    
    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,wind_speed_10m,weather_code&hourly=temperature_2m,precipitation_probability,wind_speed_10m,weather_code&timezone=auto") else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                if let date = self.dateFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
            print("Successfully decoded weather response")
            return weatherResponse.toWeatherModel()
        } catch let error as DecodingError {
            print("Decoding Error: \(error)")
            throw WeatherError.decodingError(error)
        } catch {
            print("Network Error: \(error)")
            throw WeatherError.networkError(error)
        }
    }
}

class CityService {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func searchCities(query: String) async throws -> [City] {
        guard !query.isEmpty else { return [] }
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encodedQuery)&count=10&language=en&format=json") else {
            throw WeatherError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw WeatherError.invalidResponse
            }
            
            let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: data)
            guard let results = geocodingResponse.results, !results.isEmpty else {
                return []
            }
            
            return results.map { $0.toCity() }
        } catch let error as DecodingError {
            throw WeatherError.decodingError(error)
        } catch {
            throw WeatherError.networkError(error)
        }
    }
}

// Updated Response models for OpenMeteo API
private struct WeatherResponse: Codable {
    let current: CurrentResponse
    let hourly: HourlyResponse
    let hourlyUnits: HourlyUnits
    
    enum CodingKeys: String, CodingKey {
        case current
        case hourly
        case hourlyUnits = "hourly_units"
    }
    
    func toWeatherModel() -> WeatherModel {
        let hourlyData = zip(hourly.time, zip(hourly.temperature, zip(hourly.windspeed, zip(hourly.precipitationProbability, hourly.weathercode))))
        let hourlyForecasts = hourlyData.map { time, data in
            let (temp, windPrecipCode) = data
            let (windspeed, precipCode) = windPrecipCode
            let (precip, code) = precipCode
            return WeatherModel.HourlyForecast(
                time: time,
                temp: temp,
                windSpeed: windspeed,
                precipitation: Double(precip) / 100.0,
                weatherCode: code
            )
        }
        
        return WeatherModel(
            current: .init(
                temp: current.temperature,
                windSpeed: current.windspeed,
                weatherCode: current.weathercode,
                description: getWeatherDescription(code: current.weathercode)
            ),
            hourly: hourlyForecasts
        )
    }
    
    private func getWeatherDescription(code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 77: return "Snow grains"
        case 80, 81, 82: return "Rain showers"
        case 85, 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96, 99: return "Thunderstorm with hail"
        default: return "Unknown"
        }
    }
}

private struct CurrentResponse: Codable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case windspeed = "wind_speed_10m"
        case weathercode = "weather_code"
    }
}

private struct HourlyUnits: Codable {
    let temperature: String
    let windspeed: String
    let precipitationProbability: String
    let weathercode: String
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case windspeed = "wind_speed_10m"
        case precipitationProbability = "precipitation_probability"
        case weathercode = "weather_code"
    }
}

private struct HourlyResponse: Codable {
    let time: [Date]
    let temperature: [Double]
    let windspeed: [Double]
    let precipitationProbability: [Int]
    let weathercode: [Int]
    
    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case windspeed = "wind_speed_10m"
        case precipitationProbability = "precipitation_probability"
        case weathercode = "weather_code"
    }
}

private struct GeocodingResponse: Codable {
    let results: [GeocodingResult]?
    
    struct GeocodingResult: Codable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String
        let admin1: String?
        
        func toCity() -> City {
            City(
                id: id,
                name: name,
                country: [admin1, country].compactMap { $0 }.joined(separator: ", "),
                latitude: latitude,
                longitude: longitude
            )
        }
    }
} 