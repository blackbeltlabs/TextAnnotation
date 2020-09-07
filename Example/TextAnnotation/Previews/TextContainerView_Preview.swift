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
  static var defaultColor: NSColor? = nil
  static var defaultImageName: String = "zapier_screenshot"
  
  static var previews: some View {
    Group {
      TextContainerViewPreview(color: defaultColor)
        .background(Image(defaultImageName))
        .previewLayout(.fixed(width: 300.0, height: 100.0))
      
      
      preview(with: TextAttributes.shadowAttributes(color: .white,
                                                    offsetX: 3.0,
                                                    offsetY: 0.0,
                                                    blur: 3.0))
      
      
      preview(with: TextAttributes.outlineWithShadow(outlineWidth: -2.5,
                                                     outlineColor: .white,
                                                     shadowColor: .white,
                                                     shadowOffsetX: 1.5,
                                                     shadowOffsetY: 1.5,
                                                     shadowBlur: 2.0))
    
      preview(with: TextAttributes.outline(outlineWidth: -5.0,
                                           outlineColor: .white))
      
      preview(with: TextAttributes.outline(outlineWidth: -5.0,
                                           outlineColor: .black))
      
      
      preview(with: TextAttributes.outlineWithShadow(outlineWidth: -2.5,
                                                     outlineColor: .blue,
                                                     shadowColor: .systemBlue,
                                                     shadowOffsetX: 2.5,
                                                     shadowOffsetY: 0.5,
                                                     shadowBlur: 5.0),
              color: .yellow)
    }
  }
  
  static func preview(with attributes: [NSAttributedString.Key: Any]?,
                      color: NSColor? = defaultColor) -> some View {
    
     TextContainerViewPreview(attributes: attributes, color: color)
                   .background(Image(defaultImageName))
                   .previewLayout(.fixed(width: 300.0, height: 100.0))
  }
}
#endif
