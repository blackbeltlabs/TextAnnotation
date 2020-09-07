import AppKit

public struct TextAttributes {
  public static func defaultAttributes(font: NSFont, color: NSColor) -> [NSAttributedString.Key: Any] {
    let textShadow = NSShadow()
    textShadow.shadowColor = NSColor.black.withAlphaComponent(0.5)
    textShadow.shadowOffset = NSMakeSize(1.0, -1.5)
    return [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: color,
        NSAttributedString.Key.shadow: textShadow,
    ]
  }
    
     
  public static func defaultOutlineAttributes(font: NSFont, color: NSColor) -> [NSAttributedString.Key: Any] {
    let textShadow = NSShadow()
    textShadow.shadowColor = NSColor.white.withAlphaComponent(1.0)
    textShadow.shadowOffset = NSMakeSize(1.5, 1.5)
    textShadow.shadowBlurRadius = 2.0
    
    return [
      NSAttributedString.Key.font: font,
      NSAttributedString.Key.strokeColor: NSColor.white,
      NSAttributedString.Key.strokeWidth: -2.5,
      NSAttributedString.Key.foregroundColor: color,
      NSAttributedString.Key.shadow: textShadow
    ]
  }
}
