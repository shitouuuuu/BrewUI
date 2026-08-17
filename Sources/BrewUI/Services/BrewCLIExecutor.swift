import Foundation

public final class BrewCLIExecutor: @unchecked Sendable {
    public static let shared = BrewCLIExecutor()
    
    private var customBrewPath: String?
    private let lock = NSLock()
    
    public init() {}
    
    public func setCustomBrewPath(_ path: String?) {
        lock.withLock {
            self.customBrewPath = path
        }
    }
    
    public func getBrewPath() -> String {
        let custom = lock.withLock { self.customBrewPath }
        if let custom = custom, !custom.isEmpty, FileManager.default.isExecutableFile(atPath: custom) {
            return custom
        }
        
        let candidatePaths = [
            "/opt/homebrew/bin/brew",
            "/usr/local/bin/brew",
            "/home/linuxbrew/.linuxbrew/bin/brew"
        ]
        
        for path in candidatePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return "brew"
    }
    
    // MARK: - Execute Command returning Full Output (String) safely without Pipe Deadlock
    
    public func runCommand(args: [String]) async throws -> String {
        let brewPath = getBrewPath()
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = args
        
        var env = ProcessInfo.processInfo.environment
        let currentPath = env["PATH"] ?? ""
        let brewDir = URL(fileURLWithPath: brewPath).deletingLastPathComponent().path
        env["PATH"] = "\(brewDir):/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:\(currentPath)"
        env["HOMEBREW_NO_AUTO_UPDATE"] = "1"
        env["HOMEBREW_COLOR"] = "0"
        process.environment = env
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        let fileHandle = pipe.fileHandleForReading
        
        // Start async pipe reading task BEFORE process execution to avoid 64KB buffer deadlock
        let readTask = Task.detached {
            return fileHandle.readDataToEndOfFile()
        }
        
        try process.run()
        
        let data = await readTask.value
        process.waitUntilExit()
        
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if process.terminationStatus != 0 && output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw NSError(domain: "BrewCLIError", code: Int(process.terminationStatus), userInfo: [
                NSLocalizedDescriptionKey: "brew \(args.joined(separator: " ")) failed with status \(process.terminationStatus)"
            ])
        }
        
        return output
    }
    
    // MARK: - Stream Command Output Line by Line
    
    public func runStreamingCommand(args: [String], onLine: @Sendable @escaping (String) -> Void) async throws -> Int32 {
        let brewPath = getBrewPath()
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: brewPath)
        process.arguments = args
        
        var env = ProcessInfo.processInfo.environment
        let currentPath = env["PATH"] ?? ""
        let brewDir = URL(fileURLWithPath: brewPath).deletingLastPathComponent().path
        env["PATH"] = "\(brewDir):/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:\(currentPath)"
        env["HOMEBREW_COLOR"] = "1"
        process.environment = env
        
        process.standardOutput = pipe
        process.standardError = pipe
        
        let outHandle = pipe.fileHandleForReading
        
        outHandle.readabilityHandler = { handle in
            let data = handle.availableData
            guard !data.isEmpty, let chunk = String(data: data, encoding: .utf8) else { return }
            let lines = chunk.components(separatedBy: .newlines)
            for line in lines {
                if !line.isEmpty {
                    onLine(line)
                }
            }
        }
        
        try process.run()
        process.waitUntilExit()
        
        outHandle.readabilityHandler = nil
        return process.terminationStatus
    }
}
