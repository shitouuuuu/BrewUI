import Foundation

// MARK: - Core Enums

public enum PackageType: String, Codable, CaseIterable, Identifiable, Sendable {
    case formula = "Formula"
    case cask = "Cask"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .formula: return "terminal.fill"
        case .cask: return "macwindow"
        }
    }
}

public enum ConsoleLogType: Sendable {
    case info
    case warning
    case error
    case command
    case success
    
    public var colorName: String {
        switch self {
        case .info: return "blue"
        case .warning: return "orange"
        case .error: return "red"
        case .command: return "purple"
        case .success: return "green"
        }
    }
}

public struct ConsoleLog: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp: Date
    public let message: String
    public let type: ConsoleLogType
    
    public init(timestamp: Date = Date(), message: String, type: ConsoleLogType = .info) {
        self.timestamp = timestamp
        self.message = message
        self.type = type
    }
}

// MARK: - JSON Decoding Models for Homebrew API

public struct BrewInfoResponse: Codable, Sendable {
    public let formulae: [FormulaModel]?
    public let casks: [CaskModel]?
}

public struct FormulaModel: Codable, Identifiable, Sendable {
    public var id: String { name }
    
    public let name: String
    public let fullName: String?
    public let desc: String?
    public let license: String?
    public let homepage: String?
    public let versions: FormulaVersions?
    public let installed: [FormulaInstalledItem]?
    public let outdated: Bool?
    public let pinned: Bool?
    public let dependencies: [String]?
    public let buildDependencies: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullName = "full_name"
        case desc
        case license
        case homepage
        case versions
        case installed
        case outdated
        case pinned
        case dependencies
        case buildDependencies = "build_dependencies"
    }
    
    public var currentVersionStr: String {
        if let firstInst = installed?.first {
            return firstInst.version
        }
        return versions?.stable ?? "Unknown"
    }
    
    public var latestVersionStr: String {
        return versions?.stable ?? currentVersionStr
    }
}

public struct FormulaVersions: Codable, Sendable {
    public let stable: String?
    public let head: String?
    public let bottle: Bool?
}

public struct FormulaInstalledItem: Codable, Sendable {
    public let version: String
    public let installedAsDependency: Bool?
    public let installedOnRequest: Bool?

    enum CodingKeys: String, CodingKey {
        case version
        case installedAsDependency = "installed_as_dependency"
        case installedOnRequest = "installed_on_request"
    }
}

public struct CaskModel: Codable, Identifiable, Sendable {
    public var id: String { token }
    
    public let token: String
    public let name: [String]?
    public let desc: String?
    public let homepage: String?
    public let version: String?
    public let installed: String?
    public let outdated: Bool?
    public let autoUpdates: Bool?
    
    enum CodingKeys: String, CodingKey {
        case token
        case name
        case desc
        case homepage
        case version
        case installed
        case outdated
        case autoUpdates = "auto_updates"
    }
    
    public var displayName: String {
        return name?.first ?? token
    }
    
    public var currentVersionStr: String {
        return installed ?? "Not Installed"
    }
    
    public var latestVersionStr: String {
        return version ?? "Unknown"
    }
}

// MARK: - Outdated JSON Model

public struct OutdatedResponse: Codable, Sendable {
    public let formulae: [OutdatedFormula]?
    public let casks: [OutdatedCask]?
}

public struct OutdatedFormula: Codable, Identifiable, Sendable {
    public var id: String { name }
    
    public let name: String
    public let installedVersions: [String]?
    public let currentVersion: String?
    public let pinned: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case installedVersions = "installed_versions"
        case currentVersion = "current_version"
        case pinned
    }
}

public struct OutdatedCask: Codable, Identifiable, Sendable {
    public var id: String { name }
    
    public let name: String
    public let installedVersions: String?
    public let currentVersion: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case installedVersions = "installed_versions"
        case currentVersion = "current_version"
    }
}

// MARK: - Unified Package Item for UI Rendering

public struct UnifiedPackageItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let displayName: String
    public let type: PackageType
    public let description: String
    public let homepage: String
    public let installedVersion: String
    public let latestVersion: String
    public let isOutdated: Bool
    public let isDependency: Bool
    public let license: String
    public let rawDependencies: [String]
    
    public init(formula: FormulaModel) {
        self.id = "formula:\(formula.name)"
        self.name = formula.name
        self.displayName = formula.name
        self.type = .formula
        self.description = formula.desc ?? "No description available"
        self.homepage = formula.homepage ?? ""
        self.installedVersion = formula.currentVersionStr
        self.latestVersion = formula.latestVersionStr
        self.isOutdated = formula.outdated ?? false
        self.isDependency = formula.installed?.first?.installedAsDependency ?? false
        self.license = formula.license ?? "N/A"
        self.rawDependencies = formula.dependencies ?? []
    }
    
    public init(cask: CaskModel) {
        self.id = "cask:\(cask.token)"
        self.name = cask.token
        self.displayName = cask.displayName
        self.type = .cask
        self.description = cask.desc ?? "No description available"
        self.homepage = cask.homepage ?? ""
        self.installedVersion = cask.installed ?? "Not Installed"
        self.latestVersion = cask.version ?? "Unknown"
        self.isOutdated = cask.outdated ?? false
        self.isDependency = false
        self.license = "Proprietary / Open Source"
        self.rawDependencies = []
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: UnifiedPackageItem, rhs: UnifiedPackageItem) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Search Result Item

public struct SearchResultItem: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let type: PackageType
    public let isInstalled: Bool
}
