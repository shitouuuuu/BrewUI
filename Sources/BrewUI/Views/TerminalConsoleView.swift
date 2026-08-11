import SwiftUI

public struct TerminalConsoleView: View {
    @Bindable var store: BrewDataStore
    @State private var autoScroll: Bool = true
    @State private var copiedNotice: Bool = false
    
    public init(store: BrewDataStore) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(store.isTaskRunning ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    Text("Terminal Console Output")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    if let task = store.executingTaskTitle {
                        Text("— \(task)")
                            .font(.system(size: 11, weight: .regular, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Toggle(isOn: $autoScroll) {
                        Text("Auto-scroll")
                            .font(.system(size: 11))
                    }
                    .toggleStyle(.checkbox)
                    
                    Button(action: copyLogs) {
                        Label(copiedNotice ? "Copied!" : "Copy", systemImage: copiedNotice ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: { store.clearLogs() }) {
                        Label("Clear", systemImage: "trash")
                            .font(.system(size: 11))
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: { store.isConsoleExpanded.toggle() }) {
                        Image(systemName: store.isConsoleExpanded ? "chevron.down" : "chevron.up")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            if store.isConsoleExpanded {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 3) {
                            if store.consoleLogs.isEmpty {
                                Text("Ready. Execute any Homebrew command to view live terminal logs.")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .padding(8)
                            } else {
                                ForEach(store.consoleLogs) { log in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text(formattedTime(log.timestamp))
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.gray.opacity(0.7))
                                            .frame(width: 60, alignment: .leading)
                                        
                                        Text(log.message)
                                            .font(.system(size: 11, design: .monospaced))
                                            .foregroundColor(colorForType(log.type))
                                            .textSelection(.enabled)
                                    }
                                    .id(log.id)
                                }
                            }
                        }
                        .padding(8)
                    }
                    .background(Color(nsColor: .textBackgroundColor).opacity(0.95))
                    .onChange(of: store.consoleLogs.count) { _, _ in
                        if autoScroll, let last = store.consoleLogs.last {
                            withAnimation(.easeOut(duration: 0.1)) {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                .frame(height: 180)
            }
        }
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func colorForType(_ type: ConsoleLogType) -> Color {
        switch type {
        case .info: return .primary
        case .warning: return .orange
        case .error: return .red
        case .command: return .purple
        case .success: return .green
        }
    }
    
    private func copyLogs() {
        let text = store.consoleLogs.map { "[\(formattedTime($0.timestamp))] \($0.message)" }.joined(separator: "\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copiedNotice = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            copiedNotice = false
        }
    }
}
