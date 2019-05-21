
import Cocoa

@IBDesignable
class KnobView2: NSView {
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    let side = min(dirtyRect.width, dirtyRect.height) - Configuration.controlStrokeWidth
    let squareRect = CGRect(x: dirtyRect.origin.x + (dirtyRect.width - side)/2,
                            y: dirtyRect.origin.y + (dirtyRect.height - side)/2,
                            width: side,
                            height: side)
    
    let path = NSBezierPath(ovalIn: squareRect)
    Palette.controlFillColor.setFill()
    path.fill()
    
    path.lineWidth = Configuration.controlStrokeWidth
    Palette.controlStrokeColor.setStroke()
    path.stroke()
  }
}
