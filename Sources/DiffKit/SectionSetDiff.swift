import Foundation

public struct SectionSetDiff<ChangeIndex: Comparable, ChangeElement: Diffable>: AnyCollectionDiff {
  public enum SectionSetDiffItem<Index: Comparable, Element: Diffable>: AnyCollectionDiffItem {
    case insert(index: Index, section: Element)
    case remove(index: Index, section: Element)
    case update(oldIndex: Index, oldSection: Element, newIndex: Index, newSection: Element)
    case items(section: Index, diff: Element.Diff)
  }
  
  public typealias Element = SectionSetDiffItem<ChangeIndex, ChangeElement>
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

extension SectionSetDiff.SectionSetDiffItem: Equatable where Element: Equatable, Element.Diff: Equatable {}

extension SectionSetDiff: Equatable where ChangeElement: Equatable, ChangeElement.Diff: Equatable {}
