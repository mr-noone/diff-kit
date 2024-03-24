import Foundation

public protocol Diffable where Self: Collection {
  typealias Equivalent = (Element, Element) throws -> Bool
  associatedtype Diff: AnyCollectionDiff
  
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff
  mutating func apply(diff: Diff)
}

public extension Diffable where Self: BidirectionalCollection, Diff == CollectionDiff<Index, Element> {
  func diff(from other: Self, by areEquivalent: Equivalent) rethrows -> Diff {
    return withContiguousStorage(for: self) { a in
      return withContiguousStorage(for: other) { b in
        let buffer = try! buffer(from: a, to: b, by: areEquivalent)
        let diff = diff(from: self, to: other, with: buffer)
        return diff
      }
    }
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
  func withContiguousStorage<C: Collection, R>(
    for values: C,
    _ body: (UnsafeBufferPointer<C.Element>) throws -> R
  ) rethrows -> R {
    if let result = try values.withContiguousStorageIfAvailable(body) { return result }
    let array = ContiguousArray(values)
    return try array.withUnsafeBufferPointer(body)
  }
  
  func buffer(
    from a: UnsafeBufferPointer<Element>,
    to b: UnsafeBufferPointer<Element>,
    by areEquivalent: Equivalent
  ) rethrows -> [Int] {
    let iCount = a.count
    let jCount = b.count
    
    var buffer = Array(repeating: Int(0), count: (iCount &+ 1) &* (jCount &+ 1))
    try buffer.withUnsafeMutableBufferPointer { buffer in
      var i = iCount
      while i > 0 {
        i &-= 1
        let iElement = a[i]
        
        var j = jCount
        while j > 0 {
          j &-= 1
          let jElement = b[j]
          let bIndex = i &* jCount &+ j
          
          if try areEquivalent(iElement, jElement) {
            let vIndex = (i &+ 1) &* jCount &+ (j &+ 1)
            let v = buffer[vIndex]
            buffer[bIndex] = v &+ 1
          } else {
            let oneIndex = i &* jCount &+ (j &+ 1)
            let twoIndex = (i &+ 1) &* jCount &+ j
            let one = buffer[oneIndex]
            let two = buffer[twoIndex]
            buffer[bIndex] = Swift.max(one, two)
          }
        }
      }
    }
    
    return buffer
  }
  
  func diff(from a: Self, to b: Self, with buffer: [Int]) -> Diff {
    let iCount = a.count
    let jCount = b.count
    
    var i = 0, j = 0
    var diff = Diff()
    
    while i < iCount || j < jCount {
      let iIndex = a.index(a.startIndex, offsetBy: i)
      let jIndex = b.index(b.startIndex, offsetBy: j)
      
      switch buffer[i * jCount + j] {
      case _ where j == jCount:
        diff.append(.remove(index: iIndex, element: a[iIndex]))
        i += 1
      case _ where i == iCount:
        diff.append(.insert(index: jIndex, element: b[jIndex]))
        j += 1
      case buffer[(i + 1) * jCount + (j + 1)]:
        diff.append(.update(
          oldIndex: iIndex, oldElement: a[iIndex],
          newIndex: jIndex, newElement: b[jIndex])
        )
        i += 1
        j += 1
      case buffer[(i + 1) * jCount + j]:
        diff.append(.remove(index: iIndex, element: a[iIndex]))
        i += 1
      case buffer[i * jCount + (j + 1)]:
        diff.append(.insert(index: jIndex, element: b[jIndex]))
        j += 1
      default:
        i += 1
        j += 1
      }
    }
    
    return diff
  }
}
