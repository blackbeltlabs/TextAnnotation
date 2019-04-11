//
//  ViewController.swift
//  TextAnnotation
//
//  Created by Mirko Kiefer on 03/19/2019.
//  Copyright (c) 2019 Mirko Kiefer. All rights reserved.
//

import Cocoa
import TextAnnotation

protocol TAActivateResponder: class {
    func textViewDidActivate(_ activeItem: Any?)
}

enum TAActiveArea {
    case resizeRightArea
    case resizeLeftArea
    case scaleArea
    case textArea
}
protocol TAActiveAreaResponder: class {
    func areaDidActivated(_ area: TAActiveArea)
}
class TAActivateView: NSView {
    
    // MARK: - Variables
    
    weak private var activeAreaResponder: TAActiveAreaResponder?
    private var areaType: TAActiveArea?
    
    // MARK: - Lifecycle
    
    convenience init(type: TAActiveArea, responder: TAActiveAreaResponder, frameRect: NSRect) {
        self.init(frame: frameRect)
        
        areaType = type
        activeAreaResponder = responder
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue | NSTrackingArea.Options.inVisibleRect.rawValue
        let trackingArea = NSTrackingArea(rect: bounds, options: NSTrackingArea.Options(rawValue: options), owner: self, userInfo: nil)
        
        addTrackingArea(trackingArea)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: NSResponder
    
    override func mouseEntered(with event: NSEvent) {
        // we can not implement it on this level, because on the dragging we directly receive mouseExited(with theEvent:) here
        if let responder = activeAreaResponder, let type = areaType {
            responder.areaDidActivated(type)
        }
    }
}

class TADotView: TAActivateView {
    
    // MARK: - Variables

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let strokeWidth: CGFloat = 1
        
        let side = min(dirtyRect.width, dirtyRect.height) - strokeWidth
        let squareRect = CGRect(x: dirtyRect.origin.x + (dirtyRect.width - side)/2,
                                y: dirtyRect.origin.y + (dirtyRect.height - side)/2,
                                width: side,
                                height: side)
        
        let path = NSBezierPath(ovalIn: squareRect)
        TAFrameView.kColorControlFill.setFill()
        path.fill()
        
        path.lineWidth = strokeWidth
        TAFrameView.kColorControlStroke.setStroke()
        path.stroke()
    }
}

class TAFrameView: NSView {
    static let kPadding: CGFloat = 2
    static let kRadius: CGFloat = 5
    static let kColorControlFill = #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1)
    static let kColorControlStroke = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let padding = TAFrameView.kPadding + TAFrameView.kRadius
        let framePath = NSBezierPath(rect: NSRect(x: padding,
                                                  y: padding,
                                                  width: dirtyRect.width - 2 * padding,
                                                  height: dirtyRect.height - 2 * padding))
        
        framePath.lineWidth = 1
        #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.7960784314, alpha: 1).set()
        framePath.stroke()
        framePath.close()
        
        let strokeWidth: CGFloat = 1
        let side = 2*TAFrameView.kRadius - strokeWidth
        
        // left
        var squareRect = CGRect(x: TAFrameView.kPadding,
                                y: (dirtyRect.height - TAFrameView.kRadius)/2,
                                width: side,
                                height: side)
        var path = NSBezierPath(ovalIn: squareRect)
        TAFrameView.kColorControlFill.setFill()
        path.fill()
        
        TAFrameView.kColorControlStroke.set()
        path.stroke()
        
        // right
        squareRect = CGRect(x: dirtyRect.width - (TAFrameView.kPadding + 2*TAFrameView.kRadius),
                            y: (dirtyRect.height - TAFrameView.kRadius)/2,
                            width: side,
                            height: side)
        path = NSBezierPath(ovalIn: squareRect)
        TAFrameView.kColorControlFill.setFill()
        path.fill()
        
        TAFrameView.kColorControlStroke.set()
        path.stroke()
    }
}

class TATextView: NSTextView {
    
    // MARK: - Variables
    
