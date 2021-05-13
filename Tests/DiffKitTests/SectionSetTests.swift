import XCTest
import DiffKit

final class SectionSetTests: XCTestCase {
  typealias TestSectionSet = SectionSet<Int, Int, Int>
  
  // MARK: - MutableCollection
  
  func testStartIndex() {
    let indexPath = IndexPath(item: 0, section: 0)
    let sectionSet: TestSectionSet = [[1, 2]]
    XCTAssertEqual(sectionSet.startIndex, indexPath)
  }
  
  func testEndIndex() {
    let indexPath = IndexPath(item: 0, section: 2)
    let sectionSet: TestSectionSet = [[1, 2], [3, 4]]
    XCTAssertEqual(sectionSet.endIndex, indexPath)
  }
  
  func testEmptyEndIndex() {
    let indexPath = IndexPath(item: 0, section: 0)
    let sectionSet = TestSectionSet()
    XCTAssertEqual(sectionSet.endIndex, indexPath)
  }
  
  func testSubscriptGet() {
    let indexPath = IndexPath(item: 0, section: 0)
    let sectionSet: TestSectionSet = [[1]]
    XCTAssertEqual(sectionSet[indexPath], 1)
  }
  
  func testSubscriptSet() {
    let indexPath = IndexPath(item: 0, section: 0)
    var sectionSet: TestSectionSet = [[1]]
    sectionSet[indexPath] = 2
    XCTAssertEqual(sectionSet, [[2]])
  }
  
  func testSubscriptSectionGet() {
    let sectionSet: TestSectionSet = [[1], [2]]
    XCTAssertEqual(sectionSet[1], [2])
  }
  
  func testSubscriptSectionSet() {
    var sectionSet: TestSectionSet = [[1], [2]]
    sectionSet[0] = [2]
    XCTAssertEqual(sectionSet, [[2], [2]])
  }
  
  func testIndexAfterFirstInSection() {
    let indexPath = IndexPath(item: 0, section: 0)
    let result = IndexPath(item: 1, section: 0)
    let sectionSet: TestSectionSet = [[1, 2], [1, 2]]
    XCTAssertEqual(sectionSet.index(after: indexPath), result)
  }
  
  func testIndexAfterLastInSection() {
    let indexPath = IndexPath(item: 1, section: 0)
    let result = IndexPath(item: 0, section: 1)
    let sectionSet: TestSectionSet = [[1, 2], [1, 2]]
    XCTAssertEqual(sectionSet.index(after: indexPath), result)
  }
  
  func testIndexAfterLastInSet() {
    let indexPath = IndexPath(item: 2, section: 1)
    let result = IndexPath(item: 0, section: 2)
    let sectionSet: TestSectionSet = [[1, 2], [1, 2]]
    XCTAssertEqual(sectionSet.index(after: indexPath), result)
  }
  
  // MARK: - Diffable
  
  func testDiffItems() {
    let one: TestSectionSet = [[1, 2, 3]]
    let two: TestSectionSet = [[2, 3, 4]]
    let diff: TestSectionSet.Diff = [
      .items(section: 0, diff: [
        .remove(index: 0, element: 1),
        .insert(index: 2, element: 4)
      ])
    ]
    XCTAssertEqual(one.diff(from: two), diff)
  }
  
  func testDiffInsert() {
    let one: TestSectionSet = [[4, 5, 6]]
    let two: TestSectionSet = [[1, 2, 3], [4, 5, 6]]
    let diff: TestSectionSet.Diff = [
      .insert(index: 0, section: [1, 2, 3])
    ]
    XCTAssertEqual(one.diff(from: two), diff)
  }
  
  func testDiffRemove() {
    let one: TestSectionSet = [[1, 2, 3], [4, 5, 6]]
    let two: TestSectionSet = [[4, 5, 6]]
    let diff: TestSectionSet.Diff = [
      .remove(index: 0, section: [1, 2, 3])
    ]
    XCTAssertEqual(one.diff(from: two), diff)
  }
  
