import Foundation

public struct Section<Item, Header, Footer> {
  public typealias Element = Item
  public typealias Index = Int
  
  // MARK: - Properties
  
  private var items: [Element]
  
  public let id: String?
  public var header: Header?
  public var footer: Footer?
  
  // MARK: - Inits
  
  public init() {
    self.init(items: [])
  }
  
  public init(id: String? = nil, items: [Item], header: Header? = nil, footer: Footer? = nil) {
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
  public var startIndex: Index {
    return items.startIndex
  }
  
  public var endIndex: Index {
    return items.endIndex
  }
  
  public subscript(index: Index) -> Item {
    get { items[index] }
    set { items[index] = newValue }
  }
  
  public func index(after i: Index) -> Index {
    return items.index(after: i)
  }
}

// MARK: - Equatable

extension Section: Equatable where Item: Equatable, Header: Equatable, Footer: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
      && lhs.items == rhs.items
      && lhs.header == rhs.header
      && lhs.footer == rhs.footer
  }
}

// MARK: - Methods

public extension Section {
  func sorted(by areInIncreasingOrder: (Item, Item) throws -> Bool) rethrows -> Self {
    return try Section(id: id, items: items.sorted(by: areInIncreasingOrder), header: header, footer: footer)
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
