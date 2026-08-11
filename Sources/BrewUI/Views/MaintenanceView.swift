import SwiftUI

public struct MaintenanceView: View {
    @Bindable var store: BrewDataStore
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Maintenance & System Health")
                        .font(.system(size: 24, weight: .bold))
                    Text("Keep your Homebrew installation clean, optimized, and error-free.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Doctor Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "stethoscope")
                            .font(.title)
                            .foregroundColor(.teal)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Homebrew Doctor")
                                .font(.headline)
                            Text("Check system configuration, file permissions, and tap integrity.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task { await store.runDoctor() }
                        }) {
                            Label(store.isDoctorRunning ? "Diagnosing..." : "Run Doctor", systemImage: "stethoscope")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.teal)
                        .disabled(store.isDoctorRunning || store.isTaskRunning)
                    }
                    
                    if !store.doctorOutput.isEmpty {
                        Divider()
                        
                        Text("Diagnostic Report:")
                            .font(.subheadline.bold())
                        
                        Text(store.doctorOutput)
                            .font(.system(size: 11, design: .monospaced))
                            .textSelection(.enabled)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(8)
                    }
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                // Cleanup Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.title)
                            .foregroundColor(.pink)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Homebrew Cleanup")
                                .font(.headline)
                            Text("Remove old downloads, outdated kegs, and stale cache files.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task { await store.runCleanup() }
                        }) {
                            Label("Run Cleanup", systemImage: "trash")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .disabled(store.isTaskRunning)
                    }
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            .padding(24)
        }
    }
}
