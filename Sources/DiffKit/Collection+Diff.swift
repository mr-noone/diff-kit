//
//  Collection.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 27.01.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import Foundation

public extension Collection where Element: AnySection, Element.Item: Equatable {
  func diff<C>(from other: C) -> SectionDiff<Int, Element.Item> where C: Collection, C.Index == Index, C.Element == Element {
    return diff(from: other, by: { $0 == $1 })
  }
}

public extension Collection where Element: AnySection {
  func diff<C>(from other: C, by areEquivalent: (Element.Item, C.Element.Item) throws -> Bool) rethrows -> SectionDiff<Int, Element.Item> where C: Collection, C.Index == Index, C.Element == Element {
    var diff = SectionDiff<Int, Element.Item>()
    
    for i in 0..<Swift.max(count, other.count) {
      let indx = index(startIndex, offsetBy: i)
      let source = i < count ? self[indx].items : []
      let other = i < other.count ? other[indx].items : []
      
      let itemsDiff = try source.diff(from: other, by: areEquivalent)
      
      if itemsDiff.inserted.isEmpty == false {
        diff.append(.insert(index: i, element: itemsDiff.inserted))
      }
      
      if itemsDiff.removed.isEmpty == false {
        diff.append(.remove(index: i, element: itemsDiff.removed))
      }
    }
    
    return diff
  }
}

public extension Collection where Element: Equatable {
  func diff<C>(from other: C) -> Diff<Index, Element> where C: Collection, C.Index == Index, C.Element == Element {
    return diff(from: other, by: { $0 == $1 })
  }
}

public extension Collection {
  func diff<C>(from other: C, by areEquivalent: (Element, C.Element) throws -> Bool) rethrows -> Diff<Index, Element> where C: Collection, C.Index == Index, C.Element == Element {
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
    var diff = Diff<Index, Element>()
    
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
