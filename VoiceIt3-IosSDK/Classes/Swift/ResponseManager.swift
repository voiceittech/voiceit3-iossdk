import Foundation

/// Manages localized prompt strings from the Prompts.strings file
@objc public class VoiceItResponseManager: NSObject {

    private static var bundle: Bundle? = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let podBundle = Bundle(for: VoiceItResponseManager.self)
        if let bundleURL = podBundle.resourceURL?.appendingPathComponent("VoiceIt3-IosSDK.bundle"),
           let resourceBundle = Bundle(url: bundleURL) {
            return resourceBundle
        }
        return podBundle
        #endif
    }()

    @objc public static func getMessage(_ key: String) -> String {
        bundle?.localizedString(forKey: key, value: nil, table: "Prompts") ?? key
    }

    @objc public static func getMessage(_ key: String, variable: String) -> String {
        let format = getMessage(key)
        return String(format: format, variable)
    }
}
