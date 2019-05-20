import Cocoa

public protocol HasNib: class {
  var contentView: NSView! { get }
  static var nib: NSNib { get }
}

public extension HasNib where Self: NSView {
  
  static var nib: NSNib {
    return NSNib(nibNamed: String(describing: self), bundle: Bundle(for: self))!
  }
  
  func loadNibContent() {
    let layoutAttributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
    Self.nib.instantiate(withOwner: self, topLevelObjects: nil)
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(contentView)
    
    layoutAttributes.forEach { attribute in
      self.addConstraint(
        NSLayoutConstraint(
          item: contentView,
          attribute: attribute,
          relatedBy: .equal,
          toItem: self,
          attribute: attribute,
          multiplier: 1,
          constant: 0.0))
    }
  }
}
