
import AppKit

public extension NSColor {
  static func color(from textColor: TextColor) -> NSColor {
    return NSColor(red: textColor.red,
                   green: textColor.green,
                   blue: textColor.blue,
                   alpha: textColor.alpha)
  }
  
  var textColor: TextColor {
    let rgbColor: NSColor
    
    if self.colorSpace == .sRGB {
      rgbColor = self
    } else {
      if let convertedColor = usingColorSpace(.sRGB) {
        rgbColor = convertedColor
      } else { // fallback
        return TextColor(red: 0, green: 0, blue: 0, alpha: 0)
      }
    }
    
    return TextColor(red: rgbColor.redComponent,
                     green: rgbColor.greenComponent,
                     blue: rgbColor.blueComponent,
                     alpha: rgbColor.alphaComponent)
  }
}
