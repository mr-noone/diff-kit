//
//  Collection+DiffTests.swift
//  diff-kit-tests
//
//  Created by Aleksey Zgurskiy on 05.03.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import XCTest
@testable import DiffKit

extension Diff.Change: Equatable where ChangeIndex: Equatable, ChangeElement: Equatable {
  public static func == (lhs: Diff<ChangeIndex, ChangeElement>.Change, rhs: Diff<ChangeIndex, ChangeElement>.Change) -> Bool {
    return lhs.index == rhs.index && lhs.element == rhs.element
  }
}

extension Diff: Equatable where ChangeIndex: Equatable & Comparable, ChangeElement: Equatable {
  public static func == (lhs: Diff<ChangeIndex, ChangeElement>, rhs: Diff<ChangeIndex, ChangeElement>) -> Bool {
    return lhs.inserted == rhs.inserted && lhs.removed == rhs.removed
  }
}

class Collection_DiffTests: XCTestCase {
  override func setUp() {}
  
  override func tearDown() {}
  
  func test_empty_to_1() {
    var diff = Diff<Int, Int>()
    diff.append(.insert(index: 0, element: 1))
    XCTAssertEqual([].diff(from: [1], by: { $0 == $1 }), diff)
  }
  
  func test_1_to_empty() {
    var diff = Diff<Int, Int>()
    diff.append(.remove(index: 0, element: 1))
    XCTAssertEqual([1].diff(from: [], by: { $0 == $1 }), diff)
  }
  
  func test_1_to_1_2() {
    var diff = Diff<Int, Int>()
    diff.append(.insert(index: 1, element: 2))
    XCTAssertEqual([1].diff(from: [1,2], by: { $0 == $1 }), diff)
  }
  
  func test_1_2_to_1() {
    var diff = Diff<Int, Int>()
    diff.append(.remove(index: 1, element: 2))
    XCTAssertEqual([1,2].diff(from: [1], by: { $0 == $1 }), diff)
  }
  
  func test_2_to_1_2() {
    var diff = Diff<Int, Int>()
    diff.append(.insert(index: 0, element: 1))
    XCTAssertEqual([2].diff(from: [1,2], by: { $0 == $1 }), diff)
  }
  
  func test_1_2_to_2() {
    var diff = Diff<Int, Int>()
    diff.append(.remove(index: 0, element: 1))
    XCTAssertEqual([1,2].diff(from: [2], by: { $0 == $1 }), diff)
  }
  
  func testManyToMany() {
    var diff = Diff<Int, Int>()
    diff.append(.remove(index: 0, element: 9))
    diff.append(.insert(index: 0, element: 5))
    diff.append(.remove(index: 1, element: 4))
    diff.append(.insert(index: 1, element: 6))
    diff.append(.remove(index: 2, element: 0))
    diff.append(.remove(index: 3, element: 7))
    diff.append(.remove(index: 4, element: 2))
    diff.append(.remove(index: 5, element: 1))
    diff.append(.remove(index: 6, element: 3))
    diff.append(.remove(index: 7, element: 3))
    diff.append(.remove(index: 8, element: 7))
    diff.append(.remove(index: 9, element: 7))
    diff.append(.remove(index: 11, element: 1))
    diff.append(.insert(index: 3, element: 8))
    diff.append(.insert(index: 4, element: 6))
    diff.append(.insert(index: 5, element: 9))
    diff.append(.insert(index: 6, element: 8))
    
    let a = [9, 4, 0, 7, 2, 1, 3, 3, 7, 7, 2, 1, 1]
    let b = [5, 6, 2, 8, 6, 9, 8, 1]
    
    XCTAssertEqual(a.diff(from: b, by: { $0 == $1 }), diff)
  }
}
