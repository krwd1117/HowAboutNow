import Foundation

public enum ConfigurationError: Error {
    case missingKey(String)
    case invalidPlistFile
}

public final class ConfigurationManager {
    public static let shared = ConfigurationManager()
    
    private var configuration: [String: Any]?
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        guard let plistPath = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let plistData = FileManager.default.contents(atPath: plistPath),
              let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] else {
            return
        }
        
        configuration = plistDictionary
    }
    
    public func string(for key: String) throws -> String {
        guard let configuration = configuration else {
            throw ConfigurationError.invalidPlistFile
        }
        
        guard let value = configuration[key] as? String else {
            throw ConfigurationError.missingKey(key)
        }
        
        return value
    }
}

// MARK: - Configuration Keys
public extension ConfigurationManager {
    enum Keys {
        public static let openAIAPIKey = "OpenAIAPIKey"
        public static let openAIEndpoint = "OpenAIEndpoint"
    }
}
