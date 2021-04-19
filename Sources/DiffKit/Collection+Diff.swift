import Foundation

public extension Collection {
  typealias Equivalent = (Element, Element) throws -> Bool
  typealias CollectionDiff = DiffKit.CollectionDiff<Index, Element>
  
  func diff(from other: Self) -> CollectionDiff where Element: Equatable {
    return diff(from: other, by: { $0 == $1 })
  }
  
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> CollectionDiff {
    let iCount = count
    let jCount = other.count
    
    var buffer: [[Int]] = (0...jCount).map { _ in
      [Int].init(repeating: 0, count: iCount + 1)
    }
    
    for i in (0..<iCount).reversed() {
      for j in (0..<jCount).reversed() {
        let iIndex = index(startIndex, offsetBy: i)
        let jIndex = other.index(other.startIndex, offsetBy: j)
        
        if try areEquivalent(self[iIndex], other[jIndex]) {
          buffer[j][i] = 1 + buffer[j + 1][i + 1]
        } else {
          buffer[j][i] = Swift.max(buffer[j][i + 1],
                                   buffer[j + 1][i])
        }
      }
    }
    
    var i = 0, j = 0
    var diff = CollectionDiff()
    
    while i < iCount || j < jCount {
      let iIndex = index(startIndex, offsetBy: i)
      let jIndex = other.index(other.startIndex, offsetBy: j)
      
      switch buffer[j][i] {
      case _ where j == jCount:
        diff.append(.remove(index: iIndex, element: self[iIndex]))
        i += 1
      case _ where i == iCount:
        diff.append(.insert(index: jIndex, element: other[jIndex]))
        j += 1
      case buffer[j + 1][i + 1]:
        diff.append(.remove(index: iIndex, element: self[iIndex]))
        diff.append(.insert(index: jIndex, element: other[jIndex]))
        i += 1
        j += 1
      case buffer[j][i + 1]:
        diff.append(.remove(index: iIndex, element: self[iIndex]))
        i += 1
      case buffer[j + 1][i]:
        diff.append(.insert(index: jIndex, element: other[jIndex]))
        j += 1
      default:
        i += 1
        j += 1
      }
    }
    
    return diff
  }
}

public extension RangeReplaceableCollection {
  mutating func apply(diff: CollectionDiff) {
    diff.reversed().forEach { if case let CollectionDiff.Change.remove(index, _) = $0 { remove(at: index) } }
    diff.forEach { if case let CollectionDiff.Change.insert(index, element) = $0 { insert(element, at: index) } }
  }
}
