import AppKit
import TextAnnotation

// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct TextContainerViewPreview: NSViewRepresentable {
  func makeNSView(context: Context) -> TextContainerView {
    TextContainerView(frame: .zero,
                      text: "Text Annotation",
                      color: .defaultColor())
  }

  func updateNSView(_ view: TextContainerView, context: Context) {
  }
}

@available(OSX 10.15.0, *)
struct TextContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TextContainerViewPreview()
          .background(Color.gray)
          .previewLayout(.fixed(width: 300.0, height: 300.0))
    }
}
#endif
