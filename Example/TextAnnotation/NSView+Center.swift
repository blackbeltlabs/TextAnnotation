//
//  NSView+Center.swift
//  TextAnnotation_Example
//  based on: https://github.com/hunterbridges/dabes_engine/blob/master/platform/xcode/DaBeSDK/Classes/NSView%2BCenter.m
//
//  Created by Sergey Vinogradov on 24.03.2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Cocoa

extension NSView {
    func setCenter(_ center: CGPoint) {
        frame = CGRect(origin: CGPoint(x: center.x - frame.size.width/2.0, y: center.y - frame.size.height/2.0),
                              size: frame.size)
        //CGRect(origin: CGPoint(x: center.x - NSMidX(bounds), y: center.y - NSMidY(bounds)), size: bounds.size)
    }
    
    func center() -> CGPoint {
        return CGPoint(x: NSMidX(frame), y: NSMidY(frame))
    } 
}
