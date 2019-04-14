//
//  BBDotView.swift
//  TextAnnotation
//
//  Created by Sergey Vinogradov on 12.04.2019.
//

import Cocoa

class BBDotView: BBActiveView {
    
    // MARK: - Variables
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let side = min(dirtyRect.width, dirtyRect.height) - BBConfiguration.controlStrokeWidth
        let squareRect = CGRect(x: dirtyRect.origin.x + (dirtyRect.width - side)/2,
                                y: dirtyRect.origin.y + (dirtyRect.height - side)/2,
                                width: side,
                                height: side)
        
        let path = NSBezierPath(ovalIn: squareRect)
        BBPalette.controlFillColor.setFill()
        path.fill()
        
        path.lineWidth = BBConfiguration.controlStrokeWidth
        BBPalette.controlStrokeColor.setStroke()
        path.stroke()
    }
}
