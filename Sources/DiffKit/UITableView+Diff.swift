#if os(iOS)
import UIKit

public extension UITableView {
  func apply<I, H, F>(diff: SectionSet<I, H, F>.Diff, with animation: UITableView.RowAnimation) {
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
    
    beginUpdates()
    deleteRows(at: removeIndexPaths, with: animation)
    deleteSections(removeIndexSet, with: animation)
    insertRows(at: insertIndexPaths, with: animation)
    insertSections(insertIndexSet, with: animation)
    reloadRows(at: updateIndexPaths, with: animation)
    reloadSections(updateIndexSet, with: animation)
    endUpdates()
  }
}
#endif
