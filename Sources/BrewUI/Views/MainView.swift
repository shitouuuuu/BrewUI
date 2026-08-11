import SwiftUI

public struct MainView: View {
    @Bindable var store: BrewDataStore
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar Navigation
            List(SidebarCategory.allCases, selection: $store.selectedCategory) { category in
                NavigationLink(value: category) {
                    HStack(spacing: 10) {
                        Image(systemName: category.iconName)
                            .foregroundColor(iconColor(for: category))
                            .frame(width: 20)
                        
                        Text(store.tr(category.rawValue))
                            .font(.body)
                        
                        Spacer()
                        
                        // Badge count for Updates
                        if category == .updates && !store.outdatedItems.isEmpty {
                            Text("\(store.outdatedItems.count)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            // Detail / Content Area
            VStack(spacing: 0) {
                Group {
                    switch store.selectedCategory {
                    case .dashboard:
                        DashboardView(store: store)
                    case .formulae:
                        PackageListView(targetType: .formula, store: store)
                    case .casks:
                        PackageListView(targetType: .cask, store: store)
                    case .updates:
                        UpdatesView(store: store)
                    case .search:
                        SearchDiscoverView(store: store)
                    case .maintenance:
                        MaintenanceView(store: store)
                    case .settings:
                        SettingsView(store: store)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom Console Drawer
                TerminalConsoleView(store: store)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                if store.isLoading {
                    ProgressView()
                        .controlSize(.small)
                    Text("Refreshing...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if store.isTaskRunning {
                    ProgressView()
                        .controlSize(.small)
                    Text(store.executingTaskTitle ?? "Running...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func iconColor(for category: SidebarCategory) -> Color {
        switch category {
        case .dashboard: return .blue
        case .formulae: return .cyan
        case .casks: return .purple
        case .updates: return .orange
        case .search: return .green
        case .maintenance: return .teal
        case .settings: return .gray
        }
    }
}
