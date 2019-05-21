import Cocoa

public protocol TextAnnotation where Self: NSView {
  var text: String { get set }
  var frame: CGRect { get set }
  var state: TextAnnotationState { get set }
}

extension TextContainerView: TextAnnotation {
  
}

@IBDesignable
public class TextAnnotationView: NSView, TextAnnotation, HasNib {
  @IBInspectable public var text: String = "" {
    didSet {
      textView.string = text
    }
  }
  
  public var state: TextAnnotationState = .active
  
  @IBOutlet public var contentView: NSView!
  
  @IBOutlet var textView: TextView!
  @IBOutlet var leftResizeHandle: NSView!
  @IBOutlet var rightResizeHandle: NSView!
  @IBOutlet var scaleHandle: NSView!
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setup()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    setup()
  }
  
  func setup() {
    loadNibContent()
    
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.textColor = Palette.controlFillColor
    textView.font = NSFont(name: "HelveticaNeue-Bold", size: 30)
    textView.isSelectable = false
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.isEditable = false
    textView.isVerticallyResizable = false
    textView.delegate = self
    textView.string = "some text"
  }
  
  @IBAction func didClick(recognizer: NSClickGestureRecognizer) {
    print("click")
  }
  
  @IBAction func didDoubleClick(recognizer: NSClickGestureRecognizer) {
    print("double click")
  }
  
  @IBAction func leftResizeDidDrag(recognizer: NSPanGestureRecognizer) {
    print("left drag")
  }
  
  @IBAction func rightResizeDidDrag(recognizer: NSPanGestureRecognizer) {
    print("right drag")
  }
  
  @IBAction func scaleDidDrag(recognizer: NSPanGestureRecognizer) {
    print("scale drag")
  }
  
  @IBAction func didDrag(recognizer: NSPanGestureRecognizer) {
    print("drag")
  }
}

extension TextAnnotationView {
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    textView.string = "Some example of text."
  }
}

extension TextAnnotationView: NSTextViewDelegate {
  
  // MARK: - NSTextDelegate
  
  open func textDidChange(_ notification: Notification) {
//    updateFrameWithText(textView.string)
  }
}
