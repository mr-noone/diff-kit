//
//  Diff.swift
//  diff-kit
//
//  Created by Aleksey Zgurskiy on 27.01.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import Foundation

public typealias SectionDiff<Index, Element> = Diff<Index, [Diff<Index, Element>.Change]>

public struct Diff<ChangeIndex, ChangeElement>: Collection {
  public typealias Index = Int
  public typealias Element = Change
  
  public enum Change {
    case insert(index: ChangeIndex, element: ChangeElement)
    case remove(index: ChangeIndex, element: ChangeElement)
    
    public var index: ChangeIndex {
      switch self {
      case let .insert(index, _),
           let .remove(index, _):
        return index
      }
    }
    
    public var element: ChangeElement {
      switch self {
      case let .insert(_, element),
           let .remove(_, element):
        return element
      }
    }
  }
  
  // MARK: - Private properties
  
  private var elements = [Element]()
  
  // MARK: - Public properties
  
  public var startIndex: Index { return elements.startIndex }
  public var endIndex: Index { return elements.endIndex }
  
  public var inserted: [Element] {
    return elements.filter {
      switch $0 {
      case .insert: return true
      case .remove: return false
      }
    }
  }
  
  public var removed: [Element] {
    return elements.filter {
      switch $0 {
      case .insert: return false
      case .remove: return true
      }
    }
  }
  
  // MARK: - Methods
  
  public subscript(index: Index) -> Element {
    return elements[index]
  }
  
  public func index(after i: Index) -> Index {
    return elements.index(after: i)
  }
  
  public mutating func append(_ newElement: Element) {
    elements.append(newElement)
  }
}
