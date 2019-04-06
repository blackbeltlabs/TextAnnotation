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
class TAView: NSView {
    static let kPadding: CGFloat = 3
    static let kRadius: CGFloat = 5
    
    override func draw(_ dirtyRect: NSRect) {
        let color = #colorLiteral(red: 0.3215686275, green: 0.7137254902, blue: 0.8823529412, alpha: 1)
        let framePath = NSBezierPath(rect: NSRect(x: TAView.kPadding + TAView.kRadius,
                                                  y: TAView.kPadding,
                                                  width: dirtyRect.size.width - 2 * (TAView.kPadding + TAView.kRadius),
                                                  height: dirtyRect.size.height - 2 * TAView.kPadding))
//        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
//        framePath.fill()
        
        framePath.lineWidth = 1
        color.set()
        framePath.stroke()
        framePath.close()
        
        let left = NSBezierPath()
        left.appendArc(withCenter: NSPoint(x: TAView.kPadding + TAView.kRadius, y: dirtyRect.size.height/2),
                            radius: TAView.kRadius,
                            startAngle:  270,
                            endAngle: 90,
                            clockwise: true)
        left.lineWidth = 1
        color.set()
        left.stroke()
        left.close()
        
        let right = NSBezierPath()
        right.appendArc(withCenter: NSPoint(x: dirtyRect.size.width - (TAView.kPadding + TAView.kRadius), y: dirtyRect.size.height/2),
                       radius: TAView.kRadius,
                       startAngle:  270,
                       endAngle: 90,
                       clockwise: false)
        right.lineWidth = 1
        color.set()
        right.stroke()
        right.close()
    }
}
class TATextView: NSTextView {
    
    // MARK: - Variables
}

// MARK: -
// MARK: -
// MARK: -

class TAContainerView: NSView {
    enum TAContainerViewState {
        case inactive
        case active
        case editing
        case resizeRight
        case resizeLeft
        case dragging
    }
    var state: TAContainerViewState = .inactive {
        didSet {
            guard state != oldValue else { return }
            
            var isActive: Bool = false
            if state == .inactive {
                textView.isEditable = false
                textView.isSelectable = false
                doubleClickGestureRecognizer.isEnabled = !textView.isEditable
            } else {
                isActive = true
                
                if let responder = activateResponder {
                    responder.textViewDidActivate(self)
                }
            }
            
            singleClickGestureRecognizer.isEnabled = state == .inactive
            backgroundView.isHidden = !isActive
            backgroundView.display()
            
            guard textView != nil else { return }
            textView.textColor = isActive ? NSColor.black : NSColor.gray
        }
    }
    
    // MARK: - Variables
    
    var activateResponder: TAActivateResponder?
    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
        }
    }
    var initialTouchPoint = CGPoint.zero
    var leftTally: NSView!
    var rightTally: NSView!
    var origin: CGPoint = CGPoint.zero {
        didSet {
            frame.origin = origin
            updateSubviewsFrames()
        }
    }
    
    // MARK: Private
    
    private var backgroundView: TAView!
    private var textView: TATextView!

    private let kPadding: CGFloat = TAView.kPadding
    private let kCircleRadius: CGFloat = TAView.kRadius
    
    private var singleClickGestureRecognizer: NSClickGestureRecognizer!
    private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
    
    override internal var frame: NSRect {
        didSet {
            updateSubviewsFrames()
        }
    }
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        initialTouchPoint = CGPoint(x: frameRect.origin.x + frameRect.size.width/2,
                                    y: frameRect.origin.y + frameRect.size.height/2)
        let size = frameRect.size
        
        wantsLayer = true
        layer?.backgroundColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 0.1695205479)
        
        backgroundView = TAView(frame: NSRect(origin: CGPoint.zero, size: size))
        backgroundView.isHidden = true
        self.addSubview(backgroundView)
        
        textView = TATextView(frame: NSRect(origin: CGPoint(x: kPadding, y: kPadding),
                                            size: CGSize(width: size.width - 2*kPadding,
                                                         height: size.height - 2*kPadding)))
        textView.alignment = .natural
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.gray
        textView.isSelectable = false
        
        textView.isEditable = false
        textView.delegate = self
        
        singleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.singleClickGestureHandle(_:)))
        self.addGestureRecognizer(singleClickGestureRecognizer)
        
        doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.doubleClickGestureHandle(_:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        doubleClickGestureRecognizer.numberOfTouchesRequired = 2
        self.addGestureRecognizer(doubleClickGestureRecognizer)
        
        addSubview(textView)
        
        var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: kPadding + kCircleRadius, height: size.height))
        leftTally = NSView(frame: tallyFrame)
        leftTally.wantsLayer = true
        leftTally.layer?.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.5062607021)
        addSubview(leftTally)
        
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: 0)
        rightTally = NSView(frame: tallyFrame)
        rightTally.wantsLayer = true
        rightTally.layer?.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 0.5062607021)
        addSubview(rightTally)
        
        updateFrameWithText(textView.string)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    @objc private func singleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        // FIXME: Here we fails with location of the point. ONLY in more than one row case
        initialTouchPoint = gesture.location(in: self.superview)
        state = .active
    }
    
    @objc private func doubleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        
        state = .editing
        textView.isSelectable = true
        theTextView.isEditable = true
        doubleClickGestureRecognizer.isEnabled = !theTextView.isEditable
        
        guard let responder = activateResponder else { return }
        responder.textViewDidActivate(self)
    }
    
    private func updateFrameWithText(_ string: String) {
        let text = NSString(string: string)
        
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
        
        // Now we knot text label frame. We should calculate new self.frame and redraw all the subviews
        
        textFrame = CGRect(x: center.x - width/2.0 - (kPadding + kCircleRadius),
                           y: center.y - height/2.0 - kPadding,
                           width: width + 2*(kPadding + kCircleRadius),
                           height: height + 2*kPadding)
        
        frame = textFrame
    }
    
    private func updateSubviewsFrames() {
        let size = frame.size
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
        textView.frame = CGRect(x: kPadding + kCircleRadius, y: kPadding, width: size.width - 2*(kPadding + kCircleRadius), height: size.height - 2*kPadding)
        
        var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: kPadding + kCircleRadius, height: size.height))
        leftTally.frame = tallyFrame
        
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: 0)
        rightTally.frame = tallyFrame
        CATransaction.commit()
    }
    
    // MARK: - Public
    
    func resizeWithDistance(_ distance: CGFloat) {
        guard state == .resizeRight || state == .resizeLeft else { return }
        
        var theFrame = frame
        let delta = (state == .resizeRight ? 1 : -1) * distance
        theFrame.size = CGSize(width: theFrame.size.width + delta, height: theFrame.size.height)
        
        guard theFrame.size.width > 25 else {
            state = .active
            return
        }
        
        if state == .resizeLeft {
            // should move origin as well
            theFrame.origin = CGPoint(x: theFrame.origin.x + distance, y: theFrame.origin.y)
        }
        
        frame = theFrame
        updateSubviewsFrames()
    }
}

