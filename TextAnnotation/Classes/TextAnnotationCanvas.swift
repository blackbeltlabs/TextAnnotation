import Cocoa

public protocol TextAnnotationCanvas: ActivateResponder, MouseTrackingResponder {
  var view: NSView { get }
  var textAnnotations: [TextAnnotation] { get set }
  var selectedTextAnnotation: TextAnnotation? { get set }
  var lastMouseLocation: NSPoint? { get set }
}

extension TextAnnotationCanvas {
  var cursorSet: CursorSet {
    return CursorSet.shared
  }
  
  func set(selectedTextAnnotation: TextAnnotation?) {
    if self.selectedTextAnnotation === selectedTextAnnotation {
      return
    }
    
    if let lastSelection = self.selectedTextAnnotation {
      lastSelection.state = .inactive
    }
    
    self.selectedTextAnnotation = selectedTextAnnotation
  }
  
  public func addTextAnnotation(text: String, location: CGPoint) -> TextAnnotation {
    let annotation = TextContainerView(frame: NSRect(origin: location, size: CGSize.zero))
    annotation.text = text
    annotation.activateResponder = self
    annotation.activeAreaResponder = self
    view.addSubview(annotation)
    textAnnotations.append(annotation)
    
    set(selectedTextAnnotation: annotation)
    
    annotation.state = .editing
    
    return annotation
  }
  
  public func textAnnotationCanvasMouseDown(event: NSEvent) {
    let screenPoint = event.locationInWindow
    
    var annotationToActivate: TextAnnotation?
    for annotation in textAnnotations {
      let locationInView = view.convert(screenPoint, to: annotation)
      
      if annotation.frame.contains(locationInView) {
        annotationToActivate = annotation
        break
      }
    }
    
    if annotationToActivate == nil {
      set(selectedTextAnnotation: nil)
      selectedTextAnnotation = addTextAnnotation(text: "", location: screenPoint)
      selectedTextAnnotation?.startEditing()
    }
  }
}

// ActivateResponder
extension TextAnnotationCanvas {
  public func textViewDidActivate(_ activeItem: Any?) {
    guard let anActiveItem = activeItem as? TextContainerView else { return }
    set(selectedTextAnnotation: anActiveItem)
  }
}

// MouseTrackingResponder
extension TextAnnotationCanvas {
  public func areaDidActivated(_ area: TextAnnotationArea) {
    switch area {
    case .resizeLeftArea:   cursorSet.resizeCursor.set()
    case .resizeRightArea:  cursorSet.resizeCursor.set()
    case .scaleArea:        cursorSet.scaleCursor.set()
    case .textArea:         cursorSet.defaultCursor.set()
    }
  }
}

