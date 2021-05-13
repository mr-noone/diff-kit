import Foundation

public protocol AnyCollectionDiff where
  Self: MutableCollection,
  Self: ExpressibleByArrayLiteral,
  Index == Int,
  Element: AnyCollectionDiffItem,
  Element.Index == ChangeIndex,
  Element.Element == ChangeElement {
  
  associatedtype ChangeIndex
  associatedtype ChangeElement
  
  init(_ elements: [Element])
  mutating func append(_ element: Element)
}

extension AnyCollectionDiff {
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}
