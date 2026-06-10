import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var locationsStore: LocationsStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
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
                                Text("No cities found")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Text("Try searching for another city name.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.top, 40)
                            Spacer()
                        } else {
                            searchResultsList
                        }
                    } else {
                        if !locationsStore.savedLocations.isEmpty {
                            SavedLocationsView()
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("Search Globally")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                Text("Find weather forecasts for any city.")
                                    .font(.system(size: 14, weight: .regular, design: .rounded))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.top, 60)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .navigationBarColorScheme(.dark)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
            
            TextField("Search for a city...", text: $viewModel.searchText)
                .foregroundColor(.white)
                .autocorrectionDisabled()
                .onChange(of: viewModel.searchText) { _ in
                    viewModel.search()
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.search()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var searchResultsList: some View {
        List(viewModel.searchResults) { result in
            Button(action: {
                let saved = viewModel.toSavedLocation(result)
                locationsStore.add(saved)
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
                }
                .padding(.vertical, 4)
            }
            .listRowBackground(Color.white.opacity(0.05))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

extension View {
    func navigationBarColorScheme(_ scheme: ColorScheme) -> some View {
        self.preferredColorScheme(scheme)
    }
}

#Preview {
    SearchView()
        .environmentObject(LocationsStore())
}