    lazy var twoSymbolsWidth: CGFloat = 2 * getFont().xHeight
    private weak var activeAreaResponder: TAActiveAreaResponder?
    
    // MARK: Private
    
    private var fontSizeToSizeRatio: CGFloat!
    
    // MARK: - Lifecycle
    
    convenience init(frame frameRect: NSRect, responder: TAActiveAreaResponder ) {
        self.init(frame: frameRect)
        
        activeAreaResponder = responder
        
        let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue
        let trackingArea = NSTrackingArea(rect: bounds, options: NSTrackingArea.Options(rawValue: options), owner: self, userInfo: nil)
        
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        // we can not implement it on this level, because on the dragging we directly receive mouseExited(with theEvent:) here
        if let responder = activeAreaResponder {
            responder.areaDidActivated(.textArea)
        }
        
        super.mouseEntered(with: event)
    }
    
    // MARK: - Public
    
    func frameForWidth(_ width: CGFloat, height: CGFloat) -> CGRect {
        return string.boundingRect(with: CGSize(width: width, height: height),
                                 options: NSString.DrawingOptions.usesLineFragmentOrigin,
                                 attributes: [NSAttributedStringKey.font : getFont()])
    }
    
    func calculateScaleRatio() {
        let fontSize = getFont().pointSize
        let temp = frame.height/CGFloat(numberOfLines())
        fontSizeToSizeRatio = fontSize / temp
    }
    
    func resetFontSize() {
        if fontSizeToSizeRatio == nil {
            calculateScaleRatio()
        }
        
        let temp = frame.height/CGFloat(numberOfLines())
        let size = fontSizeToSizeRatio * temp
        
        let ratio = size/getFont().pointSize
        if !(1.0...1.1 ~= ratio) {
            font = NSFont(name: getFont().fontName, size: size)
        }
    }
    
    // MARK: - Private
    
    private func getFont() -> NSFont {
        return font ?? NSFont.systemFont(ofSize: 15)
    }
    
    private func numberOfLines() -> Int {
        var numberOfLines = 1
        if let lManager = layoutManager {
            let numberOfGlyphs = lManager.numberOfGlyphs
            var index = 0
            var lineRange = NSRange(location: NSNotFound, length: 0)
            numberOfLines = 0
            
            while index < numberOfGlyphs {
                lManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
                index = NSMaxRange(lineRange)
                numberOfLines += 1
            }
        }
        
        return numberOfLines
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
                if state == .scaling {
                    textView.calculateScaleRatio()
                }
                
                isActive = true
                
                if let responder = activateResponder {
                    responder.textViewDidActivate(self)
                }
            }
            
            singleClickGestureRecognizer.isEnabled = state == .inactive
            
            backgroundView.isHidden = !isActive
            backgroundView.display()
            
            if let tally = leftTally {
                tally.isHidden = !isActive
            }
            
            if let tally = rightTally {
                tally.isHidden = !isActive
            }
            
