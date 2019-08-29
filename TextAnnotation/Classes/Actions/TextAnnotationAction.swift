//
//  TextAnnotationAction.swift
//  Pods-TextAnnotation_Example
//
//  Created by kornet on 8/27/19.
//

import Foundation

public protocol TextAnnotationAction {
  var text: String { get }
  var frameUndo: CGRect { get }
	var frameRedo: CGRect { get set}
}

// MARK: - Editing
public struct TextAnnotationActionTextEditing: TextAnnotationAction {
  public let text: String
  public let frameUndo: CGRect
	public var frameRedo: CGRect

  let oldText: String
}

// MARK: - Dragging
public struct TextAnnotationActionDragging: TextAnnotationAction {
	public let text: String
	public let frameUndo: CGRect
	public var frameRedo: CGRect
	
	let difference: CGSize
}

// MARK: - Scaling
public struct TextAnnotationActionScaling: TextAnnotationAction {
  public let text: String
  public let frameUndo: CGRect
	public var frameRedo: CGRect

  let difference: CGSize
	
  let undoFontName: String?
  let undoFontSize: CGFloat?
	let redoFontName: String
	let redoFontSize: CGFloat
}

// MARK: - Resize
enum TextAnnotationResizeType {
	case left
	case right
}

public struct TextAnnotationActionResize: TextAnnotationAction {
	public let text: String
	public let frameUndo: CGRect
	public var frameRedo: CGRect
	
	let resizeType: TextAnnotationResizeType
	let distance: CGFloat
}
