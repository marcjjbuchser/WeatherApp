import SwiftUI

struct HourlyForecastView: View {
    let forecasts: [WeatherModel.HourlyForecast]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("24-Hour Forecast")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(forecasts.prefix(24)) { forecast in
                        HourlyForecastCard(forecast: forecast)
                    }
                }
                .padding()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

private struct HourlyForecastCard: View {
    let forecast: WeatherModel.HourlyForecast
    
    var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: forecast.time)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(hourString)
                .font(.caption)
                .foregroundColor(.secondary)
            
            WeatherIcon(code: forecast.weatherCode)
                .font(.title2)
            
            Text("\(Int(round(forecast.temp)))°")
                .font(.title3)
                .bold()
            
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                Text("\(Int(round(forecast.precipitation * 100)))%")
                    .font(.caption2)
            }
            
            VStack(spacing: 4) {
                Image(systemName: "wind")
                    .foregroundColor(.gray)
                Text("\(Int(round(forecast.windSpeed)))")
                    .font(.caption2)
            }
        }
        .padding(.vertical, 8)
        .frame(width: 80)
    }
}

#Preview {
    HourlyForecastView(forecasts: [])
} 