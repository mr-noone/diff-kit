import UIKit

public extension UITableView {
  func apply<Item>(diff: SectionSet<Item, Any, Any>.SectionSetDiff, with animation: UITableView.RowAnimation) {
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
    
    beginUpdates()
    deleteRows(at: removeIndexPaths, with: animation)
    deleteSections(removeIndexSet, with: animation)
    insertRows(at: insertIndexPaths, with: animation)
    insertSections(insertIndexSet, with: animation)
    endUpdates()
  }
}
