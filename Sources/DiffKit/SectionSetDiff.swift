import Foundation

public struct SectionSetDiff<Item, Header, Footer>: Collection {
  public typealias Element = Change<Item, Header, Footer>
  public typealias Index = Int
  
  public enum Change<Item, Header, Footer> {
    public typealias Section = DiffKit.Section<Item, Header, Footer>
    
    case insert(index: Int, section: Section)
    case remove(index: Int, section: Section)
    case items(section: Int, diff: Section.CollectionDiff)
  }
  
  // MARK: - Properties
  
  private var changes = [Element]()
  
  public var startIndex: Index { changes.startIndex }
  public var endIndex: Index { changes.endIndex }
  
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

extension SectionSetDiff: ExpressibleByArrayLiteral {
  public init(arrayLiteral changes: Element...) {
    self.changes = changes
  }
}

// MARK: - Equatable

extension SectionSetDiff.Change: Equatable where Item: Equatable, Header: Equatable, Footer: Equatable {}

// MARK: - Equatable

extension SectionSetDiff: Equatable where Item: Equatable, Header: Equatable, Footer: Equatable {}