            if let tally = scaleTally {
                tally.isHidden = !isActive
                tally.display()
            }
        }
    }
    
    weak var activateResponder: TAActivateResponder?
    weak var activeAreaResponder: TAActiveAreaResponder?
    
    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
            updateFrameWithText(textView.string)
        }
    }
    var initialTouchPoint = CGPoint.zero
    var leftTally: TAActivateView?
    var rightTally: NSView!
    var scaleTally: TADotView?
    
    var origin: CGPoint = CGPoint.zero {
        didSet {
            frame.origin = origin
            updateSubviewsFrames()
        }
    }
    
    // MARK: Private
    
    private var backgroundView: TAFrameView!
    private var textView: TATextView!

    private let kTextPadding: CGFloat = 2
    private let kPadding: CGFloat = TAFrameView.kPadding
    private let kCircleRadius: CGFloat = TAFrameView.kRadius
    private let kMinimalWidth: CGFloat = 25 + 2*TAFrameView.kPadding + 2*TAFrameView.kRadius
    private let kMinimalHeight: CGFloat = 25
    
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
        
        backgroundView = TAFrameView(frame: NSRect(origin: CGPoint.zero, size: size))
        backgroundView.isHidden = true
        self.addSubview(backgroundView)
        
        textView = TATextView(frame: NSRect.zero, responder: self)
        textView.alignment = .natural
        textView.backgroundColor = NSColor.clear
        textView.textColor = TAFrameView.kColorControlFill
        textView.font = NSFont(name: "HelveticaNeue-Bold", size: 30)
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
        
        // all frames here is zero, later we set it in updateSubviewsFrames()
        let tallyFrame = NSRect.zero
        var flipper = TAActivateView(type: TAActiveArea.resizeLeftArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        leftTally = flipper
        
        flipper = TAActivateView(type: TAActiveArea.resizeRightArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        rightTally = flipper
        
        let tally = TADotView(type: TAActiveArea.scaleArea, responder: self, frameRect: tallyFrame)
        tally.isHidden = true
        addSubview(tally)
        scaleTally = tally
        
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
        
        // We should use minimal value to get height. Because of multiline.
        let minWidth = min(textFrame.width + textView.twoSymbolsWidth, textView.bounds.width)
        textFrame = textView.frameForWidth(minWidth, height: CGFloat.greatestFiniteMagnitude)
        let height = textFrame.height
        
        // Now we know text label frame. We should calculate new self.frame and redraw all the subviews
        textFrame = CGRect(x: frame.minX,
                           y: center.y - height/2.0 - (kPadding + kTextPadding),
                           width: width + 2*(kPadding + kCircleRadius + kTextPadding),
                           height: height + 2*(kPadding + kTextPadding))
        
        frame = textFrame
    }
    
    private func updateSubviewsFrames() {
        let size = frame.size
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
        textView.frame = CGRect(x: kPadding + kCircleRadius + kTextPadding, y: kPadding + kTextPadding, width: size.width - 2*(kPadding + kCircleRadius + kTextPadding), height: size.height - 2 * (kPadding + kTextPadding))
        
        var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: kPadding + 2*kCircleRadius, height: size.height))
        if let tally = leftTally {
            tally.frame = tallyFrame
        }
        
        if let tally = rightTally {
            tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
            tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - (2*kCircleRadius + kPadding))
            tally.frame = tallyFrame
        }
        
        if let tally = scaleTally {
            tallyFrame.origin = CGPoint(x: size.width - (kPadding + 2*kCircleRadius), y: kPadding)
            tallyFrame.size = CGSize(width: 2*kCircleRadius, height: 2*kCircleRadius)
            tally.frame = tallyFrame
        }
        
        CATransaction.commit()
    }
    
    // MARK: - Public
    
    func resizeWithDistance(_ distance: CGFloat) {
        guard state == .resizeRight || state == .resizeLeft else { return }
        
        var theFrame = frame
        let delta = (state == .resizeRight ? 1 : -1) * distance
        var width = theFrame.width + delta
        width = width < kMinimalWidth ? kMinimalWidth : width
        theFrame.size = CGSize(width: width, height: theFrame.height)
        
        if state == .resizeLeft {
            // should move origin as well
            theFrame.origin = CGPoint(x: theFrame.origin.x + distance, y: theFrame.origin.y)
        }
        
        // Here we have to check if text view frame has good size for such container size
        let textFrame = textView.frameForWidth(theFrame.width - 2 * (kPadding + kCircleRadius + kTextPadding),
                                               height: CGFloat.greatestFiniteMagnitude)
        let diff_width = theFrame.width - (textFrame.width + 2 * (kPadding + kCircleRadius + kTextPadding) + textView.twoSymbolsWidth)
        if diff_width < 0 {
            let height = textFrame.height + 2 * (kPadding + kTextPadding)
            let centerY = theFrame.origin.y + theFrame.height/2
            
            theFrame.size = CGSize(width: theFrame.width, height: height)
            theFrame.origin = CGPoint(x: theFrame.origin.x, y: centerY - height/2)
        }
        
        frame = theFrame
        updateSubviewsFrames()
    }
    
    func scaleWithDistance(_ difference: CGSize) {
        guard state == .scaling else { return }
        
        // we should scale it proportionally, driver of the mpvement is height difference
        var height = frame.height - difference.height
        var width = frame.width/frame.height * height
        
        width = width < kMinimalWidth ? kMinimalWidth : width
        height = height < kMinimalHeight ? kMinimalHeight : height
        
        frame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y + difference.height),
                       size: CGSize(width: width, height: height))
        updateSubviewsFrames()
        textView.resetFontSize()
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

