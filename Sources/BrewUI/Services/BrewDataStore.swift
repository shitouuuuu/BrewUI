import Foundation
import Observation

public enum SidebarCategory: String, CaseIterable, Identifiable, Sendable {
    case dashboard = "Dashboard"
    case formulae = "Formulae"
    case casks = "Casks"
    case updates = "Updates"
    case search = "Search & Discover"
    case maintenance = "Maintenance & Health"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .dashboard: return "gauge.with.needle.fill"
        case .formulae: return "terminal.fill"
        case .casks: return "macwindow"
        case .updates: return "arrow.triangle.2.circlepath"
        case .search: return "magnifyingglass"
        case .maintenance: return "stethoscope"
        case .settings: return "gearshape.fill"
        }
    }
}

@Observable
@MainActor
public final class BrewDataStore {
    public var selectedCategory: SidebarCategory = .dashboard
    public var selectedPackage: UnifiedPackageItem?
    
    public var currentLanguage: AppLanguage = {
        if let raw = UserDefaults.standard.string(forKey: "BrewUI_Language"),
           let lang = AppLanguage(rawValue: raw) {
            return lang
        }
        return .chinese
    }() {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "BrewUI_Language")
        }
    }
    
    public func tr(_ key: String) -> String {
        return L10n.text(key, lang: currentLanguage)
    }

    
    public var formulae: [FormulaModel] = []
    public var casks: [CaskModel] = []
    public var allItems: [UnifiedPackageItem] = []
    public var outdatedItems: [UnifiedPackageItem] = []
    
    public var searchResults: [SearchResultItem] = []
    public var isSearching: Bool = false
    public var searchQuery: String = ""
    
    public var consoleLogs: [ConsoleLog] = []
    public var isConsoleExpanded: Bool = true
    
    public var isLoading: Bool = false
    public var executingTaskTitle: String? = nil
    public var isTaskRunning: Bool = false
    
    public var doctorOutput: String = ""
    public var doctorStatus: String = "Not Checked"
    public var isDoctorRunning: Bool = false
    
    public var lastRefreshedDate: Date? = nil
    public var brewPath: String = "/opt/homebrew/bin/brew"
    
    public init() {
        Task {
            await detectBrewPath()
            await refreshAllData()
        }
    }
    
    public func detectBrewPath() async {
        let path = await BrewCLIExecutor.shared.getBrewPath()
        self.brewPath = path
        appendLog("Detected Homebrew path: \(path)", type: .info)
    }
    
    public func appendLog(_ message: String, type: ConsoleLogType = .info) {
        let log = ConsoleLog(message: message, type: type)
        consoleLogs.append(log)
        // Keep max 500 logs for memory performance
        if consoleLogs.count > 500 {
            consoleLogs.removeFirst(consoleLogs.count - 500)
        }
    }
    
    public func clearLogs() {
        consoleLogs.removeAll()
    }
    
    // MARK: - Load Installed & Outdated Packages
    
    public func refreshAllData() async {
        guard !isTaskRunning else { return }
        isLoading = true
        appendLog("Refreshing Homebrew package data...", type: .command)
        
        do {
            let rawOutput = try await BrewCLIExecutor.shared.runCommand(args: ["info", "--json=v2", "--installed"])
            
            if let firstBrace = rawOutput.firstIndex(of: "{"),
               let lastBrace = rawOutput.lastIndex(of: "}") {
                let jsonString = String(rawOutput[firstBrace...lastBrace])
                if let data = jsonString.data(using: .utf8) {
                    let decoded = try JSONDecoder().decode(BrewInfoResponse.self, from: data)
                    self.formulae = decoded.formulae ?? []
                    self.casks = decoded.casks ?? []
                    
                    var items: [UnifiedPackageItem] = []
                    for f in self.formulae {
                        items.append(UnifiedPackageItem(formula: f))
                    }
                    for c in self.casks {
                        items.append(UnifiedPackageItem(cask: c))
                    }
                    
                    self.allItems = items.sorted(by: { $0.displayName.lowercased() < $1.displayName.lowercased() })
                    appendLog("Loaded \(self.formulae.count) formulae and \(self.casks.count) casks.", type: .success)
                }
            } else {
                appendLog("Invalid JSON format received from brew info.", type: .error)
            }
            
            await fetchOutdated()
            lastRefreshedDate = Date()
        } catch {
            appendLog("Failed to refresh packages: \(error.localizedDescription)", type: .error)
        }
        
        isLoading = false
    }
    
    private func fetchOutdated() async {
        do {
            let rawOutput = try await BrewCLIExecutor.shared.runCommand(args: ["outdated", "--json=v2"])
            if let firstBrace = rawOutput.firstIndex(of: "{"),
               let lastBrace = rawOutput.lastIndex(of: "}") {
                let jsonString = String(rawOutput[firstBrace...lastBrace])
                if let data = jsonString.data(using: .utf8) {
                    let decoded = try JSONDecoder().decode(OutdatedResponse.self, from: data)
                    let outdatedFormulaNames = Set((decoded.formulae ?? []).map { $0.name })
                    let outdatedCaskNames = Set((decoded.casks ?? []).map { $0.name })
                    
                    self.outdatedItems = allItems.filter { item in
                        if item.type == .formula {
                            return outdatedFormulaNames.contains(item.name)
                        } else {
                            return outdatedCaskNames.contains(item.name)
                        }
                    }
                    appendLog("Found \(self.outdatedItems.count) outdated package(s).", type: .warning)
                }
            }
        } catch {
            appendLog("Failed to fetch outdated packages: \(error.localizedDescription)", type: .error)
        }
    }
    
    // MARK: - Package Actions
    
    public func installPackage(name: String, type: PackageType) async {
        let cmdArgs = (type == .cask) ? ["install", "--cask", name] : ["install", name]
        await executeBrewCommand(title: "Installing \(name)", args: cmdArgs)
        await refreshAllData()
    }
    
    public func uninstallPackage(_ item: UnifiedPackageItem) async {
        let cmdArgs = (item.type == .cask) ? ["uninstall", "--cask", item.name] : ["uninstall", item.name]
        await executeBrewCommand(title: "Uninstalling \(item.displayName)", args: cmdArgs)
        if selectedPackage?.id == item.id {
            selectedPackage = nil
        }
        await refreshAllData()
    }
    
    public func upgradePackage(_ item: UnifiedPackageItem) async {
        let cmdArgs = (item.type == .cask) ? ["upgrade", "--cask", item.name] : ["upgrade", item.name]
        await executeBrewCommand(title: "Upgrading \(item.displayName)", args: cmdArgs)
        await refreshAllData()
    }
    
    public func upgradeAll() async {
        await executeBrewCommand(title: "Upgrading All Packages", args: ["upgrade"])
        await refreshAllData()
    }
    
    public func runCleanup() async {
        await executeBrewCommand(title: "Running Homebrew Cleanup", args: ["cleanup", "-s"])
        await refreshAllData()
    }
    
    public func runDoctor() async {
        isDoctorRunning = true
        appendLog("Executing `brew doctor`...", type: .command)
        do {
            let output = try await BrewCLIExecutor.shared.runCommand(args: ["doctor"])
            doctorOutput = output
            if output.contains("Your system is ready to brew") {
                doctorStatus = "Healthy"
                appendLog("System is ready to brew!", type: .success)
            } else {
                doctorStatus = "Warnings Found"
                appendLog("Doctor found warnings/issues.", type: .warning)
            }
        } catch {
            doctorOutput = "Error running doctor: \(error.localizedDescription)"
            doctorStatus = "Error"
            appendLog("Doctor error: \(error.localizedDescription)", type: .error)
        }
        isDoctorRunning = false
    }
    
    // MARK: - Search Registry
    
    public func searchRegistry(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        appendLog("Searching Homebrew registry for '\(query)'...", type: .command)
        
        do {
            let output = try await BrewCLIExecutor.shared.runCommand(args: ["search", query])
            let lines = output.components(separatedBy: .newlines)
            var results: [SearchResultItem] = []
            
            var currentType: PackageType = .formula
            let installedNames = Set(allItems.map { $0.name })
            
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.contains("==> Formulae") {
                    currentType = .formula
                    continue
                } else if trimmed.contains("==> Casks") {
                    currentType = .cask
                    continue
                }
                
                if !trimmed.isEmpty && !trimmed.hasPrefix("==>") {
                    let names = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                    for n in names {
                        let isInst = installedNames.contains(n)
                        results.append(SearchResultItem(id: "\(currentType.rawValue):\(n)", name: n, type: currentType, isInstalled: isInst))
                    }
                }
            }
            
            searchResults = results
            appendLog("Found \(results.count) search result(s).", type: .info)
        } catch {
            appendLog("Search error: \(error.localizedDescription)", type: .error)
        }
        
        isSearching = false
    }
    
    // MARK: - Command Runner Helper
    
    private func executeBrewCommand(title: String, args: [String]) async {
        isTaskRunning = true
        executingTaskTitle = title
        appendLog("🚀 Command started: brew \(args.joined(separator: " "))", type: .command)
        
        do {
            let status = try await BrewCLIExecutor.shared.runStreamingCommand(args: args) { [weak self] line in
                Task { @MainActor in
                    self?.appendLog(line, type: .info)
                }
            }
            
            if status == 0 {
                appendLog("✅ \(title) completed successfully.", type: .success)
            } else {
                appendLog("❌ \(title) failed with code \(status).", type: .error)
            }
        } catch {
            appendLog("❌ Execution error: \(error.localizedDescription)", type: .error)
        }
        
        isTaskRunning = false
        executingTaskTitle = nil
    }
}
