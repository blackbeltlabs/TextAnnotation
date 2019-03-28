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
class TATextView: NSTextView {
    
    // MARK: - Variables
    
    var activateResponder: TAActivateResponder?
    override var isEditable: Bool {
        didSet {
            super.isEditable = isEditable
            guard oldValue != isEditable else { return }
            
            print()
        }
    }
}

class TAContainerView: NSView {
    enum TAContainerViewState {
        case inactive
        case active
        case editing
    }
    var state: TAContainerViewState = .inactive {
        didSet {
            guard state != oldValue else { return }
            
            var isActive: Bool = false
            if state == .inactive {
                textView.isEditable = false
                doubleClickGestureRecognizer.isEnabled = !textView.isEditable
            } else {
                isActive = true
                
                if let responder = activateResponder {
                    responder.textViewDidActivate(self)
                }
            }
            
            singleClickGestureRecognizer.isEnabled = state == .inactive
            border.isHidden = !isActive
            layer?.backgroundColor = isActive ? NSColor.white.cgColor : NSColor.clear.cgColor
            
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
    
    // MARK: Private
    
    private var textView: TATextView!
    private var border: CALayer!
    private let kPadding: CGFloat = 3
    
    private var singleClickGestureRecognizer: NSClickGestureRecognizer!
    private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
    
    // MARK: - Methods
    // MARK: Lifecycle
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let size = frameRect.size
        
        wantsLayer = true
        
        textView = TATextView(frame: NSRect(origin: CGPoint(x: kPadding, y: kPadding),
                                            size: CGSize(width: size.width - 2*kPadding,
                                                         height: size.height - 2*kPadding)))
        textView.alignment = .natural
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.gray
        textView.isEditable = false
        
        textView.activateResponder = self
        textView.delegate = self
        
        singleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.singleClickGestureHandle(_:)))
        self.addGestureRecognizer(singleClickGestureRecognizer)
        
        doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.doubleClickGestureHandle(_:)))
        doubleClickGestureRecognizer.numberOfClicksRequired = 2
        doubleClickGestureRecognizer.numberOfTouchesRequired = 2
        self.addGestureRecognizer(doubleClickGestureRecognizer)
        
        border = CALayer()
        border.borderColor = NSColor.magenta.cgColor
        border.borderWidth = 1
        border.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        border.frame = CGRect(origin: CGPoint.zero, size: self.bounds.size)
        border.isHidden = true
        self.layer?.addSublayer(border)
        
        addSubview(textView)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    @objc private func singleClickGestureHandle(_ desture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        
        state = .active
    }
    
    @objc private func doubleClickGestureHandle(_ desture: NSClickGestureRecognizer) {
        guard let theTextView = textView, !theTextView.isEditable else { return }
        
        state = .editing
        theTextView.isEditable = true
        doubleClickGestureRecognizer.isEnabled = !theTextView.isEditable
        
        guard let responder = activateResponder else { return }
        responder.textViewDidActivate(self)
    }
    
    func updateFrameWithText(_ string: String) {
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
        
        let labelFrame = CGRect(x: kPadding, y: kPadding, width: width, height: height)
        
        textFrame = CGRect(x: center.x - width/2.0 - kPadding,
                           y: center.y - height/2.0 - kPadding,
                           width: width + 2*kPadding,
                           height: height + 2*kPadding)
        
        border.frame = CGRect(origin: CGPoint.zero, size: textFrame.size)
        self.frame = textFrame
        textView.frame = labelFrame
    }
    
    // MARK: - Public
}

extension TAContainerView: NSTextViewDelegate {
    
    /*
    func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
        guard let stringsList = replacementStrings else { return true }
        var temp = textView.string
        for (rangeValue, stringValue) in zip(affectedRanges, stringsList) {
            let range = rangeValue.rangeValue
            temp = (temp as NSString).replacingCharacters(in: range, with: stringValue)
        }

        updateFrameWithText(temp)

        return true
    }
    */
    
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
        
        //    let kPadding: CGFloat = 10
        let size = CGSize(width: 25, height: 25)
        
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
    
    override func mouseDown(with event: NSEvent) {
        activeAnnotation = nil
        super.mouseDown(with: event)
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

extension ViewController: TAActivateResponder {
    func textViewDidActivate(_ activeItem: Any?) {
        guard let anActiveItem = activeItem as? TAContainerView else { return }
        activeAnnotation = anActiveItem
    }
}
