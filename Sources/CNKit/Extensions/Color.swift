#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS)
public extension UIColor {
    convenience init(withRGB rgb: Int) {
        self.init(red: CGFloat(((rgb & 0xff0000) >> 16))/255.0,
                  green: CGFloat(((rgb & 0xff00) >> 8))/255.0,
                  blue: CGFloat((rgb & 0xff))/255.0,
                  alpha: 0.5)
    }
}
#elseif os(macOS)
public extension NSColor {
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
public var color: UIColor? {
    return UIColor(withRGB: self.rawColor)
}
#elseif os(macOS)
public var color: NSColor? {
    return NSColor(withRGB: self.rawColor)
}
#endif
}
