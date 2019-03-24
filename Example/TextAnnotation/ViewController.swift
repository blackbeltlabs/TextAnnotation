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
        
        responder.textViewDidActivate(nil)
    }
}

class TAContainerView: NSView {
    
    // MARK: - Variables
//    var activateResponder: TAActivateResponder?
    
    var isActive: Bool = false {
        didSet {
            guard isActive != oldValue else { return }
            
            border.isHidden = !isActive
            
            guard textView != nil, let theWindow = textView.window else { return }
            textView.backgroundColor = isActive ? NSColor.white : NSColor.clear
            textView.textColor = isActive ? NSColor.black : NSColor.gray
            
            // FIXME: implement TAActivateResponder
            if isActive, theWindow.firstResponder != textView {
                theWindow.makeFirstResponder(textView)
            }
        }
    }

    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
        }
    }
    
    // MARK: Private
    
    private var textView: TATextView!
    private var border: CALayer!
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let kPadding: CGFloat = 3
        let size = frameRect.size

        wantsLayer = true
//        layer?.backgroundColor = NSColor.red.cgColor
        
        textView = TATextView(frame: NSRect(origin: CGPoint(x: kPadding, y: kPadding),
                                                            size: CGSize(width: size.width - 2*kPadding, height: size.height - 2*kPadding)))
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.gray
        textView.activateResponder = self
        textView.textStorage?.delegate = self
        
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
        
        isActive = true
    }
    
    // MARK: - Public
    
//    func activate() {
//        guard textView != nil, let theWindow = textView.window else { return }
//        if theWindow.firstResponder != textView {
//            theWindow.makeFirstResponder(textView)
//        }
//
//        border.isHidden = false
//    }
//
//    func inactivate() {
//        border.isHidden = true
//    }
}

extension TAContainerView: NSTextStorageDelegate {
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        
        
    }
}

extension TAContainerView: TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        isActive = true
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
        let size = CGSize(width: 100, height: 100)
        
        let view1 = TAContainerView(frame: NSRect(origin: location, size: size))
        view1.text = "ann. 1"
//        view1.activateResponder = self
        view.addSubview(view1)
        annotations.append(view1)
        
        let view2 = TAContainerView(frame: NSRect(origin: CGPoint(x: 50, y: 20), size: size))
        view2.text = "ann. 2"
//        view2.activateResponder = self
        view.addSubview(view2)
        annotations.append(view2)
        
        // Method supplied by TextAnnotationsController protocol implementation
        //    addTextAnnotation(text: "Some text", location: location)
    }
  
  override func mouseDown(with event: NSEvent) {
    // TextAnnotationsController needs to handle mouse down events
//    textAnnotationsMouseDown(event: event)
    for item in annotations {
        item.isActive = false
    }
    view.window?.makeFirstResponder(nil)
  }
  
  override func mouseDragged(with event: NSEvent) {
    // TextAnnotationsController needs to handle drag events
    textAnnotationsMouseDragged(event: event)
  }
    
    // MARK: - Private
    
    
}

extension ViewController: TextAnnotationDelegate {
  func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    print(textAnnotation.text)
  }
  
  func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    print(textAnnotation.frame)
  }
}

//extension ViewController: TAActivateResponder {
//    func textViewDidActivate() {
//        
//    }
//}
