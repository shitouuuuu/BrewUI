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
                    Text(store.tr("Package Updates"))
                        .font(.system(size: 24, weight: .bold))
                    Text("\(store.outdatedItems.count) \(store.tr("package(s) can be upgraded to newer versions."))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !store.outdatedItems.isEmpty {
                    Button(action: {
                        Task { await store.upgradeAll() }
                    }) {
                        Label(store.tr("Upgrade All Packages"), systemImage: "arrow.up.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(store.isTaskRunning)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Divider()
            
            if store.outdatedItems.isEmpty && store.ignoredOutdatedItems.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                    
                    Text(store.tr("All Packages Up to Date"))
                        .font(.title2.bold())
                    
                    Text(store.tr("Your Homebrew formulae and casks are running the latest releases."))
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button(store.tr("Check Again")) {
                        Task { await store.refreshAllData() }
                    }
                    .buttonStyle(.bordered)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    // Section 1: Active Pending Updates
                    if !store.outdatedItems.isEmpty {
                        Section(header: Text("\(store.outdatedItems.count) \(store.tr("package(s) can be upgraded"))").font(.headline)) {
                            ForEach(store.outdatedItems) { item in
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
                                    
                                    HStack(spacing: 8) {
                                        if store.currentUpgradingItem?.id == item.id {
                                            HStack(spacing: 6) {
                                                ProgressView()
                                                    .controlSize(.small)
                                                Text(store.tr("Upgrading..."))
                                                    .font(.caption.bold())
                                                    .foregroundColor(.orange)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.orange.opacity(0.15))
                                            .cornerRadius(8)
                                        } else if store.upgradeQueue.contains(where: { $0.id == item.id }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "clock.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                                Text(store.tr("Waiting..."))
                                                    .font(.caption.bold())
                                                    .foregroundColor(.blue)
                                                
                                                Button(action: {
                                                    store.removeFromQueue(item)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.secondary)
                                                }
                                                .buttonStyle(.plain)
                                                .help(store.tr("Cancel Queue"))
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(Color.blue.opacity(0.15))
                                            .cornerRadius(8)
                                        } else {
                                            Button(action: {
                                                store.enqueueUpgrade(item)
                                            }) {
                                                Text(store.tr("Upgrade"))
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(.orange)
                                            
                                            Button(action: {
                                                store.ignorePackage(item.name)
                                            }) {
                                                Label(store.tr("Ignore"), systemImage: "bell.slash")
                                            }
                                            .buttonStyle(.bordered)
                                            .tint(.gray)
                                            .help("Hide update notifications for this software")
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    
                    // Section 2: Ignored Outdated Packages
                    if !store.ignoredOutdatedItems.isEmpty {
                        Section(header: HStack {
                            Text(store.tr("Ignored Updates"))
                                .font(.headline)
                            Spacer()
                            Text("\(store.ignoredOutdatedItems.count) \(store.tr("ignored package(s)"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }) {
                            ForEach(store.ignoredOutdatedItems) { item in
                                HStack(spacing: 16) {
                                    Image(systemName: item.type.iconName)
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                        .frame(width: 32, height: 32)
                                        .background(Color.gray.opacity(0.12))
                                        .cornerRadius(8)
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text(item.displayName)
                                                .font(.body.weight(.semibold))
                                                .foregroundColor(.secondary)
                                            
                                            Text(store.tr("Ignored"))
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 1)
                                                .background(Color.gray.opacity(0.2))
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(item.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(item.installedVersion) -> \(item.latestVersion)")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    
                                    Button(action: {
                                        store.unignorePackage(item.name)
                                    }) {
                                        Label(store.tr("Restore"), systemImage: "bell")
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }
}
