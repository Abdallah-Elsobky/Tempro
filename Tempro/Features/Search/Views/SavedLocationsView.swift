import SwiftUI

struct SavedLocationsView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        // TODO: Sprint 4 — implement list of saved locations
        VStack {
            Text("Saved Locations View Stub")
                .padding()
        }
    }
}

#Preview {
    SavedLocationsView(viewModel: SearchViewModel())
}
