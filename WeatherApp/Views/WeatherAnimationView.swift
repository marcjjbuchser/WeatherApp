import SwiftUI

struct WeatherAnimationView: View {
    let weatherCode: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color.clear
            
            // Weather animation based on weather code
            Group {
                switch weatherCode {
                case 800: // Clear sky
                    SunnyView()
                case 801...804: // Clouds
                    CloudyView()
                case 500...531: // Rain
                    RainyView()
                case 600...622: // Snow
                    SnowyView()
                default:
                    SunnyView()
                }
            }
            .opacity(isAnimating ? 1 : 0.3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever()) {
                isAnimating = true
            }
        }
    }
}

// Weather-specific views
private struct SunnyView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "sun.max.fill")
            .font(.system(size: 80))
            .foregroundColor(.yellow)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

private struct CloudyView: View {
    @State private var offset: CGFloat = -30
    
    var body: some View {
        HStack(spacing: -20) {
            Image(systemName: "cloud.fill")
                .font(.system(size: 70))
                .foregroundColor(.white.opacity(0.8))
                .offset(x: offset)
            
            Image(systemName: "cloud.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .offset(x: offset * 0.8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever()) {
                offset = 30
            }
        }
    }
}

private struct RainyView: View {
    let raindrops = 10
    
    var body: some View {
        ZStack {
            CloudyView()
            
            ForEach(0..<raindrops, id: \.self) { index in
                RaindropView()
                    .offset(x: CGFloat(index * 20) - 100)
            }
        }
    }
}

private struct RaindropView: View {
    @State private var offset: CGFloat = -100
    
    var body: some View {
        Image(systemName: "drop.fill")
            .font(.system(size: 20))
            .foregroundColor(.blue)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 1...2))
                    .repeatForever(autoreverses: false)
                ) {
                    offset = 100
                }
            }
    }
}

private struct SnowyView: View {
    let snowflakes = 15
    
    var body: some View {
        ZStack {
            CloudyView()
            
            ForEach(0..<snowflakes, id: \.self) { index in
                SnowflakeView()
                    .offset(x: CGFloat(index * 15) - 100)
            }
        }
    }
}

private struct SnowflakeView: View {
    @State private var offset: CGFloat = -100
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "snowflake")
            .font(.system(size: 20))
            .foregroundColor(.white)
            .rotationEffect(.degrees(rotation))
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .linear(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: false)
                ) {
                    offset = 100
                    rotation = 360
                }
            }
    }
} 