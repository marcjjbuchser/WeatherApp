import XCTest
@testable import WeatherApp

final class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!
    var cityService: CityService!
    var mockSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        weatherService = WeatherService(session: mockSession)
        cityService = CityService(session: mockSession)
    }
    
    override func tearDown() {
        weatherService = nil
        cityService = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchWeatherSuccess() async throws {
        // Given
        let jsonString = """
        {
            "current": {
                "temperature_2m": 20.5,
                "wind_speed_10m": 5.2,
                "weather_code": 0
            },
            "hourly": {
                "time": ["2024-03-20T00:00"],
                "temperature_2m": [19.5],
                "wind_speed_10m": [4.8],
                "precipitation_probability": [10],
                "weather_code": [0]
            },
            "hourly_units": {
                "temperature_2m": "°C",
                "wind_speed_10m": "km/h",
                "precipitation_probability": "%",
                "weather_code": "wmo code"
            }
        }
        """
        mockSession.mockData = jsonString.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let weather = try await weatherService.fetchWeather(latitude: 0, longitude: 0)
        
        // Then
        XCTAssertEqual(weather.current.temp, 20.5)
        XCTAssertEqual(weather.current.weatherCode, 0)
        XCTAssertEqual(weather.hourly.count, 1)
    }
    
    func testSearchCitiesSuccess() async throws {
        // Given
        let jsonString = """
        {
            "results": [
                {
                    "id": 1,
                    "name": "London",
                    "latitude": 51.5074,
                    "longitude": -0.1278,
                    "country": "United Kingdom",
                    "admin1": "England"
                }
            ]
        }
        """
        mockSession.mockData = jsonString.data(using: .utf8)!
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        // When
        let cities = try await cityService.searchCities(query: "London")
        
        // Then
        XCTAssertEqual(cities.count, 1)
        XCTAssertEqual(cities[0].name, "London")
        XCTAssertEqual(cities[0].country, "England, United Kingdom")
    }
    
    func testEmptySearchQuery() async throws {
        let cities = try await cityService.searchCities(query: "")
        XCTAssertTrue(cities.isEmpty)
    }
    
    func testInvalidResponse() async {
        // Given
        mockSession.mockError = WeatherError.invalidResponse
        
        // When/Then
        do {
            _ = try await weatherService.fetchWeather(latitude: 0, longitude: 0)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is WeatherError)
        }
        
        do {
            _ = try await cityService.searchCities(query: "London")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is WeatherError)
        }
    }
}

// Mock URLSession that implements our protocol
class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw WeatherError.invalidResponse
        }
        return (data, response)
    }
} 