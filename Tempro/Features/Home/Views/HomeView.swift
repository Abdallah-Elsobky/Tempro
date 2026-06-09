import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        VStack {
            // TODO: Sprint 3 — implement complete HomeView interface
            Text("Home — Sprint 3")
                .font(.largeTitle)
                .padding()
        }
    }
}

#Preview {
    HomeView()
}
