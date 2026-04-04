import UIKit

/// Theme configuration for VoiceIt SDK UI elements
@objc public class Theme: NSObject {
    static var styles: [String: String] = [:]

    @objc public static func set(_ styleSettings: [String: String]?) {
        styles = styleSettings ?? [:]
    }

    @objc public static var mainColor: String {
        styles["kThemeColor"] ?? "#FBC132"
    }

    @objc public static var iconColor: String {
        let icon = styles["kIconStyle"] ?? "default"
        switch icon {
        case "monochrome": return "#FFFFFF"
        default: return "#FBC132"
        }
    }

    @objc public static var mainUIColor: UIColor {
        UIColor(hexString: mainColor)
    }

    @objc public static var iconUIColor: UIColor {
        UIColor(hexString: iconColor)
    }

    @objc public static var mainCGColor: CGColor {
        mainUIColor.cgColor
    }
}
