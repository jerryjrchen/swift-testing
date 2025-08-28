public protocol Arbitrary: Sendable {
  associatedtype GeneratedValue: Sendable

  /// Generate a single example using the provided random number generator.
  func generate(with rng: inout some RandomNumberGenerator) -> GeneratedValue

  /// Create values "smaller" than the maximal provided value, if possible.
  /// Because I am a dummy the shrink method by convention includes the value
  /// of the maximum value as well, even though most other property based
  /// testing frameworks will exclude it. Oh well.
  ///
  /// For example:
  /// - `[1] < [1, 2, 3]`
  /// - `0 < 1 < 1000`
  ///
  /// The returned values should be in order from smallest to largest.
  /// - Parameter maximum: Maximal value to start shrinking from
  /// - Returns: Smaller values than the maximum, if possible
  func shrink(atMost maximum: GeneratedValue) -> [GeneratedValue]
}

/// Bog standard UIntGenerator which is so simple I could cry
public struct UIntGenerator: Arbitrary {
  public typealias GeneratedValue = UInt

  public var maximum: UInt = 100

  public func generate(with rng: inout some RandomNumberGenerator) -> GeneratedValue {
    rng.next(upperBound: maximum)
  }

  public func shrink(atMost value: UInt) -> [UInt] {
    var value = value
    var candidates = [UInt]()
    // Well bounded since UInt has a fixed # of bytes
    while value > 0 {
      candidates.append(value)
      value /= 2
    }
    return [0] + candidates.reversed()
  }
}

public struct IntGenerator: Arbitrary {
  public typealias GeneratedValue = Int

  public var valueRange = (-100...100)


  public func generate(with rng: inout some RandomNumberGenerator) -> GeneratedValue {
    Int.random(in: valueRange, using: &rng)
  }

  /// For `Int`s, just shrink towards zero like a UInt for simplicity
  public func shrink(atMost value: GeneratedValue) -> [GeneratedValue] {
    guard value >= 0 else {
      return [value, 0]
    }

    var value = value
    var candidates = [Int]()

    while value > 0 {
      candidates.append(value)
      value /= 2
    }
    return [0] + candidates.reversed()
  }
}

public struct IntArrayGenerator: Arbitrary {
  public typealias GeneratedValue = [Int]

  public var valueRange = (-100...100)
  public var maxSize: UInt = 100

  /// Generates a random length list with random elements inside it
  public func generate(with rng: inout some RandomNumberGenerator) -> [Int] {
    let length = UInt.random(in: 0...maxSize, using: &rng)
    return (0..<length).map { _ in
      Int.random(in: valueRange, using: &rng)
    }
  }

  /// Shrinks by removing items from the beginning of the list
  public func shrink(atMost maximum: [Int]) -> [[Int]] {
    if maximum.isEmpty {
      return [[]]
    }
    return shrink(atMost: Array(maximum[1...])) + [maximum]
  }
  
}
