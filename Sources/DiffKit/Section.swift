import Foundation

public struct Section<Item: Equatable, Header: Equatable, Footer: Equatable> {
  public typealias Element = Item
  public typealias Index = Int
  
  // MARK: - Properties
  
  private var items: [Item]
  
  public let id: AnyHashable?
  public var header: Header?
  public var footer: Footer?
  
  // MARK: - Inits
  
  public init() {
    self.init(items: [])
  }
  
  public init(id: AnyHashable? = nil,
              items: [Item],
              header: Header? = nil,
              footer: Footer? = nil) {
    self.id = id
    self.items = items
    self.header = header
    self.footer = footer
  }
}

// MARK: - ExpressibleByArrayLiteral

extension Section: ExpressibleByArrayLiteral {
  public init(arrayLiteral items: Item...) {
    self.id = nil
    self.items = items
  }
}

// MARK: - MutableCollection

extension Section: MutableCollection {
  public var startIndex: Index { items.startIndex }
  public var endIndex: Index { items.endIndex }
  
  public subscript(index: Index) -> Item {
    get { items[index] }
    set { items[index] = newValue }
  }
  
  public func index(after i: Index) -> Index {
    return items.index(after: i)
  }
}

// MARK: - Diffable

extension Section: Diffable {
  public typealias Diff = Array<Item>.Diff
  
  public func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff {
    return try items.diff(from: other.items, by: areEquivalent)
  }
  
  public mutating func apply(diff: Diff) {
    items.apply(diff: diff)
  }
}

// MARK: - Equatable

extension Section: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
      && lhs.items == rhs.items
      && lhs.header == rhs.header
      && lhs.footer == rhs.footer
  }
}

// MARK: - Public methods

public extension Section {
  mutating func sort(by areInIncreasingOrder: (Item, Item) throws -> Bool) rethrows {
    try items.sort(by: areInIncreasingOrder)
  }
  
  mutating func insert(_ item: Item, at index: Index) {
    items.insert(item, at: index)
  }
  
  mutating func append(_ item: Item) {
    items.append(item)
  }
  
  mutating func remove(at index: Index) {
    items.remove(at: index)
  }
}
