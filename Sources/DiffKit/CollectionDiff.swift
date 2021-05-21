import Foundation

public struct CollectionDiff<ChangeIndex: Comparable, ChangeElement>: AnyCollectionDiff {
  public enum CollectionDiffItem<Index: Comparable, Element>: AnyCollectionDiffItem {
    case insert(index: Index, element: Element)
    case remove(index: Index, element: Element)
    case update(oldIndex: Index, oldElement: Element, newIndex: Index, newElement: Element)
  }
  
  public typealias Element = CollectionDiffItem<ChangeIndex, ChangeElement>
  public typealias Index = Int
  
  // MARK: - Properties
  
  private var items = [Element]()
  
  public var startIndex: Index { items.startIndex }
  public var endIndex: Index { items.endIndex }
  
  // MARK: - Methods
  
  public subscript(index: Index) -> Element {
    get { items[index] }
    set { items[index] = newValue }
  }
  
  public func index(after i: Index) -> Index {
    items.index(after: i)
  }
  
  public mutating func append(_ element: Element) {
    items.append(element)
  }
  
  // MARK: - Inits
  
  public init(_ items: [Element]) {
    self.items = items
  }
  
  public init() {
    self.init([])
  }
}

// MARK: - Equatable

extension CollectionDiff.CollectionDiffItem: Equatable where Element: Equatable {}

extension CollectionDiff: Equatable where ChangeElement: Equatable {}
