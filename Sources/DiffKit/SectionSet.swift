import Foundation

public typealias AnySectionSet = SectionSet<Any, Any, Any>

public struct SectionSet<Item, Header, Footer> {
  public typealias Section = DiffKit.Section<Item, Header, Footer>
  public typealias Element = Section.Element
  public typealias SectionIndex = Int
  public typealias Index = IndexPath
  
  // MARK: - Properties
  
  private var sections: [Section]
  
  // MARK: - Inits
  
  public init(sections: [Section] = []) {
    self.sections = sections
  }
}

// MARK: - ExpressibleByArrayLiteral

extension SectionSet: ExpressibleByArrayLiteral {
  public init(arrayLiteral sections: Section...) {
    self.sections = sections
  }
}

// MARK: - MutableCollection

extension SectionSet: MutableCollection {
  public var startIndex: Index {
    Index(item: 0, section: 0)
  }
  
  public var endIndex: Index {
    return Index(item: 0, section: sections.endIndex)
  }
  
  public subscript(index: Index) -> Item {
    get { sections[index.section][index.item] }
    set { sections[index.section][index.item] = newValue }
  }
  
  public subscript(index: SectionIndex) -> Section {
    get { sections[index] }
    set { sections[index] = newValue }
  }
  
  public func index(after i: Index) -> Index {
    let section = sections[i.section]
    let item = sections[i.section].index(after: i.item)
    
    switch item {
    case let item where item < section.endIndex:
      return IndexPath(item: item, section: i.section)
    default:
      return IndexPath(item: section.startIndex, section: sections.index(after: i.section))
    }
  }
}

// MARK: - Equatable

extension SectionSet: Equatable where Item: Equatable, Header: Equatable, Footer: Equatable {
  public static func == (lhs: SectionSet, rhs: SectionSet) -> Bool {
    return lhs.sections == rhs.sections
  }
}

// MARK: - Public

public extension SectionSet {
  var countOfSections: Int {
    sections.count
  }
  
  func countOfItems(in section: SectionIndex) -> Int {
    return sections[section].count
  }
  
  func forEach(_ body: (Index, Item) throws -> ()) rethrows {
    for section in 0..<countOfSections {
      for item in 0..<countOfItems(in: section) {
        let indexPath = Index(item: item, section: section)
        try body(indexPath, self[indexPath])
      }
    }
  }
  
  mutating func compact() {
    sections = sections.filter { !$0.isEmpty }
  }
  
  mutating func insert(_ section: Section, at index: SectionIndex) {
    sections.insert(section, at: index)
  }
  
  mutating func insert(_ item: Item, at index: Index) {
    if index.section < sections.endIndex {
      sections[index.section].insert(item, at: index.item)
    } else {
      insert(Section(), at: index.section)
      insert(item, at: index)
    }
  }
  
  mutating func append(_ section: Section) {
    insert(section, at: sections.endIndex)
  }
  
  mutating func append(_ item: Item, toSectionAt index: SectionIndex) {
    sections[index].append(item)
  }
  
  mutating func append(_ item: Item) {
    sections[sections.endIndex - 1].append(item)
  }
  
  mutating func remove(sectionAt index: SectionIndex) {
    sections.remove(at: index)
  }
  
  mutating func remove(at index: Index) {
    sections[index.section].remove(at: index.item)
  }
  
  mutating func removeFirst(where predicate: (Item) throws -> Bool) rethrows {
    if let index = try firstIndex(where: predicate) {
      sections[index.section].remove(at: index.item)
    }
  }
  
  mutating func removeAll(where predicate: (Item) throws -> Bool) rethrows {
    for section in (0..<countOfSections).reversed() {
      for item in (0..<countOfItems(in: section)).reversed() {
        if try predicate(sections[section][item]) {
          sections[section].remove(at: item)
        }
      }
    }
  }
}

// MARK: - Diff

public extension SectionSet {
  typealias SectionDiff = Section.CollectionDiff
  typealias SectionSetDiff = DiffKit.SectionSetDiff<Item, Header, Footer>
  
  func diff(from other: Self) -> SectionSetDiff where Element: Equatable {
    return diff(from: other, by: { $0 == $1 })
  }
  
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> SectionSetDiff {
    var diff = SectionSetDiff()
    
    for section in 0..<Swift.max(countOfSections, other.countOfSections) {
      let source = section < countOfSections ? self[section] : []
      let other = section < other.countOfSections ? other[section] : []
      
      switch try source.diff(from: other, by: areEquivalent) {
      case let items where source.count > 0 && items.removeCount == source.count && other.count > 0 && items.insertCount == other.count:
        diff.append(.remove(index: section, section: source))
        diff.append(.insert(index: section, section: other))
      case let items where source.count > 0 && items.removeCount == source.count:
        diff.append(.remove(index: section, section: source))
      case let items where other.count > 0 && items.insertCount == other.count:
        diff.append(.insert(index: section, section: other))
      case let itemsDiff:
        diff.append(.items(section: section, diff: itemsDiff))
      }
    }
    
    return diff
  }
  
  mutating func apply(diff: SectionSetDiff) {
    var insertItems = [(index: IndexPath, item: Item)]()
    var removeItems = [(index: IndexPath, item: Item)]()
    var insertSections = [(index: Int, section: Section)]()
    var removeSections = [(index: Int, section: Section)]()
    
    diff.forEach { change in
      switch change {
      case let .insert(index, section):
        insertSections.append((index, section))
      case let .remove(index, section):
        removeSections.append((index, section))
      case let .items(section, diff):
        diff.forEach { change in
          switch change {
          case let .insert(index, item):
            insertItems.append((IndexPath(item: index, section: section), item))
          case let .remove(index, item):
            removeItems.append((IndexPath(item: index, section: section), item))
          }
        }
      }
    }
    
    removeItems.reversed().forEach { index, _ in remove(at: index) }
    removeSections.reversed().forEach { index, _ in remove(sectionAt: index) }
    insertItems.forEach { index, item in insert(item, at: index) }
    insertSections.forEach { index, section in insert(section, at: index) }
    
    compact()
  }
}
