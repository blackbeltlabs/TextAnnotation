import AppKit

public struct TextShadow {
  
  public init(color: NSColor,
              offsetX: CGFloat,
              offsetY: CGFloat,
              blur: CGFloat) {
    self.color = color
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.blur = blur
  }
  
  let color: NSColor
  let offsetX: CGFloat
  let offsetY: CGFloat
  let blur: CGFloat
}

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
    return [
      NSAttributedString.Key.strokeColor: NSColor.white,
      NSAttributedString.Key.strokeWidth: -1.5,
    ]
  }
  
  public static func outlineWithShadow(shadowProperties: TextShadow,
                                       outlineWidth: CGFloat,
                                       outlineColor: NSColor) -> [NSAttributedString.Key: Any] {
    let shadow = NSShadow()
    shadow.shadowColor = shadowProperties.color
    shadow.shadowOffset = NSSize(width: shadowProperties.offsetX,
                                 height: shadowProperties.offsetY)
    shadow.shadowBlurRadius = shadowProperties.blur
    
    return [
      .strokeColor: outlineColor,
      .strokeWidth: outlineWidth,
      .shadow: shadow
    ]
  }
}
