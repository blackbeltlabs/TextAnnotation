

struct Stack<T> {
	fileprivate var array = [T]()

	var isEmpty: Bool {
		return array.isEmpty
	}

	var count: Int {
		return array.count
	}

	mutating func push(_ element: T) {
		array.append(element)
	}

	mutating func pop() -> T? {
		return array.popLast()
	}
	
	mutating func clear() {
		array = []
	}

	var top: T? {
		return array.last
	}
	
	var asArray: [T] {
		return array
	}
}

extension Stack: Sequence {
	func makeIterator() -> AnyIterator<T> {
		var curr = self
		return AnyIterator {
			return curr.pop()
		}
	}
}
