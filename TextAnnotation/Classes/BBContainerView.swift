//
//  BBContainerView.swift
//  TextAnnotation
//
//  Created by Sergey Vinogradov on 12.04.2019.
//

import Cocoa

protocol BBActivateResponder: class {
    func textViewDidActivate(_ activeItem: Any?)
}

open class BBContainerView: NSView {
    
    // MARK: - Variables
    
    enum ContainerViewState {
        case inactive
        case active
        case editing
        case resizeRight
        case resizeLeft
        case dragging
        case scaling
    }
    var state: ContainerViewState = .inactive {
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
    
    weak var activateResponder: BBActivateResponder?
    weak var activeAreaResponder: BBActiveAreaResponder?
    
    var text: String! {
        didSet {
            guard textView != nil else { return }
            textView.string = text
            updateFrameWithText(textView.string)
        }
    }
    var initialTouchPoint = CGPoint.zero
    var leftTally: BBActiveView?
    var rightTally: BBActiveView?
    var scaleTally: BBDotView?
    
    // FIXME: Possible unused
    var origin: CGPoint = CGPoint.zero {
        didSet {
            frame.origin = origin
            updateSubviewsFrames()
        }
    }
    
    // MARK: Private
    
    private var backgroundView: BBBackgroundView!
    private var textView: BBTextView!
    
    private let kMinimalWidth: CGFloat = 25 + 2*BBConfiguration.frameMargin + 2*BBConfiguration.dotRadius
    private let kMinimalHeight: CGFloat = 25
    
    private var singleClickGestureRecognizer: NSClickGestureRecognizer!
    private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
    
    override open var frame: NSRect {
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
        
        backgroundView = BBBackgroundView(frame: NSRect(origin: CGPoint.zero, size: size))
        backgroundView.isHidden = true
        self.addSubview(backgroundView)
        
        textView = BBTextView(frame: NSRect.zero, responder: self)
        textView.alignment = .natural
        textView.backgroundColor = NSColor.clear
        textView.textColor = BBPalette.controlFillColor
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
        var flipper = BBActiveView(type: .resizeLeftArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        leftTally = flipper
        
        flipper = BBActiveView(type: .resizeRightArea, responder: self, frameRect: tallyFrame)
        flipper.isHidden = true
        addSubview(flipper)
        rightTally = flipper
        
        let tally = BBDotView(type: .scaleArea, responder: self, frameRect: tallyFrame)
        tally.isHidden = true
        addSubview(tally)
        scaleTally = tally
        
        updateFrameWithText(textView.string)
    }
    
    required public init?(coder decoder: NSCoder) {
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
                           y: center.y - height/2.0 - (BBConfiguration.frameMargin + BBConfiguration.horizontalTextPadding),
                           width: width + 2*(BBConfiguration.frameMargin + BBConfiguration.dotRadius + BBConfiguration.horizontalTextPadding),
                           height: height + 2*(BBConfiguration.frameMargin + BBConfiguration.horizontalTextPadding))
        
        frame = textFrame
    }
    
    private func updateSubviewsFrames() {
        let size = frame.size
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
        textView.frame = CGRect(x: BBConfiguration.frameMargin + BBConfiguration.dotRadius + BBConfiguration.horizontalTextPadding, y: BBConfiguration.frameMargin + BBConfiguration.horizontalTextPadding, width: size.width - 2*(BBConfiguration.frameMargin + BBConfiguration.dotRadius + BBConfiguration.horizontalTextPadding), height: size.height - 2 * (BBConfiguration.frameMargin + BBConfiguration.horizontalTextPadding))
        
        var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: BBConfiguration.frameMargin + 2*BBConfiguration.dotRadius, height: size.height))
        if let tally = leftTally {
            tally.frame = tallyFrame
        }
        
        if let tally = rightTally {
            tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
            tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - (2*BBConfiguration.dotRadius + BBConfiguration.frameMargin))
            tally.frame = tallyFrame
        }
        
        if let tally = scaleTally {
            tallyFrame.origin = CGPoint(x: size.width - (BBConfiguration.frameMargin + 2*BBConfiguration.dotRadius), y: BBConfiguration.frameMargin)
            tallyFrame.size = CGSize(width: 2*BBConfiguration.dotRadius, height: 2*BBConfiguration.dotRadius)
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
        let textFrame = textView.frameForWidth(theFrame.width - 2 * (BBConfiguration.frameMargin + BBConfiguration.dotRadius + BBConfiguration.horizontalTextPadding),
                                               height: CGFloat.greatestFiniteMagnitude)
        let diff_width = theFrame.width - (textFrame.width + 2 * (BBConfiguration.frameMargin + BBConfiguration.dotRadius + BBConfiguration.horizontalTextPadding) + textView.twoSymbolsWidth)
        if diff_width < 0 {
            let height = textFrame.height + 2 * (BBConfiguration.frameMargin + BBConfiguration.horizontalTextPadding)
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

extension BBContainerView: NSTextViewDelegate {
    
    // MARK: - NSTextDelegate
    
    private func textDidChange(_ notification: Notification) {
        updateFrameWithText(textView.string)
    }
}

extension BBContainerView: BBActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        // After we reach the .editing state - we should not switch it back to .active, only on .inactive on complete edit
        state = textView.isEditable ? .editing : .active
    }
}

extension BBContainerView: BBActiveAreaResponder {
    func areaDidActivated(_ area: BBArea) {
        guard let areaResponder = activeAreaResponder, state == .active else { return }
        areaResponder.areaDidActivated(area)
    }
}
