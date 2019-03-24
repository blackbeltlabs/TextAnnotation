//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import TextAnnotation

class TATextView: NSTextView {
    
}

class TAContainerView: NSView {
    // MARK: - Variables
    
    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
        }
    }
    
    // MARK: Private
    
    private var textView: TATextView!
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let kPadding: CGFloat = 10
        let size = frameRect.size

        wantsLayer = true
        layer?.backgroundColor = NSColor.red.cgColor
        
        textView = TATextView(frame: NSRect(origin: CGPoint(x: kPadding, y: kPadding),
                                                            size: CGSize(width: size.width - 2*kPadding, height: size.height - 2*kPadding)))
        textView.backgroundColor = NSColor.blue
        textView.textColor = NSColor.white
        
        addSubview(textView)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    override internal func mouseDown(with event: NSEvent) {
        print("into annotation")
        
        activate()
    }
    
    // MARK: - Public
    
    func activate() {
        guard textView != nil else { return }
        textView.window?.makeFirstResponder(textView)
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
        view.addSubview(view1)
        annotations.append(view1)
        
        let view2 = TAContainerView(frame: NSRect(origin: CGPoint(x: 50, y: 20), size: size))
        view2.text = "ann. 2"
        view.addSubview(view2)
        annotations.append(view2)
        
        // Method supplied by TextAnnotationsController protocol implementation
        //    addTextAnnotation(text: "Some text", location: location)
    }
  
  override func mouseDown(with event: NSEvent) {
    // TextAnnotationsController needs to handle mouse down events
//    textAnnotationsMouseDown(event: event)
//    for item in annotations {
//        item.inactivate()
//    }
    view.window?.makeFirstResponder(nil)
  }
  
  override func mouseDragged(with event: NSEvent) {
    // TextAnnotationsController needs to handle drag events
    textAnnotationsMouseDragged(event: event)
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