extension TAContainerView: NSTextViewDelegate {
    
    // MARK: - NSTextDelegate
    
    func textDidChange(_ notification: Notification) {
        updateFrameWithText(textView.string)
    }
}

extension TAContainerView: TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        // After we reach the .editing state - we should not switch it back to .active, only on .inactive on complete edit
        state = textView.isEditable ? .editing : .active
    }
}

// MARK: -
// MARK: -
// MARK: -

class ViewController: NSViewController, TextAnnotationsController {
    
    // MARK: - Variables
    
    var annotations = [TAContainerView]()
    var activeAnnotation: TAContainerView! {
        didSet {
            if let aTextView = activeAnnotation {
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
    
    // MARK: - Methods
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically creating a text annotation
        let location = CGPoint(x: 100, y: 150)
        
        let size = CGSize(width: 40, height: 40)
        
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
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        activeAnnotation = nil
    }
    
    override func mouseUp(with event: NSEvent) {
        if activeAnnotation != nil {
            activeAnnotation.state = .active
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let screenPoint = event.locationInWindow
        
        // check annotation to activate or break resize
        let locationInView = view.convert(screenPoint, to: nil)
        var annotationToActivate: TAContainerView!
        
        for annotation in annotations {
            if annotation.frame.contains(locationInView) {
                annotationToActivate = annotation
                break
            }
        }
        
        if annotationToActivate == nil {
            activeAnnotation = nil
        } else {
            activeAnnotation?.initialTouchPoint = screenPoint
            activeAnnotation?.state = .active
        }
        
        super.mouseDown(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {

        textAnnotationsMouseDragged(event: event)
        super.mouseDragged(with: event)
    }
    
    // MARK: - Private
    
    private func textAnnotationsMouseDragged(event: NSEvent) {
        let screenPoint = event.locationInWindow
        
        // check annotation to activate or break resize
        let locationInView = view.convert(screenPoint, to: nil)
        var annotationToActivate: TAContainerView!
        
        for annotation in annotations {
            if annotation.frame.contains(locationInView) {
                annotationToActivate = annotation
                break
            }
        }
        
        // are we should continue resize
        if activeAnnotation != nil && (activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight) {
            let initialDragPoint = activeAnnotation.initialTouchPoint
            activeAnnotation.initialTouchPoint = screenPoint
            let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                    height: screenPoint.y - initialDragPoint.y)
            
            activeAnnotation.resizeWithDistance(difference.width)
            return
        }
        
        // start dragging or resize
        if annotationToActivate != nil {
            let locationInAnnotation = view.convert(screenPoint, to: annotationToActivate)
            
            var state: TAContainerView.TAContainerViewState = .active // default state
            if annotationToActivate.leftTally.frame.contains(locationInAnnotation) {
                state = .resizeLeft
            } else if annotationToActivate.rightTally.frame.contains(locationInAnnotation) {
                state = .resizeRight
            }
            
            if state != .active && annotationToActivate.state != .dragging {
                annotationToActivate.state = state
                return
            }
        }

        if activeAnnotation == nil ||
            (annotationToActivate != nil && activeAnnotation != annotationToActivate) {
            if activeAnnotation != nil {
                activeAnnotation.state = .inactive
            }
            
            activeAnnotation = annotationToActivate
        }
        guard activeAnnotation != nil else { return }
        
        // here we can only drag
        if activeAnnotation.state != .dragging {
            activeAnnotation.initialTouchPoint = screenPoint
        }
        activeAnnotation.state = .dragging
        
        let initialDragPoint = activeAnnotation.initialTouchPoint
        activeAnnotation.initialTouchPoint = screenPoint
        let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                height: screenPoint.y - initialDragPoint.y)
        
        activeAnnotation.origin = CGPoint(x: activeAnnotation.frame.origin.x + difference.width,
                                          y: activeAnnotation.frame.origin.y + difference.height)
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
        activeAnnotation = anActiveItem
    }
}
