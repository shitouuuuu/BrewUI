import SwiftUI

public struct SearchDiscoverView: View {
    @Bindable var store: BrewDataStore
    
    @State private var queryText: String = ""
    @State private var selectedTypeFilter: String = "All"
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    var filteredResults: [SearchResultItem] {
        if selectedTypeFilter == "Formulae" {
            return store.searchResults.filter { $0.type == .formula }
        } else if selectedTypeFilter == "Casks" {
            return store.searchResults.filter { $0.type == .cask }
        }
        return store.searchResults
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header & Search Box
            VStack(alignment: .leading, spacing: 12) {
                Text("Search & Discover Packages")
                    .font(.system(size: 24, weight: .bold))
                
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search Homebrew formulae or casks (e.g., node, ffmpeg, docker, raycast)...", text: $queryText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                Task { await store.searchRegistry(query: queryText) }
                            }
                        if !queryText.isEmpty {
                            Button(action: {
                                queryText = ""
                                store.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(10)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                    
                    Button("Search") {
                        Task { await store.searchRegistry(query: queryText) }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(queryText.trimmingCharacters(in: .whitespaces).isEmpty || store.isSearching)
                }
                
                // Filter Tabs
                if !store.searchResults.isEmpty {
                    Picker("Filter Type", selection: $selectedTypeFilter) {
                        Text("All (\(store.searchResults.count))").tag("All")
                        Text("Formulae (\(store.searchResults.filter { $0.type == .formula }.count))").tag("Formulae")
                        Text("Casks (\(store.searchResults.filter { $0.type == .cask }.count))").tag("Casks")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
            
            if store.isSearching {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Searching Homebrew registry for '\(queryText)'...")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "square.stack.3d.up.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(queryText.isEmpty ? "Type a package name above to search Homebrew." : "No matching packages found.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredResults) { item in
                    HStack(spacing: 16) {
                        Image(systemName: item.type.iconName)
                            .font(.title3)
                            .foregroundColor(item.type == .formula ? .blue : .purple)
                            .frame(width: 32, height: 32)
                            .background(item.type == .formula ? Color.blue.opacity(0.12) : Color.purple.opacity(0.12))
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.body.weight(.semibold))
                            Text(item.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if item.isInstalled {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Installed")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.12))
                            .cornerRadius(8)
                        } else {
                            Button(action: {
                                Task { await store.installPackage(name: item.name, type: item.type) }
                            }) {
                                Label("Install", systemImage: "arrow.down.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .disabled(store.isTaskRunning)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }
}
