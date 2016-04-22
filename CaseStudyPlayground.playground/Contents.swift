//: Playground - noun: a place where people can play

import UIKit

///
/// Case study #1 (Immutable linked list)
///

indirect enum List<X> {
  case Nil
  case Cons(X, List<X>)
}

// 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> Nil
let intList: List<Int> = .Cons(1, .Cons(2, .Cons(3, .Cons(4, .Cons(5, .Cons(6, .Nil))))))

// "a" -> "b" -> "c" -> "d" -> "e" -> Nil
let strList: List<String> = .Cons("a", .Cons("b", .Cons("c", .Cons("d", .Cons("e", .Nil)))))

// 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> Nil ======> 21
// 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> Nil ======> 720

func reduce<E, R>(list: List<E>, initial: R, combine: (E, R)->R) -> R {
  switch list {
  case .Nil:
    return initial
  case let .Cons(value, rest):
    return combine(value, reduce(rest, initial: initial, combine: combine))
  }
}

func sumList(list: List<Int>) -> Int {
  return reduce(list, initial: 0, combine: +)
}

func productList(list: List<Int>) -> Int {
  return reduce(list, initial: 1, combine: *)
}

sumList(intList)
productList(intList)

func concatenate(list: List<String>) -> String {
  return reduce(list, initial: "", combine: +)
}

concatenate(strList)

// 1 -> 2 -> Nil ======> 1 -> 2 -> Nil

func cons<X>(value: X, rest: List<X>) -> List<X> {
  return .Cons(value, rest)
}

func copy<X>(list: List<X>) -> List<X> {
  return reduce(list, initial: .Nil, combine: { cons($0, rest: $1) })
}

func show(list: List<Int>) -> String {
  return reduce(list, initial: "", combine: { "\($0) \($1)" })
}

show(copy(intList))

// 1 -> 2 -> Nil ======> 2 -> 4 -> Nil

func map<X, Y>(list: List<X>, transform: X -> Y) -> List<Y> {
  return reduce(list, initial: .Nil, combine: { cons(transform($0), rest: $1) })
}

func double(x: Int) -> Int {
  return x * 2
}

func doubleall(list: List<Int>) -> List<Int> {
  return map(list, transform: double)
}

func increment(n: Int) -> Int {
  return n + 1
}

func incrementall(list: List<Int>) -> List<Int> {
  return map(list, transform: increment)
}

show(doubleall(intList))

///
/// Case study #2 (Run-length encoding: "AAABBCCCCAAA" -> "A3B2C4A3")
///

// Imperative programming approach (hard to understand and debug)
func rleImperative(input: String) -> String {
  guard let firstChar = input.characters.first else {
    return ""
  }
  
  var counter: Int = 0
  var prevChar: Character = firstChar
  var result: String = ""
  
  for c in input.characters {
    if c == prevChar {
      counter += 1
    } else {
      result += "\(prevChar)\(counter)"
      counter = 1
      prevChar = c
    }
  }
  
  if counter != 0 {
    result += "\(prevChar)\(counter)"
  }
  
  return result
}

rleImperative("AAABBCCCCAAA")
rleImperative("")
rleImperative("A")

// 0. Preparation
// Function composition helper (works like UNIX pipe)
infix operator >>> { associativity left }
func >>> <A, B, C>(f: B -> C, g: A -> B) -> A -> C {
  return { x in f(g(x)) }
}

// "AAABBCCCCAAA" -> [(A, 3), (B, 2), (C, 4), (A, 3)] -> "A3B2C4A4"

  // 1. "AAABBCCCCAAA" -> ["AAA", "BB", "CCCC", "AAA"] -> [(A, 3), (B, 2), (C, 4), (A, 3)]

    // 1.1 "AAABBCCCCAAA" -> ["AAA", "BB", "CCCC", "AAA"]

    // ("AABBCC", ==) -> ("AA", "BBCC")
    func takeWhile<T>(xs: [T], predicate: T -> Bool) -> ([T], [T]) {
      guard let first = xs.first else { return ([], []) }
      if predicate(first) {
        let (matched, rest) = takeWhile(Array(xs.dropFirst()), predicate: predicate)
        return ([first] + matched, rest)
      } else {
        return ([], xs)
      }
    }

    func groupby<T: Equatable>(xs: [T]) -> [[T]] {
      guard let first = xs.first else { return [] }
      
      let (matched, rest) = takeWhile(Array(xs.dropFirst()), predicate: { $0 == first })
      return [[first] + matched] + groupby(rest)
    }

    func group(str: String) -> [String] {
      return groupby(Array(str.characters)).map { String($0) }
    }

    // 1.2 ["AAA", "BB", "CCCC", "AAA"] -> [(A, 3), (B, 2), (C, 4), (A, 3)]
    func toLengthPair(strs: [String]) -> [(Character, Int)] {
      return strs.map { ($0.characters.first!, $0.characters.count) }
    }

  let toCharAndRunLength1: String -> [(Character, Int)] = toLengthPair >>> group

  // 2. [(A, 3), (B, 2), (C, 4), (A, 3)] -> "A3B2C4A4"

    // 2.1 [(A, 3), (B, 2), (C, 4), (A, 3)] -> ["A3", "B2", "C4", "A4"]

    func rl2str(pair: (Character, Int)) -> String {
      return "\(pair.0)\(pair.1)"
    }

    func pair2strs(groups: [(Character, Int)]) -> [String] {
      return groups.map(rl2str)
    }

    // 2.2 ["A3", "B2", "C4", "A4"] -> "A3B2C4A4"

    func cat(strs: [String]) -> String {
      return strs.joinWithSeparator("")
    }

  let fromCharAndRunLength1: [(Character, Int)] -> String = cat >>> pair2strs

let rle: String -> String = fromCharAndRunLength1 >>> toCharAndRunLength1

rle("AAABBCCCCAAA") // "A3B2C4A3"
rle("")             // ""
rle("A")            // "A1"

// Generic module works on any type
groupby([1, 1, 2, 3, 3, 3])

