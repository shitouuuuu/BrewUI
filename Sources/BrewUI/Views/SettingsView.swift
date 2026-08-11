import SwiftUI

public struct SettingsView: View {
    @Bindable var store: BrewDataStore
    
    @State private var customPathText: String = ""
    @State private var savedNotice: Bool = false
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.tr("Settings & Environment"))
                        .font(.system(size: 24, weight: .bold))
                    Text(store.tr("Configure Homebrew binary location and system defaults."))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Language Selection Setting
                VStack(alignment: .leading, spacing: 12) {
                    Text(store.tr("Display Language"))
                        .font(.headline)
                    
                    Text(store.tr("Choose your preferred language for the UI:"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $store.currentLanguage) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                // Brew Executable Path Setting
                VStack(alignment: .leading, spacing: 14) {
                    Text(store.tr("Homebrew Binary Location"))
                        .font(.headline)
                    
                    Text(store.tr("BrewUI automatically detects standard installation paths on Apple Silicon (`/opt/homebrew/bin/brew`) and Intel Macs (`/usr/local/bin/brew`)."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        TextField(store.tr("Path to brew binary..."), text: $customPathText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(store.tr("Apply Custom Path")) {
                            Task {
                                await BrewCLIExecutor.shared.setCustomBrewPath(customPathText)
                                await store.detectBrewPath()
                                savedNotice = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    savedNotice = false
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button(store.tr("Auto Detect")) {
                            Task {
                                await BrewCLIExecutor.shared.setCustomBrewPath(nil)
                                await store.detectBrewPath()
                                customPathText = store.brewPath
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if savedNotice {
                        Text(store.tr("Path setting updated successfully!"))
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text(store.tr("Active Binary Path:"))
                            .font(.caption.bold())
                        Text(store.brewPath)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                
                // System Info Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Information")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("OS Version: macOS \(NSInformationElement.osVersionString)")
                            Text("Architecture: \(NSInformationElement.architecture)")
                            Text("App Version: BrewUI 1.0.0 (Native SwiftUI)")
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding(18)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
            }
            .padding(24)
            .onAppear {
                customPathText = store.brewPath
            }
        }
    }
}

private struct NSInformationElement {
    static var osVersionString: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }
    
    static var architecture: String {
        #if arch(arm64)
        return "Apple Silicon (arm64)"
        #else
        return "Intel (x86_64)"
        #endif
    }
}
