#if os(iOS)
import UIKit

public extension UICollectionView {
  func apply<I, H, F>(diff: SectionSet<I, H, F>.Diff) {
    var insertIndexSet = IndexSet()
    var removeIndexSet = IndexSet()
    var updateIndexSet = IndexSet()
    
    var insertIndexPaths = [IndexPath]()
    var removeIndexPaths = [IndexPath]()
    var updateIndexPaths = [IndexPath]()
    
    diff.forEach { change in
      switch change {
      case let .insert(index, _):       insertIndexSet.insert(index)
      case let .remove(index, _):       removeIndexSet.insert(index)
      case let .update(_, _, index, _): updateIndexSet.insert(index)
      case let .items(section, diff):
        diff.forEach { change in
          switch change {
          case let .insert(item, _):       insertIndexPaths.append([section, item])
          case let .remove(item, _):       removeIndexPaths.append([section, item])
          case let .update(_, _, item, _): updateIndexPaths.append([section, item])
          }
        }
      }
    }
    
    performBatchUpdates {
      deleteItems(at: removeIndexPaths)
      deleteSections(removeIndexSet)
      insertItems(at: insertIndexPaths)
      insertSections(insertIndexSet)
      reloadItems(at: updateIndexPaths)
      reloadSections(updateIndexSet)
    } completion: { _ in }
  }
}
#endif
