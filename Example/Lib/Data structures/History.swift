
import Foundation

protocol History: class {
	associatedtype Item
	
	var undoStack: Stack<Item> { get set }
	var redoStack: Stack<Item> { get set }
	
	var undoActionsArray: [Item] { get }
}

extension History {

	var canUndo: Bool { return !undoStack.isEmpty }
	var canRedo: Bool { return !redoStack.isEmpty }
	
	func save(_ item: Item) {
		undoStack.push(item)
		redoStack.clear()
	}
	
	func undo() -> Item? {
		guard let item = undoStack.pop() else {
			return nil
		}
		redoStack.push(item)
		return item
	}
	
	func redo() -> Item? {
		guard let item = redoStack.pop() else {
			return nil
		}
		undoStack.push(item)
		return item
	}
	
	var undoActionsArray: [Item] {
		return undoStack.asArray
	}
}

class HistoryClass<Item>: History {
	
	var undoStack: Stack<Item> = Stack()
	var redoStack: Stack<Item> = Stack()
	
	init() {	}
}

