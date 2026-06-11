import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var locationsStore: LocationsStore
    @Binding var activeTab: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    searchBar
                        .padding(.top, 10)
                    
                    if viewModel.isSearching {
                        ProgressView()
                            .tint(.white)
                            .padding()
                        Spacer()
                    } else if !viewModel.searchText.isEmpty {
                        if viewModel.searchResults.isEmpty {
                            VStack(spacing: 8) {
                                Text("No cities found for '\(viewModel.searchText)'")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 40)
                            Spacer()
                        } else {
                            searchResultsList
                        }
                    } else {
                        if !locationsStore.savedLocations.isEmpty {
                            SavedLocationsView(activeTab: $activeTab)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                                    .accessibilityLabel("Magnifying glass icon")
                                Text("Start typing to search globally")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.top, 60)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.clear, for: .navigationBar)
            .preferredColorScheme(.dark)
            .background(Color.clear)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
                .accessibilityLabel("Search icon")
            
            TextField("Search for a city...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.search()
                }
                .accessibilityLabel("City name search field")
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.search()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var searchResultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { result in
                    Button(action: {
                        let saved = viewModel.toSavedLocation(result)
                        locationsStore.add(saved)
                        activeTab = locationsStore.savedLocations.count
                        viewModel.searchText = ""
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(result.country)
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .accessibilityLabel("Add \(result.name) to saved locations")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Location result: \(result.name), \(result.country)")
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    SearchView(activeTab: .constant(0))
        .environmentObject(LocationsStore())
        .background(Color.black.opacity(0.85))
}
