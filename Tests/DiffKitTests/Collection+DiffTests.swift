import XCTest
import DiffKit

final class Collection_DiffTests: XCTestCase {
  typealias TestCollectionDiff = CollectionDiff<Int, Int>
  
  func test_empty_to_one() {
    let diff: TestCollectionDiff = [
      .insert(index: 0, element: 1)
    ]
    XCTAssertEqual([].diff(from: [1]), diff)
  }
  
  func test_one_to_empty() {
    let diff: TestCollectionDiff = [
      .remove(index: 0, element: 1)
    ]
    XCTAssertEqual([1].diff(from: []), diff)
  }
  
  func test_1_to_1_2() {
    let diff: TestCollectionDiff = [
      .insert(index: 1, element: 2)
    ]
    XCTAssertEqual([1].diff(from: [1, 2]), diff)
  }
  
  func test_1_2_to_1() {
    let diff: TestCollectionDiff = [
      .remove(index: 1, element: 2)
    ]
    XCTAssertEqual([1, 2].diff(from: [1]), diff)
  }
  
  func test_2_to_1_2() {
    let diff: TestCollectionDiff = [
      .insert(index: 0, element: 1)
    ]
    XCTAssertEqual([2].diff(from: [1,2]), diff)
  }
  
  func test_1_2_to_2() {
    let diff: TestCollectionDiff = [
      .remove(index: 0, element: 1)
    ]
    XCTAssertEqual([1,2].diff(from: [2]), diff)
  }
  
  func testManyToMany() {
    let diff: TestCollectionDiff = [
      .remove(index: 0, element: 9),
      .insert(index: 0, element: 5),
      .remove(index: 1, element: 4),
      .insert(index: 1, element: 6),
      .remove(index: 2, element: 0),
      .remove(index: 3, element: 7),
      .remove(index: 4, element: 2),
      .remove(index: 5, element: 1),
      .remove(index: 6, element: 3),
      .remove(index: 7, element: 3),
      .remove(index: 8, element: 7),
      .remove(index: 9, element: 7),
      .remove(index: 11, element: 1),
      .insert(index: 3, element: 8),
      .insert(index: 4, element: 6),
      .insert(index: 5, element: 9),
      .insert(index: 6, element: 8)
    ]
    
    let a = [9, 4, 0, 7, 2, 1, 3, 3, 7, 7, 2, 1, 1]
    let b = [5, 6, 2, 8, 6, 9, 8, 1]
    
    XCTAssertEqual(a.diff(from: b, by: { $0 == $1 }), diff)
  }
  
  func testApplyDiff() {
    let diff: TestCollectionDiff = [
      .remove(index: 0, element: 9),
      .insert(index: 0, element: 5),
      .remove(index: 1, element: 4),
      .insert(index: 1, element: 6),
      .remove(index: 2, element: 0),
      .remove(index: 3, element: 7),
      .remove(index: 4, element: 2),
      .remove(index: 5, element: 1),
      .remove(index: 6, element: 3),
      .remove(index: 7, element: 3),
      .remove(index: 8, element: 7),
      .remove(index: 9, element: 7),
      .remove(index: 11, element: 1),
      .insert(index: 3, element: 8),
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
