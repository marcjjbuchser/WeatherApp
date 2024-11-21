import SwiftUI

struct CitySearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WeatherViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.searchResults) { city in
                        Button(action: {
                            Task {
                                await viewModel.fetchWeather(for: city)
                                dismiss()
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(city.name)
                                    .font(.headline)
                                Text(city.country)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Search Results")
                }
                
                if !viewModel.savedCities.isEmpty {
                    Section {
                        ForEach(viewModel.savedCities) { city in
                            Button(action: {
                                Task {
                                    await viewModel.fetchWeather(for: city)
                                    dismiss()
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.headline)
                                    Text(city.country)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    } header: {
                        Text("Saved Locations")
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search for a city")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                Task {
                    await viewModel.searchCities(query: newValue)
                }
            }
        }
    }
}

#Preview {
    CitySearchView(viewModel: WeatherViewModel())
} 