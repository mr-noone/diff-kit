import Foundation

public struct SectionSet<Item: Equatable, Header: Equatable, Footer: Equatable>: ExpressibleByArrayLiteral {
  public typealias Section = DiffKit.Section<Item, Header, Footer>
  public typealias SectionIndex = Section.Index
  public typealias Element = Section.Element
  public typealias Index = IndexPath
  
  // MARK: - Properties
  
  private var sections: [Section]
  
  // MARK: - Inits
  
  public init(sections: [Section] = []) {
    self.sections = sections
  }
  
  public init(arrayLiteral sections: Section...) {
    self.sections = sections
  }
}

// MARK: - MutableCollection

extension SectionSet: MutableCollection {
  public var startIndex: Index { [0, 0] }
  public var endIndex: Index { [sections.endIndex, 0] }
  
  public subscript(index: Index) -> Item {
    get { sections[index[0]][index[1]] }
    set { sections[index[0]][index[1]] = newValue }
  }
  
  public subscript(index: SectionIndex) -> Section {
    get { sections[index] }
    set { sections[index] = newValue }
  }
  
  public func index(after i: Index) -> Index {
    let section = sections[i[0]]
    let item = sections[i[0]].index(after: i[1])
    
    switch item {
    case let item where item < section.endIndex: return [i[0], item]
    default: return [section.index(after: i[0]), section.startIndex]
    }
  }
}

// MARK: - Diffable

extension SectionSet: Diffable {
  public typealias Diff = SectionSetDiff<Int, Section>
  
  public func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff {
    var result = Diff()
    
    try sections.diff(from: other.sections).forEach { change in
      switch change {
      case let .insert(index, section):
        result.append(.insert(index: index, section: section))
        
      case let .remove(index, section):
        result.append(.remove(index: index, section: section))
        
      case let .update(_, oldSection, newIndex, newSection) where
            oldSection.id == newSection.id &&
            oldSection.header == newSection.header &&
            oldSection.footer == newSection.footer:
        let diff = try oldSection.diff(from: newSection, by: areEquivalent)
        result.append(.items(section: newIndex, diff: diff))
        
      case let .update(oldIndex, oldSection, newIndex, newSection):
        result.append(.update(oldIndex: oldIndex, oldSection: oldSection,
                              newIndex: newIndex, newSection: newSection))
      }
    }
    
    return result
  }
  
  public mutating func apply(diff: Diff) {
    diff.reversed().forEach { change in
      switch change {
      case let .remove(index, _),
           let .update(index, _, _, _):
        remove(sectionAt: index)
      default:
        break
      }
    }
    
    diff.forEach { change in
      switch change {
      case let .insert(index, section),
           let .update(_, _, index, section):
        insert(section, at: index)
      default:
        break
      }
    }
    
    diff.forEach { change in
      switch change {
      case let .items(section, diff):
        self[section].apply(diff: diff)
      default:
        break
      }
    }
  }
}

// MARK: - Equatable

extension SectionSet: Equatable {
  public static func == (lhs: SectionSet, rhs: SectionSet) -> Bool {
    return lhs.sections == rhs.sections
  }
}

// MARK: - Public

public extension SectionSet {
  // MARK: - Count
  
  var countOfSections: Int {
    sections.count
  }
  
  func countOfItems(in section: SectionIndex) -> Int {
    return sections[section].count
  }
  
  // MARK: - Search
  
  func firstSectionIndex(where predicate: (Section) throws -> Bool) rethrows -> SectionIndex? {
    return try sections.firstIndex(where: predicate)
  }
  
  func firstSectionIndex(by id: AnyHashable) -> SectionIndex? {
    return firstSectionIndex { return $0.id == id }
  }
  
  func firstSection(where predicate: (Section) throws -> Bool) rethrows -> Section? {
    return try sections.first(where: predicate)
  }
  
  func firstSection(by id: AnyHashable) -> Section? {
    return firstSection { $0.id == id }
  }
  
  // MARK: - Sorting
  
  mutating func sortSections(by areInIncreasingOrder: (Section, Section) throws -> Bool) rethrows {
    try sections.sort(by: areInIncreasingOrder)
  }
  
  // MARK: - Compact
  
  mutating func compact() {
    sections = sections.filter { !$0.isEmpty }
  }
  
  // MARK: - Insert
  
  mutating func insert(_ section: Section, at index: SectionIndex) {
    sections.insert(section, at: index)
  }
  
  mutating func insert(_ item: Item, at index: Index) {
    if index[0] < sections.endIndex {
      sections[index[0]].insert(item, at: index[1])
    } else {
      insert([], at: index[0])
      insert(item, at: index)
    }
  }
  
  // MARK: - Append
  
  mutating func append(_ section: Section) {
    insert(section, at: sections.endIndex)
  }
  
  mutating func append(_ item: Item, toSectionAt index: SectionIndex) {
    sections[index].append(item)
  }
  
  mutating func append(_ item: Item) {
    sections[sections.endIndex - 1].append(item)
  }
  
  // MARK: - Remove
  
  mutating func remove(sectionAt index: SectionIndex) {
    sections.remove(at: index)
  }
  
  mutating func remove(at index: Index) {
    sections[index[0]].remove(at: index[1])
  }
  
  mutating func removeFirst(where predicate: (Item) throws -> Bool) rethrows {
    if let index = try firstIndex(where: predicate) {
      sections[index[0]].remove(at: index[1])
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
