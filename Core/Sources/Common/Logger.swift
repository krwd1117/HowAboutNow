import Foundation
import OSLog

public final class Logger {
    public static let shared = Logger()
    fileprivate static let dateFormatter = DateFormatter()
    private static let subsystem = Bundle.main.bundleIdentifier ?? ""
    private static let osLog = OSLog(subsystem: subsystem, category: "Application")
    
    public enum Level: String {
        case debug = "[💬 DEBUG]"
        case error = "[‼️ ERROR]"
        case info = "[ℹ️ INFO]"
        case verbose = "[🔬 VERBOSE]"
        case warning = "[⚠️ WARNING]"
        case severe = "[🔥 SEVERE]"
        
        fileprivate var prefix: String {
            return "\(rawValue)"
        }
        
        fileprivate var osLogType: OSLogType {
            switch self {
            case .debug, .verbose:
                return .debug
            case .info:
                return .info
            case .warning:
                return .error
            case .error, .severe:
                return .fault
            }
        }
    }
    
    private init() {
        Self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last ?? ""
    }
    
    private class func log(level: Level, message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = false) {
        let time = Self.dateFormatter.string(from: Date())
        let threadInfo = thread ? "[\(Thread.isMainThread ? "Main" : "Background")] " : ""
        let file = sourceFileName(filePath: filename)
        let logMessage = """
            ----------------------------------------
            \(time) \(level.prefix) \(threadInfo)
            [\(file)]:\(line) \(funcName)
            👉 \(message)
            ----------------------------------------
            """
        
        #if DEBUG
        // Print to console
        Swift.print(logMessage)
        #endif
        
        // Log to Console.app
        os_log(
            .init(stringLiteral: "%{public}@"),
            log: Self.osLog,
            type: level.osLogType,
            logMessage
        )
    }
}

// MARK: - Public Methods
public extension Logger {
    static func d(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = true) {
        log(level: .debug, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
    
    static func e(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = true) {
        log(level: .error, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
    
    static func i(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = false) {
        log(level: .info, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
    
    static func v(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = false) {
        log(level: .verbose, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
    
    static func w(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = true) {
        log(level: .warning, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
    
    static func s(_ message: Any, filename: String = #file, line: Int = #line, funcName: String = #function, thread: Bool = true) {
        log(level: .severe, message: message, filename: filename, line: line, funcName: funcName, thread: thread)
    }
}

// MARK: - Date Extension
fileprivate extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self)
    }
}
