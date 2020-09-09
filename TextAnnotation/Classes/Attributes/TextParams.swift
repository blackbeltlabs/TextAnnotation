import AppKit

public struct TextParams: Codable {
  // MARK: - Properties
  public var fontName: String?
  public var fontSize: Double?
  public var foregroundColor: String? // hex
  public var outlineWidth: Double?
  public var outlineColor: String? // hex
  public var shadowColor: String? // hex
  public var shadowOffsetX: Double?
  public var shadowOffsetY: Double?
  public var shadowBlur: Double?
  
  
  // MARK: - Init
  public init(fontName: String? = nil,
              fontSize: Double? = nil,
              foregroundColor: String? = nil,
              outlineWidth: Double? = nil,
              outlineColor: String? = nil,
              shadowColor: String? = nil,
              shadowOffsetX: Double? = nil,
              shadowOffsetY: Double? = nil,
              shadowBlur: Double? = nil) {
    self.fontName = fontName
    self.fontSize = fontSize
    self.foregroundColor = foregroundColor
    self.outlineWidth = outlineWidth
    self.outlineColor = outlineColor
    self.shadowColor = shadowColor
    self.shadowOffsetX = shadowOffsetX
    self.shadowOffsetY = shadowOffsetY
    self.shadowBlur = shadowBlur
  }
  
  static func defaultFontAndColor() -> TextParams {
    TextParams(fontName: "HelveticaNeue-Bold", fontSize: 30.0, foregroundColor: "#fe4a01")
  }
  
  // get attributes from current params
  var attributes: [NSAttributedString.Key: Any] {
    
    var attributes: [NSAttributedString.Key: Any] = [:]
    
    
    if let fontName = self.fontName {
      let size: CGFloat
      
      if let fontSize = self.fontSize {
        size = CGFloat(fontSize)
      } else {
        size = 30.0
      }
      
      let font = NSFont(name: fontName, size: size) ?? NSFont.systemFont(ofSize: size)
      attributes[.font] = font
    } else if let fontSize = self.fontSize {
      attributes[.font] = NSFont.systemFont(ofSize: CGFloat(fontSize))
    } else {
      attributes[.font] = NSFont.systemFont(ofSize: 30.0)
    }
    
    if let foregroundColor = self.foregroundColor {
      attributes[.foregroundColor] = NSColor(hex: foregroundColor)
    }
    
    
    if let outlineWidth = self.outlineWidth {
      attributes[.strokeWidth] = CGFloat(outlineWidth)
    }
    
    if let outlineColor = self.outlineColor {
      attributes[.strokeColor] = NSColor(hex: outlineColor)
    }
    
    
    if shadowColor != nil || shadowOffsetX != nil || shadowOffsetY != nil || shadowBlur != nil {
      let shadow = NSShadow()
      
      if let shadowColor = self.shadowColor {
        shadow.shadowColor = NSColor(hex: shadowColor)
      }
      
      if let shadowOffsetX = self.shadowOffsetX,
         let shadowOffsetY = self.shadowOffsetY {
        shadow.shadowOffset = NSSize(width: shadowOffsetX, height: shadowOffsetY)
      }
      
      if let shadowBlur = self.shadowBlur {
        shadow.shadowBlurRadius = CGFloat(shadowBlur)
      }
      
      attributes[.shadow] = shadow
    }
    
    return attributes
  }
  
  public static func textParams(from attributes: [NSAttributedString.Key: Any]) -> TextParams {
    var params = TextParams()
    if let font = attributes[.font] as? NSFont {
      params.fontName = font.fontName
      params.fontSize = Double(font.pointSize)
    }
    
    if let foregroundColor = attributes[.foregroundColor] as? NSColor {
      params.foregroundColor = foregroundColor.hexString
    }
    
    if let outlineWidth = attributes[.strokeColor] as? CGFloat {
      params.outlineWidth = Double(outlineWidth)
    }
    
    if let outlineColor = attributes[.strokeColor] as? NSColor {
      params.outlineColor = outlineColor.hexString
    }
    
    if let shadow = attributes[.shadow] as? NSShadow {
      if let color = shadow.shadowColor {
        params.shadowColor = color.hexString
      }
      params.shadowOffsetX = Double(shadow.shadowOffset.width)
      params.shadowOffsetY = Double(shadow.shadowOffset.height)
      
      params.shadowBlur = Double(shadow.shadowBlurRadius)
    }
    
    return params
  }

}
