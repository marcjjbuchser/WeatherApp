# Weather App

A beautiful and modern iOS weather application built with SwiftUI that follows Apple's design guidelines and uses the latest iOS development practices. Created with [Cursor](https://cursor.sh/) and Claude 3.5.

## Features

- 🌤️ Real-time weather information using the OpenMeteo API
- 📍 Search and save multiple city locations
- 🎨 Beautiful weather animations for different conditions
- 📱 Clean, modern UI following Apple's design guidelines
- 📊 24-hour forecast with detailed weather information
- 💾 Persistent storage of user's preferred locations
- 🌍 Worldwide city search with the OpenMeteo Geocoding API

## Screenshots


![Simulator Screenshot - iPhone 16 Pro - 2024-11-21 at 12 32 50](https://github.com/user-attachments/assets/c70e0a96-a028-43a1-b161-4afd93c73765)


![Simulator Screenshot - iPhone 16 Pro Max - 2024-11-21 at 12 33 58](https://github.com/user-attachments/assets/9aa89fe9-40fc-47c0-b0a6-9fab0e51adfa)


## Technical Details

### Architecture
- MVVM (Model-View-ViewModel) architecture
- Clean Architecture principles
- Protocol-oriented programming
- Dependency injection for better testability

### Technologies Used
- SwiftUI for the UI layer
- Async/await for network calls
- Combine for reactive programming
- UserDefaults for persistent storage
- XCTest for unit testing

### APIs
- OpenMeteo Weather API for weather data
- OpenMeteo Geocoding API for city search

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/WeatherApp.git
   ```

2. Open WeatherApp.xcodeproj in Xcode:
   ```bash
   cd WeatherApp
   open WeatherApp.xcodeproj
   ```

3. Build and run the project:
   - Select your target device or simulator
   - Press ⌘R or click the Play button

## Project Structure

```plaintext
WeatherApp/
├── App/
│   └── WeatherAppApp.swift
├── Models/
│   └── WeatherModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── WeatherAnimationView.swift
│   ├── CurrentWeatherView.swift
│   ├── HourlyForecastView.swift
│   ├── CitySearchView.swift
│   └── WeatherIcon.swift
├── ViewModels/
│   └── WeatherViewModel.swift
├── Services/
│   ├── WeatherService.swift
│   ├── LocationManager.swift
│   └── URLSessionProtocol.swift
├── Resources/
│   └── Assets.xcassets/
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
├── Preview Content/
│   └── Preview Assets.xcassets/
├── WeatherAppTests/
│   ├── WeatherServiceTests.swift
│   └── WeatherViewModelTests.swift
├── WeatherAppUITests/
│   ├── WeatherAppUITests.swift
│   └── WeatherAppUITestsLaunchTests.swift
├── WeatherApp.xcodeproj/
│   ├── project.pbxproj
│   └── project.xcworkspace/
├── Info.plist
└── README.md
