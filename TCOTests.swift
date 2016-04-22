//
//  TCOTests.swift
//  IntroductionToFP
//
//  Created by Kori, Hiroshi on 4/21/16.
//  Copyright © 2016 Kori, Hiroshi. All rights reserved.
//

import Foundation
import XCTest

func simpleRec(n: Int) -> Int {
  if n == 0 {
    return 0
  } else {
    return 1 + simpleRec(n-1)
  }
}

// vs

func tailRec(n: Int, res: Int = 0) -> Int {
  if n == 0 {
    return res
  } else {
    return tailRec(n - 1, res: res + 1)
  }
}

class TCOTests: XCTestCase {
  let recCount = 1000000
  
  func testSimpleRec() {
    XCTAssertEqual(simpleRec(recCount), recCount)
  }
  
  func testTailRec() {
    XCTAssertEqual(tailRec(recCount), recCount)
  }
}