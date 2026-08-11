import SwiftUI

public struct PackageDetailView: View {
    let item: UnifiedPackageItem
    @Bindable var store: BrewDataStore
    
    @State private var showingUninstallAlert = false
    
    public init(item: UnifiedPackageItem, store: BrewDataStore) {
        self.item = item
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header Title & Icon
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: item.type.iconName)
                        .font(.system(size: 32))
                        .foregroundColor(item.type == .formula ? .blue : .purple)
                        .frame(width: 48, height: 48)
                        .background(item.type == .formula ? Color.blue.opacity(0.12) : Color.purple.opacity(0.12))
                        .cornerRadius(10)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.displayName)
                            .font(.title2.bold())
                        
                        Text(item.name)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            Text(item.type.rawValue)
                                .font(.caption.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(item.type == .formula ? Color.blue.opacity(0.2) : Color.purple.opacity(0.2))
                                .cornerRadius(4)
                            
                            if item.isOutdated {
                                Text("Outdated")
                                    .font(.caption.bold())
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(4)
                            }
                            
                            if item.isDependency {
                                Text("Dependency")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.15))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                // Action Buttons
                HStack(spacing: 12) {
                    if item.isOutdated {
                        Button(action: {
                            Task { await store.upgradePackage(item) }
                        }) {
                            Label("\(store.tr("Upgrade to")) \(item.latestVersion)", systemImage: "arrow.up.circle.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .disabled(store.isTaskRunning)
                    }
                    
                    if store.ignoredOutdatedNames.contains(item.name) {
                        Button(action: {
                            store.unignorePackage(item.name)
                        }) {
                            Label(store.tr("Restore"), systemImage: "bell")
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    } else if item.isOutdated {
                        Button(action: {
                            store.ignorePackage(item.name)
                        }) {
                            Label(store.tr("Ignore"), systemImage: "bell.slash")
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    }
                    
                    if !item.homepage.isEmpty, let url = URL(string: item.homepage) {
                        Link(destination: url) {
                            Label(store.tr("Homepage"), systemImage: "safari")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button(role: .destructive, action: {
                        showingUninstallAlert = true
                    }) {
                        Label("Uninstall", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(store.isTaskRunning)
                }
                .alert("Uninstall \(item.displayName)?", isPresented: $showingUninstallAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Uninstall", role: .destructive) {
                        Task { await store.uninstallPackage(item) }
                    }
                } message: {
                    Text("Are you sure you want to uninstall \(item.displayName)? This will remove it from your system.")
                }
                
                // Metadata Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Package Information")
                        .font(.headline)
                    
                    DetailRow(title: "Description", value: item.description)
                    DetailRow(title: "Installed Version", value: item.installedVersion, isMonospaced: true)
                    DetailRow(title: "Latest Version", value: item.latestVersion, isMonospaced: true)
                    DetailRow(title: "License", value: item.license)
                }
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                
                // Dependencies List
                if !item.rawDependencies.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dependencies (\(item.rawDependencies.count))")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(item.rawDependencies, id: \.self) { dep in
                                Text(dep)
                                    .font(.system(size: 11, design: .monospaced))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(18)
        }
        .frame(minWidth: 320, idealWidth: 360)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var isMonospaced: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(isMonospaced ? .system(size: 13, design: .monospaced) : .body)
                .textSelection(.enabled)
        }
    }
}

// Helper for pill flow layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.offsets[index].x, y: bounds.minY + result.offsets[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var offsets: [CGPoint] = []
        var size: CGSize = .zero
        
        init(in maxLineWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxLineWidth, currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                offsets.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxLineWidth, height: currentY + lineHeight)
        }
    }
}
