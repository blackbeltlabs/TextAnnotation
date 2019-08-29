//
//  TextAnnotationAction.swift
//  Pods-TextAnnotation_Example
//
//  Created by kornet on 8/27/19.
//

import Foundation

public protocol TextAnnotationAction: Codable, CustomStringConvertible {
  var text: String { get }
  var frameUndo: CGRect { get }
	var frameRedo: CGRect { get }
}

extension TextAnnotationAction {
	var json: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		let result = try! encoder.encode(self)
		return String(data: result, encoding: .utf8)!
	}

	public var description: String { return json }
	
	public init(from decoder: Decoder) throws {
		fatalError("init(from:) has not been implemented")
	}
}

public class TextAnnotationActionClass: TextAnnotationAction, Equatable {
	public var text: String
	public var frameUndo: CGRect
	public var frameRedo: CGRect
	
	public init(text: String, frameUndo: CGRect, frameRedo: CGRect) {
		self.text = text
		self.frameUndo = frameUndo
		self.frameRedo = frameRedo
	}
	
	public static func == (lhs: TextAnnotationActionClass, rhs: TextAnnotationActionClass) -> Bool {
		return lhs.text == rhs.text && lhs.frameUndo == rhs.frameUndo && lhs.frameRedo == lhs.frameRedo
	}
}

// MARK: - Editing
public class TextAnnotationActionTextEditing: TextAnnotationActionClass {
  let oldText: String
	
	public init(text: String, frameUndo: CGRect, frameRedo: CGRect, oldText: String) {
		self.oldText = oldText
		super.init(text: text, frameUndo: frameUndo, frameRedo: frameRedo)
	}
}

// MARK: - Dragging
public class TextAnnotationActionDragging: TextAnnotationActionClass {
	let difference: CGSize
	
	public init(text: String, frameUndo: CGRect, frameRedo: CGRect, difference: CGSize) {
		self.difference = difference
		super.init(text: text, frameUndo: frameUndo, frameRedo: frameRedo)
	}

}

// MARK: - Scaling
public class TextAnnotationActionScaling: TextAnnotationActionClass {
	let difference: CGSize
	let undoFontName: String?
	let undoFontSize: CGFloat?
	let redoFontName: String
	let redoFontSize: CGFloat
	
	public init(text: String,
							frameUndo: CGRect,
							frameRedo: CGRect,
							difference: CGSize,
							undoFontName: String?,
							undoFontSize: CGFloat?,
							redoFontName: String,
							redoFontSize: CGFloat) {
		self.difference = difference
		self.undoFontName = undoFontName
		self.undoFontSize = undoFontSize
		self.redoFontName = redoFontName
		self.redoFontSize = redoFontSize
		super.init(text: text, frameUndo: frameUndo, frameRedo: frameRedo)
	}

}

// MARK: - Resize
public enum TextAnnotationResizeType: String, Codable {
	case left
	case right
}

public class TextAnnotationActionResize: TextAnnotationActionClass {
	let resizeType: TextAnnotationResizeType
	let distance: CGFloat
	
	public init(text: String,
							frameUndo: CGRect,
							frameRedo: CGRect,
							resizeType: TextAnnotationResizeType,
							distance: CGFloat) {
		self.resizeType = resizeType
		self.distance = distance
		super.init(text: text, frameUndo: frameUndo, frameRedo: frameRedo)
	}
}
