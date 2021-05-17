import Foundation

public protocol Diffable where Self: Collection {
  typealias Equivalent = (Element, Element) throws -> Bool
  associatedtype Diff: AnyCollectionDiff
  
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff
  mutating func apply(diff: Diff)
}

public extension Diffable where Self: BidirectionalCollection, Diff == CollectionDiff<Index, Element> {
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff {
    let buffer = try self.buffer(from: other, by: areEquivalent)
    let diff = self.diff(from: other, with: buffer)
    return diff
  }
}

public extension Diffable where Element: Equatable {
  func diff(from other: Self) -> Diff {
    return diff(from: other) { $0 == $1 }
  }
}

public extension Diffable where Self: RangeReplaceableCollection, Diff == CollectionDiff<Index, Element> {
  mutating func apply(diff: Diff) {
    diff.reversed().forEach {
      switch $0 {
      case let .remove(index, _),
           let .update(index, _, _, _):
        remove(at: index)
      default:
        break
      }
    }
    
    diff.forEach {
      switch $0 {
      case let .insert(index, element),
           let .update(_, _, index, element):
        insert(element, at: index)
      default:
        break
      }
    }
  }
}

private extension Diffable where Self: BidirectionalCollection, Diff == CollectionDiff<Index, Element> {
  func buffer(from other: Self, by areEquivalent: Equivalent) rethrows -> [[Int]] {
    let iCount = count
    let jCount = other.count
    
    let row = Array(repeating: Int(0), count: iCount + 1)
    var buffer = Array(repeating: row, count: jCount + 1)
    
    var i = iCount
    var iIndex = index(startIndex, offsetBy: i)
    while i > 0 {
      i -= 1
      iIndex = index(before: iIndex)
      let iIndex = index(startIndex, offsetBy: i)
      let iElement = self[iIndex]
      
      var j = jCount
      var jIndex = other.index(other.startIndex, offsetBy: j)
      while j > 0 {
        j -= 1
        jIndex = other.index(before:jIndex)
        let jIndex = other.index(other.startIndex, offsetBy: j)
        let jElement = other[jIndex]
        
        let equal = try areEquivalent(iElement, jElement)
        
        if equal {
          buffer[j][i] = buffer[j + 1][i + 1] + 1
        } else {
          buffer[j][i] = Swift.max(buffer[j][i + 1],
                                   buffer[j + 1][i])
        }
      }
    }
    
    return buffer
  }
  
  func diff(from other: Self, with buffer: [[Int]]) -> Diff {
    let iCount = count
    let jCount = other.count
    
    var i = 0, j = 0
    var diff = Diff()
    
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
        diff.append(.update(oldIndex: iIndex, oldElement: self[iIndex],
                            newIndex: jIndex, newElement: other[jIndex]))
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
