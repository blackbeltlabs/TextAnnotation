import Cocoa
import TextAnnotation

class ViewController: NSViewController, TextAnnotationCanvas {
  var textAnnotations: [TextAnnotation] = []
  var selectedTextAnnotation: TextAnnotation?
  var lastMouseLocation: NSPoint?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Programmatically creating a text annotation
    let location = CGPoint(x: 100, y: 150)
    
    // Method supplied by TextAnnotationsController protocol implementation
    let annotation1 = createTextAnnotation(text: "Some text", location: location)
    annotation1.addTo(canvas: self)
    annotation1.delegate = self
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    let annotation = createTextAnnotation(text: "Another one", location: CGPoint(x: 150, y: 200))
    annotation.addTo(canvas: self)
    annotation.delegate = self
    annotation.startEditing()
  }
  
  override func mouseDown(with event: NSEvent) {
    let _ = textAnnotationCanvasMouseDown(event: event)
    super.mouseDown(with: event)
  }
  
  @IBAction func didSelectDelete(_ sender: AnyObject) {
    selectedTextAnnotation?.delete()
    print("delete")
  }
}

extension ViewController: TextAnnotationDelegate {
  func textAnnotationDidSelect(textAnnotation: TextAnnotation) {
    print("did select")
  }
  
  func textAnnotationDidDeselect(textAnnotation: TextAnnotation) {
    print("did deselect")
  }
  
  func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    print("did edit")
  }
  
  func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    print("did move")
  }
}