  func testDiffUpdate() {
    let one: TestSectionSet = [
      .init(id: 1, items: [1, 2, 3], header: 1, footer: 1),
      .init(id: 2, items: [4, 5, 6], header: 2, footer: 2)
    ]
    let two: TestSectionSet = [
      .init(id: 2, items: [1], header: 2, footer: 2),
      .init(id: 2, items: [4, 5, 6], header: 2, footer: 2)
    ]
    let diff: TestSectionSet.Diff = [
      .update(oldIndex: 0, oldSection: .init(id: 1, items: [1, 2, 3], header: 1, footer: 1),
              newIndex: 0, newSection: .init(id: 2, items: [1], header: 2, footer: 2))
    ]
    XCTAssertEqual(one.diff(from: two), diff)
  }
  
  func testApplyDiff() {
    var one: TestSectionSet = [
      .init(id: 1, items: [1, 2, 3], header: 1, footer: 1),
      .init(id: 2, items: [4, 5, 6], header: 2, footer: 2),
      .init(id: 3, items: [7, 8, 9], header: 3, footer: 3),
    ]
    let two: TestSectionSet = [
      .init(id: 2, items: [4, 5, 6], header: 2, footer: 2),
      .init(id: 3, items: [7, 8], header: 3, footer: 3),
      .init(id: 4, items: [10, 11], header: 4, footer: 4)
    ]
    let diff: TestSectionSet.Diff = [
      .remove(index: 0, section: .init(id: 1, items: [1, 2, 3], header: 1, footer: 1)),
      .items(section: 1, diff: [.remove(index: 2, element: 9)]),
      .insert(index: 2, section: .init(id: 4, items: [10, 11], header: 4, footer: 4))
    ]
    
    one.apply(diff: diff)
    XCTAssertEqual(one, two)
  }
  
  // MARK: - Count
  
  func testCountOfSections() {
    let sectionSet: TestSectionSet = [[1, 2], [3, 4]]
    XCTAssertEqual(sectionSet.countOfSections, 2)
  }
  
  func testCountOfItems() {
    let sectionSet: TestSectionSet = [[1, 2, 3]]
    XCTAssertEqual(sectionSet.countOfItems(in: 0), 3)
  }
  
  // MARK: - Inset
  
  func testInsertSection() {
    var sectionSet: TestSectionSet = [[3, 4]]
    sectionSet.insert([1, 2], at: 0)
    XCTAssertEqual(sectionSet, [[1, 2], [3, 4]])
  }
  
  func testInsertItem() {
    var sectionSet: TestSectionSet = [[1, 3]]
    sectionSet.insert(2, at: IndexPath(item: 1, section: 0))
    XCTAssertEqual(sectionSet, [[1, 2, 3]])
  }
  
  func testInsertItemToNewSection() {
    var sectionSet: TestSectionSet = [[1, 2]]
    sectionSet.insert(3, at: IndexPath(item: 0, section: 1))
    XCTAssertEqual(sectionSet, [[1, 2], [3]])
  }
  
  // MARK: - Append
  
  func testAppendSection() {
    var sectionSet: TestSectionSet = [[1, 2]]
    sectionSet.append([3, 4])
    XCTAssertEqual(sectionSet, [[1, 2], [3, 4]])
  }
  
  func testAppendItemToSection() {
    var sectionSet: TestSectionSet = [[1], [3]]
    sectionSet.append(2, toSectionAt: 0)
    XCTAssertEqual(sectionSet, [[1, 2], [3]])
  }
  
  func testAppendItemToLastSection() {
    var sectionSet: TestSectionSet = [[1], [2]]
    sectionSet.append(3)
    XCTAssertEqual(sectionSet, [[1], [2, 3]])
  }
  
  // MARK: - Remove
  
  func testRemoveSection() {
    var sectionSet: TestSectionSet = [[1], [2]]
    sectionSet.remove(sectionAt: 0)
    XCTAssertEqual(sectionSet, [[2]])
  }
  
  func testRemoveItemAtIndex() {
    var sectionSet: TestSectionSet = [[1, 2]]
    sectionSet.remove(at: IndexPath(item: 0, section: 0))
    XCTAssertEqual(sectionSet, [[2]])
  }
  
  func testRemoveFirstWhere() {
    var sectionSet: TestSectionSet = [[1, 2, 3, 2]]
    sectionSet.removeFirst(where: { $0 == 2 })
    XCTAssertEqual(sectionSet, [[1, 3, 2]])
  }
  
  func testRemoveAllWhere() {
    var sectionSet: TestSectionSet = [[1, 2, 3, 2]]
    sectionSet.removeAll(where: { $0 == 2 })
    XCTAssertEqual(sectionSet, [[1, 3]])
  }
}
