//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import TextAnnotation

class ViewController: TextAnnotationsController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically creating a text annotation
        let location = CGPoint(x: 100, y: 150)
        
        // Method supplied by TextAnnotationsController protocol implementation
        addTextAnnotation(text: "Some text", location: location)
    }
}
