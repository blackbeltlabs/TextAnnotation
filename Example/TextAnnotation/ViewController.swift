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
    let annotation1 = createTextAnnotation(text: "Some text",
                                           location: location,
                                           color: TextColor(red: 0.23, green: 0.83, blue: 0.76, alpha: 1.0))
    annotation1.delegate = self
    annotation1.addTo(canvas: self)
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    let annotation = createTextAnnotation(text: "Another one",
                                          location: CGPoint(x: 150, y: 200),
                                          color: TextColor.defaultColor())
    annotation.delegate = self
    annotation.addTo(canvas: self)
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
  func textAnnotationDidStartEditing(textAnnotation: TextAnnotation) {
    print("did start editing")
  }
  
  func textAnnotationDidEndEditing(textAnnotation: TextAnnotation) {
    print("did end editing")
  }
  
  func textAnnotationDidSelect(textAnnotation: TextAnnotation) {
    print("did select")
  }
  
  func textAnnotationDidDeselect(textAnnotation: TextAnnotation) {
    print("did deselect")
  }
  
  func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    print("did edit: \(textAnnotation.text)")
  }
  
  func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    print("did move")
  }
  
  
}

