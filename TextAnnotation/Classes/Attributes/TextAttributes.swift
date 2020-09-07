import AppKit

public struct TextAttributes {
  public static func shadowAttributes(color: NSColor,
                                      offsetX: CGFloat,
                                      offsetY: CGFloat,
                                      blur: CGFloat) -> [NSAttributedString.Key: Any] {
    let textShadow = NSShadow()
    textShadow.shadowColor = color
    textShadow.shadowOffset = NSMakeSize(offsetX, offsetY)
    textShadow.shadowBlurRadius = blur
    return [
        NSAttributedString.Key.shadow: textShadow,
    ]
  }
    
  public static func defaultOutlineAttributes() -> [NSAttributedString.Key: Any] {
     [
      NSAttributedString.Key.strokeColor: NSColor.white,
      NSAttributedString.Key.strokeWidth: -1.5,
    ]
  }
  
  public static func outline(outlineWidth: CGFloat, outlineColor: NSColor) -> [NSAttributedString.Key: Any] {
    [
      NSAttributedString.Key.strokeColor: outlineColor,
      NSAttributedString.Key.strokeWidth: outlineWidth,
    ]
  }
    
  public static func outlineWithShadow(outlineWidth: CGFloat,
                                       outlineColor: NSColor,
                                       shadowColor: NSColor,
                                       shadowOffsetX: CGFloat,
                                       shadowOffsetY: CGFloat,
                                       shadowBlur: CGFloat
                                       ) -> [NSAttributedString.Key: Any] {
    let shadow = NSShadow()
    shadow.shadowColor = shadowColor
    shadow.shadowOffset = NSSize(width: shadowOffsetX,
                                 height: shadowOffsetY)
    shadow.shadowBlurRadius = shadowBlur
    
    return [
      .strokeColor: outlineColor,
      .strokeWidth: outlineWidth,
      .shadow: shadow
    ]
  }
}
