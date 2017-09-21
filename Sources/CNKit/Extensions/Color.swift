#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
    public extension UIColor {
        /// Initialize a new UIColor from a given hex value.
        ///
        /// - Parameter rgb: RGB value, easily provided as hex, e.g. 0xAABBCC
        convenience init(withRGB rgb: Int) {
            self.init(red: CGFloat(((rgb & 0xff0000) >> 16))/255.0,
                      green: CGFloat(((rgb & 0xff00) >> 8))/255.0,
                      blue: CGFloat((rgb & 0xff))/255.0,
                      alpha: 0.5)
        }
    }
#elseif os(macOS)
    public extension NSColor {
        /// Initialize a new NSColor from a given hex value.
        ///
        /// - Parameter rgb: RGB value, easily provided as hex, e.g. 0xAABBCC
        convenience init(withRGB rgb: Int) {
            self.init(red: CGFloat(((rgb & 0xff0000) >> 16))/255.0,
                      green: CGFloat(((rgb & 0xff00) >> 8))/255.0,
                      blue: CGFloat((rgb & 0xff))/255.0,
                      alpha: 0.5)
        }
    }
#endif

public extension Floor.Room {
    #if os(iOS)
        /// The color this room should be displayed as.
        public var color: UIColor? {
            return UIColor(withRGB: self.rawColor)
        }
    #elseif os(macOS)
        /// The color this room should be displayed as.
        public var color: NSColor? {
            return NSColor(withRGB: self.rawColor)
        }
    #endif
}
