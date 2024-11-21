import SwiftUI

struct WeatherIcon: View {
    let code: Int
    
    var systemName: String {
        switch code {
        case 0: // Clear sky
            return "sun.max.fill"
        case 1, 2, 3: // Partly cloudy
            return "cloud.sun.fill"
        case 45, 48: // Foggy
            return "cloud.fog.fill"
        case 51, 53, 55: // Drizzle
            return "cloud.drizzle.fill"
        case 61, 63, 65: // Rain
            return "cloud.rain.fill"
        case 71, 73, 75, 77: // Snow
            return "cloud.snow.fill"
        case 80, 81, 82: // Rain showers
            return "cloud.heavyrain.fill"
        case 85, 86: // Snow showers
            return "cloud.snow.fill"
        case 95, 96, 99: // Thunderstorm
            return "cloud.bolt.rain.fill"
        default:
            return "sun.max.fill"
        }
    }
    
    var body: some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.multicolor)
    }
} 