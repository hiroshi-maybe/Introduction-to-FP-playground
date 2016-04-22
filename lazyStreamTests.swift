//
//  lazyStreamTests.swift
//  IntroductionToFP
//
//  Created by Kori, Hiroshi on 4/21/16.
//  Copyright © 2016 Kori, Hiroshi. All rights reserved.
//

import Foundation
import XCTest

let elementCount = 100000000
class LazyStreamTests: XCTestCase {
  
  // 6.980 sec on Release build
  func testArrayEvaluation() {
    self.measureBlock {
      let array: [Int] = Array<Int>(1...elementCount)
      
      let res: Int? = array
        .map    { $0 * 2 + $0 * 3 }
        .map    { $0 - 1 }
        .filter { $0 % 3 == 1 }
        .map    { $0 * 7 }
        .first
      XCTAssertEqual(res!, 28)
    }
  }
  
  // vs
  
  // 0.000 sec on Release build
  func testLazyStream() {
    // This is an example of a performance test case.
    self.measureBlock {
      let lazyCollection = (1...elementCount).lazy
      
      let res = lazyCollection
        .map    { $0 * 2 + $0 * 3 }
        .map    { $0 - 1 }
        .filter { $0 % 3 == 1 }
        .map    { $0 * 7 }
        .first
      XCTAssertEqual(res!, 28)
    }
  }
  
  // 0.382 sec on Release build
  func testForLoop() {
    // This is an example of a performance test case.
    self.measureBlock {
      let array: [Int] = Array<Int>(1...elementCount)
      
      var res: Int?
      for i in array {
        var x = i * 2 + i * 3
        x -= 1
        if (x % 3) == 1 {
          res = x * 7
          break
        }
      }

      XCTAssertEqual(res!, 28)
    }
  }
}