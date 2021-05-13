import Foundation

extension Array: Diffable {
  public typealias Diff = CollectionDiff<Index, Element>
}
