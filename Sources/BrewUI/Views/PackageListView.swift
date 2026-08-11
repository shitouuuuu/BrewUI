import SwiftUI

public struct PackageListView: View {
    let targetType: PackageType
    @Bindable var store: BrewDataStore
    
    @State private var searchText: String = ""
    @State private var filterOutdatedOnly: Bool = false
    @State private var hideDependencies: Bool = false
    
    public init(targetType: PackageType, store: BrewDataStore) {
        self.targetType = targetType
        self.store = store
    }
    
    var filteredItems: [UnifiedPackageItem] {
        store.allItems.filter { item in
            guard item.type == targetType else { return false }
            
            if filterOutdatedOnly && !item.isOutdated {
                return false
            }
            if hideDependencies && item.isDependency {
                return false
            }
            
            if searchText.isEmpty {
                return true
            } else {
                let query = searchText.lowercased()
                return item.displayName.lowercased().contains(query) ||
                       item.name.lowercased().contains(query) ||
                       item.description.lowercased().contains(query)
            }
        }
    }
    
    public var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                // Filter & Search Toolbar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Filter \(targetType.rawValue)s...", text: $searchText)
                            .textFieldStyle(.plain)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    Toggle(isOn: $filterOutdatedOnly) {
                        Text("Outdated (\(filteredItems.filter { $0.isOutdated }.count))")
                            .font(.caption)
                    }
                    .toggleStyle(.checkbox)
                    
                    if targetType == .formula {
                        Toggle(isOn: $hideDependencies) {
                            Text("Direct Only")
                                .font(.caption)
                        }
                        .toggleStyle(.checkbox)
                    }
                    
                    Spacer()
                    
                    Text("\(filteredItems.count) item(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(12)
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                // Main Table / List View
                List(selection: $store.selectedPackage) {
                    ForEach(filteredItems) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.type.iconName)
                                .foregroundColor(item.type == .formula ? .blue : .purple)
                                .font(.system(size: 16))
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(item.displayName)
                                        .font(.body.weight(.semibold))
                                    
                                    if item.isOutdated {
                                        Text("Outdated")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(Color.orange.opacity(0.18))
                                            .cornerRadius(4)
                                    }
                                }
                                
                                Text(item.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text(item.installedVersion)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.secondary.opacity(0.12))
                                .cornerRadius(6)
                            
                            if item.isOutdated {
                                Button(action: {
                                    Task { await store.upgradePackage(item) }
                                }) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .foregroundColor(.orange)
                                }
                                .buttonStyle(.plain)
                                .help("Upgrade package")
                            }
                        }
                        .padding(.vertical, 4)
                        .tag(item)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
            .frame(minWidth: 400)
            
            // Detail Panel (Inspector)
            if let selected = store.selectedPackage {
                PackageDetailView(item: selected, store: store)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "square.dashed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("Select a package to view details")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
    }
}
