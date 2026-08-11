import SwiftUI

public struct DashboardView: View {
    @Bindable var store: BrewDataStore
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Banner
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.tr("Homebrew Dashboard"))
                            .font(.system(size: 26, weight: .bold))
                        
                        if let date = store.lastRefreshedDate {
                            Text("\(store.tr("Last updated:")) \(date.formatted(date: .abbreviated, time: .standard))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text(store.tr("Loading package environment..."))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        Button(action: {
                            Task { await store.refreshAllData() }
                        }) {
                            Label(store.tr("Refresh"), systemImage: "arrow.clockwise")
                        }
                        .disabled(store.isLoading || store.isTaskRunning)
                        
                        if !store.outdatedItems.isEmpty {
                            Button(action: {
                                Task { await store.upgradeAll() }
                            }) {
                                Label("\(store.tr("Upgrade All")) (\(store.outdatedItems.count))", systemImage: "arrow.up.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .disabled(store.isTaskRunning)
                        }
                    }
                }
                .padding(.bottom, 4)
                
                // Outdated Warning Banner (if any)
                if !store.outdatedItems.isEmpty {
                    HStack(spacing: 14) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(store.outdatedItems.count) \(store.tr("package(s) can be upgraded"))")
                                .font(.headline)
                            Text(store.tr("Keep your CLI tools and apps secure and up to date."))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(store.tr("View Updates")) {
                            store.selectedCategory = .updates
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Stat Cards Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatCard(
                        title: "Formulae",
                        value: "\(store.formulae.count)",
                        subtitle: store.tr("CLI Tools & Libraries"),
                        icon: "terminal.fill",
                        color: .blue
                    ) {
                        store.selectedCategory = .formulae
                    }
                    
                    StatCard(
                        title: "Casks",
                        value: "\(store.casks.count)",
                        subtitle: store.tr("Mac Desktop Apps"),
                        icon: "macwindow",
                        color: .purple
                    ) {
                        store.selectedCategory = .casks
                    }
                    
                    StatCard(
                        title: store.tr("Outdated"),
                        value: "\(store.outdatedItems.count)",
                        subtitle: store.outdatedItems.isEmpty ? store.tr("All Up to Date") : store.tr("Pending Updates"),
                        icon: "arrow.triangle.2.circlepath",
                        color: store.outdatedItems.isEmpty ? .green : .orange
                    ) {
                        store.selectedCategory = .updates
                    }
                    
                    StatCard(
                        title: store.tr("System Doctor"),
                        value: store.doctorStatus,
                        subtitle: store.tr("Environment Health"),
                        icon: "stethoscope",
                        color: store.doctorStatus == "Healthy" ? .green : (store.doctorStatus == "Warnings Found" ? .orange : .gray)
                    ) {
                        store.selectedCategory = .maintenance
                    }
                }
                
                // Maintenance & Quick Actions Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.tr("Quick Maintenance Actions"))
                        .font(.title3.bold())
                    
                    HStack(spacing: 16) {
                        QuickActionButton(
                            title: store.tr("Run Doctor"),
                            subtitle: store.tr("Diagnose system & permissions"),
                            icon: "cross.case.fill",
                            color: .teal
                        ) {
                            Task {
                                store.selectedCategory = .maintenance
                                await store.runDoctor()
                            }
                        }
                        
                        QuickActionButton(
                            title: store.tr("Cleanup Cache"),
                            subtitle: store.tr("Reclaim disk space"),
                            icon: "trash.fill",
                            color: .pink
                        ) {
                            Task {
                                await store.runCleanup()
                            }
                        }
                        
                        QuickActionButton(
                            title: store.tr("Discover Packages"),
                            subtitle: store.tr("Search & install new software"),
                            icon: "magnifyingglass.circle.fill",
                            color: .indigo
                        ) {
                            store.selectedCategory = .search
                        }
                    }
                }
                .padding(.top, 10)
                
                // Installed Packages Overview
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Recently Installed Packages")
                            .font(.title3.bold())
                        Spacer()
                        Button("See All Formulae") {
                            store.selectedCategory = .formulae
                        }
                        .buttonStyle(.link)
                    }
                    
                    VStack(spacing: 8) {
                        ForEach(store.allItems.prefix(6)) { item in
                            HStack {
                                Image(systemName: item.type.iconName)
                                    .foregroundColor(item.type == .formula ? .blue : .purple)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.displayName)
                                        .font(.body.weight(.semibold))
                                    Text(item.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Text(item.installedVersion)
                                    .font(.system(size: 12, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.12))
                                    .cornerRadius(6)
                            }
                            .padding(10)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(24)
        }
    }
}

// MARK: - Subcomponents

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
