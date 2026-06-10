import SwiftUI

struct AppRouter: View {
    @StateObject private var locationsStore = LocationsStore()
    
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .environmentObject(locationsStore)
    }
}

#Preview {
    AppRouter()
}
