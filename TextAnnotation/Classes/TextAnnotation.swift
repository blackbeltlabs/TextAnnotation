import Cocoa

public protocol TextAnnotation where Self: NSView {
  var delegate: TextAnnotationDelegate? { get set }
  var text: String { get set }
  var frame: CGRect { get set }
  var state: TextAnnotationState { get set }
}

extension TextAnnotation {
  public func delete() {
    removeFromSuperview()
  }
}

extension TextContainerView: TextAnnotation {
  
}
