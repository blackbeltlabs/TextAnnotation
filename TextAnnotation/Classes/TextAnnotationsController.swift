import Foundation

public protocol TextAnnotationsController {

}

extension TextAnnotationsController {
  public func addTextAnnotation(text: String, location: CGPoint) {

  }

  public func textAnnotationsMouseDown(event: NSEvent) {
    
  }
  
  public func textAnnotationsMouseDragged(event: NSEvent) {
    
  }
}
/*
open class TextAnnotationsController: NSViewController {
}

 // MARK: - Variables
 
 var annotations = [BBContainerView]()
 var activeAnnotation: BBContainerView! {
 didSet {
 if let aTextView = activeAnnotation {
 for item in annotations {
 guard item != aTextView else { continue }
 item.state = .inactive
 }
 } else {
 for item in annotations {
 item.state = .inactive
 }
 view.window?.makeFirstResponder(nil)
 }
 }
 }
 
 private lazy var currentCursor: NSCursor = NSCursor.current
 private let resizeCursor = NSCursor(image: #imageLiteral(resourceName: "East-West"), hotSpot: NSPoint(x: 9, y: 9))
 private let scaleCursor = NSCursor(image: #imageLiteral(resourceName: "North-West-South-East"), hotSpot: NSPoint(x: 9, y: 9))
 
 // MARK: - Lifecycle
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 // Programmatically creating a text annotation
 let size = CGSize.zero
 
 let view1 = BBContainerView(frame: NSRect(origin: CGPoint(x: 100, y: 150), size: size))
 view1.text = "S"
 view1.activateResponder = self
 view1.activeAreaResponder = self
 view.addSubview(view1)
 annotations.append(view1)
 
 let view2 = BBContainerView(frame: NSRect(origin: CGPoint(x: 50, y: 20), size: size))
 view2.text = "2"
 view2.activateResponder = self
 view2.activeAreaResponder = self
 view.addSubview(view2)
 annotations.append(view2)
 }
 
 override func viewDidAppear() {
 super.viewDidAppear()
 
 activeAnnotation = nil
 }
 
 // MARK: NSResponder
 
 override func mouseUp(with event: NSEvent) {
 currentCursor.set()
 
 if activeAnnotation != nil {
 activeAnnotation.state = .active
 }
 }
 
 override func mouseDown(with event: NSEvent) {
 let screenPoint = event.locationInWindow
 
 // check annotation to activate or break resize
 let locationInView = view.convert(screenPoint, to: nil)
 var annotationToActivate: BBContainerView!
 
 for annotation in annotations {
 if annotation.frame.contains(locationInView) {
 annotationToActivate = annotation
 break
 }
 }
 
 if annotationToActivate == nil {
 activeAnnotation = nil
 } else {
 activeAnnotation?.initialTouchPoint = screenPoint
 activeAnnotation?.state = .active
 }
 
 super.mouseDown(with: event)
 }
 
 override func mouseDragged(with event: NSEvent) {
 textAnnotationsMouseDragged(event: event)
 
 super.mouseDragged(with: event)
 }
 
 // MARK: - Private
 
 private func textAnnotationsMouseDragged(event: NSEvent) {
 let screenPoint = event.locationInWindow
 
 // are we should continue resize or scale
 if activeAnnotation != nil, activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight || activeAnnotation.state == .scaling {
 
 let initialDragPoint = activeAnnotation.initialTouchPoint
 activeAnnotation.initialTouchPoint = screenPoint
 let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
 height: screenPoint.y - initialDragPoint.y)
 
 if activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight {
 activeAnnotation.resizeWithDistance(difference.width)
 
 resizeCursor.set()
 } else if activeAnnotation.state == .scaling {
 activeAnnotation.scaleWithDistance(difference)
 
 scaleCursor.set()
 }
 
 return
 }
 
 // check annotation to activate or break resize
 let locationInView = view.convert(screenPoint, to: nil)
 var annotationToActivate: BBContainerView!
 
 for annotation in annotations {
 if annotation.frame.contains(locationInView) {
 annotationToActivate = annotation
 break
 }
 }
 
 // start dragging or resize
 if let annotation = annotationToActivate, annotation.state == .active {
 let locationInAnnotation = view.convert(screenPoint, to: annotation)
 
 var state: BBContainerView.ContainerViewState = .active // default state
 if let tally = annotation.leftTally, tally.frame.contains(locationInAnnotation) {
 state = .resizeLeft
 } else if let tally = annotation.rightTally, tally.frame.contains(locationInAnnotation) {
 state = .resizeRight
 } else if let tally = annotation.scaleTally, tally.frame.contains(locationInAnnotation) {
 state = .scaling
 }
 
 if state != .active && annotation.state != .dragging {
 annotation.state = state
 activeAnnotation = annotation
 return
 }
 }
 
 if activeAnnotation == nil ||
 (annotationToActivate != nil && activeAnnotation != annotationToActivate) {
 if activeAnnotation != nil {
 activeAnnotation.state = .inactive
 }
 
 activeAnnotation = annotationToActivate
 }
 guard activeAnnotation != nil else {
 currentCursor.set()
 
 return
 }
 
 // here we can only drag
 if activeAnnotation.state != .dragging {
 activeAnnotation.initialTouchPoint = screenPoint
 }
 activeAnnotation.state = .dragging
 
 let initialDragPoint = activeAnnotation.initialTouchPoint
 activeAnnotation.initialTouchPoint = screenPoint
 let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
 height: screenPoint.y - initialDragPoint.y)
 
 activeAnnotation.origin = CGPoint(x: activeAnnotation.frame.origin.x + difference.width,
 y: activeAnnotation.frame.origin.y + difference.height)
 }
 }
 
 //extension ViewController: TextAnnotationDelegate {
 //    func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
 //        print(textAnnotation.text)
 //    }
 //
 //    func textAnnotationDidMove(textAnnotation: TextAnnotation) {
 //        print(textAnnotation.frame)
 //    }
 //}
 
 extension TextAnnotationsController: BBActivateResponder {
 func textViewDidActivate(_ activeItem: Any?) {
 guard let anActiveItem = activeItem as? BBContainerView else { return }
 activeAnnotation = anActiveItem
 }
 }
 
 extension TextAnnotationsController: BBActiveAreaResponder {
 func areaDidActivated(_ area: BBArea) {
 switch area {
 case .resizeLeftArea:   resizeCursor.set()
 case .resizeRightArea:  resizeCursor.set()
 case .scaleArea:        scaleCursor.set()
 case .textArea:         currentCursor.set()
 }
 }
 }
 */
