import SwiftUI

public struct UpdatesView: View {
    @Bindable var store: BrewDataStore
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Package Updates")
                        .font(.system(size: 24, weight: .bold))
                    Text("\(store.outdatedItems.count) package(s) can be upgraded to newer versions.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !store.outdatedItems.isEmpty {
                    Button(action: {
                        Task { await store.upgradeAll() }
                    }) {
                        Label("Upgrade All Packages", systemImage: "arrow.up.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(store.isTaskRunning)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
            
            if store.outdatedItems.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                    
                    Text("All Packages Up to Date")
                        .font(.title2.bold())
                    
                    Text("Your Homebrew formulae and casks are running the latest releases.")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("Check Again") {
                        Task { await store.refreshAllData() }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(store.outdatedItems) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.type.iconName)
                            .font(.title3)
                            .foregroundColor(item.type == .formula ? .blue : .purple)
                            .frame(width: 32, height: 32)
                            .background(item.type == .formula ? Color.blue.opacity(0.12) : Color.purple.opacity(0.12))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.displayName)
                                .font(.body.weight(.bold))
                            Text(item.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Version Diff Badge
                        HStack(spacing: 8) {
                            Text(item.installedVersion)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(6)
                            
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(item.latestVersion)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.18))
                                .cornerRadius(6)
                        }
                        
                        Button(action: {
                            Task { await store.upgradePackage(item) }
                        }) {
                            Text("Upgrade")
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .disabled(store.isTaskRunning)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }
}
