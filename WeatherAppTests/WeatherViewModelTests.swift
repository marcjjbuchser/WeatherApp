import XCTest
@testable import WeatherApp

@MainActor
final class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockCityService: MockCityService!
    var mockUserDefaults: UserDefaults!
    
    override func setUp() async throws {
        try await super.setUp()
        mockWeatherService = MockWeatherService()
        mockCityService = MockCityService()
        mockUserDefaults = UserDefaults(suiteName: #file)
        mockUserDefaults.removePersistentDomain(forName: #file)
        
        viewModel = WeatherViewModel(
            weatherService: mockWeatherService,
            cityService: mockCityService,
            userDefaults: mockUserDefaults
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        mockWeatherService = nil
        mockCityService = nil
        mockUserDefaults.removePersistentDomain(forName: #file)
        mockUserDefaults = nil
        try await super.tearDown()
    }
    
    func testFetchWeatherSuccess() async throws {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", latitude: 0, longitude: 0)
        let weather = WeatherModel(
            current: .init(temp: 20, windSpeed: 5, weatherCode: 0, description: "Clear"),
            hourly: []
        )
        mockWeatherService.mockWeather = weather
        
        // When
        await viewModel.fetchWeather(for: city)
        
        // Then
        XCTAssertEqual(viewModel.currentWeather?.current.temp, 20)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.currentCity, city)
    }
    
    func testSearchCitiesSuccess() async throws {
        // Given
        let cities = [
            City(id: 1, name: "Test City", country: "Test Country", latitude: 0, longitude: 0)
        ]
        mockCityService.mockCities = cities
        
        // When
        await viewModel.searchCities(query: "Test")
        
        // Then
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults[0].name, "Test City")
    }
    
    func testFetchWeatherError() async {
        // Given
        let city = City(id: 1, name: "Test City", country: "Test Country", latitude: 0, longitude: 0)
        mockWeatherService.mockError = WeatherError.invalidResponse
        
        // When
        await viewModel.fetchWeather(for: city)
        
        // Then
        XCTAssertNil(viewModel.currentWeather)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.error)
    }
    
    func testSearchCitiesError() async {
        // Given
        mockCityService.mockError = WeatherError.invalidResponse
        
        // When
        await viewModel.searchCities(query: "Test")
        
        // Then
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertNotNil(viewModel.error)
    }
}

class MockWeatherService: WeatherService {
    var mockWeather: WeatherModel?
    var mockError: Error?
    
    init() {
        super.init(session: MockURLSession())
    }
    
    override func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherModel {
        if let error = mockError {
            throw error
        }
        return mockWeather ?? WeatherModel(
            current: .init(temp: 0, windSpeed: 0, weatherCode: 0, description: ""),
            hourly: []
        )
    }
}

class MockCityService: CityService {
    var mockCities: [City]?
    var mockError: Error?
    
    init() {
        super.init(session: MockURLSession())
    }
    
    override func searchCities(query: String) async throws -> [City] {
        if let error = mockError {
            throw error
        }
        return mockCities ?? []
    }
} 
