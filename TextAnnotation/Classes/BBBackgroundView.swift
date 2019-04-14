//
//  BBBackgroundView.swift
//  TextAnnotation
//
//  Created by Sergey Vinogradov on 12.04.2019.
//

import Cocoa

class BBBackgroundView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let padding = BBConfiguration.frameMargin + BBConfiguration.dotRadius
        let framePath = NSBezierPath(rect: NSRect(x: padding,
                                                  y: padding,
                                                  width: dirtyRect.width - 2 * padding,
                                                  height: dirtyRect.height - 2 * padding))
        
        framePath.lineWidth = BBConfiguration.controlStrokeWidth
        BBPalette.frameStrokeColor.set()
        framePath.stroke()
        framePath.close()
        
        let side = 2*BBConfiguration.dotRadius - BBConfiguration.controlStrokeWidth
        
        // left
        var squareRect = CGRect(x: BBConfiguration.frameMargin,
                                y: (dirtyRect.height - BBConfiguration.dotRadius)/2,
                                width: side,
                                height: side)
        var path = NSBezierPath(ovalIn: squareRect)
        BBPalette.controlFillColor.setFill()
        path.fill()
        
        BBPalette.controlStrokeColor.setFill()
        path.stroke()
        
        // right
        squareRect = CGRect(x: dirtyRect.width - (BBConfiguration.frameMargin + 2*BBConfiguration.dotRadius),
                            y: (dirtyRect.height - BBConfiguration.dotRadius)/2,
                            width: side,
                            height: side)
        path = NSBezierPath(ovalIn: squareRect)
        BBPalette.controlFillColor.setFill()
        path.fill()
        
        BBPalette.controlStrokeColor.setFill()
        path.stroke()
    }
}
