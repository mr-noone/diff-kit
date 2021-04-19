import Foundation

extension Array {
  func multiMap(where predicate: (Element, Element) throws -> Bool) rethrows -> [[Element]] {
    try reduce([[Element]]()) { result, element in
      var result = result
      let index = try result.firstIndex {
        try $0.contains { try predicate($0, element) }
      }
      
      if let index = index {
        result[index].append(element)
      } else {
        result.append([element])
      }
      
      return result
    }
  }
}
