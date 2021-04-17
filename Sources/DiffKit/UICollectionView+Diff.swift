import UIKit

public extension UICollectionView {
  func apply<Item>(diff: SectionSet<Item, Any, Any>.SectionSetDiff) {
    var insertIndexPaths = [IndexPath]()
    var removeIndexPaths = [IndexPath]()
    var insertIndexSet = IndexSet()
    var removeIndexSet = IndexSet()
    
    diff.forEach { change in
      switch change {
      case let .insert(index, _):
        insertIndexSet.insert(index)
      case let .remove(index, _):
        removeIndexSet.insert(index)
      case let .items(section, diff):
        diff.forEach { change in
          switch change {
          case let .insert(index, _):
            insertIndexPaths.append(IndexPath(item: index, section: section))
          case let .remove(index, _):
            removeIndexPaths.append(IndexPath(item: index, section: section))
          }
        }
      }
    }
    
    performBatchUpdates {
      deleteItems(at: removeIndexPaths)
      deleteSections(removeIndexSet)
      insertItems(at: insertIndexPaths)
      insertSections(insertIndexSet)
    } completion: { _ in }
  }
}
