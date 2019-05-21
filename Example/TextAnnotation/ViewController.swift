//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

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
    addTextAnnotation(text: "Some text", location: location)
    
    addTextAnnotation(text: "Another one", location: CGPoint(x: 150, y: 200))
  }
  
  override func mouseDown(with event: NSEvent) {
    let _ = textAnnotationCanvasMouseDown(event: event)
    super.mouseDown(with: event)
  }
}
