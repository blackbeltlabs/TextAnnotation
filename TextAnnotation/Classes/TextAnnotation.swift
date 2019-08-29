import Cocoa

public protocol TextAnnotation where Self: NSView {
  var delegate: TextAnnotationDelegate? { get set }
  var text: String { get set }
  var frame: CGRect { get set }
  var state: TextAnnotationState { get set }
  
  func startEditing()
  
  func performUndo()
	func performRedo()
	func performRedoAllActions()
	func setState(with actions: [TextAnnotationAction])
}

extension TextAnnotation {
  public func delete() {
    removeFromSuperview()
  }
  
  public func select() {
    state = .active
  }
  
  public func deselect() {
    state = .inactive
  }
  
  public func addTo(canvas: TextAnnotationCanvas) {
    canvas.add(textAnnotation: self)
  }
}

