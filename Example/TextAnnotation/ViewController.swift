//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import TextAnnotation

protocol TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?)
}
class TATextView: NSTextView {
    
    // MARK: - Variables
    
    var activateResponder: TAActivateResponder?
    
    // MARK: - Methods
    // MARK: Private
    
    override internal func mouseDown(with event: NSEvent) {
        guard let responder = activateResponder else { return }
        
        self.isEditable = event.clickCount == 2
        
        responder.textViewDidActivate(nil)
    }
}

class TAContainerView: NSView {
    enum TAContainerViewState {
        case inactive
        case active
        case editing
    }
    var state: TAContainerViewState = .inactive {
        didSet {
            guard state != oldValue else { return }
            
            var isActive: Bool = false
            if state != .inactive {
                isActive = true
            }
            
            if state != .editing {
                textView.isEditable = false
            }
            
            border.isHidden = !isActive
            
            guard textView != nil else { return }
            textView.backgroundColor = isActive ? NSColor.white : NSColor.clear
            textView.textColor = isActive ? NSColor.black : NSColor.gray
        }
    }
    
    // MARK: - Variables
    var activateResponder: TAActivateResponder?
    
//    var isActive: Bool = false {
//        didSet {
//            guard isActive != oldValue else { return }
//
//            if isActive, let responder = activateResponder {
//                responder.textViewDidActivate(self)
//            }
//
////            border.isHidden = !isActive
////
////            guard textView != nil else { return }
////            textView.backgroundColor = isActive ? NSColor.white : NSColor.clear
////            textView.textColor = isActive ? NSColor.black : NSColor.gray
//        }
//    }

    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
        }
    }
    
    // MARK: Private
    
    private var textView: TATextView!
    private var border: CALayer!
    private let kPadding: CGFloat = 3
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let size = frameRect.size

        wantsLayer = true
//        layer?.backgroundColor = NSColor.red.cgColor
        
        textView = TATextView(frame: NSRect(origin: CGPoint(x: kPadding, y: kPadding),
                                                            size: CGSize(width: size.width - 2*kPadding,
                                                                         height: size.height - 2*kPadding)))
        textView.alignment = .center
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.gray
        textView.activateResponder = self
        textView.delegate = self
        
        border = CALayer()
        border.borderColor = NSColor.magenta.cgColor
        border.borderWidth = 1
        border.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        border.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        border.isHidden = true
        self.layer?.addSublayer(border)
        
        addSubview(textView)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    override internal func mouseDown(with event: NSEvent) {
        print("into annotation")
        
        if event.clickCount > 1 {
            state = .editing
        } else {
            state = .active
        }
        
        super.mouseDown(with: event)
    }
    
    // MARK: - Public
}

extension TAContainerView: NSTextViewDelegate /*NSTextDelegate*/ {
        
    func textDidChange(_ notification: Notification) {
        let text = NSString(string: textView.string)
        
        let center = CGPoint(x: NSMidX(frame), y: NSMidY(frame))
        
        var font: NSFont!
        if let theFont = textView.font {
            font = theFont
        } else {
            font = NSFont.systemFont(ofSize: 15)
        }
        var textFrame = text.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: textView.bounds.size.height),
                                          options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                          attributes: [NSAttributedStringKey.font : font])
        
        let width = textFrame.size.width + 2*font.xHeight
        
        textFrame = text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                      options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                      attributes: [NSAttributedStringKey.font : font])
        let height = textFrame.size.height
        
        let labelFrame = CGRect(x: kPadding, y: kPadding, width: width, height: height)

        textFrame = CGRect(x: center.x - width/2.0 - kPadding,
                           y: center.y - height/2.0 - kPadding,
                           width: width + 2*kPadding,
                           height: height + 2*kPadding)
        
        border.frame = CGRect(origin: CGPoint.zero, size: textFrame.size)
        self.frame = textFrame
        textView.frame = labelFrame
    }
}

extension TAContainerView: TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        state = .active
    }
}

class ViewController: NSViewController, TextAnnotationsController {
    
    // MARK: - Variables
    
    var annotations = [TAContainerView]()
    
    // MARK: - Methods
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically creating a text annotation
        let location = CGPoint(x: 100, y: 150)
        
        //    let kPadding: CGFloat = 10
        let size = CGSize(width: 25, height: 25)
        
        let view1 = TAContainerView(frame: NSRect(origin: location, size: size))
        view1.text = "1"
        view1.activateResponder = self
        view.addSubview(view1)
        annotations.append(view1)
        
        let view2 = TAContainerView(frame: NSRect(origin: CGPoint(x: 50, y: 20), size: size))
        view2.text = "2"
        view2.activateResponder = self
        view.addSubview(view2)
        annotations.append(view2)
        
        // Method supplied by TextAnnotationsController protocol implementation
        //    addTextAnnotation(text: "Some text", location: location)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        activateTextView(nil)
    }
  
  override func mouseDown(with event: NSEvent) {
    // TextAnnotationsController needs to handle mouse down events
//    textAnnotationsMouseDown(event: event)
    activateTextView(nil)
    super.mouseDown(with: event)
  }
  
  override func mouseDragged(with event: NSEvent) {
    // TextAnnotationsController needs to handle drag events
    textAnnotationsMouseDragged(event: event)
  }
    
    // MARK: - Private
    
    func activateTextView(_ textView: TAContainerView?) {
        if let aTextView = textView {
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

extension ViewController: TextAnnotationDelegate {
  func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    print(textAnnotation.text)
  }
  
  func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    print(textAnnotation.frame)
  }
}

extension ViewController: TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        guard let anActiveItem = activeItem as? TAContainerView else { return }
        activateTextView(anActiveItem)
    }
}
