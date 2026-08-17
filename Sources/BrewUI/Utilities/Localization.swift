import Foundation
import Observation

public enum AppLanguage: String, CaseIterable, Identifiable, Codable, Sendable {
    case chinese = "zh"
    case english = "en"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .chinese: return "简体中文 (Chinese)"
        case .english: return "English"
        }
    }
}

public struct L10n {
    public static func text(_ key: String, lang: AppLanguage) -> String {
        guard let langDict = translations[lang] else { return key }
        return langDict[key] ?? key
    }
    
    private static let translations: [AppLanguage: [String: String]] = [
        .chinese: [
            // Sidebar
            "Dashboard": "仪表盘概览",
            "Formulae": "Formulae (命令行工具)",
            "Casks": "Casks (Mac 桌面应用)",
            "Updates": "版本升级",
            "Search & Discover": "搜索与探索",
            "Maintenance & Health": "维护与环境诊断",
            "Settings": "设置与环境",
            
            // Dashboard
            "Homebrew Dashboard": "Homebrew 仪表盘",
            "Last updated:": "上次更新于：",
            "Loading package environment...": "正在载入 Homebrew 环境...",
            "Refresh": "刷新数据",
            "Upgrade All": "一键全部升级",
            "package(s) can be upgraded": "个软件包有可用升级",
            "Keep your CLI tools and apps secure and up to date.": "保持您的命令行工具与 Mac 软件均为最新版本。",
            "View Updates": "查看更新",
            "CLI Tools & Libraries": "命令行工具与依赖库",
            "Mac Desktop Apps": "Mac 桌面软件",
            "Outdated": "待升级",
            "All Up to Date": "已是最新版本",
            "Pending Updates": "等待升级",
            "System Doctor": "环境诊断",
            "Environment Health": "系统环境健康度",
            "Quick Maintenance Actions": "快捷维护操作",
            "Run Doctor": "运行 Doctor 诊断",
            "Diagnose system & permissions": "诊断系统配置与文件权限",
            "Cleanup Cache": "清理缓存空间",
            "Reclaim disk space": "释放旧版本与下载缓存空间",
            "Discover Packages": "探索新软件包",
            "Search & install new software": "检索并一键安装工具与应用",
            "Recently Installed Packages": "最近使用的软件包",
            "See All Formulae": "查看全部 Formulae",
            
            // Package List & Detail
            "Filter": "筛选",
            "Outdated Only": "仅看待升级",
            "Direct Only": "仅看直接安装",
            "item(s)": "个软件包",
            "Select a package to view details": "选择左侧软件包查看详细信息",
            "Package Information": "软件包信息",
            "Description": "描述说明",
            "Installed Version": "已安装版本",
            "Latest Version": "最新可用版本",
            "License": "开源/授权协议",
            "Dependencies": "依赖项",
            "Homepage": "官方主页",
            "Uninstall": "卸载",
            "Uninstall Package": "卸载软件包",
            "Are you sure you want to uninstall": "确定要卸载吗？此操作将从系统中抹除该软件包。",
            "Cancel": "取消",
            "Upgrade to": "升级至",
            "Dependency": "依赖包",
            "Not Installed": "未安装",
            
            // Updates View
            "Package Updates": "软件包升级中心",
            "package(s) can be upgraded to newer versions.": "个软件包可升级至新版本。",
            "Upgrade All Packages": "一键升级全部软件包",
            "All Packages Up to Date": "所有软件包均为最新",
            "Your Homebrew formulae and casks are running the latest releases.": "您的所有 Homebrew Formulae 和 Casks 均运行在最新发布版本。",
            "Check Again": "重新检测",
            "Upgrade": "升级",
            "Upgrading...": "升级中...",
            "Waiting...": "排队中...",
            "Cancel Queue": "取消排队",
            "Queue All": "全部加入队列",
            "Ignore": "忽略此更新",
            "Ignored": "已忽略更新",
            "Unignore": "取消忽略",
            "Restore": "恢复提示",
            "Ignored Updates": "已忽略更新的软件包",
            "ignored package(s)": "个已忽略升级提醒的软件包",
            "No ignored packages": "暂无已忽略更新的软件包",
            
            // Search View
            "Search & Discover Packages": "搜索与探索软件包",
            "Search Homebrew formulae or casks (e.g., node, ffmpeg, docker, raycast)...": "搜索 Homebrew 软件包 (例如 node, ffmpeg, docker, raycast)...",
            "Search": "搜索",
            "All": "全部",
            "Searching Homebrew registry for": "正在搜索 Homebrew 注册表",
            "Type a package name above to search Homebrew.": "在上方输入名称开始检索 Homebrew 注册表。",
            "No matching packages found.": "未找到匹配的软件包。",
            "Installed": "已安装",
            "Install": "安装",
            
            // Maintenance View
            "Maintenance & System Health": "维护与环境诊断",
            "Keep your Homebrew installation clean, optimized, and error-free.": "保持您的 Homebrew 环境整洁、高效且无异常。",
            "Homebrew Doctor": "Homebrew 诊断医生",
            "Check system configuration, file permissions, and tap integrity.": "检查系统配置、目录文件权限及软件源完整性。",
            "Diagnosing...": "正在诊断中...",
            "Diagnostic Report:": "诊断报告：",
            "Homebrew Cleanup": "Homebrew 缓存清理",
            "Remove old downloads, outdated kegs, and stale cache files.": "清理旧版本下载文件、废弃 Keg 以及过期缓存。",
            "Run Cleanup": "运行清理",
            
            // Settings View
            "Settings & Environment": "设置与环境配置",
            "Configure Homebrew binary location and system defaults.": "配置 Homebrew 可执行文件路径与界面偏好。",
            "Display Language": "界面显示语言",
            "Choose your preferred language for the UI:": "选择应用界面的首选语言：",
            "Homebrew Binary Location": "Homebrew 可执行文件路径",
            "BrewUI automatically detects standard installation paths on Apple Silicon (`/opt/homebrew/bin/brew`) and Intel Macs (`/usr/local/bin/brew`).": "BrewUI 自动识别 Apple Silicon (`/opt/homebrew/bin/brew`) 及 Intel Mac (`/usr/local/bin/brew`) 的标准安装路径。",
            "Path to brew binary...": "brew 可执行文件路径...",
            "Apply Custom Path": "应用自定义路径",
            "Auto Detect": "自动识别",
            "Path setting updated successfully!": "路径设置已更新！",
            "Active Binary Path:": "当前生效路径：",
            "System Information": "系统环境信息",
            "OS Version:": "操作系统版本：",
            "Architecture:": "处理器架构：",
            "App Version:": "应用版本：",
            
            // Terminal Console
            "Terminal Console Output": "终端实时控制台",
            "Auto-scroll": "自动滚动",
            "Copy": "复制日志",
            "Copied!": "已复制！",
            "Clear": "清空",
            "Ready. Execute any Homebrew command to view live terminal logs.": "已就绪。执行任何 Homebrew 操作时此处将实时显示终端输出日志。"
        ],
        .english: [:]
    ]
}
