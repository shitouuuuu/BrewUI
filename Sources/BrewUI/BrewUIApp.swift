import SwiftUI

@main
struct BrewUIApp: App {
    @State private var store = BrewDataStore()
    
    var body: some Scene {
        WindowGroup {
            MainView(store: store)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