extension TAContainerView: TAActiveAreaResponder {
    func areaDidActivated(_ area: TAActiveArea) {
        guard let areaResponder = activeAreaResponder, state == .active else { return }
        areaResponder.areaDidActivated(area)
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
    
    private lazy var currentCursor: NSCursor = NSCursor.current
    private let resizeCursor = NSCursor(image: #imageLiteral(resourceName: "East-West"), hotSpot: NSPoint(x: 9, y: 9))
    private let scaleCursor = NSCursor(image: #imageLiteral(resourceName: "North-West-South-East"), hotSpot: NSPoint(x: 9, y: 9))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Programmatically creating a text annotation
        let size = CGSize.zero
        
        let view1 = TAContainerView(frame: NSRect(origin: CGPoint(x: 100, y: 150), size: size))
        view1.text = "S"
        view1.activateResponder = self
        view1.activeAreaResponder = self
        view.addSubview(view1)
        annotations.append(view1)
        
        let view2 = TAContainerView(frame: NSRect(origin: CGPoint(x: 50, y: 20), size: size))
        view2.text = "2"
        view2.activateResponder = self
        view2.activeAreaResponder = self
        view.addSubview(view2)
        annotations.append(view2)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        activeAnnotation = nil
    }
    
    // MARK: NSResponder
    
    override func mouseUp(with event: NSEvent) {
        currentCursor.set()
        
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
        
        // are we should continue resize or scale
        if activeAnnotation != nil, activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight || activeAnnotation.state == .scaling {
            
            let initialDragPoint = activeAnnotation.initialTouchPoint
            activeAnnotation.initialTouchPoint = screenPoint
            let difference = CGSize(width: screenPoint.x - initialDragPoint.x,
                                    height: screenPoint.y - initialDragPoint.y)
            
            if activeAnnotation.state == .resizeLeft || activeAnnotation.state == .resizeRight {
                activeAnnotation.resizeWithDistance(difference.width)
                
                resizeCursor.set()
            } else if activeAnnotation.state == .scaling {
                activeAnnotation.scaleWithDistance(difference)
                
                scaleCursor.set()
            }
            
            return
        }
        
        // check annotation to activate or break resize
        let locationInView = view.convert(screenPoint, to: nil)
        var annotationToActivate: TAContainerView!
        
        for annotation in annotations {
            if annotation.frame.contains(locationInView) {
                annotationToActivate = annotation
                break
            }
        }
        
        // start dragging or resize
        if let annotation = annotationToActivate, annotation.state == .active {
            let locationInAnnotation = view.convert(screenPoint, to: annotation)
            
            var state: TAContainerView.TAContainerViewState = .active // default state
            if let tally = annotation.leftTally, tally.frame.contains(locationInAnnotation) {
                state = .resizeLeft
            } else if let tally = annotation.rightTally, tally.frame.contains(locationInAnnotation) {
                state = .resizeRight
            } else if let tally = annotation.scaleTally, tally.frame.contains(locationInAnnotation) {
                state = .scaling
            }
            
            if state != .active && annotation.state != .dragging {
                annotation.state = state
                activeAnnotation = annotation
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
        guard activeAnnotation != nil else {
            currentCursor.set()
            
            return
        }
        
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

extension ViewController: TAActiveAreaResponder {
    func areaDidActivated(_ area: TAActiveArea) {
        switch area {
        case .resizeLeftArea:   resizeCursor.set()
        case .resizeRightArea:  resizeCursor.set()
        case .scaleArea:        scaleCursor.set()
        case .textArea:         currentCursor.set()
        }
    }
}
