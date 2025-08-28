//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for Swift project authors
//

@testable import Testing

struct NotPropertyBasedTests {
  @Test(.hidden, arguments: [0, 1, 2, 3, 100])
  func `Bog standard parameterized test`(foo: UInt) {
    #expect(foo < 20)
  }
}

// MARK: -

extension Array where Element == Int {
  func mySorted() -> [Int] {
    if self.count <= 1 {
      return self
    }

    let mid = self.count / 2
    let leftSorted = Array(self[..<mid]).mySorted()
    let rightSorted = Array(self[mid...]).mySorted()

    return merge(leftSorted, rightSorted)
  }
}

/// This code is kinda bad but that's a feature not a bug you're supposed
/// to feel like you need some hardcore testing to prove it works 😎
func merge(_ left: [Int], _ right: [Int]) -> [Int] {
  guard
    let lfirst = left.first,
    let rfirst = right.first else {
    return left + right
  }

  if lfirst < rfirst {
    return [lfirst] + merge(Array(left[1...]), right)
  } else {
    return [rfirst] + merge(left, Array(right[1...]))
  }
}


// MARK: -

struct PropertyBasedTests {
  @Test(generator: UIntGenerator())
  func `Incredibly contrived property based testing example`(foo: UInt) {
    #expect(foo < 20)
  }

  @Test(generator: IntArrayGenerator())
  func `Slightly less contrived example with sorting`(xs: [Int]) {
    #expect(xs.sorted() == xs.mySorted())
  }


  @Test(generator: IntArrayGenerator())
  func `Shrunk examples should go from smaller to larger`(toShrink: [Int]) {
    let shrunken = IntArrayGenerator().shrink(atMost: toShrink)
    guard shrunken.count > 1 else {
      return
    }

    for idx in 0..<shrunken.count-1 {
      let cur = shrunken[idx]
      let next = shrunken[idx+1]
      #expect(cur.count <= next.count)
    }
  }
}

struct ArbitraryGeneratorTests {
  @Test func `Reasonable shrinking behaviour for UInt`() {
    #expect(
      UIntGenerator().shrink(atMost: 32) == [0, 1, 2, 4, 8, 16, 32]
    )

    #expect(
      UIntGenerator().shrink(atMost: 3) == [0, 1, 3]
    )
  }

  @Test func `Reasonable shrinking behaviour for IntArray`() {
    #expect(
      IntArrayGenerator().shrink(atMost:[]) == [[]]
    )

    #expect(
      IntArrayGenerator().shrink(atMost:[1, 2, 3]) == [[1], [2], [3], [2, 3]]
    )
  }
}
