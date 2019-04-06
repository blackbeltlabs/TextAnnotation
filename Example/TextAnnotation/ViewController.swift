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
                                                  width: dirtyRect.width - 2 * (TAView.kPadding + TAView.kRadius),
                                                  height: dirtyRect.height - 2 * TAView.kPadding))
        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setFill()
        framePath.fill()
        
        framePath.lineWidth = 1
        color.set()
        framePath.stroke()
        framePath.close()
        
        let left = NSBezierPath()
        left.appendArc(withCenter: NSPoint(x: TAView.kPadding + TAView.kRadius, y: dirtyRect.height/2),
                            radius: TAView.kRadius,
                            startAngle:  270,
                            endAngle: 90,
                            clockwise: true)
        left.lineWidth = 1
        color.set()
        left.stroke()
        left.close()
        
        let right = NSBezierPath()
        right.appendArc(withCenter: NSPoint(x: dirtyRect.width - (TAView.kPadding + TAView.kRadius), y: dirtyRect.height/2),
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
    lazy var twoSymbolsWidth = 2 * (font ?? NSFont.systemFont(ofSize: 15)).xHeight
    func frameForWidth(_ width: CGFloat, height: CGFloat) -> CGRect {
        let theFont = font ?? NSFont.systemFont(ofSize: 15)
        return string.boundingRect(with: CGSize(width: width, height: height),
                                 options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                 attributes: [NSAttributedStringKey.font : theFont])
    }
}

// MARK: -
// MARK: -
// MARK: -

class TAContainerView: NSView {
    
    // MARK: - Variables
    
    enum TAContainerViewState {
        case inactive
        case active
        case editing
        case resizeRight
        case resizeLeft
        case dragging
        case scaling
    }
    var state: TAContainerViewState = .inactive {
        didSet {
            guard state != oldValue else { return }
            if oldValue == .resizeLeft || oldValue == .resizeRight {
                updateSubviewsFrames()
            }
            
            var isActive: Bool = false
            if state == .inactive {
                textView.isEditable = false
                textView.isSelectable = false
                doubleClickGestureRecognizer.isEnabled = !textView.isEditable
                updateSubviewsFrames()
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
    var scaleTally: NSView!
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
        
        initialTouchPoint = CGPoint(x: frameRect.origin.x + frameRect.width/2,
                                    y: frameRect.origin.y + frameRect.height/2)
        let size = frameRect.size
        
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
        textView.isRichText = false
        textView.usesRuler = false
        textView.usesFontPanel = false
        textView.isEditable = false
        textView.isVerticallyResizable = false
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
        addSubview(leftTally)
        
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
        tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - tallyFrame.width)
        rightTally = NSView(frame: tallyFrame)
        addSubview(rightTally)
        
        tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.width)
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: 0)
        scaleTally = NSView(frame: tallyFrame)
        scaleTally.wantsLayer = true
        scaleTally.layer?.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        addSubview(scaleTally)
        
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
        let center = CGPoint(x: NSMidX(frame), y: NSMidY(frame))
        
        var textFrame = textView.frameForWidth(CGFloat.greatestFiniteMagnitude, height: textView.bounds.height)
        let width = max(textFrame.width + textView.twoSymbolsWidth, textView.bounds.width)
        // FIXME: Re-design whole algorythm to will be number of lines sensetive
        textFrame = textView.frameForWidth(width, height: CGFloat.greatestFiniteMagnitude)
        let height = textFrame.height
        
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
        
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
        tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - tallyFrame.width)
        rightTally.frame = tallyFrame
        
        tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: 0)
        tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.width)
        scaleTally.frame = tallyFrame
        
        CATransaction.commit()
    }
    
    // MARK: - Public
    
    func resizeWithDistance(_ distance: CGFloat) {
        guard state == .resizeRight || state == .resizeLeft else { return }
        
        var theFrame = frame
        let delta = (state == .resizeRight ? 1 : -1) * distance
        theFrame.size = CGSize(width: theFrame.width + delta, height: theFrame.height)
        
        // FIXME: better to calculate it like 2 * (kPadding + kCircleRadius) + textView.twoSymbolsWidth)
        guard theFrame.width > 25 else {
            state = .active
            return
        }
        
        if state == .resizeLeft {
            // should move origin as well
            theFrame.origin = CGPoint(x: theFrame.origin.x + distance, y: theFrame.origin.y)
        }
        
        // Here we have to check if text view frame has good size for such container size
        let textFrame = textView.frameForWidth(theFrame.width - 2 * (kPadding + kCircleRadius),
                                               height: CGFloat.greatestFiniteMagnitude)
        let diff_width = theFrame.width - (textFrame.width + 2 * (kPadding + kCircleRadius) + textView.twoSymbolsWidth)
        if diff_width < 0 {
            // let diff_height = theFrame.height - (textFrame.height + 2 * kPadding)
            let height = textFrame.height + 2 * kPadding
            let centerY = theFrame.origin.y + theFrame.height/2
            
            theFrame.size = CGSize(width: theFrame.width, height: height)
            theFrame.origin = CGPoint(x: theFrame.origin.x, y: centerY - height/2)
            // FIXME: here we should add some (prevention dissapearing symbols) height adding, depending on diff width amount. One symbol is about 9.0 of the difference
        }
        
        frame = theFrame
        updateSubviewsFrames()
    }
    
    func scaleWithDistance(_ difference: CGSize) {
        guard state == .scaling else { return }
        
        var theFrame = frame
        theFrame.size = CGSize(width: theFrame.width + difference.width, height: theFrame.height - difference.height)
        theFrame.origin = CGPoint(x: theFrame.origin.x, y: theFrame.origin.y + difference.height)
        
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
        let size = CGSize.zero
        
        let view1 = TAContainerView(frame: NSRect(origin: CGPoint(x: 100, y: 150), size: size))
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
        
        // are we should continue resize or scale
        if activeAnnotation != nil {
            let initialDragPoint = activeAnnotation.initialTouchPoint
            activeAnnotation.initialTouchPoint = screenPoint
            let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                    height: screenPoint.y - initialDragPoint.y)
            
            if activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight {
                activeAnnotation.resizeWithDistance(difference.width)
            } else {
                activeAnnotation.scaleWithDistance(difference)
            }
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
            } else if annotationToActivate.scaleTally.frame.contains(locationInAnnotation) {
                state = .scaling
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
