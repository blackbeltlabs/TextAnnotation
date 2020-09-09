
import AppKit

public extension NSColor {
  static func color(from textColor: TextColor) -> NSColor {
    return NSColor(red: textColor.red,
                   green: textColor.green,
                   blue: textColor.blue,
                   alpha: textColor.alpha)
  }
  
  var textColor: TextColor {
    return TextColor(red: redComponent, green: greenComponent, blue: blueComponent, alpha: alphaComponent)
  }
  
  
  // MARK: - Hex colors support
  
  convenience init(hex: String, alpha: CGFloat = 1.0) {
    let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    var color: UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red   = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue  = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
  
  var hexString: String {
    guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
        return "#FFFFFF"
    }
    let red = Int(round(rgbColor.redComponent * 0xFF))
    let green = Int(round(rgbColor.greenComponent * 0xFF))
    let blue = Int(round(rgbColor.blueComponent * 0xFF))
    let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
    return hexString as String
  }
}
