import AppKit
import TextAnnotation

// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct TextContainerViewPreview: NSViewRepresentable {
  let attributes: [NSAttributedString.Key: Any]?
  let color: NSColor?
  init(attributes: [NSAttributedString.Key: Any]? = nil,
       color: NSColor? = nil) {
    self.attributes = attributes
    self.color = color
  }
  func makeNSView(context: Context) -> TextContainerView {
    TextContainerView(frame: .zero,
                      text: "Text Annotation",
                      color: color?.textColor ?? .defaultColor(),
                      textAttributes: attributes)
  }

  func updateNSView(_ view: TextContainerView, context: Context) {
  }
}

@available(OSX 10.15.0, *)
struct TextContainerView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        TextContainerViewPreview()
          .background(Color.gray)
          .previewLayout(.fixed(width: 300.0, height: 100.0))
        
        
        preview(with: TextAttributes.shadowAttributes(color: .white,
                                                      offsetX: 3.0,
                                                      offsetY: 0.0,
                                                      blur: 3.0))
        
        preview(with: TextAttributes.outlineWithShadow(shadowProperties: TextShadow(color: .white, offsetX: 1.5, offsetY: 1.5, blur: 2.0),
                                                       
                                                       outlineWidth: -2.5,
                                                       outlineColor: .white))

      }
    }
  
  static func preview(with attributes: [NSAttributedString.Key: Any]?,
                      color: NSColor? = nil) -> some View {
    
     TextContainerViewPreview(attributes: attributes, color: color)
                   .background(Color.gray)
                   .previewLayout(.fixed(width: 300.0, height: 100.0))
  }
}
#endif
