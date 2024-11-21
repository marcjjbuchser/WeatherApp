import SwiftUI

struct CurrentWeatherView: View {
    let weather: WeatherModel.CurrentWeather
    
    var body: some View {
        VStack(spacing: 16) {
            Text("\(Int(round(weather.temp)))°")
                .font(.system(size: 96, weight: .thin))
                .foregroundColor(.primary)
            
            Text(weather.description.capitalized)
                .font(.title2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                WeatherDataCard(
                    icon: "wind",
                    title: "Wind",
                    value: "\(Int(round(weather.windSpeed))) km/h"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

private struct WeatherDataCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .frame(minWidth: 80)
    }
} 