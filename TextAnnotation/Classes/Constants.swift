import Cocoa

struct Configuration {
  static let controlStrokeWidth: CGFloat = 1
  static let frameMargin: CGFloat = 5
  static let dotRadius: CGFloat = 5
  static let horizontalTextPadding: CGFloat = 2
}

struct Palette {
  static var controlFillColor: NSColor  { return #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1) }
  static var controlStrokeColor: NSColor { return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) }
  static var frameStrokeColor: NSColor { return #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.7960784314, alpha: 1) }
}

