import XCTest
import DiffKit

final class DiffableTests: XCTestCase {
  typealias Collection = Array<Int>
  typealias Diff = Collection.Diff
  
  func testMeasure() {
    let one = (0..<500).map { _ in Int.random(in: 0...1000) }
    let two = (0..<500).map { _ in Int.random(in: 0...1000) }
    measure {
      let _ = one.diff(from: two)
    }
  }
  
  func test_empty_to_one() {
    let diff: Diff = [
      .insert(index: 0, element: 1)
    ]
    XCTAssertEqual([].diff(from: [1]), diff)
  }
  
  func test_one_to_empty() {
    let diff: Diff = [
      .remove(index: 0, element: 1)
    ]
    XCTAssertEqual([1].diff(from: []), diff)
  }
  
  func test_1_to_1_2() {
    let diff: Diff = [
      .insert(index: 1, element: 2)
    ]
    XCTAssertEqual([1].diff(from: [1, 2]), diff)
  }
  
  func test_1_2_to_1() {
    let diff: Diff = [
      .remove(index: 1, element: 2)
    ]
    XCTAssertEqual([1, 2].diff(from: [1]), diff)
  }
  
  func test_2_to_1_2() {
    let diff: Diff = [
      .insert(index: 0, element: 1)
    ]
    XCTAssertEqual([2].diff(from: [1,2]), diff)
  }
  
  func test_1_2_to_2() {
    let diff: Diff = [
      .remove(index: 0, element: 1)
    ]
    XCTAssertEqual([1,2].diff(from: [2]), diff)
  }
  
  func testManyToMany() {
    let diff: Diff = [
      .update(oldIndex: 0, oldElement: 9, newIndex: 0, newElement: 5),
      .update(oldIndex: 1, oldElement: 4, newIndex: 1, newElement: 6),
      .remove(index: 2, element: 0),
      .remove(index: 3, element: 7),
      .remove(index: 4, element: 2),
      .remove(index: 5, element: 1),
      .remove(index: 6, element: 3),
      .remove(index: 7, element: 3),
      .remove(index: 8, element: 7),
      .remove(index: 9, element: 7),
      .update(oldIndex: 11, oldElement: 1, newIndex: 3, newElement: 8),
      .insert(index: 4, element: 6),
      .insert(index: 5, element: 9),
      .insert(index: 6, element: 8)
    ]
    
    let a = [9, 4, 0, 7, 2, 1, 3, 3, 7, 7, 2, 1, 1]
    let b = [5, 6, 2, 8, 6, 9, 8, 1]
    
    XCTAssertEqual(a.diff(from: b, by: { $0 == $1 }), diff)
  }
  
  func testApplyDiff() {
    let diff: Diff = [
      .update(oldIndex: 0, oldElement: 9, newIndex: 0, newElement: 5),
      .update(oldIndex: 1, oldElement: 4, newIndex: 1, newElement: 6),
      .remove(index: 2, element: 0),
      .remove(index: 3, element: 7),
      .remove(index: 4, element: 2),
      .remove(index: 5, element: 1),
      .remove(index: 6, element: 3),
      .remove(index: 7, element: 3),
      .remove(index: 8, element: 7),
      .remove(index: 9, element: 7),
      .update(oldIndex: 11, oldElement: 1, newIndex: 3, newElement: 8),
      .insert(index: 4, element: 6),
      .insert(index: 5, element: 9),
      .insert(index: 6, element: 8)
    ]
    
    var a = [9, 4, 0, 7, 2, 1, 3, 3, 7, 7, 2, 1, 1]
    let b = [5, 6, 2, 8, 6, 9, 8, 1]
    
    a.apply(diff: diff)
    XCTAssertEqual(a, b)
  }
}
