import Foundation

public struct CollectionDiff<ChangeIndex: Comparable, ChangeElement>: Collection {
  public typealias Element = Change<ChangeIndex, ChangeElement>
  public typealias Index = Int
  
  public enum Change<Index: Comparable, Element> {
    case insert(index: Index, element: Element)
    case remove(index: Index, element: Element)
  }
  
  // MARK: - Properties
  
  private var changes = [Element]()
  
  public var startIndex: Index { changes.startIndex }
  public var endIndex: Index { changes.endIndex }
  
  public var insertCount: Int {
    changes.filter {
      switch $0 {
      case .insert: return true
      case .remove: return false
      }
    }.count
  }
  
  public var removeCount: Int {
    changes.filter {
      switch $0 {
      case .insert: return false
      case .remove: return true
      }
    }.count
  }
  
  // MARK: - Methods
  
  public subscript(index: Index) -> Element {
    return changes[index]
  }
  
  public func index(after i: Index) -> Index {
    return changes.index(after: i)
  }
  
  public mutating func append(_ element: Element) {
    changes.append(element)
  }
}

// MARK: - ExpressibleByArrayLiteral

extension CollectionDiff: ExpressibleByArrayLiteral {
  public init(arrayLiteral changes: Element...) {
    self.changes = changes
  }
}

// MARK: - Equatable

extension CollectionDiff.Change: Equatable where Element: Equatable {}

// MARK: - Equatable

extension CollectionDiff: Equatable where ChangeElement: Equatable {}
