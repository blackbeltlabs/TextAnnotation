//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import TextAnnotation

class ViewController: NSViewController, TextAnnotationsController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Programmatically creating a text annotation
    let location = CGPoint(x: 100, y: 150)
    
    // Method supplied by TextAnnotationsController protocol implementation
    addTextAnnotation(text: "Some text", location: location)
  }
  
  override func mouseDown(with event: NSEvent) {
    // TextAnnotationsController needs to handle mouse down events
    textAnnotationsMouseDown(event: event)
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
